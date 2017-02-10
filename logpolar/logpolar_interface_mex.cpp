#include <iostream>
#include <math.h>
#include <cmath>
#include <vector>
#include "opencv2/opencv.hpp"
#include "opencv2/core/core.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/contrib/contrib.hpp"
#include "mex.h"
#include "foveal_handle.hpp"
#include "mc_convert/mc_convert.hpp"
#include <string>
#include "MxArray.hpp"

class FoveatedObjects
{
public:
    FoveatedObjects(int width, int height, cv::Point2i center, int R, double ro0,
            int interp, int full, int S, int sp, bool pre_compute_=false) :
                logpolar_object(cv::LogPolar_Interp(width,
                        height,
                        center,
                        R,
                        ro0,
                        interp,
                        full,
                        S,
                        sp))
                {
                    
                    if(pre_compute_)
                    {
                        double total_iterations=width*height;
                        std::cout << "pre-compute objects"<< std::endl;
                        
                        // PRE-ALLOCATE SPACE
                        logpolar_objects.resize(width);
                        for(int w=0; w<width; ++w)
                        {
                            logpolar_objects[w].resize(height);
                        }
                        
                        for(int w=0; w<width; ++w)
                        {
                            for(int h=0; h<height; ++h)
                            {
                                cv::Point2i center_(w,h);
                                logpolar_objects[w][h] = cv::LogPolar_Interp(width,
                                        height,
                                        center_,
                                        R,
                                        ro0,
                                        interp,
                                        full,
                                        S,
                                        sp);
                                //std::cout << "size of:" << sizeof(logpolar_objects[w][h]) << std::endl;
                                double iteration=h+w*height;
                                std::cout << iteration << " out of " << total_iterations << " ("<< 100.0*iteration/total_iterations <<"%)"<<std::endl;
                            }
                        }
                    }
                }
                
                std::vector<std::vector<cv::LogPolar_Interp> > logpolar_objects;
                cv::LogPolar_Interp logpolar_object;
                
                friend class boost::serialization::access;
                template<class Archive>
                        void serialize(Archive & ar, const unsigned int version)
                {
                    ar & logpolar_objects;
                    ar & logpolar_object;
                }
};

BOOST_SERIALIZATION_SPLIT_FREE(::cv::Mat)
namespace boost {
  namespace serialization {
 
    /** Serialization support for cv::Mat */
    template
    void save(Archive & ar, const ::cv::Mat& m, const unsigned int version)
    {
      size_t elem_size = m.elemSize();
      size_t elem_type = m.type();
 
      ar & m.cols;
      ar & m.rows;
      ar & elem_size;
      ar & elem_type;
 
      const size_t data_size = m.cols * m.rows * elem_size;
      ar & boost::serialization::make_array(m.ptr(), data_size);
    }
 
    /** Serialization support for cv::Mat */
    template
    void load(Archive & ar, ::cv::Mat& m, const unsigned int version)
    {
      int cols, rows;
      size_t elem_size, elem_type;
 
      ar & cols;
      ar & rows;
      ar & elem_size;
      ar & elem_type;
 
      m.create(rows, cols, elem_type);
 
      size_t data_size = m.cols * m.rows * elem_size;
      ar & boost::serialization::make_array(m.ptr(), data_size);
    }
 
  }
}

/*namespace boost
{
    namespace serialization
    {
        
        template<class Archive>
                void serialize(Archive & ar, cv::LogPolar_Interp& g, const unsigned int version)
        {
            ar & g.Rsri;
            ar & g.Csri;
            ar & g.S; 
            ar & g.R;
            ar & g.M; 
            ar & g.N;
            ar & g.top;
            ar & g.bottom;
            ar & g.left;
            ar & g.right;
            ar & g.ro0;
            ar & g.romax;
            ar & g.a;
            ar & g.q;
            ar & g.interp;
            ar & g.ETAyx;
            ar & g.CSIyx;
        }
        
    } // namespace serialization
} // namespace boost
*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Get the command string
    char cmd[64];
    if (nrhs < 1 || mxGetString(prhs[0], cmd, sizeof(cmd)))
        mexErrMsgTxt("First input should be a command string less than 64 characters long.");
    
    // New
    if (!strcmp("new", cmd))
    {
        // Check parameters
        std::cout << "nrhs: " << nrhs << std::endl;
        if(nrhs!=12)
        {
            mexErrMsgTxt("wrong inputs number");
        }
        // Convert from matlab to opencv
        double *width = (double *) mxGetPr(prhs[1]);
        double *height = (double *) mxGetPr(prhs[2]);
        double *xc = (double *) mxGetPr(prhs[3]);
        double *yc = (double *) mxGetPr(prhs[4]);
        cv::Point2i center(*xc,*yc);
        double *nrings = (double *) mxGetPr(prhs[5]);
        double *rmin = (double *) mxGetPr(prhs[6]);
        double *interp = (double *) mxGetPr(prhs[7]);
        double *full = (double *) mxGetPr(prhs[8]);
        double *nsectors = (double *) mxGetPr(prhs[9]);
        double *sp = (double *) mxGetPr(prhs[10]);
        double pre_compute_ = *(double *) mxGetPr(prhs[11]);
        
        
        std::cout << "width:" << *width << std::endl;
        std::cout << "height:" << *height << std::endl;
        std::cout << "xc:" << *xc << std::endl;
        std::cout << "yc:" << *yc << std::endl;
        std::cout << "center:" << center << std::endl;
        std::cout << "nrings:" << (int)*nrings<< std::endl;
        std::cout << "rmin:" << *rmin << std::endl;
        std::cout << "interp:" << *interp << std::endl;
        std::cout << "full:" << *full << std::endl;
        std::cout << "nsectors:" << *nsectors << std::endl;
        std::cout << "sp:" << *sp << std::endl;
        std::cout << "pre_compute_:" << pre_compute_ << std::endl;
        bool pre_allocate=(*(int *) mxGetPr(prhs[11]) > 0);
        
        FoveatedObjects * foveated_objects(new FoveatedObjects(*width,
                *height,
                center,
                (int)*nrings,
                *rmin,
                (int)*interp,
                (int)*full,
                (int)*nsectors,
                (int)*sp,
                pre_compute_));
        
        plhs[0] = convertPtr2Mat<FoveatedObjects>(foveated_objects);
        
        std::string file_name="~/test.bin";
        std::ofstream ofs(file_name.c_str());
        // save data to archive
        {
            boost::archive::binary_archive(ofs);
            // write class instance to archive
            oa << foveated_objects;

            // archive and stream closed when destructors are called
        }
        
        return;
    }
    
// Check there is a second input, which should be the class instance handle
    if (nrhs < 2)
        mexErrMsgTxt("Second input should be a class instance handle.");
    
// Delete
    if (!strcmp("delete", cmd)) {
        // Destroy the C++ object
        destroyObject<cv::LogPolar_Interp>(prhs[1]);
        // Warn if other commands were ignored
        if (nlhs != 0 || nrhs != 2)
            mexWarnMsgTxt("Delete: Unexpected arguments ignored.");
        return;
    }
    
    // Get the class instance pointer from the second input
    cv::LogPolar_Interp *class_instance = convertMat2Ptr<cv::LogPolar_Interp>(prhs[1]);
    
    // Call the various class methods
    // to_cortical
    if (!strcmp("to_cortical", cmd))
    {
        // Check parameters
        if (nrhs !=3)
            mexErrMsgTxt("to_cortical: Unexpected arguments.");
        
        // Convert from matlab to opencv
        const mwSize* size=mxGetDimensions(prhs[2]);
        const cv::Mat opencv_const=cv::Mat(size[1],size[0],CV_8UC1,mxGetData(prhs[2]),0);
        
        // Call the method
        cv::Mat cortical=class_instance->to_cortical(opencv_const);
        
        // Convert from opencv to matlab
        plhs[0]=Converter(cortical);
        
        return;
    }
    
    // to_cartesian
    if (!strcmp("to_cartesian", cmd))
    {
        // Check parameters
        if (nrhs !=3)
            mexErrMsgTxt("to_cartesian: Unexpected arguments.");
        
        // Convert from matlab to opencv
        const mwSize* size=mxGetDimensions(prhs[2]);
        const cv::Mat opencv_const=cv::Mat(size[1],size[0],CV_8UC1,mxGetData(prhs[2]),0);
        
        // Call the method
        cv::Mat cartesian=class_instance->to_cartesian(opencv_const);
        
        // Convert from opencv to matlab
        plhs[0]=Converter(cartesian);
        
        return;
    }
    
// Got here, so command not recognized
    mexErrMsgTxt("Command not recognized.");
}
#include <iostream>
#include <math.h>
#include <cmath>
#include <vector>
#include "opencv2/opencv.hpp"
#include "opencv2/core/core.hpp"
#include <opencv2/highgui/highgui.hpp>
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/contrib/contrib.hpp"
#include "mex.h"
#include "foveal_handle.hpp"
#include "mc_convert/mc_convert.hpp"
#include <string>
#include "MxArray.hpp"
#include <conio.h>


using namespace cv;

class LaplacianBlending
{
public:
    cv::Mat image;
    int levels;
    
    std::vector<Mat> kernels;
    
    std::vector<Mat> imageLapPyr;
    std::vector<Mat> foveatedPyr;
    std::vector<cv::Mat> image_sizes;
    std::vector<cv::Mat> kernel_sizes;
    
    Mat imageSmallestLevel;
    Mat down,up;           
    Mat foveated_image;

    void buildPyramids()
    {
        imageLapPyr.clear();
        Mat currentImg = image;
        
        for (int l=0; l<levels; l++)
        {
            Mat image;
            pyrDown(currentImg, down);
            pyrUp(down, up, currentImg.size());
            
            Mat lap = currentImg - up;
//             imshow( "Display window ", lap );            
//             getch();            
//             
            
            imageLapPyr[l]=lap;
            
            currentImg = down;
        }
        
        imageSmallestLevel=up;
        
    }
    
public:
    LaplacianBlending(const cv::Mat& _image,const int _levels, std::vector<Mat> _kernels):
        image(_image),levels(_levels), kernels(_kernels)
        {
            image.convertTo(image,CV_64F);
            imageLapPyr.resize(levels);
            foveatedPyr.resize(levels);
            
            buildPyramids();
            image_sizes.resize(levels);
            kernel_sizes.resize(levels);
            for(int i=levels-1; i>=0;--i)
            {
                cv::Mat image_size(2,1,CV_32S);
                
                image_size.at<int>(0,0)=imageLapPyr[i].cols;
                image_size.at<int>(1,0)=imageLapPyr[i].rows;
                image_sizes[i]=image_size;
                
                cv::Mat kernel_size(2,1,CV_32S);
                
                kernel_size.at<int>(0,0)=kernels[i].cols;
                kernel_size.at<int>(1,0)=kernels[i].rows;
                kernel_sizes[i]=kernel_size;
            }
        };



	void computeRois(const cv::Mat & center,
		cv::Rect & kernel_roi_rect,
		cv::Mat & kernel_size,
		const cv::Mat & image_size)
	{
		// Kernel center - image coordinate
		cv::Mat upper_left_kernel_corner = kernel_size / 2.0 - center;;
		cv::Mat bottom_right_kernel_corner = image_size - center + kernel_size / 2.0;

		// encontrar roi no kernel
		kernel_roi_rect = cv::Rect(
			upper_left_kernel_corner.at<int>(0, 0),
			upper_left_kernel_corner.at<int>(1, 0),
			image_size.at<int>(0, 0),
			image_size.at<int>(1, 0));
	}

        cv::Mat foveate(const cv::Mat & center)
        {
            imageSmallestLevel.copyTo(foveated_image);
            cv::Rect kernel_roi_rect;
            
            for(int i=levels-1; i>=0;--i)
            {
                cv::Rect image_roi_rect;
                cv::Rect kernel_roi_rect;
                // rows

                
                // encontrar rois
                
                cv::Mat aux;
                if(i!=0)
                {
                    aux=center/(powf(2,i));
                }
                else
                {
                    aux=center;
                }
                computeRois(aux,kernel_roi_rect,kernel_sizes[i],image_sizes[i]);
                
                // Multiplicar
                cv::Mat aux_pyr;
                imageLapPyr[i].copyTo(aux_pyr);
                cv::Mat result_roi;
                cv::multiply(aux_pyr,kernels[i](kernel_roi_rect),result_roi,1.0);
                result_roi.copyTo(aux_pyr);
                if(i==(levels-1))
                {
                    add(foveated_image,aux_pyr,foveated_image);
                }
                
                else
                {
                    
                    pyrUp(foveated_image,foveated_image,cv::Size(2*foveated_image.cols,2*foveated_image.rows));
                    //resize(foveated_image, foveated_image, cv::Size(2*foveated_image.cols,2*foveated_image.rows), 0, 0, 0);
                    cv::add(foveated_image,aux_pyr,foveated_image);
                }
            }

            
            return foveated_image;
        }
        
        
        
};




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
        
        
        /*if(nrhs!=7)
         * {
         * mexErrMsgTxt("wrong inputs number");
         * }*/
        const cv::Mat image=MxArray(prhs[1]).toMat();
        double levels =*(double *) mxGetPr(prhs[2]);
        vector<Mat> kernels;/*=MxArray(prhs[3]).toMat();*/
        mxArray *cellElement;
        int nfields = mxGetNumberOfElements(prhs[3]);
        
        for(int i=0; i<nfields;++i)
        {
            cellElement = mxGetCell(prhs[3],i);
            const cv::Mat aux=MxArray(cellElement).toMat();
            kernels.push_back(aux);
            kernels[i].convertTo(kernels[i],CV_64F);
        }
        LaplacianBlending *laplacian(new LaplacianBlending(image,(int)levels, kernels));
        plhs[0]=convertPtr2Mat<LaplacianBlending>(laplacian);
        
        return;
    }
    
// Check there is a second input, which should be the class instance handle
    if (nrhs < 2)
        mexErrMsgTxt("Second input should be a class instance handle.");
    
// Delete
    if (!strcmp("delete", cmd)) {
        // Destroy the C++ object
        destroyObject<LaplacianBlending>(prhs[1]);
        // Warn if other commands were ignored
        if (nlhs != 0 || nrhs != 2)
            mexWarnMsgTxt("Delete: Unexpected arguments ignored.");
        return;
    }
    
    LaplacianBlending *laplacian = convertMat2Ptr<LaplacianBlending>(prhs[1]);
    
    if (!strcmp("get_pyramid", cmd))
    {
        if(nrhs!=2)
        {
            std::cout << "nrhs: " << nrhs << std::endl;
            mexErrMsgTxt("wrong inputs number");
            std::cout << "nrhs: " << nrhs << std::endl;
        }
//         for(int i=0; i<laplacian->levels; ++i)
//         {
            cv::Mat aux;
            laplacian->imageLapPyr[0].convertTo(aux,CV_8U);
            plhs[0]=Converter(aux);
            
//         }
        
        return;
    }
    
    if (!strcmp("foveate", cmd))
    {
        if(nrhs!=3)
        {
            std::cout << "nrhs: " << nrhs << std::endl;
            mexErrMsgTxt("wrong inputs number");
        }
        
        
        const cv::Mat center=MxArray(prhs[2]).toMat();
        cv::Mat center_aux;
        center.convertTo(center_aux,CV_32S);
        
        cv::Mat foveated_image=laplacian->foveate(center_aux);
        foveated_image.convertTo(foveated_image,CV_8U);
        
        plhs[0]=Converter(foveated_image);
        return;
    }
    
// Got here, so command not recognized
    mexErrMsgTxt("Command not recognized.");
}
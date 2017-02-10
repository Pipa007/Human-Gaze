% linux mex compilation
mex logpolar_interface_mex.cpp mc_convert/mc_convert.cpp -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_contrib -lopencv_calib3d
mex laplacian_interface_mex.cpp  MxArray.cpp mc_convert/mc_convert.cpp -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_contrib -lopencv_calib3d

% windows mex compilation
mexOpenCV -IC:\boost_1_54_0\  logpolar_interface_mex.cpp  mc_convert/mc_convert.cpp -lopencv_core249 -lopencv_imgproc249 -lopencv_highgui249 -lopencv_contrib249 -lopencv_calib3d249
mexOpenCV -IC:\boost_1_54_0\  laplacian_interface_mex.cpp MxArray.cpp mc_convert/mc_convert.cpp -lopencv_core249 -lopencv_imgproc249 -lopencv_highgui249 -lopencv_contrib249 -lopencv_calib3d249


% main.m contains an example application

NRINGS=100;
NSECTORS=200;
RMIN=0.01;
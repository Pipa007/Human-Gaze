clc
close all
clear all

NRINGS=200;
NSECTORS=200;
RMIN=0.01;

img=imread('peppers.png');
height=size(img,1);
width=size(img,2);
img=rgb2gray(img);
%Make it circular
%R=min(NROWS,NCOLS)/2.0;
%img = imcrop(img,[NROWS/2.0-R+1 NCOLS/2.0-R+1 R R]);

%RMAX=0.5*min(M,N);
%syms NRINGS

%eq=RMAX^2*pi/NRINGS==2*pi/(exp(log(RMAX/RMIN)/NRINGS)-1);
%NRINGS=abs(round(double(solve(eq,NRINGS))));
%NSECTORS=abs(round(RMAX^2*pi/NRINGS));

interp=1;
full=1;
sp=0;

pre_allocate=1;
%% Initialize foveal stereo object
logpolar_mex_ = logpolar_interface(...
            width,...
            height,...
            width/2.0,...
            height/2.0,...
            NRINGS,...
            RMIN,...
            interp,...
            full,...
            NSECTORS,...
            sp,...
            pre_allocate);

%save('teste.mat',logpolar_mex_);
himg = imshow(img_cart_back);
logpolar_interface.write_file(logpolar_mex_,'test');
return
for i=1:30
    for j=1:30
        tic
        xc=width/2+i*3;
        yc=height/2+j*3;
        
        logpolar_mex_ = logpolar_interface(...
            width,...
            height,...
            xc,...
            yc,...
            NRINGS,...
            RMIN,...
            interp,...
            full,...
            NSECTORS,...
            sp);
        
        
        img_logpolar=to_cortical(logpolar_mex_,img');
        img_cart_back = to_cartesian(logpolar_mex_,img_logpolar');
        toc
        set(himg, 'CData', img_cart_back);  %instead of imshow
        drawnow
        clear logpolar_mex_;
        
    end
end


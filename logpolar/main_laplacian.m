clc
close all
%clear all
% NRINGS=200;
% NSECTORS=200;
% RMIN=0.01;
img=imread('C:\Users\Ana Filipa\Desktop\Tese\UBUNTU TESE\PycharmProjects\Validation Set\ILSVRC2012_val_00000001.JPEG');
  % img= imresize(img ,[768 1024], 'bilinear');
 %  imshow(img);
% create kernel
height=size(img,1);
width=size(img,2);
% img=rgb2gray(img);

%  List Jpg files         
myFolder = 'C:\Users\Ana Filipa\Desktop\Tese\UBUNTU TESE\PycharmProjects\Validation Set';
filePattern = fullfile(myFolder, '*.JPEG');
jpgFiles = dir(filePattern);


p=4;
%data=sprintf('%d.mat',p);
%data=strcat('C:\Users\Bastos\Dropbox\thesis\Eye Tracking\Data Colected\Data_User_',data);
%load(data);
%        r=18
%        cordX=Data.GazeSearch(r).gazeCordX;
%        cordX=cordX(cordX~=0);
%        cordY=Data.GazeSearch(r).gazeCordY;
%        cordY=cordY(cordY~=0);

%img = jpgFiles(Data.User.ImagesSearch_Test(r)).name;

%cutoff=10;
sigma = 10;
levels= 5;

%m = min(cutoff*sigma,size(img,1)); n = min(cutoff*sigma,size(img,2));

for i=1:levels
    % four times bigger than original image to guarantee that...
    m=size(img,1)*4/(2^(i-1)); n=size(img,2)*4/(2^(i-1));
    
    [h1, h2] = meshgrid(-(n-1)/2:(n-1)/2,-(m-1)/2:(m-1)/2);
    hg = exp(- 0.5*(h1.^2+h2.^2) / (i*sigma).^2);
    
    kernel_aux=0.1*ones(m,n,3);
    
    kernel_aux(:,:,1)=hg ./ sum(hg(:));
    kernel_aux(:,:,2)=kernel_aux(:,:,1);
    kernel_aux(:,:,3)=kernel_aux(:,:,1);
    
    % normalize
    kernel_aux(:,:,1) =  kernel_aux(:,:,1)/max(max(abs(kernel_aux(:,:,1))));
    kernel_aux(:,:,2) =  kernel_aux(:,:,2)/max(max(abs(kernel_aux(:,:,2))));
    kernel_aux(:,:,3) =  kernel_aux(:,:,3)/max(max(abs(kernel_aux(:,:,3))));
    
    kernel{i}=kernel_aux;
end


%myVideo =  VideoWriter('myfile.avi', 'Uncompressed AVI');

%myVideo.FrameRate = 10;  % Default 30



%% Initialize foveal stereo object
tic()
laplacian_mex_ = laplacian_interface(img, levels, kernel);
toc()
pyramid={1,levels};
tic()

[B]=get_pyramid(laplacian_mex_);
toc()
%figure('menuBar', 'none', 'name', 'Image Display', 'keypressfcn', 'close;');


f=scatter (100,50,10, 'r');
pauseTimeInSeconds = 0.01;
durationInSeconds = 10*1;
        cordX=Data.GazeSearch(r).gazeCordX;
        cordX=cordX(cordX~=0);
        cordX=cordX(cordX~=512);
        cordY=Data.GazeSearch(r).gazeCordY;
        cordY=cordY(cordY~=0);
        cordY=cordY(cordY~=384);

%open(myVideo);
%for i=1:size(cordX,2)/2
%     for j=1:100:height
        
        
     
         center=[0 0]'
%        center=[cordX(i) cordY(i)]'

        tic()
        foveated_image=foveate(laplacian_mex_,center);
        toc()

    imshow(foveated_image);
    hold on 
    delete(f);
%    f = scatter (center(1),center(2), 'r','filled');
%        axis on;
%    grid on;
   
   %writeVideo(myVideo, foveated_image);
%     axis equal;
%     hold off
%    end
%end








close(myVideo);




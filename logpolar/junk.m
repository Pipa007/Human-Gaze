



img=imread('C:\Users\vislab\Documents\thesis\Eye Tracking\images\bathroom_1_c_l_towel.jpg');
  % img= imresize(img ,[768 1024], 'bilinear');
 %  imshow(img);
% create kernel
height=size(img,1);
width=size(img,2);
% img=rgb2gray(img);


%cutoff=10;
sigma = 3;
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
M=[];
M=kernel{5};


s = size(M);
[z,x] = ndgrid(1:s(1),1:s(2));
data = permute(num2cell(cat(3,x,M,z),  2),[3,2,1]);
plot3(data{:});



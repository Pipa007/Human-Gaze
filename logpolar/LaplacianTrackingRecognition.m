function [leftEyeAll, rightEyeAll, timeStampAll]=LaplacianTrackingRecognition(Calib, img, sigma)

global KEY_IS_PRESSED
KEY_IS_PRESSED = 0;

leftEyeAll = zeros(1,200);
rightEyeAll = zeros(1,200);
timeStampAll = zeros(1,200);

screenSize = get(0,'screensize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);


height=size(img,1);
width=size(img,2);

%cutoff=10;
%sigma = 5;
levels= 5;


for i=1:levels
    % four times bigger than original image to guarantee that...
    m=size(img,1)*4/(2^(i-1)); n=size(img,2)*4/(2^(i-1));
    
    [h1, h2] = meshgrid(-(n-1)/2:(n-1)/2,-(m-1)/2:(m-1)/2);
    hg = exp(- 0.5*(h1.^2+h2.^2) / (i*sigma)^2);
    
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

 laplacian_mex_ = laplacian_interface(img, levels, kernel);
   
 center=[width/2.0 height/2.0]';
    
 foveated_image=foveate(laplacian_mex_,center); 

%%%%%%%%%%%%%
%display task
%%%%%%%%%%%%%
    figure('Name','figure 1',...
        'Numbertitle','off',...
        'Position', [0 0 1280 1024],...
        'WindowStyle','modal',...
        'Color',[0.8 0.8 0.8],...
        'Toolbar','none');
%  figH = figure('menuBar','none','name','Calibrate','Color', Calib.bkcolor,'Renderer', 'Painters','keypressfcn','close;');


Calib.mondims = Calib.mondims1;
set(gcf,'position', [Calib.mondims.x Calib.mondims.y Calib.mondims.width Calib.mondims.height]);


xlim([1,Calib.mondims.width]); ylim([1,Calib.mondims.height]);axis ij;
set(gca,'xtick',[]);set(gca,'ytick',[]);
htext1 = text(double(0.5*Calib.mondims.width), double(0.5*Calib.mondims.height),...
    'Identifique o objecto que se encontra na imagem',...
    'HorizontalAlignment','center',... 
	'BackgroundColor',[.7 .9 .7],...
    'FontSize',18);

for i = 2:-1:1
htext2 = text(double(0.5*Calib.mondims.width),double(0.6*Calib.mondims.height),...
    ['Starting in ' num2str(i) ' seconds'],...
    'HorizontalAlignment','center',... 
	'BackgroundColor',[.7 .9 .7],...
    'FontSize',18);
    pause(1);
    delete(htext2);
end

%%%%%%%%%%%%%%%%%
%display stimulus
%%%%%%%%%%%%%%%%%

    
    figure('Name','figure 1',...
        'Numbertitle','off',...
        'Position', [0 0 screenWidth screenHeight],...
        'WindowStyle','modal',...
        'Color',[1 1 1],...
        'Toolbar','none');
   % figH = figure('menuBar','none','name','Calibrate','Color', Calib.bkcolor,'Renderer', 'Painters','keypressfcn','close;');
    himg = imshow(foveated_image,'InitialMagnification','fit');

% 
%     axes('Visible', 'off', 'Units', 'normalized',...
%     'Position', [0 0 1 1],...
%     'DrawMode','fast',...
%     'NextPlot','replacechildren');
%     
%     
%     axes('Visible', 'off', 'Units', 'normalize','Position', [0 0 1 1],'DrawMode','fast','NextPlot','replacechildren');
%     Calib.mondims = Calib.mondims1;
%     set(figH,'position',[Calib.mondims.x Calib.mondims.y Calib.mondims.width Calib.mondims.height]);
 
    gcf;
    set(gcf, 'KeyPressFcn', @myKeyPressFcn);


index=1;
index2=1;
tic;
while (~KEY_IS_PRESSED)   
    [lefteye, righteye, timestamp, trigSignal] = tetio_readGazeData;
    timerVal=toc;
    rightGazePoint2d.x = righteye(:,7);
    rightGazePoint2d.y = righteye(:,8);
    leftGazePoint2d.x = lefteye(:,7);
    leftGazePoint2d.y = lefteye(:,8);
    gaze.x = mean([rightGazePoint2d.x, leftGazePoint2d.x],2);
    gaze.y = mean([rightGazePoint2d.y, leftGazePoint2d.y],2);

    gazeX=CoordinateChangeX(screenWidth,width, mean(gaze.x));
    gazeY=CoordinateChangeY(screenHeight, height, mean(gaze.y));
    
    if (gazeX < 0 || gazeX > width || gazeY <0 || gazeY > height)
        continue
    end 
    
    center=[gazeX gazeY]';
    foveated_image=foveate(laplacian_mex_,center); 
    
    set(himg, 'CData', foveated_image); 
    
    leftEyeAll(index:(index+length(gazeX)-1))= gazeX;
    rightEyeAll(index:(index+length(gazeY)-1)) = gazeY;
    timeStampAll(index2:(index2+length(timerVal)-1)) = timerVal;
    index=index+length(gazeX);
    index2=index2+length(timerVal);
   drawnow
    
   clear logpolar_mex_

end
close all
clc
end
function myKeyPressFcn(hObject, event)
global KEY_IS_PRESSED
KEY_IS_PRESSED  = 1;
disp('key is pressed') 
end
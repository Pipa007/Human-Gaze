function [leftEyeAll, rightEyeAll, timeStampAll, Answer]=LogpolarTrackingVideo(Calib, videoFReader)

global KEY_IS_PRESSED
KEY_IS_PRESSED = 0;

leftEyeAll = [];
rightEyeAll = [];
timeStampAll = [];

screenSize = get(0,'screensize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);

videoPlayer = vision.VideoPlayer('Position',[0  0 screenWidth screenHeight]);

% frame = readFrame(video);
frame = step(videoFReader);
height=size(frame,1);
width=size(frame,2);

%Create Kernels

    %cutoff=10;
    sigma = 5;
    levels=5;

for i=1:levels
    % four times bigger than original image to guarantee that...
    m=size(frame,1)*4/(2^(i-1)); n=size(frame,2)*4/(2^(i-1));
    
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

    laplacian_mex_ = laplacian_interface(frame, levels, kernel);
    pyramid={1,levels};
    get_pyramid(laplacian_mex_);

    
    center=[width/2.0 height/2.0]';
    
    foveated_image=foveate(laplacian_mex_,center); 
    
%     figure('Name','figure 1',...
%         'Numbertitle','off',...
%         'Position', [0 0 screenWidth screenHeight],...
%         'WindowStyle','modal',...
%         'Color',[1 1 1],...
%         'Toolbar','none');
   % figH = figure('menuBar','none','name','Calibrate','Color', Calib.bkcolor,'Renderer', 'Painters','keypressfcn','close;');
   % himg = imshow(foveated_image,'InitialMagnification','fit');

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
 


step(videoPlayer, foveated_image);

%  gcf;
%     set(gcf, 'KeyPressFcn', @myKeyPressFcn);
%     set(gcf, 'Position', [2000,2000, 0, 0]);
clear laplacian_mex_
tic;
while (toc<=10)
%while (~KEY_IS_PRESSED)   
    
    frame = step(videoFReader);
    
    laplacian_mex_ = laplacian_interface(frame, levels, kernel);
    
    [lefteye, righteye, timestamp, trigSignal] = tetio_readGazeData;
    timerVal=toc;
    rightGazePoint2d.x = righteye(:,7);
    rightGazePoint2d.y = righteye(:,8);
    leftGazePoint2d.x = lefteye(:,7);
    leftGazePoint2d.y = lefteye(:,8);
    gaze.x = mean([rightGazePoint2d.x, leftGazePoint2d.x],2);
    gaze.y = mean([rightGazePoint2d.y, leftGazePoint2d.y],2);

    if isempty(lefteye)
        continue;
    end
    
     [gazeX]=CoordinateChangeX(screenWidth,width, mean(gaze.x));
     [gazeY]=CoordinateChangeY(screenHeight, height, mean(gaze.y));


    if (gazeX < 0 || gazeX > width || gazeY <0 || gazeY > height)
        continue
    end 
    
    center=[gazeX gazeY]';
    foveated_image=foveate(laplacian_mex_,center); 
    step(videoPlayer, frame);
    
    %set(himg, 'CData', foveated_image); 
%     leftEyeAll= vertcat(leftEyeAll, gazeX);
%     rightEyeAll = vertcat(rightEyeAll, gazeY);
%     timeStampAll = vertcat(timeStampAll, timerVal);
    
    
    drawnow
    clear laplacian_mex_
    end

close all
hide(videoPlayer)

display('what was the action represented in the movie\n ');
display('1 - Hand Shaking');
display('2 - Hugging');
display('3 - Kicking');
display('4 - Pointing');
display('5 - Punching');
display('6 - Pushing');
prompt = 'Escolha um numero';
Answer = input(prompt,'s');
if isempty(Answer)
    
end

end
function myKeyPressFcn(hObject, event)
global KEY_IS_PRESSED
KEY_IS_PRESSED  = 1;
disp('key is pressed') 
end
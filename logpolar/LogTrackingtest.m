clc
clear all
close all
addpath('../tetio');
addpath('../Eye Tracking');

disp('Initializing tetio...');
tetio_init();

% Set to tracker ID to the product ID of the tracker you want to connect to.
trackerId = 'TT120-204-81500299';

fprintf('Connecting to tracker "%s"...\n', trackerId);
tetio_connectTracker(trackerId)

currentFrameRate = tetio_getFrameRate;
fprintf('Frame rate: %d Hz.\n', currentFrameRate);

load('calibration.mat');


screenSize = get(0,'screensize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);

img=imread('imagem3.jpg');
height=size(img,1);
width=size(img,2);
img=rgb2gray(img);

%parametros do logpolar
NRINGS=200;
NSECTORS=200;
RMIN=0.1;

%R=min(NROWS,NCOLS)/2.0;
%img = imcrop(img,[NROWS/2.0-R+1 NCOLS/2.0-R+1 R R]);
interp=1;
full=1;
sp=0;

% Initialize foveal stereo object

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
    sp);

img_logpolar = to_cortical(logpolar_mex_,img');
img_cart_back =  to_cartesian(logpolar_mex_,img_logpolar');

% hFig = figure('Name','figure 1',...
%     'Numbertitle','off',...
%     'Position', [0 0 screenWidth screenHeight],...
%     'WindowStyle','modal',...
%     'Color',[1 1 1],...
%     'Toolbar','none');
himg = imshow(img_cart_back,'InitialMagnification','fit');


% figure('menuBar', 'none', 'name', 'Image Display', 'keypressfcn', 'close;');
% himg=image(img_cart_back);
% axis equal;

axes('Visible', 'off', 'Units', 'normalized',...
    'Position', [0 0 1 1],...
    'DrawMode','fast',...
    'NextPlot','replacechildren');

Calib.mondims = Calib.mondims1;
set(gcf,'position', [Calib.mondims.x Calib.mondims.y Calib.mondims.width Calib.mondims.height]);

xlim([1,Calib.mondims.width]); ylim([1,Calib.mondims.height]);axis ij;
set(gca,'xtick',[]);set(gca,'ytick',[]);

tetio_startTracking;
pauseTimeInSeconds = 0.01;
durationInSeconds = 10*1;


 %f=scatter (0.5,0.5, 50, 'r','filled');
for i = 1:(durationInSeconds/pauseTimeInSeconds)
    
    
    %pause(pauseTimeInSeconds);
    
    [lefteye, righteye, timestamp, trigSignal] = tetio_readGazeData;
    rightGazePoint2d.x = righteye(:,7);
    rightGazePoint2d.y = righteye(:,8);
    leftGazePoint2d.x = lefteye(:,7);
    leftGazePoint2d.y = lefteye(:,8);
    gaze.x = mean([rightGazePoint2d.x, leftGazePoint2d.x],2);
    gaze.y = mean([rightGazePoint2d.y, leftGazePoint2d.y],2);
    
     x=mean(gaze.x)
     y=mean(gaze.y)

    [gazeX]=CoordinateChangeX(screenWidth,width, mean(gaze.x));
    [gazeY]=CoordinateChangeY(screenHeight, height, mean(gaze.y));
    
    logpolar_mex_ = logpolar_interface(...
        width,...
        height,...
        gazeX,...
        gazeY,...
        NRINGS,...
        RMIN,...
        interp,...
        full,...
        NSECTORS,...
        sp);
    
    img_logpolar=to_cortical(logpolar_mex_,img');
    img_cart_back = to_cartesian(logpolar_mex_,img_logpolar');
    
   
%     xlim([1,Calib.mondims.width]); ylim([1,Calib.mondims.height]);axis ij;
%     set(gca,'xtick',[]);set(gca,'ytick',[]);
    set(himg, 'CData', img_cart_back);  
     
% himg=image(img_cart_back );
% 
%  axis equal;
% 
% axes('Visible', 'off', 'Units', 'normalized',...
%     'Position', [0 0 1 1],...
%     'DrawMode','fast',...
%     'NextPlot','replacechildren');
% 
% Calib.mondims = Calib.mondims1;
% set(gcf,'position', [Calib.mondims.x Calib.mondims.y Calib.mondims.width Calib.mondims.height]);
% 
% xlim([1,Calib.mondims.width]); ylim([1,Calib.mondims.height]);axis ij;
% set(gca,'xtick',[]);set(gca,'ytick',[]);
    
%    hold on
    
%          delete(f);
%          f = scatter (gaze.x,gaze.y,50, 'r','filled');
%          axis([0 1 0 1]);
%          hold on
%     
    drawnow
     
    clear logpolar_mex_
    
end


tetio_stopTracking;
tetio_disconnectTracker;
tetio_cleanUp;


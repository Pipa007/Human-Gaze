function [leftEyeAll, rightEyeAll, timeStampAll, Answer]=LogpolarTracking(Calib, videoFReader)

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
frame1=rgb2gray(frame);

%parametros do logpolar
NRINGS=200;
NSECTORS=200;
RMIN=0.1;

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

img_logpolar = to_cortical(logpolar_mex_,frame1');
img_cart_back =  to_cartesian(logpolar_mex_,img_logpolar');

step(videoPlayer, img_cart_back);

 gcf;
    set(gcf, 'KeyPressFcn', @myKeyPressFcn);
    set(gcf, 'Position', [2000,2000, 0, 0]);

tic;
%while (toc<=4)
while (~KEY_IS_PRESSED)   
    
    frame = step(videoFReader);
    frame1=rgb2gray(frame);
    
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

    img_logpolar=to_cortical(logpolar_mex_,frame1');
    img_cart_back = to_cartesian(logpolar_mex_,img_logpolar');
    step(videoPlayer, img_cart_back);

    leftEyeAll= vertcat(leftEyeAll, gazeX);
    rightEyeAll = vertcat(rightEyeAll, gazeY);
    timeStampAll = vertcat(timeStampAll, timerVal);
    
   drawnow
    
   clear logpolar_mex_

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
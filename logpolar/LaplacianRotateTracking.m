function [GazeX, GazeY, GazeTargetX, GazeTargetY, timerValAll, timeStampAll]=LaplacianRotateTracking(Calib, img, obj, Task, Sigma)

    global KEY_IS_PRESSED
    KEY_IS_PRESSED = 0;

    
    % Alocate memory
    GazeX = zeros(1,200);
    GazeY= zeros(1,200);
    GazeTargetX = zeros(1,200);
    GazeTargetY= zeros(1,200);
    timerValAll = zeros(1,200);
    timeStampAll = zeros(1,200);

    % Screen resolution
    screenSize = get(0,'screensize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);

    
    img = imrotate( img , angle );
    height=size(img,1);
    width=size(img,2);
    
% *************************************************************************
%
% Create Kernel
%
% *************************************************************************

    %cutoff=10;
    %sigma = 5;
    levels= 5;

    for i=1:levels
        % four times bigger than original image to guarantee that...
        m=height*4/(2^(i-1)); n=width*4/(2^(i-1));

        [h1, h2] = meshgrid(-(n-1)/2:(n-1)/2,-(m-1)/2:(m-1)/2);
        hg = exp(- 0.5*(h1.^2+h2.^2) / (i*Sigma).^2);

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



% *************************************************************************
%
% Obtain Laplacian pyramid and first foveated image
%
% *************************************************************************

     laplacian_mex_ = laplacian_interface(img, levels, kernel);

     center=[width/2.0 height/2.0]';

     foveated_image=foveate(laplacian_mex_,center); 

% *************************************************************************
%
% Display task
%
% *************************************************************************
   
    figure('Name','figure 1',...
            'Numbertitle','off',...
            'Position', [0 0 1280 1024],...
            'WindowStyle','modal',...
            'Color',[0.8 0.8 0.8],...
            'Toolbar','none');
        
    imshow(obj,'InitialMagnification','fit');
       
%     Calib.mondims = Calib.mondims1;
%     set(gcf,'position', [Calib.mondims.x Calib.mondims.y Calib.mondims.width Calib.mondims.height]);
% 
%     xlim([1,Calib.mondims.width]); ylim([1,Calib.mondims.height]);axis ij;

    
    set(gca,'xtick',[]);set(gca,'ytick',[]);
    htext1 = text(double(0.5*screenWidth-100), double(0.5*screenHeight-100),...
        Task,...
        'HorizontalAlignment','center',... 
        'BackgroundColor',[.7 .9 .7],...
        'FontSize',18);
    

    for i = 2:-1:1
    htext2 = text(double(0.5*screenWidth-100),double(0.6*screenHeight-100),...
        ['Starting in ' num2str(i) ' seconds'],...
        'HorizontalAlignment','center',... 
        'BackgroundColor',[.7 .9 .7],...
        'FontSize',18);
        pause(1);
        delete(htext2);
    end
  
    
% *************************************************************************
%
% Display stimulus
%
% *************************************************************************

    figure('Name','figure 1',...
        'Numbertitle','off',...
        'Position', [0 0 screenWidth screenHeight],...
        'WindowStyle','modal',...
        'Color',[1 1 1],...
        'Toolbar','none');
    himg = imshow(foveated_image,'InitialMagnification','fit');

    set(gcf, 'KeyPressFcn', @myKeyPressFcn);

% *************************************************************************
%
% Start Tracking
%
% *************************************************************************    
        
    index=1;
    now2=tic();
    tetio_startTracking;
    while (~KEY_IS_PRESSED)   
        
        % Read Eye tracker
        [lefteye, righteye, timestamp, trigSignal] = tetio_readGazeData;
        timerVal=toc(now2);
        rightGazePoint2d.x = righteye(:,7);
        rightGazePoint2d.y = righteye(:,8);
        leftGazePoint2d.x = lefteye(:,7);
        leftGazePoint2d.y = lefteye(:,8);
        
        % Calculate gaze
        gaze.x = mean([rightGazePoint2d.x, leftGazePoint2d.x],2);
        gaze.y = mean([rightGazePoint2d.y, leftGazePoint2d.y],2);
   
        % Normalize 
        gazeX=CoordinateChangeX(screenWidth,width, mean(gaze.x));
        gazeY=CoordinateChangeY(screenHeight, height, mean(gaze.y));

        % Delete gaze out of the image 
        if (gazeX < 0 || gazeX > width || gazeY <0 || gazeY > height)
            continue
        end 

        % Obtain foveated image
        center=[gazeX gazeY]';
        foveated_image=foveate(laplacian_mex_,center); 

        % Show image
        set(himg, 'CData', foveated_image); 
        
        % Store
        GazeX(index)= gazeX;
        GazeY(index) = gazeY;
        timerValAll(index) = timerVal;
        if(length(timestamp)~=0)
            timeStampAll(index) = timestamp(end);
        else
            timeStampAll(index) = 0;
        end
        
        index=index+1;
        drawnow

        clear logpolar_mex_

    end
    
% *************************************************************************
%
% Conclude the Task by gazing the object
%
% *************************************************************************

    KEY_IS_PRESSED  = 0;
    htext1 = text(double(0.5*screenWidth-100), double(0.5*screenHeight-100),...
    'Gaze the Target and press a key again',...
    'HorizontalAlignment','center',... 
    'BackgroundColor',[.7 .9 .7],...
    'FontSize',18);
    
    for i = 2:-1:1
        htext2 = text(double(0.5*screenWidth-100),double(0.6*screenHeight-100),...
        ['Starting in ' num2str(i) ' seconds'],...
        'HorizontalAlignment','center',... 
        'BackgroundColor',[.7 .9 .7],...
        'FontSize',18);
        pause(1);
        delete(htext2);
    end
    delete(htext1);
    
    index=1;
    while(~KEY_IS_PRESSED)
        % Read Eye tracker
        [lefteye, righteye, timestamp, trigSignal] = tetio_readGazeData;
        rightGazePoint2d.x = righteye(:,7);
        rightGazePoint2d.y = righteye(:,8);
        leftGazePoint2d.x = lefteye(:,7);
        leftGazePoint2d.y = lefteye(:,8);
        
        % Calculate gaze
        gaze.x = mean([rightGazePoint2d.x, leftGazePoint2d.x],2);
        gaze.y = mean([rightGazePoint2d.y, leftGazePoint2d.y],2);
   
        % Normalize 
        gazeX=CoordinateChangeX(screenWidth,width, mean(gaze.x));
        gazeY=CoordinateChangeY(screenHeight, height, mean(gaze.y));

        % Delete gaze out of the image 
        if (gazeX < 0 || gazeX > width || gazeY <0 || gazeY > height)
            continue
        end 

        % Obtain foveated image
        center=[gazeX gazeY]';
        foveated_image=foveate(laplacian_mex_,center); 

        % Show image
        set(himg, 'CData', foveated_image); 
        
        % Store
        GazeTargetX(index)= gazeX;
        GazeTargetY(index) = gazeY;
  
        index=index+1;
        
        drawnow

        clear logpolar_mex_

    end
    
    tetio_stopTracking;
    close all    
    
    clc
end
%funtion to detect if a key is pressed
function myKeyPressFcn(hObject, event)
    global KEY_IS_PRESSED
    KEY_IS_PRESSED  = 1;
    disp('key is pressed') 
end
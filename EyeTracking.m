%
% EyeTrackingSample
%

clc 
clear all
close all

addpath('functions');
addpath('../tetio');  

% *************************************************************************
%
% Initialization and connection to the Tobii Eye-tracker
%
% *************************************************************************
 
disp('Initializing tetio...');
tetio_init();

% Set to tracker ID to the product ID of the tracker you want to connect to.
trackerId = 'TT120-204-81500299';

fprintf('Connecting to tracker "%s"...\n', trackerId);
tetio_connectTracker(trackerId)
	
currentFrameRate = tetio_getFrameRate;
fprintf('Frame rate: %d Hz.\n', currentFrameRate);

% *************************************************************************
%
% Calibration of a participant
%
% *************************************************************************

SetCalibParams; 

disp('Starting TrackStatus');
% Display the track status window showing the participant's eyes (to position the participant).
TrackStatus; % Track status window will stay open until user key press.
disp('TrackStatus stopped');

disp('Starting Calibration workflow');
% Perform calibration
HandleCalibWorkflow(Calib);
disp('Calibration workflow stopped');

% *************************************************************************
%
% Display a stimulus 
%
% *************************************************************************


displayStimulus(Calib,'imag.jpg');


% *************************************************************************
%
% Start tracking and plot the gaze data read from the tracker.
%
% *************************************************************************

Tracking;


% [leftEyeAll, rightEyeAll, timeStampAll]=startTracking();
% 
% DisplayData(leftEyeAll, rightEyeAll );
% 
% 
% % % Save gaze data vectors to file here using e.g:
% csvwrite('gazedataleft.csv', leftEyeAll);


disp('Program finished.');

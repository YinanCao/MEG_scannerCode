function PPxDraw1440HzDots3a

%This function draws a moving dot refreshing at 1440Hz. It demonstrates how
%to use the Psychtoolbox-3 function 'PsychPropixx' to queue and display
%frames. For documentation of this function, see
%"http://psychtoolbox.org/docs/PsychProPixx"

%Please note this function is maintained by the creators of Psychtoolbox.
%For demos showing how to drive the projector with VPixx Technologies' own
%Datapixx functions, please see PPxDraw1440HzDots and PPxDraw1440HzDots2

% To display at 1440 Hz, the PROPixx sequences takes a single 1920 x 1080
% image and deconstructs it in to four 960 x 540 quadrants.
%_____________________________
%|             |             |
%|     Q1      |      Q2     |
%|_____________|_____________|
%|             |             |
%|     Q3      |      Q4     |
%|_____________|_____________|  


%Quadrants are shown FULL SCREEN, GREYSCALE in the order: 
% Quadrant 1 red channel 
% Quadrant 2 red channel
% Quadrant 3 red channel
% Quadrant 4 red channel
% Quadrant 1 green channel
% Quadrant 2 green channel
% Quadrant 3 green channel
% Quadrant 4 green channel
% Quadrant 1 blue channel 
% Quadrant 2 blue channel 
% Quadrant 3 blue channel
% Quadrant 4 blue channel

%PsychPropixx('GetImageBuffer') creates a 960 x 540 image buffer which can
%be used to draw images. These are added to the frame queue using
%PsychProPixx('QueueImage'), and their position and colour channel are
%automatically assigned based on queue order. When the right number of
%frames is reached (12 in 1440 Hz mode, or 4 in 480 Hz mode), the queue
%contents are flipped automatically. 

% 2020 Apr 06       lef     written

%Check connection and open Datapixx if it's not open yet
isConnected = Datapixx('isReady');
if ~isConnected
    Datapixx('Open');
end

%Open a display on the Propixx
% PsychDefaultSetup(2);
AssertOpenGL;
screenNumber = max(Screen('Screens'));
white     = WhiteIndex(screenNumber);
black     = BlackIndex(screenNumber);
grey      = (white+black)/2;
KbName('UnifyKeyNames');
Screen('Preference', 'SkipSyncTests', 0);
screenID = screenNumber;                                           
[windowPtr,~] = Screen('OpenWindow', screenID, 0);
% [windowPtr,rect] = PsychImaging('OpenWindow', screenID, black, [0 0 1920 1080]);

%Enable 1440 Hz mode (12 frames/flip), with sync flipping
Datapixx('SetPropixxDlpSequenceProgram', 5);
Datapixx('RegWrRd');

PsychProPixx('SetupFastDisplayMode', windowPtr, 12, 0);   
stimulusBuffer = PsychProPixx('GetImageBuffer');

%Set up some stimulus characteristics-- remember the final display will be
%halved resolution
dotRadius = 10;
dotColour = [255, 255, 255];
bkgColour = [0,0,0];
greyColour = [255, 255, 255]/2;
targetRadius = 100;
center = [960/2, 540/2];

%Predefine stim positions to increase speed. Number of angles should be
%divisible by 12 so the counter restarts after a flip.
angles = -179:2:180;
nangles = numel(angles);
rects = nan(nangles, 4);
for k = 1:numel(angles)
     x = center(1) + targetRadius * cos(angles(k)*pi/180);
     y = center(2) + targetRadius * sin(angles(k)*pi/180);
     rects(k,:) = [x-dotRadius, y-dotRadius, x+dotRadius, y+dotRadius];
end


baseRect = [0 0 1 1]*50;
centeredRect = CenterRectOnPointd(baseRect, center(1), center(2));

ifi = Screen('GetFlipInterval', windowPtr); %duration of one frame
ifi = 1/120;
disp(['ifi = ',num2str(ifi)])

sr = 480;
T = (1:10)*1/sr;
r = 1./T

cc = zeros(1,12);
idx = 1:5:12;
cc(idx) = 1;

%Start drawing dots 
OnsetTime = GetSecs;
for trl = 1:50

    for f = 1:10
     for k = 1:12
       %Clear our stimulusBuffer by creating an all-black background
       Screen('FillRect', stimulusBuffer, bkgColour, [0,0,960,540]);
       
       %Draw circle in a specific location into our stimulusBuffer
       % Screen('FillOval', stimulusBuffer, dotColour, rects(k,:));
       Screen('FillOval', stimulusBuffer, dotColour*cc(k), centeredRect);
       
       %Add the new image to our queue; the queue flips automatically once
       %12 frames have been added
       %
       OnsetTime = PsychProPixx('QueueImage', stimulusBuffer, OnsetTime + (1-0.5)*ifi);
     end
    end

    % bkg clear
    for f = 1:50
     for k = 1:12
       Screen('FillRect', stimulusBuffer, bkgColour, [0,0,960,540]);
       OnsetTime = PsychProPixx('QueueImage', stimulusBuffer, OnsetTime + (1-0.5)*ifi);
     end
    end

end % end trial

%Close
Datapixx('SetPropixxDlpSequenceProgram', 0);
Datapixx('RegWrRd');

% PsychProPixx('DisableFastDisplayMode', 1, 0);    
Datapixx('Close');
Screen('Closeall');

end

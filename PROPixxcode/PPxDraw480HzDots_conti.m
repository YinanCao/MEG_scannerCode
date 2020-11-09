function PPxDraw480HzDots_conti
%This function draws a series of dots around the center of the
%display at 480 Hz. 

% First, we construct a single 1920 x 1080 RGB image, which is passed to
% the PROPixx. The sequencer breaks the image down and shows the quadrants
% as 4 individual 960 x 540 frames, one after the other.
%_______________________________
%|             |                |           
%|     Q1      |       Q2       | 
%|             |                | 
%|_____________|________________|   
%|             |                |         
%|     Q3      |       Q4       |          
%|             |                |          
%|_____________|________________|          


%Quadrants are shown FULL SCREEN, RGB in the order Q1-Q2-Q3-Q4. 

% To create stimuli, we draw our targets as if they were full resolution,
% full screen. The helper script 'convertToQuadrant' reassigns and rescales
% the target positon to the correct quadrant. Remember that each quadrant
% gets blown up to full screen, so your resolution will be halved
% vertically and horizontally.

% Made and tested with:
% -- PROPixx firmware revision 43
% -- DATAPixx3 firmware revision 19 
% -- MATLAB version 9.6.0.1150989 (R2019a) 
% -- Psychtoolbox version 3.0.15 
% -- Datapixx Toolbox version 3.7.5735
% -- Windows 10 version 1903, 64bit

% Sep 27 2019       lef     written
% Mar 26 2020       lef     revised

%Check connection and open Datapixx if it's not open yet
isConnected = Datapixx('isReady');
if ~isConnected
    Datapixx('Open');
end

Datapixx('SetPropixxDlpSequenceProgram', 2);        %Set Propixx to 480Hz refresh (also known as Quad4x)
Datapixx('RegWrRd');                                %Push command to device register

%Open a display on the Propixx
PsychDefaultSetup(2);
AssertOpenGL;
screenNumber = max(Screen('Screens'));
white     = WhiteIndex(screenNumber);
black     = BlackIndex(screenNumber);
grey      = (white+black)/2;

KbName('UnifyKeyNames')
Screen('Preference', 'SkipSyncTests', 0);
screenID = screenNumber;                           %Change this value to change display
[windowPtr,rect] = PsychImaging('OpenWindow', screenID, black, [0 0 1920 1080]);

%Set up some stimulus characteristics
dotRadius = 40;

%Create some positions based on the regular display
center = [rect(3)/2, rect(4)/2];
radius = 0;
positions=[center(1), center(2)-radius;...            %top
           center(1)+radius, center(2);...            %right
           center(1), center(2)+radius;...            %bottom
           center(1)-radius, center(2)];              %left

% ifi = Screen('NominalFrameRate', windowPtr);
ifi = Screen('GetFlipInterval', windowPtr); %duration of one frame
disp(['ifi = ',num2str(ifi)])
%Start displaying dots

for trl = 1:300
    
    OnsetTime = GetSecs;
    if ~mod(trl,2), colour = [1,0,0,0]; nf = 3;
    elseif ~mod(trl,3), colour = [1,0.5,1,0.5]; nf = 5;
    else colour = [1,1,1,1]; nf = 7;
    end



    for f = 1:nf
        for quadrant = 1:4
        position = positions(quadrant, :);
        
        %Convert position to the same position in the quadrant 1 and draw
        [x,y] = convertToQuadrant(position, rect, quadrant); 
        Screen('FillOval', windowPtr, colour(quadrant), [x-dotRadius, y-dotRadius, x+dotRadius, y+dotRadius]);
        end
        %Flip
        OnsetTime = Screen('Flip', windowPtr, OnsetTime + (1-0.5)*ifi);
    end

        for quadrant = 1:4
        position = positions(quadrant, :);
        
        %Convert position to the same position in the quadrant 1 and draw
        [x,y] = convertToQuadrant(position, rect, quadrant); 
        Screen('FillOval', windowPtr, 0, [x-dotRadius, y-dotRadius, x+dotRadius, y+dotRadius]);
        end

    Screen('Flip', windowPtr, OnsetTime + (1-0.5)*ifi);
    pause(0.5)

%     %Keypress to exit
%     [keyIsDown, ~, ~, ~] = KbCheck;
%     if keyIsDown
%         break
%     end 
end
        
Screen('Closeall');
Datapixx('SetPropixxDlpSequenceProgram', 0);         %Revert to standard 120Hz refresh rate
Datapixx('RegWrRd');
Datapixx('Close');

end

function [x,y] = convertToQuadrant(position, displaySize, quad)
%This scales an x, y position into a specific quadrant of the screen    
scale = 0.5;

switch quad
    case 1; xOffset = 0; yOffset = 0;
    case 2; xOffset = displaySize(3)/2; yOffset = 0; 
    case 3; xOffset = 0; yOffset = displaySize(4)/2;
    case 4; xOffset = displaySize(3)/2; yOffset = displaySize(4)/2;
end
    
x = (position(1)*scale)+xOffset;
y = (position(2)*scale)+yOffset;

end

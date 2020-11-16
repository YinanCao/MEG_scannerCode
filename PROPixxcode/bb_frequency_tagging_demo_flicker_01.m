%-------------------------------------------------------------------------------
% Function
% If any questions, please contact a.zhigalov@bham.ac.uk
%-------------------------------------------------------------------------------
function bb_frequency_tagging_demo_flicker_01()

clc;

try sca
catch
end

padWidth = 60;
picWidth = 250;

% set up parameters
Screen('Preference', 'SkipSyncTests', 0); % must be 0 during experiment (!)
KbName('UnifyKeyNames');
PsychDefaultSetup(2);

% screen info and colors
screens = Screen('Screens');
scrNumber = max(screens); % draw to the external screen if avaliable
gray = 0;
% create a screen window
[window, rect] = PsychImaging('OpenWindow', scrNumber, gray);
Screen('Flip', window);
% screen and text parameters
[scrWidth, scrHeight] = Screen('WindowSize', window);

center = [rect(3)/2, rect(4)/2];
base = [center(1)-padWidth/2, center(2)-padWidth/2, center(1)+padWidth/2, center(2)+padWidth/2];

ifi = Screen('GetFlipInterval', window);
FR = Screen('NominalFrameRate', window); % monitor frame rate

%FR = 120;
%ifi = 1/FR;

FR
ifi

% my monitor bug
% if FR > 80, FR = 120; else, FR = 60; end
% my monitor bag

Screen('TextSize', window, 25);
% maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% drawing
[picFrame, padFrame] = tag_get_pictures(window, picWidth, padWidth);
xy = tag_get_xy_and_rect(picFrame, scrWidth, scrHeight);
[padLRect, padRRect] = tag_get_pad_rect(padWidth, xy);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% open projector
tag_setup_projector('open', 1);
tag_setup_projector('set', 1);


freq = [51, 63, 78, 87, 92, 108, 120, 133, 152];

for whichf = 1:length(freq)

f1 = freq(whichf);
f2 = f1;

% generate tagging signal
d2 = 1.0; % duration of tagging signal
d6 = 0.3; % break
D2 = round(FR * d2 * 12); % 12 is the Propixx multiplier for gray scale
D6 = round(FR * d6 * 12);

[xColor1d0, xColor1d1] = tag_get_tagging_signal(d2 + d6, D2 + D6, f1, f2);
size(xColor1d0)
xColor3d0 = reshape(xColor1d0, 4, 3, []);
xColor3d1 = reshape(xColor1d1, 4, 3, []);
xColor3d = {xColor3d0, xColor3d1};
D2 = D2 / 12;
D6 = D6 / 12;

vbl = Screen('Flip', window);

%Set up some stimulus characteristics
dotRadius = 10;

%Create some positions based on the regular display
center = [rect(3)/2, rect(4)/2];
radius = 0;
positions=[center(1), center(2)-radius;...            %top
           center(1)+radius, center(2);...            %right
           center(1), center(2)+radius;...            %bottom
           center(1)-radius, center(2)];              %left

% loop
for trial = 1
  for d = 1:(D2 + D6) % VBL frames
        fColor = xColor3d{1}(:, :, d);
        hColor = xColor3d{2}(:, :, d);
        if d < (D2 + 1) % tagging
          for quadrant = 1:4
            % position = positions(quadrant, :);
            i = quadrant;
            Screen('DrawTexture', window, padFrame, [], padLRect{i}, 0, [], 1, fColor(i, :));
            % [x,y] = convertToQuadrant(position, rect, quadrant);
            % Screen('FillOval', window, fColor(quadrant, :), [x-dotRadius, y-dotRadius, x+dotRadius, y+dotRadius]);
            % Screen('DrawTexture', window, padFrame, [], padRRect{i}, 0, [], 1, hColor(i, :));
          end
        end
        vbl = Screen('Flip', window, vbl + 0.5 * ifi);
  end
  vbl = Screen('Flip', window, vbl + 0.5 * ifi); 
end

end


% close screen
Screen('CloseAll');

% reset projector
tag_setup_projector('reset', 1);
tag_setup_projector('close', 1);

end % end

%-------------------------------------------------------------------------------
% Function
%-------------------------------------------------------------------------------

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






function [picFrame, padFrame] = tag_get_pictures(window, picWidth, padWidth)

picFrame = uint8(zeros(picWidth, picWidth));
padFrame = uint8(ones(padWidth, padWidth) * 255);
picFrame = Screen('MakeTexture', window, picFrame);
padFrame = Screen('MakeTexture', window, padFrame);
  
end % end

%-------------------------------------------------------------------------------
% Function
%-------------------------------------------------------------------------------
function xy = tag_get_xy_and_rect(picFrame, scrWidth, scrHeight)

texRect = Screen('Rect', picFrame);
tmpRect = CenterRectOnPoint(texRect, scrWidth / 2, scrHeight / 2);

% centers
dstrect_1 = CenterRectOnPoint(tmpRect, 1 * scrWidth / 4, 1 * scrHeight / 4);
dstrect_2 = CenterRectOnPoint(texRect, 3 * scrWidth / 4, 1 * scrHeight / 4);
dstrect_3 = CenterRectOnPoint(texRect, 1 * scrWidth / 4, 3 * scrHeight / 4);
dstrect_4 = CenterRectOnPoint(texRect, 3 * scrWidth / 4, 3 * scrHeight / 4);
dstrect = {dstrect_1, dstrect_2, dstrect_3, dstrect_4};

% center, left and right below corner
xy = cell(1, 4); 
for i = 1:4
  [x, y] = RectCenter(dstrect{i}); xy{i} = [x, y]; 
end

end % end

%-------------------------------------------------------------------------------
% Function
%-------------------------------------------------------------------------------
function [lRect, rRect] = tag_get_pad_rect(width, xy)

lRect = cell(1, 4);
rRect = cell(1, 4);
for i = 1:4
  x = xy{i}(1) - xy{1}(1);
  y = xy{i}(2) - xy{2}(2);
  lRect{i} = [x, y, x + width, y + width]; 
  x = xy{i}(1) + xy{1}(1) - width;
  y = xy{i}(2) - xy{2}(2);
  rRect{i} = [x, y, x + width, y + width]; 
end

end % end

%-------------------------------------------------------------------------------
% Function
%-------------------------------------------------------------------------------
function [xColor1d0, xColor1d1] = tag_get_tagging_signal(d, D, fl, fh)

% parameters
t = linspace(0, d, D);
xColor1d0 = 0.5 * sin(2 * pi * fl * t) + 0.5; 
xColor1d1 = 0.5 * sin(2 * pi * fh * t) + 0.5;

end % end

%-------------------------------------------------------------------------------
% Function
%-------------------------------------------------------------------------------
function tag_setup_projector(command, bProjector)

if bProjector == 1
  if strcmp(command, 'open')
    Datapixx('Open');
  elseif strcmp(command, 'set')
    Datapixx('SetPropixxDlpSequenceProgram', 5); % 1440 Hz
    Datapixx('RegWrRd');
  elseif strcmp(command, 'reset')
    Datapixx('SetPropixxDlpSequenceProgram', 0); % default
    Datapixx('RegWrRd');
  elseif strcmp(command, 'close')
    Datapixx('Close');
  else
    fprintf(1, 'Propixx command ''%s'' is not defined.\n', command);
    return
  end
end
  
end % end

%-------------------------------------------------------------------------------

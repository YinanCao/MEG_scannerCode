%-------------------------------------------------------------------------------
% Function
% If any questions, please contact a.zhigalov@bham.ac.uk
%-------------------------------------------------------------------------------
function bb_frequency_tagging_demo_flicker()

clc;

try sca
catch
end

padWidth = 40;
picWidth = 250; 

% set up parameters
Screen('Preference', 'SkipSyncTests', 2); % must be 0 during experiment (!)
KbName('UnifyKeyNames');
PsychDefaultSetup(2);

% screen info and colors
screens = Screen('Screens');
scrNumber = max(screens); % draw to the external screen if avaliable
gray = 0.4;
% create a screen window
[window, ~] = PsychImaging('OpenWindow', scrNumber, gray);
Screen('Flip', window);
% screen and text parameters
[scrWidth, scrHeight] = Screen('WindowSize', window);

ifi = Screen('GetFlipInterval', window);
FR = Screen('NominalFrameRate', window); % monitor frame rate

FR = 120;
ifi = 1/FR;

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

% generate tagging signal
d2 = 1.5; % duration of tagging signal
d6 = 0.3; % break
D2 = round(FR * d2 * 12); % 12 is the Propixx multiplier for gray scale
D6 = round(FR * d6 * 12);
[xColor1d0, xColor1d1] = tag_get_tagging_signal(d2 + d6, D2 + D6);
xColor3d0 = reshape(xColor1d0, 4, 3, []);
xColor3d1 = reshape(xColor1d1, 4, 3, []);
xColor3d = {xColor3d0, xColor3d1};
D2 = D2 / 12;
D6 = D6 / 12;

vbl = Screen('Flip', window);

% loop
for trial = 1:10
  for d = 1:(D2 + D6) % VBL frames
        fColor = xColor3d{1}(:, :, d);
        hColor = xColor3d{2}(:, :, d);
        if d < (D2 + 1) % tagging
          for i = 1:4
            Screen('DrawTexture', window, padFrame, [], padLRect{i}, 0, [], 1, fColor(i, :));
            Screen('DrawTexture', window, padFrame, [], padRRect{i}, 0, [], 1, hColor(i, :));
          end
        end
        vbl = Screen('Flip', window, vbl + 0.5 * ifi);
  end
  vbl = Screen('Flip', window, vbl + 0.5 * ifi); 
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
function [xColor1d0, xColor1d1] = tag_get_tagging_signal(d, D)

% parameters
t = linspace(0, d, D);
fl = 63;
fh = 78;
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
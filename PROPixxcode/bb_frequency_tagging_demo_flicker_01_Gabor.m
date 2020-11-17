%-------------------------------------------------------------------------------
% Function
% If any questions, please contact a.zhigalov@bham.ac.uk
%-------------------------------------------------------------------------------
function bb_frequency_tagging_demo_flicker_01_Gabor

clc;

try sca
catch
end

padWidth = 60;
picWidth = 250;

% set up parameters
Screen('Preference', 'SkipSyncTests', 2); % must be 0 during experiment (!)
KbName('UnifyKeyNames');
PsychDefaultSetup(2);

% screen info and colors
screens = Screen('Screens');
scrNumber = max(screens); % draw to the external screen if avaliable
gray = 0.5;
% create a screen window
[window, rect] = PsychImaging('OpenWindow', scrNumber, gray);
Screen('Flip', window);
% screen and text parameters
[scrWidth, scrHeight] = Screen('WindowSize', window);

grey = gray;

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
tag_setup_projector('reset', 1);
tag_setup_projector('close', 1);

tag_setup_projector('open', 0);
tag_setup_projector('set', 0);

freq = [63, 78, 87, 92, 108, 120, 133, 152];


%Gabor_setup;

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

%Create some positions based on the regular display
% center = [rect(3)/2, rect(4)/2];
% radius = 0;
% positions=[center(1), center(2)-radius;...            %top
%            center(1)+radius, center(2);...            %right
%            center(1), center(2)+radius;...            %bottom
%            center(1)-radius, center(2)];              %left

padFrame


% loop
for trial = 1
  for d = 1:(D2 + D6) % VBL frames
        fColor = xColor3d{1}(:, :, d);
        hColor = xColor3d{2}(:, :, d);
        if d < (D2 + 1) % tagging
          for quadrant = 1:4
            % position = positions(quadrant, :);
            i = quadrant;
            
            
          % Screen('DrawTexture', window, textureIndexTarg, [], dstRect, orientation, [], 1, fColor(i, :));
            Screen('DrawTexture', window, padFrame,         [], padLRect{i}, 0, [], 1, fColor(i, :));
            
           
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
%tag_setup_projector('reset', 1);
%tag_setup_projector('close', 1);

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


function Gabor_setup()

info.mon_width_cm  = 46;% width of monitor (cm)
info.mon_height_cm = 27;% height of monitor (cm)
info.view_dist_cm  = 53;% viewing distance (cm)
info.pix_per_deg   = info.window_rect(3) *(1 ./ (2 * atan2(info.mon_width_cm / 2, info.view_dist_cm))) * pi/180;

info.width = info.mon_width_cm;
info.height = info.mon_height_cm;
info.dist = info.view_dist_cm;

%----------------
% Gabor Parameters
%----------------
if info.Session_type == 'B'
    Gabor.WorB =  1; % 1:black
else
    Gabor.WorB = -1; %-1:white
end


Gabor.tr_contrast           = all_contrast;
Gabor.freq_deg              = 5; % spatial frequency (cycles/deg)
Gabor.period                = 1/Gabor.freq_deg*info.pix_per_deg; % in pixels
Gabor.freq_pix              = 1/Gabor.period;% in pixels
Gabor.SDofGaussX            = 20; % SD of x-axis of Gaussian ellipse (fixed; unit = pixel)
Gabor.diameter_deg          = 1.6;
Gabor.patchHalfSize         = round(info.pix_per_deg*(Gabor.diameter_deg/2)); % 50 pix
Gabor.patchPixel            = -Gabor.patchHalfSize:Gabor.patchHalfSize;
Gabor.elp                   = 1;
Gabor.numGabors             = 3;
if Block_type == 'n'
    Gabor.gc_from_sc_deg    = 1.25;
    Gabor.gc_from_sc_pix    = round(info.pix_per_deg*Gabor.gc_from_sc_deg);
elseif Block_type == 'f'
    Gabor.gc_from_sc_deg    = 2.2;
    Gabor.gc_from_sc_pix    = round(info.pix_per_deg*Gabor.gc_from_sc_deg);
end
Gabor.X_Shift_deg           = round(((sqrt(3)/2) * Gabor.gc_from_sc_deg));
Gabor.Y_Shift_deg           = round(((1/2) * Gabor.gc_from_sc_deg));
Gabor.X_Shift_pix           = round(info.pix_per_deg * Gabor.X_Shift_deg);
Gabor.Y_Shift_pix           = round(info.pix_per_deg * Gabor.Y_Shift_deg);
Gabor.size_fluctuation      = round(info.pix_per_deg*0);% 0 pix
Gabor.outlineWidth          = 1;

%   Position
Trial.all_pos               = ['L','M','R'];
Trial.all_triangle_dir      = 'U';
Trial.Triangle_dir          = 'U';

Trial.numGabors             = 3;
Trial.Gabor_arng_rotation   = 'R';
Trial.Gabor_orientation     = all_angles;
Trial.rot_deg               = 5;

Trial.cueNumColor          = white;

Trial.cueNumberD           = 0.3;
%    Make a truncated distributaion for inter_trial delay
pd                         = makedist('Exponential','mu',0.75);
t                          = truncate(pd,0.6,1.5);
Trial.BRD                  = random(t,[1,nTrials]);% Being Ready duration
Trial.cueD                 = 0.05; % cue duration
Trial.cue2StimD            = 0.1;
Trial.SD                   = 0.8;% Stimulus duration
Trial.ISI                  = 0.4;
Trial.s2PD                 = 0.5;
Trial.ProbD                = 0.5;
Trial.StRCD                = 0.5; % probe offset to response onset
Trial.RCD                  = 2; % Response cue duration
Trial.FBD                  = 0.25;% FeedBack duration
Trial.TimeWaitafterFB      = 0.3;

if Trial.Triangle_dir == 'U'
    x                  = [-Gabor.X_Shift_pix,0,Gabor.X_Shift_pix];
    y                  = [Gabor.Y_Shift_pix,-Gabor.gc_from_sc_pix,Gabor.Y_Shift_pix];
else
    x                  = [-Gabor.X_Shift_pix,0,Gabor.X_Shift_pix];
    y                  = [-Gabor.Y_Shift_pix,Gabor.gc_from_sc_pix,-Gabor.Y_Shift_pix];
end

if Trial.Gabor_arng_rotation == 'R'
    x_rot              = round(x*cosd(Trial.rot_deg) - y*sind(Trial.rot_deg));
    y_rot              = round(y*cosd(Trial.rot_deg) + x*sind(Trial.rot_deg));
    Xpos               = [center_x,center_x,center_x] + x_rot;
    Ypos               = [center_y,center_y,center_y] + y_rot;
else
    x_rot              = round(x*cosd(360-Trial.rot_deg) - y*sind(360-Trial.rot_deg));
    y_rot              = round(y*cosd(360-Trial.rot_deg) + x*sind(360-Trial.rot_deg));
    Xpos               = [center_x,center_x,center_x] + x_rot;
    Ypos               = [center_y,center_y,center_y] + y_rot;
end

Gabor.Xpos = Xpos([2,1,3]); % this order is: left, mid, right
Gabor.Ypos = Ypos([2,1,3]); % so we need to change it to mid, left, right

%    Crossed fixation information
Gabor.Fixation_dot_deg        = 0.15;
Gabor.Fixation_cross_h_deg    = Gabor.Fixation_dot_deg;
Gabor.Fixation_cross_w_deg    = Gabor.Fixation_dot_deg*4;
Gabor.Fixation_dot_pix        = round(info.pix_per_deg*Gabor.Fixation_dot_deg);
Gabor.Fixation_cross_h_pix    = round(info.pix_per_deg*Gabor.Fixation_cross_h_deg);
Gabor.Fixation_cross_w_pix    = round(info.pix_per_deg*Gabor.Fixation_cross_w_deg);
fixCrossDimPix                = round(info.pix_per_deg*(Gabor.Fixation_cross_w_deg/2));%12 pix
xCoords                       = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords                       = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords                     = [xCoords; yCoords];
lineWidthPix                  = round(info.pix_per_deg*Gabor.Fixation_dot_deg);%6 pix
fix_rect                      = [-fixCrossDimPix -lineWidthPix./2 fixCrossDimPix lineWidthPix./2];



end







function textureIndexTarg = genGabor()


% fun
% gabor parameters:
period = Gabor.period; % in pixels
f = 1/period; % spatial frequency
SDofGaussX = Gabor.SDofGaussX; % SD of x-axis of Gaussian ellipse (fixed; unit = pixel)
patchHalfSize = Gabor.patchHalfSize; % canvas on which gaussians are drawn
elp=Gabor.elp;
patchPixel = -patchHalfSize:patchHalfSize;

% define gabor positions (horizontal line atm):
gaborrect = [-patchHalfSize -patchHalfSize patchHalfSize patchHalfSize];

% make gabor:
[x,y] = meshgrid(patchPixel, patchPixel);

BorW = Gabor.WorB; % 1:black, -1:white
a = SDofGaussX; % lowerbound of SD of y-axis of Gaussian ellipse
b = SDofGaussX*elp; % upperbound of SD of y-axis of Gaussian ellipse
SDofGaussY  = (b-a)*rand(1,Gabor.numGabors) + a;  % SD of y-axis of Gaussian ellipse
% contrast = all_contrast(thiscontrast);

for whichG = 1 % top, left, right

    posX = Gabor.Xpos(whichG); % top, left, right
    posY = Gabor.Ypos(whichG);
    
    dstRect = CenterRectOnPoint(gaborrect, posX, posY);
    valleyC = BorW;
    c = all_contrast(thiscontrast); % top, left, right
    gauss = exp(-(x.^2/(2*SDofGaussX^2)+y.^2/(2*SDofGaussY(whichG)^2)));
    gauss(gauss < 0.01) = 0;
    t = 0;
    gabor = sin(2*pi*f*(y*sin(t) + x*cos(t))).*gauss;
    
    M = grey*(1 + gabor*valleyC*c); % shift phase if valley = white
    % to be consistent with the phase when valley = black (default)
    if valleyC > 0
        M(M > grey) = grey;
    else
        M(M < grey) = grey;
    end
    % crop outside the circle
    
    px = 0;
    py = 0;
    th = linspace(0, 2*pi);
    xc = px + patchHalfSize*cos(th);
    yc = py + patchHalfSize*sin(th);
    idx = inpolygon(y(:),x(:),xc,yc);
    M(~idx) = grey;
    
    orientation = Trial.Gabor_orientation(thisangle);
    textureIndexTarg = Screen('MakeTexture', window, M);
    
    if c>0
        Screen('FrameOval', window, holder_c,dstRect,Gabor.outlineWidth);
    end
    
    

end








end
clear; clc; close all;
Screen('CloseAll');
Screen('Preference', 'SkipSyncTests', 0);
cd('/Users/yinancaojake/Documents/Postdoc/UKE/MEG_scannerCode/FregTag_contrast_control')

%--------------------------------------
% Open the window and Setup PTB  values
%--------------------------------------
PsychDefaultSetup(2);
AssertOpenGL;
screenNumber = max(Screen('Screens'));

keyLR = {'z','g'}; % b,z,g,r for 1,2,3,4
KbName('UnifyKeyNames');
left     = KbName(keyLR{1});
right    = KbName(keyLR{2});

% Define the colors
white     = WhiteIndex(screenNumber);
black     = BlackIndex(screenNumber);
grey      = (white + black) / 2;
green     = [0,200,0];
red       = [200,0,0];
blue      = [0,0,200];
dark_grey = white / 4;


% Open the Window
% HideCursor;
Screen('Preference', 'TextRenderer', 1); % smooth text
% smallWindow4Debug    =  [0, 0, 1920, 1080]/1.3;
smallWindow4Debug  = [];
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, smallWindow4Debug, 32, 2,...
    [], [],  kPsychNeed32BPCFloat);
[center_x, center_y] = RectCenter(windowRect);
Screen('TextFont', window, 'Helvetica'); % define text font
Screen('TextSize', window, 22); % define text font
info.window_rect  = windowRect;
info.frameDur     = Screen('GetFlipInterval', window); %duration of one frame
info.frameRate    = Screen('NominalFrameRate', window);
ifi = info.frameDur;
info.frameRate = 60;

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% stimulus:
info.mon_width_cm  = 46;% width of monitor (cm)
info.mon_height_cm = 27;% height of monitor (cm)
info.view_dist_cm  = 53;% viewing distance (cm)
info.pix_per_deg   = info.window_rect(3) *(1./(2*atan2(info.mon_width_cm/2, info.view_dist_cm)))*pi/180;

Gabor.freq_deg              = 5; % spatial frequency (cycles/deg)
Gabor.period                = 1/Gabor.freq_deg*info.pix_per_deg; % in pixels
Gabor.freq_pix              = 1/Gabor.period;% in pixels
Gabor.diameter_deg          = 3;
Gabor.patchHalfSize         = round(info.pix_per_deg*(Gabor.diameter_deg/2)); % 50 pix
Gabor.SDofGaussX            = Gabor.patchHalfSize/2;
Gabor.patchPixel            = -Gabor.patchHalfSize:Gabor.patchHalfSize;
Gabor.elp                   = 1;


% gabor parameters:
period = Gabor.period; % in pixels
f = 1/period; % spatial frequency
SDofGaussX = Gabor.SDofGaussX; % SD of x-axis of Gaussian ellipse (fixed; unit = pixel)
patchHalfSize = Gabor.patchHalfSize; % canvas on which gaussians are drawn
elp = Gabor.elp;
patchPixel = -patchHalfSize:patchHalfSize;

% define gabor positions (horizontal line atm):
gaborrect = [-1,-1,1,1]*Gabor.patchHalfSize; % canvas on which gaussians are drawn
% make gabor:
[x,y] = meshgrid(patchPixel, patchPixel);
SDofGaussY = SDofGaussX;
Gabor.Xpos = center_x + [-100, 100];
gauss = exp(-(x.^2/(2*SDofGaussX^2)+y.^2/(2*SDofGaussY^2)));
gauss(gauss < 0.01) = 0;
t = 0;
gabor = sin(2*pi*f*(y*sin(t) + x*cos(t))).*gauss;


% generate tagging signal
tag_f = [63,78,85,95,102,121];
FR = info.frameRate;
d2 = 2;
d6 = 0;
D2 = round(FR * d2);
D6 = round(FR * d6);
tag_sig = tag_get_tagging_signal(d2 + d6, (D2 + D6)*12, tag_f);
xColor3d = cell(0);
for i = 1:length(tag_sig)
    xColor3d{i} = reshape(tag_sig{i}, 4, 3, []);
end

% convert positions for quadrants
q_dstRect_all = [];
for whichG = 1:2
    posX = Gabor.Xpos(whichG); % top, left, right
    posY = center_y;
    dstRect = CenterRectOnPoint(gaborrect, posX, posY);
    q_dstRect_gabor = zeros(4,4);
    for q = 1:4
        [x1,y1] = convertToQuadrant(dstRect(1:2), windowRect, q);
        [x4,y4] = convertToQuadrant(dstRect(3:4), windowRect, q);
        q_dstRect_gabor(q,:) = [x1,y1,x4,y4];
    end
    q_dstRect_all{whichG} = q_dstRect_gabor;
end

rect{1} = [0        0 center_x   center_y*2];
rect{2} = [center_x 0 center_x*2 center_y*2];
count = 1;
for i = 1:2
    xy = rect{i};
    for q = 1:4
        [x1,y1] = convertToQuadrant(xy(1:2), windowRect, q);
        [x4,y4] = convertToQuadrant(xy(3:4), windowRect, q);
        quadRect(:,count) = [x1,y1,x4,y4];
        count = count + 1;
    end
end


for trial = 1:6
    
    pause(1)
    
    % trial-specific:
    freq = randsample(1:length(tag_sig),1);
    contrast = .6;
    
    peak = (1 + contrast)*0.5;
    
    bkg_color = [grey, rand*grey];
    rectColor = repmat(bkg_color([1,1,1,1,2,2,2,2]),3,1);

    baseM_all = cell(0);
    
    for side = 1:2
        this_bkg = bkg_color(side);
        amp = peak - this_bkg;
        M = gabor*amp + this_bkg;
        M(M < this_bkg) = this_bkg;
        % crop outside the circle
        px = 0;
        py = 0;
        th = linspace(0, 2*pi);
        xc = px + patchHalfSize*cos(th);
        yc = py + patchHalfSize*sin(th);
        idx = inpolygon(y(:),x(:),xc,yc);
        M(~idx) = this_bkg;
        baseM_all{side} = M;
    end

    
    vbl = Screen('Flip', window);
    % Stimulus presentation
    for vblframe = 1:D2
        
        side = 2;
        this_bkg = bkg_color(side);
        amp = peak - this_bkg;
        M = gabor*amp + this_bkg;
        M(M < this_bkg) = this_bkg;
        % crop outside the circle
        px = 0;
        py = 0;
        th = linspace(0, 2*pi);
        xc = px + patchHalfSize*cos(th);
        yc = py + patchHalfSize*sin(th);
        idx = inpolygon(y(:),x(:),xc,yc);
        M(~idx) = this_bkg;
        baseM_all{side} = M;
        
        rectColor = repmat(bkg_color([1,1,1,1,2,2,2,2]),3,1);
        
        Screen('FillRect', window, rectColor, quadRect);
        
        destinationRect = [];
        textureIndexTarg = [];
        count = 1;
        for q = 1:4 % quadrant
            for whichG = 1:2 % stimuli
                this_bkg = bkg_color(whichG);
                baseM = baseM_all{whichG};
                fColor = xColor3d{freq}(:,:,vblframe); % each row=quad,
                q_dstRect = q_dstRect_all{whichG};
                Mx = nan([size(baseM,1),size(baseM,2),3]);
                for chan = 1:3
                   M = baseM - this_bkg; % bring to zero
                   if whichG == 2
                       M = M.*fColor(q, chan);
                   end
                   M = M + this_bkg;
                   Mx(:,:,chan) = M;
                end
                textureIndexTarg(count) = Screen('MakeTexture', window, Mx);
                destinationRect(:,count) = q_dstRect(q,:)';
                count = count + 1;
            end % end stim
        end % end quad
        Screen('DrawTextures', window, textureIndexTarg, [], destinationRect, 0, [], 1);
        vbl = Screen('Flip', window, vbl + 0.5 * ifi);
        Screen('Close', textureIndexTarg);
        
        
        % check response:
        start = vbl;
        %flush_kbqueues(info.kbqdev);
        [keyIsDown, secs, press_key, deltaSecs] = KbCheck();
        while ( press_key(left)==0  && press_key(right)==0 && GetSecs-start<0.49 * ifi)
            [keyIsDown, secs, press_key, deltaSecs] = KbCheck();
        end
        
        change = 0;
        if press_key(left)
            disp('left')
            change = -0.05;
        elseif press_key(right)
            disp('right')
            change = 0.05;
        end
        
        bkg_color(2) = bkg_color(2) + change;
        
        if bkg_color(2) > 0.5
            bkg_color(2) = 0.5;
        end
        
    end % end of frame loop
    
    vbl = Screen('Flip', window, vbl + 0.5 * ifi);

end

Screen('CloseAll');
ShowCursor;
fclose('all');
Priority(0);
sca;


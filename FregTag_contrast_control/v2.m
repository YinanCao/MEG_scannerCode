clear; clc; close all;

%% set test parameters
contrast_test = [0.1:0.02:0.3,0.5,0.7,0.9,1];
freq_test = [63, 90, 120, 1];
version_test = 2:3;
Nrep = 2;
info.f = freq_test;
length(contrast_test)*length(freq_test)*length(version_test)*Nrep
%%

Screen('CloseAll');
Screen('Preference', 'SkipSyncTests', 0);

cd /home/usera/Documents/MEG_scannerCode/FregTag_contrast_control/

SubName = 'CaoY';
datadir = '/home/usera/Documents/';
log_dir = [datadir 'Log'];
if ~exist(log_dir, 'dir')
   mkdir(log_dir);
end

%--------------------------------------
% Open the window and Setup PTB values
%--------------------------------------
PsychDefaultSetup(2);
AssertOpenGL;
screenNumber = max(Screen('Screens'));

keyLR = {'z','g','r','q'}; % b,z,g,r for 1,2,3,4
KbName('UnifyKeyNames');
left     = KbName(keyLR{1});
right    = KbName(keyLR{2});
next     = KbName(keyLR{3});
stopall  = KbName(keyLR{4});

% Define the colors
white     = WhiteIndex(screenNumber);
black     = BlackIndex(screenNumber);
grey      = (white + black) / 2;

% Open the Window
% HideCursor;
Screen('Preference', 'TextRenderer', 1); % smooth text
smallWindow4Debug  = [0, 0, 1920, 1080];
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, smallWindow4Debug, 32, 2,...
    [], [],  kPsychNeed32BPCFloat);
[center_x, center_y] = RectCenter(windowRect);
Screen('TextFont', window, 'Helvetica'); % define text font
Screen('TextSize', window, 22); % define text font
info.window_rect  = windowRect;
info.frameDur     = Screen('GetFlipInterval', window); %duration of one frame
info.frameRate    = Screen('NominalFrameRate', window);
ifi = info.frameDur;
% info.frameRate = 1/ifi;

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
Gabor.patchHalfSize         = round(info.pix_per_deg*(Gabor.diameter_deg/2));
Gabor.SDofGaussX            = Gabor.patchHalfSize/2;
Gabor.patchPixel            = -Gabor.patchHalfSize:Gabor.patchHalfSize;


% gabor parameters:
period = Gabor.period; % in pixels
f = 1/period; % spatial frequency
SDofGaussX = Gabor.SDofGaussX; % SD of x-axis of Gaussian ellipse (fixed; unit = pixel)
patchHalfSize = Gabor.patchHalfSize; % canvas on which gaussians are drawn
patchPixel = -patchHalfSize:patchHalfSize;
frameHalfSize = patchHalfSize*1.5;

% define gabor positions (horizontal line atm):
gaborrect = [-1,-1,1,1]*Gabor.patchHalfSize; % canvas on which gaussians are drawn
% make gabor:
[x,y] = meshgrid(patchPixel, patchPixel);
SDofGaussY = SDofGaussX;
Gabor.Xpos = center_x + [-2, 2]*Gabor.patchHalfSize;
gauss = exp(-(x.^2/(2*SDofGaussX^2)+y.^2/(2*SDofGaussY^2)));
gauss(gauss < 0.01) = 0;
t = 0;
gabor = sin(2*pi*f*(y*sin(t) + x*cos(t))).*gauss;

% generate tagging signal
FR = info.frameRate;
d2 = 20;
d6 = 0;
D2 = round(FR * d2);
D6 = round(FR * d6);
tag_sig = tag_get_tagging_signal(d2 + d6, (D2 + D6)*12, freq_test);
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
% full screen background for version 3
rr = [0 0 center_x*2 center_y*2];
for q = 1:4
    [x1,y1] = convertToQuadrant(rr(1:2), windowRect, q);
    [x4,y4] = convertToQuadrant(rr(3:4), windowRect, q);
    fullScreenbkg(:,q) = [x1,y1,x4,y4];
end

% prepare for cropping:
px = 0;
py = 0;
th = linspace(0, 2*pi);
xc = px + patchHalfSize*cos(th);
yc = py + patchHalfSize*sin(th);
idx = inpolygon(y(:),x(:),xc,yc);


%% conditions
allc = contrast_test;
allf = 1:length(freq_test);
allv = version_test;

cond = [];
for x = 1:length(allc)
    for y = 1:length(allf)
        for z = 1:length(allv)
            cond = [cond; allc(x),allf(y),allv(z)];
        end
    end
end
cond = repmat(cond,Nrep,1);
Ntrial = size(cond,1);
cond = cond(randperm(Ntrial),:);
Trial.answer = [cond, nan(size(cond,1),1)];
[keyIsDown, secs, press_key, deltaSecs] = KbCheck();


%%
info.kb_setup = 'MEG';
Setup_keys;

tag_setup_projector('open', 1);
tag_setup_projector('reset', 1);

%---------------
% Start the task
%---------------
DrawFormattedText(window, 'Ready? Press [SPACE] to start!', 'center', center_y+175, white);
Screen('Flip', window);
TTL = 0; % Get the TTL from the scanner
while TTL==0
    [keyIsDown, secs, keyCode] = KbCheck(-3, 2);  % Check keyboard press
    if strcmp(KbName(keyCode),'space')==1  % TTL
        TTL = 1;    % Start the experiment
        debrun = GetSecs; %%% Scanning starts!!!!
        disp('OK, let''s start!!')
    else
        TTL = 0;
    end
end
Screen('Flip', window);
pause(1);

HideCursor;

tag_setup_projector('set', 1);
WaitSecs(3);

%%
c = clock;
sname = sprintf('%s/%s_%s_%02d%02d-%02d%02d.mat',log_dir,SubName,'contrastmatch',c(3),c(2),c(4),c(5));

for trial = 1:Ntrial
    
    if press_key(stopall)
        break;
    end
    
    pause(.5)
    
    % trial-specific:
    contrast = cond(trial,1);
    freq     = cond(trial,2);
    version  = cond(trial,3);
    peak = (1 + contrast)*0.5;
    
    rect = cell(0); quadRect = [];
    switch version
        case 1
        rect{2} = [center_x 0 center_x*2 center_y*2];
        rect{1} = [0        0 center_x   center_y*2];
        case 2
        rect{3} = [center_x-Gabor.patchHalfSize 0 center_x+Gabor.patchHalfSize center_y*2];
        rect{2} = [center_x 0 center_x*2 center_y*2];
        rect{1} = [0        0 center_x   center_y*2];
        case 3
        for k = 1:2
            rect{k} = [Gabor.Xpos(k)-frameHalfSize, center_y-frameHalfSize, Gabor.Xpos(k)+frameHalfSize, center_y+frameHalfSize];
        end
    end
    % Quad conversion of positions:
    count = 1;
    for i = 1:length(rect)
        xy = rect{i};
        for q = 1:4
            [x1,y1] = convertToQuadrant(xy(1:2), windowRect, q);
            [x4,y4] = convertToQuadrant(xy(3:4), windowRect, q);
            quadRect(:,count) = [x1,y1,x4,y4];
            count = count + 1;
        end
    end
   
    % pre compute all Gabors of different bkg
    count = 1; Gabor_pool = cell(0);
    candid_bkg = 0:0.005:0.5;
    for this_bkg = candid_bkg
        amp = peak - this_bkg;
        M = gabor*amp + this_bkg;
        M(M < this_bkg) = this_bkg;
        % crop outside the circle
        M(~idx) = this_bkg;
        Gabor_pool{count} = M;
        count = count + 1;
    end
    
    % reference Gabor on grey background
    ref_Gabor = Gabor_pool{end};
    baseM_all{1} = ref_Gabor;
    
    % random starting value:
%     which_bkg = randsample(1:length(candid_bkg),1);
    which_bkg = length(candid_bkg);
    baseM_all{2} = Gabor_pool{which_bkg};

    bkg_color = [grey, candid_bkg(which_bkg), black];
    
    id = 1:length(rect);
    id = repmat(id,[4,1]);
    id = id(:)';
    
    vbl = Screen('Flip', window);
    % Stimulus presentation
    tic;
    for vblframe = 1:D2
        
        if version == 3
            Screen('FillRect', window, ones(1,4)*black, fullScreenbkg);
        end
        
        rectColor = repmat(bkg_color(id),3,1);
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
                   if whichG == 2 && freq < length(freq_test)
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
        flush_kbqueues(info.kbqdev);
        [keyIsDown, secs, press_key, deltaSecs] = KbCheck();
        while ( press_key(left)==0  && press_key(right)==0 && GetSecs-start<0.4 * ifi)
            [keyIsDown, secs, press_key, deltaSecs] = KbCheck();
        end
        
        change = 0;
        if press_key(left)
            change = -1;
        elseif press_key(right)
            change = 1;
        elseif press_key(next) || press_key(stopall)
            break;
        end
        
        which_bkg = which_bkg + change;
        if which_bkg < 1
           which_bkg = 1;
        elseif which_bkg > length(candid_bkg)
            which_bkg = length(candid_bkg);
        end
        
        baseM_all{2} = Gabor_pool{which_bkg};
        bkg_color(2) = candid_bkg(which_bkg);
        
        
    end % end of frame loop
    toc;
    vbl = Screen('Flip', window, vbl + 0.5 * ifi);
    
    Trial.answer(trial,end) = bkg_color(2);
    save(sname,'Trial','Gabor','info');

end

Screen('CloseAll');
ShowCursor;
fclose('all');
Priority(0);
sca;

tag_setup_projector('reset', 1);
tag_setup_projector('close', 1);

%% plot
close all;
D = Trial.answer;
for v = unique(D(:,3))'
    subplot(1,3,v)
    freqstr = cell(0);
    for f = unique(D(:,2))'
        freqstr{f} = [num2str(info.f(f)),' Hz'];
        p = [];
        for c = unique(D(:,1))'
            x = D(D(:,3)==v&D(:,2)==f&D(:,1)==c,4);
            p = [p; c, nanmean(x)];
        end
        plot(p(:,1),p(:,2),'o-')
        hold on;
    end
    title(['Version ',num2str(v)])
    axis square
    ylim([0,1])
    if v == 3
    legend(freqstr)
    end
    xlabel('Gabor luminance')
    ylabel('bkg luminance (control)')
end










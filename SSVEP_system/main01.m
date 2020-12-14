clear; clc; close all;
debug = 0;
smallWindow4Debug = [0, 0, 1920, 1080]/1.2;
Screen('Preference', 'SkipSyncTests', 0);
sca;
datadir = '/home/usera/Documents/';
datadir = '/Users/yinancaojake/'
log_dir = [datadir 'Log'];
if ~exist(log_dir, 'dir')
   mkdir(log_dir);
end
SubName = 'TC';
%--------------------------------------
% Open the window and Setup PTB  values
%--------------------------------------
PsychDefaultSetup(2);
AssertOpenGL;
screenNumber = max(Screen('Screens'));
% Define the colors
white     = WhiteIndex(screenNumber);
black     = BlackIndex(screenNumber);
grey      = white / 2;

info.do_trigger = 0;

% Define the keys
keyLR = {'z','g','2@'}; % b,z,g,r for 1,2,3,4
KbName('UnifyKeyNames');
% left     = KbName(keyLR{1});
% right    = KbName(keyLR{2});
% left foot: 1!
% right foot: '2@'

% Open the Window
control_bkg = 0.3;
multisample_flag = 6;
Screen('Preference', 'TextRenderer', 1); % smooth text
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, control_bkg, smallWindow4Debug, 32, 2,...
    [], multisample_flag, []);
[center_x, center_y] = RectCenter(windowRect);
Screen('TextFont', window, 'Helvetica'); % define text font
Screen('TextSize', window, 22); % define text font
info.window_rect  = windowRect;
info.frameDur     = Screen('GetFlipInterval', window); %duration of one frame
info.frameRate    = Screen('NominalFrameRate', window);
ifi = info.frameDur;
info.mon_width_cm  = 46;% width of monitor (cm)
info.mon_height_cm = 27;% height of monitor (cm)
info.view_dist_cm  = 53;% viewing distance (cm)
info.pix_per_deg   = info.window_rect(3) *(1 ./ (2 * atan2(info.mon_width_cm / 2, info.view_dist_cm))) * pi/180;

if info.frameRate == 0
    info.frameRate = 60;
end
% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

if info.do_trigger
    addpath matlabtrigger/
else
    addpath faketrigger/
end


%---------------
% Start the task
%---------------
DrawFormattedText(window, 'Ready? Press [SPACE] to start!', 'center', center_y + 175, white);
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
pause(1);
Screen('Flip', window);

contrast  = linspace(0.15, 1, 5);
gaborsize = linspace(1.8, 4, 3);
tag_f     = [63, 78, 85, 91, 103, 135];
parm = [];
cond_i = 1;
for i = 1:length(contrast)
    for j = 1:length(gaborsize)
        for k = 1:length(tag_f)
        parm = [parm; contrast(i),gaborsize(j),k,(rand*2-1)*180,cond_i];
        cond_i = cond_i + 1;
        end
    end
end
nrep = 1;
parm = repmat(parm,nrep,1);
nTrials = size(parm,1);
parm = parm(randperm(nTrials),:);
Trial.contrast = parm(:,1);
Trial.gaborsize = parm(:,2);
Trial.tagging_freq = parm(:,3);
Trial.orientation = parm(:,4);
Trial.trigval = parm(:,5);

% save data prep:
c = clock;
sname = sprintf('%s/%s_%02d%02d-%02d%02d.mat',log_dir,SubName,c(3),c(2),c(4),c(5));
save(sname,'Trial','info','parm')

% main experiment
DrawFormattedText(window, 'Please stay very still!','center',center_y-100,white);
Screen('Flip', window);
TTL = 0; % Get the TTL from the scanner
while TTL==0
    [keyIsDown, secs, keyCode] = KbCheck(-3, 2);  % Check keyboard press
    if strcmp(KbName(keyCode),'space')
        TTL = 1;    % Start the experiment
        debrun = GetSecs; %%% Scanning starts!!!!
        disp('OK, let''s start!!')
    else
        TTL = 0;
    end
end
pause(1);
Screen('Flip', window);

for trial = 1:nTrials

    disp(['>>> Trial: ',num2str(trial),' of ', num2str(nTrials)])
    Trial_run_ssvep;
    pause(.5);

end % end of the trials
disp('>>> mini block ended')
    
% Close and clear all
Screen('CloseAll');
ShowCursor;
fclose('all');
Priority(0);
sca;



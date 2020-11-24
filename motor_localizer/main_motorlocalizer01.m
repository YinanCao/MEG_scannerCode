clear; clc; close all;
SubName = 'YC';
debug = 0;
debugkey = 0;
datadir = '/home/usera/Documents/';
% addpath(genpath('/Applications/Psychtoolbox'));
sca;

info.SubNo = 1;

log_dir = [datadir 'Log'];
if ~exist(log_dir, 'dir')
   mkdir(log_dir);
end

cd /home/usera/Documents/MEG_scannerCode/motor_localizer/
smallWindow4Debug  = [0, 0, 1920, 1080];
%smallWindow4Debug  = [1921, 0, 1920*2, 1080];
Screen('Preference', 'SkipSyncTests', 0);
nTrials = 20;
blockRep = 1;

EL_flag = 0;
trigger_flag = 1;


% Define the keys
KbName('UnifyKeyNames');
L_Hand     = KbName('z'); % 2
R_Hand     = KbName('g'); % 3
L_Foot     = KbName('1!');
R_Foot     = KbName('2@');

if debugkey
    L_Hand     = KbName('a'); % 2
    R_Hand     = KbName('s'); % 3
    L_Foot     = KbName('d'); 
    R_Foot     = KbName('f');
end

time_win = 5;
if debug
    time_win = 0.1;
end

block_type = {1,'Left Hand', L_Hand,L_Hand
              2,'Right Hand',R_Hand,R_Hand
              3,'Left Foot', L_Foot,L_Foot
              4,'Right Foot',R_Foot,R_Foot
              5,'Two hands',L_Hand,R_Hand
              6,'Two feet',L_Foot,R_Foot
              7,'Left Hand + Left Foot', L_Hand,L_Foot
              8,'Right Hand + Right Foot', R_Hand,R_Foot
              9,'Left Hand + Right Foot',L_Hand,R_Foot
             10,'Right Hand + Left Foot',R_Hand,L_Foot
             };
Ntype = size(block_type,1);

block_all = repmat(block_type,blockRep,1);
nBlock = length(block_all);
block_all = block_all(randperm(nBlock),:);

PsychDefaultSetup(2);
AssertOpenGL;
screenNumber = max(Screen('Screens'));

% Define the colors
white     = WhiteIndex(screenNumber);
black     = BlackIndex(screenNumber);
grey      = white / 2;
green     = [0,200,0];
red       = [200,0,0];
blue      = [0,0,200];
dark_grey = white / 4;
holder_c  = [0 1 1];

Screen('Preference', 'TextRenderer', 1); % smooth text

if debug
    smallWindow4Debug  = [0 0 1920 1080]/1.2;
end
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, smallWindow4Debug, 32, 2,...
    [], [],  kPsychNeed32BPCFloat);
[center_x, center_y] = RectCenter(windowRect);
Screen('TextFont', window, 'Helvetica'); % define text font
Screen('TextSize', window, 30); % define text font
info.window_rect  = windowRect;
info.frameDur     = Screen('GetFlipInterval', window); %duration of one frame
info.frameRate    = Screen('NominalFrameRate', window);
ifi = info.frameDur;

if ~debug
    HideCursor;
end

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

patchHalfSize = 50;
gaborrect = [-patchHalfSize -patchHalfSize patchHalfSize patchHalfSize];
dstRect = CenterRectOnPoint(gaborrect, center_x, center_y);
info.SubName       = SubName;
info.ET            = EL_flag;
info.do_trigger    = trigger_flag;
info.kb_setup      = 'MEG';
info.mon_width_cm  = 45;    % width of monitor (cm)
info.mon_height_cm = 26.5;  % height of monitor (cm)
info.view_dist_cm  = 50;    % viewing distance (cm)
info.pix_per_deg   = info.window_rect(3) *(1 ./ (2 * atan2(info.mon_width_cm / 2, info.view_dist_cm))) * pi/180;

info.width = info.mon_width_cm;
info.height = info.mon_height_cm;
info.dist = info.view_dist_cm;
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

Setup_keys;
% rng('shuffle');
trigger_enc = setup_trigger;
disp('trigger setup done well.....')
 
if info.do_trigger
    addpath matlabtrigger/
else
    addpath faketrigger/
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for session = 1:3
    
    % time counting starts
    tic;

    % eye tracking prep:
    DrawFormattedText(window, 'We will calibrate your eye positions',...
        'center', center_y-100, white);
    Screen('Flip', window);
    disp('press space bar to calibrate ET')
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
    pause(1)
    Screen('Flip', window);


    % ET calibration:
    if info.ET
        disp('ET calibrating')
        [el, info] = ELconfig_Bharath(window, [SubName,'_ML',num2str(session)], info, screenNumber);
        % Calibrate the eye tracker
        EyelinkDoTrackerSetup(el);
        disp('Calibrating now....')
    end
    disp('ET calibration done! >>>>>>>>>>')


    DrawFormattedText(window, 'Please stay very still! We are measuring head position',...
            'center', center_y-100, white);
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
    pause(1)
    Screen('Flip', window);



    % Start Eyelink recording
    if info.ET
        disp('ET recording >>>>>>>>>')
        Eyelink('StartRecording');
        WaitSecs(0.1);
        Eyelink('message', 'Start recording Eyelink');
        trigger(trigger_enc.EL_start);
        disp('ET recording starts.....')
        disp(['trigger sent = ',num2str(trigger_enc.EL_start)])
    end


    % start experiment:
    for block = 1:nBlock

        DrawFormattedText(window, block_all{block,2},'center', 'center', white);
        Screen('Flip', window);

        motor_code = [];
        for i = 1:2
            motor_code(i) = block_all{block,i+2};
        end

        TTL = 0; % Get the TTL from the scanner
        while TTL==0
            [keyIsDown, secs, keyCode] = KbCheck(-3, 2);  % Check keyboard press
            if keyCode(motor_code(1))==1 || keyCode(motor_code(2))==1
                TTL = 1;    % Start the experiment
                debrun = GetSecs; %%% Scanning starts!!!!
                disp('OK, let''s start!!')
            else
                TTL = 0;
            end
        end
        trigger(trigger_enc.motor_blockType(block_all{block,1}));
        disp(['trigger sent = ',num2str(trigger_enc.motor_blockType(block_all{block,1}))])
        if info.ET
            Eyelink('message', num2str(trigger_enc.motor_blockType(block_all{block,1})));
        end
        pause(1)

        Rotated_fixation(window,fix_rect,center_x,center_y,dark_grey,[0,90]);
        Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
        Screen('Flip', window);

        for trl = 1:nTrials

            % fixation always on:
            Rotated_fixation(window,fix_rect,center_x,center_y,dark_grey,[0,90]);
            Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
            % present a cicle
            Screen('FrameOval', window, holder_c, dstRect, 3);

            [~, start_fix] = Screen('Flip', window);
            trigger(trigger_enc.circle_on)
            disp(['trigger sent = ',num2str(trigger_enc.circle_on)])
            if info.ET
                Eyelink('message', num2str(trigger_enc.circle_on));
            end

            start = start_fix;
            flush_kbqueues(info.kbqdev);
            [keyIsDown, secs, press_key, deltaSecs] = KbCheck();
            endrt = GetSecs;
            while ( press_key(L_Hand)==0  && press_key(R_Hand)==0 &&...
                    press_key(L_Foot)==0  && press_key(R_Foot)==0 ...
                    && GetSecs-start<time_win)
                [keyIsDown, secs, press_key, deltaSecs] = KbCheck();
                endrt = secs;
            end

            motor_identifier;

            Rotated_fixation(window,fix_rect,center_x,center_y,dark_grey,[0,90]);
            Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
            Screen('Flip', window);
            a = 1.4;
            b = 0.7;
            pause(b + (a-b)*rand)

        end % end trial

    end % end block


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save Eyelink data
    if info.ET
        disp('>>> attempting to save ET data >>>')
        time_str = strrep(mat2str(fix(clock)),' ','_');
        eyefilename = fullfile([log_dir,'/',time_str,'_',info.edfFile]);
        Eyelink('CloseFile');
        Eyelink('WaitForModeReady', 500);
        try
            status = Eyelink('ReceiveFile', info.edfFile, eyefilename);
            disp(['File ' eyefilename ' saved to disk']);
        catch
            warning(['File ' eyefilename ' not saved to disk']);
        end
        Eyelink('StopRecording');
    end
    
    % time counting ends
    toc;

    DrawFormattedText(window, 'This block is finished! Thanks!', 'center', 'center', WhiteIndex(window));
    Screen('Flip', window);
    TTL = 0; % Get the TTL from the scanner
    while TTL==0
        [keyIsDown, secs, keyCode] = KbCheck(-3, 2);  % Check keyboard press
        if strcmp(KbName(keyCode),'space')==1  % TTL
            TTL = 1;    % Start the experiment
            debrun = GetSecs; %%% Scanning starts!!!!
            disp('OK, done!!')
        else
            TTL = 0;
        end
    end
    Screen('Flip', window);
    
end % end of session

% Close and clear all
Screen('CloseAll');
ShowCursor;
fclose('all');
Priority(0);
sca;





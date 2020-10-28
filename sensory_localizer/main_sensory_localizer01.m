clear; clc; close all;
debug = 1;
datadir = '/Users/yinancaojake/Documents/';
Screen('Preference', 'SkipSyncTests', 2);
SubNo = 1;
SubName = 'pilot02';
EL_flag = 0;
trigger_flag = 0;
keyLR = {'b','z'};

block_rep = 1;
loc_all = repmat(1:3,1,block_rep);
loc_all = loc_all(randperm(length(loc_all)));

all_angles = [-67.5 -45 -22.5 22.5  45  67.5];
all_contrast = [0.2,0.5,0.8];

session_type = 'B';

Block_type = 'f';
Age = 24;
Gender = 'F';
Hand = 'R';
session_No = 1;
test_str = 'SensoryLocal';
stim_str = 'Gabor';

addpath(genpath('/Applications/Psychtoolbox'));
sca;

log_dir = [datadir 'Log'];
if ~exist(log_dir, 'dir')
   mkdir(log_dir);
end

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
green     = [0,200,0];
red       = [200,0,0];
blue      = [0,0,200];
dark_grey = white / 4;
holder_c  = [0 1 1];

% Define the keys
KbName('UnifyKeyNames');
% right     = KbName('rightarrow');
% left      = KbName('leftarrow');
% middle    = KbName('uparrow');
% brk       = KbName('space');
left     = KbName(keyLR{1});
right    = KbName(keyLR{2});
% left foot: 1!
% right foot: '2@'

% Open the Window
% HideCursor;
Screen('Preference', 'TextRenderer', 1); % smooth text

smallWindow4Debug  = [1920, 0, 1920*2, 1080];
if debug
    smallWindow4Debug  = [0 0 1920 1080]/1.2;
end
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, smallWindow4Debug, 32, 2,...
    [], [],  kPsychNeed32BPCFloat);
[center_x, center_y] = RectCenter(windowRect);
Screen('TextFont', window, 'Helvetica'); % define text font
Screen('TextSize', window, 22); % define text font
info.window_rect  = windowRect;
info.frameDur     = Screen('GetFlipInterval', window); %duration of one frame
info.frameRate    = Screen('NominalFrameRate', window);
ifi = info.frameDur;

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Set needed variables1
nrep = 1;
[~,nTrials] = gen_design(1,nrep);
Set_Vars;
Setup_keys;

%---------------
% Start the task
%---------------
DrawFormattedText(window, 'Ready? Press [SPACE] to start!', 'center', center_y+175,white);
Screen('Flip', window);
trigger(trigger_enc.block_start);  % trigger to mark start of the block
if  info.ET
    Eyelink('message', 'blockstart');
end

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

% main experiment


for session = 1:2
    
    tic;
    % eye tracking prep:
    DrawFormattedText(window, 'We will calibrate your eye positions',...
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
    Screen('Flip', window);
    
    % ET calibration:
    if info.ET
        disp('ET calibrating')
        [el, info] = ELconfig(window, ['sub_',SubName,'_sess',...
            num2str(session)], info, screenNumber);
        % Calibrate the eye tracker
        EyelinkDoTrackerSetup(el);
    end
    disp('ET calibration done! >>>>>>>>>>')

    % >>>>>>>>>>>>>>>>>>>>>>>>>
    % >>>>>>>>>>>>>>>>>>>>>>>>>
    % >>>>>>>>>>>>>>>>>>>>>>>>>
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
    pause(1);
    Screen('Flip', window);
    % >>>>>>>>>>>>>>>>>>>>>>>>>
    % >>>>>>>>>>>>>>>>>>>>>>>>>
    % >>>>>>>>>>>>>>>>>>>>>>>>>
    
    % Start Eyelink recording
    if info.ET
        disp('ET recording >>>>>>>>>')
        Eyelink('StartRecording');
        WaitSecs(0.1);
        Eyelink('message', 'Start recording Eyelink');
        trigger(trigger_enc.EL_start);
    end
    
    Task_message; % stay still
    pause(6);
    Screen('Flip', window);
    
    % save data prep:
    c = clock;
    sname = sprintf('%s/%s_%s_%s_%s_%s_sess_%d_%02d%02d-%02d%02d.mat',...
       log_dir,SubName,session_type,Block_type,test_str,stim_str,session,c(3),c(2),c(4),c(5));
    
   
for block = 1:length(loc_all)
    
    disp(['starting Session ',num2str(session),' Block ',num2str(block)])
    
    % new location will begin:
    location = loc_all(block);
    [d_matrix,nTrials] = gen_design(location,nrep);
    save_designMatrix{block} = d_matrix;

    % reset
    Trial.cue_position = [];
    Trial.orientation  = [];
    Trial.contrast     = [];
    Trial.probe_pos    = [];
    Trial.true_answer  = [];
    Trial.probe_contrast =[];
    Trial.RT = [];
    Trial.Timing = [];
    Trial.answer = [];
    Trial.eval_answer = [];
    
    %%% waiting for the first trial and not start the task immediately
    instruct_loc = location;
    make_cue;
    Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]);
    Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
    Screen('Flip', window);
    trigger(trigger_enc.cue_on)
    if info.ET
        Eyelink('message', num2str(trigger_enc.cue_on));
    end
    
    WaitSecs(2);
    
    % back in fixation
    Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]);
    Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
    Screen('Flip', window);
    trigger(trigger_enc.cue_off)
    if info.ET
        Eyelink('message', num2str(trigger_enc.cue_off));
    end

    % trial starts:
    correctness = {'error','correct','missed'};
    save_d = [];
    for trial = 1:nTrials
        
        disp(['>>> Trial: ',num2str(trial),' of ', num2str(nTrials)])
        
        thisTrial = d_matrix{trial};

        % last sample:
        last_angle = thisTrial(end,2);
        answer_name = {'L','R'};
        Trial.true_answer(trial) = answer_name{(last_angle>=4)+1};
        
        Trial_run;
        Receive_Feedback;
        disp(['user responded: ',Trial.answer(trial),' ',correctness{Trial.eval_answer(trial)+1}])
        
        save_d = [save_d; thisTrial(end,:),Trial.true_answer(trial),...
                          Trial.eval_answer(trial),...
                          Trial.RT(trial)];
            
        save_respMatrix{block} = save_d;
        
        if info.ET
            Eyelink('message', num2str(trigger_enc.trial_end));
        end
        
        save(sname,'Trial','Gabor','trigger_enc','info','save_designMatrix','save_respMatrix');

    end % end of the trials
    disp('>>> mini block ended')
    
    trigger(trigger_enc.block_end);  % trigger to mark end of the block
    if  info.ET
        Eyelink('message', num2str(trigger_enc.block_end));
    end

end % end of mini blocks (locations)

toc;

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


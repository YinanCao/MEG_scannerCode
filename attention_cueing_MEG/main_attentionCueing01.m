clear; clc; close all;

debug = 0;
cue2StimGap = 0.3;

cd /home/usera/Documents/MEG_scannerCode/attention_cueing_MEG/

datadir = '/home/usera/Documents/';
log_dir = [datadir 'Log'];
if ~exist(log_dir, 'dir')
   mkdir(log_dir);
end
Screen('Preference', 'SkipSyncTests', 0);
SubNo = 1;
SubName = 'Kos';
EL_flag = 1;
trigger_flag = 1;
keyLR = {'b','z'};
dopractice = 0;

all_angles = [-67.5 -45 -22.5 22.5  45  67.5];

pow = 0.5;
jnd = 0.07;
s_jnd = (0.5+jnd)^pow-0.5.^pow;
all_contrast = [0.2,0.5,0.8];
c = all_contrast;
jnd_l = c - exp(log(c.^pow - s_jnd)./pow);
jnd_r = exp(log(c.^pow + s_jnd)./pow) - c;
jnd_pow = [-jnd_l',jnd_r'];

map_code = 2;
session_type = 'B';

if map_code == 1
    mapping = ['R','L']; % change this
    map = {'probe contrast is higher'; 'probe contrast is lower'};
    if session_type == 'W'
        map_color = {[1 1 1], [.6 .6 .6]};
    else
        map_color = {1-[1 1 1], 1-[.6 .6 .6]};
    end
else
    mapping = ['L','R']; % change this
    map = {'probe contrast is lower'; 'probe contrast is higher'};
    if session_type == 'W'
        map_color = {[.6 .6 .6], [1 1 1]};
    else
        map_color = {1-[.6 .6 .6], 1-[1 1 1]};
    end
end
map_str = ['probe<sample=',mapping(1)];

Block_type = 'f';
Age = 24;
Gender = 'F';
Hand = 'R';
session_No = 1;


addpath(genpath('/Applications/Psychtoolbox'));
sca;




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
left     = KbName(keyLR{1});
right    = KbName(keyLR{2});
% left foot: 1!
% right foot: '2@'

% Open the Window
% 
if ~debug
    HideCursor;
end
smallWindow4Debug  = [0, 0, 1920, 1080];
if debug
    smallWindow4Debug  = [0 0 1920 1080]/1.2;
end 
Screen('Preference', 'TextRenderer', 1); % smooth text
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
Set_Vars;
Setup_keys;


% % calibration:
% if info.ET
%     disp('ET calibrating')
%     [el, info] = ELconfig(window, ['sub',num2str(info.SubNo),'_sess',...
%         num2str(0),'_b',num2str(0)], info, screenNumber);
%     % Calibrate the eye tracker
%     EyelinkDoTrackerSetup(el);
% end

%---------------
% Start the task
%---------------
DrawFormattedText(window, 'Ready? Press [SPACE] to start!', 'center', center_y+175,white);
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




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dopractice
while 1
    doMask = 0;
    block = 3;
    
    Task_message;
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
   
    % define the trial parameters in this block:
    change = repmat([-1,1],1,nTrials/2);
    change = change(randperm(nTrials));
    answer = mapping((change>0)+1);
    
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
    Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]);
    Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
    Screen('Flip', window);
    WaitSecs(1);
    
    Set_designX;
    for trial = 1:nTrials % nTrials was defined in Set_Vars.m
        % cue position:
        Trial.cue_position(trial,:) = design_x(:,trial,1,block); % e.g., [1,1,0]

        % stimulus angle: % 3
        this_o = design_x(:,trial,2,block);
        Trial.orientation(trial,:) = Trial.Gabor_orientation(this_o);

        % stimulus contrast
        Trial.contrast(trial,:) = Gabor.tr_contrast(design_x(:,trial,3,block));
        
        probe_pos = design_x(:,trial,4,block);
        Trial.probe_pos(trial,:) = probe_pos;
        % stim contrast at probe location:
       
        Trial.true_answer(trial) = answer(trial);
        jnd_prac = 0.18;
        Trial.probe_contrast(trial,:) = Trial.contrast(trial,probe_pos==1) + jnd_prac*change(trial);
        
    end
    
    nstop = 6;
    for trial = 1:nstop % nTrials
        Trial_run;
        Receive_Feedback;
    end % end of the trials
    
    final_message = sprintf('Practice finished, thanks! \n \n');
    DrawFormattedText(window, final_message, 'center', 'center', WhiteIndex(window));
    DrawFormattedText(window, 'Do you want to proceed to real experiment?', 'center', center_y+100,white);
    DrawFormattedText(window, '1: yes, proceed', 'center', center_y+150,white);
    DrawFormattedText(window, '2: no, more practice', 'center', center_y+200,white);
    Screen('Flip', window);
    
    TTL = 0; % Get the TTL from the scanner
    while TTL==0
        [keyIsDown, secs, keyCode] = KbCheck(-3, 2);  % Check keyboard press
        if strcmp(KbName(keyCode),keyLR{1})==1  % TTL
            TTL = 1;    % Start the experiment
            debrun = GetSecs; %%% Scanning starts!!!!
            disp('OK, let''s start!!')
        elseif strcmp(KbName(keyCode),keyLR{2})==1  % TTL
            TTL = 2;
        else
            TTL = 0;
        end
    end
    Screen('Flip', window);
    
    if TTL==1
        break;
    end

end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% main experiment
for session = 1
    
    doMask = 0;
    if mod(session,2)
        %doMask = 1;
    end
    
    if doMask
%         mask_str = 'mask';
    else
        mask_str = 'nomask';
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> % 
    for block = 1:3

        disp(['starting Session ',num2str(session),' Block ',num2str(block)])

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
        pause(.5)
        Screen('Flip', window);

        % ET calibration:
        if info.ET
            disp('ET calibrating')
            [el, info] = ELconfig(window,...
                [SubName,'_AC',num2str(session),num2str(block)], info, screenNumber);
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

        Task_message;
        TTL = 0; % Get the TTL from the scanner
        while TTL==0
            [keyIsDown, secs, keyCode] = KbCheck(-3, 2);  % Check keyboard press
            if strcmp(KbName(keyCode),keyLR{1}) || strcmp(KbName(keyCode),keyLR{2})...
                || strcmp(KbName(keyCode),'space')
                TTL = 1;    % Start the experiment
                debrun = GetSecs; %%% Scanning starts!!!!
                disp('OK, let''s start!!')
            else
                TTL = 0;
            end
        end
        pause(1);
        Screen('Flip', window);

        c = clock;
        sname = sprintf('%s/%s_%s_%s_%s_%s_block_%d_%02d%02d-%02d%02d.mat',...
           log_dir,SubName,session_type,Block_type,map_str,mask_str,block,c(3),c(2),c(4),c(5));

        % define the trial parameters in this block:
        change = repmat([-1,1],1,nTrials/2);
        change = change(randperm(nTrials));
        answer = mapping((change>0)+1);

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

        % Start Eyelink recording
        if info.ET
            disp('ET recording >>>>>>>>>')
            Eyelink('StartRecording');
            WaitSecs(0.1);
            Eyelink('message', 'Start recording Eyelink');
            trigger(trigger_enc.EL_start);
        end

        %%% waiting for the first trial and not start the task immediately
        Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]);
        Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
        Screen('Flip', window);
        WaitSecs(1);

        Set_designX;
        for trial = 1:nTrials % nTrials was defined in Set_Vars.m

            % cue position:
            Trial.cue_position(trial,:) = design_x(:,trial,1,block); % e.g., [1,1,0]

            % stimulus angle: % 3
            this_o = design_x(:,trial,2,block);
            Trial.orientation(trial,:) = Trial.Gabor_orientation(this_o);

            % stimulus contrast
            Trial.contrast(trial,:) = Gabor.tr_contrast(design_x(:,trial,3,block));

            probe_pos = design_x(:,trial,4,block);
            Trial.probe_pos(trial,:) = probe_pos;
            % stim contrast at probe location:

            Trial.true_answer(trial) = answer(trial);

            idx = (change>0)+1;
            Trial.probe_contrast(trial,:) = Trial.contrast(trial,probe_pos==1) + jnd_pow(probe_pos==1, idx(trial));
        end

        correctness = {'error','correct','missed'};
        for trial = 1:nTrials
            disp(['>>> Trial: ',num2str(trial),' of ', num2str(nTrials)])
            Trial_run;
            Receive_Feedback;
            disp(['user responded: ',Trial.answer(trial),' ',correctness{Trial.eval_answer(trial)+1}])

            trigger(trigger_enc.trial_end)
            if info.ET
                Eyelink('message', num2str(trigger_enc.trial_end));
            end
            save(sname,'Trial','Gabor','trigger_enc','info');

        end % end of the trials
        disp('>>> block ended')
        trigger(trigger_enc.block_end);  % trigger to mark end of the block
        if  info.ET
            Eyelink('message', num2str(trigger_enc.block_end));
        end

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

        Trial.Acc_withoutMissed   = sum(Trial.eval_answer==1)./(sum(Trial.eval_answer==1)+sum(Trial.eval_answer==0));
        Trial.Acc_withMissed      = sum(Trial.eval_answer==1)./nTrials;
        Trial.NoMissed            = sum(Trial.eval_answer==99);

        final_message = sprintf('Thanks! Please rest... \n \n Your accuracy score was: %0.2f',Trial.Acc_withMissed*100);
        DrawFormattedText(window, final_message, 'center', 'center', WhiteIndex(window));
        DrawFormattedText(window, 'Press [SPACE] to start!', 'center', center_y+175,white);
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

    end

end % end of session

% Close and clear all
Screen('CloseAll');
ShowCursor;
fclose('all');
Priority(0);
sca;



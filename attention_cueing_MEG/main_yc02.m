clear; clc; close all;

SubName = 'kos';
pow = 0.5;
jnd = 0.1;
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
SubNo = 1;
Age = 24;
Gender = 'F';
Hand = 'R';
EL_flag = 0;
session_No = 1;

cd('/home/donnerlab/Documents/MATLAB/Yinan/attention_cueing/attention_cueing_lab/')
addpath(genpath('/Applications/Psychtoolbox'));
sca;

cd(pwd);
log_dir = [pwd '/Log'];
if ~exist(log_dir, 'dir')
   mkdir(log_dir);
end

Screen('Preference', 'SkipSyncTests', 2);
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
right     = KbName('6');
left      = KbName('4');
% middle    = KbName('5');
% Open the Window
HideCursor;
Screen('Preference', 'TextRenderer', 1); % smooth text
smallWindow4Debug    =  []; %[0, 0, 1920, 1080]/1.1;
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
Setup_ET;
%Setup_button;

% Start Eyelink recording
if info.ET
    Eyelink('StartRecording');
    WaitSecs(0.1);
    Eyelink('message', 'Start recording Eyelink');
end

%---------------
% Start the task
%---------------
DrawFormattedText(window, 'Ready? Press [SPACE] to start!', 'center', center_y+175,white);
Screen('Flip', window);
trigger(trigger_enc.block_start);  % trigger to mark start of the block
if  info.ET
    Eyelink('message', num2str(trigger_enc.block_start));
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

% KbWait();
% flush_kbqueues(info.kbqdev);

%%%% design_x, column order: 
% cue_x,
% angle_x,
% contrast_x,
% probe_x

% practice trials:


while 1
    doMask = 1;
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
    
    nstop = 12;
    for trial = 1:nstop % nTrials
        Trial_run;
        Receive_Feedback;
    end % end of the trials
    
    final_message = sprintf('Practice finished, thanks! \n \n');
    DrawFormattedText(window, final_message, 'center', 'center', WhiteIndex(window));
    DrawFormattedText(window, 'Do you want to proceed to real experiment?', 'center', center_y+100,white);
    DrawFormattedText(window, 'Y: yes, proceed', 'center', center_y+150,white);
    DrawFormattedText(window, 'N: no, more practice', 'center', center_y+200,white);
    Screen('Flip', window);
    
    TTL = 0; % Get the TTL from the scanner
    while TTL==0
        [keyIsDown, secs, keyCode] = KbCheck(-3, 2);  % Check keyboard press
        if strcmp(KbName(keyCode),'y')==1  % TTL
            TTL = 1;    % Start the experiment
            debrun = GetSecs; %%% Scanning starts!!!!
            disp('OK, let''s start!!')
        elseif strcmp(KbName(keyCode),'n')==1  % TTL
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

% main experiment

for session = 1:2
    
    doMask = 0;
    if mod(session,2)
        doMask = 1;
    end
    
    if doMask
        mask_str = 'mask';
    else
        mask_str = 'nomask';
    end

for block = 1:3
    
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
    
    %%% waiting for the first trial and not start the task immediately
    Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]);
    Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
    Screen('Flip', window);
    WaitSecs(1);
    
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
    

    
    for trial = 1:nTrials
        
        Trial_run;
        Receive_Feedback;

        trigger(trigger_enc.fb_cue_off);  % trigger to mark end of the feedback cue
        trigger(trigger_enc.trial_end);   % trigger to mark end of the trial
        if info.ET
            Eyelink('message', num2str(trigger_enc.fb_cue_off));
            Eyelink('message', num2str(trigger_enc.trial_end));
        end
        
        save(sname,'Trial','Gabor','trigger_enc','info');

    end % end of the trials
    
    trigger(trigger_enc.block_end);  % trigger to mark end of the block
    if  info.ET
        Eyelink('message', num2str(trigger_enc.block_end));
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





% End of the Task

% WaitSecs(2);
% 
% TDMOGtask.info = info;
% TDMOGtask.Trial = Trial;
% TDMOGtask.Gabor = Gabor;
% TDMOGtask.trigger = trigger_enc;

% Save ET data
% if info.ET
%     Eye_path=sprintf('Eye_data/%s/%s/Sub (%i)/Se (%i)',session_type,Block_type,SubNo,session_No);
%     if ~isdir (Eye_path)
%         mkdir(Eye_path);
%     end
%     Save_EL_path=sprintf('Eye_data/%s/%s/Sub (%i)/Se (%i)/block_%i',session_type,Block_type,SubNo,session_No,Block_No);
%     Eyelink('CloseFile');
%     Eyelink('WaitForModeReady', 500);
%     try
%         Eyelink('ReceiveFile', info.edfFile, Save_EL_path);
%     catch
%         warning(['eye_tracker data did not saved to disk']);
%     end
%     Eyelink('StopRecording');
% end




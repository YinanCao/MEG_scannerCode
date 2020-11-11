clear; clc; close all;

debug = 0;

probeDotcontrast = 0.65; % 0.5 is grey
ndotFrames = 1;

probeDotScale = 1/8;
cd /home/usera/Documents/MEG_scannerCode/attention_cueing_MEG_dynamic/

datadir = '/home/usera/Documents/';
log_dir = [datadir 'Log'];
if ~exist(log_dir, 'dir')
   mkdir(log_dir);
end

Screen('Preference', 'SkipSyncTests', 0);
SubNo = 1;
SubName = 'tmp';
EL_flag = 1;
trigger_flag = 1;
keyLR = {'z','g'}; % b,z,g,r for 1,2,3,4


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if debug
    keyLR = {'F','J'}; % b,z,g,r for 1,2,3,4
end

all_angles = [-67.5 -45 -22.5 22.5  45  67.5]; % Gabor orientations
all_contrast = 0.5*ones(1,3);

session_type = 'B';
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
        
        Set_designY;

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
            [el, info] = ELconfig_yc(window,[SubName,'_Ady',num2str(session),num2str(block)], info, screenNumber);
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

        Task_message; % ok
        
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
        sname = sprintf('%s/%s_%s_%s_%s_block_%d_%02d%02d-%02d%02d.mat',...
           log_dir,SubName,'AttDyna',Block_type,mask_str,block,c(3),c(2),c(4),c(5));

        % define the trial parameters in this block:
%         change = repmat([-1,1],1,nTrials/2);
%         change = change(randperm(nTrials));
%         answer = mapping((change>0)+1);


        % reset
        Trial.cue_position1 = [];
        Trial.cue_position2 = [];
        Trial.orientation  = [];
        Trial.contrast     = [];
        Trial.probe_pos    = [];
        Trial.true_answer  = [];
        Trial.probe_contrast =[];
        Trial.RT = [];
        Trial.Timing = [];
        Trial.answer = [];
        Trial.eval_answer = [];
        Trial.dotpresence = [];

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

        answer_str = {'L','R'};
        for trial = 1:nTrials % nTrials was defined in Set_Vars.m

            % cue position:
            Trial.cue_position1(trial,:) = design_y(:,trial,1); % e.g., [1,1,0]
            Trial.cue_position2(trial,:) = design_y(:,trial,2);

            % stimulus angle:
            this_o = design_y(:,trial,4);
            Trial.orientation(trial,:) = Trial.Gabor_orientation(this_o);

            % stimulus contrast
            Trial.contrast(trial,:) = all_contrast;

            probe_pos = design_y(:,trial,3);
            Trial.probe_pos(trial,:) = probe_pos;
            % stim contrast at probe location:

            Trial.true_answer(trial) = answer_str{sum(probe_pos)+1};
            Trial.dotpresence(trial) = sum(probe_pos);
        end

        correctness = {'error','correct','missed'};
        loc = ['T','L','R'];
        for trial = 1:nTrials
            disp(['>>> Trial: ',num2str(trial),' of ', num2str(nTrials)])
            orix = Trial.orientation(trial,:);
            disp(['cue1 = ',loc(Trial.cue_position1(trial,:)>0),...
            ' | cue2 = ',loc(Trial.cue_position2(trial,:)>0),...
            ' | dot = ',loc(Trial.probe_pos(trial,:)>0),...
            ' | ori: ',num2str(orix(1)),' / ',num2str(orix(2)),' / ',num2str(orix(3))]);

            
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



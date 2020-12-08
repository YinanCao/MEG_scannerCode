clear; clc; close all;
cd /home/usera/Documents/MEG_scannerCode/choice27cond_FTag/
datadir = '/home/usera/Documents/';
log_dir = [datadir 'Log'];
if ~exist(log_dir, 'dir')
   mkdir(log_dir);
end
sca;

multisample_flag = 6;
debug = 0;
session_type = 'W';
tag_f = [63, 78, 85];
info.tagging_freq = tag_f;
GaborDiameter = 1.8;
all_angles = [20 45 70]; % Gabor orientations

nTrials = 72;

tagging_checkMode = 0;

Screen('Preference', 'SkipSyncTests', 0);
SubNo = 1;
SubName = 'MTM';
EL_flag = 0;
trigger_flag = 1;
keyLR = {'z','g','2@'}; % b,z,g,r for 1,2,3,4

% L_Hand     = KbName('z'); % 2
% R_Hand     = KbName('g'); % 3
% L_Foot     = KbName('1!');
% R_Foot     = KbName('2@');

Block_type = 'f';
Age = 24;
Gender = 'F';
Hand = 'R';
session_No = 1;

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
dark_grey = 0.1;
holder_c  = [0 1 1];

Gabor.outlineColor = 0.75*ones(1,3);

control_bkg = 0.3;

if tagging_checkMode
    control_bkg = 0;
end
% Define the keys
KbName('UnifyKeyNames');
left     = KbName(keyLR{1});
right    = KbName(keyLR{2});
middle   = KbName(keyLR{3});

%%
smallWindow4Debug  = [0, 0, 1920, 1080];
Screen('Preference', 'TextRenderer', 1); % smooth text
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, control_bkg, smallWindow4Debug, 32, 2,...
    [], multisample_flag, []);
% PsychImaging('OpenWindow', screenid, 0, [], 32, 2, [], 6, []);
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
%%

% Set needed variables1
Set_Vars_FT;
Setup_keys;

tag_setup_projector('open', 1);
tag_setup_projector('reset', 1);

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
Screen('Flip', window);
pause(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fixdotpos = CenterRectOnPointd([0 0 lineWidthPix lineWidthPix]*1.2, center_x, center_y);
tmp = [fixdotpos(1),0;
       0,fixdotpos(2);
       fixdotpos(3),0;
       0,fixdotpos(4)];
fixdotposX = [];
for q = 1:4
    newtmp = [];
    for edges = 1:size(tmp,1)
       [x,y] = convertToQuadrant(tmp(edges,:), windowRect, q);
       newtmp = [newtmp; x,y];
    end
    fixdotposX(q,:) = [newtmp(1,1), newtmp(2,2), newtmp(3,1), newtmp(4,2)];
end
for q = 1:4
 [center_x_q(q), center_y_q(q)] = convertToQuadrant([center_x, center_y], windowRect, q);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

mask_str = 'nomask';

Set_design; % load design matrix
Nblock_all = length(design_blk);
% main experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> % 
sess_count = 1;

for block = 1:9 %Nblock_all

    disp(['Block ',num2str(block)])

    HideCursor;
    Screen('TextSize', window, 22)

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
    pause(.5)

    % ET calibration:
    if info.ET
        disp('ET calibrating')
        [el, info] = ELconfig_yc(window,[SubName,'FT27',num2str(session),num2str(block)], info, screenNumber);
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
    pause(.5);
    Screen('Flip', window);
    pause(.5)
    % >>>>>>>>>>>>>>>>>>>>>>>>>
    % >>>>>>>>>>>>>>>>>>>>>>>>>
    % >>>>>>>>>>>>>>>>>>>>>>>>>

    Task_message; % ok

    TTL = 0; % Get the TTL from the scanner
    while TTL==0
        [keyIsDown, secs, keyCode] = KbCheck(-3, 2);  % Check keyboard press
        if strcmp(KbName(keyCode),keyLR{1}) || strcmp(KbName(keyCode),keyLR{2})...
            || strcmp(KbName(keyCode),'space') || strcmp(KbName(keyCode),keyLR{3})
            TTL = 1;    % Start the experiment
            debrun = GetSecs; %%% Scanning starts!!!!
            disp('OK, let''s start!!')
        else
            TTL = 0;
        end
    end
    pause(.5)
    Screen('Flip', window);
    pause(.5)

    c = clock;
    sname = sprintf('%s/%s_%s_%s_%s_block_%d_%02d%02d-%02d%02d.mat',...
       log_dir,SubName,'choice27FTnew',Block_type,mask_str,block,c(3),c(2),c(4),c(5));

    % reset
    Trial.orientation  = [];
    Trial.contrast     = [];
    Trial.true_answer  = [];
    Trial.RT = [];
    Trial.Timing = [];
    Trial.answer = [];
    Trial.eval_answer = [];
    Trial.tagging_freq = [];

    % Start Eyelink recording
    if info.ET
        disp('ET recording >>>>>>>>>')
        Eyelink('StartRecording');
        WaitSecs(0.1);
        Eyelink('message', 'Start recording Eyelink');
        trigger(trigger_enc.EL_start);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %****************************%
    tag_setup_projector('set', 1);
    %%% waiting for the first trial and not start the task immediately
    for k = 1:4
        Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
    end
    Screen('Flip', window);
    WaitSecs(5);

    answer_str = {'M','L','R'};
    design_y = design_blk{block};

    fake_f = repmat(1:3,1,80);
    for trial = 1:nTrials % nTrials was defined in Set_Vars.m

        % stimulus angle:
        this_o = design_y(trial,:,2);
        Trial.orientation(trial,:) = Trial.Gabor_orientation(this_o);

        % stimulus contrast
        Trial.contrast(trial,:) = design_y(trial,:,1);
        [~,max_gabor] = max(Trial.contrast(trial,:));

        % true answer:
        Trial.true_answer(trial) = answer_str{max_gabor};

        Trial.tagging_freq(trial,:) = randperm(3);
        if tagging_checkMode
            Trial.tagging_freq(trial,1) = fake_f(trial);
        end
    end

    correctness = {'error','correct','missed'};
    loc = ['T','L','R'];
    for trial = 1:nTrials
        disp(['>>> Trial: ',num2str(trial),' of ', num2str(nTrials)])
%             orix = Trial.orientation(trial,:);
%             disp(['cue1 = ',loc(Trial.cue_position1(trial,:)>0),...
%             ' | cue2 = ',loc(Trial.cue_position2(trial,:)>0),...
%             ' | dot = ',loc(Trial.probe_pos(trial,:)>0),...
%             ' | ori: ',num2str(orix(1)),' / ',num2str(orix(2)),' / ',num2str(orix(3))]);

        Trial_run_FT;
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

    tag_setup_projector('reset', 1);
    ShowCursor;
    Screen('TextSize', window, 22); % define text font

    final_message = sprintf('Thanks! Please rest... \n \n Your accuracy score was: %0.2f',Trial.Acc_withMissed*100);
    DrawFormattedText(window, final_message, 'center', 'center', WhiteIndex(window));
    
    if ~mod(block,3) % every 3 blocks
        DrawFormattedText(window, ['Session ',num2str(sess_count),' is done'], 'center', center_y+175,white);
        sess_count = sess_count + 1;
    else
        DrawFormattedText(window, 'Press [SPACE] for next block!', 'center', center_y+175,white);
    end
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

end % end of block


% Close and clear all
Screen('CloseAll');
ShowCursor;
tag_setup_projector('reset', 1);
tag_setup_projector('close', 1);
fclose('all');
Priority(0);
sca;



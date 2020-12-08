clear; clc; close all;
sca;

cd /home/usera/Documents/MEG_scannerCode/JNDquest/
datadir = '/home/usera/Documents/';
log_dir = [datadir 'Log'];
if ~exist(log_dir, 'dir')
   mkdir(log_dir);
end

tag_f = [63, 78, 85];
info.tagging_freq = tag_f;
GaborDiameter = 1.8;
control_bkg = 0.325;
all_angles = [20 45 70]; % Gabor orientations

SubName='xx';
SubNo=1;
Age=1;
Gender='F';
Hand='R';
session_type='W';
session_No=1;
Block_type='f';
Block_No=1;
nTrials=80;
EL_flag=0;

multisample_flag = 6;
Screen('Preference', 'SkipSyncTests', 0);
%%
%-----------------------------------
% Clear the workspace and the screen
%-----------------------------------
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
dark_grey = 0.1;
Gabor.outlineColor = 0.75*ones(1,3);

% Define the keys
KbName     ('UnifyKeyNames');
left      = KbName('z');
right     = KbName('g');
% middle     = KbName('r');
% Open the Window
Screen('Preference', 'TextRenderer', 1); % smooth text
smallWindow4Debug    = [0, 0, 1920, 1080];
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, control_bkg, smallWindow4Debug, 32, 2,...
    [], multisample_flag, []);
[center_x, center_y] = RectCenter(windowRect);
Screen('TextFont', window, 'Helvetica'); % define text font
Screen('TextSize', window, 22); % define text font
info.window_rect  = windowRect;
info.frameDur     = Screen('GetFlipInterval', window); %duration of one frame
info.frameRate    = Screen('NominalFrameRate', window);
ifi = info.frameDur;

% info.frameRate = 60;

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Set needed variables1
Set_Vars;
Setup_keys;
%% quad conversion
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
%%
tag_setup_projector('open', 1);
tag_setup_projector('reset', 1);
HideCursor;
%---------------
% Start the task
%---------------
Task_message;
% trigger(trigger_enc.block_start);  % trigger to mark start of the block
KbWait();
flush_kbqueues(info.kbqdev);

tag_setup_projector('set', 1);
WaitSecs(1);

for k = 1:4
    Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
end
Screen('Flip', window);
WaitSecs(1);

% Define Quest counter to know which quest should be updated in each trial
for q_c=1:Trial.num_quests
    eval(['q_counter' num2str(q_c) '=1']);
end

for trial=1:nTrials
    Trial_run;
    Receive_Feedback;
    % Update the Quest
    if (Trial.eval_answer(trial))==2
        w_q = num2str(Trial.Which_quest(trial));
        eval (['Quest.q' w_q '(q_counter' w_q ') = Quest.q' w_q ...
            '(q_counter' w_q '-1);']);
    else
        response = Trial.eval_answer(trial);
        w_q = num2str(Trial.Which_quest(trial));
        eval (['Quest.q' w_q '(q_counter' w_q ') = QuestUpdate(Quest.q' w_q ...
            '(q_counter' w_q '-1),Trial.log10_tr(trial),response);']);
    end
%     trigger(trigger_enc.fb_cue_off);  % trigger to mark end of the feedback cue
%     trigger(trigger_enc.trial_end);   % trigger to mark end of the trial

    
end% end of the trials
Trial.Acc_withoutMissed   = sum(Trial.eval_answer==1)./(sum(Trial.eval_answer==1)+sum(Trial.eval_answer==0));
Trial.Acc_withMissed      = sum(Trial.eval_answer==1)./nTrials;
Trial.NoMissed            = sum(Trial.eval_answer==2);

if nTrials>20
    e=(round(nTrials./(Trial.num_quests*10))-1)*10+1;
else
    e=nTrials./Trial.num_quests;
end
for q_c=1:Trial.num_quests
    if q_c == 1
eval (['quantile_list_log10 = QuestQuantile(Quest.q' num2str(q_c) '(e:end-1))-log10(Trial.Gabor_all_contrast_base('  int2str(q_c) '));']);
eval (['mean_list_log10 = QuestMean(Quest.q' num2str(q_c) '(e:end-1))-log10(Trial.Gabor_all_contrast_base('  int2str(q_c) '));']);
eval (['mode_list_log10 = QuestMode(Quest.q' num2str(q_c) '(e:end-1))-log10(Trial.Gabor_all_contrast_base('  int2str(q_c) '));']);
eval (['quantile_list = 10.^(QuestQuantile(Quest.q' num2str(q_c) '(e:end-1)))-(Trial.Gabor_all_contrast_base('  int2str(q_c) '));']);
eval (['mean_list = 10.^(QuestMean(Quest.q' num2str(q_c) '(e:end-1)))-(Trial.Gabor_all_contrast_base('  int2str(q_c) '));']);
eval (['mode_list = 10.^(QuestMode(Quest.q' num2str(q_c) '(e:end-1)))-(Trial.Gabor_all_contrast_base('  int2str(q_c) '));']);
eval (['JND_contrast_list= Quest.JND_contrast' num2str(q_c) '(e:end)']);
eval (['JND_log10contrast_list =  Quest.JND_log10contrast' num2str(q_c) '(e:end)']);
        
    else
eval (['quantile_list_log10 = [quantile_list_log10 QuestQuantile(Quest.q' num2str(q_c) '(e:end-1))-log10(Trial.Gabor_all_contrast_base('  int2str(q_c) '))]']);
eval (['mean_list_log10 = [mean_list_log10 QuestMean(Quest.q' num2str(q_c) '(e:end-1))-log10(Trial.Gabor_all_contrast_base('  int2str(q_c) '))]']);
eval (['mode_list_log10 = [mode_list_log10 QuestMode(Quest.q' num2str(q_c) '(e:end-1))-log10(Trial.Gabor_all_contrast_base('  int2str(q_c) '))]']);
eval (['quantile_list = [quantile_list 10.^(QuestQuantile(Quest.q' num2str(q_c) '(e:end-1)))-(Trial.Gabor_all_contrast_base('  int2str(q_c) '))]']);
eval (['mean_list = [mean_list 10.^(QuestMean(Quest.q' num2str(q_c) '(e:end-1)))-(Trial.Gabor_all_contrast_base('  int2str(q_c) '))]']);
eval (['mode_list = [mode_list 10.^(QuestMode(Quest.q' num2str(q_c) '(e:end-1)))-(Trial.Gabor_all_contrast_base('  int2str(q_c) '))]']);
eval (['JND_contrast_list = [JND_contrast_list Quest.JND_contrast' num2str(q_c) '(e:end)]']);
eval (['JND_log10contrast_list = [JND_log10contrast_list Quest.JND_log10contrast' num2str(q_c) '(e:end)]']);
        
    end
end


Quest.Quantile_JND_log10     = mean(quantile_list_log10);
Quest.Mean_JND_log10         = mean(mean_list_log10);
Quest.Mode_JND_log10         = mean(mode_list_log10);
Quest.Quantile_JND           = mean(quantile_list);
Quest.Mean_JND               = mean(mean_list);
Quest.Mode_JND               = mean(mode_list);

%%
tag_setup_projector('reset', 1);
Screen('TextSize', window, 22); % define text font
% End of the Task
final_message=sprintf('Thank you so much ... \n \n Your accuracy score is: %0.2f',Trial.Acc_withMissed*100);
DrawFormattedText(window, final_message, 'center', 'center', WhiteIndex(window));
Screen('Flip', window);
WaitSecs(2);
% trigger(trigger_enc.block_end);  % trigger to mark end of the block

JND_BDMOGtask.info=info;
JND_BDMOGtask.Trial=Trial;
JND_BDMOGtask.Gabor=Gabor;
JND_BDMOGtask.Quest=Quest;
JND_BDMOGtask.trigger=trigger_enc;

% Beh_path=sprintf('Beh_data/%s/%s/Sub (%i)/Se (%i)',session_type,Block_type,SubNo,session_No);
% if ~isdir (Beh_path)
%     mkdir(Beh_path);
% end
% Save_beh_path=sprintf('Beh_data/%s/%s/Sub (%i)/Se (%i)/block_%i',session_type,Block_type,SubNo,session_No,Block_No);
% save(Save_beh_path,'JND_BDMOGtask');

JND.quantile         = Quest.Quantile_JND;
JND.mean             = Quest.Mean_JND;
JND.mode             = Quest.Mode_JND;
JND.quantile_log10   = Quest.Quantile_JND_log10;
JND.mean_log10       = Quest.Mean_JND_log10;
JND.mode_log10       = Quest.Mode_JND_log10;
JND.list_tr          = JND_contrast_list;
JND.list_tr_q1       = JND_contrast_list(1:(length(JND.list_tr)/2));
JND.list_tr_q2       = JND_contrast_list((length(JND.list_tr)/2)+1:end);
JND.mean_tr_q1       = mean(JND.list_tr_q1);
JND.mean_tr_q2       = mean(JND.list_tr_q2);
JND.list_tr_log10    = JND_log10contrast_list;
JND.list_tr_q1_log10 = JND_log10contrast_list(1:(length(quantile_list)/2));
JND.list_tr_q2_log10 = JND_log10contrast_list((length(quantile_list)/2)+1:end);
JND.mean_tr_q1_log10 = mean(JND.list_tr_q1_log10);
JND.mean_tr_q2_log10 = mean(JND.list_tr_q2_log10);
JND.base_value       = Trial.Gabor_all_contrast_base(1);



% Save_thr_path1=sprintf('Beh_data/%s/%s/Sub (%i)/thr_block_%i',session_type,Block_type,SubNo,Block_No);
% save(Save_thr_path1,'JND');
% 
% Save_thr_path2=sprintf('Beh_data/%s/%s/Sub (%i)/Se (%i)/thr_block_%i',session_type,Block_type,SubNo,session_No,Block_No);
% save(Save_thr_path2,'JND');

% try 
%     send_email;
% catch
%     m=0;
% end

% save this varr: Quest.Mean_JND

estimated_jnd = [Quest.Quantile_JND]

disp(['JND = ', num2str(estimated_jnd)])

% Close and clear all
Screen('CloseAll');
ShowCursor;
fclose('all');
Priority(0);
sca;
tag_setup_projector('close', 1);

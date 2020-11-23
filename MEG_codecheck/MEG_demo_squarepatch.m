clear; clc; close all;
% Yinan Cao, UKE 11/2020
Screen('CloseAll');
sca;

Screen('Preference', 'SkipSyncTests', 0);

info.ET = 0;
info.SubNo = 1;
info.BlockNo = 1;
info.do_trigger = 1;
info.kb_setup = 'noMEG';

% info.width
% info.height

% Setup the ParPort
if info.do_trigger
    addpath matlabtrigger/
else
    addpath faketrigger/
end
trigger_enc = setup_trigger;

KbName('UnifyKeyNames');
% set up key
setup_key;
if strcmp(info.kb_setup,'MEG')
    Lft = '1';
    Rgt = '4';
    ext = 'ESCAPE';
    flush_kbqueues(info.kbqdev);
else
    Lft = 'LeftArrow';
    Rgt = 'RightArrow';
    ext = 'ESCAPE'; 
end

% 
% 
% log_dir = [pwd '/Log'];
% if ~exist(log_dir, 'dir')
%    mkdir(log_dir);
% end

subj = 'yinan';
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

% Open the Window
% HideCursor;
Screen('Preference', 'TextRenderer', 1); % smooth text
% smallWindow4Debug    =  [0, 0, 1920, 1080]/1.3;
smallWindow4Debug  = [];
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, smallWindow4Debug, 32, 2,...
    [], [],  kPsychNeed32BPCFloat);
[center_x, center_y] = RectCenter(windowRect);
Screen('TextFont', window, 'Helvetica'); % define text font
Screen('TextSize', window, 22); % define text font
info.window_rect  = windowRect;
info.frameDur     = Screen('GetFlipInterval', window); %duration of one frame
info.frameRate    = Screen('NominalFrameRate', window);
ifi = info.frameDur;

% stimulus:
baseRect = [0 0 200 200];
centeredRect = CenterRectOnPointd(baseRect, center_x, center_y);
rectColor = [1 1 1];

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


if info.ET
    [el, info] = ELconfig(window, ['s',num2str(info.SubNo),'_b',num2str(info.BlockNo)], info, screenNumber);
    %[el, info] = ELconfig(window, [subj,sess,num2str(b)], info, screenNumber);
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);
end

% Start Eyelink recording
if info.ET
    Eyelink('StartRecording');
    WaitSecs(0.1);
    Eyelink('message', 'Start recording Eyelink');
end

% trials:
for trial = 1:20
     
    Screen('FillRect', window, rectColor, centeredRect);
    
    [~, start_stim] = Screen('Flip', window);
    trigger(16);
    if info.ET
        Eyelink('message', 'stimon'); 
    end
    
    stimFrames = round(2/ifi);
    [~, end_stim] = Screen('Flip', window, start_stim +  (stimFrames - .5)*ifi); % cue gone
    trigger(14);
    if info.ET
        Eyelink('message', 'stimoff'); 
    end
    
    tel = 0;
    double_press = false;
    resp = 0;
    deadline = 1.5;
    kbqdev = info.kbqdev;
    while (resp==0 && tel < deadline)
        [keyIsDown, firstPress] = check_kbqueues(kbqdev);
        tel = GetSecs-start_stim;
        if keyIsDown  % logging response type
            secs = GetSecs;
            keys = KbName(firstPress);  % retrieving string variable containing currently pressed key(s)
            resp = 1;
            if iscell(keys)
                double_press = true;  % in case of a double-press...having this as first 'if' 
                % test means it takes absolute precedence - any trial on which two keys 
                % are simulaneously pressed, at any time, will be marked error
                trigger(trigger_enc.resp_bad);  % trigger to mark a bad response
                if info.ET, Eyelink('message', num2str(trigger_enc.resp_bad)); end
            else
                RT = secs-start_stim;  % logging RT relative to trial start
                switch keys
                    case ext
                        sca
                        throw(MException('EXP:Quit', 'User request quit'));
                    case {Lft, 'LeftArrow', '1!'}
                        resp = 1;
                        trigger(trigger_enc.resp_left);  % trigger to mark a left response
                        if info.ET, Eyelink('message', num2str(trigger_enc.resp_left)); end
                    case {Rgt, 'RightArrow', '4$'}
                        resp = 2;
                        trigger(trigger_enc.resp_right);  % trigger to mark a right response
                        if info.ET, Eyelink('message', num2str(trigger_enc.resp_right)); end
                    otherwise
                        resp = 99;  % in case any button other than task relevant ones is pressed
                        trigger(trigger_enc.resp_bad);  % trigger to mark a bad response
                        if info.ET, Eyelink('message', num2str(trigger_enc.resp_bad)); end
                end
            end
        end
    end
    
    pause(.5)
    if info.ET
        Eyelink('message', 'trialend'); 
    end

end

% Save Eyelink data
if info.ET
    time_str = strrep(mat2str(fix(clock)),' ','_');
    fprintf('Saving EyeLink data to %s\n', [log_dir,subj,'/',info.BlockNo])
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

sca
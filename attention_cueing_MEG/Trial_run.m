
cue_N = sum(Trial.cue_position(trial,:));
DrawFormattedText(window, num2str(cue_N), 'center', 'center', Trial.cueNumColor);
[~, start_cueNumber] = Screen('Flip', window);
trigger(trigger_enc.cue_N)
cueNumberFrames = round(Trial.cueNumberD/ifi);
Screen('Flip', window, start_cueNumber +  (cueNumberFrames - .5)*ifi); % stop it
trigger(trigger_enc.cue_N)
% WaitSecs(.1);

% fixation presentation before stimulus onset
Rotated_fixation(window,fix_rect,center_x,center_y,dark_grey,[0,90]);
Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
% [~, start_delay] = Screen('Flip', window);
[~, start_fix] = Screen('Flip', window);
trigger(trigger_enc.trial_start);  
if info.ET
    Eyelink('command', 'record_status_message "TRIAL %d/%d"', trial, nTrials);
    Eyelink('message', 'TRIALID %d', trial);
    Eyelink('message', num2str(trigger_enc.trial_start));
end
fixFrames = round(Trial.BRD(trial)/ifi);

cueFrames = round(Trial.cueD/ifi);
% add cue:
make_cue;
Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]);
Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
[VBLTimestamp, cueOnsetTime] = Screen('Flip', window, start_fix+(fixFrames-0.5)*ifi);
trigger(trigger_enc.cue_on)
if info.ET
    Eyelink('message', num2str(trigger_enc.cue_on));
end

Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]);
Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
[~,cueOff] = Screen('Flip', window, cueOnsetTime +  (cueFrames - .5)*ifi); % cue gone
trigger(trigger_enc.cue_off)
if info.ET
    Eyelink('message', num2str(trigger_enc.cue_off));
end

cue2stimFrames = round(Trial.cue2StimD/ifi);
stimFrames = round(Trial.SD/ifi);
% Stimulus presentation
Make_gabor;
Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]);
Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
[~, stimOnset] = Screen('Flip', window, cueOnsetTime +  (cue2stimFrames - .5)*ifi);
trigger(trigger_enc.stim_on);  % trigger to mark start of the stim
if info.ET
    Eyelink('message', num2str(trigger_enc.stim_on));
end

% stop stimulus:
Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]);
Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
[~, stimOff] = Screen('Flip', window, stimOnset +  (stimFrames - .5)*ifi); % stim gone
Screen('Close', textureIndexTarg);
trigger(trigger_enc.stim_off);  % trigger to mark start of the stim
if info.ET
    Eyelink('message', num2str(trigger_enc.stim_off));
end

% present Mask:
% stim2Mask = round(0/ifi);

if doMask
    Make_noiseMask;
    Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]);
    Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
    [~, MaskOn] = Screen('Flip', window, stimOff); % probe on
    Screen('Close', textureIndexTarg);
end

stim2Probe = round(Trial.s2PD/ifi);
% present probe:
Make_probe;
Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]);
Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
[~, probeOn] = Screen('Flip', window, stimOff +  (stim2Probe - .5)*ifi); % probe on
trigger(trigger_enc.prob_on);  % trigger to mark start of the stim
if info.ET
    Eyelink('message', num2str(trigger_enc.prob_on));
end


% stop probe
probeFrames = round(Trial.ProbD/ifi);
Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]);
Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
[~, probeOff] = Screen('Flip', window, probeOn +  (probeFrames - .5)*ifi); % probe off


trigger(trigger_enc.prob_off);  % trigger to mark start of the stim
if info.ET
    Eyelink('message', num2str(trigger_enc.prob_off));
end

Screen('Close', textureIndexTarg);



probe2Resp = round(Trial.StRCD/ifi);
% response cue
Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]+45);
Screen('FillOval', window, blue, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
[~, respOn] = Screen('Flip', window, probeOff + (probe2Resp-0.5)*ifi);
trigger(trigger_enc.resp_cue_on);  % trigger to mark start of the response cue
if info.ET
    Eyelink('message', num2str(trigger_enc.resp_cue_on));
end
% Trial.real_SD(trial)=Trial.stimulus_off(trial)-Trial.stimulus_on(trial);
% Trial.real_StRCD(trial)=Trial.response_cue_on(trial)-Trial.stimulus_off(trial);
start = respOn;
% Trial.response_cue_on(trial);
flush_kbqueues(info.kbqdev);
%[keyIsDown, press_key]=check_kbqueues(info.kbqdev);
[keyIsDown, secs, press_key, deltaSecs] = KbCheck();
endrt = GetSecs;
while ( press_key(left)==0  && press_key(right)==0 && GetSecs-start<Trial.RCD)
    [keyIsDown, secs, press_key, deltaSecs] = KbCheck();
    endrt = secs;
end
% trigger(trigger_enc.prob_off);  % trigger to mark start of the stim
% if info.ET
%     Eyelink('message', num2str(trigger_enc.prob_off));
% end


Trial.RT(trial) = endrt-start;

timing = [start_fix
cueOnsetTime
cueOff
stimOnset
stimOff
probeOn
probeOff
respOn
endrt];

Trial.Timing(trial,:) = timing;


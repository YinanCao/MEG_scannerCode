
% fixation presentation before stimulus onset
for k = 1:4
Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
% Screen('FillOval', window, white, fixdotposX(k,:)); % fixation center dot
end
[~, vbl] = Screen('Flip', window);
start_fix = vbl;
trigger(trigger_enc.trial_start);
if info.ET
    Eyelink('command', 'record_status_message "TRIAL %d/%d"', trial, nTrials);
    Eyelink('message', 'TRIALID %d', trial);
    Eyelink('message', num2str(trigger_enc.trial_start));
end
% fixFrames = round(Trial.BRD(trial)/ifi);

pause(Trial.BRD(trial))

% fix2stimFrames = round(Trial.cue2StimD/ifi);
% stimFrames = round(Trial.SD/ifi);

nsample = size(thisTrial,1);

%stimOff = start_fix; % initiaalize
%ISIFrames = fix2stimFrames;

% generate tagging signal
FR = info.frameRate;
d2 = Trial.SD; % duration of tagging signal
d6 = Trial.ISI; % 
D2 = round(FR * d2) * 12; % 12 is the Propixx multiplier for gray scale
D6 = round(FR * d6) * 12;
tag_f = [63, 78, 85];

tag_sig = tag_get_tagging_signal(d2 + d6, D2 + D6, tag_f);
xColor3d = cell(0);
for i = 1:length(tag_sig)
    xColor3d{i} = reshape(tag_sig{i}, 4, 3, []);
end
D2 = D2 / 12;
D6 = D6 / 12;

% Screen('Flip', window);

%vbl = Screen('Flip', window);

for sample = 1:nsample
    
    % ISIFrames = round(Trial.ISI/ifi);
    thiscontrast = thisTrial(sample,1);
    thisangle = thisTrial(sample,2);
    thisloc = thisTrial(sample,3);
    orientation = Trial.Gabor_orientation(thisangle);
    Make_gabor_Ftag; % create baseM
    
    % Stimulus presentation
    for vblframe = 1:(D2 + D6)
    
        fColor = xColor3d{thisloc}(:,:,vblframe); % each row=quad,
        % column = RGB
        if vblframe < (D2 + 1) % tagging
            destinationRect = nan(4,4); 
            textureIndexTarg = nan(1,4);
                for q = 1:4
                    Mx = nan([size(baseM,1),size(baseM,2),3]);
                    for chan = 1:3
                       baseM = ones(size(baseM));
                       M = baseM - grey; % bring to zero
                       if mod(sample,2)
                          M = M.*fColor(q, chan);
                       end
                       M = M + grey;
                       Mx(:,:,chan) = M;
                    end
                    textureIndexTarg(q) = Screen('MakeTexture', window, Mx);
                    destinationRect(:,q) = q_dstRect(q,:)';
                end
            % 4 row by n columns matrix.
            for k = 1:4
            Screen('DrawTexture', window, textureIndexTarg(k), [], destinationRect(:,k), orientation, [], 1);
%             Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
%             Screen('FrameOval', window, white, destinationRect(:,k), Gabor.outlineWidth*info.cuewidth);
            end
        else
            for k = 1:4
            Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
%             Screen('FillOval', window, white, fixdotposX(k,:)); % fixation center dot
            end
        end
        vbl = Screen('Flip', window, vbl + 0.5 * ifi);
        Screen('Close', textureIndexTarg);
 
        if vblframe == 1
            trigger(trigger_enc.stim_on);  % trigger to mark start of the stim
            if info.ET
                Eyelink('message', num2str(trigger_enc.stim_on));
            end
            stimOnset = vbl;
        elseif vblframe == D2 + 1
            trigger(trigger_enc.stim_off);  % trigger to mark start of the stim
            if info.ET
                Eyelink('message', num2str(trigger_enc.stim_off));
            end
            stimOff = vbl;
        end
    end
    
%vbl = Screen('Flip', window, vbl + 0.5 * ifi); 
end % end of sample

% Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

probe2Resp = round(Trial.StRCD/ifi);
% response cue

for k = 1:4
Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]+45);
% Screen('FillOval', window, white, fixdotposX(k,:)); % fixation center dot
end
[~, respOn] = Screen('Flip', window, stimOff + (probe2Resp-0.5)*ifi);
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
stimOnset
stimOff
respOn
endrt];

Trial.Timing(trial,:) = timing;


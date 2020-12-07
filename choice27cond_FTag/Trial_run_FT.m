%%%%%%%%%%%%% quad transformed locations
if trial == 1
    patchHalfSize = Gabor.patchHalfSize; % canvas on which gaussians are drawn
    % define gabor positions (horizontal line atm):
    gaborrect = [-patchHalfSize -patchHalfSize patchHalfSize patchHalfSize];
    q_dstRect_all = cell(0);
    for whichG = 1:3 % top, left, right
        posX = Gabor.Xpos(whichG); % top, left, right
        posY = Gabor.Ypos(whichG);
        dstRect = CenterRectOnPoint(gaborrect, posX, posY);
        q_dstRect_gabor = zeros(4,4);
        for q = 1:4
            [x1,y1] = convertToQuadrant(dstRect(1:2), windowRect, q);
            [x4,y4] = convertToQuadrant(dstRect(3:4), windowRect, q);
            q_dstRect_gabor(q,:) = [x1,y1,x4,y4];
        end
        q_dstRect_all{whichG} = q_dstRect_gabor;
    end
    
    % generate tagging signal
    FR = info.frameRate;
    d2 = Trial.SD; % duration of tagging signal
    d6 = Trial.ISI; % 0
    D2 = round(FR * d2);
    D6 = round(FR * d6);
    tag_sig = tag_get_tagging_signal(d2 + d6, (D2 + D6)*12, tag_f);
    xColor3d = cell(0);
    for i = 1:length(tag_sig)
        xColor3d{i} = reshape(tag_sig{i}, 4, 3, []);
    end

end
%%%%%%%%%%%%%
%%%%%%%%%%%%%
orientations = [];
count = 1;
for q = 1:4
    for whichG = 1:3
        orientations(count) = Trial.orientation(trial,whichG);
        count = count + 1;
    end
end
%%%%%%%%%%%%%

% fixation presentation before stimulus onset
for k = 1:4
    Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
end
start_fix = Screen('Flip', window);
trigger(trigger_enc.trial_start);  
if info.ET
    Eyelink('command', 'record_status_message "TRIAL %d/%d"', trial, nTrials);
    Eyelink('message', 'TRIALID %d', trial);
    Eyelink('message', num2str(trigger_enc.trial_start));
end
fixFrames = round(Trial.BRD(trial)/ifi);


for k = 1:4
    Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
end
vbl = Screen('Flip', window, start_fix + (fixFrames-0.5)*ifi);

Make_gabor_Ftag_baseM; % create baseM_all{}

trl_tagf = Trial.tagging_freq(trial,:);

% Stimulus presentation
for vblframe = 1:D2
    destinationRect = [];
    textureIndexTarg = [];
    count = 1;
    for q = 1:4 % quadrant
        for whichG = 1 % stimuli
            baseM = baseM_all{whichG};
            fColor = xColor3d{trl_tagf(whichG)}(:,:,vblframe); % each row=quad,
            q_dstRect = q_dstRect_all{whichG};
            Mx = nan([size(baseM,1),size(baseM,2),3]);
            if tagging_checkMode
               baseM = ones(size(baseM));
            end
            for chan = 1:3
               M = baseM - control_bkg; % bring to zero
               M = M.*fColor(q, chan);
               M = M + control_bkg;
               Mx(:,:,chan) = M;
            end
            textureIndexTarg(count) = Screen('MakeTexture', window, Mx);
            destinationRect(:,count) = q_dstRect(q,:)';
            count = count + 1;
        end % end stim
    end % end quad
    Screen('DrawTextures', window, textureIndexTarg, [], destinationRect, orientations, [], 1);
    if ~tagging_checkMode
        Screen('FrameOval', window, white, destinationRect, 1);
    end
%     Screen('FrameOval', window, white, destinationRect, Gabor.outlineWidth*info.cuewidth);
    for k = 1:4
        Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
    end
    
    vbl = Screen('Flip', window, vbl + 0.5 * ifi);
    Screen('Close', textureIndexTarg);
    
    if vblframe == 1
        trigger(trigger_enc.stim_on);  % trigger to mark start of the stim
        if info.ET
            Eyelink('message', num2str(trigger_enc.stim_on));
        end
        stimOnset = vbl;
    end

end % end vbl frames


for k = 1:4
    Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
end
vbl = Screen('Flip', window, vbl + 0.5 * ifi); 
trigger(trigger_enc.stim_off);  % trigger to mark start of the stim
if info.ET
    Eyelink('message', num2str(trigger_enc.stim_off));
end
stimOff = vbl;


probe2Resp = round(Trial.StRCD/ifi);
% response cue
for k = 1:4
    Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]+45);
end
[~, respOn] = Screen('Flip', window, stimOff + (probe2Resp-0.5)*ifi);
trigger(trigger_enc.resp_cue_on);  % trigger to mark start of the response cue
if info.ET
    Eyelink('message', num2str(trigger_enc.resp_cue_on));
end
start = respOn;
flush_kbqueues(info.kbqdev);
[keyIsDown, secs, press_key, deltaSecs] = KbCheck();
endrt = GetSecs;
while ( press_key(left)==0  && press_key(right)==0 && GetSecs-start<Trial.RCD)
    [keyIsDown, secs, press_key, deltaSecs] = KbCheck();
    endrt = secs;
end
Trial.RT(trial) = endrt-start;

timing = [start_fix
stimOnset
stimOff
respOn
endrt];

Trial.Timing(trial,:) = timing;


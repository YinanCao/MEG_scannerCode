%%%%%%%%%%%%% quad transformed locations
if trial == 1
    patchHalfSize = Gabor.patchHalfSize; % canvas on which gaussians are drawn
    % define gabor positions (horizontal line atm):
    gaborrect = [-patchHalfSize -patchHalfSize patchHalfSize patchHalfSize];
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
[~, start_fix] = Screen('Flip', window);
trigger(trigger_enc.trial_start);  
if info.ET
    Eyelink('command', 'record_status_message "TRIAL %d/%d"', trial, nTrials);
    Eyelink('message', 'TRIALID %d', trial);
    Eyelink('message', num2str(trigger_enc.trial_start));
end
fixFrames = round(Trial.BRD(trial)/ifi);

cueFrames = round(Trial.cueD/ifi); % 100ms
% add first cue:
cue_position1 = Trial.cue_position1(trial,:);
make_cue(window, Gabor, cue_position1, q_dstRect_all, white)
for k = 1:4
    Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
end
[VBLTimestamp, cueOnsetTime] = Screen('Flip', window, start_fix+(fixFrames-0.5)*ifi);
trigger(trigger_enc.cue_on)
if info.ET
    Eyelink('message', num2str(trigger_enc.cue_on));
end

for k = 1:4
    Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
end
[~,cueOff] = Screen('Flip', window, cueOnsetTime +  (cueFrames - .5)*ifi); % cue gone
trigger(trigger_enc.cue_off)
if info.ET
    Eyelink('message', num2str(trigger_enc.cue_off));
end

cue2stimFrames = round(Trial.cue2StimD/ifi);
for k = 1:4
    Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
end
vbl = Screen('Flip', window, cueOnsetTime +  (cue2stimFrames - .5)*ifi); %

Make_gabor_Ftag_baseM; % create baseM
% stimonset to 2nd cue:
stim2newcue = round(Trial.stim2newcue(trial)/ifi);
cue_position2 = Trial.cue_position2(trial,:);

cue2_time = [stim2newcue+1; stim2newcue+1+cueFrames];
% present red dot:
stim2dot = round(Trial.stim2dot(trial)/ifi);
% stop red dot:
dotFrames = round(Trial.dotD/ifi);
dot_time = [stim2dot+1, stim2dot+1+dotFrames];

% Stimulus presentation
for vblframe = 1:D2
    destinationRect = [];
    textureIndexTarg = [];
    count = 1;
    for q = 1:4 % quadrant
        for whichG = 1:3 % stimuli
            fColor = xColor3d{whichG}(:,:,vblframe); % each row=quad,
            q_dstRect = q_dstRect_all{whichG};
            Mx = nan([size(baseM,1),size(baseM,2),3]);
            for chan = 1:3
               if tagging_checkMode
                   baseM = ones(size(baseM));
               end
               M = baseM - grey; % bring to zero
               M = M.*fColor(q, chan);
               M = M + grey;
               Mx(:,:,chan) = M;
            end
            textureIndexTarg(count) = Screen('MakeTexture', window, Mx);
            destinationRect(:,count) = q_dstRect(q,:)';
            count = count + 1;
        end % end stim
    end % end quad
    Screen('DrawTextures', window, textureIndexTarg, [], destinationRect, orientations, [], 1);
    if ~tagging_checkMode
        for k = 1:4
            Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
        end
        Screen('FrameOval', window, white, destinationRect, Gabor.outlineWidth*info.cuewidth);
%         for k = 1:size(destinationRect,2)
%             Screen('FrameOval', window, white, destinationRect(:,k), Gabor.outlineWidth*info.cuewidth);
%         end
    end
    
    % draw second cue
    if vblframe >= cue2_time(1) && vblframe <= cue2_time(2)
        make_cue(window, Gabor, cue_position2, q_dstRect_all, white)
    end
    
    % draw low-contrast transient dot target
    if vblframe >= dot_time(1) && vblframe <= dot_time(2)
        make_redDot;
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
    
    if vblframe == cue2_time(1)
        trigger(trigger_enc.SecondCue_on); 
        if info.ET
            Eyelink('message', num2str(trigger_enc.SecondCue_on));
        end
        secondCueOnset = vbl;
    elseif vblframe == cue2_time(2)
        trigger(trigger_enc.SecondCue_off);  
        if info.ET
            Eyelink('message', num2str(trigger_enc.SecondCue_off));
        end
        secondCueOff = vbl;
    end
    
    if vblframe == dot_time(1)
        dotOnset = vbl;
        trigger(trigger_enc.prob_on); 
        if info.ET
            Eyelink('message', num2str(trigger_enc.prob_on));
        end
    elseif vblframe == dot_time(2)
        dotOff = vbl;
        trigger(trigger_enc.prob_off);  
        if info.ET
            Eyelink('message', num2str(trigger_enc.prob_off));
        end
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
cueOnsetTime
cueOff
stimOnset
secondCueOnset
secondCueOff
dotOnset
dotOff
stimOff
respOn
endrt];

Trial.Timing(trial,:) = timing;


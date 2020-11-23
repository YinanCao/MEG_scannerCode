
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
D2 = round(FR * d2);
D6 = round(FR * d6);

% if tagging_checkMode
%     tag_f = repmat([63, 150],[1,8]);
% end
tag_sig = tag_get_tagging_signal(d2 + d6, (D2 + D6)*12, tag_f);
xColor3d = cell(0);
for i = 1:length(tag_sig)
    xColor3d{i} = reshape(tag_sig{i}, 4, 3, []);
end

%%%%%%%%%%%%% quad transformed locations
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
%%%%%%%%%%%%%

    
for sample = 1:nsample
    
    % ISIFrames = round(Trial.ISI/ifi);
    thiscontrast = thisTrial(sample,1);
    thisangle = thisTrial(sample,2);
%     thisloc = thisTrial(sample,3);
%     thisloc = [1,2,3]; % present at all 3 locations
    %orientation = Trial.Gabor_orientation(thisangle);
    orientation = repmat([-45, 0, 45],1,4);
    Make_gabor_Ftag; % create baseM, will use thisloc
    % but in tagging_checkMode=1, thisloc = 2;
    
    % Stimulus presentation
    for vblframe = 1:(D2 + D6)
        
        % column = RGB
        if vblframe < (D2 + 1) % tagging
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
                           baseM = ones(size(baseM))*Gabor_onoff(whichG);
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
            % 4 row by n columns matrix.
%             Screen('DrawTexture', window, textureIndexTarg(k), [], destinationRect(:,k), orientation, [], 1);
              Screen('DrawTextures', window, textureIndexTarg, [], destinationRect, orientation, [], 1);
            if ~tagging_checkMode
                for k = 1:4
                    Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
                    Screen('FrameOval', window, white, destinationRect(:,k), Gabor.outlineWidth*info.cuewidth);
                end
            end
        else
            for k = 1:4
            Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
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


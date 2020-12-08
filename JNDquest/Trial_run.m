if trial == 1
    patchHalfSize = Gabor.patchHalfSize; % canvas on which gaussians are drawn
    % define gabor positions (horizontal line atm):
    gaborrect = [-patchHalfSize -patchHalfSize patchHalfSize patchHalfSize];
    q_dstRect_all = cell(0);
    for whichG = 1:2 
        posX = Gabor.Xpos(whichG);
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
    d6 = 0;
    D2 = round(FR * d2);
    D6 = round(FR * d6);
    tag_sig = tag_get_tagging_signal(d2 + d6, (D2 + D6)*12, tag_f);
    xColor3d = cell(0);
    for i = 1:length(tag_sig)
        xColor3d{i} = reshape(tag_sig{i}, 4, 3, []);
    end
end
%%
orientations = [];
count = 1;
for q = 1:4
    for whichG = 1:2
        orientations(count) = Trial.orientation(trial,whichG);
        count = count + 1;
    end
end

%% fixation presentation before stimulus onset
for k = 1:4
    Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
end
start_fix = Screen('Flip', window);
trigger(trigger_enc.trial_start);
fixFrames = round(Trial.BRD(trial)/ifi);


for k = 1:4
    Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
end
vbl = Screen('Flip', window, start_fix + (fixFrames-0.5)*ifi);

%%
% Get the threshold from the QUEST
w_q = num2str(Trial.Which_quest(trial));
eval(['tr=QuestQuantile(Quest.q' w_q ...
    '(q_counter' w_q '));']);
eval(['Quest.Quantile' w_q '(q_counter' w_q ')=QuestQuantile(Quest.q' w_q '(q_counter' w_q '));']);
eval(['Quest.Mean' w_q '(q_counter' w_q ')=QuestMean(Quest.q' w_q '(q_counter' w_q '));']);
eval(['Quest.Mode' w_q '(q_counter' w_q ')=QuestMode(Quest.q' w_q '(q_counter' w_q '));']);
eval(['q_counter' w_q '=q_counter' w_q '+1']);

if 10^(tr) < Trial.Gabor_contrast(trial)
    tr= log10(Trial.Gabor_contrast(trial));
    eval(['Quest.Quantile' w_q '(q_counter' w_q '-1)=tr;']);
end


if Trial.Gabor_position(trial) =='R' % 1 for left and 2 for right
    Trial.contrast_right(trial)= (10.^(tr));
    Trial.contrast_left(trial)= Trial.Gabor_contrast(trial);
    Trial.contrast(trial,2)=(10.^(tr));
    Trial.contrast(trial,1)=Trial.Gabor_contrast(trial);
else %'L'
    Trial.contrast_left(trial)= (10.^(tr));
    Trial.contrast_right(trial)= Trial.Gabor_contrast(trial);
    Trial.contrast(trial,1)=(10.^(tr));
    Trial.contrast(trial,2)=Trial.Gabor_contrast(trial);
end

% store some date
Trial.log10_tr(trial)=tr;
Trial.contrast_tr(trial)=10.^tr;
Trial.contrast_B(trial)=Trial.Gabor_contrast(trial);
Trial.JND_contrast(trial)= Trial.contrast_tr(trial)-Trial.contrast_B(trial);
Trial.JND_log10contrast(trial)= Trial.log10_tr(trial)-log10(Trial.contrast_B(trial));
eval(['Quest.JND_contrast' w_q '(q_counter' w_q '-1)=Trial.JND_contrast(trial);']);
eval(['Quest.JND_log10contrast' w_q '(q_counter' w_q '-1)=Trial.JND_log10contrast(trial);']);

%%
Make_gabor_Ftag_baseM; % create baseM_all{}
% choose 2 arbi f for the 2 stim
tag_f_thistrl = randi(length(tag_f),1,2);
% Stimulus presentation
for vblframe = 1:D2
    destinationRect = [];
    textureIndexTarg = [];
    count = 1;
    for q = 1:4 % quadrant
        for whichG = 1:2 % stimuli
            baseM = baseM_all{whichG};
            fColor = xColor3d{tag_f_thistrl(whichG)}(:,:,vblframe); % each row=quad,
            q_dstRect = q_dstRect_all{whichG};
            Mx = nan([size(baseM,1),size(baseM,2),3]);
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
    Screen('FrameOval', window, Gabor.outlineColor, destinationRect, 1);

    for k = 1:4
        Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
    end
    
    vbl = Screen('Flip', window, vbl + 0.5 * ifi);
    Screen('Close', textureIndexTarg);
    
    if vblframe == 1
        % trigger(trigger_enc.stim_on);  % trigger to mark start of the stim
        stimOnset = vbl;
    end

end % end vbl frames
%%

for k = 1:4
    Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
end
vbl = Screen('Flip', window, vbl + 0.5 * ifi); 
trigger(trigger_enc.stim_off);
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

% timing = [start_fix
% stimOnset
% stimOff
% respOn
% endrt];
% 
% Trial.Timing(trial,:) = timing;

%%



% Trial.real_BRD(trial)=Trial.stimulus_on(trial)-start_delay;
% 
% trigger(trigger_enc.stim_on);  % trigger to mark start of the stim
% WaitSecs(Trial.SD(trial)); % Duration of the stimulus presentation
% 
% % Gap from Stimulus off to response cue on
% Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]);
% Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
% [Trial.stimulus_off(trial)]=Screen('Flip', window);
% trigger(trigger_enc.stim_off);  % trigger to mark end of the stim
% 
% WaitSecs(Trial.StRCD);
% 
% % response cue
% Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[45,135]);
% Screen('FillOval', window, blue, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
% [Trial.response_cue_on(trial)]=Screen('Flip', window);
% trigger(trigger_enc.resp_cue_on);  % trigger to mark start of the response cue
% 
% Trial.real_SD(trial)=Trial.stimulus_off(trial)-Trial.stimulus_on(trial);
% Trial.real_StRCD(trial)=Trial.response_cue_on(trial)-Trial.stimulus_off(trial);
% start= Trial.response_cue_on(trial);
% flush_kbqueues(info.kbqdev);
% %[keyIsDown, press_key]=check_kbqueues(info.kbqdev);
% [keyIsDown, secs, press_key, deltaSecs] = KbCheck();
% endrt=GetSecs;
% while (press_key(left)==0  && press_key(right)==0 && GetSecs-start<Trial.RCD)
%     [keyIsDown, secs, press_key, deltaSecs] = KbCheck();
%     
%     %[keyIsDown, press_key]=check_kbqueues(info.kbqdev);
%     endrt=GetSecs;
% end
% Trial.RT(trial)=endrt-start;



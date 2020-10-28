% check the answer
if press_key(left)
    Trial.answer(trial)='L';
    trigger(trigger_enc.resp_left);  % trigger to mark the response
    if info.ET
        Eyelink('message', num2str(trigger_enc.resp_left));
    end
% elseif press_key(middle)
%     Trial.answer(trial)='M';
%     trigger(trigger_enc.resp_middle);  % trigger to mark the response
%     if info.ET
%         Eyelink('message', num2str(trigger_enc.resp_middle));
%     end
elseif press_key(right)
    Trial.answer(trial)='R';
    trigger(trigger_enc.resp_right);  % trigger to mark the response
    if info.ET
        Eyelink('message', num2str(trigger_enc.resp_right));
    end
else
    Trial.answer(trial)='I';
    trigger(trigger_enc.resp_missed);  % trigger to mark the response
    if info.ET
        Eyelink('message', num2str(trigger_enc.resp_missed));
    end
end

% evaluate the answer
if  Trial.answer(trial) =='I'
    Trial.eval_answer(trial)=2;
    DrawFormattedText(window, ['Missed Response'], 'center', 'center',white);
    [start_FB]=Screen('Flip', window);
    trigger(trigger_enc.resp_cue_off);  % trigger to mark end of the response cue
    trigger(trigger_enc.fb_cue_on);  % trigger to mark start of the feedback cue
    trigger(trigger_enc.resp_missed);  % trigger to mark missed response
    if info.ET
        Eyelink('message', num2str(trigger_enc.resp_cue_off));
        Eyelink('message', num2str(trigger_enc.fb_cue_on));
        Eyelink('message', num2str(trigger_enc.resp_missed));
    end
    WaitSecs(Trial.FBD); % Feedback presentation/ Missed or Ignored
else
    if Trial.answer(trial)==Trial.true_answer(trial)
        Trial.eval_answer(trial)=1;
        Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[45,135]);
        Screen('FillOval', window, green, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
        [start_FB]=Screen('Flip', window);
        trigger(trigger_enc.resp_cue_off);  % trigger to mark end of the response cue
        trigger(trigger_enc.fb_cue_on);  % trigger to mark start of the feedback cue
        trigger(trigger_enc.resp_correct);  % trigger to mark correct response
        if info.ET
            Eyelink('message', num2str(trigger_enc.resp_cue_off));
            Eyelink('message', num2str(trigger_enc.fb_cue_on));
            Eyelink('message', num2str(trigger_enc.resp_correct));
        end
        WaitSecs(Trial.FBD); % Feedback presentation/ Correct
    else
        Trial.eval_answer(trial)=0;
        Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[45,135]);
        Screen('FillOval', window, red, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
        [start_FB]=Screen('Flip', window);
        trigger(trigger_enc.resp_cue_off);  % trigger to mark end of the response cue
        trigger(trigger_enc.fb_cue_on);  % trigger to mark start of the feedback cue
        trigger(trigger_enc.resp_wrong);  % trigger to mark wrong response
        if info.ET
            Eyelink('message', num2str(trigger_enc.resp_cue_off));
            Eyelink('message', num2str(trigger_enc.fb_cue_on));
            Eyelink('message', num2str(trigger_enc.resp_wrong));
        end
        WaitSecs(Trial.FBD); % Feedback presentation/ Wrong
    end
    
    
end

Trial.real_FBD(trial)=GetSecs-start_FB;

% after feekback, add a time wait until the next trial occurs
Rotated_fixation(window,fix_rect,center_x,center_y,dark_grey,[0,90]);
Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
Screen('Flip', window);
WaitSecs(Trial.TimeWaitafterFB);
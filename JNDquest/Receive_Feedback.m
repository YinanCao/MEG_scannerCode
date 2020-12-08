% check the answer
Screen('TextSize', window, 22/2); % define text font
Offset = 20;
% try to update code
if press_key(left)
    Trial.answer(trial)='L';
% elseif press_key(middle)
%     Trial.answer(trial)='M';

elseif press_key(right)
    Trial.answer(trial)='R';

else
    Trial.answer(trial)='I';

end

% evaluate the answer
if  Trial.answer(trial) =='I'
    Trial.eval_answer(trial)=2;
    % DrawFormattedText(window, 'Missed Response', center_x,center_y, white);
    for k = 1:4
        DrawFormattedText(window, 'Missed Response', center_x_q(k)-40, center_y_q(k)-Offset, white);
    end
    [start_FB]=Screen('Flip', window);
%     trigger(trigger_enc.resp_cue_off);  % trigger to mark end of the response cue
%     trigger(trigger_enc.fb_cue_on);  % trigger to mark start of the feedback cue

    WaitSecs(Trial.FBD); % Feedback presentation/ Missed or Ignored
else
    if Trial.answer(trial)==Trial.Gabor_position(trial)
        Trial.eval_answer(trial)=1;

        for k = 1:4
        Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]+45);
%         Screen('FillOval', window, green, fixdotposX(k,:)); % fixation center dot
        DrawFormattedText(window, 'correct', center_x_q(k)-17, center_y_q(k)-Offset, white);
        end
        
        [start_FB]=Screen('Flip', window);

        WaitSecs(Trial.FBD); % Feedback presentation/ Correct
    else
        Trial.eval_answer(trial)=0;
%         Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[45,135]);
%         Screen('FillOval', window, red, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
%         
%         
        for k = 1:4
        Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]+45);
%         Screen('FillOval', window, red, fixdotposX(k,:)); % fixation center dot
        DrawFormattedText(window, 'wrong', center_x_q(k)-15, center_y_q(k)-Offset, white);
        end
        
        [start_FB]=Screen('Flip', window);

        WaitSecs(Trial.FBD); % Feedback presentation/ Wrong
    end

end

Trial.real_FBD(trial)=GetSecs-start_FB;

% after feekback, add a time wait until the next trial occurs
% Rotated_fixation(window,fix_rect,center_x,center_y,dark_grey,[0,90]);
% Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));

for k = 1:4
Rotated_fixation(window, fix_rect, center_x_q(k), center_y_q(k), dark_grey, [0,90]);
% Screen('FillOval', window, white, fixdotposX(k,:)); % fixation center dot
end
Screen('Flip', window);
WaitSecs(Trial.TimeWaitafterFB);
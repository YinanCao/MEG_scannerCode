%    Initial message
if trial==nTrials./2+1
message= ['... You can rest :)...\n'...
'To continue, please press a key'];
DrawFormattedText(window, [message], 'center', 'center',white);
Screen('Flip', window);
KbWait();
WaitSecs(0.2);
flush_kbqueues(info.kbqdev);
end

patchHalfSize  = Gabor.patchHalfSize; % canvas on which gaussians are drawn
gaborrect = [-patchHalfSize -patchHalfSize patchHalfSize patchHalfSize];

if Trial.Triangle_dir(trial)== 'U' 
    trinagle_msg= ['In this mini-block the stimuli are aligned in a rotated upward triangle as you can see below \n' ...
    'To report your answer, please press \n \n' ...
    '4 ---> Left Patch \n'...
    '5 ---> Top Patch \n'...
    '6 ---> Right Patch \n \n' ...
    'Press SPACE to start!'];
P=['LUR'];
for whichG = 1:Gabor.numGabors
    posX_cw = task_msg_xp_cw_u(whichG)-240;
    posY_cw = task_msg_yp_cw_u(whichG)+100;
    posX_ccw = task_msg_xp_ccw_u(whichG)+240;
    posY_ccw = task_msg_yp_ccw_u(whichG)+100;
    dstRect_cw = CenterRectOnPoint(gaborrect, posX_cw, posY_cw);
    dstRect_ccw = CenterRectOnPoint(gaborrect, posX_ccw, posY_ccw);
    Screen('FrameOval', window, holder_c,dstRect_cw,2);
    Screen('FrameOval', window, holder_c,dstRect_ccw,2);
    DrawFormattedText(window, P(whichG), posX_cw-7, posY_cw+7 ,white);
    DrawFormattedText(window, P(whichG), posX_ccw-7, posY_ccw+7 ,white);
end
else
     trinagle_msg= ['In this mini-block the stimuli are aligned in a rotated downward triangle as you can see below \n' ...
    'To report your answer, please press \n \n' ...
    '4 ---> Left Patch \n'...
    '5 ---> Down Patch \n'...
    '6 ---> Right Patch \n \n' ...
    'Press SPACE to start!'];
P=['LDR'];
for whichG = 1:Gabor.numGabors
    posX_cw = task_msg_xp_cw_d(whichG)-240;
    posY_cw = task_msg_yp_cw_d(whichG)+100;
    posX_ccw = task_msg_xp_ccw_d(whichG)+240;
    posY_ccw = task_msg_yp_ccw_d(whichG)+100;
    dstRect_cw = CenterRectOnPoint(gaborrect, posX_cw, posY_cw);
    dstRect_ccw = CenterRectOnPoint(gaborrect, posX_ccw, posY_ccw);
    Screen('FrameOval', window, holder_c,dstRect_cw,2);
    Screen('FrameOval', window, holder_c,dstRect_ccw,2);
    DrawFormattedText(window, P(whichG), posX_cw-7, posY_cw+7 ,white);
    DrawFormattedText(window, P(whichG), posX_ccw-7, posY_ccw+7 ,white);

end
end



%    Task message
DrawFormattedText(window, [trinagle_msg], 'center', 'center',white);
Screen('Flip', window);
[keyIsDown, secs, press_key, deltaSecs]= KbCheck();
while ( press_key(brk)==0)
    [keyIsDown, secs, press_key, deltaSecs]=KbCheck();
    %[keyIsDown, press_key]=check_kbqueues(info.kbqdev);
end
flush_kbqueues(info.kbqdev);
Rotated_fixation(window, fix_rect, center_x, center_y,dark_grey,[0,90]);
Screen('FillOval', window, white, CenterRectOnPointd([0 0 lineWidthPix lineWidthPix], center_x, center_y));
Screen('Flip', window);
WaitSecs(0.5);

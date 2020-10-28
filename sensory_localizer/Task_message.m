%    Initial message
% if info.Session_type == 'W'
%     DrawFormattedText(window, ['...please select the brightest patch...'], 'center', center_y-125,white);
% else
%     DrawFormattedText(window, ['...please select the darkest patch...'], 'center', center_y-125,white);
% end
% DrawFormattedText(window, ['Please maintain your gaze on the fixation throughout the trial'], 'center', center_y-75,white);
% DrawFormattedText(window, ['Plus with a white dot: Be ready'], 'center', center_y-25,white);
% DrawFormattedText(window, ['Cross with a blue dot: Response Cue'], 'center', center_y+25,blue);
% DrawFormattedText(window, ['Plus with a Green dot: Correct Response'], 'center', center_y+75,[0 1 0]);
% DrawFormattedText(window, ['Plus with a Red dot: Wrong Response'], 'center', center_y+125,[1 0 0]);


DrawFormattedText(window, 'Experiment will begin, please do not move','center', center_y-100, white);

DrawFormattedText(window, 'key 1: CCW',  center_x-190, center_y-50, green);
DrawFormattedText(window, 'key 2: CW', center_x+90, center_y-50, green);

% DrawFormattedText(window, 'CCW', center_x-270, 'center', black);
% DrawFormattedText(window, 'CW', center_x+40, 'center', white);

% DrawFormattedText(window, 'Press [any key] to start!', 'center', center_y+175,white);
Screen('Flip', window);
%    Initial message
% if info.Session_type == 'W'
message= ['... please select the brightest patch...\n'...
    'To report your answer, please press \n \n' ...
    'L ---> Left Patch \n'...
    'R ---> Right Patch \n \n'];
% else
%     message= ['... please select the darkest patch...\n'...
%     'To report your answer, please press \n \n' ...
%     '4 ---> Left Patch \n'...
%     '6 ---> Right Patch \n \n'];
% end

% %    Task message
DrawFormattedText(window, [message], 'center', center_y-225,white);
DrawFormattedText(window, ['Please maintain your gaze on the fixation throughout the trial'], 'center', center_y-75,white);
% DrawFormattedText(window, ['Plus with a white dot: Be ready'], 'center', center_y-25,white);
% DrawFormattedText(window, ['Cross with a blue dot: Response Cue'], 'center', center_y+25,[0 0 1]);
% DrawFormattedText(window, ['Plus with a Green dot: Correct Response'], 'center', center_y+75,[0 1 0]);
% DrawFormattedText(window, ['Plus with a Red dot: Wrong Response'], 'center', center_y+125,[1 0 0]);

DrawFormattedText(window, ['Only respond after the *rotation* of the fixation +'], 'center', center_y+25,[0 0 1]);

DrawFormattedText(window, ['Press any key to start!'], 'center', center_y+175,white);
%

Screen('Flip', window);


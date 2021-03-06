
% make Kb Queue: Need to specify the device to query button box
% Find the keyboard + MEG buttons.
if strcmp(info.kb_setup,'MEG')
    [idx, names, all] = GetKeyboardIndices();
%     info.kbqdev = [idx(strcmpi(names, 'ATEN USB KVMP w. OSD')), idx(strcmpi(names, 'Current Designs, Inc. 932')),...
%         idx(strcmpi(names, 'Apple Internal Keyboard / Trackpad')), idx(strcmpi(names, ''))];
    info.kbqdev = idx;
%     keyList = zeros(1, 256);
%     keyList(KbName({'ESCAPE','SPACE', 'LeftArrow', 'RightArrow','UpArrow',...
%         '1', '2', '3', '4', 'b', 'g', 'y', 'r', '1!', '2@', '3#', '4$'})) = 1; % only listen to those keys!
    % first four are the buttons in mode 001, escape and space are for
    % the experimenter, rest is for testing
    keyList = ones(1, 256);
    for kbqdev = info.kbqdev
        PsychHID('KbQueueCreate', kbqdev, keyList);
        PsychHID('KbQueueStart', kbqdev);
        WaitSecs(.1);
        PsychHID('KbQueueFlush', kbqdev);
    end
else
    [idx, names, all] = GetKeyboardIndices();
    info.kbqdev = [idx(strcmpi(names, 'Microsoft Wired Keyboard 600')),...
        idx(strcmpi(names, 'Magic Keyboard')),...
        idx(strcmpi(names, 'DELL Dell USB Entry Keyboard')), idx(strcmpi(names, ''))];
    
    keyList = zeros(1, 256);
    keyList(KbName({'ESCAPE','SPACE', 'j', 'f'})) = 1; % only listen to those keys!
    % first four are the buttons in mode 001, escape and space are for
    % the experimenter, rest is for testing
    for kbqdev = info.kbqdev
        PsychHID('KbQueueCreate', kbqdev, keyList);
        PsychHID('KbQueueStart', kbqdev);
        WaitSecs(.1);
        PsychHID('KbQueueFlush', kbqdev);
    end
end

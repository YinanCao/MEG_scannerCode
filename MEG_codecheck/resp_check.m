clear; clc; close all;

info.kb_setup = 'noMEG';

setup_key;
if strcmp(info.kb_setup,'MEG')
    Lft = '1';
    Rgt = '4';
    ext = 'ESCAPE';
    flush_kbqueues(info.kbqdev);
else
    Lft = 'LeftArrow';
    Rgt = 'RightArrow';
    ext = 'ESCAPE'; 
end

for trial = 1:20

    
    keys = 'NaN';
    tel = 0;
    double_press = false;
    resp = 0;
    deadline = 3;
    kbqdev = info.kbqdev;
    start_stim = GetSecs();
    while (resp==0 && tel < deadline)
        [keyIsDown, firstPress] = check_kbqueues(kbqdev);
        tel = GetSecs-start_stim;
        if keyIsDown  % logging response type
            secs = GetSecs;
            keys = KbName(firstPress);  % retrieving string variable containing currently pressed key(s)
        end
    end
    disp(['trial: ',num2str(trial), '>>>>>: ',keys])
    

end
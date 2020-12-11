function [el, options] = ELconfig_yc(window, subj, options, screenNum)
% Yinan Cao, irrationality lab UKE, 03/11/2020

res = Screen('Resolution', screenNum);

if options.ET
    dummymode = 0;
else
    dummymode = 1;
end

[IsConnected, IsDummy] = EyelinkInit(dummymode);
if IsDummy, warning('SetupEL:dummy','EyeLink in dummy mode!'); end
if ~IsConnected
    warning('SetupEL:noInit','Failed to initialize EyeLink!');
    return
end
[~, vs] = Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs);

el = EyelinkInitDefaults(window);
el.backgroundcolour = ...

% % SEND SCREEN SIZE TO EL SO THAT VISUAL ANGLE MEASUREMENTS ARE CORRECT
rv = []; % collect return values from eyetracker commands

rv(end+1) = Eyelink('command', ...
    'screen_pixel_coords = %ld, %ld, %ld, %ld', 0, 0, res.width, res.height); %rv 1
phys_coord = sprintf('screen_phys_coords = %ld, %ld, %ld, %ld'...
    , -floor(10*options.width/2)... %half width
    ,  floor(10*options.height/2)... %half height
    ,  floor(10*options.width/2)... %half width
    , -floor(10*options.height/2));   %half height %rv 2
rv(end+1) = Eyelink('command', phys_coord);
rv(end+1) = Eyelink('command', 'screen_distance = %ld %ld', ...
    10*options.dist, 10*options.dist); %rv 3

% make sure we get the right data from eyelink:
Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,DIAMETER,GAZERES,HREF,PUPIL,INPUT,STATUS,BUTTON');
Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,DIAMETER,VELOCITY,STATUS');
Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK, MESSAGE, INPUT,BUTTON');
Eyelink('command', 'file_sample_data = LEFT,RIGHT,GAZE,DIAMETER,GAZERES,HREF,PUPIL,STATUS,BUTTON,INPUT,HTARGET');
Eyelink('command', 'file_event_data = GAZE,GAZERES,HREF,DIAMETER,VELOCITY');
Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');


Eyelink('command', 'enable_automatic_calibration = NO');
Eyelink('command', 'calibration_type = HV5');
Eyelink('command', 'generate_default_targets = NO');


targets = sprintf('calibration_targets = %i,%i %i,%i %i,%i %i,%i %i,%i',...
    res.width*1/2, res.height/2,...
    res.width*1/2-200, res.height/2,...
    res.width*1/2+200, res.height/2,...
    res.width*1/2, res.height/2-200,...
    res.width*1/2, res.height/2+200);
vtargets = sprintf('validation_targets = %i,%i %i,%i %i,%i %i,%i %i,%i',...
    res.width*1/2, res.height/2,...
    res.width*1/2-200, res.height/2,...
    res.width*1/2+200, res.height/2,...
    res.width*1/2, res.height/2-200,...
    res.width*1/2, res.height/2+200);
Eyelink('command', targets);
Eyelink('command', vtargets);

EyelinkUpdateDefaults(el);

%  open edf file for recording data from Eyelink - CANNOT BE MORE THAN 8 CHARACTERS
if length(subj)<=8
    options.edfFile = sprintf('%s.edf', subj);
else
    options.edfFile = sprintf('%s.edf', subj(end-7:end));
end
Eyelink('Openfile', options.edfFile);

% send information that is written in the preamble
preamble_txt = sprintf('%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %d', ...
    'Experiment', 'CNFDNC', ...
    'subjectnr', subj, ...
    'edfname', options.edfFile, ...
    'screen_hz', options.frameRate, ...
    'screen_resolution', options.window_rect, ...
    'date', datestr(now),...
    'screen_distance', options.dist);
Eyelink('command', 'add_file_preamble_text ''%s''', preamble_txt);

end

    function [el, info] = ELconfig(window, edf_name, info, screenNum)
%screenNum = max(Screen('Screens')); % will use the main screen when single-monitor setup
res = Screen('Resolution', screenNum);
% setup the Eyelink initialization at the beginning of each block
% code from Hannah, UKE
if info.ET
    dummymode = 0; % set to 1 to run in dummymode (using mouse as pseudo-eyetracker)
else
    dummymode = 1; % set to 1 to run in dummymode (using mouse as pseudo-eyetracker)
end
[IsConnected, IsDummy] = EyelinkInit(dummymode);
if IsDummy, warning('SetupEL:dummy','EyeLink in dummy mode!'); end
if ~IsConnected
    warning('SetupEL:noInit','Failed to initialize EyeLink!');
    return
end

[v, vs ]    = Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs );

el = EyelinkInitDefaults(window);

% % SEND SCREEN SIZE TO EL SO THAT VISUAL ANGLE MEASUREMENTS ARE CORRECT
rv = []; % collect return values from eyetracker commands

rv(end+1) = Eyelink('command', ...
    'screen_pixel_coords = %ld, %ld, %ld, %ld', 0, 0, res.width, res.height); %rv 1

% BENQ Screen is 535mm wide and 300mm high
phys_coord = sprintf('screen_phys_coords = %ld, %ld, %ld, %ld'...
    , -floor(10*info.width/2)... %half width
    ,  floor(10*info.height/2)... %half height
    ,  floor(10*info.width/2)... %half width
    , -floor(10*info.height/2));   %half height %rv 2
rv(end+1) = Eyelink('command', phys_coord);

rv(end+1) = Eyelink('command', 'screen_distance = %ld %ld', ...
    10*info.dist, 10*info.dist); %rv 3
%
% % Write the display configuration as message into the file
% Eyelink('message', ...
%     'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, res.width, res.height);
% % Eyelink('message', 'SCREEN_PHYS_COORDS %ld %ld %ld %ld' ....
%     , -floor(10*info.width/2) ... %half width
%     ,  floor(10*info.height/2) ... %half height
%     ,  floor(10*info.width/2) ... %half width
%     , -floor(10*info.height/2));   %half height

% make sure we get the right data from eyelink - all of it!
Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,DIAMETER,GAZERES,HREF,PUPIL,INPUT,STATUS,BUTTON');
Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,DIAMETER,VELOCITY,STATUS');
Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK, MESSAGE, INPUT,BUTTON');
Eyelink('command', 'file_sample_data = LEFT,RIGHT,GAZE,DIAMETER,GAZERES,HREF,PUPIL,STATUS,BUTTON,INPUT,HTARGET');
Eyelink('command', 'file_event_data = GAZE,GAZERES,HREF,DIAMETER,VELOCITY');
Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
%Eyelink('command', 'calibration_type = HV9');

Eyelink('command', 'enable_automatic_calibration = NO');
Eyelink('command', 'calibration_type = HV5');
Eyelink('command', 'generate_default_targets = NO');


targets = sprintf('calibration_targetwindows = %i,%i %i,%i %i,%i %i,%i %i,%i',...
    res.width/2, res.height/2,...
    res.width/2-200, res.height/2,...
    res.width/2+200, res.height/2,...
    res.width/2, res.height/2-200,...
    res.width/2, res.height/2+200);
vtargets = sprintf('validation_targets = %i,%i %i,%i %i,%i %i,%i %i,%i',...
    res.width/2, res.height/2,...
    res.width/2-200, res.height/2,...
    res.width/2+200, res.height/2,...
    res.width/2, res.height/2-200,...
    res.width/2, res.height/2+200);
Eyelink('command', targets);
Eyelink('command', vtargets);

EyelinkUpdateDefaults(el);

%  open edf file for recording data from Eyelink - CANNOT BE MORE THAN 8 CHARACTERS
if length(edf_name)<=8
    info.edfFile = sprintf('%s.edf', edf_name);
else
    info.edfFile = sprintf('%s.edf', edf_name(end-7:end));
end
Eyelink('Openfile', info.edfFile);

% send information that is written in the preamble
preamble_txt = sprintf('%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %d', ...
    'Experiment', 'CNFDNC', ...
    'subjectnr', info.SubNo, ...
    'edfname', info.edfFile, ...
    'screen_hz', info.frameRate, ...
    'screen_resolution', info.window_rect, ...
    'date', datestr(now),...
    'screen_distance', info.dist);
Eyelink('command', 'add_file_preamble_text ''%s''', preamble_txt);

end

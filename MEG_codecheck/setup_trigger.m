function trigger = setup_trigger()

% trigger.zero = 0;
% trigger.width = 0.005; 

trigger.block_start = 1;   % start of block
trigger.stim_start = 21;   % onset of stream

trigger.resp_left = 41;    % 'left' response
trigger.resp_right = 42;   % 'right' response
trigger.resp_bad = 43;     % bad response (either double press, or task-irrelevant button)

trigger.fb = 51;   % feedback for correct
trigger.fb_bad = 52;     % feedback for incorrect

trigger.trial_end = 61;    % offset of feedback/onset of break period

trigger.block_end = 99;    % end of block



end

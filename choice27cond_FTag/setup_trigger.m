function trig = setup_trigger()

trig.EL_start = 1;

trig.block_start = 100;     % start of block
trig.block_end   = 150;     % end of block

trig.cue_N = 5;

trig.trial_start = 11;    % start of trial
trig.trial_end   = 19;    % end of trial

trig.stim_on  = 111;      % start of stim
trig.stim_off = 119;      % end of stim

trig.resp_cue_on  = 112;  % start of response cue
trig.resp_cue_off = 118;  % end of response cue

trig.resp_correct = 51;   % 'correct' response
trig.resp_wrong   = 61;   % 'wrong' response
trig.resp_missed  = 71;   % 'missed' response

trig.fb_cue_on  = 114;    % start of feedback cue
trig.fb_cue_off = 116;    % end of feedback cue

trig.resp_left  = 22;     % left bar was selected
trig.resp_right = 33;     % right bar was selected
trig.resp_middle = 44;     % middle bar was selected
trig.resp_invalid = 90;      % missed response

end

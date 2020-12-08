function trig = setup_trigger()

trig.block_start = 1;     % start of block
trig.block_end   = 9;     % end of block

trig.trial_start = 11;    % start of trial
trig.trial_end   = 19;    % end of trial

trig.stim_on  = 111;      % start of stim
trig.stim_off = 119;      % end of stim

trig.resp_cue_on  = 112;  % start of response cue
trig.resp_cue_off = 118;  % end of response cue

trig.resp_correct = 51;   % 'correct' response
trig.resp_wrong   = 50;   % 'wrong' response
trig.resp_missed  = 52;   % 'missed' response

trig.fb_cue_on  = 114;    % start of feedback cue
trig.fb_cue_off = 116;    % end of feedback cue

trig.resp_left  = 22;     % left bar was selected
trig.resp_right = 33;     % right bar was selected
trig.resp_middle= 44;     % middle bar was selected
trig.resp_missed= 55;      % missed response

end

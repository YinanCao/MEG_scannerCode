
function make_cue(window, Gabor, cue_position, q_dstRect_all)
% gabor parameters:
% patchHalfSize = Gabor.patchHalfSize; % canvas on which gaussians are drawn

% define gabor positions (horizontal line atm):
% gaborrect = [-patchHalfSize -patchHalfSize patchHalfSize patchHalfSize];

cue_pos = find(cue_position>0);
    
if ~isempty(cue_pos)
    if size(cue_pos,1)>1
        cue_pos = cue_pos';
    end
    for q = 1:4
        for whichG = cue_pos % 1,2,3
            tmp_loc = q_dstRect_all{whichG};
            Screen('FrameOval', window, Gabor.holder_c, tmp_loc(q,:), Gabor.outlineWidth*3);
        end
    end
end

return;





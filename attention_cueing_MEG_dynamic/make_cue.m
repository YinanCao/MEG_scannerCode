
% gabor parameters:
patchHalfSize = Gabor.patchHalfSize; % canvas on which gaussians are drawn

% define gabor positions (horizontal line atm):
gaborrect = [-patchHalfSize -patchHalfSize patchHalfSize patchHalfSize];

cue_pos = find(cue_position>0);
    
if ~isempty(cue_pos)
    if size(cue_pos,1)>1
        cue_pos = cue_pos';
    end

    for whichG = cue_pos % 1,2,3

        posX = Gabor.Xpos(whichG);
        posY = Gabor.Ypos(whichG);
        dstRect = CenterRectOnPoint(gaborrect, posX, posY);

        Screen('FrameOval', window, Gabor.holder_c, dstRect, Gabor.outlineWidth*3);
    end
end





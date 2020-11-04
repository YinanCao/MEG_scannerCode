
cue_pos = find(Trial.probe_pos(trial,:)>0);
    
if ~isempty(cue_pos)
    if size(cue_pos,1)>1
        cue_pos = cue_pos';
    end

    for whichG = cue_pos % 1,2,3

        posX = Gabor.Xpos(whichG);
        posY = Gabor.Ypos(whichG);
        dstRect = CenterRectOnPoint(gaborrect, posX, posY);

        dotSizePix = Gabor.SDofGaussX*probeDotScale;
        Screen('DrawDots', window, [posX, posY], dotSizePix, probeDotcontrast, [], 2);
    end
end
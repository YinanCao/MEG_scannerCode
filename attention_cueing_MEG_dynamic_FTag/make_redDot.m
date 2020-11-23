
cue_pos = find(Trial.probe_pos(trial,:)>0);
    
if ~isempty(cue_pos)
    if size(cue_pos,1)>1
        cue_pos = cue_pos';
    end
    
    for q = 1:4
        for whichG = cue_pos % 1,2,3

            posX = Gabor.Xpos(whichG);
            posY = Gabor.Ypos(whichG);

            [x1,y1] = convertToQuadrant([posX, posY], windowRect, q);

            dotSizePix = Gabor.SDofGaussX*probeDotScale;
            Screen('DrawDots', window, [x1,y1], dotSizePix, probeDotcontrast, [], 2);
        end
    end
end
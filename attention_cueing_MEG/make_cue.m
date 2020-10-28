
% gabor parameters:
period = Gabor.period; % in pixels
f = 1/period; % spatial frequency
SDofGaussX = Gabor.SDofGaussX; % SD of x-axis of Gaussian ellipse (fixed; unit = pixel)
patchHalfSize = Gabor.patchHalfSize; % canvas on which gaussians are drawn
elp=Gabor.elp;
patchPixel = -patchHalfSize:patchHalfSize;

% define gabor positions (horizontal line atm):
gaborrect = [-patchHalfSize -patchHalfSize patchHalfSize patchHalfSize];

% make gabor:
% [x,y] = meshgrid(patchPixel, patchPixel);

% BorW = Gabor.WorB; % 1:black, -1:white
% a = SDofGaussX; % lowerbound of SD of y-axis of Gaussian ellipse
% b = SDofGaussX*elp; % upperbound of SD of y-axis of Gaussian ellipse
% SDofGaussY  = (b-a)*rand(1,Gabor.numGabors) + a;  % SD of y-axis of Gaussian ellipse
% contrast = Trial.contrast(trial,:);

cue_pos = find(Trial.cue_position(trial,:)>0);
if size(cue_pos,1)>1
    cue_pos = cue_pos';
end

for whichG = cue_pos % 1,2,3
    
    posX = Gabor.Xpos(whichG);
    posY = Gabor.Ypos(whichG);
    dstRect = CenterRectOnPoint(gaborrect, posX, posY);
    
    Screen('FrameOval', window, holder_c, dstRect, Gabor.outlineWidth*3);
    dotSizePix = Gabor.SDofGaussX;
%     Screen('DrawDots', window, [posX, posY], dotSizePix, holder_c, [], 2);
end





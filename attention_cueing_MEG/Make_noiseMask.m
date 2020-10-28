
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
[x,y] = meshgrid(patchPixel, patchPixel);

BorW = Gabor.WorB; % 1:black, -1:white
a = SDofGaussX; % lowerbound of SD of y-axis of Gaussian ellipse
b = SDofGaussX*elp; % upperbound of SD of y-axis of Gaussian ellipse
SDofGaussY  = (b-a)*rand(1,Gabor.numGabors) + a;  % SD of y-axis of Gaussian ellipse
contrast = Trial.contrast(trial,:);

for whichG = 1:Gabor.numGabors % top, left, right

    posX = Gabor.Xpos(whichG); % top, left, right
    posY = Gabor.Ypos(whichG);
    
    dstRect = CenterRectOnPoint(gaborrect, posX, posY);
    valleyC = BorW;
    c = contrast(whichG); % top, left, right
    gauss = exp(-(x.^2/(2*SDofGaussX^2)+y.^2/(2*SDofGaussY(whichG)^2)));
    gauss(gauss < 0.01) = 0;
    t = 0;
    gabor = sin(2*pi*f*(y*sin(t) + x*cos(t))).*gauss;
    
    M = grey*(1 + gabor*valleyC*c); % shift phase if valley = white
%     % to be consistent with the phase when valley = black (default)
%     if valleyC > 0
%         M(M > grey) = grey;
%     else
%         M(M < grey) = grey;
%     end
%     % crop outside the circle
%     
%     px = 0;
%     py = 0;
%     th = linspace(0, 2*pi);
%     xc = px + patchHalfSize*cos(th);
%     yc = py + patchHalfSize*sin(th);
%     idx = inpolygon(y(:),x(:),xc,yc);
%     M(~idx) = grey;
    
    M2 = rand(size(M));
    M2(~idx) = grey;
    
    orientation = Trial.orientation(trial,whichG);
    textureIndexTarg = Screen('MakeTexture', window, M2);
    Screen('DrawTextures', window, textureIndexTarg, [], dstRect,orientation);
    if c>0
        Screen('FrameOval', window, holder_c,dstRect,Gabor.outlineWidth);
    end
    
    

end






% attempt to achieve frequency tagging...

% gabor parameters:
period = Gabor.period; % in pixels
f = 1/period; % spatial frequency
SDofGaussX = Gabor.SDofGaussX; % SD of x-axis of Gaussian ellipse (fixed; unit = pixel)
patchHalfSize = Gabor.patchHalfSize; % canvas on which gaussians are drawn
elp = Gabor.elp;
patchPixel = -patchHalfSize:patchHalfSize;

% define gabor positions (horizontal line atm):
gaborrect = [-patchHalfSize -patchHalfSize patchHalfSize patchHalfSize];

% make gabor:
[x,y] = meshgrid(patchPixel, patchPixel);
SDofGaussY = SDofGaussX;
gauss = exp(-(x.^2/(2*SDofGaussX^2)+y.^2/(2*SDofGaussY^2)));
gauss(gauss < 0.01) = 0;
t = 0;
gabor = sin(2*pi*f*(y*sin(t) + x*cos(t))).*gauss;

%%
px = 0;
py = 0;
th = linspace(0, 2*pi);
xc = px + patchHalfSize*cos(th);
yc = py + patchHalfSize*sin(th);
idx = inpolygon(y(:),x(:),xc,yc);
%%
contrast = Trial.contrast(trial,:);

contrast(contrast>1) = 1;
% baseM_all = cell(0);
% for whichG = 1:3
%     peak = (1 + contrast(whichG))*0.5;
%     amp = peak - control_bkg;
%     M = gabor*amp + control_bkg;
%     M(M < control_bkg) = control_bkg;
%     % crop outside the circle
%     M(~idx) = control_bkg;
%     baseM_all{whichG} = M;
% end


baseM_all = cell(0);
for whichG = 1:Gabor.numGabors
    amplitude = (1-control_bkg)*contrast(whichG);
    M = gabor*amplitude + control_bkg;
    M(M < control_bkg) = control_bkg;
    % crop outside the circle
    M(~idx) = control_bkg;
    baseM_all{whichG} = M;
end

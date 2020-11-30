clear; clc; close all;

info.pix_per_deg = 35.8071;
Gabor.freq_deg              = 5; % spatial frequency (cycles/deg)
Gabor.period                = 1/Gabor.freq_deg*info.pix_per_deg; % in pixels
Gabor.freq_pix              = 1/Gabor.period;% in pixels
Gabor.diameter_deg          = 2;
Gabor.patchHalfSize         = round(info.pix_per_deg*(Gabor.diameter_deg/2)); % 50 pix
Gabor.SDofGaussX            = Gabor.patchHalfSize/2;
Gabor.patchPixel            = -Gabor.patchHalfSize:Gabor.patchHalfSize;
Gabor.elp                   = 1;
Gabor.WorB                  = -1; % 1:black, -1:white

% gabor parameters:
period = Gabor.period; % in pixels
f = 1/period; % spatial frequency
SDofGaussX = Gabor.SDofGaussX; % SD of x-axis of Gaussian ellipse (fixed; unit = pixel)
patchHalfSize = Gabor.patchHalfSize; % canvas on which gaussians are drawn
elp = Gabor.elp;
patchPixel = -patchHalfSize:patchHalfSize;

% define gabor positions (horizontal line atm):
gaborrect = [-1,-1,1,1]*Gabor.patchHalfSize; % canvas on which gaussians are drawn

% make gabor:
[x,y] = meshgrid(patchPixel, patchPixel);
valleyC = Gabor.WorB; % 1:black, -1:white
SDofGaussY = SDofGaussX;
% Gabor.Xpos = center_x + [-100, 100];

grey = 0.5;

    bkg_color = [grey, .2];

    
    
    gauss = exp(-(x.^2/(2*SDofGaussX^2)+y.^2/(2*SDofGaussY^2)));
    gauss(gauss < 0.01) = 0;
    t = 0;
    gabor = sin(2*pi*f*(y*sin(t) + x*cos(t))).*gauss;
    
    contrast = .4;
    peak = (1 + contrast)*0.5;
    
    baseM_all = cell(0);
    for side = 1:2
        this_bkg = bkg_color(side);
        amp = peak - this_bkg;
        M = gabor*amp + this_bkg;
        M(M < this_bkg) = this_bkg;
        % crop outside the circle
        px = 0;
        py = 0;
        th = linspace(0, 2*pi);
        xc = px + patchHalfSize*cos(th);
        yc = py + patchHalfSize*sin(th);
        idx = inpolygon(y(:),x(:),xc,yc);
        M(~idx) = this_bkg;
        baseM_all{side} = M;
        
        subplot(1,2,side)
        imagesc(M,[0,1]);
        colormap(gray)
        colorbar
        axis square
        
        [max(M(:)), min(M(:))]
       
    end
    
    
    
    
    
%     figure;
%     subplot(121)
%     imagesc(gabor,[-1,1])
%     colormap(gray)
%     colorbar
%     axis square
%     subplot(122)
%     plot(gabor(round(size(gabor,2)/2),:))
%     axis square
    
    
    
    
    
    
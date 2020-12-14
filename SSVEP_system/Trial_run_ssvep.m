%%%%%%%%%%%%% quad transformed locations
Gabor.freq_deg              = 5; % spatial frequency (cycles/deg)
Gabor.period                = 1/Gabor.freq_deg*info.pix_per_deg; % in pixels
Gabor.freq_pix              = 1/Gabor.period;% in pixels
% Gabor.SDofGaussX            = 20; % SD of x-axis of Gaussian ellipse (fixed; unit = pixel)
Gabor.diameter_deg          = Trial.gaborsize(trial);
Gabor.patchHalfSize         = round(info.pix_per_deg*(Gabor.diameter_deg/2)); % 50 pix
Gabor.SDofGaussX            = Gabor.patchHalfSize/2;
Gabor.patchPixel            = -Gabor.patchHalfSize:Gabor.patchHalfSize;
Gabor.elp                   = 1;
Gabor.numGabors             = 1;
Gabor.outlineColor          = ones(1,3)*0.75;


patchHalfSize = Gabor.patchHalfSize; % canvas on which gaussians are drawn
% define gabor positions (horizontal line atm):
gaborrect = [-patchHalfSize -patchHalfSize patchHalfSize patchHalfSize];
q_dstRect_all = cell(0);
for whichG = 1 
    posX = center_x;
    posY = center_y;
    dstRect = CenterRectOnPoint(gaborrect, posX, posY);
    q_dstRect_gabor = zeros(4,4);
    for q = 1:4
        [x1,y1] = convertToQuadrant(dstRect(1:2), windowRect, q);
        [x4,y4] = convertToQuadrant(dstRect(3:4), windowRect, q);
        q_dstRect_gabor(q,:) = [x1,y1,x4,y4];
    end
    q_dstRect_all{whichG} = q_dstRect_gabor;
end

% generate tagging signal
FR = info.frameRate;
d2 = 4; % duration of tagging signal
d6 = 0; % 0
D2 = round(FR * d2);
D6 = round(FR * d6);
tag_sig = tag_get_tagging_signal(d2 + d6, (D2 + D6)*12, tag_f);
xColor3d = cell(0);
for i = 1:length(tag_sig)
    xColor3d{i} = reshape(tag_sig{i}, 4, 3, []);
end

orientations = [];
count = 1;
for q = 1:4
    orientations(count) = Trial.orientation(trial);
    count = count + 1;
end

vbl = Screen('Flip', window);

Make_gabor_Ftag_baseM; % create baseM_all{}

trl_tagf = Trial.tagging_freq(trial);

% Stimulus presentation
for vblframe = 1:D2
    destinationRect = [];
    textureIndexTarg = [];
    count = 1;
    for q = 1:4 % quadrant
        for whichG = 1 % stimuli
            baseM = baseM_all{whichG};
            fColor = xColor3d{trl_tagf(whichG)}(:,:,vblframe); % each row=quad,
            q_dstRect = q_dstRect_all{whichG};
            Mx = nan([size(baseM,1),size(baseM,2),3]);
            for chan = 1:3
               M = baseM - control_bkg; % bring to zero
               M = M.*fColor(q, chan);
               M = M + control_bkg;
               Mx(:,:,chan) = M;
            end
            textureIndexTarg(count) = Screen('MakeTexture', window, Mx);
            destinationRect(:,count) = q_dstRect(q,:)';
            count = count + 1;
        end % end stim
    end % end quad
    Screen('DrawTextures', window, textureIndexTarg, [], destinationRect, orientations, [], 1);
    Screen('FrameOval', window, Gabor.outlineColor, destinationRect, 1);

    vbl = Screen('Flip', window, vbl + 0.5 * ifi);
    Screen('Close', textureIndexTarg);
    
    if vblframe == 1
        trigger(Trial.trigval(trial));
    end

end % end vbl frames

vbl = Screen('Flip', window, vbl + 0.5 * ifi); 
trigger(Trial.trigval(trial));


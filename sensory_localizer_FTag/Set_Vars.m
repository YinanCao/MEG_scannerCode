
info.cuewidth      = 1; % pix
info.nTrials       = nTrials;
info.SubName       = SubName;
info.SubNo         = SubNo;
info.Age           = Age;
info.Gender        = Gender;
info.Hand          = Hand;
info.Date          = date;
info.Session_type  = session_type;
info.Session_No    = session_No;
info.Block_type    = Block_type;
info.BlockNo       = 1;
info.ET            = EL_flag;
info.do_trigger    = trigger_flag;
info.kb_setup      = 'MEG';
info.mon_width_cm  = 46;% width of monitor (cm)
info.mon_height_cm = 27;% height of monitor (cm)
info.view_dist_cm  = 53;% viewing distance (cm)
info.pix_per_deg   = info.window_rect(3) *(1 ./ (2 * atan2(info.mon_width_cm / 2, info.view_dist_cm))) * pi/180;

info.width = info.mon_width_cm;
info.height = info.mon_height_cm;
info.dist = info.view_dist_cm;

rng('shuffle');
trigger_enc = setup_trigger;
 
if info.do_trigger
    addpath matlabtrigger/
else
    addpath faketrigger/
end

%----------------
% Gabor Parameters
%----------------
if info.Session_type == 'B'
    Gabor.WorB =  1; % 1:black
else
    Gabor.WorB = -1; %-1:white
end

info.loc_all = loc_all;
Gabor.tr_contrast           = all_contrast;
Gabor.freq_deg              = 5; % spatial frequency (cycles/deg)
Gabor.period                = 1/Gabor.freq_deg*info.pix_per_deg; % in pixels
Gabor.freq_pix              = 1/Gabor.period;% in pixels
% Gabor.SDofGaussX            = 20; % SD of x-axis of Gaussian ellipse (fixed; unit = pixel)
Gabor.diameter_deg          = 3;
Gabor.patchHalfSize         = round(info.pix_per_deg*(Gabor.diameter_deg/2)); % 50 pix
Gabor.SDofGaussX            = Gabor.patchHalfSize/2;
Gabor.patchPixel            = -Gabor.patchHalfSize:Gabor.patchHalfSize;
Gabor.elp                   = 1;
Gabor.numGabors             = 3;
if Block_type == 'n'
    Gabor.gc_from_sc_deg    = 1.25;
    Gabor.gc_from_sc_pix    = round(info.pix_per_deg*Gabor.gc_from_sc_deg);
elseif Block_type == 'f'
    Gabor.gc_from_sc_deg    = 2.2;
    Gabor.gc_from_sc_pix    = round(info.pix_per_deg*Gabor.gc_from_sc_deg);
end
Gabor.X_Shift_deg           = round(((sqrt(3)/2) * Gabor.gc_from_sc_deg));
Gabor.Y_Shift_deg           = round(((1/2) * Gabor.gc_from_sc_deg));
Gabor.X_Shift_pix           = round(info.pix_per_deg * Gabor.X_Shift_deg);
Gabor.Y_Shift_pix           = round(info.pix_per_deg * Gabor.Y_Shift_deg);
Gabor.size_fluctuation      = round(info.pix_per_deg*0);% 0 pix
Gabor.outlineWidth          = 1;

%   Position
Trial.all_pos               = ['L','M','R'];
Trial.all_triangle_dir      = 'U';
Trial.Triangle_dir          = 'U';
% Trial.trial_type            = [1:8];
% Trial.type                  = [Shuffle(repmat(Trial.trial_type,[1 nTrials/16])) Shuffle(repmat(Trial.trial_type,[1 nTrials/16]))];
% counterbalance the number of  our 8 different conditions in both U and D presentation
% Trial.JND                   = round(JND_median,2);
% Trial.value_B_base          = JND_base_value;
% Trial.min_D                 = Min_D;
% Trial.value_B_rng           = [repmat(Trial.value_B_base,[1 8])];
% Trial.value_A_dev           = Trial.value_B_rng+([-2 -1 1 2 -2 -1 1 2]*Trial.JND);
% Trial.value_D_dev           = [Trial.value_B_rng(1:4)+([-2.5 -2.5 -2.5 -2.5]*Trial.JND) ones(1,4)*Trial.min_D];
% Trial.value_B               = Trial.value_B_rng(Trial.type);
% Trial.value_A               = Trial.value_A_dev(Trial.type);
% Trial.value_D               = Trial.value_D_dev(Trial.type);

Trial.numGabors             = 3;
Trial.Gabor_arng_rotation   = 'R';
Trial.Gabor_orientation     = all_angles;
Trial.rot_deg               = 5;

Trial.cueNumColor          = white;

Trial.cueNumberD           = 0.3;
%    Make a truncated distributaion for inter_trial delay
pd                         = makedist('Exponential','mu',0.75);
t                          = truncate(pd,0.6,1.5);
Trial.BRD                  = random(t,[1,nTrials]);% Being Ready duration
Trial.cueD                 = 0.05; % cue duration
Trial.cue2StimD            = 0.1;
Trial.SD                   = 1;% Stimulus duration
Trial.ISI                  = 0.4;
Trial.s2PD                 = 0.5;
Trial.ProbD                = 0.5;
Trial.StRCD                = 0.5; % probe offset to response onset
Trial.RCD                  = 2; % Response cue duration
Trial.FBD                  = 0.25;% FeedBack duration
Trial.TimeWaitafterFB      = 0.3;

if Trial.Triangle_dir == 'U'
    x                  = [-Gabor.X_Shift_pix,0,Gabor.X_Shift_pix];
    y                  = [Gabor.Y_Shift_pix,-Gabor.gc_from_sc_pix,Gabor.Y_Shift_pix];
else
    x                  = [-Gabor.X_Shift_pix,0,Gabor.X_Shift_pix];
    y                  = [-Gabor.Y_Shift_pix,Gabor.gc_from_sc_pix,-Gabor.Y_Shift_pix];
end

if Trial.Gabor_arng_rotation == 'R'
    x_rot              = round(x*cosd(Trial.rot_deg) - y*sind(Trial.rot_deg));
    y_rot              = round(y*cosd(Trial.rot_deg) + x*sind(Trial.rot_deg));
    Xpos               = [center_x,center_x,center_x] + x_rot;
    Ypos               = [center_y,center_y,center_y] + y_rot;
else
    x_rot              = round(x*cosd(360-Trial.rot_deg) - y*sind(360-Trial.rot_deg));
    y_rot              = round(y*cosd(360-Trial.rot_deg) + x*sind(360-Trial.rot_deg));
    Xpos               = [center_x,center_x,center_x] + x_rot;
    Ypos               = [center_y,center_y,center_y] + y_rot;
end

Gabor.Xpos = Xpos([2,1,3]); % this order is: left, mid, right
Gabor.Ypos = Ypos([2,1,3]); % so we need to change it to mid, left, right

%    Crossed fixation information
Gabor.Fixation_dot_deg        = 0.15;
Gabor.Fixation_cross_h_deg    = Gabor.Fixation_dot_deg;
Gabor.Fixation_cross_w_deg    = Gabor.Fixation_dot_deg*4;
Gabor.Fixation_dot_pix        = round(info.pix_per_deg*Gabor.Fixation_dot_deg);
Gabor.Fixation_cross_h_pix    = round(info.pix_per_deg*Gabor.Fixation_cross_h_deg);
Gabor.Fixation_cross_w_pix    = round(info.pix_per_deg*Gabor.Fixation_cross_w_deg);
fixCrossDimPix                = round(info.pix_per_deg*(Gabor.Fixation_cross_w_deg/2));%12 pix
xCoords                       = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords                       = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords                     = [xCoords; yCoords];
lineWidthPix                  = round(info.pix_per_deg*Gabor.Fixation_dot_deg);%6 pix
fix_rect                      = [-7 -2 7 2];%[ceil([-fixCrossDimPix -lineWidthPix/2]./2) floor([fixCrossDimPix lineWidthPix/2]./2)];


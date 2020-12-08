
%-----------------------------------------
% Predefined and define needed inforamtion
%-----------------------------------------
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
info.BlockNo       = Block_No;
info.ET            = EL_flag;
info.do_trigger    = 0;
info.kb_setup      = 'MEG';
info.mon_width_cm  = 46;% width of monitor (cm)
info.mon_height_cm = 27;% height of monitor (cm)
info.view_dist_cm  = 53;% viewing distance (cm)
info.pix_per_deg   = info.window_rect(3) *(1 ./ (2 * atan2(info.mon_width_cm / 2, info.view_dist_cm))) * pi/180;

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

Gabor.foil_contrast      = 0;    
Gabor.freq_deg           = 5; % spatial frequency (cycles/deg)
Gabor.period             = 1/Gabor.freq_deg*info.pix_per_deg; % in pixels
Gabor.freq_pix           = 1/Gabor.period;% in pixels

Gabor.diameter_deg       = GaborDiameter;
Gabor.patchHalfSize      = round(info.pix_per_deg*(Gabor.diameter_deg/2)); % 50 pix
Gabor.SDofGaussX         = Gabor.patchHalfSize/2;
Gabor.patchPixel         = -Gabor.patchHalfSize:Gabor.patchHalfSize;
Gabor.elp                = 1;
Gabor.numGabors          = 2;
if Block_type == 'n'
    Gabor.gc_from_sc_deg = 1.25;
    Gabor.gc_from_sc_pix = round(info.pix_per_deg*Gabor.gc_from_sc_deg);
elseif Block_type == 'f'
    Gabor.gc_from_sc_deg = 2.2;
    Gabor.gc_from_sc_pix = round(info.pix_per_deg*Gabor.gc_from_sc_deg);
end
Gabor.X_Shift_deg        = round(((sqrt(3)/2) * Gabor.gc_from_sc_deg));
Gabor.Y_Shift_deg        = round(((1/2) * Gabor.gc_from_sc_deg));
Gabor.X_Shift_pix        = round(info.pix_per_deg * Gabor.X_Shift_deg);
Gabor.Y_Shift_pix        = round(info.pix_per_deg * Gabor.Y_Shift_deg);
Gabor.Xpos               = [center_x-Gabor.X_Shift_pix,center_x+Gabor.X_Shift_pix];
Gabor.Ypos               = [center_y,center_y];
Gabor.size_fluctuation   = round(info.pix_per_deg*0);%0 pix


%   Position
Trial.all_pos                 = ['L','R'];
Trial.Gabor_position          = Shuffle(repmat(Trial.all_pos,[1 nTrials/2]));
Trial.Gabor_orientation_type  = Shuffle(repmat(['R','R'], [1 nTrials/2]));% 'R':clockwise 'L':Couter-clockwis
Trial.Gabor_orientation_R     = all_angles;
%Trial.Gabor_orientation_L     = [100 135 170];
Trial.Gabor_all_contrast_base = [0.5 0.5];
Trial.num_quests              = 2;
Trial.Which_quest             = Shuffle(repmat([1:Trial.num_quests],[1 nTrials/Trial.num_quests]));
Trial.near_rng                = [1.03 1.07];
Trial.far_rng                 = [1.6 1.8];
Trial.t_guess                 = Trial.Gabor_all_contrast_base...
    .*([diff(Trial.near_rng)*rand + min(Trial.near_rng) ...
    diff(Trial.far_rng)*rand + min(Trial.far_rng)]);
Trial.Gabor_contrast          = Trial.Gabor_all_contrast_base(Trial.Which_quest);

%    Make a truncated distributaion for inter_trial delay
pd                            = makedist('Exponential','mu',0.75);
t                             = truncate(pd,0.5,1);
Trial.BRD                     = random(t,[1,nTrials]);% Being Ready duration
Trial.SD                      = 1;% Stimulus duration
Trial.StRCD                   = 0.15; % Stimulus offset to Response Cue onset duration
Trial.RCD                     = 1; % Response Cue duration
Trial.FBD                     = 0.25;% FeedBack duration
Trial.MD                      = 0.2 + (0.1*rand(nTrials,3));%mask duration
Trial.TimeWaitafterFB         = 0.6;

for trial=1:nTrials
    if Trial.Gabor_orientation_type(trial) =='R'
        %which_o = randperm(3);
        which_o = randi(3,1,3);
            Trial.orientation (trial,:) = Trial.Gabor_orientation_R(which_o(1:2));
    else
        which_o = randperm(3);
            Trial.orientation (trial,:) = Trial.Gabor_orientation_L(which_o(1:2));
    end
    
    % first column: left gabor and second column: right gabor
    Trial.Center_X_fluc(trial,:)= Gabor.Xpos+((sign(randn(1,Gabor.numGabors )).*rand(1,Gabor.numGabors ))*Gabor.size_fluctuation);
    Trial.Center_Y_fluc(trial,:)= Gabor.Ypos+((sign(randn(1,Gabor.numGabors )).*rand(1,Gabor.numGabors ))*Gabor.size_fluctuation);
    
end


%-------------------------
% Set the QUEST Parameters
%-------------------------
% Here we use two Quests to avoid biasing
t_guess=log10(Trial.t_guess);

for q=1:Trial.num_quests
    eval(['Quest.tGuess' num2str(q) '= t_guess(q)' ]);
    eval (['Quest.tGuessSd' num2str(q) '= 0.5']);
    eval (['Quest.pThreshold' num2str(q) '= 0.75']);
    eval (['Quest.beta' num2str(q) '= 3.5']);
    eval (['Quest.delta' num2str(q) '= 0.01']);
    eval (['Quest.gamma' num2str(q) '= 0.5']);
    eval (['Quest.q' num2str(q) '(1)= QuestCreate(Quest.tGuess' num2str(q) ...
        ',Quest.tGuessSd' num2str(q) ',Quest.pThreshold' num2str(q) ...
        ',Quest.beta' num2str(q) ',Quest.delta' num2str(q) ',Quest.gamma' num2str(q) ');']);
end

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
% fix_rect                      = [-fixCrossDimPix -lineWidthPix./2 fixCrossDimPix lineWidthPix./2];

fix_rect                      = [-5 -1 5 1];
%[ceil([-fixCrossDimPix -lineWidthPix/2]./2) floor([fixCrossDimPix lineWidthPix/2]./2)];

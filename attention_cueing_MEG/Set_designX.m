
%-----------------------------------------
% Predefined and define needed inforamtion
%-----------------------------------------
clc
% >>>>>>> orientation table:
angle_x = [
1 2 3 4 5 6 3 3 2 6 6 5 2 1 1 5 4 4
2 1 1 5 4 4 1 2 3 4 5 6 3 3 2 6 6 5
3 3 2 6 6 5 2 1 1 5 4 4 1 2 3 4 5 6
];
angle_x = repmat(angle_x,1,3); % 54 trials, cue1, cue2, cue3

% >>>>>>> cue location table:
cue_1  = [ % cue only 1 location
1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1
];
cue_2 = [ % cue 2 locations
1 1 1 1 1 1 0 1 0 1 0 1 1 0 1 0 1 0
1 0 1 0 1 0 1 1 1 1 1 1 0 1 0 1 0 1
0 1 0 1 0 1 1 0 1 0 1 0 1 1 1 1 1 1
];
cue_3 = [ones(3,6),ones(3,6),ones(3,6)]; % cue all 3 locations
cue_x = [cue_1, cue_2, cue_3]; % 54 trials


% >>>>>>> contrast table
contrast_x = cat(3,ones(3,18),ones(3,18)*2,ones(3,18)*3); 
% 3 blocks to counterbalance contrast for each location and angle
for i = 1:size(contrast_x,1)
    for j = 1:size(contrast_x,2)
        contrast_x(i,j,:) = contrast_x(i,j,randsample(1:3,3));
    end
end
contrast_x = repmat(contrast_x,[1,3,1]); % 54 trials, cue1, cue2, cue3
% contrast = 3 blocks already 

% rep anlge_x and cue_x to 3 blocks:
angle_x = repmat(angle_x,[1,1,3]);
cue_x = repmat(cue_x,[1,1,3]);

probe_x = cue_x*0;
% design the probe location
for block = 1:3
    probe = cue_x(:,:,block);
    nt = size(probe,2); % ntrial
    while 1
        pb = [];
        for t = 1:nt
            tmp = probe(:,t);
            id = find(tmp>0);
            pb(t) = id(randi(length(id)));
        end
        l = [];
        for k = 1:3
            l(k) = length(find(pb==k));
        end
        if l(1)==l(2) && l(2)==l(3)
            break;
        end
    end
    for t = 1:nt
        probe_x(pb(t),t,block) = 1;
    end
end % end block
% size(probe_x)
% size(angle_x)
% size(cue_x)
% size(contrast_x)

%%%%%%%% very important:
design_x = cat(4,cue_x,angle_x,contrast_x,probe_x);
design_x = permute(design_x,[1,2,4,3]); % last dim is block

% trial order suffuling:
for block = 1:3
    nTrials = size(design_x,2);
    shuffle_trial = randperm(nTrials)';
    design_x(:,:,:,block) = design_x(:,shuffle_trial,:,block);
end
% size(design_x) % last dim is 3 blocks

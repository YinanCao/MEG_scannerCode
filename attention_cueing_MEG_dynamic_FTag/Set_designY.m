
% orientation:
ori = [perms(1:3); perms(1:3)+3]'; % % top, left, right
% well, angles can just be different...

% cued location:
cue = [eye(3);ones(1,3)]';

cue_table = [];
count = 1;
for i = 1:size(cue,2)
    for j = setdiff(1:size(cue,2),i)
        cue_table(:,count,1) = cue(:,i);
        cue_table(:,count,2) = cue(:,j);
        count = count + 1;
    end
end
cue_table_change = cue_table;
cue_table_Nochange = cue_table;
cue_table_Nochange(:,:,2) = 0;
% yes/no second cue:
cue_table = cat(2,cue_table_change,cue_table_Nochange);

% cue 2 timing:

% yes/no probe-dot: within each condition, which cued location
probe = cue_table(:,:,2);
probe(:,13:24) = cue_table(:,13:24,1);
p_loc = [];
tmp = probe*0;
for k = 1:size(probe,2)
    candid_loc = find(probe(:,k)==1);
    p_loc = candid_loc(randi(length(candid_loc)));
    tmp(p_loc,k) = 1;
end
cue_table = cat(3,cue_table,tmp);

cue_table_nodot = cue_table;
cue_table_nodot(:,:,3) = 0;
cue_all = cat(2,cue_table_nodot,cue_table);

N = size(cue_all,2)/size(ori,2);
ori_all = repmat(ori,[1,N,1]);
N = size(cue_all,2);
ori_all = ori_all(:,randperm(N));

design_y = cat(3,cue_all,ori_all); % cue1, cue2, probeloc, orientation
% top, left, right

design_y = design_y(:,randperm(N),:);
nTrials = N;

% design_y([1,3],:,1:2) = 0;




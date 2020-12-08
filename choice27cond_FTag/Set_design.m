% 8 conditions
B   = 0.5;
jnd = 0.06;
A   = [-2, -1, 1, 2]*jnd + B;
D   = [0.15, B-3*jnd];
CC  = [];
for d = 1:2
    for a = 1:4
        CC = [CC; A(a),B,D(d)];
    end
end
% A/B/D contrast, just for top,left,right order

ori = [ % for A,B,D
1 1 1
2 2 2
3 3 3
3 3 1
3 3 2
2 2 1
2 2 3
1 1 2
1 1 3
3 1 3
3 2 3
2 1 2
2 3 2
1 2 1
1 3 1
1 3 3 
2 3 3
1 2 2
3 2 2
2 1 1
3 1 1
1 2 3
2 1 3
3 1 2
1 3 2
3 2 1
2 3 1];

tmp = [];
count = 1;
design = [];
for i = 1:size(CC,1)
    for j = 1:size(ori,1)
        design(count,:,1) = CC(i,:);
        design(count,:,2) = ori(j,:);
        count = count + 1;
    end
end

pos_ord = perms(1:3);
% now, let's permute the position
design_all = [];
for i = 1:size(pos_ord,1)
    design_all = cat(1, design_all, design(:,pos_ord(i,:),:));
end

n = size(design_all,1);
shuffle_ord = randperm(n);
design_all = design_all(shuffle_ord,:,:);

% 18.0000   72.0000
% 24.0000   54.0000
% 12.0000  108.0000

trl_in_block = nTrials;
block = size(design_all,1)/trl_in_block;
tt = []; design_blk = cell(0);
for b = 1:block
    tt = trl_in_block*(b-1)+1:(trl_in_block*b);
    design_blk{b} = design_all(tt,:,:);
end








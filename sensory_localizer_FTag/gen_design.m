function [d_matrix,nTrials] = gen_design(block,niter)
    d_matrix = [];
    trlc = 1;
    for iter = 1:niter
        cond = [];
        for loc = block % location
            for c = 1:3 % contrast
                for ori = 1:6 % anlges
                    cond = [cond; c,ori,loc];
                end
            end
        end
        rep = 2;
        design = repmat(cond,rep,1);
        maxN = 8;
        shuffle_trial = randperm(size(design,1))';
        design = design(shuffle_trial,:);
        set = { 1;
                [2,3];
                [4,5,6];
                [7,8,9,10];
                [11,12,13,14,15];
                [16,17,18,19,20,21];
                [22,23,24,25,26,27,28];
                [29,30,31,32,33,34,35,36]};
        for k = randperm(maxN)
            d_matrix{trlc} = design(set{k},:);
            trlc = trlc + 1;
        end
    end
    nTrials = length(d_matrix);
end



clc;
tag_f = [63, 78, 94];
pair = nchoosek(tag_f,2)

harmo = sort([tag_f*2, tag_f*3, tag_f*1])
inter = sort([sum(pair,2)',diff(pair')])

cc = [];
for i = 1:length(inter)
    for j = 1:length(harmo)
       cc = [cc; abs(inter(i)-harmo(j))];
    end
end
min(cc)







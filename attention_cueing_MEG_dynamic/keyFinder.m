clear; clc

for t=1:3

t0 = GetSecs();
runner = 1;
while GetSecs() < t0 + 2
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-3);
    if keyIsDown
        b(runner,t) = find(keyCode);
        runner=runner+1;
    end
end
a(t)    = sum(keyCode);
n{t}    = KbName(keyCode);
end

% GetKeyboardIndices() % [3:6,8,12]
b(b==0)=[];
keyCode=zeros(256,1);
keyCode(unique(b))=1;
KbName(keyCode)
clear
clc
keyIsDown = 0;
while ~keyIsDown
[keyIsDown, secs, press_key, deltaSecs] = KbCheck();
%KbName(press_key)
end

find(press_key)
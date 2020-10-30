function trig = setup_trigger()

trig.EL_start = 1;

trig.circle_on = 4;

for k = 1:10
    trig.motor_blockType(k) = k + 200;
end

trig.L_Hand = 11;
trig.R_Hand = 18;
trig.L_Foot = 30;
trig.R_Foot = 68;
trig.resp_invalid = 99;

end

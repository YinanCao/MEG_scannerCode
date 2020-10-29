
if press_key(L_Hand)
    trigger(trigger_enc.L_Hand);  % trigger to mark the response
    disp(['trigger sent = ',num2str(trigger_enc.L_Hand)])
    if info.ET
        Eyelink('message', num2str(trigger_enc.L_Hand));
    end

elseif press_key(R_Hand)
    trigger(trigger_enc.R_Hand);  % trigger to mark the response
    disp(['trigger sent = ',num2str(trigger_enc.R_Hand)])
    if info.ET
        Eyelink('message', num2str(trigger_enc.R_Hand));
    end

elseif press_key(L_Foot)
    trigger(trigger_enc.L_Foot);  % trigger to mark the response
    disp(['trigger sent = ',num2str(trigger_enc.L_Foot)])
    if info.ET
        Eyelink('message', num2str(trigger_enc.L_Foot));
    end
    
elseif press_key(R_Foot)
    trigger(trigger_enc.R_Foot);  % trigger to mark the response
    disp(['trigger sent = ',num2str(trigger_enc.R_Foot)])
    if info.ET
        Eyelink('message', num2str(trigger_enc.R_Foot));
    end
    
else 
    trigger(trigger_enc.resp_invalid);  % trigger to mark the response
    disp(['trigger sent = ',num2str(trigger_enc.resp_invalid)])
    if info.ET
        Eyelink('message', num2str(trigger_enc.resp_invalid));
    end

end
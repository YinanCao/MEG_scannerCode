function x = tag_get_tagging_signal(d, D, f)

    % parameters
    t = linspace(0, d, D);

    for whichf = 1:length(f)
        x{whichf} = 0.5 * sin(2 * pi * f(whichf) * t) + 0.5; 
    end

end % end

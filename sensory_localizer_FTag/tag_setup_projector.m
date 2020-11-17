function tag_setup_projector(command, bProjector)

if bProjector == 1
  if strcmp(command, 'open')
    Datapixx('Open');
  elseif strcmp(command, 'set')
    Datapixx('SetPropixxDlpSequenceProgram', 5); % 1440 Hz
    Datapixx('RegWrRd');
  elseif strcmp(command, 'reset')
    Datapixx('SetPropixxDlpSequenceProgram', 0); % default
    Datapixx('RegWrRd');
  elseif strcmp(command, 'close')
    Datapixx('Close');
  else
    fprintf(1, 'Propixx command ''%s'' is not defined.\n', command);
    return
  end
end
  
end % end
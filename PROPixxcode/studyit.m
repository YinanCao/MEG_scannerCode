clear;clc;
close all;
FR = 60;
d2 = 1.0; % duration of tagging signal
d6 = 0.3; % break
D2 = round(FR * d2 * 12); % 12 is the Propixx multiplier for gray scale
D6 = round(FR * d6 * 12);

d = d2 + d6
D = D2 + D6

t = linspace(0, d, D);
fl = 100;
fh = 70;
xColor1d0 = 0.5 * sin(2 * pi * fl * t) + 0.5; 
xColor1d1 = 0.5 * sin(2 * pi * fh * t) + 0.5;
plot(t,xColor1d0, t,xColor1d1)

size(xColor1d0)
xColor3d0 = reshape(xColor1d0, 4, 3, []);
xColor3d1 = reshape(xColor1d1, 4, 3, []);

size(xColor3d0)
% size(xColor3d1)
xColor3d0(:,:,1)
xColor1d0(1:12)

xColor3d = {xColor3d0, xColor3d1};
D2 = D2 / 12; % VBL frames at 120 Hz
D6 = D6 / 12;
(D2 + D6)

%%

% loop
for trial = 1
    tmp = [];
  for d = 1:(D2 + D6)
    fColor = xColor3d{1}(:, :, d);
    hColor = xColor3d{2}(:, :, d);
    if d < (D2 + 1) % tagging
      for i = 1:4
        tmp = [tmp; fColor(i, :)];
        % hColor(i, :);
      end
    end
  end
end

close all;
plot(tmp)

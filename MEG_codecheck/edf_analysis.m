clear; clc; close all;
tool_path = '/Users/yinancaojake/Documents/MATLAB/YC_private/';
restoredefaultpath
addpath(genpath(tool_path))

datadir = '/Users/yinancaojake/Documents/Postdoc/UKE/pilot/MEG_codecheck/Log/';
edf0 = Edf2Mat([datadir,'s1_b2.edf'])
% plot(edf0)

% 
% edf0.Events.Messages.info'
t = edf0.Events.Messages.time(11:end)';
diff(t)


% edf0.Samples
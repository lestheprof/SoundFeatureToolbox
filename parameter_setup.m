function param = parameter_setup()

param = [];
param.Fs = 44100; %sampling frequency
param.num_levels = 10; %number of sensitivity levels

% Filterbank parameters:
param.f_low = 50; %lowest central frequency
param.f_high = 6500; %highest central frequency
param.n_channels = 200 ;; %number of filter channels
param.cf = MakeErbCFs(param.f_low,param.f_high,param.n_channels);
% Please uncomment the following line and comment the previous one if you
% have different central frequencies than those calculated by the
% MakeErbCfs() function.

% param.cf = [120 400 880 1740 3250 6000]; %central frequencies


% The correction factor is used for adjusting the implementation of Michael
% Newton and this one. It is calculated as the average of the quotient
% between the maximum of this toolbox's IR (for each channel) and the maximum
% of M. Newton's toolbox's IR.
param.correction_factor = 1.334;
param.min_level = 0.0002;
param.min_level = param.min_level*param.correction_factor;
% added LSS May 10 2013
% multiplication factor between levels
param.mult_factor = sqrt(2) ;


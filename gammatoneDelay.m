function d=gammatoneDelay(cf,fs, N_erbs)

% Compute gammatone envelope delay in samples
% this is (equation 41, Cooke 1993, pp 69
% (n-1)/2 * pi * b in seconds
% where n is filter order (4 here)
% and b is bandwithh, which is here 1.018 * ERB 
%
% assumes bandwidcth is 1 erb, unless N_erbs is set

if (nargin < 3) N_erbs = 1 ;
end

d=(3*fs)./(N_erbs * erb(cf)*bwcorrection*2*pi);
function [segments] = findsegments_1(fname,sigma1, sigmaratio, dtperelement, nsamples, varargin)
%findsegments fimds segments in a sound (provided as an array)
% new version 11 Oct 2018: bandpass filtered version
%
% Uses half difference of gaussians on the bandpassed
% signal, unfiltered.
%   fname name for sound
%   sigma1: faster gaussian
%   sigmaratio: slower gaussian = sigma1 * sigmaratio
%   dtperelement: time per sample
%   nsamples: number of samples in the convolving function
%   vararegin see below
debug = true ; 
% default values for BPF etc: use varargin to adjust
minCochFreq = 100 ; % BPF parameters
maxCochFreq = 5000 ;
N_erbs = 1 ; 
nFilt = 10 ;
smoothlength = 0.01 ; % Bartlett filter parameter length of triangular (bartlett) window used to smooth
%   rectified signal prior to hdog filtering (in seconds)

i = 1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        
        case 'mincochfreq'
            minCochFreq = varargin{i+1}; 
            i=i+1 ;
        case 'maxcochfreq'
            maxCochFreq = varargin{i+1}; 
            i=i+1 ;
        case 'n_erbs'
            N_erbs = varargin{i+1}; 
            i=i+1 ;
        case 'nfilt'
            nFilt = varargin{i+1}; 
            i=i+1 ;
        case 'smoothlength'
            smoothlength = varargin{i+1}; 
            i=i+1 ;
        otherwise
            error('findsegments_1: Unknown argument %s given',varargin{i});
    end
    i=i+1 ;
end
% Wholegaussian and smoothing should probably be precomputed if there are many signals to be
% processed
wholegaussian = diffofgaussians(sigma1, sigma1 * sigmaratio, nsamples * 2 + 1,dtperelement) ;
hdog = wholegaussian(nsamples: end) ;
if (debug)
    disp(['findsegments: sum of half difference of Guassians = ' num2str(sum(hdog))]) ;
end
% Calculate smoothing for signal
bartlettlength = floor(smoothlength/dtperelement) ;
bartlettwindow = bartlett(bartlettlength) ;
bartlettwindow = bartlettwindow/sum(bartlettwindow) ; % normalise to sum of 1

% bandpass the signal
[bmSig, sig, fs, datalength, cochCFs, delayVector] = ...
    bmsigmono(fname, nFilt, minCochFreq, maxCochFreq, 10, 'gamma', N_erbs) ;

% calculate oosignal for each band
% initialise oosignal
oosignal = zeros(size(bmSig)) ;
for (band = 1:nFilt)
    % first rectify the band from tne basilar membrane signal, then smooth
    % it with the bartlett window, then convolve it with the half
    % difference of Gaussians
    oosignal(band,:) = conv(conv(abs(bmSig(band,:)),bartlettwindow, 'same'), hdog, 'same') ;
end
oosignal_final = sum(oosignal,1) ;

% now segment the signal using oosignal_final

segments = 0;
end


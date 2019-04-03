function [segments] = findsegments_2(fname,sigma1, sigmaratio, dtperelement, nsamples, varargin)
%findsegments_2 finds segments in a sound (provided as an array)
% new version started 2 April 2019: finds segments using LIF neurons
%
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
debug = false ;
% default values for BPF etc: use varargin to adjust
minCochFreq = 100 ; % BPF parameters
maxCochFreq = 5000 ;
N_erbs = 1 ;
nFilt = 10 ;
smoothlength = 0.01 ; % Bartlett filter parameter length of triangular (bartlett) window used to smooth
%   rectified signal prior to hdog filtering (in seconds)
% constants for segmentation from oo signal

% do we take log of onset and offset?
logonset = true ;
threshold = 0.04 ;
G_quiet = 0.05 ;
k_minimin = 0.4 ; % not used just yet...
segStartAdjust = 0.05 ; % allows adjusting back the time of a segment start to ZX before peak
%
minseglength = 0 ; % minimum segment length

% new parameters for LIF based onset and offset
onset_diss = 100 ; % dissipation for onset neurons
onset_rp = 0.05 ; % refractory period for onset cells
onset_wt = 100.0 ; % onset weight
offset_diss = 100 ; % dissipation for offset neurons
offset_rp = 0.05 ; % refractory period for onset cells
offset_wt = 100.0 ; % offset weight
convergence = 4 ; % convergence (no of inputs to each neuron = 2*convergence + 1)

% new parameters for calculating actual segments
summarysteplength = 0.005 ; % 5ms default
summaryintegratelength = 0.02; % 20ms default



i = 1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'debug'
            debug  = varargin{i+1};
            i=i+1 ;
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
        case 'threshold'
            threshold = varargin{i+1};
            i=i+1 ;
        case 'logonset'
            logonset = varargin{i+1};
            i=i+1 ;
        case 'g_quiet'
            G_quiet = varargin{i+1};
            i=i+1 ;
        case 'k_minmin'
            K_minmin = varargin{i+1};
            i=i+1 ;
        case 'segstartadjust'
            segStartAdjust = varargin{i+1};
            i=i+1 ;
        case 'minseglength'
            minseglength = varargin{i+1};
            i=i+1 ;
        case 'onset_diss'
            onset_diss = varargin{i+1};
            i=i+1 ;
        case 'onset_rp'
            onset_rp = varargin{i+1};
            i=i+1 ;
        case 'onset_wt'
            onset_wt  = varargin{i+1};
            i=i+1 ;
        case 'offset_diss'
            offset_diss = varargin{i+1};
            i=i+1 ;
        case 'offset_rp'
            offset_rp = varargin{i+1};
            i=i+1 ;
        case 'offset_wt'
            offset_wt = varargin{i+1};
            i=i+1 ;
        case 'convergence'
            convergence = varargin{i+1};
            i=i+1 ;
        otherwise
            error('findsegments_1: Unknown argument %s given',varargin{i});
    end
    i=i+1 ;
end
segStartAdjustSamnples = segStartAdjust / dtperelement ; % get in samples

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
    bmsigmono(fname, nFilt, minCochFreq, maxCochFreq, 100, 'gamma', N_erbs) ;

MAXSEGMENTS = 1000 ; % maximal permissabkle number of segments

% calculate oosignal for each band: the second version gives the same result and is more efficient
% initialise oosignal
oosignal = zeros(size(bmSig)) ;
for band = 1:nFilt
    % first rectify the band from tne basilar membrane signal, then smooth
    % it with the bartlett window, then convolve it with the half
    % difference of Gaussians
    oosignal(band,:) = conv(conv(abs(bmSig(band,:)),bartlettwindow, 'same'), hdog, 'same') ;
end

% code below generates a single oosignal_final. This time we want to
% process the channel oosignals independently
% % does the order make any difference (shouldn't)
% bmSigRect = abs(bmSig) ;
% bmSigTotRect = sum(bmSigRect,1) ;
% oosignal_final = conv(conv(bmSigTotRect,bartlettwindow, 'same'), hdog, 'same') ;

onset_signal = abs(max(0,oosignal)) ; % onset signal, positive or 0, 1 per band
offset_signal = abs(max(0, -oosignal)) ; % offset signal, positive or 0, 1 per band
if logonset % logarithmic adjustment?
    onset_signal = log(1 + onset_signal) ;
    offset_signal = log(1 + offset_signal) ;
end
% find spikes caused by onset signal:
% calculate inputs to LIF array (convergence paramater)
onset_wide = onset_signal ; % initialise
for j = 1:nFilt
    for k = 1:convergence
        if (j-k > 0)
            onset_wide(j,:) =  onset_wide(j,:) +  onset_signal(j-k,:) ;
        end
        if (j+k <=nFilt)
            onset_wide(j,:) =  onset_wide(j,:) +  onset_signal(j+k,:) ;
        end
    end
end
% apply LIF array and get out onset spike times. Note that weight to onset
% is normalised to allow for convergence
onset_times = iandfneurons(onset_wide * (onset_wt/(2*convergence + 1)), fs, ...
        1, onset_diss, onset_rp, 0); % rrp isn't used

% find spikes caused by offset signal:
% calculate inputs to LIF array (convergence paramater)
offset_wide = offset_signal ;
for j = 1:nFilt
    for k = 1:convergence
        if (j-k > 0)
            offset_wide(j,:) =  offset_wide(j,:) +  offset_signal(j-k,:) ;
        end
        if (j+k <= nFilt)
            offset_wide(j,:) =  offset_wide(j,:) +  offset_signal(j+k,:) ;
        end
    end
end
% apply LIF array and get out offset spike times.  Note that weight to
% offset
% is normalised to allow for convergence
offset_times = iandfneurons(offset_wide * (offset_wt/(2*convergence + 1)), fs, ...
        1, offset_diss, offset_rp, 0); % rrp isn't used

% now segment the signal using the onset and offset spikes.
% create summaries of onset and ofset spikes
% overall length of the signals is datalength * fs
% use summarysteplength steps for whole length of signal
% initialise arrays
onsetsummary = zeros(1, ceil(datalength / (summarysteplength*fs))) ;
offsetsummary = zeros(1, ceil(datalength / (summarysteplength*fs))) ;
summarylength = length(onsetsummary) ;
% fill arrays
summaryintegratesteps = ceil(summaryintegratelength/summarysteplength) ;
presum = floor(summaryintegratesteps / 2) ;
postsum = summaryintegratesteps - presum ; % so pre + post = summaryintegratesteps
for oi = 1:size(onset_times, 1) % for each onset spike
    onsetsummary(max(1, ceil(onset_times(oi,2)/summarysteplength) - presum):min(summarylength, ceil(onset_times(oi,2)/summarysteplength) + postsum)) = ...
       onsetsummary(max(1, ceil(onset_times(oi,2)/summarysteplength) - presum):min(summarylength, ceil(onset_times(oi,2)/summarysteplength) + postsum)) + 1 ;
end
for oi = 1:size(offset_times, 1) % for each offset spike
    offsetsummary(max(1, ceil(offset_times(oi,2)/summarysteplength) - presum):min(summarylength, ceil(offset_times(oi,2)/summarysteplength) + postsum)) = ...
       offsetsummary(max(1, ceil(offset_times(oi,2)/summarysteplength) - presum):min(summarylength, ceil(offset_times(oi,2)/summarysteplength) + postsum)) + 1 ;
end



allsegments = segments(1:segno - 1,:) ;

if (segno == 1)
    % no segments found
    disp(['findsegments_1: ' fname ' no segments found']) ;
    segments = [] ;
else
    % remove segments less that minseglength if one exists.
    outsegnumber = 1 ;
    maxseglength = 0 ;
    if minseglength > 0 % if 0 there's no minimum
        for insegnumber = 1:segno - 1
            seglength = (allsegments(insegnumber, 2) - allsegments(insegnumber, 1)) ;
            % find maximally long segment
            if (seglength > maxseglength)
                maxseglength = seglength ;
                maxsegindex = insegnumber ;
            end
            % keep segments greater than maximal length
            if (allsegments(insegnumber, 2) - allsegments(insegnumber, 1)) > minseglength
                % keep segment
                segments(outsegnumber, :) = allsegments(insegnumber, :) ;
                outsegnumber = outsegnumber + 1 ;
            end % if
        end % for
        if outsegnumber == 1 % no segments are long enough: use the longest actual one:
            % can use this to keep only longest segment by making minseglength large
            segments(1,:) = allsegments(maxsegindex,:) ;
            segments = segments(1,:) ;
        else
            segments= segments(1:outsegnumber - 1,:) ;
        end
        
    else % no minimum length
        segments = allsegments ;
    end
end
end


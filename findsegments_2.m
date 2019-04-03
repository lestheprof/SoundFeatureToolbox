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
threshold = 0.04 ;
G_quiet = 0.05 ;
k_minimin = 0.4 ; % not used just yet...
segStartAdjust = 0.05 ; % allows adjusting back the time of a segment start to ZX before peak
%
minseglength = 0 ; % minimum segment length

% new parameters for LIF based onset and offset
onset_diss = 100 ; % dissipation for onset neurons
onset_rp = 0.05 ; % refractory period for onset cells
onset_wt = 40.0 ; % onset weight
offset_diss = 100 ; % dissipation for offset neurons
offset_rp = 0.05 ; % refractory period for onset cells
offset_wt = 40.0 ; % offset weight
convergence = 4 ; % convergence (no of inputs to each neuron = 2*convergence + 1)



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

% probably good to do this by supplying a function with threshold, G_quiet and K_minmin
% (see 1994 JNMR paper)
[peakvalues, peaks]  = findpeaks([0 oosignal_final]) ; % added 0 to allow for starting at high level.
peaks = peaks - 1 ; % adjust for added 0
[minvalues, minima] = findpeaks(-oosignal_final) ;
peaktimes = peaks * dtperelement ; % from samples to seconds
mintimes = minima * dtperelement  ;
% now segment
segno = 1 ;
peakno = 1 ;
minno = 1 ;
peakno_1 = peakno ;
segments = zeros([MAXSEGMENTS, 2]) ;
segment_finished = false ;
while (peakno  <= length(peaktimes))
    if (peakvalues(peakno) > threshold)
        % valid peak start
        segments(segno,1) = peaktimes(peakno) ;
        segstartpeak_sample = peaks(peakno) ; % record for use in later adjustmsegmentent
        while ((minno < length(mintimes)) && (mintimes(minno) <= peaktimes(peakno)))
            minno = minno + 1 ;
        end
        % mintimes(minno) is 1st estimate of segment end
        segments(segno, 2) = mintimes(minno) ;
        % where would next segment start?
        segment_finished = false ;
        peakno_1 = peakno ;
        minno_1 = minno ;
        while (~segment_finished)
            while ((peakno_1 < length(peaktimes)) && (peaktimes(peakno_1) <= segments(segno, 2)) ...
                    && (peakvalues(peakno_1) > threshold))
                peakno_1 = peakno_1 + 1 ; % step forward to start of next segment
            end
            if (peakno_1 > length(peaktimes))
                % we've hit the end of the sound
                % segments(segno, 2) = mintimes(minno_1 - 1) ;
                segment_finished = true ;
                peakno = peakno_1 ;
                minno = minno_1 ;
                segno = segno + 1 ;
            else
                % find segment end
                while ((minno_1 < length(mintimes)) && (mintimes(minno_1) <= peaktimes(peakno_1)))
                    minno_1 = minno_1 + 1 ;
                end
                if ((minno_1 >= length(mintimes)) && (mintimes(minno_1) <= segments(segno,1)))
                    % invalid segment
                    disp('findsegments_1: invalid segment') ;
                else
                    % accept only if time between end of initial segment estimate and
                    % this new start < G_quiet
                    if ((peaktimes(peakno_1) - segments(segno, 2)) <= G_quiet)
                        segments(segno, 2) = mintimes(minno_1) ;
                    else
                        segment_finished = true ;
                        peakno = peakno_1 ;
                        minno = minno_1 ;
                        segno = segno + 1 ;
                    end
                    if ((peakno_1 > length(peaktimes)) || (minno_1 > length(mintimes)))
                        % we've hit the end of the sound
                        segments(segno, 2) = mintimes(minno_1 - 1) ;
                        segment_finished = true ;
                        peakno = peakno_1 ;
                        minno = minno_1 ;
                        segno = segno + 1 ;
                    end
                    peakno_1 = peakno_1 + 1 ;
                end
            end
            
        end
        
    else
        peakno = peakno + 1 ;
    end
    if (segment_finished)
        % segment (segno - 1) found
        % backtrack from start of segment to previous zx
        newstartpoint = segstartpeak_sample ;
        while ((newstartpoint > 0) && (oosignal_final(newstartpoint) > 0))
            newstartpoint = newstartpoint - 1 ;
        end
        % is it within a reasonable time since the peak?
        if ((segstartpeak_sample - newstartpoint) < segStartAdjustSamnples)
            segments(segno-1, 1) = (newstartpoint * dtperelement) ;
        end
    end
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


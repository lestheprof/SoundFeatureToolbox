function [nFiles] = findsegments_all_2(soundDirectory,soundFileList, outputDirectory, varargin)
%findsegments_all creates the segments for all the files in
%soundDirectory named in soundFileList
%   calls findsegments_1.m repeatedly to create the segments. places the
%   output segments in outputDirectory/<filename>.segs one for each file
%
% LSS 24 OCTOBER 2018 

%parameters for calls to findsegments_1.m default to below values,
%overwritable using varargin. 
nullsegments = 0 ; % false ;
sigma1 = 0.02 ;
sigmaratio = 1.2 ;
fs = 44100 ; % adjust if required
dtperelement = 1.0/fs ;
nsamples = 4000 ;
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
K_minmin = 0.4 ; % not used just yet...
segStartAdjust = 0.05 ; % allows adjusting back the time of a segment start to ZX before peak
minseglength = 0 ;

% new parameters for LIF based onset and offset
onset_diss = 100 ; % dissipation for onset neurons
onset_rp = 0.05 ; % refractory period for onset cells
onset_wt = 40.0 ; % onset weight
offset_diss = 100 ; % dissipation for offset neurons
offset_rp = 0.05 ; % refractory period for onset cells
offset_wt = 40.0 ; % offset weight
convergence = 4 ; % convergence (no of inputs to each neuron = 2*convergence + 1)

filesuffix = '' ; % used for identifying this particular run

i = 1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'nullsegments'
            nullsegments = varargin{i+1};
            i=i+1 ;
        case 'sigma1'
            sigma1 = varargin{i+1};
            i=i+1 ;
        case 'sigmaratio'
            sigmaratio = varargin{i+1};
            i=i+1 ;
        case 'nsamples'
            nsamples = varargin{i+1};
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
        case 'logonset'
            logonset = varargin{i+1};
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
        case 'filesuffix'
            filesuffix = varargin{i+1};
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
    end % switch
    i=i+1 ;
end %while

% read input_filelist to get the list of files to be processed
inputfid = fopen([soundDirectory '/' soundFileList]) ;
fline = fgetl(inputfid) ;
nooffiles = 1 ;
while (ischar(fline) && (length(fline) > 0))
    filelist{nooffiles} = fline ;
    fline = fgetl(inputfid) ;
    nooffiles = nooffiles + 1 ;
end
nooffiles = nooffiles - 1 ;
fclose(inputfid) ;

% create output directory if required
if (~(exist(outputDirectory, 'dir') == 7))
    % create folder
    mkdir(outputDirectory) ;
end
% process each file, one by one
for i = 1:nooffiles
    filenameroot =  strsplit(filelist{i}, '.') ;
    if (nullsegments > 0)
        % open file
        [ y, fs] = audioread([soundDirectory '/' filelist{i} ]) ;
        % find length and creata single segment
        segments = [(1/fs)  (length(y)/fs)] ;
    else
        
        % call below needs all varargin parameters set
        [segments] = findsegments_2([soundDirectory '/' filelist{i} ],sigma1, sigmaratio, dtperelement, nsamples,...
            'mincochfreq',minCochFreq, 'maxcochfreq', maxCochFreq, 'n_erbs', N_erbs, 'nfilt',  nFilt, ...
            'smoothlength', smoothlength, 'threshold', threshold , 'g_quiet', G_quiet, 'k_minmin', K_minmin, ...
            'segstartadjust',  segStartAdjust, 'minseglength', minseglength, 'onset_diss', onset_diss, ...
            'onset_rp', onset_rp,'onset_wt', onset_wt,  'offset_diss', offset_diss, 'offset_rp', offset_rp, ...
            'offset_wt', offset_wt, 'convergence', convergence, 'logonset', logonset) ;
        % set up params structure for saving
        params.sigma1 = sigma1 ;
        params.sigmaratio = sigmaratio ;
        params.dtperelement = dtperelement ;
        params.nsamples = nsamples;
        params.minCochFreq = minCochFreq ;
        params.maxcochfreq = maxcochfreq ;
        params.n_erbs = N_erbs ;
        params.nfilt = nFilt ;
        params.smoothlength = smoothlength ;
        params.threshold = threshold ;
        params.g_quiet = G_quiet ;
        params.k_minmin = K_minmin ;
        params.segstartadjust = segStartAdjust ;
        params.minseglength = minseglength ;
        params.onset_diss = onset_diss ;
        params.logonset = logonset ; 
        params.date = date() ;
        
        
    end
    save([outputDirectory '/' [filenameroot{1} filesuffix] '_segs.mat'], 'segments', 'params') ;
end % for

nFiles = nooffiles ; % return number of files processed

end % function



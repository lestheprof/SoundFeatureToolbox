function [nFiles] = findsegments_all(soundDirectory,soundFileList, outputDirectory, varargin)
%findsegments_all creates the segments for all the files in
%soundDirectory named in soundFileList
%   calls findsegments_1.m repeatedly to create the segments. places the
%   output segments in outputDirectory/<filename>.segs one for each file

%parameters for calls to findsegments_1.m default to below values,
%overwritable using varargin. 
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
        otherwise
            error('findsegments_1: Unknown argument %s given',varargin{i});
    end % switch
    i=i+1 ;
end %while

% read input_filelist to get the list of files to be processed
inputfid = fopen(soundFileList) ;
fline = fgetl(inputfid) ;
nooffiles = 1 ;
while ischar(fline)
    filelist{nooffiles} = fline ;
    fline = fgetl(inputfid) ;
    nooffiles = nooffiles + 1 ;
end
nooffiles = nooffiles - 1 ;

% process each file, one by one
for i = 1:nooffiles
   filenameroot =  strsplit(filelist{i}, '.') ;
   [segments] = findsegments_1([soundDirectory '/' filelist{i} ],sigma1, sigmaratio, dtperelement, nsamples, varargin) ;
   save([outputDirectory '/' filenameroot '.segs'], 'segments') ;
end % for

end % function



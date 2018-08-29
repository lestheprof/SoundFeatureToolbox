function noofexperiments = generategaboroutputs_mono(stimulibasedir, experimentname,dirname, ...
    input_filelist, ANSigDir, outputDir, gaborparams, resamplerate, display, varargin)
% generategaboroutputs_mono: creates a matrix of level 1 features from the
% files named in input_filelist in the directory onsetSigDir, placing the
% results in outputDir (created if required). This one uses the Gabor
% filters, and the parameters for the filter are provided in the structure
% gaborparams
%
% gaborparams has the following fields:
% bandwidth:
% lambda: inter-peak interval (at resample_gabor sampling rate) in samples
% gamma: aspect ratio - will be very different depending on orientation of
% filter
% theta: orientation: pi/2 for amplitude modulation, 0 for harmonics!
%
% started LSS 13 2 2014
%
% read varargin paramaters 
% if zeromean is 1 then filters will have mean 0
zeromean = 0 ;
% gamma used is set so that the width should be constant, as set for bwmin.
% internal sampling rate for Gabor computation
resample_gabor = 2000 ;
szxvalue = 13 ;
szyvalue = 0 ;
verbose = 0 ;
i=1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'resample_gabor';
            resample_gabor=varargin{i+1};
            i=i+2;
        case 'zeromean'
            zeromean = varargin{i+1};
            i=i+2;
        case 'szxvalue';
            szxvalue=varargin{i+1};
            i=i+2;
        case 'szyvalue'
            szyvalue =varargin{i+1};
            i=i+2;
        case 'verbose'
            verbose=varargin{i+1};
            i=i+2;
        otherwise
            error('generategaboroutputs_mono: Unknown argument %s given',varargin{i});
            %             case 'SaveAN' % save the AN spikes as well: default is don't
            %                 savean = varargin{i+1};  % saving of AN spikes as well
    end
end

% read input_filelist to get the list of files to be processed
inputfid = fopen([stimulibasedir  experimentname '/' dirname '/' input_filelist]) ;
fline = fgetl(inputfid) ;
noofexperiments = 1 ;
while ischar(fline)
    filelist{noofexperiments} = fline ;
    fline = fgetl(inputfid) ;
    noofexperiments = noofexperiments + 1 ;
end
noofexperiments = noofexperiments - 1 ;
if (noofexperiments == 0)
    error('No files to be processed') ;
end
% list of files to be processed in in cell array filelist, with the number
% of files in noofexperiments

for j=1:noofexperiments
    if verbose
    % display experiment info
        disp([filelist{j} ' generating gabor outputs running']) ;
    end
    
    % split the file name stem from ths suffix
    % will not work if there's more than 2 '.' characters in filename
    fileparts = strsplit(filelist{j}, '.') ;
    numstrings = length(fileparts) ;
    if numstrings == 3
        startpart = [fileparts{1} '.' fileparts{2}] ;
        % suffix = fileparts{3} ;
    else
        startpart = fileparts{1} ;
        % suffix = fileparts{2} ;
    end
    % filestem = [startpart '.'] ; % filestem includes the .
    
    
    % read in the AN Signal structure for this experiment
    z1 = load([stimulibasedir experimentname  dirname '/' ANSigDir '/' startpart '_ANSig.mat']) ;
    % temporary fix: some versions of ANSigDir do not have a separate
    % ANParams field
    if (~isfield(z1.AN, 'ANParams'))
        % create the field
        z1.AN.ANParams.datesStr = z1.AN.dateStr ;
        z1.AN.ANParams.soundlength = z1.AN.soundlength ;
        z1.AN.ANParams.signlevel = z1.AN.siglevel ;
        z1.AN.ANParams.fmin = z1.AN.fmin ;
        z1.AN.ANParams.fmax = z1.AN.fmax ;
        z1.AN.ANParams.channels = z1.AN.channels ;
        z1.AN.ANParams.N_erbs = z1.AN.N_erbs ;
        z1.AN.ANParams.minlevel_zc = z1.AN.minlevel_zc ;
        z1.AN.ANParams.multiplier = z1.AN.multiplier ;
        z1.AN.ANParams.filtertype = z1.AN.filtertype ;
        z1.AN.ANParams.cf = z1.AN.cf ;
        z1.AN.ANParams.Fs = z1.AN.Fs ;
        z1.AN.ANParams.datalength = z1.AN.datalength ;
        z1.AN.ANParams.experiment = z1.AN.experiment ;
    end
    % for this work, type = 3: that is, use the spikes directly (log
    % intensity), and generate absolute values
    type = 3 ;
    %  Just run with a single value of lambda
    gaboroutput = runmultigabors(gaborparams.bandwidth, gaborparams.lambda, 1, gaborparams.lambda ,  gaborparams.gamma ,...
        gaborparams.theta, z1.AN, type, display, 'resample_final', resamplerate, 'zeromean', zeromean,...
        'szxvalue' , szxvalue, 'resample_gabor', resample_gabor, 'szyvalue', szyvalue ) ;
    % to create it
    gaborparams.resamplerate = resamplerate ;
    gaborparams.resample_gabor = resample_gabor ;
    gaborparams.szxvalue = szxvalue ; 
    gaborparams.szyvalue = szyvalue ; 

    if ~exist([stimulibasedir  experimentname  dirname '/' outputDir], 'dir')
        % create directory
        mkdir([stimulibasedir  experimentname  dirname '/' outputDir]) ;
    end
    ANParams = z1.AN.ANParams; % note thatb this contains the AN signal istself
    save([stimulibasedir experimentname  dirname '/' outputDir '/' startpart ...
        '_gaboroutputs.mat'], 'gaboroutput',  'ANParams', 'gaborparams') ;
    
    
end % experiment loop
end %

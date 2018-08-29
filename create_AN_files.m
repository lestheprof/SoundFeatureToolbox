function [ noofexperiments ] = create_AN_files(stimulibasedir, experimentname,dirname, input_filelist, store_bmSig, ...
    bmSigdir, ANSigdir, varargin)
%create_AN_files Creates a single "spike train" from a sound file. The
%output is a single structure, AN, which is saved to a file. The element
%AN.signal contains a number of cell elements each of whihc is a 2 by N
%arrat, with the 1st element being the sample number of the spike, and the
%2nd element being the sensitivity level of the spike.
%
%   Reads in a list of files, 
%   For each file, calls the gammatone filterbank (if store_bmSig <= 1, or 
%   reads it from a file if store_bmSig == 2) and 
%   then generates the
%   AN spike train (using Gabriel's software, because I think it's faster),
%   and saves this in a file with the appropriate name.
%
% LSS 17 5 2013 
%
% bug fix 20 feb 2015 lss.
%
% get parameters from parameter file
paramfilelocation = stimulibasedir ;
i=1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        
        case 'paramfilelocation'
            paramfilelocation = varargin{i+1}; 
            i=i+1 ;
        otherwise
            error('generateTimitFileList: Unknown argument %s given',varargin{i});
    end
    i=i+1 ;
end
if exist([paramfilelocation  experimentname  dirname '/' 'parameters_monoonset.mat'], ...
        'file')
    % read the file
    load([paramfilelocation  experimentname  dirname  '/' 'parameters_monoonset.mat']) ;
    soundlength = AN.soundlength ;
    siglevel = AN.siglevel ;
    fmin = AN.fmin ;
    fmax = AN.fmax ;
    channels = AN.channels ;
    minlevel_zc = AN.minlevel_zc ;
    multiplier = AN.multiplier ;
    iterations = AN.iterations ;
    N_erbs = AN.N_erbs ;
else
    error('No parameter (parameters_moonsets) file found. Stopping') ;
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
fclose(inputfid) ;
noofexperiments = noofexperiments - 1 ;
if (noofexperiments == 0)
    error('No files to be processed') ;
end
% list of files to be processed in in cell array filelist, with the number
% of files in noofexperiments


% first create the signals, or read them from file if appropriate.
for j=1:noofexperiments % for each sound file
        disp([filelist{j} ' in create_AN_files'] ) ;
        
    % split the file name stem from ths suffix
    % will not work if there's more than 2 '.' characters in filename
    fileparts = strsplit(filelist{j}, '.') ; 
    numstrings = length(fileparts) ;
    if numstrings == 3
        startpart = [fileparts{1} '.' fileparts{2}] ;
        suffix = fileparts{3} ;
    else
        startpart = fileparts{1} ;
        suffix = fileparts{2} ;
    end
    filestem = [startpart '.'] ; % filestem includes the .


        % generate the multichannel dataset
    if (store_bmSig <= 1)
    [bmSig, sig, fs, datalength, cochCFs, delayVector] = ...
        bmsigmono([stimulibasedir  experimentname  dirname '/'  filestem  suffix], ...
        channels , fmin,fmax, soundlength, AN.filtertype, N_erbs);
    end
    if (store_bmSig == 1)
        % we need to save the bmSig matrix, for later re-use
        if ~exist([stimulibasedir  experimentname  dirname '/' bmSigdir], 'dir')
            % create directory
            mkdir([stimulibasedir  experimentname  dirname '/' bmSigdir]) ;
        end
        save([stimulibasedir  experimentname  dirname '/' bmSigdir '/' filestem '_bmSig'],...
            'bmSig', 'sig', 'fs', 'datalength', 'cochCFs', 'delayVector') ;
    end
    if (store_bmSig == 2)
        % load the bmSig matrix from the file
        load([stimulibasedir  experimentname  dirname '/' bmSigdir '/' filestem '_bmSig'],'-mat' ) ;
        % shrink bmSig if required (let the specified soundlength over-ride 
        % the data lengtyh in the loaded bmSig 
        bmSig = squeeze(bmSig) ; % added in case stored version is 1 by N by length
        [  ~, nsamples] = size(bmSig) ;
        if nsamples > (soundlength * fs)
            bmSig = bmSig( :, 1 : int32(soundlength * fs)) ;
            datalength = int32(soundlength * fs) ;
        end
            
    end
    
    % now generate the AN Spike train
    AN.cf = cochCFs ;
    AN.Fs = fs ;
    % added 28 Jan 2014: cope with a stereo bmsig - added squeeze.
    AN.signal = AN_coder_GRM(squeeze(bmSig),AN) ;
    AN.datalength = datalength ;
    AN.experiment = filelist{j} ;
   if (~isfield(AN, 'ANParams'))
        % create the field
        AN.ANParams.datesStr = AN.dateStr ;
        AN.ANParams.soundlength = AN.soundlength ;
        AN.ANParams.signlevel = AN.siglevel ;
        AN.ANParams.fmin = AN.fmin ;
        AN.ANParams.fmax = AN.fmax ;
        AN.ANParams.channels = AN.channels ;
        AN.ANParams.N_erbs = AN.N_erbs ;
        AN.ANParams.minlevel_zc = AN.minlevel_zc ;
        AN.ANParams.multiplier = AN.multiplier ;
        AN.ANParams.filtertype = AN.filtertype ;
        AN.ANParams.cf = AN.cf ;
        AN.ANParams.Fs = AN.Fs ;
        AN.ANParams.datalength = AN.datalength ;
        AN.ANParams.experiment = AN.experiment ;
    else
       % Changed, 20 Feb 2015. Even if ANParams exists, some fields need updated
       AN.ANParams.datalength = AN.datalength ;
       AN.ANParams.experiment = AN.experiment ;
    end
    % now save this output
    if ~exist([stimulibasedir  experimentname  dirname '/' ANSigdir], 'dir')
            % create directory
            mkdir([stimulibasedir  experimentname  dirname '/' ANSigdir]) ;
    end
    % save it in a file that has .mat at the end
    save([stimulibasedir  experimentname  dirname '/' ANSigdir '/' startpart '_ANSig' '.mat'],...
            'AN') ;
end


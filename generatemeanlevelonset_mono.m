function noofexperiments = generatemeanlevelonset_mono(stimulibasedir, experimentname,dirname, ...
    input_filelist, onsetSigDir, outputDir, resamplerate, display, varargin)
% generatemeanlevelonset_mono: creates a matrix of level 1 features from the
% files named in input_filelist in the directory onsetSigDir, placing the
% results in outputDir (created if required).
%
%
% started LSS 13 2 2014
%
% read varargin paramaters (none yet!)
i=1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        otherwise
            error('generatemeanlevelonset_mono: Unknown argument %s given',varargin{i});
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
    % display experiment info
    disp([filelist{j} ' mean level onset running']) ;
    
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
    
    
    % read in the onset structure for this experiment
    z1 = load([stimulibasedir experimentname  dirname '/' onsetSigDir '/' startpart '_onset.mat']) ;
    
    if (~isfield(z1.ANparams, 'ANParams'))
        % create the field
        z1.ANparams.ANParams.datesStr = z1.ANparams.dateStr ;
        z1.ANparams.ANParams.soundlength = z1.ANparams.soundlength ;
        z1.ANparams.ANParams.signlevel = z1.ANparams.siglevel ;
        z1.ANparams.ANParams.fmin = z1.ANparams.fmin ;
        z1.ANparams.ANParams.fmax = z1.ANparams.fmax ;
        z1.ANparams.ANParams.channels = z1.ANparams.channels ;
        z1.ANparams.ANParams.N_erbs = z1.ANparams.N_erbs ;
        z1.ANparams.ANParams.minlevel_zc = z1.ANparams.minlevel_zc ;
        z1.ANparams.ANParams.multiplier = z1.ANparams.multiplier ;
        z1.ANparams.ANParams.filtertype = z1.ANparams.filtertype ;
        z1.ANparams.ANParams.cf = z1.ANparams.cf ;
        z1.ANparams.ANParams.Fs = z1.ANparams.Fs ;
        z1.ANparams.ANParams.datalength = z1.ANparams.datalength ;
        z1.ANparams.ANParams.experiment = z1.ANparams.experiment ;
    end
    mlo = meanlevelonset(resamplerate, z1, display ) ; % calculate the mean level onset
    % save the mean level ounset output, along with the parametersets used
    % to create it
    mloparams.resamplerate = resamplerate ;
    if ~exist([stimulibasedir  experimentname  dirname '/' outputDir], 'dir')
        % create directory
        mkdir([stimulibasedir  experimentname  dirname '/' outputDir]) ;
    end
    onsetparams = z1.onsetparams ;
    ANParams = z1.ANparams.ANParams; % note that this contains the AN signal itself.
    save([stimulibasedir experimentname  dirname '/' outputDir '/' startpart ...
        '_onsetmeans.mat'], 'mlo', 'onsetparams', 'ANParams', 'mloparams') ;
    
    
end % experiment loop
end %

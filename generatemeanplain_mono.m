function noofexperiments = generatemeanplain_mono(stimulibasedir, experimentname,dirname, ...
    input_filelist, ANSigDir, outputDir, resamplerate, display, varargin)
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
fclose(inputfid) ;
noofexperiments = noofexperiments - 1 ;
if (noofexperiments == 0)
    error('No files to be processed') ;
end
% list of files to be processed in in cell array filelist, with the number
% of files in noofexperiments

for j=1:noofexperiments
    % display experiment info
    disp([filelist{j} ' mean level (plain) running']) ;
    
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
    z1 = load([stimulibasedir experimentname  dirname '/' ANSigDir '/' startpart '_ansig.mat']) ;
    
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
    type = 1 ; % use theAN spikes direclty: log intensity.
    mlm = runmultimeans(resamplerate, z1.AN, type, display ); % calculate the mean level (plain)
    % save the mean level ounset output, along with the parametersets used
    % to create it
    mlmparams.resamplerate = resamplerate ;
    if ~exist([stimulibasedir  experimentname  dirname '/' outputDir], 'dir')
        % create directory
        mkdir([stimulibasedir  experimentname  dirname '/' outputDir]) ;
    end
    ANParams = z1.AN.ANParams; % note that this contains the AN signal itself.
    save([stimulibasedir experimentname  dirname '/' outputDir '/' startpart ...
        '_plainmeans.mat'], 'mlm',  'ANParams', 'mlmparams') ;
    
    
end % experiment loop
end %

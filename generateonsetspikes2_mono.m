function generateonsetspikes2_mono(stimulibasedir, experimentname,dirname, input_filelist, anSigDir, onsetSigDir, display, varargin)
% New version, started 12 Nov 2002
%
% modified to process new "wide" onsetside_zc7 7 3 2003 LSS
% modified 3 12 2005: added intervalepsilon to setparameters_mono_timit
% to allow onset interval
% computation. Also put in delay compensation, so that stored onsets are
% delay compensated
%
% this one reads in the AN files generated using generateANsignals.m
% and produces the onset spike files. It uses genonsetspikes1_mono, which
% in turn uses a depressing synapse and a LIF neuron. It also calculates
% the overall onset interval, using overallonset, and stores the results in
% a file
%
%updated to read the more compact AN files created by Gabriel in Edinburgh.
%

if nargin < 7
    display = 0 ;
end
savean = 0 ; % default is don't save AN spikes
delaycompensate = 0 ; % default is no delay compensation
paramfilelocation = stimulibasedir; % default location of the parameters file

i=1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        
        case 'savean' % save the AN spikes as well: default is don't
            savean = varargin{i+1};  % saving of AN spikes as well
        case 'delaycompensate'
            delaycompensate = varargin{i+1}; % delay compensation
        case 'paramfilelocation'
            paramfilelocation = varargin{i+1};
        otherwise
            error('generateonsetspikes2_mono: Unknown argument %s given',varargin{i});
    end
    i=i+2 ;
end


% heaps of parameters

store_onsetspikes = 1 ; % store the onset spikes

% get parameters from parameter file
if exist([paramfilelocation  experimentname  dirname '/' 'parameters_monoonset.mat'])
    % read the file
    load([paramfilelocation  experimentname  dirname '/' 'parameters_monoonset.mat']) ;

else
    error(['No parameters file (parameters_monoonset.mat) found. Stopping'] ) ;

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
    disp([filelist{j} ' onset spikes running']) ;
    % cochlear filtering and AN generation already done.
    
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
    % filestem = [startpart '.'] ; % filestem includes the .
    
    
    % read in the AN structure for this experiment
    z1 = load([stimulibasedir experimentname  dirname '/' anSigDir '/' startpart '_ANSig.mat']) ;
    cochCFs = z1.AN.cf ;
    noCochFilt = z1.AN.channels ;
    datalength = z1.AN.datalength ;
    fs = z1.AN.Fs ;


    % uses exactly 1 onset cell/band, whereas plain uses 1 per AN fibre
    [leftan,  leftonset_wide] = ...
        genonsetspikes2_mono(z1.AN, onset) ;

    if delaycompensate
        % adjust onset spikes for filterbank delay
        delayvector = z1.AN.delayVector ;

        for i_sens=1:length(leftonset_wide)
            [listlength, temp] = size(leftonset_wide(i_sens).list) ; % Never use length on a >1 dimensional array!!!
            for i_onset = 1:listlength
                leftonset_wide(i_sens).list(i_onset,2) = leftonset_wide(i_sens).list(i_onset,2) ...
                    - delayvector(leftonset_wide(i_sens).list(i_onset,1)) ;
            end
        end
    end

    % nerve spike generation

    [intervals, Nusedininteerval] = overallonset(leftonset_wide, noCochFilt, onset.sensitivitygap, onset.intervalgap,display) ;
    % intervals = overallonset(leftonset_wide, 0.005, onset.intervalgap) ;
    if (display==1)
        % display  results for onsets only
        % find out how many of the lists in leftonset_wide are null
        left = 0 ; right = 0 ;
        leftcontent = zeros([1 AN.iterations]) ; % preallocate
        for k = 1:AN.iterations
            if ~(isempty(leftonset_wide(k).list) )
                leftcontent(k) = 1 ;
                left = left + 1 ;
            else
                leftcontent(k) = 0 ;
            end
        end
        figure('Name', [ filelist{j} ':  onsets'])  ;

        plotadjust = 0 ;

        for k=1:AN.iterations
            if leftcontent(k) == 1
                subplot(left,1,left - k  + 1) ;
                if k > 1
                    spikeraster(leftonset_wide(k).list,'Range',1:noCochFilt, 'EndTime',double(datalength)/fs, ...
                        'Annotate', num2str(k))
                    set(gca,'XTickLabel',{' ',' ',' ',' ',' ', ' ',' ',' ',' ',' '}) ;
                else
                    spikeraster(leftonset_wide(k).list,'Range',1:noCochFilt, 'EndTime',double(datalength)/fs, 'Xlabel', 'Left',...
                        'Annotate', num2str(k)) ;
                end
            else plotadjust = plotadjust + 1 ;
            end
        end



    end
    if (display==2)
        % display all results
        figure('Name', filelist{j}) ;
        subplot(4,1,1) ;
        spikeraster(leftan,'Range',1:noCochFilt, 'EndTime',double(datalength)/fs) ;
        subplot(4,1,2);
        spikeraster(rightan,'Range',1:noCochFilt, 'EndTime',double(datalength)/fs) ;
        %         subplot(6,1,3) ;
        %         spikeraster(leftonset,'Range',1:noCochFilt, 'EndTime',datalength/fs) ;
        subplot(4,1,3) ;
        spikeraster(leftonset_band,'Range',1:noCochFilt, 'EndTime',double(datalength)/fs) ;
        %         subplot(6,1,5);
        %         spikeraster(rightonset,'Range',1:noCochFilt, 'EndTime',datalength/fs) ;
        subplot(4,1,4);
        spikeraster(rightonset_band,'Range',1:noCochFilt, 'EndTime',double(datalength)/fs) ;
    end
    if (display==3)
        % display  results for onset_band only
        figure('Name', filelist{j})  ;
        subplot(2,1,1) ;

        spikeraster(leftonset_band,'Range',1:noCochFilt, 'EndTime',double(datalength)/fs) ;
        subplot(2,1,2);

        spikeraster(rightonset_band,'Range',1:noCochFilt, 'EndTime',double(datalength)/fs) ;
    end

    % always store the onset spikes?
    if (store_onsetspikes)
        % store the parameters   used to generate the AN spikes in the onset file as well
%         ANparams.fmin = z1.AN.fmin ;
%         ANparams.fmax = z1.AN.fmax ;
%         ANparams.channels = z1.AN.channels  ;
%         ANparams.siglevel=  z1.AN.siglevel  ;
%         ANparams.minlevel_zc = z1.AN.minlevel_zc   ;
%         ANparams.multiplier = z1.AN.multiplier   ;
%         ANparams.iterations = z1.AN.iterations   ;
%         ANparams.stimulibasedir = z1.AN.stimulibasedir   ;
%         ANparams.experimentname = z1.AN.experimentname   ;
%         ANparams.fs = z1.AN.fs   ;
%         ANparams.datalength = z1.AN.datalength   ;
%         ANparams.cochCFs = z1.AN.cf ;
%         ANparams.numchannels = z1.AN.numchannels   ;
%         % ANparams.delayvector = z1.AN.delayVector   ;
%         ANparams.experiment = z1.AN.experiment   ;
        ANparams = z1.AN ;
        ANparams.timestamp  = datestr(clock,0) ;
        onsetparams = onset ;
        onsetparams.timestamp = datestr(clock, 0) ; onsetparams.wide = 1 ;
        
        if ~exist([stimulibasedir  experimentname  dirname '/' onsetSigDir], 'dir')
        % create directory
            mkdir([stimulibasedir  experimentname  dirname '/' onsetSigDir]) ;
        end
        if savean

            save([stimulibasedir experimentname  dirname '/' onsetSigDir '/' startpart ...
            '_onset.mat'], 'leftan',  'leftonset_wide',  'intervals', 'Nusedininteerval', ...
            'onsetparams', 'ANparams') ;
        else
            save([stimulibasedir experimentname  dirname '/' onsetSigDir '/' startpart ...
            '_onset.mat'], 'leftonset_wide',  'intervals', 'Nusedininteerval', ...
            'onsetparams', 'ANparams') ;
        end


    end % 
end % experiment loop

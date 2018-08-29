function [ nfiles ] = type1_autocrosscorr(stimulibasedir, experimentname,dirname, input_filelist, store_bmSig, bmSigdir, Correlsigdir)
%type1_autocrosscorr After filtering with Gammatone if required, rectifies,
%adds1, logs, and calculates cross-correltation across channels. 
% 
%
%   Reads in a list of files,
%   For each file, calls the gammatone filterbank (if store_bmSig <= 1, or
%   reads it from a file if store_bmSig == 2) and (full-wave) rectifies signal
%   If smoothing is requested, it is performed using triangular
%   convolution, with either the same conveolver in each channel, or a
%   different conveolver in each channel.
% If resampling is required, this is performed (much reduces volume of
% data). Cross-correlation is performed across the different bands, with
% delays up to corrparam.maxdelay.
%
% LSS 17 5 2013 (description updated 27 June 2013)
%
% get parameters from parameter file
if exist([stimulibasedir  experimentname  dirname '/' 'parameters_monoonset.mat'], ...
        'file')
    % read the file
    load([stimulibasedir  experimentname  dirname  '/' 'parameters_monoonset.mat']) ;
    soundlength = AN.soundlength ;
    siglevel = AN.siglevel ;
    fmin = AN.fmin ;
    fmax = AN.fmax ;
    channels = AN.channels ;
    minlevel_zc = AN.minlevel_zc ;
    multiplier = AN. multiplier ;
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
noofexperiments = noofexperiments - 1 ;
if (noofexperiments == 0)
    error('No files to be processed') ;
end
% list of files to be processed in in cell array filelist, with the number
% of files in noofexperiments


% first create the signals, or read them from file if appropriate.
for j=1:noofexperiments % for each sound file
    disp([filelist{j} ' in type1_autocrosscorr'] ) ;
    
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
        [  ~, nsamples] = size(bmSig) ;
        if nsamples > (soundlength * fs)
            bmSig = bmSig( :, 1: int32(soundlength * fs)) ;
            datalength = int32(soundlength * fs) ;
        end
        
    end
    
    % now create a rectified and >1 signal for correlaton calculation
    AN.cf = cochCFs ;
    AN.Fs = fs ;
    bmSigPos = abs(bmSig) ; %+  ones(size(bmSig))  ; add this later
    % note that bmSig (and bmSigPos) is AN.channels by datalength
    % now smooth the dataset: aim is to avoid  issuesfrom actual signal
    % frequnecy
    clear bmSig ;
    if corrparam.smooth > 0
        % perform smoothing
        % do we smooth every channelin the same way, or do we apply a men
        % filter over a period proportional to the period of the centre
        % frequency iof the band?
        if corrparam.smoothtype == 1
            % calculate convolution element
            convolver = hamming(fix(corrparam.smooth * AN.Fs)) ; % was ones([ 1 fix(corr.smooth * AN.Fs)]) ;
            % normalise it
            convolver = convolver/sum(convolver) ;
            
            for ch = 1:AN.channels
                bmSigPos(ch, :) = conv(  bmSigPos(ch, :), convolver, 'same') ;
            end
        else if  corrparam.smoothtype == 2 % different convolver for each band
                for ch = 1:AN.channels
                    
                    convolver = hamming(fix(corrparam.smooth * AN.Fs * cochCFs(ch)/1000)) ;
                    % was ones([ 1 fix(corr.smooth * AN.Fs * cochCFs(ch)/1000)]) ;
                    convolver = convolver/sum(convolver) ;
                    
                    bmSigPos(ch, :) = conv(  bmSigPos(ch, :), convolver, 'same') ;
                end
            end
        end
    end
    bmSigPos = log2( bmSigPos + 1) ; % add one on and then take logs (base 2)
    if corrparam.repackage > 0
        % repackage
        remix = fix(corrparam.repackage * AN.Fs) ;
        newnumsamples = fix(datalength/remix) ; % number of samples in each new "sample"
        % allocate space for repackaged data
        smallBmSigPos = zeros([AN.channels, newnumsamples]) ;
        for ch  = 1:AN.channels
            for snoset = 1:newnumsamples
                smallBmSigPos(ch, snoset) = mean(bmSigPos(ch, (snoset - 1) * remix + 1: snoset * remix) ) ;
            end
        end
        n_timeslot = fix(corrparam.maxdelay/corrparam.repackage) ;
        % if this is being repackaged, we should also save the repackaged
        % array
        save([stimulibasedir  experimentname  dirname '/' bmSigdir '/' filestem '_smallBmSigPos'], 'smallBmSigPos', 'AN', 'corrparam') ;
    else
        smallBmSigPos = bmSigPos ; % no repackaging
        % how many timeslots?
        % n_timeslot = fix(corr.maxdelay/corr.mindelay) ;
        n_timeslot = fix(corrparam.maxdelay * AN.Fs) ;
    end
    %calculate auto and cross correlations
    clear bmSigPos ;
    % set up correlation 3d array to hold result (pre by post by delay)
    correlns = zeros([ AN.channels AN.channels n_timeslot + 2]) ;
    delay = 0 ; % start with 0 delay
    for pre = 1:AN.channels
        
        for post  = 1:AN.channels
            % calculate cross/aurocorrelation between pre and post
            % channels with delay
            % thiscorrel = xcorr(smallBmSigPos(pre,:), smallBmSigPos(post,:), n_timeslot, 'coeff') ;
            thiscorrel = xcorr(smallBmSigPos(pre,:), smallBmSigPos(post,:), n_timeslot) ;
            
            correlns(pre, post, :) = thiscorrel(n_timeslot:end) ;
        end
    end
    
    
    %     AN.signal = AN_coder_GRM(bmSig,AN) ;
    %     % now save this output
    if ~exist([stimulibasedir  experimentname  dirname '/' Correlsigdir], 'dir')
        % create directory
        mkdir([stimulibasedir  experimentname  dirname '/' Correlsigdir]) ;
    end
    %     % save it in a file that has .mat at the end
    % save the corrparams too
    save([stimulibasedir  experimentname  dirname '/' Correlsigdir '/' startpart '_CorrelSig' '.mat'],...
        'correlns', 'AN', 'corrparam') ;
end
nfiles = noofexperiments ;
end


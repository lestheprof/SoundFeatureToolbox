function [ noofexperiments ] = generatesegments( stimulibasedir, experimentname,dirname, input_filelist,...
    OnsetSigdir, ANMatrixDir, OnsetMatrixDir,GaborMatrixDirSet, OutputDir, varargin)
%generatesegments: creates segments which start at the onset
%   for each file in input-filelist, (in the directory specified by
% [stimulibasedir, experimentname,dirname]), reads the onset intervals. For
% qualifying onset intervals, (i) a segment of data from the relevant array
% coded in ANMatrixdir;  and from the array coded in OnsetMatrixDir, and from
% the set of directorsies stored in the array GaborMatrixDirSet starting at the
% beginning of the onset interval (-pretime, if set), and lasting for
% seglength (in seconds) is created, and these are turned into a 3
% dimensional array (index by time by channel). The sampling rate in the
% array is the same as the sampling rate in ANMatrixDir (or
% GaborMatrixDir) (so all the sampling rates must be the same).
% The resulting (large) matrices are stored in OutputDir,
% along with the parameters used in this datasets creation.

% started about 20 Feb 2014.
% expanded 24 2 2014
%
% addition: for each segment, we need to know which dataset it arose from,
% so we can reconnect a classifiction of the segments with the actual
% segment itself
% started 27 Feb 2014.
%
% preparatory stuff

% optional parameters
maxsegsperfile = 40 ;
maxoutputlength = 50000 ; % big
maxintervallength = 200 ;
pretime = 0 ;  % default time before start of onset interval
% used in determining if an interval qualifies
minintervallength = 0.01 ; %10ms default minimum interval length
minimumspikes = 2 ; % 2 is default minumum number of spikes in an interval
seglength = 0.075; % 75ms default segment length
fileset = 'fileset' ;
i=1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'pretime'
            pretime = varargin{i+1} ;
            i = i + 2 ;
        case 'minintervallength'
            minintervallength = varargin{i+1} ;
            i = i + 2 ;
        case 'minimumspikes'
            minimumspikes = varargin{i+1} ;
            i = i + 2 ;
        case 'seglength'
            seglength = varargin{i+1} ;
            i = i + 2 ;
        case 'maxoutputlength'
            maxoutputlength =  varargin{i+1} ;
            i = i + 2 ;
        case 'maxintervallength'
            maxintervallength =  varargin{i+1} ;
            i = i + 2 ;
        case 'fileset'
            fileset =  varargin{i+1} ;
            i = i + 2 ;
        otherwise
            error('generatesegments: Unknown argument %s given',varargin{i});
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
% find out how many Gabor arrays there are
nGabors = length(GaborMatrixDirSet) ;

% list of files to be processed is in cell array filelist, with the number
% of files in noofexperiments
%
meansIntervalno = 1 ; % indices of the interval numbers of Level 0 AN
meansOnsetno = 1 ; % indices of the mean onset level 1
gaborIntervalno = ones([1 nGabors])  ; % index for each Gabor Level 1 feature type
segmentid = cell([1 noofexperiments * maxsegsperfile]) ; % usef for file name for segment
segmentstart = zeros([1 noofexperiments * maxsegsperfile]) ; % use for segment offset within the file
for j=1:noofexperiments
    % display experiment info
    disp([filelist{j} ' generating segments running']) ;
    
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
    OnsetInfo = load([stimulibasedir experimentname  dirname '/' OnsetSigdir '/' startpart '_onset.mat']) ;
    
    if (j == 1)
        %initialise the output arrays
        % note that maxoutputlength and maxintervallength are set at start
        meansoutputarray = zeros([maxoutputlength maxintervallength OnsetInfo.ANparams.channels]) ;
        meansonsetarray = zeros([maxoutputlength maxintervallength OnsetInfo.ANparams.channels]) ;
        % allow for several Gabor arrays
        meansgaborarray =  zeros([nGabors maxoutputlength maxintervallength OnsetInfo.ANparams.channels]) ;
    end
    
    % load the datasets to be used
    % ANSig
    ANSigInfo = load([stimulibasedir experimentname  dirname '/' ANMatrixDir '/' startpart '_plainmeans.mat']) ;
    % Onset Sig
    OnsetSigInfo = load([stimulibasedir experimentname  dirname '/' OnsetMatrixDir '/' startpart '_onsetmeans.mat']) ;
    % Gabor Signals
    for gaborno = 1:nGabors
        GaborSigInfo{gaborno} = load([stimulibasedir experimentname  dirname '/' GaborMatrixDirSet{gaborno} '/' startpart '_gaboroutputs.mat']) ;
    end
    
    
    
    spikesusedinintervals = sum(OnsetInfo.Nusedininteerval,2) ;
    % check length of each array to be use (used to avoid falling off the
    % end of the array)
    length_ANmlm =  size(ANSigInfo.mlm,1) ;
    length_Onsetmlo = size(OnsetSigInfo.mlo,1) ;
    length_Gabor = zeros([1 nGabors]) ;
    for gno = 1:nGabors
        length_Gabor(gno) = size(GaborSigInfo{gno}.gaboroutput{1},1) ;
    end
    % we'd like these to be the same! That way we can do analysis across
    % the different L0 and L1 matrices
    % find the meximal length, and extend the pthers with 0's to that
    % length
    maxlength = max([length_ANmlm length_Onsetmlo length_Gabor]) ;
    % now pad them out to the same length
    ANmlm = zeros([maxlength size(ANSigInfo.mlm,2)]) ;
    Onsetmlo = zeros([maxlength size(OnsetSigInfo.mlo,2)]) ;
    Gaborvect = zeros([nGabors maxlength size(GaborSigInfo{gno}.gaboroutput{1},2)]) ;
    % and then put the data back in
    ANmlm(1:length_ANmlm, :) = ANSigInfo.mlm ;
    Onsetmlo(1:length_Onsetmlo,:) = OnsetSigInfo.mlo ;
    for gno = 1:nGabors
        Gaborvect(gno, 1:length_Gabor(gno), :) = GaborSigInfo{gno}.gaboroutput{1} ;
    end
    
    % for each onset interval
    
    for onsetno = 1:size(OnsetInfo.intervals, 1)
        if ((meansIntervalno + size(OnsetInfo.intervals, 1)) > maxoutputlength)
            error('generatesegments: arrays too small to hold all the intervals: increase maxoutputlength') ;
        end
        % does this interval qualify ?
        if (((OnsetInfo.intervals(onsetno,2) - OnsetInfo.intervals(onsetno,1)) > minintervallength) ... % length
                && (spikesusedinintervals(onsetno) > minimumspikes)) %
            %qualifies
            % extract segment from AN signal
            % ANSigInfo = load([stimulibasedir experimentname  dirname '/' ANMatrixDir '/' startpart '_plainmeans.mat']) ;
            vectstart = floor((OnsetInfo.intervals(onsetno,1) - pretime) * ANSigInfo.mlmparams.resamplerate) ;
            % vecstart can be -ve if there's a really early onset. Omit it
            if (vectstart >=1)
                vectlength = floor(seglength * ANSigInfo.mlmparams.resamplerate) ;
                % defensive:
                if ((vectstart + vectlength-1) <= maxlength)
                    intervalvector = ANmlm(vectstart:(vectstart + vectlength-1), :) ;
                    % and put it into large 3D array
                    meansoutputarray(meansIntervalno, 1:vectlength, :) = intervalvector ;
                    % store the name of the current file, and the start of the segment (in
                    % seconds) for this segment.
                    segmentid{meansIntervalno} = startpart ;
                    segmentstart(meansIntervalno) = OnsetInfo.intervals(onsetno,1) ;
                    meansIntervalno = meansIntervalno + 1 ;
                end
                
            end
            %
            % extract segment from Onset Signal.
            vectstart = floor((OnsetInfo.intervals(onsetno,1) - pretime) * OnsetSigInfo.mloparams.resamplerate) ;
            vectlength = floor(seglength * OnsetSigInfo.mloparams.resamplerate) ;
            % defensive
            % vecstart can be -ve if there's a really early onset. Omit it
            if (vectstart >=1)
                if ((vectstart + vectlength-1) <= maxlength)
                    intervalvector = Onsetmlo(vectstart:(vectstart + vectlength-1), :) ;
                    % and put it into large 3D array
                    meansonsetarray(meansOnsetno, 1:vectlength, :) = intervalvector ;
                    meansOnsetno = meansOnsetno + 1 ;
                end
            end
            
            %
            % extract segment from the Gabor signals
            for gno = 1: nGabors
                % GaborSigInfo = load([stimulibasedir experimentname  dirname '/' GaborMatrixDir '/' startpart '_gaboroutputs.mat']) ;
                vectstart = floor((OnsetInfo.intervals(onsetno,1) - pretime) * GaborSigInfo{gno}.gaborparams.resamplerate) ;
                vectlength = floor(seglength * GaborSigInfo{gno}.gaborparams.resamplerate) ;
                %defensive
                % vecstart can be -ve if there's a really early onset. Omit it
                if (vectstart >=1)
                    if ((vectstart + vectlength-1) <= maxlength)
                        intervalvector = Gaborvect(gno, vectstart:(vectstart + vectlength-1), :) ;
                        % and put it into large 3D array
                        meansgaborarray(gno, gaborIntervalno(gno), 1:vectlength, :) = intervalvector ;
                        gaborIntervalno(gno) = gaborIntervalno(gno) + 1 ;
                    end
                end
            end
            
        end % qualifying if
    end % onsets in a single sound file
    
end % for %
% store the large arrays
% reduce to actual size
meansgaborarray = meansgaborarray(:, 1:meansIntervalno - 1, 1:vectlength, :) ;
meansonsetarray = meansonsetarray(1:meansOnsetno - 1, 1:vectlength, :) ;
meansoutputarray = meansoutputarray(1:meansIntervalno - 1, 1:vectlength, :) ;
segmentid = segmentid(1:meansIntervalno-1) ;
segmentstart = segmentstart(1:meansIntervalno-1) ;
% now save this output
if ~exist([stimulibasedir  experimentname  dirname '/' OutputDir], 'dir')
    % create directory
    mkdir([stimulibasedir  experimentname  dirname '/' OutputDir]) ;
end
% save it in a file that has .mat at the end
% keep the parameters used
vectors.pretime = pretime ;
vectors.minintervallength = minintervallength ;
vectors.minimumspikes = minimumspikes ;
vectors.seglength = seglength ;
ANParams = ANSigInfo.ANParams ; % parameters used in creating the AN spikes
onsetparams = OnsetInfo.onsetparams ; % parameters used in creating the Onset spikes
mloparams = OnsetSigInfo.mloparams ; % mean level onset parameters
mlmparams = ANSigInfo.mlmparams ; % parameters for the AN means
for gno = 1: nGabors % the sets of parameters for the gabors
    gaborparams{gno} = GaborSigInfo{gno}.gaborparams;
end
save([stimulibasedir  experimentname  dirname '/' OutputDir '/' fileset '_vectors' '.mat'],...
    'meansoutputarray', 'meansonsetarray', 'meansgaborarray','segmentid','segmentstart','vectors', 'ANParams', ...
    'onsetparams', 'mlmparams', 'mloparams', 'gaborparams' ) ;

end


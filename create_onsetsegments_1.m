function [ numberofsegments, segarray, filelist ] = create_onsetsegments_1(stimulibasedir, experimentname,dirname, input_filelist, bmSigdir, onsetSigDir, onsetqualifier, prestart,duration)
%create_onsetsegments Creates a number of segments from onset intervals and
%smallBmSig dataset elements
%   First determines where all the relevant files will be, using
%   [stimulibasedir experimentname dirname] for the base of the location,
%   and then using store_bmSig for locating the smallBmSig elements, and
%   onsetSigDir for the onsets. Segemnts will be AN.channels wide, with duration/corrparam.repackage
%   length. Each inputfilelist will be scanned for onset intervals (and the
%   number found in each reported to the screen), and the array of segments
%   (and the various parameters used in creating it) written to a file. onsetqualifier is used
%   to determine whether an interval is to be used: it must use at least the onsetqualifier fraction
%   of the number of channels. The
%   actual interval will begin at the start of the onset - prestart, and be
%   of duratiopn duration.
%
% lss started 7 June 2013.
% modified 16 June 2013, to also record the names and times of the starts
% of the segments
%
 debug = 0 ;
% read input_filelist to get the list of files to be processed
inputfid = fopen([stimulibasedir  experimentname '/' dirname '/' input_filelist]) ;
fline = fgetl(inputfid) ;
noofexperiments = 1 ;
while ischar(fline)
    filelist{noofexperiments}.name = fline ;
    fline = fgetl(inputfid) ;
    noofexperiments = noofexperiments + 1 ;
end
noofexperiments = noofexperiments - 1 ;
if (noofexperiments == 0)
    error('No files to be processed') ;
end
% list of files to be processed in in cell array filelist, with the number
% of files in noofexperiments

% first find out how many onset intervals there are. Do this to set up main
% output array
numberofsegments = 0 ;
for j=1:noofexperiments % for each sound file
    if (debug > 0)
        disp([filelist{j}.name ' in create_onsetsegments: initial assessment of number of onset intervals'] ) ;
    end
    
    % split the file name stem from ths suffix
    % will not work if there's more than 2 '.' characters in filename
    fileparts = strsplit(filelist{j}.name, '.') ;
    numstrings = length(fileparts) ;
    if numstrings == 3
        startpart = [fileparts{1} '.' fileparts{2}] ;
        suffix = fileparts{3} ;
    else
        startpart = fileparts{1} ;
        suffix = fileparts{2} ;
    end
    filestem = [startpart '.'] ; % filestem includes the .
    % read the onset file
    onsetdata = load([stimulibasedir  experimentname  dirname '/' onsetSigDir '/' startpart '_onset.mat'] ) ; % no dot
    [numintervals, ~] = size(onsetdata.intervals) ; % find the number of intervals altogether
    qnumintervals = 0 ;
    qintervalids= zeros([1 numintervals]) ; % initialise number of qualified intervals to maximal size
    for i = 1:numintervals
        if ((sum(onsetdata.Nusedininteerval(i,:))/onsetdata.ANparams.channels) >= onsetqualifier)
            qnumintervals = qnumintervals + 1 ; % this interval qualifies
            qintervalids(qnumintervals) = i ; % so store it
        end
    end
    qintervalids = qintervalids(1:qnumintervals) ; % cut array of valid intervals down to actual size
    filelist{j}.qnumintervals = qnumintervals ;
    filelist{j}.qintervalids = qintervalids ;
    filelist{j}.intervals = onsetdata.intervals ; % record the intervals themselves
    filelist{j}.segbasenumber = numberofsegments ; % record the start segment number (0 for 1st one)
    numberofsegments = numberofsegments + qnumintervals ;
end

% filelist now contains names, number of qualified onset intervals, and
% which ones are qualified for each file. 
% create a 3d array to hold all the segments
% need to read the first of the smallBmSigPos files to get the correct
% sampling rate
smallBmdata = load([stimulibasedir  experimentname  dirname '/' bmSigdir '/' filestem '_smallBmSigPos'], '-mat' ) ; % with dot
numsamples = fix(duration/smallBmdata.corrparam.repackage) ; % number of samples in each segment
segarray = zeros([numberofsegments onsetdata.ANparams.channels numsamples]) ; % to hold all the segments
segbasenumber = 0 ;
for j=1:noofexperiments % for each sound file
    disp([filelist{j}.name, ' creating segments']) ;
    % split the file name stem from ths suffix
    % will not work if there's more than 2 '.' characters in filename
    fileparts = strsplit(filelist{j}.name, '.') ;
    numstrings = length(fileparts) ;
    if numstrings == 3
        startpart = [fileparts{1} '.' fileparts{2}] ;
        suffix = fileparts{3} ;
    else
        startpart = fileparts{1} ;
        suffix = fileparts{2} ;
    end
    filestem = [startpart '.'] ; % filestem includes the .
    smallBmdata = load([stimulibasedir  experimentname  dirname '/' bmSigdir '/' filestem '_smallBmSigPos'], '-mat' ) ; % with dot
    onsetdata = load([stimulibasedir  experimentname  dirname '/' onsetSigDir '/' startpart '_onset.mat'] ) ; % no dot

    for segno = 1:filelist{j}.qnumintervals;
        segid = filelist{j}.qintervalids(segno) ;
        % get the segment itself
        segstarttime = onsetdata.intervals(segno,1) ;
        segstart = fix(segstarttime/smallBmdata.corrparam.repackage) ;
        % segment = smallBmdata.smallBnSigPos(:,segstart:segstart+numsamples-1) ;
        segarray(segbasenumber + segno,:,:) = smallBmdata.smallBmSigPos(:,segstart:segstart+numsamples-1) ;
    end
    segbasenumber = segbasenumber + filelist{j}.qnumintervals ;
end
 
% could save the segarray here?
onsetsegs.onsetqualifier = onsetqualifier;
onsetsegs.prestart = prestart ;
onsetsegs.duration = duration ;

fileparts = strsplit(input_filelist, '.') ;
save([stimulibasedir  experimentname  dirname '/' input_filelist '_onsetSegs.mat'], 'segarray', ...
    'onsetsegs', 'filelist') ;   
end










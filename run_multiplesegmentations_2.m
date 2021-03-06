function segments = run_multiplesegmentations_2(sd, filelist, nfilters, varargin)
% run_multiplesegmentations_2: LSS March 2019 
% l.s.smith@cs.stir.ac.uk
%
% function to run through segmenting a single file (1st in the list at
% [sd  / filelist] with vaying number of filters 1 to nfilters.
% creates a lot of files with the segmentations produced, and then loads
% them into  a single structure segments which is nfilters by 1 with the
% segmentation for each number of filters. The intent it that the user
% compare what they expect with what's produced, for example for continuous
% sopeech and continuoius speech in noiose. Note that continuous speech
% does not have word boundaries (for example, the word "semiquaver" is pronounced in
% exactly the same way as "semi quaver" would be in continuous speech). What
% this
% system finds is onsets and offsets, and so it is sensitive to starts and
% finishes of eneregy in different parts of the spectrum.
%
% sd is the directory with the sounds (.wav, for example) (so
% 'stimuli_2019' might be appropriate)
% filelist is the file containing the name of the file to be processed
% e.g. 'fournmubers.wav'
% nfilters is the number of filters to be used (e.g. 25)
%
% returns a structure array with nfilters elements, each containing the
% segmentation prxoduced for that  number of channels.
%
% intended simply to show effect of filter number
startfilter = 1 ;

i = 1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'startfilter'
            startfilter = varargin{i+1};
            i=i+1 ;
            otherwise
            error('run_multiplesegmentations_2: Unknown argument %s given',varargin{i});
    end
    i=i+1 ;
end
            
for nf = startfilter:nfilters
    convergence = floor(nf/6) ;
    % convergence = 0 ;
    s1 = findsegments_all_2(sd, [sd '/' filelist], sd, 'nfilt', nf, 'filesuffix', num2str(nf), 'minseglength', 0.1, 'sigmaratio', 1.1 ,...
        'onset_wt' ,500, 'offset_wt', 500, 'convergence', convergence, 'logonset', true) ;
end
if ~(s1 == 1)
    disp(['This version expects only one file to be processed: number of files = ' num2str(s1) ' only 1st file processed']) ;
end

inputfid = fopen([sd '/' filelist]) ;
fline = fgetl(inputfid) ;
nooffiles = 1 ;
while (ischar(fline) && (~isempty(fline)))
    filenames{nooffiles} = fline ;
    fline = fgetl(inputfid) ;
    nooffiles = nooffiles + 1 ;
end
nooffiles = nooffiles - 1 ;
fclose(inputfid) ;

filenameroot =  strsplit(filenames{1}, '.') ;

for i = startfilter:nfilters
    segments(i,:) = load([sd '/' filenameroot{1} num2str(i) '_segs.mat'], 'segments') ;
    % delete the files
    delete([sd '/' filenameroot{1} num2str(i) '_segs.mat']);
end
end

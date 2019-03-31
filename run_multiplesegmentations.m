function segments = run_multiplesegmentations(sd, filelist, nfilters)
% run_multiplesegmentations:
% function to run through segmenting a single file (1st in the list at
% [sd  / filelist] with vaying number of filters 1 to nfilters.
% creates a lot of files with the segmentations produced, and then loads
% them into  a single structure segments which is nfilters by 1 ,l with the
% segmentation foir each number of filters.
%
% sd is the directory wioth the sounds (.wav, for example)
% filelist is the file containing the name of the file to be processed
% nfilters is the number of filters to be used
%
% intended simply to show effect of filter number

for nf = 1:nfilters
    s1 = findsegments_all(sd, [sd '/' filelist], sd, 'nfilt', nf, 'filesuffix', num2str(nf), 'minseglength', 0.1) ;
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

for i =1:nfilters
    segments(i,:) = load([sd '/' filenameroot{1} num2str(i) '_segs.mat']) ;
end
end

function [datafile_for_ESNEKM] = convertAN(ANdirectory, ANfilelist, targets, targettype, deltaT)
%convertAN Convert AN data to format for ESNEKN
%   Read AN file list, and the relevant targets, and convert to a data file
%   for ESN/EKM
%   for each AN file, the data is formed into a N-Channels by number of
%   deltaT's array each element beiong the number of spikes in that deltaT
%   Normalisation may be required, to avoid higher frequency bands having
%   much higher values.
%
%   parameters:
%   ANdirectory: directory containing the AN files
%   ANfilelist: file containing the list of files to be processed
%   targets: file containing the .csv file with the informatiojn about the
%   targets for each audio file
%   targettype: 1 for class of sound (Effects/Human/Music/Nature/Urban), 2
%   for acrtual form of sound (more classes)
%   deltaT: length of time to parcel the spikes into
% may need another parameter to control how the spikes are re-parcelled.

% read input_filelist to get the list of files to be processed
inputfid = fopen(ANfilelist) ;
fline = fgetl(inputfid) ;
nooffiles = 1 ;
while ischar(fline)
    filelist{nooffiles} = fline ;
    fline = fgetl(inputfid) ;
    nooffiles = nooffiles + 1 ;
end
nooffiles = nooffiles - 1 ;
% read targets .csv file
% can't use csvread as the file has textual values
f1 = fopen(targets) ;
% read the whole file(probably Logsheet_Development.csv) into a 1 by 3
% cell, where the first cell is a cell array of the base type (Effects, for
% example), the second cell is a cell array the type of sound (Beep, for example) , and
% the third cell is a cell array containing the file name.
targetinfo = textscan(f1,'%s%s%s', 'Delimiter', {','})  ;
fclose(f1) ; % close file
% identify the targets to use
if (targettype == 1) % use the first cell to create the targets
    
else if (targettype == 2) % use the second cell to create the targets
        
    else error(['convertAN: invalid target type = ' num2str(targettype)]) ;
    end
end

% process each file, one by one
for i = 1:nooffiles
    ANname = filelist{i} ;    
    % get the stem of the file name
    filenameelements =  strsplit(ANname, '.') ;
    currentAN = load([ANdirectory '/' filenameelements{1} '_ANSig.mat']) ;
    % filenameelements{1} has the filename root
    % find where it occurs in the file name list
    idx = find(contains(targetinfo{3}, filenameelements{1})) ; % actual is xxx.wav
    disp([num2str(idx) ' ' targetinfo{3}{idx}]) ;
 
end

end


function [datafile_for_ESNEKM] = convertAN(ANfilelist, targets, deltaT)
%convertAN Convert AN data to format for ESNEKN
%   Read AN file list, and the relevant targets, and convert to a data file
%   for ESN/EKM
%   for each AN file, the data is formed into a N-Channels by number of
%   deltaT's array each element beiong the number of spikes in that deltaT
%   Normalisation may be required, to avoid higher frequency bands having
%   much higher values.

% read input_filelist to get the list of files to be processed
inputfid = fopen(ANfilelist) ;
fline = fgetl(inputfid) ;
nooffiles = 1 ;
while ischar(fline)
    filelist{nooffiles} = fline ;
    fline = fgetl(inputfid) ;
    nooffiles = nooffiles + 1 ;
end
% read targets .csv file
% can't use csvread as the file has textual values
f1 = fopen(targets) ;
% read the whole file(probably Logsheer_Development.csv) into a 1 by 3
% cell, where the first cell is a cell array of the base type (Effects, for
% example), the second cell is a cell array the type of sound (Beep, for example) , and
% the third cell is a cell array containing the file name.
targetinfo = textscan(f1,'%s%s%s', 'Delimiter', {','})  ;
fclose(f1) ; % close file

% process each file, one by one
for i = 1:nooffiles
    currentAN = load(filelist{i}) ;
    % 
end

end


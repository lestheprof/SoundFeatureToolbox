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

% process each file, one by one

end


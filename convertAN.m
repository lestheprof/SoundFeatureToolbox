function convertAN(ANdirectory, ANfilelist, targets, targettype, deltaT, outputfile, reparcel)
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
%   targets: file containing the .csv file with the information about the
%   targets for each audio file
%   targettype: 1 for class of sound (Effects/Human/Music/Nature/Urban), 2
%   for actual form of sound (more classes)
%   deltaT: length of time to parcel the spikes into
%   reparcel: 0 none, 1 use CF to adjust all values, 2 as 1, plus take log(1+x)
%   of values

debug = true ;

reparcel_const = 1000 ; % used so that values stay in a reasonable range when re-parcelled
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
fclose(inputfid) ;
% read targets .csv file
% can't use csvread as the file has textual values
f1 = fopen(targets) ;
% read the whole file(probably Logsheet_Development.csv) into a 1 by 3
% cell, where the first cell is a cell array of the base type (Effects, for
% example), the second cell is a cell array the type of sound (Beep, for example) , and
% the third cell is a cell array containing the file name.
textscan(f1,'%s%s%s', 1, 'Delimiter', {','})  ; % ignore first line (headers)
targetinfo = textscan(f1,'%s%s%s', 'Delimiter', {','})  ; % read rest of file
fclose(f1) ; % close file
% identify the targets to use
if (targettype == 1) % use the first cell to create the targets
    targetset = unique(targetinfo{1}) ;
else
    if (targettype == 2) % use the second cell to create the targets
        targetset = unique(targetinfo{2}) ;
    else
        error(['convertAN: invalid target type = ' num2str(targettype)]) ;
    end
end

% targetset
% initialise output dataset
outdatacells = cell(nooffiles, 2) ;

% process each file, one by one
for i = 1:nooffiles
    ANname = filelist{i} ;
    % get the stem of the file name
    filenameelements =  strsplit(ANname, '.') ;
    currentAN = load([ANdirectory '/' filenameelements{1} '_ANSig.mat']) ;
    % filenameelements{1} has the filename root
    % find where it occurs in the file name list
    idx = find(contains(targetinfo{3}, filenameelements{1})) ; % actual is xxx.wav
    % find target index (i.e. output value)
    [~ , tindex] = ismember(targetinfo{targettype}{idx}, targetset)  ;
    % now calculate values for the input matrix for each channel
    if debug
        disp([num2str(idx) ' ' targetinfo{3}{idx} ' target = ' num2str(tindex)]) ;
    end
    outdatacells{i,2} = tindex ; % set target output
    % initialise array to hold the input for this target
    n_timesteps = floor((currentAN.AN.datalength/currentAN.AN.Fs) / deltaT) ;
    inputarray = zeros(currentAN.AN.channels, n_timesteps) ;
    % add up spikes in currentAN/ASN.sighnal (1 by currentAN.AN.channels)
    % seem to have to be done channel by channel
    step = deltaT * currentAN.AN.Fs ; % step in samples
    
    for chno=1:currentAN.AN.channels % process each channel
        currenttime = step ;
        currentsignalindex = 1 ; % pointer to where we are in signal
        for currenttimeindex = 1:n_timesteps % create 1 value per timestep
            inputarray(chno,currenttimeindex) = 0 ;
            signaltemp = currentAN.AN.signal{chno} ; % optimised: faster access
            % add up within a single deltaT
            while (  (currentsignalindex < size(signaltemp, 2)) && (signaltemp(1, currentsignalindex) < currenttime))
                inputarray(chno,currenttimeindex) = inputarray(chno,currenttimeindex) + ...
                    signaltemp(2, currentsignalindex) ; % add up spike values
                currentsignalindex = currentsignalindex + 1 ;          
            end
            currenttime = currenttimeindex * step ; % end of next timestep in samples
        end
        
    end
    if (reparcel >= 1)
        % apply a correction for the Cf of each channel
        inputarray = inputarray * (reparcel_const/currentAN.AN.cf(chno)) ;
        if (reparcel == 2)
            % log-scale the values
            inputarray = log(1+inputarray) ;
        end         
    end
    
    outdatacells{i, 1} = inputarray ;

end
% write out the data file
AN = currentAN.AN ;
save(outputfile, 'outdatacells', 'reparcel', 'deltaT', 'AN', 'filelist') ;
end


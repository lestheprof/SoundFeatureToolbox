function [numfiles] = segment(filename,segmenttimes)
% segment: segments a sound file into a number of pieces, using the first
% dimension of array. Writes the segments to files called
% filename_seg<i>.au or wav depending on whether the original file was an
% au or a wav. Returns number of segments written.
%
% Note that segment times are in seconds.
%
% Written by Dean hunter, modified by LSS June 17 July 2013.

% start by reading the file fname into vector sig, sampling freq fs
% cope with different suffixes on sounds. NB: raw uncomporessed only
locn = strfind(filename, '.') ; % find occurrences of .
suffix = filename(locn(length(locn)): length(filename)) ; % find suffix
prefix =filename(1:locn(length(locn))-1) ; % omit the .
% filetype = 'au';

% now read file
if strcmp(suffix ,'.au')
    [sig, fs, bits] = auread(filename);
    filetype ='au';
else if strcmp(suffix ,'.AU')
        [sig, fs, bits] = auread(filename);
        filetype ='au';
    else if strcmp(suffix , '.wav')
            [sig,fs,bits] = wavread(filename) ;
            filetype ='wav';
        else if strcmp(suffix , '.WAV')
                [sig,fs,bits] = wavread(filename) ;
                filetype ='wav';
            else
                error(['Invalid suffix = ' suffix]) ;
            end ;
        end ;
    end;
end;

% convert segmenttimes to samples
segmenttimes = fix(segmenttimes * fs) ;
% and use only the 1st dimension
segmenttimes = segmenttimes (:,1) ;

% check if sound file has a length
if size(sig) > 0
    if segmenttimes(1) >= 1
        numfiles=0; %set default number of output files
        outputsig=[];
        
    else
        error(['first array index : ',num2str(segmenttimes(:,1)),' ,segment selection is smaller than 1.']);
    end
    
    for i=1:numel(segmenttimes)-1
        
        if segmenttimes(i) < segmenttimes(i+1) ||  xor(segmenttimes(i),segmenttimes(i+1))%test segmenttimes element sequence
            
                outputsig = sig(segmenttimes(i):segmenttimes(i+1)); % note that endpoints are used twice
            
        else
            error(['Index values : ' num2str(segmenttimes(i)),', ',num2str(segmenttimes(i+1)), ',value is greater than its succeeding index, or smaller than 1 in the input array'] ) ;
        end
        switch filetype
            case 'au'
                if (bits == 16)
                    auwrite(outputsig,fs,bits,'linear', strcat(prefix, '_seg',num2str(i),'.au')); %write out each segment
                else
                    auwrite(outputsig,fs,bits, strcat(prefix, '_seg',num2str(i),'.au')); %write out each segment
                end
            case 'wav'
                wavwrite(outputsig,fs,bits,strcat(prefix, '_seg' ,num2str(i),'.wav'));
        end
        numfiles=numfiles+1; %add one to total files output
        outputsig=[];%set output back to empty
    end
    
else
    numfiles = 0 ;  % return 0 if there's no sound in filename
end




end
function [numfiles] = segment(filename,segmenttimes)
% segment: segments a sound file into a number of pieces, using an number
% of segments by 2 array
% Writes the segments to files called
% filename_seg<i>.wav depending.
% Returns number of segments written.
%
% Note that segment times are in seconds.
%
% Written by Dean hunter, modified by LSS June 17 July 2013.
% rewritten LSS October 2018

%  read file
[sig,fs] = audioread(filename) ;
prefix = extractBefore(filename, '.') ;
% convert segmenttimes to samples
segmenttimes = fix(segmenttimes * fs) ;

% check if sound file has a length
if size(sig) > 0
    if segmenttimes(1) >= 1
        numfiles=0; %set default number of output files
    else
        error(['segment : ',num2str(segmenttimes(:,1)),' ,segment selection is smaller than 1.']);
    end
    
    for i=1:size(segmenttimes,1) % use first index
        
        if (segmenttimes(i,1) < segmenttimes(i, 2) )%test segmenttimes element sequence
            
            outputsig = sig(segmenttimes(i, 1):segmenttimes(i, 2)); % note that endpoints are used twice
            
        else
            error(['Index values : ' num2str(segmenttimes(i, 1)),', ',num2str(segmenttimes(i, 2)),...
                ' segment has end < beginning'] ) ;
        end
        
        audiowrite(strcat(prefix, '_seg' ,num2str(i),'.wav'), outputsig, fs);
        
        numfiles=numfiles+1; %add one to total files output
    end
    
else
    numfiles = 0 ;  % return 0 if there's no sound in filename
end




end
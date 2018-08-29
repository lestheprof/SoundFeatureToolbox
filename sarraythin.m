function spikethinarray =  sarraythin(spikearray, epsilon)
% turns spike  N * 3 array
% where element 1 is sensitivity level, 2 is bandpass channel no, 3 is time
% into an N*5 array by combining those spikes from the same stimulus as
% defined by their coming from the same BP channel, but different
% sensitivity levels, where the time is such that the less sensitive levels
% fire a little later
% spikearray is the flattened structure produced by sarray
% epsilon is the maximal difference between two adjacent spikes in the same
% BP channel, but on different sensitivity levels. 0.02 seems good
%
% output format is < s-level low, s-level hi, BP channel no, start time,
% end time>
% note that not all s-levels may have actually had a firing
% assumes appropriate ordering of spikearray.

% epsilon = 0.02 ; % delay across all the sensitivity levels. now a
% parameter
[salength temp] = size(spikearray) ;

outindex = 0 ;
currtime = -1 ; % initialise
currchannel = 0 ;

for i = 1:salength
    if spikearray(i, 2) ~= currchannel
        % change of channel: new output must start
        outindex = outindex + 1 ;
        spikethinarray(outindex,:) = [spikearray(i,1) spikearray(i,1) spikearray(i, 2) ...
                spikearray(i, 3) spikearray(i, 3)] ;
        currtime = spikearray(i, 3) ;
        currchannel = spikearray(i, 2) ;
    else
        % same channel
        if (spikearray(i,3) - currtime) > epsilon
            % long break between spikes in same channel: new output
            % must start
            outindex = outindex + 1 ;
            spikethinarray(outindex,:) = [spikearray(i,1) spikearray(i,1) spikearray(i, 2) ...
                spikearray(i, 3) spikearray(i, 3)] ;
            currtime = spikearray(i, 3) ;
        else
            % continue current output
            % by updating 2nd and 5th element
            % allow for reversing of level outputs (seems to happen
            % occasionally)
            if spikearray(i,1) > spikethinarray(outindex,2)
                spikethinarray(outindex,2) = spikearray(i,1) ;
            else
                spikethinarray(outindex,1) = spikearray(i,1) ;
            end
            spikethinarray(outindex,5) = spikearray(i,3) ;
            currtime = spikearray(i, 3) ;
        end
    end
end
spikethinarray = sortrows(spikethinarray, [4 5 3]) ; % sort into channel within time order
    
    
    

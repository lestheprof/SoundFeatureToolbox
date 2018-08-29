function [intervals, chutilised] = overallonset(leftonsets, noCochFilt, epsilon1, epsilon2, display) 
% returns a set of intervals and 
% generates a single graph showing the onsets found from the mono output
% from the onset neurons. First flattens the leftonsets structure, then
% gathers together those onsets which arose in different sensitivity levels 
% but came from the same bandpass channel and we assume came from the same
% source. Lastly, draws a figure from these
%
% epsilon is used as the maximal time between spikes in different s-levels
%
% needs to return channels used as well
%
s1 = sarray(leftonsets) ; %flatten array
a1 = sarraythin(s1, epsilon1) ; % produce an  N*5 array, with elements lowest s-Level, 
% highest s-level, channel, start, endtime.

% find the intervals
[alength, ~] = size(a1) ;
intervals = [] ;

a1 = sortrows(a1,[4 5]) ;
channelsused = zeros([1 noCochFilt]) ; % for storing channels used in one interval

intervalnumber = 1 ;
startint = a1(1,4) ; endint = a1(1,5) ;
% add the channel used in to the list
channelsused(a1(1, 3)) = 1 ;
for i = 2: alength
    if a1(i,4) > (endint + epsilon2) % new interval
        % end of interval
        intervals = [intervals ; [startint endint]] ;
        % store the channels used    
        chutilised(intervalnumber,:) = channelsused ;
        intervalnumber = intervalnumber + 1 ;
        channelsused = zeros([1 noCochFilt]) ; % re-initialise
        
        startint = a1(i,4) ;
        endint = a1(i,5) ;
        % add the channel used in to the list
        channelsused(a1(i, 3)) = 1 ;
    else % same interval            
        % add the channel used in to the list
        channelsused(a1(i, 3)) = 1 ;
        if a1(i,5) > endint % extend interval if necessary
            endint = a1(i,5) ;
        end
    end
end
% also last one
endint = a1(i,5) ;
channelsused(a1(i, 3)) = 1 ;
chutilised(intervalnumber,:) = channelsused ;
intervals = [intervals; [startint endint]] ;
%
% draw a graph
if (display)
    figure ;
    plot(a1(:,4), a1(:,3), '.k') ;
end

    
    
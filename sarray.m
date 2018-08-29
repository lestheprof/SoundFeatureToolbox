function spikearray =  sarray(spikestructure)
% turns spike structure into a N * 3 array
% element 1 is sensitivity level, 2 is bandpass channel no, 3 is time
% allocate space first
lenflatspikes = 0 ;
for i=1:length(spikestructure)
            [l1 temp] = size(spikestructure(i).list) ;
            lenflatspikes = lenflatspikes+l1 ;
end
spikearray = zeros([lenflatspikes 3]) ;
currlength = 0 ;
for i = 1:length(spikestructure)
    [listsize, temp] = size(spikestructure(i).list) ;
    for j = 1:listsize
        spikearray(currlength + j, :) = [i spikestructure(i).list(j,1:2)] ; % mod LSS 23 6 2004 
    end
    currlength = currlength + listsize ;
end
% sort so that spikes from adjacent s-levels in the same channel at about
% the same time are adjacent
spikearray = sortrows(spikearray, [2 3 1]) ;
    
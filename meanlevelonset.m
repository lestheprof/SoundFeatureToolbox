function [ meanonset ] = meanlevelonset(resamplerate, Onset, display )
%meanlevelonset: Takes the onset output signal, which is a structure
%containing spikes, and recasts it into a 2D array, Nsamples by Nchannels,
%at the resamplerat sample rate
%   Organisation:
% 1: turn the onset structure element leftonset_wide into a single large
% array, puttting the sensitivity level into each of the 3 by
% NumberOfSpikes array elements
% 2: Order by Channel then Time
% 3: generate the array from the dataset, possibly using multiple onset
% spikes for each array element.
%
% Commenced 10 Feb 2014: LSS
%
% Get some important values out of the Onset structure
% fs = Onset.ANparams.Fs ; % sampling rate
iterations = Onset.ANparams.iterations ;
numchannels  = Onset.ANparams.channels ;

% create the output array after we
% find the time of the very last onset
% first concatentate the onset spikes together: to create the array for
% this add up the lengths of the different onset arrays.
numonsetspikes = 0 ;
lasttime = 0 ;
for slevel = 1:iterations
    if ~isempty(Onset.leftonset_wide(slevel).list)
        numonsetspikes = numonsetspikes + size(Onset.leftonset_wide(slevel).list,1) ;
        % also find the time of the last onset spike
        if (Onset.leftonset_wide(slevel).list(end, 2) > lasttime)
            lasttime = Onset.leftonset_wide(slevel).list(end, 2) ;
        end
    end
end
% initialise output array
% calculate number of time slots at resample rate
numsamples = ceil((lasttime + 0.1) * resamplerate) ;
meanonset = zeros([numsamples numchannels]) ;
if (numonsetspikes == 0)
    return ;
end
% now create the array to hold all the spikes
allonsetspikes = zeros([numonsetspikes 3]) ;
% and fill it up: each row is <slevel, channelnumber, time>
start = 1 ;
for slevel = 1:iterations
    if ~isempty(Onset.leftonset_wide(slevel).list)
        allonsetspikes(start:start -1 + size(Onset.leftonset_wide(slevel).list,1), 1) = slevel ;
        allonsetspikes(start:start -1 + size(Onset.leftonset_wide(slevel).list,1), 2:3) = Onset.leftonset_wide(slevel).list ;
        start = start + size(Onset.leftonset_wide(slevel).list,1) ;
    end
end
% now sort it into channel then time then slevel
allonsetspikes = sortrows(allonsetspikes, [2, 3, 1] ) ;
% and fill up the meanonsetarray from it
spikeindex = 1 ; % index the allonspikes array
for chno = 1: numchannels
    for sample = 1:numsamples
        % find the value to put into this sample of this channel
        if (spikeindex > numonsetspikes) || (allonsetspikes(spikeindex, 2) > chno) % out of onset spikes for this channel
            meanonset(sample, chno) = 0 ;
        else
            % find the onset spikes for this channel inside this resample
            % interval
            numspikes = 0 ;
            leveltotal = 0 ;
            while (spikeindex <= numonsetspikes) && (allonsetspikes(spikeindex, 3) < (sample/resamplerate)) && (allonsetspikes(spikeindex, 2) == chno)
                numspikes = numspikes + 1 ;
                leveltotal = leveltotal + allonsetspikes(spikeindex, 1) ;
                spikeindex = spikeindex + 1 ;
            end
            if (numspikes > 0)
                meanonset(sample, chno) = leveltotal/numspikes ;
            end
        end
    end
end
   if display
        % note that imagesc is being used, because image() ignores values <
        % 0
        figure('Name', 'Level 1: Onset') ;
        % find max and min values for xx{gbno}, set so that 0 is midpoint
        top = max(max(meanonset)) ;
        bot = min(min(meanonset)) ;
        lim = max(top, -bot) ;
        imagesc(meanonset') ; set(gca, 'YDir', 'normal') ; set(gca, 'CLim', [-lim lim]) ;
        clim = get(gca, 'CLim') ;
        % annotate
        
            title(['Mean Onset resamplerate='  num2str(resamplerate) ]);
        
    end             


end


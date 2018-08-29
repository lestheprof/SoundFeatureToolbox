function [ meansignal ] = meanlevelsinglechannel( channel, resamplerate, AN , endtime)
%meanlevelsinglechannel Summary: turns an AN spike train into a set of
%(positive) level values at resamplerate
% The data in which the channel
%resides is in the AN structure AN, which also contains the sample rate
%(Fs), the centre frequencies of all the channels (AN.cf), as well as the
%spikes themselves. These are in a cell array, AN.signal, which has
%AN.channels elements. Each spike is of the form <samplenumber level>
%
% LSS started Feb 7 2014
% this version uses level (sensitivity level) as the mulitplier, making the
% amplitude logarithmically scaled
%

if channel > AN.channels
    error('meanlevelsinglechannel:channel', 'channel number exceeds channels in AN structure') ;
end
starttime = 1  ;
% use endtime if supplied
if (~exist('endtime','var') || (endtime == 0) )
    if ~isempty(AN.signal{channel})
        endtime = floor(AN.signal{channel}(1, end) * resamplerate/AN.Fs);
    else
     endtime = 0 ;
    end
end
if (endtime == 0)
    meansignal = [] ; % no spikes
    return
end
meansignal = zeros([endtime 1]) ; % 1 dimensional
% bugfix 10 Feb 2014.
[~, nspikes_tot] = size(AN.signal{channel}) ;

if (AN.cf(channel) > resamplerate) % integrate over resample interval if that's less than channel period
    anspikeno = 1 ;
    for sample = starttime:endtime
        % count total (mean) level of spikes in this interval
        level = 0 ;
        nspikes = 0 ;
        while ((anspikeno <= nspikes_tot) && (AN.signal{channel}(1, anspikeno) * resamplerate/AN.Fs < sample))
            level = level + AN.signal{channel}(2, anspikeno) ;
            anspikeno = anspikeno + 1 ;
            nspikes = nspikes + 1 ;
        end
        if (nspikes > 0)
            meansignal(sample) = (level/nspikes) ;
        else
            meansignal(sample) = 0 ;
        end
    end
else % the frequency of the signal in this band in these bands is less than resamplerate
    % convolve gb5 with a pulse of appropriate duration
	tconv = ones([1 round(resamplerate/AN.cf(channel))])' ; % precalculate the convolution for each spike
	tconv = tconv/length(tconv) ; % normalise
    % gb5a = conv2(gb5, tconv) ;
    [gbl, gbh] = size(tconv) ;
    halflength = round(gbl/2) ; 
    % halfheight = round(gbh/2) ;

    % now add this in (centered!) for each spike
    for anspikeno = 1:size(AN.signal{channel}, 2) % for each spike
        level = AN.signal{channel}(2,anspikeno) ;
        % calculate where this is to be added
        sample = round(AN.signal{channel}(1,anspikeno) * resamplerate/AN.Fs) ;
        % ensure we stay in array
        if ((sample - halflength >= 1) && (sample + halflength + 1 <= endtime))
            % bug fix: use gbl, not length(gb5): 22 1 2014.
            meansignal(sample-halflength:sample-halflength+gbl -1, : ) = ...
                meansignal(sample-halflength:sample-halflength + gbl -1, :) + level * tconv ;
        end
    end
end




end


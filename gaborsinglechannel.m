function [ newsignal2d ] = gaborsinglechannel( channel, resamplerate, AN, gb5, endtime )
%gaborsinglechannel Summary: applies the gabor filter in gb5 to the
%1-dimensional data in a single channel, to produce a multiple channel output. 
%All the rows of the Gabor filter are used. The data in which the channel
%resides is in the AN structure AN, which also contains the sample rate
%(Fs), the centre frequencies of all the channels (AN.cf), as well as the
%spikes themselves. These are in a cell array, AN,signal, which has
%AN.channels elements. Each spike is of the form <samplenumber level>
%
% LSS started December 10 2013, based on testgaborsinglechannel.m
% this version uses level (sensitivity level) as the mulitplier, making the
% amplitude logarithmically scaled
%

if channel > AN.channels
    error('testgaborsinglechannel:channel', 'channel number exceeds channels in AN structure') ;
end
starttime = 1  ;
% use endtime if supplied
if (~exist('endtime','var') || (endtime == 0) )
    endtime = floor(AN.signal{channel}(1, end) * resamplerate/AN.Fs);
end
[gbl, gbh] = size(gb5) ;
newsignal2d = zeros([endtime gbh]) ; % 2dimensional
%bug fix 10 Feb 2012
[~, nspikes_tot] = size(AN.signal{channel}) ;

if (AN.cf(channel) > resamplerate) % integrate over 1ms if that's less than channel period
    halflength = round(gbl/2) ; 
    % halfheight = round(gbh/2) ;
    anspikeno = 1 ;
    for sample = starttime:endtime
        % count total level of spikes in this interval
        level = 0 ;
        nspikes = 0 ;
        while ((anspikeno <= nspikes_tot) && (AN.signal{channel}(1, anspikeno) * resamplerate/AN.Fs < sample))
            level = level + AN.signal{channel}(2, anspikeno) ;
            anspikeno = anspikeno + 1 ;
            nspikes = nspikes + 1 ;
        end
        if (nspikes > 0)
            % add in using mean value of the levels in this time interval
            % for now just use the middle value of the gb5 array
            % NOTE: we are adding in the filter starting at the spike:
            % should it be centred on the spike? Yes...
            % ensure that we stay off the edge of the array
            if ((sample - halflength >= 1) && (sample + halflength + 1 <= endtime))
                % assumes that we are not going off the edge of the array
                newsignal2d(sample-halflength:sample-halflength+length(gb5) -1, : ) = ...
                    newsignal2d(sample-halflength:sample-halflength + length(gb5) -1, :) + (level/nspikes) * gb5 ;
            end
        end
    end
else % the period of the signal in these bands exceeds resamplerate
    % convolve gb5 with a pulse of appropriate duration
	tconv = ones([1 round(resamplerate/AN.cf(channel))])' ; % precalculate the convolution for each spike
	tconv = tconv/length(tconv) ; % normalise
    gb5a = conv2(gb5, tconv) ;
    [gbl, gbh] = size(gb5a) ;
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
            newsignal2d(sample-halflength:sample-halflength+gbl -1, : ) = ...
                newsignal2d(sample-halflength:sample-halflength + gbl -1, :) + level * gb5a ;
        end
    end
end




end


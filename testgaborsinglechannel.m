function [ newsignal ] = testgaborsinglechannel( channel, resamplerate, AN, gb5 )
%testgaborsinglechannel Summary: applies the gabor filter in gb5 to the
%1-dimensional data in a single channel. The data in which the channel
%resides is in the AN structure AN, which also contains the sample rate
%(Fs), the centre frequencies of all the channels (AN.cf), as well as the
%spikes themselves. These are in a cell array, AN,signal, which has
%AN.channels elements. Each spike is of the form <samplenumber level>
%
% LSS December 10 2013
%

if channel > AN.channels
    error('testgaborsinglechannel:channel', 'channel number exceeds channels in AN structure') ;
end
starttime = 1  ;
endtime = floor(AN.signal{channel}(1, end) * resamplerate/AN.Fs);


if (AN.cf(channel) > resamplerate) % integrate over 1ms if that's less than channel period
    [gbl, gbh] = size(gb5) ;
    newsignal = zeros([1 endtime + gbl]) ;
    anspikeno = 1 ;
    for sample = starttime:endtime
        % count total level of spikes in this interval
        level = 0 ;
        nspikes = 0 ;
        while (AN.signal{channel}(1, anspikeno) * resamplerate/AN.Fs < sample)
            level = AN.signal{channel}(2, anspikeno) ;
            anspikeno = anspikeno + 1 ;
            nspikes = nspikes + 1 ;
        end
        if (nspikes > 0)
            % add in using mean value of the levels in this time interval
            % for now just use the middle value of the gb5 array
            % NOTE: we are adding in the filter starting at the spike:
            % should it be centred on the spike?
            newsignal(sample:sample+length(gb5) -1) = ...
            newsignal(sample:sample + length(gb5) -1) + (level/nspikes) * squeeze(gb5(:,ceil(gbh/2) ))' ;
        end
    end
else % the period of the signal in these bands exceeds resamplerate
    % convolve gb5 with a pulse of appropriate duration
	tconv = ones([1 round(resamplerate/AN.cf(channel))])' ; % precalculate the convolution for each spike
	tconv = tconv/length(tconv) ; % normalise
    gb5a = conv2(gb5, tconv) ;
    [gbl, gbh] = size(gb5a) ;
    newsignal = zeros([1 endtime + gbl]) ;

    % now add this in (centered!) for each spike
    for anspikeno = 1:size(AN.signal{channel}, 2) % for each spike
        level = AN.signal{channel}(2,anspikeno) ;
        % calculate where this is to be added
        sample = round(AN.signal{channel}(1,anspikeno) * resamplerate/AN.Fs) ;
        newsignal(sample:sample+length(gb5a) -1) = ...
            newsignal(sample:sample + length(gb5a) -1) + level * squeeze(gb5a(:,ceil(gbh/2) ))' ;
    end
end




end


% test out gabor on a single channel
channel = 95; % use this channel
resamplerate = 1000;
starttime = 1 ;
endtime = floor(AN.signal{channel}(1, end) * resamplerate/AN.Fs);

newsignal = zeros([1 endtime + length(gb5)]) ;

if (AN.cf(channel) > resamplerate) % integrate over 1ms if that's less than channel period
    anspikeno = 1 ;
    for sample = starttime:endtime
        % count spikes in this interval
        level = 0 ;
        nspikes = 0 ;
        while (AN.signal{channel}(1, anspikeno) * resamplerate/AN.Fs < sample)
            level = AN.signal{channel}(2, anspikeno) ;
            anspikeno = anspikeno + 1 ;
            nspikes = nspikes + 1 ;
        end
        if (nspikes > 0)

            newsignal(sample:sample+length(gb5) -1) = ...
            newsignal(sample:sample + length(gb5) -1) + (level/nspikes) * squeeze(gb5(:, 23))' ;
        end
    end
else
%     tconv = ones([1 round(resamplerate/AN.cf(channel))])' ; % precalculate the convolution for each spike
%     tconv = tconv/length(tconv) ;
%     newsignal = zeros([1 AN.signal{channel}(1, end) * (resamplerate/AN.Fs) + ...
%          + length(gb5)]) ; % initialise the output
%     gconv = conv2(tconv, gb5) ;


end


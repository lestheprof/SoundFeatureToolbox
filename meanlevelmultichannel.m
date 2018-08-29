function [ finalsignal2d ] = meanlevelmultichannel(resamplerate, AN, type)
%meanlevelmultichannel: Computes the mean level from the AN spikes by
%calling meanlevelsunglecham[nnel multiple times.
%
% create output array
% unfortunately, the soundlength field in AN is faulty. We need to use the
% time of the last AN spike across all the channels
lasttime = 0 ;
for channel = 1: AN.channels
    if (~isempty(AN.signal{channel}) && (AN.signal{channel}(1, end) > lasttime))
        lasttime = AN.signal{channel}(1, end) ;
    end
end
% lasttime is in samples
endtime = floor(lasttime * resamplerate/AN.Fs) ; % endtime is in resamplerate samples
finalsignal2d = zeros([endtime AN.channels]) ;
for ch = 1: AN.channels
    if (type == 1) % use levels directly: logarithmic amplitude
        meanchan = meanlevelsinglechannel(ch, resamplerate, AN, endtime) ;
    else if (type == 2) % use AN.multiplier ^ level: linear amplitude
            meanchan = meanlevelsinglechannel_lin(ch, resamplerate, AN, endtime) ; % not yet written
        end
    end
    % and add it in (it should fit!)
    finalsignal2d(:, ch) = meanchan ;
end

end


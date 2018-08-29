function [ finalsignal2d ] = gabormultichannel(resamplerate, AN, gb5, type)
%gabormultichannel: Applies the gabor filter gb5 to all channels of AN
%signal
%   gabormultichannel computes a 2d array of size number of channels times
%   resampled length by adding up the gabor filter application to each
%   channel
%
% LSS started 10 Dec 2013.
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
[gbl, gbh] = size(gb5) ;
halfheight = floor(gbh/2) ;
if (gbh > AN.channels) disp(['gabormultichannel: ' 'Gabor height exceeds number of channels']) ;
end
for ch = 1: AN.channels
    if (type == 1) % use levels directly: logarithmic amplitude
        gaborchan = gaborsinglechannel(ch, resamplerate, AN, gb5, endtime) ;
    else if (type == 2) % use AN.multiplier ^ level: linear amplitude
            gaborchan = gaborsinglechannel_lin(ch, resamplerate, AN, gb5, endtime) ;
        end
    end
    % and add it in (as much as fits)
    if (ch - halfheight <= 0) % won't fit, falls off bottom
        finalsignal2d(:, 1:ch+halfheight) = finalsignal2d(:, 1:ch+halfheight) + gaborchan(:, 2 + (halfheight - ch):end) ;
    end
    if (ch + halfheight > AN.channels) % won't fit, falls off top: will only do both if height of gabor > number of channels
        finalsignal2d(:, ch - halfheight :end) = finalsignal2d(:, ch - halfheight :end) + gaborchan(:, 1:AN.channels - (ch - halfheight) + 1) ;
    end
    if ((ch - halfheight > 0) && (ch + halfheight <= AN.channels)) % add the lot
        finalsignal2d(:, ch-halfheight:ch+halfheight) = finalsignal2d(:, ch-halfheight:ch+halfheight) + gaborchan ;
    end
end

    
    


end


function [segments] = findsegments(signalin,sigma1, sigmaratio, dtperelement, nsamples, smoothlength)
%findsegments fimds segments in a sound (provided as an array)
%
% very simplest methid using half difference of gaussians on the original
% signal, unfiltered.
%   signalin: sound inoput as a narray
%   sigma1: faster gaussian
%   sigmaratio: slower gaussian = sigma1 * sigmaratio
%   dtperelement: time per sample
%   nsamples: number of samples in the convolving function
%   smoothlength is length of triangular (bartlett) window used to smooth
%   rectified signal prior to hdog filtering (in seconds)
debug = true ; 
wholegaussian = diffofgaussians(sigma1, sigma1 * sigmaratio, nsamples * 2 + 1,dtperelement) ;
hdog = wholegaussian(nsamples: end) ;
if (debug)
    disp(['findsegments: sum of half difference of Guassians = ' num2str(sum(hdog))]) ;
end
% rectify and smooth sound
rectsignal = abs(signalin) ;
bartlettlength = floor(smoothlength/dtperelement) ;
bartlettwindow = bartlett(bartlettlength) ;
bartlettwindow = bartlettwindow/sum(bartlettwindow) ; % normalise to sum of 1
rectsignal = conv(rectsignal, bartlettwindow, 'same') ;

% convolve signalin with hdog to produce onset/offset signal
oosignal = conv(rectsignal, hdog, 'same') ;
% 


segments = 0;
end


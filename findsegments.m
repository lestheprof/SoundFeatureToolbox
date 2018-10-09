function [segments] = findsegments(signalin,sigma1, sigmaratio, dtperelement, nsamples)
%findsegments fimds segments in a sound (provided as an array)
%
% very simplest methid using half difference of gaussians on the original
% signal, unfiltered.
%   signalin: sound inoput as a narray
%   sigma1: faster gaussian
%   sigmaratio: slower gaussian = sigma1 * sigmaratio
%   dtperelement: time per sample
%   nsamples: number of samples in the convolving function
debug = true ; 
wholegaussian = diffofgaussians(sigma1, sigma1 * sigmaratio, nsamples * 2 + 1,dtperelement) ;
hdog = wholegaussian(nsamples: end) ;
if (debug)
    disp(['findsegments: sum of half difference of Guassians = ' num2str(sum(hdog))]) ;
end
% convolve signalin with hdog to produce onset/offset signal
oosignal = conv(signalin, hdog, 'same') ;
% 

outputArg1 = inputArg1;
outputArg2 = inputArg2;
end


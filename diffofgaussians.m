function yvector = diffofgaussians(sigma1, sigma2, nsamples, stdperelement)
% create a vector of length nsampleswith a difference of gaussians (for +ve
% centre, sigma1 < sigma2)
% note that nsamples must be odd: the middle value will be the result at 0
% xdelta = (2 * max_x)/(nsamples -1) ;
xvector = [(-nsamples + 1)/2:(nsamples-1)/2] * stdperelement ;
yvector = (1/(2 * pi * sigma1) * exp(- (xvector .* xvector)/(2 * sigma1 * sigma1))) -  ...
    (1/(2 * pi * sigma2) * exp(- (xvector .* xvector)/(2 * sigma2 * sigma2))) ;


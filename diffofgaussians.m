function yvector = diffofgaussians(sigma1, sigma2, nsamples, dtperelement, varargin)
% create a vector of length nsampleswith a difference of gaussians (for +ve
% centre, sigma1 < sigma2)
% note that nsamples must be odd: the middle value will be the result at 0
% xdelta = (2 * max_x)/(nsamples -1) ;
% LSS updated 23 April 2019, to include normalisation via varargin
%
normalise = false ; % for compatibility with earlier versions
% varargin parameter setting
i = 1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'normalise'
            normalise = varargin{i+1};
            i=i+1 ;
        otherwise
            error('diffofgaussians: Unknown argument %s given',varargin{i});
    end
    i=i+1 ;
end
xvector = [(-nsamples + 1)/2:(nsamples-1)/2] * dtperelement ;
if ~normalise
yvector = (1/(2 * pi * sigma1) * exp(- (xvector .* xvector)/(2 * sigma1 * sigma1))) -  ...
    (1/(2 * pi * sigma2) * exp(- (xvector .* xvector)/(2 * sigma2 * sigma2))) ;
else
    normfactor = sum(1/(2 * pi * sigma1) * exp(- (xvector .* xvector)/(2 * sigma1 * sigma1))) ; % sum of one Gaussian
    yvector = ((1/(2 * pi * sigma1) * exp(- (xvector .* xvector)/(2 * sigma1 * sigma1))) -  ...
    (1/(2 * pi * sigma2) * exp(- (xvector .* xvector)/(2 * sigma2 * sigma2)))) / normfactor ;
end
end


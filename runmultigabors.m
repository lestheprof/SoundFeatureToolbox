function [ xx ] = runmultigabors(bandwidth, lambdamin, lambdastep, lambdamax ,  gamma ,theta, AN, type, display, varargin )
%runmultigabors run gabor filters over a range of bw's on AN
%   Calculates a set of gabor filters (but diesn't display them), then
%   runs them on AN. If type == 1 then it uses the levels directly, i.e.
%   logarithmic amplitude; if type == 2, then the levels are used linearly
%   if type == 3 then it uses the levels directly, but uses the absolute
%   values, and if type == 4 it uses the levels linearly, but with the
%   absoulte values of the Gabor filter.
%
% Calls gabor_fn_1 to set up the gabor patches, one by one, then calls
% gabormultichannel to convolve the patch with the spectrotemporal 2-d
% array
%
% LSS 12 12 13
%
% Updated Feb 2014:to use with a low final resampling rate, we still need
% to run the Gabor filter at a higher resampling rate (resample_gabor),
% then downsample the final signal to the final ourput rate
% (resample_final)
% create a range of gabor functions
%
% if zeromean is 1 then filters will have mean 0
zeromean = 0 ;
% gamma used is set so that the width should be constant, as set for bwmin.
resample_gabor = 2000 ; % resampling rate for Gabor filter
resample_final = resample_gabor ; % resampling rate for final output
szxvalue = 13 ;
szyvalue = 0 ; % if supplied to gabor_fn_1 as 0, then it is recomputed there
filename = '' ;

i=1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'resample_gabor';
            resample_gabor=varargin{i+1};
            i=i+1;
        case 'resample_final';
            resample_final=varargin{i+1};
            i=i+1;
        case 'szxvalue';
            szxvalue=varargin{i+1};
            i=i+1;
        case 'zeromean'
            zeromean = varargin{i+1};
            i=i+1;
        case 'filename'
            filename = varargin{i+1};
            i=i+1 ;
        case 'szyvalue'
            szyvalue = varargin{i+1};
            i=i+1 ;
            
        otherwise
            error('runmultigabors_abs: Unknown argument %s given',varargin{i});
    end
    i=i+1;
end
% bandwidth = 0.4 ; % (was 0.7) is now a parameter
if display > 1
    displaygabors = 1 ; % set to 1 to display the actual Gabor patches being used
    display = 1 ;
else displaygabors = 0 ;
end
% szxvalue = 13 ; % for compatibility with bandwidth of 0.7 and theta = pi/2 use 13
% initialise arrays used
gammaused = zeros([1 ceil((lambdamax-lambdamin)/lambdastep)]) ;
% difficult to initialise gbpatch because we don't know what size it will
% be till we call gabor_fn_1
index = 1 ;
for lambda = lambdamin:lambdastep:lambdamax
    gammaused(index) = gamma*(lambda/lambdamin) ;
    gb = gabor_fn_1(bandwidth,gammaused(index),0,lambda, theta, displaygabors,'szx', szxvalue, 'szy', szyvalue) ;
    gbpatch{index} = gb ;
    % correct filter to zero-mean
    if zeromean
        gbpatch{index} = gbpatch{index} - mean(mean(gb)) ;
    end
    index = index + 1 ;
end
% run them
for gbno = 1:index-1
    if type <= 2
        gaborconvolve = gabormultichannel(resample_gabor, AN, gbpatch{gbno}, type) ;
    else
        if type <= 4
            gaborconvolve = gabormultichannel_abs(resample_gabor, AN, gbpatch{gbno}, type - 2) ;
        else error(['runmultigabors: invalid type parameter = ' num2str(type)]) ;
        end
    end
    % do we need to downsample?
    if (resample_final < resample_gabor)
        % donwsample gaborconolve (which is n_samples long by number of
        % channels) to the resample_final sampling rate
        xx{gbno} = resample(gaborconvolve, resample_final, resample_gabor) ; % from sig proc toolbox
    else
        xx{gbno} = gaborconvolve ;
    end
    if display
        % note that imagesc is being used, because image() ignores values <
        % 0
        figure('Name', [filename 'Gabor Convolution']) ;
        % find max and min values for xx{gbno}, set so that 0 is midpoint
        top = max(max(xx{gbno})) ;
        bot = min(min(xx{gbno})) ;
        lim = max(top, -bot) ;
        imagesc(xx{gbno}') ; set(gca, 'YDir', 'normal') ; set(gca, 'CLim', [-lim lim]) ;
        clim = get(gca, 'CLim') ;
        % annotate
        if (type > 2)
            title(['ABS: bw=' num2str(bandwidth) ' gamma=' num2str(gammaused(gbno)) ' psi=' num2str(0) ' lambda=' num2str(lambdamin + (gbno -1) * lambdastep) ...
                ' theta=' num2str(theta) ' szx=' num2str(szxvalue) , ' CLim=', num2str(clim(1)), ',', num2str(clim(2)) ]);
        else
            title(['Pos and Neg: : bw=' num2str(bandwidth) ' gamma=' num2str(gammaused(gbno)) ' psi=' num2str(0) ' lambda=' num2str(lambdamin + (gbno -1) * lambdastep) ...
                ' theta=' num2str(theta) ' szx=' num2str(szxvalue) , ' CLim=', num2str(clim(1)), ',', num2str(clim(2)) ]);
        end
    end
%     if min(min(xx{1})) < 0
%         disp(['runmiltigabors oddity']) ;
%     end
end

end


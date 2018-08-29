function [ icas1d, icas2d, proj ] = makeICAs_altogether(datastruct, ndisplay, varargin)
%makeICAs_altogether Run ICA's on the concatenated dataset
%   Needs work to be done to cope with more than 2 Gabors
% 
% modified 1 April 2014: by default set lastEig equal to numOfIC: in this
% way, we are (I understand, (i) reducing the dimensionality of the PCAs
% so that we are looking at the ICAs of a no0n-full-rank PCA matrix. 
i=1 ;
infostr = '' ;
subplotting = 0 ;
numOfIC = 20 ; %default number of of ICAs to generate
lastEig = numOfIC ; % default number of eigenvalues to use in ICA.
segmentsummary = 0 ; % default: if 1 then 1 output/segment
ngabors = 2 ;

while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'infostr'
            infostr = varargin{i+1};
            i = i+2 ;
        case 'subplot'
            subplotting = varargin{i+1};
             i = i+2 ;
        case 'numofic'
            numOfIC = varargin{i+1};
             i = i+2 ;
        case 'lasteig'
            lastEig = varargin{i+1};
             i = i+2 ;       
        case 'segmentsummary'
            segmentsummary = varargin{i+1};
            i = i+2 ;
        case 'ngabors'
            ngabors = varargin{i+1};
            i = i+2 ;
        otherwise
            error('makeICAs_altogether: Unknown argument %s given',varargin{i});
            %             case 'SaveAN' % save the AN spikes as well: default is don't
            %                 savean = varargin{i+1};  % saving of AN spikes as well
    end
end

if ~segmentsummary
    % concatenate the arrays into a single large vector
    s1array = [datastruct.meansoutputarray/std(datastruct.meansoutputarray(:)) ...
    datastruct.meansonsetarray/std(datastruct.meansonsetarray(:))] ;
    for i = 1:ngabors
        g1 = squeeze(datastruct.meansgaborarray(i,:,:,:)) ;
        s1array = [s1array g1/std(g1(:))] ;

    end
else
    % allocate s1array
    % compact every L0, L1 element to a single vector
    % each is number of values * time * number of channels
    [numvects, ~, numchans] = size(datastruct.meansoutputarray) ;
    ng = size(datastruct.meansgaborarray,1) ;
    if (ng ~= ngabors)
        error('makePCAs_altogether: number of Gabors stated not equal to number in datastructure') ;
    end
    s1array = zeros([numvects ngabors+2 numchans]) ;
    s1array(:, 1,:) = squeeze(sum(datastruct.meansoutputarray,2)) ;
    s1array(:,2,:) = squeeze(sum(datastruct.meansonsetarray,2)) ;
    for gno = 1:ngabors
        gabor1 = squeeze(datastruct.meansgaborarray(gno,:,:,:)) ;
        s1array(:,gno+2, :) = squeeze(sum(gabor1,2)) ;
    end
end
    

% then run ICA on it
[ icas1d, icas2d, proj ] = makeICAs(s1array,ndisplay, 'infostr',infostr, 'subplot', subplotting, 'numOfIC', numOfIC, 'lastEig', lastEig) ;

end


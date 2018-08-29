function [ projections ] = usePCAs_altogether(datastruct, pca_array, npcas, varargin)
%usePCAs_altogether: Take the datastruct, and produce the vectors to be
%projected using the pca matrix
%
% syarted LSS 26 March 2014

i=1 ;
infostr = '' ;
subplotting = 0 ;
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
        case 'segmentsummary'
            segmentsummary = varargin{i+1};
            i = i+2 ;
        case 'ngabors'
            ngabors = varargin{i+1};
            i = i+2 ;
        otherwise
            error('generatemeanlevelonset_mono: Unknown argument %s given',varargin{i});
            %             case 'SaveAN' % save the AN spikes as well: default is don't
            %                 savean = varargin{i+1};  % saving of AN spikes as well
    end
end

if ~segmentsummary
    % concatenate the arrays into a single large vector
    s1array = [datastruct.meansoutputarray/std(datastruct.meansoutputarray(:)) ...
    datastruct.meansonsetarray/std(datastruct.meansonsetarray(:))] ;
    for i = 1:ngabors
        % needs a fix if there's only one segment: otherwise seueeze works
        % rather too well, and reduces dimensionality of matrix to 2,
        % rather than 3.
        g1 = squeeze(datastruct.meansgaborarray(i,:,:,:)) ;
        if ndims(g1) == 2
            g1 = reshape(g1, [1 size(g1)]) ;
        end
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
    
    % s1array contains the data to be projected using the pcas
% reshape s1array for use with the pcas
[nseg, ntime,nchans] = size(s1array) ;
s1arrayr = reshape(s1array, [nseg ntime * nchans]) ;
proj = s1arrayr * pca_array ; % has full rank
projections = proj(:,1:npcas) ;

end


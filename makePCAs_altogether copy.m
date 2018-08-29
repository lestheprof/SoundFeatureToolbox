function [ pcas ] = makePCAs_altogether(datastruct, ndisplay, varargin)
%makePCAs_altogether Run PCA's on the concatenated dataset
%   Needs work to be done to cope with more than 2 Gabors

i=1 ;
infostr = '' ;
subplotting = 0 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'infostr'
            infostr = varargin{i+1};
            i = i+2 ;
        case 'subplot'
            subplotting = varargin{i+1};
            i = i+2 ;
        otherwise
            error('generatemeanlevelonset_mono: Unknown argument %s given',varargin{i});
            %             case 'SaveAN' % save the AN spikes as well: default is don't
            %                 savean = varargin{i+1};  % saving of AN spikes as well
    end
end

% concatenate the arrays into a single large vector
g1 = squeeze(datastruct.meansgaborarray(1,:,:,:)) ;
g2 = squeeze(datastruct.meansgaborarray(2,:,:,:)) ;

s1array = [datastruct.meansoutputarray/std(datastruct.meansoutputarray(:)) ...
    datastruct.meansonsetarray/std(datastruct.meansonsetarray(:))  g1/std(g1(:)) ...
    g2/std(g2(:)) ] ;
% then run PCA on it
pcas = makePCAs(s1array,ndisplay, 'infostr',infostr, 'subplot', subplotting) ;

end


function  plotimage( xx, titledata, varargin )
%plotimage for quick plot of recangular matrices
%   simply plots 2 D xx with text title titledata

i=1 ;
subplotting = 0 ; 
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'subplot'
            subplotting = varargin{i+1};
            i = i+2 ;
        otherwise
            error('plotimage: Unknown argument %s given',varargin{i});
            %             case 'SaveAN' % save the AN spikes as well: default is don't
            %                 savean = varargin{i+1};  % saving of AN spikes as well
    end
end

if (~subplotting)
    figure('Name', titledata) ; % create figure if not part of a subplot
end
% find max and min values for xx{gbno}, set so that 0 is midpoint
top = max(max(xx)) ;
bot = min(min(xx)) ;
% lim = max(top, -bot) ;
imagesc(xx') ; set(gca, 'YDir', 'normal') ; set(gca, 'CLim', [bot top]) ;
clim = get(gca, 'CLim') ;
title(['Info = ' titledata , ' CLim=', num2str(clim(1)), ',', num2str(clim(2)) ]);
end


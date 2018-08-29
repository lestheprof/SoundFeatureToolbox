function [ signalmean ] = runmultimeans(resample, AN, type, display )
%runmultimeans simply takes the AN spikes and returns an array with values
%calculated from them, at the stated resampling rate.
%

% resample = 2000 ;

% run them
    if type <= 2
        signalmean = meanlevelmultichannel(resample, AN,  type) ;
    else
        error(['runmultimeans: invalid type parameter = ' num2str(type)]) ;
    end
    if display
        % note that imagesc is being used, because image() ignores values <
        % 0
        figure('Name', 'Level 0 means')  ;   
        % find max and min values for xx{gbno}, set so that 0 is midpoint
        top = max(max(signalmean)) ;
        bot = min(min(signalmean)) ;
        lim = max(top, -bot) ;
        imagesc(signalmean') ; set(gca, 'YDir', 'normal') ; set(gca, 'CLim', [-lim lim]) ;
        clim = get(gca, 'CLim') ; 
        % annotate
        title(['resample=',  num2str(resample), ' CLim=', num2str(clim(1)), ',', num2str(clim(2)) ]);
    end
end



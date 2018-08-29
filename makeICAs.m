function [ icas1d, icas2d,  proj ] = makeICAs( largematrix, numtodisplay, varargin )
%makeICAs calculate and return a number of ICAs. Default is 20, use numOfIC in varargin
% to alter. Uses 1st 100 eigenvalues. ICAs for largematrix, displaying the first
%numtoidisplay of them
%
% returns 
% icas1d which is (timesteps * number of channels) by number of ICAs
% icas2d, which is timestepps by number of channels by number of
% ICAs, and 
% proj which is numfOfIC by number of values in largematrix (1st
% dimension).
%
% lss 6 march 2014.
% bug fix 22 4 2014: 2d ICA output were not reshape'd correctly.
%
i=1 ;
infostr = '' ;
subplotting = 0 ;
numOfIC =20 ; % number of ICAS to generate
lastEig = 100 ; % last eigenvalue to use
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
        otherwise
            error('makeICAs: Unknown argument %s given',varargin{i});
            %             case 'SaveAN' % save the AN spikes as well: default is don't
            %                 savean = varargin{i+1};  % saving of AN spikes as well
    end
end
if (numtodisplay > 0) % ignore if nothing to plot
    displayfactors = factor(numtodisplay) ; % only relevant if subplotting
    if (length(displayfactors) >= 2)
        numrows = prod(displayfactors(2:end)) ;
    else
        numrows = displayfactors(1) ;
    end
    if (subplotting) % if no subplot, then call to figure is in plotimage
        figure ;
    end
end
% find number of dimensions of the matrix
numdims = ndims(largematrix) ;
if (numdims == 3)
    % find the PCAs
    % reshape the array
    [numvals, tdim, fdim] = size(largematrix) ;
    reshapedarray = reshape(largematrix, [numvals fdim*tdim]) ;
    % which is thr correct projecting matrix?
    % [proj, icas1d, ~ ] = fastica(reshapedarray','numOfIC', numOfIC, 'displayMode', 'off', 'lastEig', lastEig) ;
    [proj, ~ , icas1d] = fastica(reshapedarray','numOfIC', numOfIC, 'displayMode', 'off', 'lastEig', lastEig) ;

    % un-reshape the icas
    % bug fix 22 4 2014
    icas2d = reshape(icas1d,[numOfIC tdim fdim ]) ;
    % display some of them
    % display some of them  NB don't make numtodisplay a prime!
    
    for dno = 1:numtodisplay
        if subplotting
            subplot(displayfactors(1), numrows, dno) ;
        end
        plotimage(squeeze(icas2d(:,:,dno)),['ICA ' num2str(dno) infostr],'subplot', subplotting) ;
    end
else if (numdims == 4)
        [numtypes, numvals, tdim, fdim] = size(largematrix) ;
        for gbnos = 1: numtypes
            largematrix1 = squeeze(largematrix(gbnos, :,:,:)) ;
            
            % find the PCAs
            % reshape the array
            [numvals, tdim, fdim] = size(largematrix1) ;
            reshapedarray = reshape(largematrix1, [numvals fdim*tdim]) ;
            [proj, icas1d, ~ ] = fastica(reshapedarray','numOfIC', numOfIC, 'displayMode', 'off', 'lastEig', lastEig) ;
             % un-reshape the icas
             % bug fix 22 4 2014
            icas2d = reshape(icas1d,[numOfIC tdim fdim ]) ;

            
            
            for dno = 1:numtodisplay
                if subplotting
                    subplot(displayfactors(1), numrows, dno) ;
                end
                plotimage(squeeze(icas2d(:,:,dno)), ...
                    ['Set = ' num2str(gbnos) ' ICA ' num2str(dno)  infostr],...
                    'subplot', subplotting) ;
            end
            if subplotting
                title(['ICA ' infostr]) ;
            end
        end
        
    else error(['makePCAs: dimension of input matrix neither 3 nor 4']) ;
    end
    
    
end


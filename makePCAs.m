function [ pcas ] = makePCAs( largematrix, numtodisplay, varargin )
%makePCAs calculate and return PCAs for lagematrix, displaying the first
%numtoidisplay of them
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
    [pcas , ~, latencies] = pca(reshapedarray) ;
    % un-reshape the pcas
    pcasfordisplay = reshape(pcas, [tdim fdim fdim * tdim]) ;
    % display some of them
    % display some of them  NB don't make numtodisplay a prime!
    
    for dno = 1:numtodisplay
        if subplotting
            subplot(displayfactors(1), numrows, dno) ;
        end
        plotimage(squeeze(pcasfordisplay(:,:,dno)),['PCA ' num2str(dno) ' latency =   ' num2str(latencies(dno), 2) '\newline' infostr],'subplot', subplotting) ;
    end
else if (numdims == 4)
        [numtypes, numvals, tdim, fdim] = size(largematrix) ;
        for gbnos = 1: numtypes
            largematrix1 = squeeze(largematrix(gbnos, :,:,:)) ;
            
            % find the PCAs
            % reshape the array
            [numvals, tdim, fdim] = size(largematrix1) ;
            reshapedarray = reshape(largematrix1, [numvals fdim*tdim]) ;
            [pcas , ~, latencies] = pca(reshapedarray) ;
            % un-reshape the pcas
            pcasfordisplay = reshape(pcas, [tdim fdim fdim * tdim]) ;
            
            
            for dno = 1:numtodisplay
                if subplotting
                    subplot(displayfactors(1), numrows, dno) ;
                end
                plotimage(squeeze(pcasfordisplay(:,:,dno)), ...
                    ['Set = ' num2str(gbnos) ' PCA ' num2str(dno) ' latency =  ' num2str(latencies(dno), 2) '\newline' infostr],...
                    'subplot', subplotting) ;
            end
            if subplotting
                title(['PCA ' infostr]) ;
            end
        end
        
    else error(['makePCAs: dimension of input matrix neither 3 nor 4']) ;
    end
    
    
end


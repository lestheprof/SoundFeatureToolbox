function qualityfigure = compareclusters_fn(f1)
% compareclusters_fn: takes in the results of the clustering, and returns
% an array of the quality figures for these clusters.
% f1 and m1 are generated from processclusters_fn
% thwe quality figure is a normalised version of
% epsilon_max/Sigma(epslion_i) over all the phonemes in all the clusters.
% Note thatthis will also depend on the value uased for const_phonfraction
% in processclusters_fn.

[numcomponents, numclusters] = size(f1) ;
qualityfigure = zeros([numcomponents numclusters]) ;
for compno = 1:numcomponents
    for numclust=1:numclusters
        % disp(['compareclusters_fn ' num2str(compno), ' ' num2str(numclust)]) ;
        % try on f1 first
        %create a list of phonemes in order
        totalphonemes = [] ;
        for clno = 1:length(f1{compno, numclust}.pcamodephonemes)
            totalphonemes = [totalphonemes; f1{compno, numclust}.pcamodephonemes{clno}] ;
        end
        utotalphonemes = unique(totalphonemes) ;
        % put the pcamodephonemes lists in order, putting the pcaphonfreqclust in
        % order at the same time
        for clno = 1:length(f1{compno, numclust}.pcamodephonemes)
            [sfpcamodeph{clno}, remap]= sort(f1{compno, numclust}.pcamodephonemes{clno}) ;
            sfpcaphonfreq{clno} = f1{compno, numclust}.pcaphonfreqclust{clno}(remap) ;
        end
        % create array to put occurrences into
        allphonemes = zeros([length(utotalphonemes) length(f1{compno, numclust}.pcamodephonemes)]) ;
        % put in the values for each cluster
        for clno = 1:length(f1{compno, numclust}.pcamodephonemes)
            cpno = 1 ;
            for pno = 1:length(utotalphonemes)
                if (cpno <= length(sfpcamodeph{clno}))
                    if (strcmp(utotalphonemes(pno), sfpcamodeph{clno}(cpno)))
                        allphonemes(pno, clno) = sfpcaphonfreq{clno}(cpno) ;
                        cpno = cpno + 1 ;
                    end
                end
            end
        end
        % now calculate a score
        for pno = 1:length(utotalphonemes)
            % epsilon = epsilon_max/Sigma(epslion_i)
            % calculate Sigma(epsilon_i)
            sigepsilon = sum(allphonemes(pno,:)) ;
            maxepsilon = max(allphonemes(pno,:)) ;
            qualityfigure(compno, numclust) = qualityfigure(compno, numclust) + maxepsilon/sigepsilon ; % would like to be near 1
        end
        qualityfigure(compno, numclust) = qualityfigure(compno, numclust)/length(utotalphonemes) ;
        
    end
end
end








const_phonfraction = 0.5 ;
% find the phonemes in the clusters
%
% female first
%
% deal with PCA first
for  i = 1:n_clusters_pca % for each cluster
    pcaphonemes{i} = f1.segmentphoneme(line1to8_km5_pca == i) ; % find the phonemes in this cluster
    % find the list of phonemes, and the index in that list of each
    [pcaphonemesunique{i}, ~, pcaphuid{i}] = unique(pcaphonemes{i}) ;
    
    % now find the most frequently occurring phonemes in each of the
    % n_clusters_pca lists.
    numphonemes = length(pcaphonemes{i}) ;
    % intiialise arrays
    modeno = zeros([1 floor(numphonemes/2)]) ;
    phonfreq = zeros([1 floor(numphonemes/2)]) ;
    totalfrequency = 0 ;
    phonsinlist = 0 ;
    pcaphuidtemp = pcaphuid{i} ;
    while (totalfrequency < (numphonemes * const_phonfraction))
        phonsinlist = phonsinlist + 1 ;
        [modeno(phonsinlist), phonfreq(phonsinlist)] = mode(pcaphuidtemp) ;
        pcaphuidtemp= pcaphuidtemp(pcaphuidtemp ~= modeno(phonsinlist)) ;
        totalfrequency = totalfrequency + phonfreq(phonsinlist) ;
    end
    %modeno now has the most common phonemes indexes, and phonfreq has the
    %frequency of each. Now put the actual phoneme into an array
    pcamodephonemes{i} = pcaphonemesunique{i}(modeno(1:phonsinlist)) ;
    pcaphonfreqclust{i} = phonfreq(1:phonsinlist) ;

end
% and ICAs
for  i = 1:n_clusters_ica % for each cluster
    icaphonemes{i} = f1.segmentphoneme(line1to8_km5_ica == i) ; % find the phonemes in this cluster
    % find the list of phonemes, and the index in that list of each
    [icaphonemesunique{i}, ~, icaphuid{i}] = unique(icaphonemes{i}) ;
    
    % now find the most frequently occurring phonemes in each of the
    % n_clusters_pca lists.
    numphonemes = length(icaphonemes{i}) ;
    % intiialise arrays
    modeno = zeros([1 floor(numphonemes/2)]) ;
    phonfreq = zeros([1 floor(numphonemes/2)]) ;
    totalfrequency = 0 ;
    phonsinlist = 0 ;
    icaphuidtemp = icaphuid{i} ;
    while (totalfrequency < (numphonemes * const_phonfraction))
        phonsinlist = phonsinlist + 1 ;
        [modeno(phonsinlist), phonfreq(phonsinlist)] = mode(icaphuidtemp) ;
        icaphuidtemp= icaphuidtemp(icaphuidtemp ~= modeno(phonsinlist)) ;
        totalfrequency = totalfrequency + phonfreq(phonsinlist) ;
    end
    %modeno now has the most common phonemes indexes, and phonfreq has the
    %frequency of each. Now put the actual phoneme into an array
    icamodephonemes{i} = icaphonemesunique{i}(modeno(1:phonsinlist)) ;
    icaphonfreqclust{i} = phonfreq(1:phonsinlist) ;

end



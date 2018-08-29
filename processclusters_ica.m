function [fem, male] = processclusters_ica(timitlocn, vdirectory, segmentsfile, icafile , varargin)
% processclusters_fn: using the segments in the segmentsfile, and the
% clusters in the clustersfile, find and return the phonemes (and their
% frequencies) in each cluster

% LSS 10 March 2014.
const_phonfraction = 0.5 ; % fraction of phonemesin those returned.
i=1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'const_phonfraction';
            const_phonfraction=varargin{i+1};
            i=i+1;
            
        otherwise
            error('processclusters_fn: Unknown argument %s given',varargin{i});
    end
    i=i+1;
end
%
% read the segmentsfiles
% we only need f1 and m1 from them
segdata = load([timitlocn '/' vdirectory '/' segmentsfile]) ;
% read the clustersfile
clustdata_m = load([timitlocn '/' vdirectory '/' clustersfile '_m']) ;
clustdata_f = load([timitlocn '/' vdirectory '/' clustersfile '_f']) ;

% female first
%
% deal with PCA first

for  i = 1:clustdata_f.pcaparams.clusters_pca % for each cluster
    pcaphonemes{i} = segdata.f1.segmentphoneme(clustdata_f.line1to8_km5_pca == i) ; % find the phonemes in this cluster
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
    fem.pcamodephonemes{i} = pcaphonemesunique{i}(modeno(1:phonsinlist)) ;
    fem.pcaphonfreqclust{i} = phonfreq(1:phonsinlist) ;
    fem.pcaphons(i) = numphonemes ;
    
end
% and ICAs

for  i = 1:clustdata_f.icaparams.clusters_ica % for each cluster
    icaphonemes{i} = segdata.f1.segmentphoneme(clustdata_f.line1to8_km5_ica == i) ; % find the phonemes in this cluster
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
    fem.icamodephonemes{i} = icaphonemesunique{i}(modeno(1:phonsinlist)) ;
    fem.icaphonfreqclust{i} = phonfreq(1:phonsinlist) ;
    fem.icaphons(i) = numphonemes ;
    
end
% male next
%
% deal with PCA first
for  i = 1:clustdata_m.pcaparams.clusters_pca % for each cluster
    pcaphonemes{i} = segdata.m1.segmentphoneme(clustdata_m.line1to8_km5_pca == i) ; % find the phonemes in this cluster
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
    male.pcamodephonemes{i} = pcaphonemesunique{i}(modeno(1:phonsinlist)) ;
    male.pcaphonfreqclust{i} = phonfreq(1:phonsinlist) ;
    male.pcaphons = numphonemes ;
    
end
% and ICAs
for  i = 1:clustdata_m.icaparams.clusters_ica % for each cluster
    icaphonemes{i} = segdata.m1.segmentphoneme(clustdata_m.line1to8_km5_ica == i) ; % find the phonemes in this cluster
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
    male.icamodephonemes{i} = icaphonemesunique{i}(modeno(1:phonsinlist)) ;
    male.icaphonfreqclust{i} = phonfreq(1:phonsinlist) ;
    male.icaphons = numphonemes ;
    
end
end




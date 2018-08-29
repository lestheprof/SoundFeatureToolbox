function clusterica_fn(timitlocn, vdirectory, ngabors, outputfilename, varargin)
% clusterpcaica_fn: performs clustering of the PCA and ICA datasets
% was previously a script

% lss 5 March 2014: started
% turned into a function 10 March 2014..
%
% modded 1 4 2014, just to do ICAs. PCAs are different

%location of stem
if isempty(timitlocn) % default value
    timitlocn = '/Volumes/MacHD2/Researchshare/timit3/AU_TIMIT' ;
end


n_clusters_ica = 200 ; % number of clusters to use in kmeans clustering: for ica
segmentsummary = 0 ;
i=1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        
        case 'clusters_ica'
            n_clusters_ica = varargin{i+1};
            i=i+1;
        case 'segmentsummary'
            segmentsummary = varargin{i+1};
            i=i+1;
            
        otherwise
            error('clusterica_fn: Unknown argument %s given',varargin{i});
    end
    i=i+1;
end


icaparams.clusters_ica = n_clusters_ica ;

% get the ICA data in
i1 = load([timitlocn '/' vdirectory '/expt_all_ICA20.mat']) ;
%
% Female first
% get the vectors and other information in
f1 = load([timitlocn '/' vdirectory '/expt_female_vectors.mat']) ;
% create the matrix, same as was used in PCA/ICA generation
% put together the different arrays, normalised for standard deviation.
if ~segmentsummary
    % concatenate the arrays into a single large vector
    s1array = [f1.meansoutputarray/std(f1.meansoutputarray(:)) ...
        f1.meansonsetarray/std(f1.meansonsetarray(:))] ;
    for i = 1:ngabors
        g1 = squeeze(f1.meansgaborarray(i,:,:,:)) ;
        s1array = [s1array g1/std(g1(:))] ;
        
    end
else
    % allocate s1array
    % compact every L0, L1 element to a single vector
    % each is number of values * time * number of channels
    [numvects, ~, numchans] = size(f1.meansoutputarray) ;
    ng = size(f1.meansgaborarray,1) ;
    if (ng ~= ngabors)
        error('makePCAs_altogether: number of Gabors stated not equal to number in datastructure') ;
    end
    s1array = zeros([numvects ngabors+2 numchans]) ;
    s1array(:, 1,:) = squeeze(sum(f1.meansoutputarray,2)) ;
    s1array(:,2,:) = squeeze(sum(f1.meansonsetarray,2)) ;
    for gno = 1:ngabors
        gabor1 = squeeze(f1.meansgaborarray(gno,:,:,:)) ;
        s1array(:,gno+2, :) = squeeze(sum(gabor1,2)) ;
    end
end

% get sizes for reshaping: num is number of segments, a1 is sum of the
% number of elemnts (in time) of each of the arratys concatenated into
% s1array, a2 is the number of channels used (needs to be the same
% throughout the arrays concatenated together).
[num, a1, a2] = size(s1array) ;
% reshape to a 2D array: required for PCA or ICA
s1arrayr = reshape(s1array,[num a1*a2]) ;
% now project the s1arrayr through the n_clusters_ica (=n_icas)
% vectors, and find out which gives the larges (modulus) value
projections_f1 = i1.proj_f' ;
% this should be the same as doing the projection on a zero-mean array:
% check
% calculate zero-mean array
s1arrayrmean = mean(s1arrayr,2) ;
s1arrayrmeanfull = repmat(s1arrayrmean, 1, a1*a2) ;
s1arrayrzmean = s1arrayr - s1arrayrmeanfull ;
projections_f = s1arrayrzmean * i1.icas1d_f' ; % will be large_number by 200
% (in fact, this is already in i1.proj_f')
% now find the  index of the largest elements
[line1icamaxval, line1to8_km5_ica] = max(projections_f1, [], 2) ;
[line1icamaxval_a, line1to8_km5_ica_a] = max(projections_f, [], 2) ;

% line1to8_km5_ica should be <large number> by 1


save([timitlocn '/' '/' vdirectory '/' outputfilename '_ica_f'],  'line1to8_km5_ica', 'line1icamaxval',  'line1to8_km5_ica_a', 'line1icamaxval_a' , 'icaparams') ;

% male
m1 = load([timitlocn '/' vdirectory '/expt_male_vectors.mat']) ;
% create the matrix, same as was used in PCA/ICA generation
% put together the different arrays, normalised for standard deviation.
if ~segmentsummary
    % concatenate the arrays into a single large vector
    s1array = [m1.meansoutputarray/std(m1.meansoutputarray(:)) ...
        m1.meansonsetarray/std(m1.meansonsetarray(:))] ;
    for i = 1:ngabors
        g1 = squeeze(m1.meansgaborarray(i,:,:,:)) ;
        s1array = [s1array g1/std(g1(:))] ;
        
    end
else
    % allocate s1array
    % compact every L0, L1 element to a single vector
    % each is number of values * time * number of channels
    [numvects, ~, numchans] = size(m1.meansoutputarray) ;
    ng = size(m1.meansgaborarray,1) ;
    if (ng ~= ngabors)
        error('makePCAs_altogether: number of Gabors stated not equal to number in datastructure') ;
    end
    s1array = zeros([numvects ngabors+2 numchans]) ;
    s1array(:, 1,:) = squeeze(sum(m1.meansoutputarray,2)) ;
    s1array(:,2,:) = squeeze(sum(m1.meansonsetarray,2)) ;
    for gno = 1:ngabors
        gabor1 = squeeze(m1.meansgaborarray(gno,:,:,:)) ;
        s1array(:,gno+2, :) = squeeze(sum(gabor1,2)) ;
    end
end

% get sizes for reshaping: num is number of segments, a1 is sum of the
% number of elemnts (in time) of each of the arratys concatenated into
% s1array, a2 is the number of channels used (needs to be the same
% throughout the arrays concatenated together).
[num, a1, a2] = size(s1array) ;
% reshape to a 2D array: required for PCA or ICA
s1arrayr = reshape(s1array,[num a1*a2]) ;
% now project the s1arrayr through the n_clusters_ica (=n_icas)
% vectors, and find out which gives the larges (modulus) value
projections_m1 = i1.proj_m' ;
% this should be the same as doing the projection on a zero-mean array:
% check
% calculate zero-mean array
s1arrayrmean = mean(s1arrayr,2) ;
s1arrayrmeanfull = repmat(s1arrayrmean, 1, a1*a2) ;
s1arrayrzmean = s1arrayr - s1arrayrmeanfull ;

projections_m = s1arrayrzmean * i1.icas1d_m' ; % will be large_number by 200

% (in fact, this is already in i1.proj_m')
% now find the  index of the largest elements
[line1icamaxvalm, line1to8_km5_icam] = max(projections_m1, [], 2) ;
[line1icamaxvalm_a, line1to8_km5_icam_a] = max(projections_m, [], 2) ;

% line1to8_km5_ica should be <large number> by 1



save([timitlocn '/' vdirectory '/' outputfilename '_ica_m'],  'line1to8_km5_icam', 'line1icamaxvalm' ,  'line1to8_km5_icam_a', 'line1icamaxvalm_a' , 'icaparams') ;
end




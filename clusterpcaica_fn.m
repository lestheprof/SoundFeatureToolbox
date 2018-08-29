function clusterpcaica_fn(timitlocn, vdirectory, ngabors, outputfilename, varargin)
% clusterpcaica_fn: performs clustering of the PCA and ICA datasets
% was previously a script

% lss 5 March 2014: started
% turned into a function 10 March 2014..

%location of stem
if isempty(timitlocn) % default value
    timitlocn = '/Volumes/MacHD2/Researchshare/timit3/AU_TIMIT' ;
end

n_pcastouse = 8 ; % number of PCA clusters to use
n_icastouse = 8 ; % number of ICA clusters to use
n_clusters_pca = 5 ; % number of clusters to use in kmeans clustering: for pca
n_clusters_ica = 5 ; % number of clusters to use in kmeans clustering: for ica
segmentsummary = 0 ;
i=1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'pcastouse';
            n_pcastouse=varargin{i+1};
            i=i+1;
        case 'icastouse';
            n_icastouse=varargin{i+1};
            i=i+1;
        case 'clusters_pca';
            n_clusters_pca=varargin{i+1};
            i=i+1;
        case 'clusters_ica'
            n_clusters_ica = varargin{i+1};
            i=i+1;
        case 'segmentsummary'
            segmentsummary = varargin{i+1};
            i=i+1;
            
        otherwise
            error('clusterpcaica_fn: Unknown argument %s given',varargin{i});
    end
    i=i+1;
end

pcaparams.pcastouse = n_pcastouse ;
icaparams.icastouse = n_icastouse ;
pcaparams.clusters_pca = n_clusters_pca ;
icaparams.clusters_ica = n_clusters_ica ;

if n_pcastouse > 0
    % get the PCA data in
    p1 = load([timitlocn '/' vdirectory '/expt_all_PCA.mat']) ;
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
    % generate the first n_pcastouse PCAs
    line1to8pca = s1arrayr * p1.pcas_female(:,1:n_pcastouse) ;
    
    % Cluster them: produce the projections (N (number of segments) by
    % n_pcastouse), and the centres (n_clusters_pca by n_pcastouse)
    [line1to8_km5_pca, cpca5] = kmeans(line1to8pca, n_clusters_pca) ;
else
    line1to8_km5_pca = [] ;
    cpca5 = [] ;
end

if n_icastouse > 0
    % same for ica
    i1 = load([timitlocn '/' vdirectory '/expt_all_ICA20.mat']) ;
    % line1to8ica = s1arrayr * i1.b(:,1:n_icastouse) ;
    line1to8ica = i1.proj_f' ;
    % Cluster them: produce the projections (N (number of segments) by
    % n_icastouse), and the centres (n_clusters_ica by n_icastouse)
    [line1to8_km5_ica, cica5] = kmeans(line1to8ica, n_clusters_ica) ;
else
    line1to8_km5_ica = [] ;
    cica5 = [] ;
end
save([timitlocn '/' '/' vdirectory '/' outputfilename '_f'], 'line1to8_km5_pca', 'line1to8_km5_ica', 'cpca5', 'cica5', 'pcaparams', 'icaparams') ;

% male
if n_pcastouse > 0
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
    % generate the first n_pcastouse PCAs
    line1to8pca = s1arrayr * p1.pcas_female(:,1:n_pcastouse) ;
    
    % Cluster them: produce the projections (N (number of segments) by
    % n_pcastouse), and the centres (n_clusters_pca by n_pcastouse)
    [line1to8_km5_pca, cpca5] = kmeans(line1to8pca, n_clusters_pca) ;
else
    line1to8_km5_pca = [] ;
    cpca5 = [] ;
end

if n_icastouse > 0
    
    % same for ica
    % i1 = load([timitlocn '/Vectors250/expt_all_ICA20.mat']) ;
    % line1to8ica = s1arrayr * i1.b(:,1:n_icastouse) ;
    line1to8ica = i1.proj_m' ;
    % Cluster them: produce the projections (N (number of segments) by
    % n_icastouse), and the centres (n_clusters_ica by n_icastouse)
    [line1to8_km5_ica, cica5] = kmeans(line1to8ica, n_clusters_ica) ;
else
    line1to8_km5_ica = [] ;
    cica5 = [] ;
end

save([timitlocn '/' vdirectory '/' outputfilename '_m'], 'line1to8_km5_pca', 'line1to8_km5_ica', 'cpca5', 'cica5','pcaparams', 'icaparams') ;
end




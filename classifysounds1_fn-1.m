function [classifications_pca, classifications_ica, segOut] = classifysounds1_fn(soundlocation, filelist, soundclasslocation, ANSigDir, AMMeanPlain250, onsetSigdir, onsetMeans250, ...
    gaborparamsall,outputdir, projectiondir, varargin)
% classifysounds_fn: takeas in a sound, AN's it, Onsets it, generates the
% same representation as for the clustering. But then uses the PCA
% components to project this representation down to a lower dimetionsality,
% then uses the KNN centres to attempt to classify each segment.
%
% This version can have multiple Gabor filters. Note that the length of
% gaborparamsall and the number of elements in gabordirs should be the
% same.
% This version also allows that the gabors and all the ANs, and Onsets be
% parcelled up into a single vector for each segment. Uses the varargin
% parameter segmentsummary
% This version atempts ICAs
%
% many parameters not in the call can be altered using varargin
% some parameters used
%
display = 0 ;
% default is to run everything, but this can be changed using varargin
runan = 1 ;
runonsets = 1 ;
runplainandonsets = 1 ;
rungabors = 1 ;
rungeneratesegments = 1 ; % currently has to be one, because the segment data is overwritten.
store_bmSig =  0 ;
bmSigdir = 'BMSigDir' ;
pretime = 0.005 ; % time to include before onstet time
seglength = 0.05 ; % segment length to use
gabordirs{1} = 'GaborResults250a' ;
gabordirs{2} = 'GaborResults250b' ;
soundtype = 'male' ;
timit = 0 ; % these aren't TIMIT datasets.
n_pcas = 8 ; % number of PCAS used/to use
n_icas = 10 ; % must be <= number of icas in matrix
n_clusters = 10 ; % number of clusters in the cluster being used for classification
resamplerate = 250 ;
segmentsummary = 0 ; % default is one output per resamplerate sample:
% if segmentsummary is 1 then just one output per segment
numcl = 1 ; % number of clusters to use in finding nearest center: default is simply the nearest one.
usepcas = 1 ; % use PCA based cluster interpretation
useicas = 0 ; % use ica based cluster interpretation
numcl_ica = 1 ; % number of ICA classifications to use

i=1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'pretime';
            pretime=varargin{i+1};
            i=i+1;
        case 'seglength'
            seglength=varargin{i+1};
            i=i+1;
        case 'gabordirs'
            gabordirs = varargin{i+1};
            i=i+1;
        case 'timit'
            timit =  varargin{i+1};
            i=i+1;
        case 'n_pcas'
            n_pcas  =  varargin{i+1};
            i=i+1;
        case 'n_icas'
            n_icas  =  varargin{i+1};
            i=i+1;
        case 'n_clusters'
            n_clusters =  varargin{i+1};
            i=i+1;
        case 'soundtype'
            soundtype =  varargin{i+1};
            i=i+1;
        case'resamplerate'
            resamplerate =  varargin{i+1};
            i=i+1;
        case 'store_bmsig'
            resamplerate =  varargin{i+1};
            i=i+1;
        case 'bmsigdir'
            bmSigdir =  varargin{i+1};
            i=i+1;
        case 'segmentsummary'
            segmentsummary =  varargin{i+1};
            i=i+1;
        case 'runan'
            runan =  varargin{i+1};
            i=i+1;
        case 'runonsets'
            runonsets =  varargin{i+1};
            i=i+1;
        case 'runplainandonsets'
            runplainandonsets =  varargin{i+1};
            i=i+1;
        case 'rungabors'
            rungabors =  varargin{i+1};
            i=i+1;
%         case 'rungeneratesegments'
%             rungeneratesegments =  varargin{i+1};
%             i=i+1;
        case 'numcl'
            numcl =  varargin{i+1};
            i=i+1;
        case 'usepcas'
            usepcas =  varargin{i+1};
            i=i+1;
        case 'useicas'
            useicas  =  varargin{i+1};
            i=i+1;
        case 'numcl_ica'
            numcl_ica =  varargin{i+1};
            i=i+1;
            
        otherwise
            error('runTIMIT250_fn: Unknown argument %s given',varargin{i});
    end
    i=i+1;
end

if runan
    create_AN_files(soundlocation, '','', filelist, store_bmSig, bmSigdir, ANSigDir) ;
end
if runonsets
    generateonsetspikes2_mono(soundlocation, '','', filelist, ANSigDir, onsetSigdir, display) ;
end

if runplainandonsets
    n_run = generatemeanplain_mono(soundlocation, '', '', filelist, ANSigDir, AMMeanPlain250, resamplerate, 0) ;
    mo = generatemeanlevelonset_mono(soundlocation, '', '', filelist, onsetSigdir, onsetMeans250, resamplerate, 0) ;
end

% run through all the gabors
ngabors = length(gabordirs) ;
if (length(gaborparamsall) ~= ngabors)
    error('runTIMIT250gabor2_fn: number of gabor directories not the same as number of sets of parameters. termionating') ;
end
if rungabors
    for gno = 1: ngabors
        gaborparams = gaborparamsall{gno} ;
        n_gaborrun = generategaboroutputs_mono(soundlocation, '', '', filelist, ANSigDir, gabordirs{gno}, gaborparams,resamplerate, 0) ;
    end
end

if rungeneratesegments
    nm = generatesegments_1(soundlocation, '', '',filelist, onsetSigdir,  AMMeanPlain250, onsetMeans250, gabordirs, outputdir, ...
        'minimumspikes', 10, 'fileset', soundtype, 'pretime', pretime, 'timit', timit, 'seglength', seglength) ;
    disp(['resample done: ' num2str(nm) ' test sound.  sound type is ' soundtype]) ;
    
end

m1 = load([soundlocation '/' outputdir '/' soundtype '_vectors.mat']) ; %

if usepcas
    % get the pca projection matrix and project to lower dimensonal space
    p1 = load([soundclasslocation '/' projectiondir '/expt_all_PCA.mat']) ;
    if strcmp(soundtype, 'male')
        pca = p1.pcas_male ;
    else
        if strcmp(soundtype, 'female')
            pca = p1.pcas_female ;
        else
            error(['classifysounds_fn: invalid soundtype = ' soundtype]) ;
        end
    end
    % projections is <number of segments> by n_pcas
    projections = usePCAs_altogether(m1, pca, n_pcas, 'ngabors', ngabors, 'segmentsummary', segmentsummary) ;
    
    % Load the cluster centres and find the nerast cluster(s)
    % load the cluster that was generated using n_pcas, and with n_cluster
    % clusters.
    if strcmp(soundtype, 'male')
        cl1 = load([soundclasslocation '/' projectiondir '/clustertest_C' num2str(n_pcas) '_clusts' num2str(n_clusters) '_pca_m.mat']) ;
    else
        if strcmp(soundtype, 'female')
            cl1 = load([soundclasslocation '/' projectiondir '/clustertest_C' num2str(n_pcas) '_clusts' num2str(n_clusters) '_pca_f.mat']) ;
        else
            error(['classifysounds_fn: invalid soundtype = ' soundtype]) ;
        end
    end
    % cl1.cpca is n_clusters by by n_pcas, and is the cluster centres
    
    % find the nearest cluster centre
    % use pdist2
    no_tobeclassified = size(projections,1) ;
    dd = zeros([ no_tobeclassified numcl]) ; % distances
    ii = zeros([ no_tobeclassified numcl]) ; % identities
    for segno = 1:no_tobeclassified
        [dd(segno, :), ii(segno, :)] = pdist2(cl1.cpca5, squeeze(projections(segno, :)), 'Euclidean','Smallest', numcl) ;
    end
    
    % now turn these clustering values into a phoneme (string)
    ph1 = load([soundclasslocation '/' projectiondir '/clusterphons_C' num2str(n_pcas) '_clusts_pca' num2str(n_clusters) '.mat']) ;
    if strcmp(soundtype, 'male')
        pcamodephonemes = ph1.m1.pcamodephonemes ;
        pcaphonfreqclust = ph1.m1.pcaphonfreqclust ;
        pcaphons = ph1.m1.pcaphons ;
    else
        pcamodephonemes = ph1.f1.pcamodephonemes ;
        pcaphonfreqclust = ph1.f1.pcaphonfreqclust ;
        pcaphons = ph1.f1.pcaphons ;
    end
    % if nuymcl is 1, then we simply choose ii(segno) as the cluster, and take
    % the top one
    classifications = cell(1, no_tobeclassified) ;
    if (numcl == 1)
        for segno = 1: no_tobeclassified
            classifications{segno}.phoneme = pcamodephonemes{ii(segno)}{1} ;
            classifications{segno}.time = m1.segmentstart(segno) ;
        end
    else % numcl > 0
        for segno = 1: no_tobeclassified
            for phno = 1:numcl
                classifications{segno}.phoneme{phno} = pcamodephonemes{ii(segno, phno)}{1} ;
                classifications{segno}.phoneme2{phno} = pcamodephonemes{ii(segno, phno)}{2} ;
                
            end
            classifications{segno}.time = m1.segmentstart(segno) ;
        end
    end
    
    classifications_pca = classifications ;
    
end % usepcas

if useicas
    % get the ica projection matrix: use it directly. 
    ica1 = load([soundclasslocation '/' projectiondir '/expt_all_ICA20.mat']) ;
    if strcmp(soundtype, 'male')
        icas = ica1.icas1d_m ;
    else
        if strcmp(soundtype, 'female')
            icas = ica1.icas1d_f ;
        else
            error(['classifysounds_fn: invalid soundtype = ' soundtype]) ;
        end
    end
    % projections is <number of segments> by n_icas
    projections = useICAs_altogether(m1, icas, n_icas, 'ngabors', ngabors, 'segmentsummary', segmentsummary) ;
    
    % take the absolute values of the projecttions, since we are interested
    % in the largest projection, independent of sign
    projectionsabs = abs(projections) ;
    no_tobeclassified = size(projections,1) ;

    % find the location of the numcl_ica largest projectsions 
    projlocns = zeros([numcl_ica no_tobeclassified]) ;
    for pjno = 1 : numcl_ica
        [~, projlocns(pjno,:)]  = max(projectionsabs, [], 2) ; 
        for ii = 1:no_tobeclassified % zeroise these maxima: I suspect there's a better way of doing this.
            projectionsabs(ii, projlocns(pjno,ii)) = 0 ;
        end
    end
    

    % now turn these clustering values into a phoneme (string)
    ph1 = load([soundclasslocation '/' projectiondir '/ica_projns_' num2str(n_icas)  '.mat']) ;
    if strcmp(soundtype, 'male')
        icamodephonemes = ph1.m1.icamodephonemes ;
        icaphonfreqclust = ph1.m1.icaphonfreqclust ;
        i = ph1.m1.icaphons ;
    else
        icamodephonemes = ph1.f1.icamodephonemes ;
        icaphonfreqclust = ph1.f1.icaphonfreqclust ;
        icaphons = ph1.f1.icaphons ;
    end
    % if nuymcl is 1, then we simply choose ii(segno) as the cluster, and take
    % the top one
    %
    classifications = cell(1, no_tobeclassified) ;
    if (numcl_ica == 1)
        for segno = 1: no_tobeclassified
            if ~isempty(icamodephonemes{projlocns(segno)})
                classifications{segno}.phoneme = icamodephonemes{projlocns(segno)}{1} ;
            else
                classifications{segno}.phoneme = '' ;
            end
            classifications{segno}.time = m1.segmentstart(segno) ;
        end
    else % numcl_ica > 1
        for segno = 1: no_tobeclassified
            for phno = 1:numcl_ica
                if ~isempty(icamodephonemes{projlocns(phno, segno)})
                    classifications{segno}.phoneme{phno} = icamodephonemes{projlocns(phno, segno)}{1} ;
                else
                    classifications{segno}.phoneme{phno} = '' ;
                end
                % classifications{segno}.phoneme2{phno} = icamodephonemes{ii(segno, phno)}{2} ;
                
            end
            classifications{segno}.time = m1.segmentstart(segno) ;
        end
    end
    

    classifications_ica = classifications ;
    
    segOut = m1.segmentid;


end % useicas

end


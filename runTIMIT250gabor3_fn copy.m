function runTIMIT250gabor3_fn(timitlocn, filelist, ANSigDir, AMMeanPlain250, onsetSigdir, onsetMeans250, gaborparamsall,outputdir, varargin)
% runTIMIT250_fn: runs through all TIMIT; male and female separately, assuming AN
% in ANSigdir, Onsets in onsetSigdir.
% 
% This version can have multiple Gabor filters. Note that the length of
% gaborparamsall and the number of elements in gabordirs should be the
% same.
% This version also allows that the gabors and all the ANs, and Onsets be
% parcelled up into a single vector for each segment. Uses the varargin
% parameter segmentsummary
% This version omits ICAs
%
% many parameters not in the call can be altered using varargin
% some parameters used
%
display = 0 ;
pcadisplay = 0 ;
icadisplay = 0 ;
% default is to run everything, but this can be changed using varargin
runan = 1 ;
runonsets = 1 ;
runplainandonsets = 1 ;
rungabors = 1 ;
rungeneratesegments = 1 ;
runPCAICA = 1 ;
runclustering_pca = 1 ;
runclustering_ica = 1 ;
analyseclusters_pca  = 1 ;
analyseclusters_ica = 1 ;

store_bmSig =  0 ;
bmSigdir = 'BMSigDir' ;
pretime = 0.005 ; % time to include before onstet time
seglength = 0.05 ; % segment length to use
gabordirs{1} = 'GaborResults250a' ;
gabordirs{2} = 'GaborResults250b' ;
filelist_male = 'filelist_male.txt' ;
filelist_female = 'filelist_female.txt' ;
timit = 1 ;
n_pcas = 8 ;
n_icas = 8 ;
resamplerate = 250 ;
segmentsummary = 0 ; % default is one output per resamplerate sample: 
% if segmentsummary is 1 then just one output per segment
compstart = 40 ;
compstep = 10 ;
compfinish = 40 ;
cluststart = 200 ;
cluststep = 50 ;
clustfinish = 200 ;
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
        case 'filelist_male'
            filelist_male =  varargin{i+1};
            i=i+1;
        case 'filelist_female'
            filelist_female =  varargin{i+1};
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
        case 'rungeneratesegments'
            rungeneratesegments =  varargin{i+1};
            i=i+1;
        case 'runpcaica'
            runPCAICA =  varargin{i+1};
            i=i+1;
        case 'runclustering'
            runclustering =  varargin{i+1};
            i=i+1;
        case 'pcadisplay'
            pcadisplay =  varargin{i+1};
            i=i+1;
        case 'icadisplay' 
            icadisplay =  varargin{i+1};
            i=i+1;
        case 'runclustering_pca'
            runclustering_pca =  varargin{i+1};
            i=i+1;
        case 'runclustering_ica'
            runclustering_ica =  varargin{i+1};
            i=i+1;
        case 'analyseclusters_ica'
            analyseclusters_ica =  varargin{i+1};
            i=i+1;
        case  'analyseclusters_pca'
            analyseclusters_ica =  varargin{i+1};
            i=i+1;
        otherwise
            error('runTIMIT250_fn: Unknown argument %s given',varargin{i});
    end
    i=i+1;
end

% timitlocn = '/Volumes/MacHD2/Researchshare/timit3/AU_TIMIT' ;
if runan
    create_AN_files(timitlocn, '','', filelist, store_bmSig, bmSigdir, ANSigDir) ;
end
if runonsets
    generateonsetspikes2_mono(timitlocn, '','', filelist, ANSigDir, onsetSigdir, display) ;
end

if runplainandonsets
    n_run = generatemeanplain_mono(timitlocn, '', '', filelist, ANSigDir, AMMeanPlain250, resamplerate, 0) ;
    mo = generatemeanlevelonset_mono(timitlocn, '', '', filelist, onsetSigdir, onsetMeans250, resamplerate, 0) ;
end

% run through all the gabors
ngabors = length(gabordirs) ;
if (length(gaborparamsall) ~= ngabors)
    error('runTIMIT250gabor2_fn: number of gabor directories not the same as number of sets of parameters. termionating') ;
end
if rungabors
    disp(['Gabor production starting']) ;

    for gno = 1: ngabors
        gaborparams = gaborparamsall{gno} ;
        n_gaborrun = generategaboroutputs_mono(timitlocn, '', '', filelist, ANSigDir, gabordirs{gno}, gaborparams,resamplerate, 0) ;
    end
end

if rungeneratesegments
    disp(['segment generation starting']) ;

    nm = generatesegments_1(timitlocn, '', '',filelist_male, onsetSigdir,  AMMeanPlain250, onsetMeans250, gabordirs, outputdir, ...
        'minimumspikes', 10, 'fileset', 'expt_male', 'pretime', pretime, 'timit', timit, 'seglength', seglength) ;
    disp(['male 250 resample done ' num2str(nm)]) ;
    nf = generatesegments_1(timitlocn, '', '',filelist_female, onsetSigdir,  AMMeanPlain250, onsetMeans250, gabordirs, outputdir, ...
        'minimumspikes', 10, 'fileset', 'expt_female', 'pretime', pretime, 'timit', timit, 'seglength', seglength) ;
    disp(['female 250 resample done ' num2str(nf)]) ;
end

if runPCAICA
    disp(['PCA/ICA starting ']) ;

    m1 = load([timitlocn '/' outputdir '/expt_male_vectors.mat']) ;
    f1 = load([timitlocn '/' outputdir '/expt_female_vectors.mat']) ;

    if n_pcas > 0
    pcas_male = makePCAs_altogether(m1, pcadisplay,'infostr', ' concatenated, male timit, 250 resample', 'subplot', 1, 'segmentsummary', segmentsummary) ;
    pcas_female = makePCAs_altogether(f1, pcadisplay, 'infostr', ' concatenated, female timit, 250 resample','subplot', 1, 'segmentsummary', segmentsummary) ;
    end
    if n_icas > 0 % modded 1 4 2014: make number of ICs and lastEig the same. 
    [icas1d_m, icas2d_m, proj_m] = makeICAs_altogether(m1, icadisplay, 'numOfIC', n_icas, 'lastEig', n_icas, 'infostr', 'ICA concat male timit ','subplot', 1) ;
    [icas1d_f, icas2d_f, proj_f] = makeICAs_altogether(f1, icadisplay, 'numOfIC', n_icas, 'lastEig', n_icas, 'infostr', 'ICA concat female timit ','subplot', 1) ;
    end
    % can't save parts of a structure so remove some elements.
    f1 = rmfield(f1, { 'meansgaborarray', 'meansonsetarray', 'meansoutputarray', 'vectors'}) ;
    m1 = rmfield(m1, {'meansgaborarray', 'meansonsetarray', 'meansoutputarray', 'vectors'}) ;
    if n_pcas > 0
    save([timitlocn '/' outputdir '/expt_all_PCA'], 'pcas_female', 'pcas_male',  'f1', 'm1') ;
    end
    if n_icas > 0
    save([timitlocn '/' outputdir '/expt_all_ICA20'], 'icas1d_f', 'icas2d_f', 'proj_f', 'f1', 'm1', ...
        'icas1d_m', 'icas2d_m', 'proj_m') ;
    end
end

if runclustering_pca
    % create the clusters (clustercreate)
    disp(['Clustering (pca) starting']) ;
    for components = compstart:compstep:compfinish
        for clusts = cluststart:cluststep:clustfinish
            % clusterpcaica.m will save the output in
            % clustertest_C<pcas>_clusts<clusts>_f/m.mat
            % only do the PCA (ICA) part if n_pcas >0 (n_icas > 0)
            if (n_pcas == 0)
                component_pcas = 0 ;
            else component_pcas = components ;
            end
            clusterpca_fn(timitlocn, outputdir, ngabors, ['clustertest_C' num2str(components) '_clusts' num2str(clusts)], ...
                'pcastouse', component_pcas, ...
                'clusters_pca', clusts,  'segmentsummary', segmentsummary) ;
            %processclusters doesn't save anything
            [f1, m1] = processclusterspca_fn(timitlocn, outputdir, 'expt_all_PCA.mat', ...
                ['clustertest_C' num2str(components) '_clusts' num2str(clusts)], 'const_phonfraction', 1.0) ;
            % so we need to save it now
            save([timitlocn '/' outputdir '/' 'clusterphons_C' num2str(components) '_clusts_pca' num2str(clusts) '.mat'], 'f1', 'm1', 'components', 'clusts') ;
            
        end
    end
end

if runclustering_ica
        disp(['Clustering (ica) starting']) ;
        clusterica_fn(timitlocn, outputdir, ngabors, ['ica_projns_' num2str(n_icas) ], ...
                'clusters_ica', n_icas, 'segmentsummary', segmentsummary) ;
            %processclusters doesn't save anything
            [f1, m1] = processclustersica_fn(timitlocn, outputdir, 'expt_all_ICA20.mat', ...
                ['ica_projns_' num2str(n_icas)], 'const_phonfraction', 1.0) ;
            % so we need to save it now
            save([timitlocn '/' outputdir '/' 'clusterphons_C' num2str(components) '_clusts_ica' num2str(clusts) '.mat'], 'f1', 'm1', 'components', 'clusts') ;
end


if analyseclusters_pca
disp(['Analysing PCA clusters starting']) ;
    for components = compstart:compstep:compfinish
        for clusts = cluststart:cluststep:clustfinish
% analyse clusters
            cl2p = load([timitlocn '/' outputdir ['clustertest_C' num2str(components) '_clusts' num2str(clusts) '.mat']]) ;
            [NMIf_p QFf_p] = compareclusterspca_single_fn(cl2p.f1, cl2p.clusts) ;
            [NMIm_p QFm_p] = compareclusterspca_single_fn(cl2p.m1, cl2p.clusts) ;
            disp([ 'PCA clustering: Components = ' num2str(components) ' Clusters = ' num2str(clusters) ' Female NMI = ' num2str(NMIf_p) ' Male NMI = ' num2str(NMIm_p)]) ;
        end
    end
end

if analyseclusters_ica
    disp(['Analysing ICA clusters starting']) ;

    cl2i = load([timitlocn '/' outputdir ['ica_projns_' num2str(n_icas)] 'mat']) ;
    [NMIf_i QFf_i] = compareclustersica_single_fn(cl2i.f1, cl2i.clusts) ;
    [NMIm_i QFm_i] = compareclustersica_single_fn(cl2i.m1, cl2i.clusts) ;
    disp(['ICA clustering: ICAs = ' num2str(n_icas)  ' Female NMI = ' num2str(NMIf_i) ' Male NMI = ' num2str(NMIm_i)]) ;
end

end




function runTIMIT250gabor2_fn(timitlocn, filelist, ANSigDir, AMMeanPlain250, onsetSigdir, onsetMeans250, gaborparamsall,outputdir, varargin)
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
% default is to run everything, but this can be changed using varargin
runan = 1 ;
runonsets = 1 ;
runplainandonsets = 1 ;
rungabors = 1 ;
rungeneratesegments = 1 ;
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
resamplerate = 250 ;
segmentsummary = 0 ; % default is one output per resamplerate sample: 
% if segmentsummary is 1 then just one output per segment
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
    for gno = 1: ngabors
        gaborparams = gaborparamsall{gno} ;
        n_gaborrun = generategaboroutputs_mono(timitlocn, '', '', filelist, ANSigDir, gabordirs{gno}, gaborparams,resamplerate, 0) ;
    end
end

if rungeneratesegments
    nm = generatesegments_1(timitlocn, '', '',filelist_male, onsetSigdir,  AMMeanPlain250, onsetMeans250, gabordirs, outputdir, ...
        'minimumspikes', 10, 'fileset', 'expt_male', 'pretime', pretime, 'timit', timit, 'seglength', seglength) ;
    disp(['male 250 resample done ' num2str(nm)]) ;
    nf = generatesegments_1(timitlocn, '', '',filelist_female, onsetSigdir,  AMMeanPlain250, onsetMeans250, gabordirs, outputdir, ...
        'minimumspikes', 10, 'fileset', 'expt_female', 'pretime', pretime, 'timit', timit, 'seglength', seglength) ;
    disp(['female 250 resample done ' num2str(nf)]) ;
end

m1 = load([timitlocn '/' outputdir '/expt_male_vectors.mat']) ;
pcas_male = makePCAs_altogether(m1, n_pcas,'infostr', ' concatenated, male timit, 250 resample', 'subplot', 1, 'segmentsummary', segmentsummary) ;
% [icas1d_m, icas2d_m, proj_m] = makeICAs_altogether(m1, n_pcas, 'infostr', 'ICA concat male timit ','subplot', 1) ;
f1 = load([timitlocn '/' outputdir '/expt_female_vectors.mat']) ;
pcas_female = makePCAs_altogether(f1, n_pcas,'infostr', ' concatenated, female timit, 250 resample','subplot', 1, 'segmentsummary', segmentsummary) ;
% [icas1d_f, icas2d_f, proj_f] = makeICAs_altogether(f1, 8, 'infostr', 'ICA concat female timit ','subplot', 1) ;
% can't save parts of a structure so remove some elements.
f1 = rmfield(f1, { 'meansgaborarray', 'meansonsetarray', 'meansoutputarray', 'vectors'}) ;
m1 = rmfield(m1, {'meansgaborarray', 'meansonsetarray', 'meansoutputarray', 'vectors'}) ;

save([timitlocn '/' outputdir '/expt_all_PCA'], 'pcas_female', 'pcas_male',  'f1', 'm1') ;
% save([timitlocn '/' outputdir '/expt_all_ICA20'], 'icas1d_f', 'icas2d_f', 'proj_f', 'f1', 'm1', ...
%    'icas1d_m', 'icas2d_m', 'proj_m') ;

% create the clusters (clustercreate)
for components = 4:1:16
for clusts = 3:1:24
    clusterpcaica_fn(timitlocn, outputdir, ['clustertest_C' num2str(components) '_clusts' num2str(clusts)], 'pcastouse', components, ...
        'icastouse', components, 'clusters_pca', clusts, 'clusters_ica', clusts) ;
    [f1{(components-3), (clusts-2)}, m1{(components-3), (clusts-2)}] = processclusters_fn(timitlocn, outputdir, 'expt_all_PCA.mat', ...
        ['clustertest_C' num2str(components) '_clusts' num2str(clusts)], 'const_phonfraction', 1.0) ;
end
end
save([timitlocn '/' outputdir '/clusterresults14032104.mat'], 'f1', 'm1') ;

% analyse clusters
cl2 = load([timitlocn '/' outputdir '/clusterresults14032104.mat']) ;
[NMIf_p QFf_p] = compareclusterspca_fn(cl2.f1) ;
[NMIm_p QFm_p] = compareclusterspca_fn(cl2.m1) ;
[NMIm_i QFm_i] = compareclustersica_fn(cl2.m1) ;
[NMIf_i QFf_i] = compareclustersica_fn(cl2.f1) ;

save([timitlocn '/' outputdir '/clusteranalysis14032104.mat'], 'NMIf_p', 'QFf_p', 'NMIm_p', 'QFm_p', 'NMIm_i', 'QFm_i', 'NMIf_i', 'QFf_i') ;  ;
end




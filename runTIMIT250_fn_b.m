function runTIMIT250_fn(timitlocn, filelist, ANSigDir, AMMeanPlain250, onsetSigdir, onsetMeans250, gaborparamsall,outputdir, varargin)
% runTIMIT250_fn: runs through all TIMIT; male and female separately, assuming AN
% in ANSigdir, Onsets in onsetSigdir, and produce 1st 8 components of the
% concatenated L0, L1 onset, L1 Gabor at lambda = 18, and L1 Gabor at
% lambda = 10. gaborparamsall(1,:) is 1st Gabor filter, gaborparamsall(2,:)
% is 2nd Gabor paramteters.
%
% many parameters not in the call can be altered using varargin
% some parameters used
%
display = 0 ;
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
            
        otherwise
            error('runTIMIT250_fn: Unknown argument %s given',varargin{i});
    end
    i=i+1;
end

% % % timitlocn = '/Volumes/MacHD2/Researchshare/timit3/AU_TIMIT' ;
% % create_AN_files(timitlocn, '','', filelist, store_bmSig, bmSigdir, ANSigDir) ;
% % generateonsetspikes2_mono(timitlocn, '','', filelist, ANSigDir, onsetSigdir, display) ;
% % 
% % 
% % n_run = generatemeanplain_mono(timitlocn, '', '', filelist, ANSigDir, AMMeanPlain250, resamplerate, 0) ;
% % mo = generatemeanlevelonset_mono(timitlocn, '', '', filelist, onsetSigdir, onsetMeans250, resamplerate, 0) ;
% % % gaborparams.bandwidth = 0.7 ;
% % % gaborparams.gamma = 4 ;
% % % gaborparams.theta = pi/2 ;
% % % gaborparams.lambda = 18 ;
% % gaborparams = gaborparamsall{1} ;
% % n_gaborrun = generategaboroutputs_mono(timitlocn, '', '', filelist, ANSigDir, gabordirs{1}, gaborparams,resamplerate, 0) ;
% % gaborparamsb = gaborparamsall{2} ;
% % % gaborparamsb.lambda = 10 ;
% % n_gaborrunb = generategaboroutputs_mono(timitlocn, '', '', filelist, ANSigDir, gabordirs{2}, gaborparamsb,resamplerate, 0) ;
% % 
% % nm = generatesegments_1(timitlocn, '', '',filelist_male, onsetSigdir,  AMMeanPlain250, onsetMeans250, gabordirs, outputdir, ...
% %     'minimumspikes', 10, 'fileset', 'expt_male', 'pretime', pretime, 'timit', timit, 'seglength', seglength) ;
% % disp(['male 250 resample done ' num2str(nm)]) ;
% % nf = generatesegments_1(timitlocn, '', '',filelist_female, onsetSigdir,  AMMeanPlain250, onsetMeans250, gabordirs, outputdir, ...
% %     'minimumspikes', 10, 'fileset', 'expt_female', 'pretime', pretime, 'timit', timit, 'seglength', seglength) ;
% % disp(['female 250 resample done ' num2str(nf)]) ;
% % 
% % m1 = load([timitlocn '/' outputdir '/expt_male_vectors.mat']) ;
% % pcas_male = makePCAs_altogether(m1, n_pcas,'infostr', ' concatenated, male timit, 250 resample', 'subplot', 1) ;
% % [icas1d_m, icas2d_m, proj_m] = makeICAs_altogether(m1, n_pcas, 'infostr', 'ICA concat male timit ','subplot', 1) ;
% % f1 = load([timitlocn '/' outputdir '/expt_female_vectors.mat']) ;
% % pcas_female = makePCAs_altogether(f1, n_pcas,'infostr', ' concatenated, female timit, 250 resample','subplot', 1) ;
% % [icas1d_f, icas2d_f, proj_f] = makeICAs_altogether(f1, 8, 'infostr', 'ICA concat female timit ','subplot', 1) ;
% % % can't save parts of a structure so remove some elements.
% % f1 = rmfield(f1, { 'meansgaborarray', 'meansonsetarray', 'meansoutputarray', 'vectors'}) ;
% % m1 = rmfield(m1, {'meansgaborarray', 'meansonsetarray', 'meansoutputarray', 'vectors'}) ;
% % 
% % save([timitlocn '/' outputdir '/expt_all_PCA'], 'pcas_female', 'pcas_male',  'f1', 'm1') ;
% % save([timitlocn '/' outputdir '/expt_all_ICA20'], 'icas1d_f', 'icas2d_f', 'proj_f', 'f1', 'm1', ...
% %     'icas1d_m', 'icas2d_m', 'proj_m') ;

%create the clusters (clustercreate)
components = 40 ;
for clusts = 400:100:800
    clusterpcaica_fn(timitlocn, outputdir, ['clustertest_C' num2str(components) '_clusts' num2str(clusts)], 'pcastouse', components, ...
        'icastouse', components, 'clusters_pca', clusts, 'clusters_ica', clusts) ;
    [f1{(1), (clusts/100 -3)}, m1{(1), (clusts/100 - 3)}] = processclusters_fn(timitlocn, outputdir, 'expt_all_PCA.mat', ...
        ['clustertest_C' num2str(components) '_clusts' num2str(clusts)], 'const_phonfraction', 1.0) ;
end
% end
save([timitlocn '/' outputdir '/clusterresults20032104a.mat'], 'f1', 'm1') ;

% analyse cluste3
cl2 = load([timitlocn '/' outputdir '/clusterresults20032104a.mat']) ;
[NMIf_p QFf_p] = compareclusterspca_fn(cl2.f1) ;
[NMIm_p QFm_p] = compareclusterspca_fn(cl2.m1) ;
[NMIm_i QFm_i] = compareclustersica_fn(cl2.m1) ;
[NMIf_i QFf_i] = compareclustersica_fn(cl2.f1) ;

save([timitlocn '/' outputdir '/clusteranalysis20032104a.mat'], 'NMIf_p', 'QFf_p', 'NMIm_p', 'QFm_p', 'NMIm_i', 'QFm_i', 'NMIf_i', 'QFf_i') ;  ;
end




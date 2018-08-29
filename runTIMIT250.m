% % script to run through all TIMIT; male and female separately, assuming AN
% % in ANSigdir, Onsets in onsetSigdir, and produce 1st 8 components of the
% % concatenated L0, L1 onset, L1 Gabor at lambda = 18, and L1 Gabor at
% % lambda = 10.
% 
% timitlocn = '/Volumes/MacHD2/Researchshare/timit3/AU_TIMIT' ;
% % some parameters used
% pretime = 0.005 ; % time to include before onstet time
% seglength = 0.05 ; % segment length to use
% n_run = generatemeanplain_mono(timitlocn, '', '', 'filelist_all.txt', 'ANSigdir', 'ANMeanPlain250', 250, 0) ;
% mo = generatemeanlevelonset_mono(timitlocn, '', '', 'filelist_all.txt', 'onsetSigdir', 'onsetMeans250', 250, 0) ;
% gaborparams.bandwidth = 0.7 ;
% gaborparams.gamma = 4 ;
% gaborparams.theta = pi/2 ;
% gaborparams.lambda = 18 ;
% n_gaborrun = generategaboroutputs_mono(timitlocn, '', '', 'filelist_all.txt', 'ANSigDir', 'GaborResults250a', gaborparams,250, 0) ;
% gaborparamsb = gaborparams ;
% gaborparamsb.lambda = 10 ;
% n_gaborrunb = generategaboroutputs_mono(timitlocn, '', '', 'filelist_all.txt', 'ANSigDir', 'GaborResults250b', gaborparamsb,250, 0) ;
% 
% gabordirs{1} = 'GaborResults250a' ;
% gabordirs{2} = 'GaborResults250b' ;
% nm = generatesegments_1(timitlocn, '', '','filelist_male.txt', 'onsetSigdir',  'ANMeanPlain250', 'OnsetMeans250', gabordirs, 'Vectors250', ...
%     'minimumspikes', 10, 'fileset', 'expt_male', 'pretime', pretime, 'timit', 1, 'seglength', seglength) ;
disp(['male 250 resample done ' num2str(nm)]) ;
nf = generatesegments_1(timitlocn, '', '','filelist_female.txt', 'onsetSigdir',  'ANMeanPlain250', 'OnsetMeans250', gabordirs, 'Vectors250', ...
    'minimumspikes', 10, 'fileset', 'expt_female', 'pretime', pretime, 'timit', 1, 'seglength', seglength) ;
disp(['female 250 resample done ' num2str(nf)]) ;

m1 = load([timitlocn '/Vectors250/expt_male_vectors.mat']) ;
pcas_male = makePCAs_altogether(m1, 8,'infostr', ' concatenated, male timit, 250 resample', 'subplot', 1) ;
[icas1d_m, icas2d_m, proj_m] = makeICAs_altogether(m1, 8, 'infostr', 'ICA concat male timit ','subplot', 1) ;
f1 = load([timitlocn '/Vectors250/expt_female_vectors.mat']) ;
pcas_female = makePCAs_altogether(f1, 8,'infostr', ' concatenated, female timit, 250 resample','subplot', 1) ;
[icas1d_f, icas2d_f, proj_f] = makeICAs_altogether(f1, 8, 'infostr', 'ICA concat female timit ','subplot', 1) ;
% can't save parts of a structure so remove some elements.
f1 = rmfield(f1, { 'meansgaborarray', 'meansonsetarray', 'meansoutputarray', 'vectors'}) ;
m1 = rmfield(m1, {'meansgaborarray', 'meansonsetarray', 'meansoutputarray', 'vectors'}) ;

save([timitlocn '/Vectors250/expt_all_PCA'], 'pcas_female', 'pcas_male',  'f1', 'm1') ;
save([timitlocn '/Vectors250/expt_all_ICA20'], 'icas1d_f', 'icas2d_f', 'proj_f', 'f1', 'm1', ...
    'icas1d_m', 'icas2d_m', 'proj_m') ;




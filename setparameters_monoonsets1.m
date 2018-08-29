function setparameters_monoonsets1(stimulibasedir, experimentname, dirname)
% set AN and Onset parameters for the mono onset event file generation 
% in a file in stimulibasedir experimentname / dirname / parameters_monoonset.mat

% note that setup below includes values for both AM and pure onset.
% Last set for pure onset LSS 6 2 2003
% updated to provide values for onsetside_zc7 on 7 3 2003
% added a timestamp April 17 2013.
% added am parameters July 25 2013 LSS NOT CURRENTLY IN USE

% add a timestamp
AN.dateStr = datestr(now) ; % lss April 2013. 
AN.soundlength = 200; % 3 mins 20 seems to be about the absoulte maximum
% 600 is too long, leastwise at 44100 samples, mono
% length of sound to use, in seconds)(set to 10 minutes
% AN.soundlength = 2 ; % just for one expt with the 1st note of the sax

% parameter below beieved redundant. Use changes to minlevel_zc.

AN.siglevel = 200 ; % actual level of signal applied - was 200 for claps signal

% parameters for bm signal generation
% for speech
% AN.fmin = 1500; % was 150 (was 250)
% AN.fmax = 8000; % was 10000
% AN.channels = 32; % was 32

% for experimentation
AN.fmin = 50; % was 150 (was 100)
AN.fmax = 6500; % was 10000 (was 8000)
AN.channels = 200; % was 32/64
AN.N_erbs = 1 ; % 1 is normal bandwidth. 4 is narrow

% parameters for AN signal generation
% AN.minlevel_zc = 0.0025; % for Cauer filter
AN.minlevel_zc = 0.0002; % was 0.00014 for Gamma filter
AN.multiplier = 1.414 ; % root 2: 3dB difference: 2 = 6dB
AN.iterations = 16 ; %8=24dB 10 is also good.

AN.filtertype = 'gamma'; % filter type

% parameters for correlations
corrparam.smooth = 0.001 ; % for smoothing: this is value at 1Khz
corrparam.smoothtype = 2 ; % 1 is same for all bands, 2 uses a linear multiplier of corr.smooth by the centre frequency
corrparam.mindelay = 0.002 ; % timing step for corrlations
corrparam.maxdelay = 0.5 ; % maximal delay in correlations was 0.07
corrparam.repackage = 0.002 ; % for repackaging the logged rectified signal: 1/new sample rate was 0.0005
% if 0 no repackaging.
% note that there will be a total of corr.maxdelay/corr.mindelay + 1 layers
% of an AN.channels by AN.channels matrix

% parameters for onsets
% 6 3 2003
% values for wide onset cell
onset.onsetcellwt_wide =  10000/21 ; % weight to onset cell was 1500 for spread-wide = 2 (was 10000 for single AN input)
onset.spread_wide = 10 ; % number of AN fibers on each side of centre (0->no spread) (was 2)
% Note that the above parameters interact: as spread_wide is increased, so
% the number of synapses on to each onset cell increases, with the total
% number being 2*onset.spread_wide + 1. The weight used needs to reflect
% this, because all the weights are (currently) the same, being set to
% onset.onsetcellwt_wide.

% the next parameter sets up how the reservoirs on the depressing synapse
% interact. 
onset.depsynparams_wide = [100 1100 9]; % (was 100 1100 9 )depressing synapse parameters

% the parameters below set up the dissipation level for the neuron. 
onset.dissconst_wide =0.15;
onset.fmaxdiss_wide = 3500 ; % was 1500
onset.fmindiss_wide = 500 ;
onset.th_iandf_wide = 1 ;
onset.rp_wide = 0.02 ; % was 0.015 (0.003 is an attempt at AM)
onset.rrp_wide = 0.015 ; % not used
% note that ITD.mincluster_b etc. is used in ITD calculations for wide
% onset cells
% below: used in overallonset
onset.sensitivitygap = 0.005 ; % max gap between sensitivity levels
onset.intervalgap = 0.015 ; % used in overallonset for separating onsets

% parametes for AM detecting unit
am.cellwt = 10000 ; 
% no spread at all, so no am.spread
am.depsynparams = [5000 1000 30] ; % but see email from Madhu
am.dissconst_wide = 10; % certainly considerably greater than onset.diss
am.fmaxdiss_wide = 4000 ; % seems a reasonable limit
am.fmindiss_wide = 800 ; % unlikely to seek AM below this frequenct
am.th_iandf_wide = 1 ; % seems reasonable
am.rp_wide = 0.002  ;% a little less than half of 1/fmax AM.

save([stimulibasedir  experimentname  dirname '/' 'parameters_monoonset'], 'AN', 'corrparam', 'onset', 'am') ;

% save([stimulibasedir  experimentname '\' dirname '\' 'parameters_ascii'], 'AN', 'onset', 'ITD', 'IID','-ASCII') ;

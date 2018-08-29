% monaural run through
% 
%

% stimulibasedir = '/Users/lss/matlab_stuff/stimuli/Aug_2006/speechplusinterference/sp+pink_Curtains/' ;
stimulibasedir = ...
 '/Users/lss/matlab_stuff/music/piano/' ;
experiments = {'As44'} ;


experimentname = '' ;
suffix = '.wav' ;
todaysdir = 'multinotes' ;
bmSigdir = 'bmSig_main' ;
filter_type = 'gamma' ;
store_bmSig = 1 ;

display = 'Y' ;
dispchannels = [1 5 9 14 19 21 25 30 35 40 50 60] ;

% call setparameters_monoonsets to set up the parameters for this run
setparameters_monoonsets(todaysdir, experimentname, stimulibasedir)

% generate the AN file
generateANsignals_mono(todaysdir, store_bmSig,  suffix, experiments, ...
    experimentname, ...
    stimulibasedir, bmSigdir, filter_type, display, dispchannels) ;

display = 1 ;
% generate the onset file
generateonsetspikes1_mono(todaysdir, experiments, experimentname, ...
    stimulibasedir, display) ;

% generate the neural spikes
noofexperiments = size(experiments); 
nspikes = zeros([1 noofexperiments]) ;
for exptno = 1:noofexperiments
    onsetfilename = [stimulibasedir experimentname  todaysdir '/' experiments{exptno} ...
            '_onset.mat'] ;
    spikefilename = [stimulibasedir experimentname  todaysdir '/' experiments{exptno} ...
            '.spikesin'] ;
    nspikes(exptno) = onset_to_neuralspikes(onsetfilename, spikefilename) ;
end
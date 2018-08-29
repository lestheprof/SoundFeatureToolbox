function runTIMIT250gabor3_fn(timitlocn, filelist, ANSigDir, AMMeanPlain250, onsetSigdir, onsetMeans250, gaborparamsall,outputdir, varargin)
% runTIMIT250gabor3_fn: runs through a set of data, intended to be from
% TIMIT because it can use the annotations. However, it can also preprocess
% (but not assess) other datasets as well.
%
% non-varargin parameters:
% timitlocn: the folder where the files to be processed are placed
% filelist: a file within at folder, containing the names of the files to
% be processed
% ANSigDir: the folder within timitlocn which will hold/holds the AN output
% for each file to be processed
% AMMeanPlain250: the folder within timitlocn that holds/will hold the
% compressed (vector) AN signal for each file
% onsetSigdir: the folder within timitlocn thatb holds/will hold the onset
% spike signals
% onsetMeans250: the folder within timitlocn that holds/will hold the
% compressed (vector) representing the onset signals
% gaborparamsall: the set of gabor parameters, held as a cell array, with
% each cell holding the balues bandwidth, gamma, theta, and lambda.
% outputdir: the folder within timitlocn where the outputs will be placed.
%
% note that folders that are needed, but do not exist, will be created.
%
% There are comments here at the start, and more throughout the text of
% this function
%
%There are multiple stages, and the can be run or not run by using the
%varargin arguments 
% runan: Run the auditory nerve stage
% runonsets: run the onset stage
% runplainandonsets: run the stage that compresses the AN and onsets into
% vectors at the reasmple rate
% rungabors: Run the gabor filters
% rungeneratesegments: Run the generation of segments
% runPCAICA: Run the PCA and ICA analysis
% runclustering_pca: Cluster the data using PCA
% runclustering_ica: Use the ica's as clusters;
% analyseclusters_pca: analyse the clusters from the PCA data
% analyseclusters_ica: analyse the datya from the ICA data
%
% all are set to 1 (run) by default. The communication between the sections
% is through files.
% 
% This version can have multiple Gabor filters. Note that the length of
% gaborparamsall and the number of elements in gabordirs (varargin parameter) should be the
% same.
% This version also allows that the gabors and all the ANs, and Onsets be
% parcelled up into a single vector for each segment. Uses the varargin
% parameter segmentsummary
%
% many parameters not in the call can be altered using varargin
% some parameters used
%
% the following are the defaults for the varargin parameters
display = 0 ;
displaygabors = 0 ;
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
filelist_male = 'filelist_male.txt' ; % used for male speech
filelist_female = 'filelist_female.txt' ; % used for female speech
timit = 1 ; % set to 1 allows the timit annotation to be used
n_pcas = 40 ;
n_icas = 8 ;
resamplerate = 250 ;
segmentsummary = 0 ; % default is one output per resamplerate sample: 
% if segmentsummary is 1 then just one output per segment
compstart = 40 ; % these probably should be varargin parameters, but aren't at the moment
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
        case 'resamplerate'
            resamplerate =  varargin{i+1};
            i=i+1;
        case 'store_bmsig'
            store_bmsig =  varargin{i+1};
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
            analyseclusters_pca =  varargin{i+1};
            i=i+1;
        case 'displaygabors'
            displaygabors =  varargin{i+1};
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
    % cfreate the vector based form of AN and onset, at resamplerate
    % samples/second
    n_run = generatemeanplain_mono(timitlocn, '', '', filelist, ANSigDir, AMMeanPlain250, resamplerate, 0) ;
    mo = generatemeanlevelonset_mono(timitlocn, '', '', filelist, onsetSigdir, onsetMeans250, resamplerate, 0) ;
end

% run through all the gabors
ngabors = length(gabordirs) ;
if (length(gaborparamsall) ~= ngabors)
    error('runTIMIT250gabor2_fn: number of gabor directories not the same as number of sets of parameters. Terminating') ;
end
if rungabors
    disp(['Gabor production starting']) ;

    for gno = 1: ngabors
        gaborparams = gaborparamsall{gno} ;
        % currently lets the system choose szxvalue (channels) and
        % szyvalue(duration) if these are not supplied.
        if isfield(gaborparams, 'szxvalue')
            szxvalue = gaborparams.szxvalue ;
        else
            szxvalue = 13 ;
        end
        if isfield(gaborparams, 'szyvalue')
            szyvalue = gaborparams.szyvalue ;
        else
            szyvalue = 0 ; % if 0 it is computed in gabor generation
        end
        n_gaborrun = generategaboroutputs_mono(timitlocn, '', '', filelist, ANSigDir, gabordirs{gno}, gaborparams,resamplerate, displaygabors, 'szxvalue', szxvalue, 'szyvalue', szyvalue) ;
    end
end

if rungeneratesegments
    disp(['segment generation starting']) ;
    % generates the segment, each of length seglength, starting from
    % pretime before the beginning of the onset interval. Male and female
    % done seperately.

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
    pcas_male = makePCAs_altogether(m1, pcadisplay,'infostr', ' concatenated, male timit, 250 resample', 'subplot', 1, 'segmentsummary', segmentsummary, 'ngabors', ngabors ) ;
    pcas_female = makePCAs_altogether(f1, pcadisplay, 'infostr', ' concatenated, female timit, 250 resample','subplot', 1, 'segmentsummary', segmentsummary,  'ngabors', ngabors) ;
    end
    if n_icas > 0 % modded 1 4 2014: make number of ICs and lastEig the same. In this way, we can have a number
    % of ICAs less than the number of components.
    [icas1d_m, icas2d_m, proj_m] = makeICAs_altogether(m1, icadisplay, 'numOfIC', n_icas, 'lastEig', n_icas, 'infostr', 'ICA concat male timit ','subplot', 1,  'ngabors', ngabors) ;
    [icas1d_f, icas2d_f, proj_f] = makeICAs_altogether(f1, icadisplay, 'numOfIC', n_icas, 'lastEig', n_icas, 'infostr', 'ICA concat female timit ','subplot', 1,  'ngabors', ngabors) ;
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
            save([timitlocn '/' outputdir '/' 'ica_projns_' num2str(n_icas) '.mat'], 'f1', 'm1', 'n_icas') ;
end


if analyseclusters_pca
disp(['Analysing PCA clusters starting']) ;
    for components = compstart:compstep:compfinish
        for clusts = cluststart:cluststep:clustfinish
% analyse clusters
            cl2p = load([timitlocn '/' outputdir ['/clusterphons_C' num2str(components) '_clusts_pca' num2str(clusts) '.mat']]) ;
            [NMIf_p QFf_p] = compareclusterspca_single_fn(cl2p.f1, cl2p.clusts) ;
            % cl2p = load([timitlocn '/' outputdir ['/clustertest_C' num2str(components) '_clusts' num2str(clusts) '_m.mat']]) ;
            [NMIm_p QFm_p] = compareclusterspca_single_fn(cl2p.m1, cl2p.clusts) ;
            disp([ 'PCA clustering: Components = ' num2str(components) ' Clusters = ' num2str(clusts) ' Female NMI = ' num2str(NMIf_p) ' Male NMI = ' num2str(NMIm_p)]) ;
        end
    end
end

if analyseclusters_ica
    disp(['Analysing ICA clusters starting']) ;

    cl2i = load([timitlocn '/' outputdir ['/ica_projns_' num2str(n_icas)] '.mat']) ;
    [NMIf_i QFf_i] = compareclustersica_single_fn(cl2i.f1, cl2i.n_icas) ;
    %  cl2i = load([timitlocn '/' outputdir ['/ica_projns_' num2str(n_icas)] '_ica_m.mat']) ;
    [NMIm_i QFm_i] = compareclustersica_single_fn(cl2i.m1, cl2i.n_icas) ;
    disp(['ICA clustering: ICAs = ' num2str(n_icas)  ' Female NMI = ' num2str(NMIf_i) ' Male NMI = ' num2str(NMIm_i)]) ;
end

end




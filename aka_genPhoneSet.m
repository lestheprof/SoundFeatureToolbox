
function [pcaclasses_eight, icaclasses_eight, segId] = aka_genPhoneSet()

%Reads all files in a directory
directLoc = '/Volumes/Extra/AllenCorpus/testexp';
soundtyp = 'male';

filName = fullfile(directLoc,'filelist.m');

filePattern = fullfile(directLoc, '*.wav');
filePattern2 = fullfile(directLoc, '*.au');
allFiles=[dir(filePattern);dir(filePattern2)];

[lenSet,~] =size(allFiles);


fid=fopen(filName, 'w+'); % creates file write object
for k=1:lenSet-1
    % writes each file in dir to list
    fprintf(fid,[allFiles(k).name '\n']);
end
fprintf(fid,[allFiles(k+1).name]);
fclose(fid);

fclose('all');

% Call gabor params
gabor3set

% set parameters
setparameters_monoonsets_TIMIT(directLoc,'','')


soundclasslocation = '/Volumes/Extra/timit/';


[pcaclasses_eight, icaclasses_eight, segId] = classifysounds1_fn(directLoc, 'filelist.m', ...
    soundclasslocation,'ANSigDir', 'AMMeanPlain', 'onsetSigdir2', 'onsetMeans2', g3params, ...
    'speechtestout2', 'Vectors250f', 'gabordirs', outputdir, 'n_pcas', 40, 'n_clusters', 200, ...
    'runan', 0, 'runonsets', 0, 'runplainandonsets', 0, 'rungabors', 0,  'segmentsummary', 0, ...
    'numcl', 3,'seglength', 0.1, 'resamplerate', 150,'usepcas', 1, 'useicas', 1, 'n_icas', 200,...
    'numcl_ica', 3) ;

%[pcaclasses_eight, icaclasses_eight] = classifysounds1_fn(directLoc, 'filelist.m', ...
%    soundclasslocation,'ANSigDir', 'AMMeanPlain', 'onsetSigdir2', 'onsetMeans2', g3params, ...
%    'speechtestout2', 'Vectors250f', 'gabordirs', outputdir, 'n_pcas', 40, 'n_clusters', 200, ...
%    'runan', 0, 'runonsets', 0, 'runplainandonsets', 0, 'rungabors', 0,  'segmentsummary', 0, ...
%    'numcl', 3,'seglength', 0.1, 'resamplerate', 150,'usepcas', 1, 'useicas', 1, 'n_icas', 200,...
%    'numcl_ica', 3,'soundtype',soundtyp) ;

for i = 1:length(pcaclasses_eight)
disp(['pca ' pcaclasses_eight{i}.phoneme ' ' num2str(pcaclasses_eight{i}.time) ' ' segId{i}]) ;
disp(['ica ' icaclasses_eight{i}.phoneme ' ' num2str(icaclasses_eight{i}.time) ' ' segId{i}]) ;
end




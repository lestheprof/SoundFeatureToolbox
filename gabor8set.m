timitlocn = '/Volumes/MacHD2/Researchshare/timit3/AU_TIMIT' ;
ANSigDir = 'ANSigDir' ;
outputdirstring = 'gabor20032014_' ;
resamplerate = 250 ;
gabor8setvalue = [0.7 8 0.5 0 19 45; 0.7 9 0.84 pi/8 19 35; 0.7 11 1.414 pi/4 19 35; 0.7 14 2.37 3*pi/8 19 35; ... ] ;
0.7 18 4 pi/2 13 45; 0.7 14 2.37 5*pi/8 19 35; 0.7 11 1.414 3*pi/4 19 35; 0.7 9 0.84 7*pi/8 19 35] ;
[ngabors, gaborparamlength] = size(gabor8setvalue) ;
for i=1:ngabors
    outputdir{i} = [outputdirstring num2str(i)] ;
end

for i=1:ngabors
    disp(['set ' num2str(i)  ' started']) ;
    gb{i}.bandwidth = gabor8setvalue(i,1) ;
    gb{i}.lambda= gabor8setvalue(i,2) ;
    gb{i}.theta= gabor8setvalue(i,4);
    gb{i}.gamma = gabor8setvalue(i,3) ;
        gb{i}.szxvalue = gabor8setvalue(i, 5) ;
    gb{i}.szyvalue = gabor8setvalue(i, 6) ;
% n_gaborrun(i) = generategaboroutputs_mono(timitlocn, '', '', 'tenofeachgen.txt', ANSigDir, outputdir{i}, gb,resamplerate, 0, ...
%        'szxvalue', gabor8setvalue(i, 5), 'szyvalue', gabor8setvalue(i, 6), 'zeromean', 1 ) ;
end


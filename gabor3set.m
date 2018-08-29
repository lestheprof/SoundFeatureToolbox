% thia set is simply am and envelop modulation, all at theta = pi/2
timitlocn = '/Volumes/MacHD2/Researchshare/timit3/AU_TIMIT' ;
ANSigDir = 'ANSigDir' ;
outputdirstring = 'gabor25042014_' ;
% resamplerate = 250 ;
gabor3setvalue = [0.7 9 2 pi/2 13 31; 0.7 21 4 pi/2 13 50; 0.7 50 10 pi/2 13 101] ;
[ngabors, gaborparamlength] = size(gabor3setvalue) ;
for i=1:ngabors
    outputdir{i} = [outputdirstring num2str(i)] ;
end

for i=1:ngabors
    disp(['set ' num2str(i)  ' started']) ;
    g3params{i}.bandwidth = gabor3setvalue(i,1) ;
   
    g3params{i}.lambda= gabor3setvalue(i,2) ;
    g3params{i}.theta= gabor3setvalue(i,4);
    g3params{i}.gamma = gabor3setvalue(i,3) ;
    g3params{i}.szxvalue = gabor3setvalue(i, 5) ;
    g3params{i}.szyvalue = gabor3setvalue(i, 6) ;

% n_gaborrun(i) = generategaboroutputs_mono(timitlocn, '', '', 'tenofeachgen.txt', ANSigDir, outputdir{i}, gb,resamplerate, 0, ...
%         'szxvalue', gabor8setvalue(i, 5), 'szyvalue', gabor8setvalue(i, 6), 'zeromean', 1 ) ;
    g3params{i}.gaborfilter = gabor_fn_1(g3params{i}.bandwidth, g3params{i}.gamma, 0, g3params{i}.lambda, ...
        g3params{i}.theta, 1, 'szx',g3params{i}.szxvalue, 'szy', g3params{i}.szyvalue) ;
end


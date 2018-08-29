% initialise segparams
segparams.kmin = 1000 ;
segparams.kmax = 1000;
segparams.postprocess = 1 ;
segparams.rmin = 1.1 ;
segparams.rmax= 3.5 ;
segparams.numberinset = 5 ;
segparams.disson = 8 ;
segparams.dissoff = 9;

segparams.rp = 0.01 ;
% segparams.mixing = [1 1 1 1 1 1 1 1 1] ;
segparams.mixing = [0.1 0.3 0.5 0.7 0.9 1 1 0.9 0.7 0.5 0.3 0.1] ;

segparams.ooweight_on = 2.0 ;
segparams.ooweight_off = 2.5 ;

segparams.mininterval = 0.01 ;
segparams.weight = 1.5 ;
segparams.minsize = 0.02 ;

% beauchamp = '/Volumes/MacHD2/Researchshare/music/beauchamp/' ;
% allensubset = '/Users/lss/matlab_stuff/stimuli/f101m102/' ;
allensubset = '/Volumes/MacHD2/Researchshare/timit3/allenESNdata/f101m102_subset' ;
allenall = '/Volumes/MacHD2/Researchshare/timit3/allenESNdata/f101m102' ;
runnumber = 0 ;
for ooweight_on = 1.5: 0.25:2.0
    for ooweight_off = 2.25
        segparams.ooweight_on = ooweight_on ;
        segparams.ooweight_off = ooweight_off ;
        disp(['segparams.ooweight_on = ' num2str(segparams.ooweight_on)]) ;
        disp(['segparams.ooweight_off = ' num2str(segparams.ooweight_off)]) ;

        runnumber = runnumber + 1 ;
        % stores the numbers in  allensubset/NBewSegments/XXX_segresults<i>.mat
        [tsh, tsf, cc, dd, ss, ff, seglengths] = generatenewsegmentation_mono(allensubset, '', '', 'temp.txt', 'ANMeanPlain250', 'NewSegments', segparams, 'assesseg', 1, 'epsilon_start', 0.03,'epsilon_end', 0.04,  ...
            'display', 0, 'silent', 1) ;
        disp(['parameter set = ' num2str(runnumber) ': totsegs (by hand) =' num2str(tsh) ' totsegs found = ' num2str(tsf) ' correct = ' num2str(cc) ' deletions = ' num2str(dd) ' start found = ' num2str(ss) ' failure = ' num2str(ff)]) ;
        actuallengthmatrix = seglengths(1:max(find(seglengths ~= 0))) 
        
    end
end
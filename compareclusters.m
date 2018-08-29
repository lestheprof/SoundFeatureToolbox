% try on f1 first
%create a list of phonemes in order
totalphonemes = [] ;
for clno = 1:length(f1{1}.pcamodephonemes)
    totalphonemes = [totalphonemes; f1{1}.pcamodephonemes{clno}] ;
end
utotalphonemes = unique(totalphonemes) ;
% put the pcamodephonemes lists in order, putting the pcaphonfreqclust in
% order at the same time
for clno = 1:3
    [sfpcamodeph{clno}, remap]= sort(f1{1}.pcamodephonemes{clno}) ;
    sfpcaphonfreq{clno} = f1{1}.pcaphonfreqclust{clno}(remap) ;
end
% create array to put occurrences into
allphonemes = zeros([length(utotalphonemes) length(f1{1}.pcamodephonemes)]) ;
% put in the values for each cluster
for clno = 1:length(f1{1}.pcamodephonemes)
    cpno = 1 ;
    for pno = 1:length(utotalphonemes)
        if (cpno <= length(sfpcamodeph{clno})) && (strcmp(utotalphonemes(pno), sfpcamodeph{clno}(cpno)))
            allphonemes(pno, clno) = sfpcaphonfreq{clno}(cpno) ;
            cpno = cpno + 1 ;
        end
    end
end
% now calculate a score
qualityfigure = 0 ;
for pno = 1:length(utotalphonemes)
    % epsilon = (Sigma(epsilon_i) - epsilon_max)/Sigma(epslion_i)
    % calculate Sigma(epsilon_i)
    sigepsilon = sum(allphonemes(pno,:)) ;
    maxepsilon = max(allphonemes(pno,:)) ;
    qualityfigure = qualityfigure + maxepsilon/sigepsilon ; % would like to be near 1
end
qualityfigure = qualityfigure/length(utotalphonemes) ;

        
        



    
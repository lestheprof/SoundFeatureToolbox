function [normmutinf, qualityfigure] = compareclusterspca_single_fn(f1, numclusters)
% compareclusters_fn: takes in the results of the clustering, and returns
% an array of the quality figures for these clusters.
% f1  are generated from processclusters_fn
% the quality figure is a normalised version of
% epsilon_max/Sigma(epslion_i) over all the phonemes in all the clusters.
% Note thatthis will also depend on the value used for const_phonfraction
% in processclusters_fn.

% [numcomponents, numclusters] = size(f1) ; single component number
qualityfigure = 0 ;
normmutinf = 0 ;
mutinf = 0 ;



% disp(['compareclusters_fn ' num2str(compno), ' ' num2str(numclust)]) ;
% try on f1 first
%create a list of phonemes in order
totalphonemes = [] ;
for clno = 1:length(f1.pcamodephonemes)
    totalphonemes = [totalphonemes; f1.pcamodephonemes{clno}] ;
end
utotalphonemes = unique(totalphonemes) ;
% put the pcamodephonemes lists in order, putting the pcaphonfreqclust in
% order at the same time
for clno = 1:length(f1.pcamodephonemes)
    [sfpcamodeph{clno}, remap]= sort(f1.pcamodephonemes{clno}) ;
    sfpcaphonfreq{clno} = f1.pcaphonfreqclust{clno}(remap) ;
end
% create array to put occurrences into
allphonemes = zeros([length(utotalphonemes) length(f1.pcamodephonemes)]) ;
% put in the values for each cluster
for clno = 1:length(f1.pcamodephonemes)
    cpno = 1 ;
    for pno = 1:length(utotalphonemes)
        if (cpno <= length(sfpcamodeph{clno}))
            if (strcmp(utotalphonemes(pno), sfpcamodeph{clno}(cpno)))
                allphonemes(pno, clno) = sfpcaphonfreq{clno}(cpno) ;
                cpno = cpno + 1 ;
            end
        end
    end
end
% now calculate a score
qtemp = zeros([1 length(f1.pcamodephonemes)]) ;
for pno = 1:length(utotalphonemes)
    % needs modified: calculate the quality figure for each
    % cluster, then average these across clusters (without regard
    % for size): still may reward small clusters, but only if they
    % are really good at what they do!
    %
    % epsilon = epsilon_max/Sigma(epslion_i)
    % calculate Sigma(epsilon_i)
    sigepsilon = sum(allphonemes(pno,:)) ;
    [maxepsilon, locn] = max(allphonemes(pno,:)) ;
    qtemp(locn) = qtemp(locn) + maxepsilon/sigepsilon ;
    % qualityfigure(compno, numclust) = qualityfigure(compno, numclust) + maxepsilon/sigepsilon ; % would like to be near 1
end
% qualityfigure(compno, numclust) = qualityfigure(compno, numclust)/length(utotalphonemes) ;
% qualityfigure for each cluster is the qtemp figure divided by the
% number of unique phonemes in that cluster
for clno = 1:length(f1.pcamodephonemes)
    qualityfigure =  qualityfigure + ...
        qtemp(clno)/length(unique(f1.pcamodephonemes{clno})) ;
end
qualityfigure = qualityfigure/numclusters ;

% attempt Normalised Mutual Information

N = sum(sum(allphonemes)) ; % total number of points to cluster
mi = 0 ;
% for each cluster
clustersizes = sum(allphonemes) ;
classsizes = sum(allphonemes') ;
for clno = 1: length(f1.pcamodephonemes)
    
    % for each class
    for classno = 1: size(allphonemes,1)
        % cluster clno intersect class classno is allphonemes(classno, clno)
        if (allphonemes(classno, clno) > 0)
            mi = mi + (allphonemes(classno, clno)/N) * ...
                log2((N * allphonemes(classno, clno))/(clustersizes(clno) * classsizes(classno))) ;
        end
    end
end
% mi not normalised
mutinf = mi ;
% to normalise, divide by (H(clusters) + H(classes)) /2
% Calculate H(clusters)
HC = 0 ;
for clno = 1: length(f1.pcamodephonemes)
    HC = HC - (clustersizes(clno)/N) * log2(clustersizes(clno)/N) ;
end
% calculate H(classes)
Hclasses = 0 ;
for classno = 1: size(allphonemes,1)
    Hclasses = Hclasses - (classsizes(classno)/N) * log2(classsizes(classno)/N) ;
end
normmutinf = mutinf * 2/(HC + Hclasses) ;

end








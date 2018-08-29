% attempt Normalised Mutual Information

N = sum(sum(allphonemes)) ; % total number of points to cluster
nmi = 0 ;
% for each cluster
for clno = 1: length(f1{compno, numclust}.icamodephonemes)
    clustersizes = sum(allphonemes) ;
    classsizes = sum(allphonemes') ;
    % for each class
    for classno = 1: size(allphonemes,1)
        % cluster clno intersect class classno is allphonemes(classno, clno)
        if (allphonemes(classno, clno) > 0)
            nmi = nmi + (allphonemes(classno, clno)/N) * log2((N * allphonemes(classno, clno))/(clustersizes(clno) * classsizes(classno))) ;
        end
    end
end
        
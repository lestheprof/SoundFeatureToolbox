function fmmatrix = makedogfmmatrix(sigma1, sigma2, stdperelement, ncols, nrows, rowshift)
maxelements = ncols + (nrows - 1) * abs(rowshift) ;
if ~odd(maxelements) 
    disp('unexpected even number of elements in makedogmatrix: expected ncols to be odd') ;
    maxelements = maxelements + 1 ;
end
center = (maxelements - 1) /2 ;
% generate the dog vector
dogvector = diffofgaussians(sigma1, sigma2, maxelements, stdperelement) ;
% now generate and populate the fmmatrix
fmmatrix = zeros([nrows ncols]) ;
% startelement should be center - (ncols - 1)/2 at the central row vector
centralrow = ceil(nrows/2) ;
for i = 1:nrows
    startelement = center - ceil((ncols - 1)/2) + (centralrow - i) * rowshift + 1 ;
    % startelement = 1 + (rowshift * (i-1)) ;
    fmmatrix(i, :) = dogvector(startelement: startelement + ncols - 1) ;
end
% normalise
% how? row by row for now
for i = 1 : nrows
    sumrow = sum(fmmatrix(i, :)) ;
    fmmatrix(i,:) = fmmatrix(i,:) - sumrow/ncols ;
end
    


function oddness = odd(number)
oddness = bitand(number,1) ;
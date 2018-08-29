% test out gabor on a single channel
channel = 20; % use this channel
tconv = ones([1 round(AN.Fs/AN.cf(channel))])' ; % precalculate the convolution for each spike
tconv = tconv/length(tconv) ;
newsignal = zeros([1 AN.signal{channel}(1, end) + ...
    round(AN.Fs/AN.cf(channel)) + length(gb5)]) ; % initialise the output
gconv = conv2(tconv, gb5) ;

for anspikeno = 1:length(AN.signal{channel})
    samplenumber = AN.signal{channel}(1, anspikeno) ;
    level = AN.signal{channel}(2, anspikeno) ; 
    %calculate this convolution
    gconv = conv2( level * tconv, gb5) ;
    % add it in
    newsignal(samplenumber:samplenumber+length(gconv) -1) = ...
        newsignal(samplenumber:samplenumber + length(gconv) -1) + squeeze(gconv(:, 10))' ;
end
    
    
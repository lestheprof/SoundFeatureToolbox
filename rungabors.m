% create a range of gabor functions
index = 1 ;
type = 2 ;
for bw = 10:3:26
    gb = gabor_fn(0.7,1,0,bw,0, 0) ;
    gbpatch{index} = gb ;
    index = index + 1 ;
end
% run them
for gbno = 1:index-1
    xx{gbno} = gabormultichannel(1000, AN, gbpatch{gbno}, type) ;
    figure ; mesh(xx{gbno}) ;
end
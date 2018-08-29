function AN = AN_coder_GRM(filt_sig,param)
% AN_coder_GRM: This is the main function of the AN encoder.
% Inputs:
% filt_sig = matrix containing the filtered signal. Each row contains one
% filtered signal. So if we have filtered a 1000-samples signal with a
% filterbank of 10 channels, the filt_sig has to be a matrix of 10x1000.
%
% param = struct containing the main parameters of the toolbox. This is now
% taken partly from the setparameters_monoonsets function, and from the create_AN_files
% function
%
% The output is an array of #num_channels cells. Each cell contains a
% matrix with the spikes corresponding to that filter channel. The first
% row of this matrix contains the sample index of the spike, and the second
% row the sensitivity level of each spike.
%
% Gabriel Reines, Univ. of Edinburgh, 10/05/2013
% Modded LSS 14 5 013. 

tic
cf = param.cf;
AN = cell(1,length(cf));
for i = 1:length(cf)
    % find all the positive-going ZX
    sp_tr = pg_zerocross(filt_sig(i,:));
    % compute the mean amplitude of the previous 1/4 cycle before the ZX
    sp_tr(2,:) = mean_amp_computation(sp_tr,filt_sig(i,:),cf(i),param);
    % eliminate those ZX whose mean amplitude are below the minimum level
    sp_tr(:,sp_tr(2,:)<param.minlevel_zc) = []; % to fit with AN structure
    
    aux = sp_tr(2,:);
    num_levels = param.iterations; % to fit with AN structure
    levels = zeros(1,num_levels);
    levels(1) = param.minlevel_zc;
    for j = 2:num_levels
        % each following level is sqrt(2) times the preceeding (i.e. 3dB)
        levels(j) = levels(j-1)*param.multiplier; % changed to a parameter LSS May 10 2013. 
    end
    
    for j = length(levels):-1:1
        sp_tr(2,aux>=levels(j)) = j;
        aux(aux>=levels(j)) = 0;
    end
    AN{i} = sp_tr;
end
toc
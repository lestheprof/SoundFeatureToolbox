function spiketimes = iandfneurons(activity, fs, th, diss, rp, rrp)
% compute the I and F neuron firing pattern
%
% necessary parameters:
% activity is n_neurons by n_timesteps
% fs is sampling frequency of activity
% optional parameters
% th is threshold
% diss is dissipation
% rp is refractory period
% rrp is relative refractory period
%
% needs thought: requires capability for a RP, possible an RRP
% and better to have output take the form of an array suitable for spikeraster
% sort out optional parameters
if nargin < 3 th = 1; end ;
if nargin < 4 diss = 100; end ;
if nargin < 5 rp = 0.004; end ; % in seconds
if nargin < 6 rrp = 0 ; end ;

maxonsetspikes = 100000 ; % adjust if required

[numNeurons, datalength] = size(activity) ;
deltaT = 1.0 / fs ;
thresholdVector = th * ones(1, numNeurons) ;
onsetActivity = zeros(1,numNeurons) ;
zeroActivity = zeros(1, numNeurons) ;
rpvector = zeros(1, numNeurons) ;
spiketimes = zeros([maxonsetspikes 2])  ; % preallocate
nspikes = 0 ;
% find rp, rrp in samples
rpsamples = floor(rp * fs) ;
rrpsamples = floor(rrp * fs) ;

for tau=1:datalength
   % disp(rpvector) ;
   onsetActivity = onsetActivity + deltaT .* (activity(:,tau)' ...
      - diss .* onsetActivity) ;
   % check if any are  nonnegative and fix
   negact = onsetActivity < zeroActivity ;
   neglist = find(negact) ;
   for i=1:length(neglist) 
      onsetActivity(neglist(i)) = 0 ;
   end ;
   % decrement refractory period vector
   if any(rpvector) % are we in any ref period?
      rpentries = find(rpvector) ;
      for j=1:length(rpentries)
         rpvector(rpentries(j)) = rpvector(rpentries(j))- 1 ;
      end ;
   end ;
   % does it fire ?
   % first adjust thresholds of those in rrp
   % not yet implemented
   onsetfiring = onsetActivity >= th ;
   if any(onsetfiring)
      firelist = find(onsetfiring) ;
      % update onsetspikes, but
      % ignore those in refractory period
      for k=1:length(firelist)
         % reset activity level
         onsetActivity(firelist(k)) = 0 ;
         if rpvector(firelist(k)) == 0
             nspikes = nspikes + 1 ;
             if (nspikes > maxonsetspikes)
                 error(['iandfneurons: too many onset spikes: adjust maxonsetspikes']) ;
             end
            % update spike list
            spiketimes(nspikes,:) = [firelist(k) tau/fs] ;% this should be faster! alter this: slow
            % update refractory period
            rpvector(firelist(k)) = rpsamples ;
         end ;
      end ;
   end ;
end ;
spiketimes = spiketimes(1:nspikes, :) ; % contract to size actually used
end

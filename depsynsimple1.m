function X = depsynsimple1(firetimes,sampleRate, numChannels, dataLength, gperms, alpha, beta)
% removes references to rho and lambda which were 0 in depsyn anyway
%  simulation of a 3-reservoir depressing synapse
% Data is arrayed as one channel per row.
% All channels are done in parallel (but each time step is
% sequential) so it will be much more efficient to process lots
% of channels at once.
%
% new version which does not use the sparse array
% last updated LSS 17 June 2002
%
% gperms is rate factor for effect of incoming spikes per ms (spike is 1 sample long)
% defaults to 700
% alpha is rate factor from cleft to reuptake 
% defaults to 500
% beta is reuptake factor
% defaults to 50%
%  Y is the main reservoir content
%  X is the cleft content
%  W is the reuptake "reservoir" level
%  I is the input at each stepno
%  simlength is the length of the simulation in seconds

if (nargin < 5) gperms = 700 ; end ;
if (nargin < 6) alpha = 500 ; end ;
if (nargin < 7) beta = 50 ; end ;

% initialise parameters
dt = 1.0/sampleRate ; % time step
% lambda = 0 ; %rate of loss from cleft
% rho = 0.00 ; % main reservoir manufacture rate
k = 1 ; %main reservoir maximum level
g = gperms*sampleRate/1000 ; % rate factor for effect of incoming spikes 2000 for 1ms spike

%set reservoir initial values
Y=ones(numChannels,1) ;
X=zeros(numChannels,dataLength) ;
W=zeros(numChannels,1) ;
Znull=zeros(numChannels,1) ;

% a quick check first
if (g * k * dt > 1) 
   disp('rate from Y to X too high') ; 
end ;

% run the simulation
firenumber = 1 ;
[lfiretimes temp] = size(firetimes) ;
g1 = g*k ; % simple optimisation
for stepno=2:1:dataLength
   % compute the rate from reservoir Y to cleft X
   % Z = g1.*data(:,stepno-1) ;
   Z = Znull ;
   endsteptime = ((stepno-1) * dt) ;
   if (firenumber <= lfiretimes)
       while (firetimes(firenumber,2) < endsteptime) 
           Z(firetimes(firenumber,1)) = g1 ;
           firenumber = firenumber + 1 ;
           if (firenumber > lfiretimes) break ; end
       end
   end
   X(:,stepno) = max(X(:,stepno - 1) + dt .* ...
      (Z .* Y - alpha .*  X(:,stepno - 1) ) ,0) ;
   Y = max(Y  + dt .* ...
      (beta .* W - Z .* Y ),0) ;
   
   W = max(W + dt .* ...
      (alpha .* X(:,stepno - 1) - beta .* W),0) ;
   
   if (X(1,stepno) > 1)
      disp('something wrong at') ;
   	disp(X(:,stepno) );   
   end ;
   % Y(31)
end ;


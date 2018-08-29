function [bm,env,instf]=gammatone1(x,fshz,cfhz,N_erbs,pc)


% GAMMATONE gammatone(x,fshz,cfhz,pc) implements the 4th 
% order gammatone filter with centre frequency cfhz (in Hz)
% and sampling frequency fshz (in Hz).
%
% If phase compensation is required, supply anything as the
% 4th argument.
%
% If called with zero or one output arguments, it returns the 
% filter output i.e. simulated basilar membrane displacement. 
%
% Called as [bm,env] = gammatone(x,fshz,cfhz) it returns the 
% filter output and instantaneous envelope. 
%
% Called as [bm,env,instf] = gammatone(x,fshz,cfhz) it returns 
% the filter output, instantaneous envelope and frequency.
%

% Implementation by impulse invariant transform as described in
% Cooke's thesis. Phase compensation as suggested by Holdsworth.
%
% REVISION HISTORY
%
% Extended by Martin from Guy's version - 20 Feb 96
%
% Extended by Guy 3/6/99 to do proper phase compensation (i.e. peak of
% impulse response envelope is aligned with fine structure). This is
% achieved by introducing a phase delay when shifting down to d.c.

wcf=2*pi*cfhz;	 	        	% radian frequency
tpt=(2*pi)/fshz;
bw=N_erbs*erb(cfhz)*bwcorrection;	% bandwidth
a=exp(-bw*tpt);
gain=((bw*tpt)^4)/6; 	     	% based on integral of impulse response

delay=1;
pc=0;
if nargin == 5
  delay = floor(gammatoneDelay(cfhz,fshz));		% envelope delay
  x=[x zeros(1,delay)];
  delay=delay+1;
  pc=-cfhz*3/bw;										% phase correction of fine structure
end;

kT=[0:length(x)-1]/fshz;

q=exp(j*(-wcf*kT+pc)).*x;								% shift down to d.c.
p=filter([1 0],[1 -4*a 6*a^2 -4*a^3 a^4],q);		% filter: part 1
u=filter([1 4*a 4*a^2 0],[1 0],p);
  				% filter: part 2
bm=gain*real(exp(j*wcf*kT).*u);						% shift up in frequency

bm=bm(delay:length(bm)); 								% apply phase correction to envelope

if nargout > 1
  												% instantaneous envelope
  
  env = gain*abs(u);
  env=env(delay:length(env));
  
  if nargout == 3
    											% instantaneous frequency
    instf=real(cfhz+[diff(unwrap(angle(u))) 0]./tpt);
    instf=instf(delay:length(instf));
  
  end
end
    





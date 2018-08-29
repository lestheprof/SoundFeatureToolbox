function onsetfiring = onsetnew(AN, channel)
% onsetfiring: creates a 2d array of offset firing times in a single channel
% new version  of offset - and perhaps onset later as well.
% LSS 6 April 2014.
%

period = 1.0/AN.cf(channel) ;

exc_risetime = 0.001 ;
exc_staytime = max(0.005, 2*period) ;
exc_falltime = 0.005 ;
excmaxvalue = (2*period/0.005) ;
inh_risetime = 0.005 ;
inh_staytime = max(0.01,2*period) ;
inh_falltime = 0.005 ;
inhmaxvalue = 0 ;
excactivitylimiter = 2.0 ;

% channel =42 ;

% offset synaptic responses.
% shape for excitatory signal
excduration = ceil(exc_risetime* AN.Fs) + ceil(exc_staytime * AN.Fs) + ceil(exc_falltime * AN.Fs );
excvector = zeros(1, excduration) ;
% fill excvector
excvector(1:ceil(exc_risetime *AN.Fs)) = (1:ceil(exc_risetime *AN.Fs))/(ceil(exc_risetime *AN.Fs) * excmaxvalue) ;
excvector(ceil(exc_risetime *AN.Fs)+1 :ceil(exc_risetime *AN.Fs) + ceil(exc_staytime * AN.Fs) + 1) = excmaxvalue ;
excvector(ceil(exc_risetime *AN.Fs) + ceil(exc_staytime * AN.Fs) +1 : (ceil(exc_risetime * AN.Fs) +  ceil(exc_staytime * AN.Fs) + ceil(exc_falltime * AN.Fs ))) = ...
    (ceil(exc_falltime*AN.Fs):-1:1)/ ...
    (ceil(exc_falltime*AN.Fs) * excmaxvalue);
% shape for inhibitory signal
inhduration = ceil(inh_risetime* AN.Fs) + ceil(inh_staytime * AN.Fs) + ceil(inh_falltime * AN.Fs );
inhvector = zeros(1, inhduration) ;
inhvector(1:ceil(inh_risetime *AN.Fs)) = ((ceil(inh_risetime *AN.Fs):-1:1)-1) /(ceil(inh_risetime *AN.Fs) * (1-inhmaxvalue)) ;
inhvector(ceil(inh_risetime *AN.Fs) +1 : ceil(inh_risetime *AN.Fs) + ceil(inh_staytime * AN.Fs)) = 0 ;
inhvector(ceil(inh_risetime *AN.Fs) + ceil(inh_staytime * AN.Fs)+ 1: (ceil(inh_risetime *AN.Fs) + ceil(inh_staytime * AN.Fs) + ceil(inh_falltime *AN.Fs))) = ...
    (1:ceil(inh_falltime *AN.Fs)) /(ceil(inh_falltime *AN.Fs) *(1-inhmaxvalue)) ;

%offset calculation
% for each spike in channel, add the excvector in
% initialise first
activityexc = zeros(AN.iterations, AN.datalength+length(excvector)) ;
activityshunt = ones(AN.iterations, AN.datalength+length(inhvector)) ;

% fill in for each spike
for spikeno = 1:length(AN.signal{channel})
    for sno = 1:AN.signal{channel}(2, spikeno)
    activityexc(sno,AN.signal{channel}(1,spikeno) :AN.signal{channel}(1,spikeno) + excduration - 1) ...
        =    activityexc(sno,AN.signal{channel}(1,spikeno) :AN.signal{channel}(1,spikeno) + excduration - 1) + ...
        excvector ;
        activityshunt(sno,AN.signal{channel}(1,spikeno) :AN.signal{channel}(1,spikeno) + inhduration - 1) ...
       = min(activityshunt(sno,AN.signal{channel}(1,spikeno) :AN.signal{channel}(1,spikeno) + inhduration - 1), inhvector) ;
    end
end
% nonlinear capping of values at each synapse
% make activityexc peak at 1, and activityshunt have lowest value of 0.
activityexc(activityexc > excactivitylimiter) = excactivitylimiter ;
activityshunt(activityshunt < 0) = 0 ;
% ensure that output has sampe length as input
activityexc = activityexc(:, 1:AN.datalength) ;
activityshunt = activityshunt(:, 1:AN.datalength) ;
% dot-product of shunt and excitation 
activity = activityexc .* activityshunt ;
onsetfiring = (activity >= 1) ;

end






 


function [totalfiretimes, wide_times] = onsetside_zc7_mono(anspikes, onsetparams)

% run after generateANsignals
% generates  onset spikes for a set of channels, logically on 1 side
% side should be 1= or 2=
% where 1 = left, 2 = right
% anspikes is the AN spike train structure
% This version:
%   
%   for each iteration
%       uses multiple AN spikes most sensitive are number 1, etc.
%       has 1 depressing synapse between each AN fiber and each onset cell
%       computes onset cell outputs (1 per AN: uses wttoonset_wide as link strength => widetimes)
%   sorts the AN cell outputs into time within channel
%   sorts the onset cell outputs into time within channel
%
%
% Nov 12 started modularisation. No globals.
% Nov 28: trying out an inhibitory shunting synapse as well
%
% new version 6 3 2003: multiple AN/s channel, with input from a number of
% channels (uses spread_wide from onset_params)

% mono version LSS 16 5 2003

filename = anspikes.experiment ;
fs = anspikes.fs ;
datalength = anspikes.datalength ;
cochCFs = anspikes.cochCFs ;
numchans = length(cochCFs) ;
iterations = anspikes.iterations ;
wttoonset_wide = onsetparams.onsetcellwt_wide ; % weight to onset cell
depsynparams_wide = onsetparams.depsynparams_wide ; % depressing synapse parameters
spread_wide = onsetparams.spread_wide ; % number of AN fibers on each side of centre

wide_times = [] ;

% parameters for I and F for 1 onset cell/AN fiber now come from the onsetparams structure
th_iandf_wide = onsetparams.th_iandf_wide ; % always 1 (Threshold)
% let's try making diss a vector, with value proportional to frequency
dissconst_wide = onsetparams.dissconst_wide ;
diss_wide = dissconst_wide .* cochCFs ; % but note that this may require to be modified later

% and here's the modification (same as onsetside5)
fmaxdiss_wide = onsetparams.fmaxdiss_wide ; % was 1500
% find 1st band above this frequency
s1 = find(cochCFs > fmaxdiss_wide) ;
if (~isempty(s1))
    diss_wide(s1(1):length(cochCFs)) = diss_wide(s1(1)) ;
end
% and level diss off below some frequency too
fmindiss_wide = onsetparams.fmindiss_wide ; % was 1000
s2 = find(cochCFs < fmindiss_wide) ;
if (~isempty(s2))
    diss_wide(1:s2(length(s2))) = diss_wide(s2(length(s2))) ;
end

rp_wide = onsetparams.rp_wide ; % refractory period in seconds
rrp_wide = onsetparams.rrp_wide ; % not currently used
spread = onsetparams.spread_wide ; % spread on input to onset cells

totalfiretimes=[] ; % for AN 

% generate fire and firetimes arrays from zero crossings
% just call once, and do the multiple iterations internally
% mark each zxlist element with a 1 in position (x,3) if it causes a firing

zxstructure = anspikes.zxstructure ;

    
activity_wide = zeros( numchans, datalength) ; % accumulated activity

% process 1 iteration at a time
for iterno = 1:iterations

    firetimes = zxstructure(iterno).list ;
    
    % totalfiretimes has all the firing times on the AN, over all the iterations
    totalfiretimes=[ totalfiretimes ; firetimes] ;
    
    if (~isempty(firetimes))
	% sort into time within channel no
        firetimes = sortrows(firetimes,[2 1]) ;
    end
    % compute depressing synapse output
    % note that other parameters are currently inside the function depsyn()
    % 3rd parameter is g per ms, 4th parameter is alpha
    activity_wide = depsynsimple1(firetimes, fs, numchans, datalength, ...
        depsynparams_wide(1), depsynparams_wide(2), depsynparams_wide(3)) ;
    activity_widenew = activity_wide ;
    % produce a new vector from activity_wide which includes the spread
    for j = 1:numchans

        for k = 1:spread
            if (j-k > 0)
                activity_widenew(j,:) =  activity_widenew(j,:) +  activity_wide(j-k,:) ;
            end
            if (j+k <=numchans)
                activity_widenew(j,:) =  activity_widenew(j,:) +  activity_wide(j+k,:) ;
            end
        end
    end
    clear activity_wide ;
    % produce Iand F output
    wide_times(iterno).list = iandfneurons(activity_widenew * wttoonset_wide, fs, ...
        th_iandf_wide, diss_wide, rp_wide, rrp_wide);
end;


% the input to each 
% sort the auditory nerve firing times by time then channel number
if (~isempty(totalfiretimes))
    totalfiretimes = sortrows(totalfiretimes,[2 1]) ;
end

% sort the output onset spike times (1/AN) by channel number then by spike time
% if (~isempty(stimes))
%     stimes = sortrows(stimes,[1 2]) ;
% end ;



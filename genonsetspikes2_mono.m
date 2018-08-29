function [an, onset_wide] =...
    genonsetspikes2_mono(anspikes, onsetparams, display)
% Takes the anspikes structure and generates the onset spikes from this
% onsetcellweight is the weight to the onset cells (1/AN)
% onsetcellweight_band is the weight to the 2nd set of onset cells, (1/Band)
% depsynparams are the depressing synapse parameters for 1st onset cells
% 
% display : 0 no graphs, 1: onset cells only, 2: all
%
% generates nerve spikes in AN and onset for both left and right

% new version: 2 sets of onset cells, 1 per AN, and 1 per band
% started 22 July 2002
% new version 12 Nov 2002: no globals
% 
% modded 21 11 2002, to use onsetparams and transmit them to onsetsize_zc4 so that 
% ALL the parameters are on-file (and not in the program)
%
% calls onsetspikes7, generating onset spikes per AN fiber , with
% cross-band input LSS 7.3.2003
%
% Mono version LSS 16 5 2003
%
% Modified to call onsetside_zc8_mono 31 5 2013


if (nargin < 2) 
    onsetparams.onsetcellwt = 50 ;
    onsetparams.onsetcellwt_wide = 50 ; 
    onsetparams.depsynparams = [700 3000 10] ; 
    onsetparams.depsynparams_band = [700 3000 10] ; % may need others added    
end

if (nargin < 3) display = 0 ; end ;


% get local variables from anspikes structure
% filename = anspikes.experiment ;
% noCochFilt = anspikes.numchannels ;
% datalength = anspikes.datalength ;
% fs = anspikes.fs ;



[an, onset_wide] = onsetside_zc8_mono(anspikes,  onsetparams) ;



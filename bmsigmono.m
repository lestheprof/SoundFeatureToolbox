function  [bmSig, sig, fs, datalength, cochCFs, delayVector] = ...
    bmsigmono(fname, nFilt, minCochFreq, maxCochFreq, duration, filter_type, N_erbs)
% performs the bmm operation using the gammatone function by default, or the cauer filter if this is set in filter_type, and leaves the
% results in  bmSig - bandpassed signal sig - original sound fs - sampling
% frequency cochCFs - cochlear Fc's delayVector - vector of delays in
% gammatone filters, but 0 in Cauer filters, duration is the length of the sound to read, in seconds
%
% like bmsigstereo, but it expects a mono signal
% now returns a 2d output.
%
% this version started 12 Nov 2002 LSS
% this mono version started 16 May 2003
% minor  mod 23 1 2004, to remove irrelevant defaults
% minor mode 3 2 2004, added N_erbs allowing varying bandwidth for
% gammatone

% modified to cope with both .wav and .au extensions LSS 3 12 2003.
% modified to return a 2D output (no need to squeeze!)

if (nargin < 6) filter_type = 'gamma' ; end ;
if (nargin < 7) N_erbs = 1 ; end ;

% start by reading the file fname into vector sig, sampling freq fs
locn = findstr('.', fname) ; % find occurrences of .
suffix = fname(locn(length(locn))+1: length(fname)) ; % find suffix
% now read file
% if strcmp(suffix ,'au') %commented out 8 jan 2016.
%     [sig, fs, bits] = auread(fname);
% else if strcmp(suffix ,'AU')
%         [sig, fs, bits] = auread(fname);
%     else if strcmp(suffix , 'wav')
%             [sig,fs,bits] = wavread(fname) ;
%         else if strcmp(suffix , 'WAV')
%                 [sig,fs,bits] = wavread(fname) ;
%             else
%                 error(['Invalid suffix = ' suffix]) ;
%             end ;
%         end ;
%     end;
% end;

[sig, fs] = audioread(fname) ; % modifiend 8 Jan 2016.

% check sound is mono 
if (size(sig, 2) ~= 1) 
   disp('input sound file is not mono: left (chan1) used') ;
   sig = sig(:,1) ;
end ;

% if the sound is longer than duration, read it again, but only for
% duration this time (necessary, as we don't know the sampling rate to
% start with)
if (length(sig)/fs > duration)
    clear sig ;
%     if (strcmp(suffix ,'au') || strcmp(suffix ,'AU')) % commented out 8
%     jan 2016
%         [sig, fs, bits] = auread(fname, duration * fs);
%     else if (strcmp(suffix , 'wav') || strcmp(suffix ,'WAV'))
%             [sig,fs,bits] = wavread(fname, duration * fs) ;
%         else
%             error(['Invalid suffix = ' suffix]) ;
%         end
%     end ;
    [sig,fs] = audioread(fname, [1 duration * fs]) ; % modified 8 Jan 2016
end
    

datalength = length(sig);
bmSig = zeros(nFilt,datalength) ; % initialise mono  signal
instf = zeros(nFilt) ;
delayvector = zeros(1, nFilt) ;


% set up the filter band centre frequencies
cochCFs=MakeErbCFs(minCochFreq,maxCochFreq,nFilt);
% do a number of adjacent channels perform the filtering (but just 1
% channel at a time)
side = 1 ; % mono Modded LSS 14 5 2013: make output 2D
    
	for c=1:1:nFilt  % which channel
    
     if (eq(filter_type,'cauer'))
         [f_1, f_2] = cauer_bandwidth_erb_original(cochCFs, c);   
         [bmSig(c,:), env, instf] = cauer_final(sig(:,side)',fs, f_1, f_2);
            %% DUMMY COMPENSATION x, fshz, cochCFs, f_1, f_2, Rp, Rs, pc
            delayVector = zeros(size(delayVector));
        else
	        [bmSig(c,:), env, instf] = gammatone1(sig(:,side)',fs,cochCFs(c),N_erbs); %no del comp
            delayVector(c) = gammatoneDelay(cochCFs(c),fs,N_erbs) * (1/fs) ; % channel delay in seconds
            %% COMPENSATION uncomment to remove delay compensation
            %% delayVector = zeros(size(delayVector));
     end; %if
     
 end;



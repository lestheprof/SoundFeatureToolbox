function [ gbsummary_all, finalgdotproduct, finalgallproduct ] = analysegabors( timitlocn, filelistname, gdirectorybase, ngabors, varargin )
%analysegabors2: analysis of the gabors produced
%   for the gabor outputs produced in the directories [gdirectorybase num2str(i)] for i from 1 to ngabors,
% look at each each file in filelist, and from it create an ngabor by ngabor
% matrix which measures the co-occurrence (in some difrerent senses) of
% these Gabor outputs


% lss 18 March 2014: started
% normalisation?
%

%location of stem
if isempty(timitlocn) % default value
    timitlocn = '/Volumes/MacHD2/Researchshare/timit3/AU_TIMIT' ;
end

% when we do the summarisation, we can either add up over the frequency
% bands (giving a vector whose length is the length of the signal), or over time
% (giving a vector whose length is the number of bands in the signal).
summarise = 'bands' ; % bands is default. Alternative is 'time'
normalise = 0 ; % do we normalise the Gabor's before correlation? default is no

i=1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'summarise';
            summarise=varargin{i+1};
            i=i+1;
        case 'normalise'
            normalise=varargin{i+1};
            i=i+1;
            
        otherwise
            error('analysegabors: Unknown argument %s given',varargin{i});
    end
    i=i+1;
end

if (strcmpi(summarise, 'bands') == 1)
    bands = 1 ;
else if (strcmpi(summarise, 'time') == 1)
        bands = 0 ;
    else
        error('analysegabors: invalis summarse type') ;
    end
end


% read input_filelist to get the list of files to be processed
inputfid = fopen([timitlocn  '/' filelistname]) ;
fline = fgetl(inputfid) ;
noofexperiments = 1 ;
while ischar(fline)
    filelist{noofexperiments} = fline ;
    fline = fgetl(inputfid) ;
    noofexperiments = noofexperiments + 1 ;
end
noofexperiments = noofexperiments - 1 ;
if (noofexperiments == 0)
    error('No files to be processed') ;
end
fclose(inputfid) ;

gdotprod = zeros(ngabors) ;
gallprod = zeros(ngabors) ;
finalgdotproduct = zeros([noofexperiments ngabors ngabors]) ;
finalgallproduct = zeros([noofexperiments ngabors ngabors]) ;
for j=1:noofexperiments
    % display experiment info
    disp([filelist{j} ' calculating correlations between Gabors']) ;
    
    % split the file name stem from ths suffix
    % will not work if there's more than 2 '.' characters in filename
    fileparts = strsplit(filelist{j}, '.') ;
    numstrings = length(fileparts) ;
    if numstrings == 3
        startpart = [fileparts{1} '.' fileparts{2}] ;
        % suffix = fileparts{3} ;
    else
        startpart = fileparts{1} ;
        % suffix = fileparts{2} ;
    end
    % filestem = [startpart '.'] ; % filestem includes the .
    for gno = 1:ngabors
        % read in the Gabor filteroutput for this file, and this gabor filter
        gabors(gno)  = load([timitlocn    '/' gdirectorybase  num2str(gno) '/' startpart '_gaboroutputs.mat']) ;
    end
    if bands
        gbsummary = zeros([ngabors size(gabors(gno).gaboroutput{1}, 1)]) ;
    else
        gbsummary = zeros([ngabors size(gabors(gno).gaboroutput{1}, 2)]) ;
    end
    for gno = 1:ngabors
        if bands
            gbsummary(gno, :) = sum(gabors(gno).gaboroutput{1}, 2)  / size(gabors(gno).gaboroutput{1}, 2) ;
        else
            gbsummary(gno, :) = sum(gabors(gno).gaboroutput{1}, 1)/ size(gabors(gno).gaboroutput{1}, 1) ;
        end
    end
    normalisingfactors = zeros([1 ngabors]) ;
    if normalise
        for gno = 1:ngabors
            normalisingfactors(gno) = norm(gbsummary(gno, :)) ;
        end
    end
    
    for gnopre = 1:ngabors
        
        for gnopost = 1:ngabors
            
            if normalise
                gdotprod(gnopre, gnopost) = sum((gbsummary(gnopre, :)/normalisingfactors(gnopre)) ...
                    .* (gbsummary(gnopost, :)/normalisingfactors(gnopost))) ;
                gallprod(gnopre, gnopost) = ((sum(gbsummary(gnopre, :))/normalisingfactors(gnopre)) ...
                    * (sum(gbsummary(gnopost, :))/normalisingfactors(gnopost))) ; %- gdotprod(gnopre, gnopost) ;
            else
                gdotprod(gnopre, gnopost) = sum(gbsummary(gnopre, :) .* gbsummary(gnopost, :)) ;
                
                gallprod(gnopre, gnopost) = (sum(gbsummary(gnopre, :)) * sum(gbsummary(gnopost, :))); % - gdotprod(gnopre, gnopost) ;
            end
        end
    end
    finalgdotproduct(j, :, :) = gdotprod ;
    finalgallproduct(j, :, :) = gallprod ;
    gbsummary_all{j} = gbsummary ;
    
    
end


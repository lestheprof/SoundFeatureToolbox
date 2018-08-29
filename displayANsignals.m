function displayANsignals(stimulibasedir, experimentname,dirname, input_filelist, anSigDir, display, dispchannels, optionaltime)
% revised March 2016
% displays the AN signals from a set fo files named in input_filelist. The
% files are in [stimulibasedir experimentname  dirname '/' anSigDir '/' startpart '_ANSig.mat']
% where start[part is derived from the file names in input_filelist
% display is L or R or B
% dispchannels is array with channels to be displayed, first channel goes
% at top
% Note that the parameters file needs to exist, and should correspond with
% the AN file!


% get parameter file
if (exist([stimulibasedir  experimentname '/' dirname '/' 'parameters_monoonset.mat'],'file') )   
    % read the file
    load([stimulibasedir  experimentname '/' dirname '/' 'parameters_monoonset.mat']) ;
else
    disp('No parameter file found. Stopping') ;
    return ;
end

% read input_filelist to get the list of files to be processed
inputfid = fopen([stimulibasedir  experimentname '/' dirname '/' input_filelist]) ;
fline = fgetl(inputfid) ;
noofexperiments = 1 ;
while ischar(fline)
    filelist{noofexperiments} = fline ;
    fline = fgetl(inputfid) ;
    noofexperiments = noofexperiments + 1 ;
end
fclose(inputfid) ;
noofexperiments = noofexperiments - 1 ;
if (noofexperiments == 0)
    error('No files to be processed') ;
end

endtime = 0 ;
if (exist('optionaltime', 'var'))
    starttime = optionaltime(1) ; 
    endtime = optionaltime(2) ;
end

for j=1:noofexperiments
    % display experiment info
    disp([filelist{j} ' drawing']) ;
    % cochlear filtering and AN generation already done.
    
    % split the file name stem from ths suffix
    % will not work if there's more than 2 '.' characters in filename
    fileparts = strsplit(filelist{j}, '.') ;
    numstrings = length(fileparts) ;
    if numstrings == 3
        startpart = [fileparts{1} '.' fileparts{2}] ;
        suffix = fileparts{3} ;
    else
        startpart = fileparts{1} ;
        suffix = fileparts{2} ;
    end
    
   load([stimulibasedir experimentname  dirname '/' anSigDir '/' startpart '_ANSig.mat']) ;
    
    % find the maximal value for the sensitivity level and use this to
    % scale
    maxscale = 1 ;
    for chx = 1:length(dispchannels)
        maxscale  = max(maxscale, max(AN.signal{chx}(2,:))) ;
    end
    
    if (display == 'L' || display == 'B') % left or both
        % display AN from left side
        % which channels
        figure ;
        for xx = 1:length(dispchannels) % for each channel to display
            chno = dispchannels(xx) ;
            
            % for annumber = 1:AN.iterations % plot each AN fiber one by one
                % order by time within channel number
                s1data = [] ;
                if ~isempty(AN.signal{xx}) % ignore channels with no spikes
                    % draw a line of length AN.signal{xx}(2,i) at sample AN.signal{xx}(1,i)
                    % plot this set of points
                    
                        subplot(length(dispchannels), 1, xx) ;
                      
                        % plot(AN.signal{xx}(1,:)/AN.Fs, AN.signal{xx}(2,:),'.', 'MarkerSize', 3) ;
                        stem(AN.signal{chno}(1,:)/AN.Fs, AN.signal{chno}(2,:),'.', 'MarkerSize', 3) ;  
                        axis off
                        hold on
                   
                end
           %  end % plot this AN number  
            % annotate the graph just drawn
            if xx == 1
                title([filelist{j} ' Left.  AN firing']) ;
            end
            if xx == length(dispchannels)
                xlabel(['channel ' num2str(chno)]) ;
            end
            if endtime == 0
                xlim([0 AN.datalength/AN.Fs] );
            else
                xlim([starttime endtime] );
            end
            ylim([0 maxscale + 1]) ;
            hold off
        end % channel
        
    end % display
    
    
end


function [ annotatedsegments ] = annotate_segments( segmentarray, phnfilelocation, samplerate )
%annotate_segments annotates the segment struct array with phonetcis from
%the .phn files
%   for each segment, adds the sequence of phonetics from the .phn file.
%   The first one is likely to be partial, the intermediate ones will be
%   complete, and the last one is l;ikely to be partial. Note that the .phn
%   file is in samples, hnce the need for the samplerate parameter. The
%   annotation is however, in secopnds, as are the segment times.
%
% started LSS 25 June 2013.
%
% maximum number of phons per segment. If more are needed adjust
% declaration of annotatedsegments
maxphonseg = 5 ; 
edgedelta = 0.008 ; % if overlap at start < this, ignore

lastfilename = '' ;  
% initialise lines array once - should help efficiency. I think 200 is
% enough for all the .PHNs.
lines([1 200]) = struct('start',0, 'final', 0, 'phon', '', 'startseconds', 0, ...
            'finalseconds', 0) ;
        
% initialise the output as well. Max of 5 segments (may not be enough)
annotatedsegments([1 length(segmentarray)]) = struct('segstart', 0, 'segend', 0, ...
    'filename', '','nphons', 0, 'phonstarts', [0 0 0 0 0], 'phonends', [0 0 0 0 0], ...
    'phonarray', char('xxxx' ,'xxxx', 'xxxx', 'xxxx', 'xxxx')) ;
        
for segno = 1:length(segmentarray)
    % is this the same file as last time?
    if (~strcmp(segmentarray(segno).filename, lastfilename))
        % change of file: read this .phn file in
        % parse the filename, because it has .AU on the end and we need to
        % remove it
        fileparts = strsplit(segmentarray(segno).filename, '.') ;
        numstrings = length(fileparts) ;
        if numstrings == 3
            startpart = [fileparts{1} '.' fileparts{2}] ;
            suffix = fileparts{3} ;
        else
            startpart = fileparts{1} ;
            suffix = fileparts{2} ;
        end
        filestem = [startpart '.'] ;
        filename = [filestem 'PHN'] ;
        % open the file
        phnhandle = fopen([phnfilelocation '/' filename]) ;

        linenumber = 1 ;
        lines(linenumber).start = fscanf(phnhandle,'%d',1) ;
        lines(linenumber).final = fscanf(phnhandle,'%d',1) ;
        lines(linenumber).phon = fscanf(phnhandle,'%s',1) ;
        lines(linenumber).startseconds = lines(linenumber).start/samplerate;
        lines(linenumber).finalseconds = lines(linenumber).final/samplerate ;
        phon = '';
        while (~strcmp(phon, 'h#'))
            linenumber = linenumber + 1 ;
            lines(linenumber).start = fscanf(phnhandle,'%d',1) ;
            lines(linenumber).final = fscanf(phnhandle,'%d',1) ;
            lines(linenumber).startseconds = lines(linenumber).start/samplerate;
            lines(linenumber).finalseconds = lines(linenumber).final/samplerate ;
            phon = fscanf(phnhandle,'%s',1) ;
            lines(linenumber).phon = phon ;
        end
        lastfilename = segmentarray(segno).filename ;
        linepointer = 1 ;
        fclose(phnhandle) ;
    end
    
    % now process the next segment
    while ((lines(linepointer).finalseconds < segmentarray(segno).segstart) && ...
        (linepointer <= linenumber))
        linepointer = linepointer + 1 ;
    end
    % start of segmnent segno is now before the end of the current line in
    % PHN
    % fill up the annotatedsegments data structure from original
    annotatedsegments(segno).segstart = segmentarray(segno).segstart ;
    annotatedsegments(segno).segend = segmentarray(segno).segend ;
    annotatedsegments(segno).filename = segmentarray(segno).filename ;
    nphons = 0 ;
    while ((linepointer <= linenumber) && ...
            (lines(linepointer).startseconds < segmentarray(segno).segend))

        % add a phoneme 
        nphons = nphons + 1 ;
        if (nphons > maxphonseg)
            disp(['Phonemes in segment ' num2str(segno) ' exceeds ' num2str(maxphonseg) ': later phonemes ignored ']) ;
        else
            % if this phoneme ends after the beginning of this segment by more than edgedelta,
            % we should use the previous one too
            if linepointer > 1
            if ((lines(linepointer-1).finalseconds > (segmentarray(segno).segstart + edgedelta)) ...
                    && (nphons ==1))
                
                % store the last phoneme here as well
                annotatedsegments(segno).nphons = nphons ;
                annotatedsegments(segno).phonstarts(nphons) = lines(linepointer-1).startseconds ;
                annotatedsegments(segno).phonends(nphons) = lines(linepointer-1).finalseconds ;
                % horrible kludge: but how can I get a string into a 4 char
                % array?
                x1 = char(lines(linepointer-1).phon, '    ') ;
                annotatedsegments(segno).phonarray(nphons,:) = x1(1,:) ;
                nphons = nphons + 1 ;
                
            end
            end
            % store this phomeme
            annotatedsegments(segno).nphons = nphons ;
            annotatedsegments(segno).phonstarts(nphons) = lines(linepointer).startseconds ;
            annotatedsegments(segno).phonends(nphons) = lines(linepointer).finalseconds ;
            % horrible kludge: but how can I get a string into a 4 char
            % array?
            x1 = char(lines(linepointer).phon, '    ') ;
            annotatedsegments(segno).phonarray(nphons,:) = x1(1,:) ;
        end
        linepointer = linepointer + 1 ;
    end
        
    
end % segno for loop
        

end


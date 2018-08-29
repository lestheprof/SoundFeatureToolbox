%count the number of segments with 2 phonemes, and examine how much of each
%phoneme is inside each segment. Segments are in annotatedsegs.
% added 2 July 2013: records which phonemes are where. Uses symbolset,
% assumed ordered.
% LSS 28 June 2013.
% convert sumbol array to cell

symbolsetcell = num2cell(symbolset, 2) ; % all around the houses, but
% easier than writing a full string mathcing routine. Will use
% find(strcmp(str, symbolsetcell)); Phew.
hhashstart = 0 ;
hhashend = 0 ;
closurecount = 0 ;
p1insegno = 0 ;
p1insegarray = zeros ([1 length(annotatedsegs)]) ;
p2insegno = 0 ;
p2insegarray = zeros ([1 length(annotatedsegs)]) ;
seglengths2 = zeros ([1 length(annotatedsegs)]) ;
segswithtwophons = 0 ;
hhashstart3 = 0 ;
hhashend3 = 0 ;
segswith3phons = 0 ;
p1insegno3 = 0 ;
p3insegno = 0 ;
p1insegarray3 = zeros ([1 length(annotatedsegs)]) ;
p3insegarray3 = zeros ([1 length(annotatedsegs)]) ;
p2lengthssegarray3 = zeros ([1 length(annotatedsegs)]) ;

seglengths3 = zeros ([1 length(annotatedsegs)]) ;
% arrays to hold the number of each phoneme in each position.
s2p1 = zeros([1 length(symbolset)]) ; % segment of length 1 phoneme 1 etc.
s2p2 = zeros([1 length(symbolset)]) ;
s3p1 = zeros([1 length(symbolset)]) ;
s3p2 = zeros([1 length(symbolset)]) ;
s3p3 = zeros([1 length(symbolset)]) ;
s1p1 = zeros([1 length(symbolset)]) ;


for i = 1:length(annotatedsegs)
    if  (annotatedsegs(i).nphons == 1)
        % record which phoneme is found
        p1no = find(strcmp(annotatedsegs(i).phonarray(1,:), symbolsetcell)) ;
        s1p1(p1no) = s1p1(p1no) + 1 ;
        
    else
        
        if (annotatedsegs(i).nphons == 2) % two segment elements
            % histogram the phonemes found
            p1no = find(strcmp(annotatedsegs(i).phonarray(1,:), symbolsetcell)) ;
            p2no = find(strcmp(annotatedsegs(i).phonarray(2,:), symbolsetcell)) ;
            s2p1(p1no) = s2p1(p1no) + 1 ;
            s2p2(p2no) = s2p2(p2no) + 1 ;
            % form histogrammable array of segment lengths
            segswithtwophons = segswithtwophons + 1 ;
            seglengths2(segswithtwophons) = annotatedsegs(i).segend - annotatedsegs(i).segstart ;
            if strcmp(annotatedsegs(i).phonarray(1,:), 'h#  ') % start of data
                hhashstart = hhashstart + 1 ;
            else
                % closures?
                temp = annotatedsegs(i).phonarray(1,:) ;
                clpart = temp(2:3) ;
                if strcmp(clpart, 'cl')
                    closurecount = closurecount + 1 ;
                else
                    if strcmp(annotatedsegs(i).phonarray(2,:), 'h#  ') % end of data
                        hhashend = hhashend + 1 ;
                    else
                        % how much of the 1st phoneme is in the segment?
                        p1inseg = annotatedsegs(i).phonends(1) - annotatedsegs(i).segstart ;
                        p1insegno = p1insegno + 1 ;
                        p1insegarray(p1insegno) = p1inseg ;
                        % and how much of the second segment is in the segment?
                        p2inseg = annotatedsegs(i).segend - annotatedsegs(i).phonstarts(2) ;
                        p2insegno = p2insegno + 1 ;
                        p2insegarray(p2insegno) = p2inseg ;
                    end
                end
            end
        else if (annotatedsegs(i).nphons == 3) % three segment elements
                % histogram the phonemes found
                p1no = find(strcmp(annotatedsegs(i).phonarray(1,:), symbolsetcell)) ;
                p2no = find(strcmp(annotatedsegs(i).phonarray(2,:), symbolsetcell)) ;
                p3no = find(strcmp(annotatedsegs(i).phonarray(3,:), symbolsetcell)) ;
                
                s3p1(p1no) = s3p1(p1no) + 1 ;
                s3p2(p2no) = s3p2(p2no) + 1 ;
                s3p3(p3no) = s3p3(p3no) + 1 ;
                
                segswith3phons = segswith3phons + 1 ;
                seglengths3(segswith3phons) = annotatedsegs(i).segend - annotatedsegs(i).segstart ;
                if strcmp(annotatedsegs(i).phonarray(1,:), 'h#  ') % start of data
                    hhashstart3 = hhashstart3 + 1 ;
                end
                if strcmp(annotatedsegs(i).phonarray(3,:), 'h#  ') % end of data
                    hhashend3 = hhashend3 + 1 ;
                end
                % how mich of the 1st phoneme is in the segment?
                p1inseg3 = annotatedsegs(i).phonends(1) - annotatedsegs(i).segstart ;
                p1insegno3 = p1insegno3 + 1 ;
                p1insegarray3(p1insegno3) = p1inseg3 ;
                % and how much of the third segment is in the segment?
                p3inseg = annotatedsegs(i).segend - annotatedsegs(i).phonstarts(3) ;
                p3insegno = p3insegno + 1 ;
                p3insegarray3(p3insegno) = p3inseg ;
                % and the length of the 2nd segment
                p2lengthssegarray3(segswith3phons) = annotatedsegs(i).phonends(2) - annotatedsegs(i).phonstarts(2)  ;
                
            end
        end
    end
end
p1insegarray = p1insegarray(1:p1insegno) ;
p2insegarray = p2insegarray(1:p2insegno) ;
seglengths2 = seglengths2(1:segswithtwophons) ;
seglengths3 = seglengths3(1:segswith3phons) ;
p1insegarray3 = p1insegarray3(1:p1insegno3) ;
p3insegarray3 = p3insegarray3(1:p3insegno) ;
p2lengthssegarray3 = p2lengthssegarray3(1:segswith3phons) ;

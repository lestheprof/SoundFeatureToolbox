function formatEsnData(useOnset,useAn,useGabors, rootDir, mloDir,mlaDir,gabDirs, varargin)
% This function will read a list of files and the equivalent onsets, gabors
% and AN signals, and then convert all into a data format suitable for
% input into an ESN.   Will also create a directory of all file names for
% classification translation purposes, and determine the number of outputs.
%  Finally, will save data to chosen filename.  Requires a number of
%  inputs,  useOnset (1 or 0), use An(1 or 0), and useGabors (1 or 0).
%  Also requires root dir, meanOnset (mlo), and AN (mla) dirs. Also
%  requires cell array of gabor dirs (gabDirs).
% Example call
% formatEsnData(1,1,0,'F:/testallen2','onsetMeans2','AMMeanPlain',{'gabor25042014_1','gabor25042014_2','gabor25042014_3'});

% Note, this works only for Allen Corpus
% AKA - May 2014

%rootDir = 'F:/testallen2'; % Root dir to take all files from
%gabDirs = {'gabor25042014_1','gabor25042014_2','gabor25042014_3'};
%mloDir = 'onsetMeans2'; % Onset dir to add in
%mlaDir = 'AMMeanPlain'; % AN dir to add in
%useOnset = 1;
%useAn = 1;
%useGabors = 1;

% Varargin parameters
% 'outdataname' - Specifies a name to give the output file
% 'gender' - Can be either 'm' - male, 'f' - female, or 'mf' - both

outFileName ='inputDataSet.mat'; % default name
genderSplit ='mf'; % default gender split

i=1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'outname';
            outFileName=varargin{i+1};
            i=i+1;
        case 'gender';
            genderSplit=lower(varargin{i+1});
            i=i+1;
        otherwise
            error('formatEsnData: Unknown argument %s given',varargin{i});
    end
    i=i+1;
end


if (useOnset+useAn+useGabors ~= 0)
    % creates list of all au or wav files in directory
    filePattern = fullfile(rootDir, '*.wav');
    filePattern2 = fullfile(rootDir, '*.au');
    
    % Depending on gender allocation, only list certain files
    
    if strcmp(genderSplit,'f')
        tempFiles=[dir(filePattern);dir(filePattern2)];
        % searches for all male files and only adds them to directory
        counter = 1;
        for k = 1:length(tempFiles)
            start = find(tempFiles(k).name==('_'),1, 'first');
            if (strcmp(tempFiles(k).name(start+1),genderSplit))
                Files(counter) = tempFiles(k);
                counter = counter+1;
            end
            
        end
        clear tempFiles counter;
    elseif strcmp(genderSplit,'m')
        tempFiles=[dir(filePattern);dir(filePattern2)];
        % searches for all male files and only adds them to directory
        counter = 1;
        for k = 1:length(tempFiles)
            start = find(tempFiles(k).name==('_'),1, 'first');
            if (strcmp(tempFiles(k).name(start+1),genderSplit))
                Files(counter) = tempFiles(k);
                counter = counter+1;
            end
            
        end
        clear tempFiles counter;
        
    else
        % If no gender split, assume male and female combined
        Files=[dir(filePattern);dir(filePattern2)];
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Create arrays
    %create blank cell array, 3 by however many audio files
    allInputData = cell(length(Files),3);
    
    % create a matrix to put the raw cells in
    % also create a directory of keys
    rawLabels = cell(length(Files),1);
    rawDirect = cell(length(Files),2);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Create phones and directory
    % get file name and add to input as phone label and full name
    for k = 1:length(Files)
        
        % Find suffix dot and last _
        phoneend = find(Files(k).name==('.'),1, 'last');
        phonestart = find(Files(k).name==('_'),1, 'last');
        
        % add to cell array
        %allInputData{k,1} = Files(k).name(phonestart+1:phoneend-1);
        rawLabels{k,1} = Files(k).name(phonestart+1:phoneend-1);
        
        % add the file name (sans suffix to label (column 2)
        allInputData{k,2} = Files(k).name(1:phoneend-1);
        
    end
    
    % ----------------- Directory Creation ------------------------------
    % Go through each file in raw label list, compare it to list of
    % existing phones in directory.  If already exists, assign class.  If
    % it does not exist, add a row to directory and then assign.
    for k = 1:length(Files)
        % Take kth value in raLabel
        tempL = rawLabels{k};
        
        ismem = 0; % Initially not found
        % Compare to directory
        for k2 = 1:length(Files)
            tempC = rawDirect{k2,1};
            ismem = ismember(tempL,tempC);
            if( ismem>0)
                allInputData{k,1} = k2;
                break;
            end
        end
        
        % if not found, add to table
        if (ismem == 0)
            firstempty = find(cellfun('isempty', rawDirect(:,1)),1);
            rawDirect{firstempty,1} = tempL;
            rawDirect{firstempty,2} = firstempty;
            allInputData{k,1} = firstempty;
        end
        clear ismem;
    end
    
    
    % When directories finished, remove blank lines
    firstempty = find(cellfun('isempty', rawDirect),1);
    if(firstempty ~=0)
        directList = rawDirect(1:firstempty-1,:);
    else
        directList = rawDirect;
    end
    
    % ---------- End of Directory Creation ------------------------------
    
    % ----------------- Merging of Data ---------------------------------
    % Depending on input parameters chosen, merges combination of AN, mean
    % onsets and gabors into one combined array, and then saves.
    for k = 1:length(Files)
        
        % variables to create full files
        totInputs=0;
        totInputDim=0;
        
        % initial empty matrix
        mergedall = zeros(totInputs,totInputDim);
        
        % For each gabor dir specified above, read and merge
        if(useGabors)
            gabData = cell(length(gabDirs),1);
            for k2 = 1:length(gabDirs)
                % get dir to load
                gabfil = fullfile(rootDir,gabDirs{k2},[allInputData{k,2},'_gaboroutputs.mat']);
                % load file
                % needs to be in the format of inputs x length, so flip
                gabRead = load(gabfil);
                gabData{k2} = gabRead.gaboroutput{1}';
                
                [inps(k2),dims(k2)] = size(gabData{k2});
                totInputs=totInputs+inps(k2);
                totInputDim=max(totInputDim,dims(k2));
            end
            
            % Merge Gabors
            mergedall = zeros(totInputs,totInputDim);
            for k3 = 1:k2
                mergedall((1+(inps(k3)*(k3-1))):(k3*inps(k3)),1:dims(2)) = gabData{k3};
            end
        end
        
        % Add onset information for each file , take from onset dir
        if(useOnset)
            temp1 = mergedall;
            
            onsetfil = fullfile(rootDir,mloDir,[allInputData{k,2},'_onsetmeans.mat']);
            onsetread = load(onsetfil);
            onsData = onsetread.mlo';
            [inps(k),dims(k)] = size(onsData);
            
            % Get Dims for creating combined matrix
            totInputs=totInputs+inps(k);
            totInputDim=max(totInputDim,dims(k));
            
            % Create combined matrix
            mergedall= zeros(totInputs,totInputDim);
            
            % merge in onsets
            mergedall(1:inps(k),1:dims(k)) = onsData;
            
            % merge in gabor data to create overall
            [tempIns,tempSize] = size(temp1);
            mergedall((inps(k)+1):totInputs,1:tempSize) = temp1;
        end
        
        % Add AN Signal information for each file, take from AN mean dir
        if(useAn)
            temp1 = mergedall;
            
            anfil = fullfile(rootDir,mlaDir,[allInputData{k,2},'_plainmeans.mat']);
            anread = load(anfil);
            anData = anread.mlm';
            [inps(k),dims(k)] = size(anData);
            
            % Get Dims for creating combined matrix
            totInputs=totInputs+inps(k);
            totInputDim=max(totInputDim,dims(k));
            
            % Create combined matrix
            mergedall= zeros(totInputs,totInputDim);
            
            % merge in an
            mergedall(1:inps(k),1:dims(k)) = anData;
            
            % merge in all to create overall
            [tempIns,tempSize] = size(temp1);
            mergedall((inps(k)+1):totInputs,1:tempSize) = temp1;
        end
        
        % Final format for output
        allInputData{k,3} = mergedall;
        
    end
    
    
    %save output file and variables
    totNetInputs = totInputs;
    
    %save((fullfile(rootDir,'inputDataSet.mat')), 'allInputData', 'directList','totNetInputs','-v7.3');
    save((fullfile(rootDir,outFileName)), 'allInputData', 'directList','totNetInputs','-v7.3');
    
else
    % If no inputs have been chosen for use, stop writing process
    disp('No inputs chosen for processing.  Stopping');
end
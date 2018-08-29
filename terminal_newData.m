


%clear all ;
%clc;

% Main path of toolbox for running and saving
% mainPath = 'D:/Research/Matlab/Toolboxes/ESN_Basic_Toolbox/ESN_Basic_Toolbox/';

mainPath = '/Users/lss/matlab_stuff/SoundFeatureToolbox/' ;

% Location where data stored
% dataPath = 'F:/f101m102/';
% for LSS Mac
dataPath = '/Volumes/MacHD2/Researchshare/timit3/allenESNdata/f101m102/';

datasetup = 0; % 1 to run setup, 0 if data already setup
runESN = 1; % 1 to run ESN, 0 to not run

% Set up data
if datasetup
    setup.gabDirs = {'gabor05052014_1','gabor05052014_2','gabor05052014_3'};
    setup.mloDir = 'onsetMeans250'; % Onset dir to add in
    setup.mlaDir = 'AMMeanPlain250'; % AN dir to add in
    setup.useOnset = 1;
    setup.useAn = 1;
    setup.useGabors = 1;
    formatEsnData(setup.useOnset,setup.useAn,setup.useGabors,dataPath,...
        setup.mloDir,setup.mlaDir,setup.gabDirs);
    
end



if runESN
    %%%%%%%%%%%%% Reading files%%%%%%%%%%%%%%%%%
    
    % original before changes
    %temp1=load('dataset/RASTA_PLP_training.mat');
    %groups=cell2mat(temp1.RASTA_PLP_training( :,1));
    
    temp1=load([dataPath,'inputDataSet.mat']);
    groups=cell2mat(temp1.allInputData( :,1));
    
    % Get directory to evaluate output
    % This contains the phone, and the number
    % Matches against column 1 of the input data
    directory = temp1.directList;
    
    % get number of classes from directory defined previously
    no_classes = length(temp1.directList);
    
    no_input_dimensions= temp1.totNetInputs;
    
    [train,test] = crossvalind('holdout',groups,0.30);
    training_Data=temp1.allInputData(train  ,3);
    training_label=temp1.allInputData(train ,1);
    training_label=cell2mat(training_label(:));
    
    %clear temp1;
    %%%%%%%%%%%%%%% test %%%%%%%%%%%%%%
    %temp1=load('TestSet/all_15_female_male_testing_PLP.mat');
    testing_Data=temp1.allInputData(test ,3);
    testing_label=temp1.allInputData(test,1);
    testing_label=cell2mat(testing_label(:));
    
    % temporarily make training and test the same
    % testing_Data=temp1.allInputData(train  ,3);
    % testing_label=temp1.allInputData(train ,1);
    % testing_label=cell2mat(testing_label(:));
    
    clear temp1;
    
    %%%%%%%%%%%%%%%%%% Parameters %%%%%%%%%%%%%%%%%%%%%%
    
    % Adjust these to suit, currently random numbers
    % Optimise over time by trying params
    
    re_size=[600 800 1000 1200 1400];
    % win_scl=[0.001 0.01 0.1 0.5 1 10 100];
    % w_scl=[0.001 0.01 0.1 0.5 1 10 100];
    % leakage_rate=[0.9 0.7 0.5 0.3 0.2 0.1 0.01 0.001];
    
    % If 0 stay the same, if 1, no memory, completely change each time
    leakage_rate=[0.01];
    % scale for the inner matrix for the reservoir, input weights
    win_scl=[0.1];
    % Internal weights
    w_scl=[0.5];
    
    
    
    
    newline=double(sprintf('\n'));
    
    %no_input_dimensions=100;
    % Can specify.  Over large is okay if we don't know the answers
    % Defined above
    %no_classes=20;
    
    % Should be adjusted for large networks to prevent overfitting
    regularization_parameter=0.0001;
    
    
    
    
    numberOfRuns=2;
    result=zeros(numberOfRuns,2);
    
    
    
    for i=1 : length(re_size)
        for c=1 : length(leakage_rate)
            for d_win=1:length(win_scl)
                for c_w=1:length(w_scl)
                    for b=1 : numberOfRuns
                        
                        
                        
                        %%%%%%%%%%%%%% Constructing the Network %%%%%%%%%%%%
                        
                        
                        
                        
                        net = Esn( re_size(i) , leakage_rate(c) , no_input_dimensions , win_scl(d_win) ,  w_scl(c_w))
                        
                        
                        disp(['====================ESN===========================' newline]);
                        
                        disp(['Reservoir Size = ' num2str(re_size(i)) '   Leakage Rate = ' num2str(leakage_rate(c)) newline 'Input dimensions = '  num2str(no_input_dimensions) ...
                            ' Win Scaler =  '  num2str(win_scl(d_win)) ' Wreservoir Scaler = ' num2str(w_scl(c_w))  ]);
                        
                        
                        disp(['=================================================' newline]);
                        
                        
                        %%%%%%%%%%%%%% Passing the training Data to the Network and Collecting the reservoir's responce on reservoirrResponceTraining %%%%%%%%%%%%
                        
                        
                        
                        
                        disp([newline 'Feeding the training data to the network' newline]);
                        istrain=true;
                        [reservoirrResponceTraining]=net.runReservoir(training_Data,istrain,mainPath);
                        % [reservoirrResponceTraining]=net.runReservoir(training_Data,istrain);
                        
                        
                        
                        
                        
                        %%%%%%%%%%%%%% Trianing the readout function using Normal equation %%%%%%%%%%%%
                        
                        disp([ newline 'Trianing the readout function ' newline ]);
                        [theta]= normalEqn(reservoirrResponceTraining,training_label,no_classes,regularization_parameter);
                        
                        
                        
                        %%%%%%%%%%%%%% Passing the Test Data to the Network and Collecting the reservoir's responce on reservoirrResponceTest %%%%%%%%%%%%
                        disp([newline 'Feeding the Test data to the network ' newline]);
                        
                        istrain=false;
                        [reservoirrResponceTest]=net.runReservoir(testing_Data,istrain,mainPath );
                        
                        
                        
                        
                        
                        
                        %%%%%%%%%%%%%%  Evaluating the model on the Training Data %%%%%%%%%%%%
                        disp([ newline '=======================Evaluation on training Data ==============================' newline]);
                        
                        [accuarcyTraining sttr outTraining]=evaluation( reservoirrResponceTraining,training_label,theta);
                        
                        
                        disp([ newline ' Accuracy  on training Data = ' num2str(accuarcyTraining) newline]);
                        
                        
                        
                        %%%%%%%%%%%%%%  Evaluating the model on the Test Data %%%%%%%%%%%%
                        disp([newline ' =======================Evaluation on Test ==============================' newline]);
                        [accuarcyTesting stts out_Testing]=evaluation( reservoirrResponceTest,testing_label,theta);
                        disp([ newline ' Accuracy  on Test Data = ' num2str(accuarcyTesting) newline]);
                        
                        
                        
                        result(b,:)=[accuarcyTraining,accuarcyTesting]
                    end
                    
                    
                    
                    
                    
                    
                    
                    %%%%%%%%%%%%%%%%%%% Saving the Result %%%%%%%%%%%%%%
                    average_train=mean(result(:,1));
                    std_train=std(result(:,1));
                    average_test=mean(result(:,2));
                    std_test=std(result(:,2));
                    
                    % filename=sprintf([mainPath,'Result/%s_%d_.dat'],'RASTA_PLP_training',  numberOfRuns);
                    filename=sprintf([mainPath,'Result/%s_%d_.dat'],'ANOnsetGabor_training',  numberOfRuns);
                    
                    % if target directory does not exist, create it.
                    if ~exist([mainPath 'Result'], 'dir')
                        mkdir([mainPath 'Result']) ;
                    end
                    fid = fopen(filename, 'a');
                    
                    disp([ newline 'Writing the reuslt to:' newline  filename  newline ] );

                    fprintf (fid, '%4.4f %4.4f %4.4f %4.4f %4.4f %4.4f %4.4f %4.4f \n',...
                        average_train,std_train,average_test,std_test...
                        ,re_size(i),leakage_rate(c),win_scl(d_win),w_scl(c_w));
                    
                    
                    
                    
                    
                    
                    fclose(fid);
                    
                    result=zeros(numberOfRuns,2);
                    
                    
                    
                    
                end
            end
        end
    end
    
    
    % Uncomment this to test output
    
    % Additional code to evaluate output
    
    numtest = 1596; % change this to try different test data
    [val,class] = max(out_Testing(numtest,:));
    actVal = directory(testing_label(numtest)) 
    predVal = directory(class)
    
end




%% experiment#1
% -Experiment1 of ubicomp 2014 paper- *cross session validation*
% In this experiment, we combined data from all sessions for each participant,
% and using offline annotations perform k-fold cross-validation such that k is
% the number of sessions a participant was observed within each study, and
% every fold consists of data from a specific session.
% The goal of this experiment is to analyze intersession variability of
% different SMM.
% Output could be found in the results folder: 
%   exp1tableS1S2.mat - which contains 2 cell ({study1},{study2})
%   each cell contains a matrix (3 x (4x6))
%                                               Participant1                 Participant2
%     |  svm-Baseline features    |   accuracy   tpR  fpR  precision  | accuracy   tpR  fpR  precision   ...
%     |  svm-Stockwell features   |   accuracy   tpR  fpR  precision  | accuracy   tpR  fpR  precision   ...
%     |  svm-Combined features    |   accuracy   tpR  fpR  precision  | accuracy   tpR  fpR  precision   ...
%
%% experiment1
clear all;
setRoot;
featureType={'baseline';'stockwell';'combined'};
studyLabel=['1','2'];
col4id=[7,3];
for varN=studyLabel
    disp(['Evaluate study ', varN]);
    varName2Save=strcat('exp1zstudy',varN,'videoPrevious');
    
    studyXDataPath=strcat(rootPath,filesep,'data',filesep,'Study',varN,filesep);
    sessionList0=dir(studyXDataPath);
    sessionListChar=sessionList0(3:end,:);
    sessionListCell={sessionListChar.name};
    sessionListChar=char(sessionListCell);
    exp1table=[];
    for ii=1:6
        pos4select = col4id(str2double(varN));
        selectedSubjectSessionList=sessionListChar( ...
                                strcmp( ...
                                    cellstr( ...
                                        sessionListChar(:,pos4select)...
                                    )...
                                ,num2str(ii))...
                            ,:);
        sessionNum=size(selectedSubjectSessionList,1);
        subjectXresult=zeros(size(featureType,1),4);
        if sessionNum>1
            
            for f=1:size(featureType,1)
                disp(['Evaluate feature set ', featureType(f)]);
                stereotypyParameters;
                behaviorClassificationParameters.featureVectorType=char(featureType(f));
                
                tpR=zeros(1,sessionNum);
                fpR=zeros(1,sessionNum);
                tnR=zeros(1,sessionNum);
                fnR=zeros(1,sessionNum);
                accuracy=zeros(1,sessionNum);
                Precision=zeros(1,sessionNum);
                Recall=zeros(1,sessionNum);
                cm=[];
                for c=1:sessionNum
                    testSessions=selectedSubjectSessionList(c,:);
                    trainSessions=selectedSubjectSessionList(setdiff(1:sessionNum,c),:);
                    
                    %             selectedSession=selectedSubjectSessionList(c,:);
                    
                    %  1. load fvs of all classroom sessions ecxept 1 and conc to fvtrian.
                    fvTotalTrain=[];labelVecTotalTrain=[];fvTotalTrainN=[];
                    for i1=1:size(trainSessions,1)
                        
                        trainSessionPath=strcat(studyXDataPath,trainSessions(i1,:));
                        cd(trainSessionPath);
                        
                        %                         sessionPath=char(trainSessions{i1,3});
                        %                         cd(sessionPath);
                        if exist(strcat(trainSessionPath,filesep,'featureVectorAndLabels.mat'))
                            load featureVectorAndLabels;
                            fvTotalTrain=[fvTotalTrain;featureVectorAndLabels.fv];
                            fvTotalTrainN=[fvTotalTrainN;featureVectorAndLabels.fvNew];
                            labelVecTotalTrain=[labelVecTotalTrain;featureVectorAndLabels.videoLabelvec];
                        end
                    end
                    featureVectorAndLabelsTrain.fv=fvTotalTrain;
                    featureVectorAndLabelsTrain.fvNew=fvTotalTrainN;
                    featureVectorAndLabelsTrain.videoLabelvec=labelVecTotalTrain;
                    
                    % 2. load fv of the left out session to fvTest.
                    fvTotalTest=[];labelVecTotalTest=[];fvTotalTestN=[];
                    for i2=1:size(testSessions,1)
                        testSessionPath=strcat(studyXDataPath,testSessions(i2,:));
                        cd(testSessionPath);
                        if exist(strcat(testSessionPath,filesep,'featureVectorAndLabels.mat'))
                            load featureVectorAndLabels;
                            fvTotalTest=[fvTotalTest;featureVectorAndLabels.fv];
                            fvTotalTestN=[fvTotalTestN;featureVectorAndLabels.fvNew];
                            labelVecTotalTest=[labelVecTotalTest;featureVectorAndLabels.videoLabelvec];
                        else
                            cm=[cm c];
                        end
                    end
                    
                    
                    
                    behaviorClassificationParameters.onlyLearnModel=1;
                    [results,model]=behaviorClassification(behaviorClassificationParameters,featureVectorAndLabelsTrain);
                    clear featureVectorAndLabelsTrain;
                    % 4. test the traind model using fvTrain on fvTest.
                    if strcmp(behaviorClassificationParameters.featureVectorType,'combined')
                        fvTotalTest=fvTotalTestN;
                    elseif strcmp(behaviorClassificationParameters.featureVectorType,'baseline')
                        fvTotalTest=fvTotalTestN(:,451:end);
                    end
                    fvTotalTest=normc(fvTotalTest); % normalizing each dimension
                    maxElement=max(max(fvTotalTest));
                    testData=fvTotalTest./maxElement;
                    testLabel=labelVecTotalTest;
                    %  [predictLabel, a, prob_values] = svmpredict(testLabel, testData, model); % run the SVM model on the test data
                    [predictLabel, a, prob_values] = predict(testLabel,sparse(testData), model);
                    ac =sum(labelVecTotalTest==predictLabel);
                    tp=length(find(predictLabel~=1&labelVecTotalTest~=1));
                    fp=length(find(labelVecTotalTest==1&predictLabel~=labelVecTotalTest));
                    tn=length(find(predictLabel==1&predictLabel==labelVecTotalTest));
                    fn=length(find(predictLabel==1&predictLabel~=labelVecTotalTest));
                    
                    accuracy(c) = ac / length(labelVecTotalTest);
                    tpR(c)=tp/sum(labelVecTotalTest~=1);
                    fpR(c)=fp/sum(labelVecTotalTest==1);
                    tnR(c)=tn/sum(labelVecTotalTest==1);
                    fnR(c)=fn/sum(labelVecTotalTest~=1);
                    % Precision = true_positive / (true_positive + false_positive)
                    Precision(c)=tp/(tp+fp);
                    % Recall = true_positive / (true_positive + false_negative)
                    Recall(c)=tp/(tp+fn);
                end
                accuracy(cm) =[];
                tpR(cm)=[];
                fpR(cm)=[];
                tnR(cm)=[];
                fnR(cm)=[];
                Precision(cm)=[];
                Recall(cm)=[];
                
                results.accuracy=mean(accuracy);
                results.tpR=mean(tpR);
                results.fpR=mean(fpR);
                results.tnR=mean(tnR);
                results.fnR=mean(fnR);
                results.tnR=mean(tnR);
                results.fnR=mean(fnR);
                results.Precision=mean(Precision);
                results.Recall=mean(Recall);
                
                r.(strcat('Subject',num2str(ii)))=results;
                disp(strcat('subject ',num2str(ii)));
                
                subjectXresult(f,1)=results.accuracy;subjectXresult(f,2)=results.tpR;
                subjectXresult(f,3)=results.fpR;subjectXresult(f,4)=results.Precision;
            end
            
        end
        exp1table=[exp1table subjectXresult];
    end
    exp1tableS1S2{str2num(varN)}=exp1table;
end
cd(strcat(rootPath,filesep,'results', filesep, 'SVM'));
save('exp1tableS1S2','exp1tableS1S2');

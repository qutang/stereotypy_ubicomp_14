%% experiment#3
% -Experiment3 of ubicomp 2014 paper- *cross subject validation*
% Description in the paper:
% Trained the classifier with data from all the participants but
% one and tested the performance on the left out participant.
%
% * in this script, for each subject , we train a model based on a fv
% concatenated from all sessions of all other subjects and test on that
% subejct sessions and using video(offline) annotations
%
% Output:
%   exp3tableS1S2- which contains 2 cell ({study1},{study2})
%   each cell contains a matrix (3 x (4x6))
%                                               Participant1                 Participant2
%     |  svm-Baseline features    |   accuracy   tpR  fpR  precision  | accuracy   tpR  fpR  precision   ...
%     |  svm-Stockwell features   |   accuracy   tpR  fpR  precision  | accuracy   tpR  fpR  precision   ...
%     |  svm-Combined features    |   accuracy   tpR  fpR  precision  | accuracy   tpR  fpR  precision   ...
%
%%
clear all;
setRoot;
varN1='videoHybrid';
featureType={'baseline';'stockwell';'combined'};
studyLabel=['1','2'];
col4id=[7,3];
for varN=studyLabel
%     varName2Save=strcat('exp5study',varN,varN1);
    studyXDataPath=strcat(rootPath,filesep,'data',filesep,'Study',varN,filesep);
    sessionList0=ls(studyXDataPath);
    sessionListChar=sessionList0(3:end,:);
    sessionListCell=cellstr(sessionListChar);
    exp3table=[];
    for ii=1:6
        subjectNdxs=find(strcmp(cellstr(sessionListChar(:,col4id(str2double(varN)))),num2str(ii)));
        testSubjectPaths=sessionListChar(subjectNdxs,:);
        otherSubjectsNdxs = setdiff(1:size(sessionListChar,1),subjectNdxs);
        otherSessionsPaths=sessionListChar(otherSubjectsNdxs,:);
        
        % 1. load fvs of all other sessions and conc to fvTrain.
        fvTotalTrain=[];labelVecTotalTrain=[];fvTotalTrainN=[];
        for i1=1:size(otherSessionsPaths,1)
            sessionPath=strcat(studyXDataPath,otherSessionsPaths(i1,:));
            cd(sessionPath);
             if exist(strcat(sessionPath,filesep,'featureVectorAndLabels.mat'))
                load featureVectorAndLabels;
                fvTotalTrain=[fvTotalTrain;featureVectorAndLabels.fv];
                fvTotalTrainN=[fvTotalTrainN;featureVectorAndLabels.fvNew];
                labelVecTotalTrain=[labelVecTotalTrain;featureVectorAndLabels.videoLabelvec];
            end
        end
        featureVectorAndLabelsTrain.fv=fvTotalTrain;
        featureVectorAndLabelsTrain.fvNew=fvTotalTrainN;
        featureVectorAndLabelsTrain.videoLabelvec=labelVecTotalTrain;
        
        
        % 2. load fvs of all that subject sessions and conc to fvTest.
        fvTotalTest=[];labelVecTotalTest=[];fvTotalTestN=[];
        for i2=1:size(testSubjectPaths,1)
            sessionPath=strcat(studyXDataPath,testSubjectPaths(i2,:));
            cd(sessionPath);
            if exist(strcat(sessionPath,filesep,'featureVectorAndLabels.mat'))
                load featureVectorAndLabels;
                fvTotalTest=[fvTotalTest;featureVectorAndLabels.fv];
                fvTotalTestN=[fvTotalTestN;featureVectorAndLabels.fvNew];
                labelVecTotalTest=[labelVecTotalTest;featureVectorAndLabels.videoLabelvec];
            end
        end
        
        
        subjectXresult=zeros(size(featureType,1),4);
        for f=1:size(featureType,1)
            
            % 3. get the model based on fvTrain.
            stereotypyParameters;
            behaviorClassificationParameters.onlyLearnModel=1;
            behaviorClassificationParameters.featureVectorType=char(featureType(f));
            [results,model]=behaviorClassification(behaviorClassificationParameters,featureVectorAndLabelsTrain);
%             clear featureVectorAndLabelsTrain;
            % 4. test the traind model using fvTrain on fvTest.
            if strcmp(behaviorClassificationParameters.featureVectorType,'combined')
                fvTotalTest2=fvTotalTestN;
            elseif strcmp(behaviorClassificationParameters.featureVectorType,'baseline')
                fvTotalTest2=fvTotalTestN(:,451:end);
            elseif strcmp(behaviorClassificationParameters.featureVectorType,'stockwell')
                fvTotalTest2=fvTotalTest;
            end
            
            fvTotalTest2=normc(fvTotalTest2); % normalizing each dimension
            maxElement=max(max(fvTotalTest2));
            testData=fvTotalTest2./maxElement;
            testLabel=labelVecTotalTest;
            [predictLabel, a, prob_values] = predict(testLabel,sparse(testData), model);
            ac =sum(labelVecTotalTest==predictLabel);
            tp=length(find(predictLabel~=1&labelVecTotalTest~=1));
            fp=length(find(labelVecTotalTest==1&predictLabel~=labelVecTotalTest));
            tn=length(find(predictLabel==1&predictLabel==labelVecTotalTest));
            fn=length(find(predictLabel==1&predictLabel~=labelVecTotalTest));
            
            accuracy = ac / length(labelVecTotalTest);
            tpR=tp/sum(labelVecTotalTest~=1);
            fpR=fp/sum(labelVecTotalTest==1);
            tnR=tn/sum(labelVecTotalTest==1);
            fnR=fn/sum(labelVecTotalTest~=1);
            
            disp(strcat('subject ',num2str(ii)));
            
            subjectXresult(f,1)=accuracy;subjectXresult(f,2)=tpR;
            subjectXresult(f,3)=fpR;subjectXresult(f,4)=tp/(tp+fp);
        end
        exp3table=[exp3table subjectXresult];
    end
    exp3tableS1S2{str2num(varN)}=exp3table;
end

cd(strcat(rootPath,filesep,'results',filesep,'SVM'));
save('exp3tableS1S2','exp3tableS1S2');

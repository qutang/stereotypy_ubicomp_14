%% experiment#4
%
% Description in the paper:
% In this experiment, we trained our classifier using data from all Study1
% sessions and tested the resulting algorithm on Study2 sessions for each
% participant. The goal of this experiment was to understand the impact of
% time on our recognition performance.
% Results from this experiment are reported in Table 6 of the paper.
%
%
% Output:
%   exp4table- dimension (3 x (4x6))
%                                               Participant1                 Participant2
%     |  svm-Baseline features    |   accuracy   tpR  fpR  precision  | accuracy   tpR  fpR  precision   ...
%     |  svm-Stockwell features   |   accuracy   tpR  fpR  precision  | accuracy   tpR  fpR  precision   ...
%     |  svm-Combined features    |   accuracy   tpR  fpR  precision  | accuracy   tpR  fpR  precision   ...
%
%%
clear all;
varName2Save=strcat('exp3hstudy12video');
featureType={'baseline';'stockwell';'combined'};
% featureType={'stockwell'};
setRoot;
studyLabel=['1','2'];
col4id=[7,3];

study1DataPath=strcat(rootPath,filesep,'data',filesep,'Study1',filesep);
sessionList0S1=dir(study1DataPath);
sessionListCharS1=sessionList0S1(3:end,:);
sessionListCellS1={sessionListCharS1.name};
sessionListCharS1=char(sessionListCellS1);
study2DataPath=strcat(rootPath,filesep,'data',filesep,'Study2',filesep);
sessionList0S2=dir(study2DataPath);
sessionListCharS2=sessionList0S2(3:end,:);
sessionListCellS2={sessionListCharS2.name};
sessionListCharS2=char(sessionListCellS2);
exp4table=[];
for ii=1:6
    
    subjectNdxS1=find(strcmp(cellstr(sessionListCharS1(:,col4id(1))),num2str(ii)));
    classSessionsS1=sessionListCharS1(subjectNdxS1,:);
    
    subjectNdxS2=find(strcmp(cellstr(sessionListCharS2(:,col4id(2))),num2str(ii)));
    classSessionsS2=sessionListCharS2(subjectNdxS2,:);
    
    %  1. load fvs of all classroom sessions of study1 and conc to fvClass.
    fvTotalTrainClass=[];fvTotalTrainClassN=[];labelVecTotalTrainClass=[];
    %     fvTotalTest=[];labelVecTotalTest=[];
    for i1=1:size(classSessionsS1,1)
        sessionPath=strcat(study1DataPath,classSessionsS1(i1,:));
        cd(sessionPath);
        load featureVectorAndLabels;
        fvTotalTrainClass=[fvTotalTrainClass;featureVectorAndLabels.fv];
        fvTotalTrainClassN=[fvTotalTrainClassN;featureVectorAndLabels.fvNew];
        labelVecTotalTrainClass=[labelVecTotalTrainClass;featureVectorAndLabels.videoLabelvec];
    end
    featureVectorAndLabelsTrainClass.fv=fvTotalTrainClass;
    featureVectorAndLabelsTrainClass.fvNew=fvTotalTrainClassN;
    featureVectorAndLabelsTrainClass.videoLabelvec=labelVecTotalTrainClass;
    %   clear featureVectorAndLabels;
    
    
    
    % 3. load fvs all class sessions of study2 and conc to fvTest.
    fvTotalTest=[];fvTotalTestN=[];labelVecTotalTest=[];
    for i2=1:size(classSessionsS2,1)
        sessionPath=strcat(study2DataPath,classSessionsS2(i2,:));
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
        % 3. get the model based on fvClass an fvLab of study1.
        stereotypyParameters;
        behaviorClassificationParameters.featureVectorType=char(featureType(f));
        behaviorClassificationParameters.onlyLearnModel=1;
        [results,modelClass]=behaviorClassification(behaviorClassificationParameters,featureVectorAndLabelsTrainClass);
        
        % 4. test the traind model using fvClass of study2
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
        %  [predictLabel, a, prob_values] = svmpredict(testLabel, testData, model); % run the SVM model on the test data
        [predictLabelClass, a, prob_values] = predict(testLabel,sparse(testData), modelClass); % run the SVM model on the test data
        
        accClass = sum(testLabel==predictLabelClass)/length(testLabel);
        
        %         ac = ac + sum(testLabel==predictLabelClass);
        tp=length(find(predictLabelClass~=1&testLabel~=1));
        % fpNum=fpNum+length(find(testLabel~=1&predictLabelClass~=testLabel));
        fp=length(find(testLabel==1&predictLabelClass~=testLabel));
        % tnNum=tnNum+length(find(testLabel==1&predictLabelClass==testLabel));
        tn=length(find(predictLabelClass==1&predictLabelClass==testLabel));
        fn=length(find(predictLabelClass==1&predictLabelClass~=testLabel));
        
        tpR=tp/sum(testLabel~=1);
        fpR=fp/sum(testLabel==1);
        tnR=tn/sum(testLabel==1);
        fnR=fn/sum(testLabel~=1);
        % Precision = true_positive / (true_positive + false_positive)
        results.Precision=tp/(tp+fp);
        % Recall = true_positive / (true_positive + false_negative)
        results.Recall=tp/(tp+fn);
        
        results.tpR=tpR;
        results.fpR=fpR;
        results.tnR=tnR;
        results.fnR=fnR;
        
        results.accuracy=accClass;
        
        r.(strcat('Subject',num2str(ii)))=results;
        disp(strcat('subject ',num2str(ii)));
        
        subjectXresult(f,1)=accClass;subjectXresult(f,2)=tpR;
        subjectXresult(f,3)=fpR;subjectXresult(f,4)=tp/(tp+fp);
    end
    exp4table=[exp4table subjectXresult];
end
cd(rootPath);
cd(strcat(rootPath,filesep,'results',filesep,'SVM'));
save('exp4table','exp4table');

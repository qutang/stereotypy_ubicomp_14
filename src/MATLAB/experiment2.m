%% experiment#2
% -Experiment2 of ubicomp 2014 paper-
% In this experiment, all sessions for each participant within
% each study are pooled, and we perform 10-fold crossvalidation
% over each participant's data using offline annotations. Results for SVM_B
% and SVM_C in Study1 and Study2 are reported in Table 4 of the ubicomp 2014
% paper. The goal of this experiment was to evaluate within session
% performance of these classifiers.
%
% Output:
%   exp2tableS1S2- which contains 2 cell ({study1},{study2})
%   each cell contains a matrix (3 x (4x6))
%                                               Participant1                 Participant2
%     |  svm-Baseline features    |   accuracy   tpR  fpR  precision  | accuracy   tpR  fpR  precision   ...
%     |  svm-Stockwell features   |   accuracy   tpR  fpR  precision  | accuracy   tpR  fpR  precision   ...
%     |  svm-Combined features    |   accuracy   tpR  fpR  precision  | accuracy   tpR  fpR  precision   ...
%% experiment2
clear all;
setRoot;
featureType={'baseline';'stockwell';'combined'};
varN1='videoHybrid';
studyLabel=['1','2'];
col4id=[7,3];

for varN=studyLabel
    disp(['Processing study ', varN]);
    varName2Save=strcat('exp1pstudy',varN,varN1);
    expression1=strcat(varName2Save,'=[];','r=',varName2Save,';');
    studyXDataPath=strcat(rootPath,filesep,'data',filesep,'Study',varN,filesep);
    sessionList0=dir(studyXDataPath);
    sessionListChar=sessionList0(3:end,:);
    sessionListCell={sessionListChar.name};
    sessionListChar=char(sessionListCell);
    exp2table=[];
    for ii=1:6
        selectedSubjectSessionList=sessionListChar(strcmp(cellstr(sessionListChar(:,col4id(str2double(varN)))),num2str(ii)),:);
        sessionNum=size(selectedSubjectSessionList,1);
        
        
        
        %  1. load fvs of all classroom sessions of study1 and conc to fvClass.
        fvTotalTrainClass=[];fvTotalTrainClassN=[];labelVecTotalTrainClass=[];
        %     fvTotalTest=[];labelVecTotalTest=[];
        for i1=1:sessionNum
            sessionPath=strcat(studyXDataPath,selectedSubjectSessionList(i1,:));
            cd(sessionPath);
            if exist(strcat(sessionPath,filesep,'featureVectorAndLabels.mat'))
                load featureVectorAndLabels;
                fvTotalTrainClass=[fvTotalTrainClass;featureVectorAndLabels.fv];
                fvTotalTrainClassN=[fvTotalTrainClassN;featureVectorAndLabels.fvNew];
                labelVecTotalTrainClass=[labelVecTotalTrainClass;featureVectorAndLabels.videoLabelvec];
            end
        end
        featureVectorAndLabelsTrainClass.fv=fvTotalTrainClass;
        featureVectorAndLabelsTrainClass.fvNew=fvTotalTrainClassN;
        featureVectorAndLabelsTrainClass.videoLabelvec=labelVecTotalTrainClass;
        %   clear featureVectorAndLabels;
        subjectXresult=zeros(size(featureType,1),4);
        for f=1:size(featureType,1)
            disp(['Evaluating feature type ', featureType{f}])
            %     3. train and test the model using 10 fold cross validation
            stereotypyParameters;
            behaviorClassificationParameters.featureVectorType=char(featureType(f));
            [results.Class,model]=behaviorClassification(behaviorClassificationParameters,featureVectorAndLabelsTrainClass);
            
            r.(strcat('Subject',num2str(ii)))=results;
            disp(strcat('subject ',num2str(ii)));
            
            subjectXresult(f,1)=results.Class.accuracy;subjectXresult(f,2)=results.Class.tpR;
            subjectXresult(f,3)=results.Class.fpR;subjectXresult(f,4)=results.Class.Precision;
        end
        exp2table=[exp2table subjectXresult];
    end
    exp2tableS1S2{str2num(varN)}=exp2table;
end
%     expression2=strcat(varName2Save,'=r;');
%     eval(expression2);
cd(strcat(rootPath,filesep,'results',filesep,'SVM'));
save('exp2tableS1S2','exp2tableS1S2');


%% stereotypyParameters
% sets parameters for enable/disabling each function in stereotypyMain
% scrip. It also sets the parameters needed for each function seperately. 
%% Study Type
% labelingParameters.studyType='1';   %'2';
%% enable/disable each function in main script
labelingEnableFlag=0;           %(def:0)
checkLabelsPresentationEnableFlag=1;            %(def:0)
featureExtractionEnableFlag=0;                  %(def:0)
behaviorClassificationEnableFlag=0;             %(def:1)

%% labelingParameters
labelingParameters.fs=90; %0;
labelingParameters.interpolationType='linear';%'spline'  %(def:linear)
labelingParameters.saveLabels=1; %0;         %(def:0)

%% featureExtractionParameters
featureExtractionParameters.saveFeatures=1; %0   %(def:0)

%% behaviorClassificationParameters
% behaviorClassificationParameters.LibSVMparameters =['-t 0 -v 10 -h 0'];
behaviorClassificationParameters.LibSVMparameters ='-t 0';
behaviorClassificationParameters.Liblinearparameters='-s 1 -q';
behaviorClassificationParameters.featureVectorType='stockwell';%'stockwell' %'combined'; %'baseline'  %(def:stockwell)
behaviorClassificationParameters.onlyLearnModel=0;
behaviorClassificationParameters.trainingSetBalancingEnable=1;
behaviorClassificationParameters.labelTypeForClassification='video';    %'phone';%'video';%'agreement';'disagreement'; %(def:video)







%% stereotypyMain
% stereotypyMain.m is an script which is able to do following tasks if the
% parameter related to that task is enabled('1') in the stereotypyParameters.m
% file.
%
% Note (1) you can run this script for each session of each subject. For
% doing this, you should change the current folder to the data subject/
% session folder and find the Smartphone folder and then merged. Then, you
% can run the script.
%
% Note (2): If you want to use this script in other scripts, e.g. in
% experiment1-5 scripts which we use this scrip in a for loop to operate
% it automatically on all data set, you should comment [clear all;] and
% uncomment clearvars -except xxx (add variables you dont want to be cleared)
%
% Note (3): you can use the automatic selection of data and session if you
% manipulate AllPaths.mat by yourself. In this case you need to uncomment
% automatic selection part and change start of AllPath strings manually.
%
%
% Tasks:
% 1. labeling:
%    sampling is not constant, phone/video annotation files are in in
%    different format and have information about start and end of each
%    behavior, output of this function is preprocessedDataAndLabels.mat
%    which is a math file which includes: labeled data and correspoding
%    time stamps with a constant sampling rate.
%
%
% 3. checkLabelsPresentation:
%    This function gets preprocessedDataAndLabels and plots data and labels
%    on eachother for right wrist, left wrist, torso seperately. each plot
%    contains x,y,x acceleration data and conincided labels.
%
%
% 7. featureExtraction:
%    It uses preprocessedDataAndLabels.mat to produce feature vectores that
%    we can use in classification, clustering an so on. The Output will be
%    featureVectorAndLabels.mat which will be saved in the same folder as
%    data.
%
% 8. behaviorClassification:
%    this function gets featureVectorAndLabels.mat and and apply
%    multi-class LibSVM classier on data and save results.mat and model.mat
%    in the current folder. You need to set
%    behaviorClassificationParameters in the parameter file (stereotypyParameters).
%
%    See also stereotypyParameters, labeling, featureExtraction ,behaviorClassification,...
%
%   $Author: Marzieh Haghighi $    $Date: 2012 $    $Revision: 0.7 $
%   Copyright: Northeastern University 2014
%% stereotypyMain
% clear all;
%% automaic subject/session selection   (should be commented in general)
if ~exist('disableAutoSelection','var')
clear all;
setRoot;

stereotypyParameters;    % load parameter file
subjectID=input('Please select subject ID (1-6):','s');
studyType=str2double(input('Please select study type (1-2):','s'));
labelingParameters.studyType=num2str(studyType);
if studyType==1
    studyXDataPath=strcat(rootPath,'data', filesep, 'Study1', filesep);
    col4id=7;
else
    studyXDataPath=strcat(rootPath,'data', filesep, 'Study2', filesep);
    col4id=3;
end
sessionList0=ls(studyXDataPath);
sessionListChar=sessionList0(3:end,:);
sessionListCell=cellstr(sessionListChar);

selectedSubjectSessionList=sessionListChar(strcmp(cellstr(sessionListChar(:,col4id)),subjectID),:);
for i=1:size(selectedSubjectSessionList,1)
    disp(strcat('[',num2str(i),']: ',selectedSubjectSessionList(i,:)));
end
    selectedSessionNdx=str2double(input('Please select the desired session to process from the printed list:','s'));
selectedSession=selectedSubjectSessionList(selectedSessionNdx,:);
selectedSessionPath=strcat(studyXDataPath,selectedSession);
cd(selectedSessionPath);
end

%% 1. labeling
if labelingEnableFlag
    loadData;
    preprocessedDataAndLabels=labeling(labelingParameters,rawData,rawAnnotation);
elseif featureExtractionEnableFlag || checkLabelsPresentationEnableFlag
    load preprocessedDataAndLabels;
    load Hd;
end

% 3. checkLabelsPresentation
if checkLabelsPresentationEnableFlag
    checkLabelsPresentation(preprocessedDataAndLabels,Hd)
end

%% featureExtraction
if featureExtractionEnableFlag
    preprocessedData=preprocessedDataAndLabels{1};
    preprocessedLabels=preprocessedDataAndLabels{2};
    featureVectorAndLabels=featureExtraction(featureExtractionParameters,preprocessedData,preprocessedLabels,Hd);
elseif behaviorClassificationEnableFlag
    load featureVectorAndLabels;
end

%% behaviorClassification
if behaviorClassificationEnableFlag
    [results,model]=behaviorClassification(behaviorClassificationParameters,featureVectorAndLabels);
end


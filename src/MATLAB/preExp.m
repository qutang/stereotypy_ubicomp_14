%% preExp
% This script generates;
%   - preprocessedDataAndLabels.mat (1x3 cell)
%       contains 3 cell for right, left and torso data and each cell is a
%       matrix (timeSamples x 4) that,
%       first coloumn is time,
%       second coloumn is acceleration data for x-axis
%       third coloumn is acceleration data for y-axis
%       forth coloumn is acceleration data for z-axis
%
%
%   - featureVectorAndLabels.mat (structure)
%       is a structure containing following fields,
%       fv- (number of features x dimention of features(stockwell))
%       fvt- (number of features x (dimention of features(stockwell)+1(time)))
%       fvNew- (number of features x dimention of features(stockwell+ Baseline features))
%       videoLabelvec-(number of features x video labels)
%       phoneLabelvec-(number of features x phone labels)
% 
% and if "labelingParameters.saveLabels" and
% "featureExtractionParameters.saveFeatures" are true, it saves the related
% .mat file correspondingly. These two .mat files will be saved in the same
% folder as data. 
% * after running of this script one time, other experiment scripts will
% just use these two .mat files for each session data. 
% 
% * Do not change the default values of the stereotypyParameters.
%
%% preExp
% Pop up to choose rootPath
clear all;
setRoot;
% initial settings
studyLabel=['1','2'];
col4id=[7,3];
disableAutoSelection=1;
varN1='video';
stereotypyParameters;
labelingEnableFlag=1;          
featureExtractionEnableFlag=1;
checkLabelsPresentationEnableFlag=0; %If wanting to check annotation plot, set to be 1 
behaviorClassificationEnableFlag=0;  
for varN=studyLabel
    varName2Save=strcat('exp1study',varN,varN1);
    studyXDataPath=strcat(rootPath,filesep,'data',filesep,'Study',varN, filesep);
    sessionList0=dir(studyXDataPath);
    sessionListChar=sessionList0(3:end,:);
    sessionListCell = {sessionListChar.name};
    labelingParameters.studyType=varN;
    for ii=1:size(sessionListChar,1)
        sessionPath=strcat(studyXDataPath,sessionListCell{ii});
        disp(['Preparing ', sessionListCell{ii}, ', please wait...']);
        cd(sessionPath);
        stereotypyMain;
        disp(['Done with preparing ', sessionListCell{ii}]);
    end
    cd(rootPath);   
end
clear disableAutoSelection;

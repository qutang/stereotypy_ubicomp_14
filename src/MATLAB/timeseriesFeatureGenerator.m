%% boutFeatureGenerator
% This script generates a struct for each subjects input preprocessedDataAndLabels
% which contains:
%   timeseriesFeatures. rate
%   timeseriesFeatures. frequency
%   timeseriesFeatures. duration
%   timeseriesFeatures. latency
%   timeseriesFeatures. intensity
%   timeseriesFeatures. periodicity  ???

%a vector for each bout consiting of:
% [boutDuration boutIntensity boutNumofMoves]
% you need to enable following flags in the stereotypy script:
% - intensityLabelingEnableFlag
% - boutsDurationAndTemporalDistanceEnableFlag
% - moveCounterEnableFlag
%
% saves results in the timeseriesFeatures.mat cell array.
%%
% function boutFeatures=boutFeatureGenerator(preprocessedDataAndLabels,contextLabels)
function timeseriesFeatures=timeseriesFeatureGenerator(preprocessedDataAndLabels,Hd)

% Load Data & Labels
preprocessedLabels=preprocessedDataAndLabels{2}{1};
preprocessedData=preprocessedDataAndLabels{1};

% data:
rightWristXYZ=preprocessedData{1}(:,2:end);% =rightWristXYZ;
leftWristXYZ=preprocessedData{2}(:,2:end);% =leftWristXYZ;
torsoXYZ=preprocessedData{3}(:,2:end);  % =torsoXYZ;

% Filter data (high-pass IIR,fc= 0.1)
rightWristXYZ=filter(Hd,rightWristXYZ); 
leftWristXYZ=filter(Hd,leftWristXYZ);
torsoXYZ=filter(Hd,torsoXYZ);

% normalizing data to make it comparable for across studies
rightWristXYZ=rightWristXYZ./max(max(rightWristXYZ));
leftWristXYZ=leftWristXYZ./max(max(leftWristXYZ));
torsoXYZ=torsoXYZ./max(max(torsoXYZ));

% labels:
rightLabel=preprocessedLabels{1};% load rightLabel;
leftLabel=preprocessedLabels{2};% load leftLabel;
torsoLabel=preprocessedLabels{3};% load torsoLabel;
% context labels
% rightContextLabels=contextLabels{1};

% times
tr=preprocessedData{1}(:,1);% load tr;
tl=preprocessedData{2}(:,1);% load tl;
tt=preprocessedData{2}(:,1);% load tt;
%%
exsistingLabels=unique(rightLabel(:,1));

if  find(exsistingLabels==400)~=0    %'rock'
    numOfMovesRock=[];
    boutIntensityRock=[];
    targetBehaviourNdx=find(torsoLabel(:,2)~=0);
    targetBehaviourLabel=torsoLabel(targetBehaviourNdx,2);
    %     targetBehaviourContextLabel=rightContextLabels(targetBehaviourNdx,1);
    targetBehaviourData={rightWristXYZ(targetBehaviourNdx,:),leftWristXYZ(targetBehaviourNdx,:),torsoXYZ(targetBehaviourNdx,:)};
    targetBehaviourTimes=tr(targetBehaviourNdx,:);
    boutL=unique(targetBehaviourLabel);
    numOfBouts=length(boutL);
    boutsDuration=zeros(1,numOfBouts);
    boutsTemporalDistance=zeros(1,numOfBouts-1);
    boutStartTime=zeros(1,numOfBouts);
    boutEndTime=zeros(1,numOfBouts);
    
    norm_right = sqrt(sum(rightWristXYZ(targetBehaviourNdx,2:end).^2,2));
    norm_left  = sqrt(sum(leftWristXYZ(targetBehaviourNdx,2:end).^2,2));
    norm_torso = sqrt(sum(torsoXYZ(targetBehaviourNdx,2:end).^2,2));
    for j=1:numOfBouts
        
        %       bout duration calculation
        boutStartTime(j)=targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1));
        boutEndTime(j)=targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1,'last'));
        boutsDuration(j)=targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1,'last'))-targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1));
        if j~=numOfBouts
            boutsTemporalDistance(j)=targetBehaviourTimes(find(targetBehaviourLabel==boutL(j+1),1))-targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1,'last'));
        end
        %       move counting
        BoutNdx=find(targetBehaviourLabel==boutL(j));
        %         BoutRight=targetBehaviourData{1}(BoutNdx,2:end);
        %         BoutLeft= targetBehaviourData{2}(BoutNdx,2:end);
        BoutTorso=targetBehaviourData{3}(BoutNdx,2:end);
        varBoutTorso = var(BoutTorso);
        mostVariantBout=BoutTorso(:,find(max(varBoutTorso)==varBoutTorso,1));
        numOfMovesInBout=zeroCrossingCounter(mostVariantBout);
        numOfMovesRock=[numOfMovesRock numOfMovesInBout/((1e-3)*boutsDuration(j))];
        %         intensity calculation
        boutIntensity=[sum(norm_right(BoutNdx).^2) sum(norm_left(BoutNdx).^2) sum(norm_torso(BoutNdx).^2)];
        boutIntensityRock=[boutIntensityRock mean(boutIntensity)./((1e-3)*boutsDuration(j))];
        %         boutContextLabelsRock{j}=unique(targetBehaviourContextLabel(BoutNdx));
    end
    %     timeseriesFeatures.boutContextLabels.rock=boutContextLabelsRock;
    timeseriesFeatures.rate.rock=[numOfBouts,(tr(end)-tr(1))*(1e-3),(numOfBouts/(tr(end)-tr(1))*(1e-3))];
    timeseriesFeatures.engagementProportion.rock=[sum(boutsDuration)*(1e-3),(tr(end)-tr(1))*(1e-3),(sum(boutsDuration)/(tr(end)-tr(1)))];
    timeseriesFeatures.boutIntensities.rock=boutIntensityRock;
    timeseriesFeatures.boutsDuration.rock=(1e-3)*boutsDuration;
    timeseriesFeatures.boutsTemporalDistance.rock=(1e-3)*boutsTemporalDistance;
    timeseriesFeatures.boutStartTime.rock=boutStartTime;
    timeseriesFeatures.boutEndTime.rock=boutEndTime;
    timeseriesFeatures.numOfMoves.rock=numOfMovesRock;
else
    %     timeseriesFeatures.boutContextLabels.rock='non-existent';
    timeseriesFeatures.rate.rock=[0,(tr(end)-tr(1))*(1e-3),0];
    timeseriesFeatures.engagementProportion.rock=[0,(tr(end)-tr(1))*(1e-3),0];
    timeseriesFeatures.boutIntensities.rock=[];
    timeseriesFeatures.boutsDuration.rock=[];
    timeseriesFeatures.boutsTemporalDistance.rock=[];
    timeseriesFeatures.boutStartTime.rock=[];
    timeseriesFeatures.boutEndTime.rock=[];
    timeseriesFeatures.numOfMoves.rock=[];
end

if  find(exsistingLabels==600)~=0       %'flapRock'
    numOfMovesRockFlap_R=[];
    numOfMovesRockFlap_F=[];
    boutIntensityRockFlap=[];
    targetBehaviourNdx=find(torsoLabel(:,3)~=0);
    targetBehaviourLabel=torsoLabel(targetBehaviourNdx,3);
    %         targetBehaviourContextLabel=rightContextLabels(targetBehaviourNdx,1);
    targetBehaviourData={rightWristXYZ(targetBehaviourNdx,:),leftWristXYZ(targetBehaviourNdx,:),torsoXYZ(targetBehaviourNdx,:)};
    targetBehaviourTimes=tr(targetBehaviourNdx,:);
    boutL=unique(targetBehaviourLabel);
    numOfBouts=length(boutL);
    boutsDuration=zeros(1,numOfBouts);
    boutStartTime=zeros(1,numOfBouts);
    boutEndTime=zeros(1,numOfBouts);
    boutsTemporalDistance=zeros(1,numOfBouts-1);
    
    norm_right = sqrt(sum(rightWristXYZ(targetBehaviourNdx,2:end).^2,2));
    norm_left  = sqrt(sum(leftWristXYZ(targetBehaviourNdx,2:end).^2,2));
    norm_torso = sqrt(sum(torsoXYZ(targetBehaviourNdx,2:end).^2,2));
    
    for j=1:numOfBouts
        %       bout duration calculation
        boutStartTime(j)=targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1));
        boutEndTime(j)=targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1,'last'));
        boutsDuration(j)=targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1,'last'))-targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1));
        if j~=numOfBouts
            boutsTemporalDistance(j)=targetBehaviourTimes(find(targetBehaviourLabel==boutL(j+1),1))-targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1,'last'));
        end
        %       move counting
        BoutNdx=find(targetBehaviourLabel==boutL(j));
        BoutRight=targetBehaviourData{1}(BoutNdx,2:end);
        BoutLeft= targetBehaviourData{2}(BoutNdx,2:end);
        BoutRightLeft=[BoutRight BoutLeft];
        varBoutRightLeft = var(BoutRightLeft);
        mostVariantBout_F=BoutRightLeft(:,find(max(varBoutRightLeft)==varBoutRightLeft,1));
        numOfMovesInBout_F=zeroCrossingCounter(mostVariantBout_F);
        numOfMovesRockFlap_F=[numOfMovesRockFlap_F numOfMovesInBout_F];
        
        BoutTorso=targetBehaviourData{3}(BoutNdx,2:end);
        varBoutTorso = var(BoutTorso);
        mostVariantBout=BoutTorso(:,max(varBoutTorso)==varBoutTorso);
        numOfMovesInBout=zeroCrossingCounter(mostVariantBout);
        numOfMovesRockFlap_R=[numOfMovesRockFlap_R/((1e-3)*boutsDuration(j)) numOfMovesInBout/((1e-3)*boutsDuration(j))];
        %         numOfMovesRock=[numOfMovesRock numOfMovesInBout];
        %         intensity calculation
        boutIntensity=[sum(norm_right(BoutNdx).^2) sum(norm_left(BoutNdx).^2) sum(norm_torso(BoutNdx).^2)];
        boutIntensityRockFlap=[boutIntensityRockFlap mean(boutIntensity)./((1e-3)*boutsDuration(j))];
        %         boutContextLabelsRockFlap{j}=unique(targetBehaviourContextLabel(BoutNdx));
    end
    %     timeseriesFeatures.boutContextLabels.rockFlap=boutContextLabelsRockFlap;
    timeseriesFeatures.rate.rockFlap=[numOfBouts,(tr(end)-tr(1))*(1e-3),(numOfBouts/(tr(end)-tr(1))*(1e-3))];
    timeseriesFeatures.engagementProportion.rockFlap=[sum(boutsDuration)*(1e-3),(tr(end)-tr(1))*(1e-3),(sum(boutsDuration)/(tr(end)-tr(1)))];
    timeseriesFeatures.boutIntensities.rockFlap=boutIntensityRockFlap;
    timeseriesFeatures.boutsDuration.rockFlap=(1e-3)*boutsDuration;
    timeseriesFeatures.boutsTemporalDistance.rockFlap=(1e-3)*boutsTemporalDistance;
    timeseriesFeatures.boutStartTime.rockFlap=boutStartTime;
    timeseriesFeatures.boutEndTime.rockFlap=boutEndTime;
    timeseriesFeatures.numOfMoves.rockFlap=max(numOfMovesRockFlap_F,numOfMovesRockFlap_R);
else
    %         timeseriesFeatures.boutContextLabels.rockFlap=[];
    timeseriesFeatures.rate.rockFlap=[0,(tr(end)-tr(1))*(1e-3),0];
    timeseriesFeatures.engagementProportion.rockFlap=[0,(tr(end)-tr(1))*(1e-3),0];
    timeseriesFeatures.boutIntensities.rockFlap=[];
    timeseriesFeatures.boutsDuration.rockFlap=[];
    timeseriesFeatures.boutsTemporalDistance.rockFlap=[];
    timeseriesFeatures.boutStartTime.rockFlap=[];
    timeseriesFeatures.boutEndTime.rockFlap=[];
    timeseriesFeatures.numOfMoves.rockFlap=[];
end

if  find(exsistingLabels==800)~=0    %'flap'
    numOfMovesFlap=[];
    boutIntensityFlap=[];
    targetBehaviourNdx=find(torsoLabel(:,4)~=0);
    targetBehaviourLabel=torsoLabel(targetBehaviourNdx,4);
    %         targetBehaviourContextLabel=rightContextLabels(targetBehaviourNdx,1);
    targetBehaviourData={rightWristXYZ(targetBehaviourNdx,:),leftWristXYZ(targetBehaviourNdx,:),torsoXYZ(targetBehaviourNdx,:)};
    targetBehaviourTimes=tr(targetBehaviourNdx,:);
    boutL=unique(targetBehaviourLabel);
    numOfBouts=length(boutL);
    boutsDuration=zeros(1,numOfBouts);
    boutStartTime=zeros(1,numOfBouts);
    boutEndTime=zeros(1,numOfBouts);
    boutsTemporalDistance=zeros(1,numOfBouts-1);
    
    norm_right = sqrt(sum(rightWristXYZ(targetBehaviourNdx,2:end).^2,2));
    norm_left  = sqrt(sum(leftWristXYZ(targetBehaviourNdx,2:end).^2,2));
    norm_torso = sqrt(sum(torsoXYZ(targetBehaviourNdx,2:end).^2,2));
    
    for j=1:numOfBouts
        %       bout duration calculation
        boutStartTime(j)=targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1));
        boutEndTime(j)=targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1,'last'));
        boutsDuration(j)=targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1,'last'))-targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1));
        if j~=numOfBouts
            boutsTemporalDistance(j)=targetBehaviourTimes(find(targetBehaviourLabel==boutL(j+1),1))-targetBehaviourTimes(find(targetBehaviourLabel==boutL(j),1,'last'));
        end
        %       move counting
        BoutNdx=find(targetBehaviourLabel==boutL(j));
        BoutRight=targetBehaviourData{1}(BoutNdx,2:end);
        BoutLeft= targetBehaviourData{2}(BoutNdx,2:end);
        %         BoutTorso=[targetBehaviourData{3}(BoutNdx,:);
        BoutRightLeft=[BoutRight BoutLeft];
        varBoutRightLeft = var(BoutRightLeft);
        mostVariantBout=BoutRightLeft(:,find(max(varBoutRightLeft)==varBoutRightLeft,1));
        
        numOfMovesInBout=zeroCrossingCounter(mostVariantBout);
        numOfMovesFlap=[numOfMovesFlap numOfMovesInBout/((1e-3)*boutsDuration(j))];
        %         intensity calculation
        boutIntensity=[sum(norm_right(BoutNdx).^2) sum(norm_left(BoutNdx).^2) sum(norm_torso(BoutNdx).^2)];
        boutIntensityFlap=[boutIntensityFlap mean(boutIntensity)./((1e-3)*boutsDuration(j))];
        
        %         boutContextLabelsFlap{j}=unique(targetBehaviourContextLabel(BoutNdx));
    end
    %     timeseriesFeatures.boutContextLabels.flap=boutContextLabelsFlap;
    timeseriesFeatures.rate.flap=[numOfBouts,(tr(end)-tr(1))*(1e-3),(numOfBouts/(tr(end)-tr(1))*(1e-3))];
    timeseriesFeatures.engagementProportion.flap=[sum(boutsDuration)*(1e-3),(tr(end)-tr(1))*(1e-3),(sum(boutsDuration)/(tr(end)-tr(1)))];
    timeseriesFeatures.boutIntensities.flap=boutIntensityFlap;
    timeseriesFeatures.boutsDuration.flap=(1e-3)*boutsDuration;
    timeseriesFeatures.boutsTemporalDistance.flap=(1e-3)*boutsTemporalDistance;
    timeseriesFeatures.boutStartTime.flap=boutStartTime;
    timeseriesFeatures.boutEndTime.flap=boutEndTime;
    timeseriesFeatures.numOfMoves.flap=numOfMovesFlap;
else
    %     timeseriesFeatures.boutContextLabels.flap=[];
    timeseriesFeatures.rate.flap=[0,(tr(end)-tr(1))*(1e-3),0];
    timeseriesFeatures.engagementProportion.flap=[0,(tr(end)-tr(1))*(1e-3),0];
    timeseriesFeatures.boutIntensities.flap=[];
    timeseriesFeatures.boutsDuration.flap=[];
    timeseriesFeatures.boutsTemporalDistance.flap=[];
    timeseriesFeatures.boutStartTime.flap=[];
    timeseriesFeatures.boutEndTime.flap=[];
    timeseriesFeatures.numOfMoves.flap=[];
end

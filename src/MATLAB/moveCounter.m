%% function numOfMoves=moveCounter(preprocessedData,preprocessedLabels)
%  tries to counts number of rocks, flap, flap-rocks(we count number of
%  flaps and rocks seperately in the flap-rock period)
%  for counting rocks:  choose from x,y,z axis of torso signal the one
%  with most variance inside the bout
%  for flaps: choose from x,y,z axis of right/left wrist signal the one with
%  most variance inside the bout
%
%%
function numOfMoves=moveCounter(preprocessedData,preprocessedLabels)
%% Load Data & Labels
%data:
rightWristXYZ=preprocessedData{1};% =rightWristXYZ;
leftWristXYZ=preprocessedData{2};% =leftWristXYZ;
torsoXYZ=preprocessedData{3};  % =torsoXYZ;

%labels:
rightLabel=preprocessedLabels{1};% load rightLabel;
leftLabel=preprocessedLabels{2};% load leftLabel;
torsoLabel=preprocessedLabels{3};% load torsoLabel;

%% Filter data (high-pass IIR,fc= 0.1)???
% w0=filter(Hd,rightWristXYZ);
% w1=filter(Hd,leftWristXYZ);
% w2=filter(Hd,torsoXYZ);
%%
exsistingLabels=unique(rightLabel(:,1));

if  find(exsistingLabels==400)~=0    %'rock'
    numOfMovesRock=0;
    targetBehaviourNdx=find(torsoLabel(:,2)~=0);
    targetBehaviourLabel=torsoLabel(targetBehaviourNdx,2);
    targetBehaviourData={rightWristXYZ(targetBehaviourNdx,:),leftWristXYZ(targetBehaviourNdx,:),torsoXYZ(targetBehaviourNdx,:)};
    for j=1:length(unique(targetBehaviourLabel))
        BoutNdx=find(targetBehaviourLabel==j);
        %         BoutRight=targetBehaviourData{1}(BoutNdx,2:end);
        %         BoutLeft= targetBehaviourData{2}(BoutNdx,2:end);
        BoutTorso=targetBehaviourData{3}(BoutNdx,2:end);
        varBoutTorso = var(BoutTorso);
        mostVariantBout=BoutTorso(:,find(max(varBoutTorso)==varBoutTorso,1));
        numOfMovesInBout=zeroCrossingCounter(mostVariantBout);
        numOfMovesRock=numOfMovesRock+numOfMovesInBout;
    end
    numOfMoves.rock=numOfMovesRock;
else
    
    numOfMoves.rock='non-existent';
end
if  find(exsistingLabels==600)~=0       %'flapRock'
    targetBehaviourNdx=find(torsoLabel(:,3)~=0);
    targetBehaviourLabel=torsoLabel(targetBehaviourNdx,3);
    targetBehaviourData={rightWristXYZ(targetBehaviourNdx,:),leftWristXYZ(targetBehaviourNdx,:),torsoXYZ(targetBehaviourNdx,:)};
    numOfMovesRockFlap_R=0;
    numOfMovesRockFlap_F=0;
    
    for j=1:length(unique(targetBehaviourLabel))
        BoutNdx=find(targetBehaviourLabel==j);
        BoutRight=targetBehaviourData{1}(BoutNdx,2:end);
        BoutLeft= targetBehaviourData{2}(BoutNdx,2:end);
        BoutRightLeft=[BoutRight BoutLeft];
        varBoutRightLeft = var(BoutRightLeft);
        mostVariantBout_F=BoutRightLeft(:,find(max(varBoutRightLeft)==varBoutRightLeft,1));
        numOfMovesInBout_F=zeroCrossingCounter(mostVariantBout_F);
        numOfMovesRockFlap_F=numOfMovesRockFlap_F+numOfMovesInBout_F;
        
        BoutTorso=targetBehaviourData{3}(BoutNdx,2:end);
        varBoutTorso = var(BoutTorso);
        mostVariantBout=BoutTorso(:,max(varBoutTorso)==varBoutTorso);
        numOfMovesInBout=zeroCrossingCounter(mostVariantBout);
        numOfMovesRockFlap_R=numOfMovesRockFlap_R+numOfMovesInBout;
    end
    numOfMoves.rockFlap=[numOfMovesRockFlap_R numOfMovesRockFlap_F];
else
    numOfMoves.rockFlap='non-existent';
end

if  find(exsistingLabels==800)~=0    %'flap'
    numOfMovesFlap=0;
    targetBehaviourNdx=find(torsoLabel(:,4)~=0);
    targetBehaviourLabel=torsoLabel(targetBehaviourNdx,4);
    targetBehaviourData={rightWristXYZ(targetBehaviourNdx,:),leftWristXYZ(targetBehaviourNdx,:),torsoXYZ(targetBehaviourNdx,:)};
    for j=1:length(unique(targetBehaviourLabel))
        
        BoutNdx=find(targetBehaviourLabel==j);
        BoutRight=targetBehaviourData{1}(BoutNdx,2:end);
        BoutLeft= targetBehaviourData{2}(BoutNdx,2:end);
        %         BoutTorso=[targetBehaviourData{3}(BoutNdx,:);
        BoutRightLeft=[BoutRight BoutLeft];
        varBoutRightLeft = var(BoutRightLeft);
        mostVariantBout=BoutRightLeft(:,find(max(varBoutRightLeft)==varBoutRightLeft,1));
        
        numOfMovesInBout=zeroCrossingCounter(mostVariantBout);
        numOfMovesFlap=numOfMovesFlap+numOfMovesInBout;
    end
    numOfMoves.flap=numOfMovesFlap;
else
    numOfMoves.flap='non-existent';
end

% if exist('numOfMoves')
end





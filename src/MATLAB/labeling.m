%% function preprocessedDataAndLabels=labeling(labelingParameters,rawData,rawAnnotation)
%  this function gets raw data and annotation cells and match a label
%  vector to our data using raw annotation information. phone/video
%  annotation files are in different format and have information about
%  start and end time of each behavior. It also change the sampling rate to
%  a constant number using interpolation.
%
% Inputs:
%       - rawData
%       - rawAnnotation
%       - labelingParameters
%
% Outputs:
%       - preprocessedDataAndLabels. (1 x 2 cell)
%           first cell  ==> (data-1x3 (right-left-torso) cell ==> each cell contains a N x 4 matrix - [col1:timeStamps  col2:x-axisdata  col3:y-axisdata  col4:z-axisdata]) 
%           second cell ==> (labels-1x3(video1-phone-video2) cell)- each
%           cell contains a N x 4 matrix- [Label rock_Label flapRock_Label flap_Label]
% 
%
% See also stereotypyParameters,..
%%
function preprocessedDataAndLabels=labeling(labelingParameters,rawData,rawAnnotation)

Wocket_00_RawCorrectedData_RightWrist=rawData{1};
Wocket_01_RawCorrectedData_LeftWrist=rawData{2};
Wocket_02_RawCorrectedData_Torso=rawData{3};
phoneAnnotation=rawAnnotation{1};
phoneAnnotationIntervals=rawAnnotation{2};
videoAnnotation=rawAnnotation{3};
videoAnnotationIntervals=rawAnnotation{4};

% for study 1: generate fake 'sync' label according to 'good data' in video
% annotations of study 1
videoAnnotationIntervals(2,2)=videoAnnotationIntervals(2,1);
videoAnnotationIntervals(3,1)=videoAnnotationIntervals(3,2);

videoAnnotation(2,1)=videoAnnotation(2,3);
videoAnnotation(3,3)=videoAnnotation(3,1);
if strcmp(labelingParameters.studyType,'1')
videoAnnotationIntervals(2:3,4)=cellstr('sync');

phoneAnnotation=[videoAnnotation(1:3,:);phoneAnnotation(2:end,:)];
phoneAnnotationIntervals=[videoAnnotationIntervals(1:3,:);phoneAnnotationIntervals(2:end,:)];
else
videoAnnotation2=rawAnnotation{5};
videoAnnotationIntervals2=rawAnnotation{6};
videoAnnotationIntervals2(2,2)=videoAnnotationIntervals2(2,1);
videoAnnotationIntervals2(3,1)=videoAnnotationIntervals2(3,2);
videoAnnotation2(2,1)=videoAnnotation2(2,3);
videoAnnotation2(3,3)=videoAnnotation2(3,1); 
end
%% PhoneAnnotation 
%% p1.Constructing a matrix like min/sec/msec for phone Annotation StartTime and StopTime
samplingPeriodMilSec=(1/labelingParameters.fs)*1000;
% ms
B1=phoneAnnotation(2:end,:);
ms_annotation=zeros(size(B1,1),size(B1,2));
for j=[1,3]
    for i=1:size(B1,1)
        b=cell2mat(B1(i,j));
        b1= str2num(b(length(b)-2:length(b)));
        if b1>90
            ms_annotation(i,j)=b1;
        elseif b1<1
            ms_annotation(i,j)=b1*100;
        else
            ms_annotation(i,j)=10*(b1-floor(b1));
        end
    end
end
% min/sec
% StartTime
amsecStartTime= ms_annotation(:,3);

StartTime_a1=phoneAnnotationIntervals(2:end,1);
StartTime_a1=datevec(StartTime_a1);
ahourStartTime = StartTime_a1(:,4);
aminuteStartTime = StartTime_a1(:,5);
asecStartTime = StartTime_a1(:,6);
if norm(ahourStartTime-sort(ahourStartTime,'ascend'))~=0
    ahourStartTime(find(ahourStartTime<ahourStartTime(1)))=ahourStartTime(1)+1;
end
aStart=[ahourStartTime,aminuteStartTime,asecStartTime,amsecStartTime];
% %  Constructing a vector for time in milliseconds
aStart1=amsecStartTime+1000*asecStartTime+60000*aminuteStartTime+3600000*ahourStartTime;
% EndTime
amsecEndTime=ms_annotation(:,1);
EndTime_a1=phoneAnnotationIntervals(2:end,2);
EndTime_a1=datevec(EndTime_a1);
ahourEndTime = EndTime_a1(:,4);
aminuteEndTime = EndTime_a1(:,5);
asecEndTime = EndTime_a1(:,6);
if norm(ahourEndTime-sort(ahourEndTime,'ascend'))~=0
    ahourEndTime(find(ahourEndTime<ahourEndTime(1)))=ahourEndTime(1)+1;
end
aEnd=[ahourEndTime,aminuteEndTime,asecEndTime,amsecEndTime];
% %  Constructing a vector for time in milliseconds
aEnd1=amsecEndTime+1000*asecEndTime+60000*aminuteEndTime+3600000*ahourEndTime;
if strcmp(labelingParameters.studyType,'1')
aStart1(1)=aStart1(1)-500;
aEnd1(2)=aEnd1(2)+500;
end
% merging rows
% aEnd_merged=strcat(num2str(aminuteEndTime),num2str(asecEndTime),num2str(amsecEndTime));
%% p2. Constructing a matrix like min/sec/msec for time stamps of RightWrist, LeftWrist and torso
W0=Wocket_00_RawCorrectedData_RightWrist;
W1=Wocket_01_RawCorrectedData_LeftWrist;
W2=Wocket_02_RawCorrectedData_Torso;
% w0= cell2mat(W0);
% w1= cell2mat(W1);
% w2= cell2mat(W2);
w0=W0;    w1=W1;   w2=W2;
y0=floor(w0./1000);
y1=floor(w1./1000);
y2=floor(w2./1000);
w0t= unixtime(y0(:,1));w1t= unixtime(y1(:,1));w2t= unixtime(y2(:,1));

yr0=((w0./1000)-floor(w0./1000))*1000;ms0=(round(yr0(:,1)));
yr1=((w1./1000)-floor(w1./1000))*1000;ms1=(round(yr1(:,1)));
yr2=((w2./1000)-floor(w2./1000))*1000;ms2=(round(yr2(:,1)));

rightTime=[w0t(:,4:6),ms0];leftTime=[w1t(:,4:6),ms1];torsoTime=[w2t(:,4:6),ms2];

% %  Constructing a vector for time in milliseconds
rightTime1=rightTime(:,4)+1000*rightTime(:,3)+60000*rightTime(:,2)+3600000*rightTime(:,1);
equalTimes0=find(diff(rightTime1)==0);
% rightTime1=rightTime1-rightTime1(1);
leftTime1=leftTime(:,4)+1000*leftTime(:,3)+60000*leftTime(:,2)+3600000*leftTime(:,1);
equalTimes1=find(diff(leftTime1)==0);
% leftTime1=lefTime1-leftTime1(1);
torsoTime1=torsoTime(:,4)+1000*torsoTime(:,3)+60000*torsoTime(:,2)+3600000*torsoTime(:,1);
equalTimes2=find(diff(torsoTime1)==0);
% torsoTime1=torsoTime1-torsoTime1(1);

% delete data points with equal times
rightTime1(equalTimes0)=[];leftTime1(equalTimes1)=[];torsoTime1(equalTimes2)=[];
W0(equalTimes0,:)=[];W1(equalTimes1,:)=[];W2(equalTimes2,:)=[];
%% p3. Linear/CubicSpline interpplation for finding corrected time stamps

% % not sure why I did the below part, but keep it for now! maybe you'll find
% % out the reason later!
% %  tr = 0:11:rightTime1(end);tl= 0:11:leftTime1(end);tt = 0:11:torsoTime1(end);
% trStart11mul=rightTime1(1)+(11-mod(rightTime1(1),11));
% tlStart11mul=leftTime1(1)+(11-mod(leftTime1(1),11));
% ttStart11mul=torsoTime1(1)+(11-mod(torsoTime1(1),11));
% maxStart11mul=max([trStart11mul,tlStart11mul,ttStart11mul]);
% endCommonTime=min([rightTime1(end),leftTime1(end),torsoTime1(end)]);
%
% tr = maxStart11mul:11:endCommonTime;tl= maxStart11mul:11:endCommonTime;tt = maxStart11mul:11:endCommonTime;
% % tr = trStart11mul:11:rightTime1(end);tl= tlStart11mul:11:leftTime1(end);tt = ttStart11mul:11:torsoTime1(end);
% % tr = rightTime1(1):11:rightTime1(end);tl= leftTime1(1):11:leftTime1(end);tt = torsoTime1(1):11:torsoTime1(end);

if strcmp(labelingParameters.studyType,'1')
    samplingPeriodMilSec1=(1/60)*1000;
else
    samplingPeriodMilSec1=samplingPeriodMilSec;
end
% instead of above part just crop the data and set a common target time
% stamp vector for right,left and torso
startCommonTime=max([rightTime1(1),leftTime1(1),torsoTime1(1)]);
endCommonTime=min([rightTime1(end),leftTime1(end),torsoTime1(end)]);
tr = startCommonTime:samplingPeriodMilSec1:endCommonTime;
tl=tr;
tt=tr;
% right
rightX = interp1(rightTime1,W0(:,2),tr,labelingParameters.interpolationType);
rightY = interp1(rightTime1,W0(:,3),tr,labelingParameters.interpolationType);
rightZ = interp1(rightTime1,W0(:,4),tr,labelingParameters.interpolationType);
rightxyz=[rightX;rightY;rightZ];
% figure,plot(rightTime1,W0(:,2),'o',tr,rightX);
% left
leftX = interp1(leftTime1,W1(:,2),tl,labelingParameters.interpolationType);
leftY = interp1(leftTime1,W1(:,3),tl,labelingParameters.interpolationType);
leftZ = interp1(leftTime1,W1(:,4),tl,labelingParameters.interpolationType);
leftxyz=[leftX;leftY;leftZ];
% torso
torsoX = interp1(torsoTime1,W2(:,2),tt,labelingParameters.interpolationType);
torsoY = interp1(torsoTime1,W2(:,3),tt,labelingParameters.interpolationType);
torsoZ = interp1(torsoTime1,W2(:,4),tt,labelingParameters.interpolationType);
torsoxyz=[torsoX;torsoY;torsoZ];

if strcmp(labelingParameters.studyType,'1')
    
%     fs1 = 10;             % Original sampling frequency in Hz
% t1 = 0:1/fs1:1;       % Time vector
% x = t1;               % Define a linear sequence
% y = resample(x,9,6);  % Now resample it
% t2 = (0:(length(y)-1))*2/(3*fs1);  % New time vector
fsOriginal=60;
% right
rightX=resample(rightX,9,6);
rightY=resample(rightY,9,6);
rightZ=resample(rightZ,9,6);
rightxyz=[rightX;rightY;rightZ];
% left
leftX=resample(leftX,9,6);
leftY=resample(leftY,9,6);
leftZ=resample(leftZ,9,6);
leftxyz=[leftX;leftY;leftZ];
% torso
torsoX=resample(torsoX,9,6);
torsoY=resample(torsoY,9,6);
torsoZ=resample(torsoZ,9,6);
torsoxyz=[torsoX;torsoY;torsoZ];

tr=startCommonTime+((0:(length(rightX)-1))*6*1000/(9*fsOriginal));
% tr222=resample(tr,9,6);
tl=tr;
tt=tr;
end
%% p4. set 400 for 'rock', 600 for 'flap-rock', 800 for 'flap', 50 for 'sync' PHONE ANNOTATION
if strcmp(labelingParameters.studyType,'1')
    rockLabel='Rock';
    flapLabel='Flap';
    flapRockLabel='Flap-Rock';
else
    rockLabel='rock';
    flapLabel='flap';
    flapRockLabel='flap-rock';
end
phoneLabel=zeros(size(tr,2),1);
rock_phoneLabel=zeros(size(tr,2),1);rock_phoneLabelNdx=1;
flapRock_phoneLabel=zeros(size(tr,2),1);flapRock_phoneLabelNdx=1;
flap_phoneLabel=zeros(size(tr,2),1);flap_phoneLabelNdx=1;


shiftLenght=0;%45;

for i=1:size(aStart,1)
    diffTimeS=tr-aStart1(i);
    S=find(abs(diffTimeS)<=5.55);
    diffTimeE=tr-aEnd1(i);
    E=find(abs(diffTimeE)<=5.55);
    if strcmp(phoneAnnotationIntervals(i+1,3),'sync')==1
        phoneLabel((S-shiftLenght):(E-shiftLenght),1)=50;
    elseif strcmp(phoneAnnotationIntervals(i+1,3),rockLabel)==1
        phoneLabel((S-shiftLenght):(E-shiftLenght),1)=400;
        rock_phoneLabel((S-shiftLenght):(E-shiftLenght),1)=rock_phoneLabelNdx;
        rock_phoneLabelNdx=rock_phoneLabelNdx+1;
    elseif strcmp(phoneAnnotationIntervals(i+1,3),flapRockLabel)==1
        phoneLabel((S-shiftLenght):(E-shiftLenght),1)=600;
        flapRock_phoneLabel((S-shiftLenght):(E-shiftLenght),1)=flapRock_phoneLabelNdx;
        flapRock_phoneLabelNdx=flapRock_phoneLabelNdx+1;
    elseif strcmp(phoneAnnotationIntervals(i+1,3),flapLabel)==1
        phoneLabel((S-shiftLenght):(E-shiftLenght),1)=800;
        flap_phoneLabel((S-shiftLenght):(E-shiftLenght),1)=flap_phoneLabelNdx;
        flap_phoneLabelNdx=flap_phoneLabelNdx+1;
    end
end
phoneLabelAll=[phoneLabel rock_phoneLabel flapRock_phoneLabel flap_phoneLabel];

% rightLabel=rightLabel(1:length(rightX));
% leftLabel=leftLabel(1:length(leftX));
% torsoLabel=torsoLabel(1:length(torsoX));
%% videoAnnotation 1
%% v1.Constructing a matrix like min/sec/msec for phone Annotation StartTime and StopTime
AnnotationIntervals=videoAnnotationIntervals;
% samplingPeriodMilSec=(1/labelingParameters.fs)*1000;
% ms
B1=videoAnnotation(2:end,:);
ms_annotation=zeros(size(B1,1),size(B1,2));
for j=[1,3]
    for i=1:size(B1,1)
        b=cell2mat(B1(i,j));
        b1= str2num(b(length(b)-2:length(b)));
        if b1>90
            ms_annotation(i,j)=b1;
        elseif b1<1
            ms_annotation(i,j)=b1*100;
        else
            ms_annotation(i,j)=10*(b1-floor(b1));
        end
    end
end
% min/sec
% StartTime
amsecStartTime= ms_annotation(:,3);

StartTime_a1=AnnotationIntervals(2:end,1);
StartTime_a1=datevec(StartTime_a1);
ahourStartTime = StartTime_a1(:,4);
aminuteStartTime = StartTime_a1(:,5);
asecStartTime = StartTime_a1(:,6);
if norm(ahourStartTime-sort(ahourStartTime,'ascend'))~=0
    ahourStartTime(find(ahourStartTime<ahourStartTime(1)))=ahourStartTime(1)+1;
end
aStart=[ahourStartTime,aminuteStartTime,asecStartTime,amsecStartTime];
% %  Constructing a vector for time in milliseconds
aStart1=amsecStartTime+1000*asecStartTime+60000*aminuteStartTime+3600000*ahourStartTime;
% EndTime
amsecEndTime=ms_annotation(:,1);
EndTime_a1=AnnotationIntervals(2:end,2);
EndTime_a1=datevec(EndTime_a1);
ahourEndTime = EndTime_a1(:,4);
aminuteEndTime = EndTime_a1(:,5);
asecEndTime = EndTime_a1(:,6);
if norm(ahourEndTime-sort(ahourEndTime,'ascend'))~=0
    ahourEndTime(find(ahourEndTime<ahourEndTime(1)))=ahourEndTime(1)+1;
end
aEnd=[ahourEndTime,aminuteEndTime,asecEndTime,amsecEndTime];
% %  Constructing a vector for time in milliseconds
aEnd1=amsecEndTime+1000*asecEndTime+60000*aminuteEndTime+3600000*ahourEndTime;
% if strcmp(labelingParameters.studyType,'1')
aStart1(1)=aStart1(1)-500;
aEnd1(2)=aEnd1(2)+500;
% end
% merging rows
% aEnd_merged=strcat(num2str(aminuteEndTime),num2str(asecEndTime),num2str(amsecEndTime));
%% v2. Constructing a matrix like min/sec/msec for time stamps of RightWrist, LeftWrist and torso

%% v3. Linear/CubicSpline interpplation for finding corrected time stamps

%% v4. set 400 for 'rock', 600 for 'flap-rock', 800 for 'flap', 50 for 'sync' VIDEO ANNOTATION
videoLabel=zeros(size(tr,2),1);
rock_videoLabel=zeros(size(tr,2),1);rock_videoLabelNdx=1;
flapRock_videoLabel=zeros(size(tr,2),1);flapRock_videoLabelNdx=1;
flap_videoLabel=zeros(size(tr,2),1);flap_videoLabelNdx=1;


shiftLenght=0;%45;

for i=1:size(aStart,1)
    diffTimeS=tr-aStart1(i);
    S=find(abs(diffTimeS)<=5.55);
    diffTimeE=tr-aEnd1(i);
    E=find(abs(diffTimeE)<=5.55);
    if strcmp(AnnotationIntervals(i+1,4),'sync')==1
        videoLabel((S-shiftLenght):(E-shiftLenght),1)=50;
    elseif strcmp(AnnotationIntervals(i+1,4),rockLabel)==1
        videoLabel((S-shiftLenght):(E-shiftLenght),1)=400;
        rock_videoLabel((S-shiftLenght):(E-shiftLenght),1)=rock_videoLabelNdx;
        rock_videoLabelNdx=rock_videoLabelNdx+1;
    elseif strcmp(AnnotationIntervals(i+1,4),flapRockLabel)==1
        videoLabel((S-shiftLenght):(E-shiftLenght),1)=600;
        flapRock_videoLabel((S-shiftLenght):(E-shiftLenght),1)=flapRock_videoLabelNdx;
        flapRock_videoLabelNdx=flapRock_videoLabelNdx+1;
    elseif strcmp(AnnotationIntervals(i+1,4),flapLabel)==1
        videoLabel((S-shiftLenght):(E-shiftLenght),1)=800;
        flap_videoLabel((S-shiftLenght):(E-shiftLenght),1)=flap_videoLabelNdx;
        flap_videoLabelNdx=flap_videoLabelNdx+1;
    end
end
% rightLabelVideo2=[rightLabelV rock_rightLabel flapRock_rightLabel flap_rightLabel];
videoLabel1All=[videoLabel rock_videoLabel flapRock_videoLabel flap_videoLabel];
%% videoAnnotation 2
if strcmp(labelingParameters.studyType,'2')
%% v1.Constructing a matrix like min/sec/msec for phone Annotation StartTime and StopTime
AnnotationIntervals=videoAnnotationIntervals2;
% samplingPeriodMilSec=(1/labelingParameters.fs)*1000;
% ms
B1=videoAnnotation2(2:end,:);
ms_annotation=zeros(size(B1,1),size(B1,2));
for j=[1,3]
    for i=1:size(B1,1)
        b=cell2mat(B1(i,j));
        b1= str2num(b(length(b)-2:length(b)));
        if b1>90
            ms_annotation(i,j)=b1;
        elseif b1<1
            ms_annotation(i,j)=b1*100;
        else
            ms_annotation(i,j)=10*(b1-floor(b1));
        end
    end
end
% min/sec
% StartTime
amsecStartTime= ms_annotation(:,3);

StartTime_a1=AnnotationIntervals(2:end,1);
StartTime_a1=datevec(StartTime_a1);
ahourStartTime = StartTime_a1(:,4);
aminuteStartTime = StartTime_a1(:,5);
asecStartTime = StartTime_a1(:,6);
if norm(ahourStartTime-sort(ahourStartTime,'ascend'))~=0
    ahourStartTime(find(ahourStartTime<ahourStartTime(1)))=ahourStartTime(1)+1;
end
aStart=[ahourStartTime,aminuteStartTime,asecStartTime,amsecStartTime];
% %  Constructing a vector for time in milliseconds
aStart1V2=amsecStartTime+1000*asecStartTime+60000*aminuteStartTime+3600000*ahourStartTime;
% EndTime
amsecEndTime=ms_annotation(:,1);
EndTime_a1=AnnotationIntervals(2:end,2);
EndTime_a1=datevec(EndTime_a1);
ahourEndTime = EndTime_a1(:,4);
aminuteEndTime = EndTime_a1(:,5);
asecEndTime = EndTime_a1(:,6);
if norm(ahourEndTime-sort(ahourEndTime,'ascend'))~=0
    ahourEndTime(find(ahourEndTime<ahourEndTime(1)))=ahourEndTime(1)+1;
end
aEnd=[ahourEndTime,aminuteEndTime,asecEndTime,amsecEndTime];
% %  Constructing a vector for time in milliseconds
aEnd1V2=amsecEndTime+1000*asecEndTime+60000*aminuteEndTime+3600000*ahourEndTime;
% if strcmp(labelingParameters.studyType,'1')
aStart1V2(1)=aStart1V2(1)-500;
aEnd1V2(2)=aEnd1V2(2)+500;
% end
% merging rows
% aEnd_merged=strcat(num2str(aminuteEndTime),num2str(asecEndTime),num2str(amsecEndTime));
%% v2. Constructing a matrix like min/sec/msec for time stamps of RightWrist, LeftWrist and torso

%% v3. Linear/CubicSpline interpplation for finding corrected time stamps

%% v4. set 400 for 'rock', 600 for 'flap-rock', 800 for 'flap', 50 for 'sync' VIDEO ANNOTATION

video2Label=zeros(size(tr,2),1);
rock_video2Label=zeros(size(tr,2),1);rock_video2LabelNdx=1;
flapRock_video2Label=zeros(size(tr,2),1);flapRock_video2LabelNdx=1;
flap_video2Label=zeros(size(tr,2),1);flap_video2LabelNdx=1;


shiftLenght=0;%45;

for i=1:size(aStart,1)
    diffTimeS=tr-aStart1V2(i);
    S=find(abs(diffTimeS)<=5.55);
    diffTimeE=tr-aEnd1V2(i);
    E=find(abs(diffTimeE)<=5.55);
    if strcmp(AnnotationIntervals(i+1,4),'sync')==1
        video2Label((S-shiftLenght):(E-shiftLenght),1)=50;
    elseif strcmp(AnnotationIntervals(i+1,4),rockLabel)==1
        video2Label((S-shiftLenght):(E-shiftLenght),1)=400;
        rock_video2Label((S-shiftLenght):(E-shiftLenght),1)=rock_video2LabelNdx;
        rock_video2LabelNdx=rock_video2LabelNdx+1;
    elseif strcmp(AnnotationIntervals(i+1,4),flapRockLabel)==1
        video2Label((S-shiftLenght):(E-shiftLenght),1)=600;
        flapRock_video2Label((S-shiftLenght):(E-shiftLenght),1)=flapRock_video2LabelNdx;
        flapRock_video2LabelNdx=flapRock_video2LabelNdx+1;
    elseif strcmp(AnnotationIntervals(i+1,4),flapLabel)==1
        video2Label((S-shiftLenght):(E-shiftLenght),1)=800;
        flap_video2Label((S-shiftLenght):(E-shiftLenght),1)=flap_video2LabelNdx;
        flap_video2LabelNdx=flap_video2LabelNdx+1;
    end
end
% rightLabelVideo2=[rightLabelV rock_rightLabel flapRock_rightLabel flap_rightLabel];
videoLabel2All=[video2Label rock_video2Label flapRock_video2Label flap_video2Label];
else
videoLabel2All=videoLabel1All;
end

%% p&v5. rejecting missing parts based on a threshold
thr=10e02;% threshold for rejecting a missing part 1sec
missingPartsBeginingIndexR=find(diff(rightTime1)>thr);
missingPartsBeginingIndexL=find(diff(leftTime1)>thr);
missingPartsBeginingIndexT=find(diff(torsoTime1)>thr);
missingPartsLabelR=zeros(1,length(tr));
missingPartsLabelL=zeros(1,length(tl));
missingPartsLabelT=zeros(1,length(tt));
% missingPartsTimesStartR=rightTime1(missingPartsBeginingIndexR);
% missingPartsTimesEndR=rightTime1(missingPartsBeginingIndexR+1);

for i=length(missingPartsBeginingIndexR):-1:1
    missStartNdx=find(abs(tr-rightTime1(missingPartsBeginingIndexR(i)))<=5.55);
    missEndNdx=find(abs(tr-rightTime1(missingPartsBeginingIndexR(i)+1))<=5.55);
    missingPartsLabelR(missStartNdx:missEndNdx)=1;
end
for i=length(missingPartsBeginingIndexL):-1:1
    missStartNdx=find(abs(tl-leftTime1(missingPartsBeginingIndexL(i)))<=5.55);
    missEndNdx=find(abs(tl-leftTime1(missingPartsBeginingIndexL(i)+1))<=5.55);
    missingPartsLabelL(missStartNdx:missEndNdx)=1;
end
for i=length(missingPartsBeginingIndexT):-1:1
    missStartNdx=find(abs(tt-torsoTime1(missingPartsBeginingIndexT(i)))<=5.55);
    missEndNdx=find(abs(tt-torsoTime1(missingPartsBeginingIndexT(i)+1))<=5.55);
    missingPartsLabelT(missStartNdx:missEndNdx)=1;
end

% find the unioun of all missing parts
missingPartsLabel=or(or(missingPartsLabelR,missingPartsLabelL),missingPartsLabelT);
% missingPartsStartNdx=find(diff(missingPartsLabel)==1);
% missingPartsEndNdx=find(diff(missingPartsLabel)==-1);

tr(missingPartsLabel)=[];
phoneLabelAll(missingPartsLabel,:)=[];
videoLabel1All(missingPartsLabel,:)=[];
videoLabel2All(missingPartsLabel,:)=[];
rightxyz(:,missingPartsLabel)=[];
leftxyz(:,missingPartsLabel)=[];
torsoxyz(:,missingPartsLabel)=[];

trOrg=tr;tlOrg=tl;ttOrg=tt;
% check to see if this part is necessary or not
tr = tr(1):samplingPeriodMilSec:(tr(1)+samplingPeriodMilSec*(length(tr)-1));
tl=tr;tt=tr;
% tl = tl(1):samplingPeriodMilSec:(tl(1)+samplingPeriodMilSec*(length(tl)-1));
% tt = tt(1):samplingPeriodMilSec:(tt(1)+samplingPeriodMilSec*(length(tt)-1));


%% p6.
mintS=min([tr(1),tl(1),tt(1)]);
tr=tr-mintS+1;
tl=tl-mintS+1;
tt=tt-mintS+1;
% maxtS=max([tr(1),tl(1),tt(1)]);
% mintE=min([tr(end),tl(end),tt(end)]);

% rightWristXYZ=[tr',rightX',rightY',rightZ'];
rightWristXYZ=[tr',rightxyz'];
% rightWristXYZ=rightWristXYZ(find(tr==maxtS,1):find(tr==mintE,1),:);
% % rightLabel=rightLabel(find(tr==maxtS,1):find(tr==mintE,1));
% phoneLabelAll=phoneLabelAll((find(tr==maxtS,1):find(tr==mintE,1)),:);
% videoLabel1All=videoLabel1All((find(tr==maxtS,1):find(tr==mintE,1)),:);

leftWristXYZ=[tl',leftxyz'];
% leftWristXYZ=leftWristXYZ(find(tl==maxtS,1):find(tl==mintE,1),:);
% % leftLabel=leftLabel(find(tl==maxtS,1):find(tl==mintE,1));
% leftLabel2=leftLabel2((find(tl==maxtS,1):find(tl==mintE,1)),:);
% leftLabelVideo2=leftLabelVideo2((find(tl==maxtS,1):find(tl==mintE,1)),:);

torsoXYZ=[tt',torsoxyz'];
% torsoXYZ=torsoXYZ(find(tt==maxtS,1):find(tt==mintE,1),:);
% % torsoLabel=torsoLabel(find(tt==maxtS,1):find(tt==mintE,1));
% torsoLabel2=torsoLabel2((find(tt==maxtS,1):find(tt==mintE,1)),:);
% torsoLabelVideo2=torsoLabelVideo2((find(tt==maxtS,1):find(tt==mintE,1)),:);

% phoneLabels={phoneLabelAll,leftLabel2,torsoLabel2};
% videoLabels={videoLabel1All,leftLabelVideo2,torsoLabelVideo2};


% preprocessedData={rightWristXYZ,leftWristXYZ,torsoXYZ};

% %% agreement
%         agreedLabels=videoLabel1All;
%         agreedLabels(setdiff(1:size(agreedLabels,1),find(videoLabel1All(:,1)==phoneLabelAll(:,1))),1)=0;
%         agreedLabels(setdiff(1:size(agreedLabels,1),find(videoLabel1All(:,2)==phoneLabelAll(:,2))),2)=0;
%         agreedLabels(setdiff(1:size(agreedLabels,1),find(videoLabel1All(:,3)==phoneLabelAll(:,3))),3)=0;
%         agreedLabels(setdiff(1:size(agreedLabels,1),find(videoLabel1All(:,4)==phoneLabelAll(:,4))),4)=0; 
% % disagreement
%         disagreedLabels=videoLabel1All;
%         disagreedLabels(find(videoLabel1All(:,1)==phoneLabelAll(:,1)),1)=0;
%         disagreedLabels(find(videoLabel1All(:,2)==phoneLabelAll(:,2)),2)=0;
%         disagreedLabels(find(videoLabel1All(:,3)==phoneLabelAll(:,3)),3)=0;
%         disagreedLabels(find(videoLabel1All(:,4)==phoneLabelAll(:,4)),4)=0; 
%         
%% Filter data (high-pass IIR,fc= 0.1)
w0=rightWristXYZ; % w0=filter(Hd,rightWristXYZ); is done in featureExtraction func!
w1=leftWristXYZ;  % w1=filter(Hd,leftWristXYZ);
w2=torsoXYZ;      % w2=filter(Hd,torsoXYZ);
%% keep btw two sync only
% halfsize=floor(size(videoLabel1All,1)/2);sR=find(videoLabel1All(1:halfsize,1)==50,1,'last');eR=find(videoLabel1All(halfsize:end,1)==50,1,'first')+halfsize-1;

if strcmp(labelingParameters.studyType,'1')
syncLabelsNdx=find(videoLabel1All(:,1)==50);
sR=syncLabelsNdx(find(abs(trOrg(syncLabelsNdx)-aEnd1(1))<1500,1,'last'));
eR=syncLabelsNdx(find(abs(trOrg(syncLabelsNdx)-aStart1(2))<2500,1,'first'));
elseif strcmp(labelingParameters.studyType,'2')
syncLabelsNdx=union(find(videoLabel1All(:,1)==50),find(videoLabel2All(:,1)==50));
sR=syncLabelsNdx(find(abs(trOrg(syncLabelsNdx)-max(aEnd1V2(1),aEnd1(1)))<1500,1,'last'));
eR=syncLabelsNdx(find(abs(trOrg(syncLabelsNdx)-min(aStart1V2(2),aStart1(2)))<1500,1,'first'));       
end

if isempty(sR)&& ~isempty(eR)
    fprintf('missing begining sync');
    videoLabel1All=videoLabel1All(1:eR-1,:);w0=w0(1:eR-1,:);tr=tr(1:eR-1);
    phoneLabelAll=phoneLabelAll(1:eR-1,:);w1=w1(1:eR-1,:);tl=tl(1:eR-1);
    videoLabel2All=videoLabel2All(1:eR-1,:);w2=w2(1:eR-1,:);tt=tt(1:eR-1);
%     rightLabelPhone1=rightLabelPhone(1:eR-1);
elseif isempty(eR) && ~isempty(sR)
    % % % % examples are 001-2010-04-30 & 001-2010-06-03 sessions %%
    % 002-2010-04-27&002-2011-03-22
    fprintf('missing finishing sync; we end with minimum length');
    % min1=min([size(w0,1),size(w1,1),size(w2,1)]);
    videoLabel1All=videoLabel1All(sR+1:end,:);w0=w0(sR+1:end,:);tr=tr(sR+1:end);
    phoneLabelAll=phoneLabelAll(sR+1:end,:);w1=w1(sR+1:end,:);tl=tl(sR+1:end);
    videoLabel2All=videoLabel2All(sR+1:end,:);w2=w2(sR+1:end,:);tt=tt(sR+1:end);
elseif ~isempty(eR) && ~isempty(sR)
    videoLabel1All=videoLabel1All(sR+1:eR-1,:);w0=w0(sR+1:eR-1,:);tr=tr(sR+1:eR-1);
    phoneLabelAll=phoneLabelAll(sR+1:eR-1,:);w1=w1(sR+1:eR-1,:);tl=tl(sR+1:eR-1);
    videoLabel2All=videoLabel2All(sR+1:eR-1,:);w2=w2(sR+1:eR-1,:);tt=tt(sR+1:eR-1);
end

phoneLabels={phoneLabelAll,phoneLabelAll,phoneLabelAll};
videoLabels={videoLabel1All,videoLabel1All,videoLabel1All};
video2Labels={videoLabel2All,videoLabel2All,videoLabel2All};


w0(:,1)=tr;w1(:,1)=tl;w2(:,1)=tt;
preprocessedData={w0,w1,w2};
if strcmp(labelingParameters.studyType,'1')
    preprocessedLabels={videoLabels,phoneLabels};
else
    preprocessedLabels={videoLabels,phoneLabels,video2Labels};
end

preprocessedDataAndLabels={preprocessedData,preprocessedLabels};

disp('labeling Finished.');
if labelingParameters.saveLabels
    save('preprocessedDataAndLabels','preprocessedDataAndLabels');
    disp('data and labels are saved.');
end
end
%%%
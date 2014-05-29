%% function checkLabelsPresentation(preprocessedDataAndLabels,Hd)
% This function gets preprocessedDataAndLabels and plots data and labels on
% eachother for right wrist, left wrist, torso seperately. each plot
% contains x,y,x acceleration data and conincided labels.
%   Inputs:
%         - preprocessedDataAndLabels. (1 x 2 cell)
%           first cell  ==> (data-1x3 (right-left-torso) cell ==> each cell contains a N x 4 matrix - [col1:timeStamps  col2:x-axisdata  col3:y-axisdata  col4:z-axisdata])
%           second cell ==> (labels-1x3(video1-phone-video2) cell)- each
%           cell contains a N x 4 matrix- [Label rock_Label flapRock_Label flap_Label]
%           Hd - filter coefficients
%%
function checkLabelsPresentation(preprocessedDataAndLabels,Hd)

W0=preprocessedDataAndLabels{1}{1};% W0=rightWristXYZ;
W1=preprocessedDataAndLabels{1}{2};% W1=leftWristXYZ;
W2=preprocessedDataAndLabels{1}{3};  % W2=torsoXYZ;
tr=W0(:,1);
tl=W1(:,1);
tt=W2(:,1);
phoneLabels=preprocessedDataAndLabels{2}{2};

videoLabels1=preprocessedDataAndLabels{2}{1};

%% Filter data (high-pass IIR,fc= 0.1)
% filteredW = filter(Hd,w0(:,2));
W0=filter(Hd,W0);
W1=filter(Hd,W1);
W2=filter(Hd,W2);

%% CHECK PHONE LABELS
allTimes={tr,tl,tt};
W={W0,W1,W2};
axisLabel={' rigth',' left',' torso'};
for i=1:3
    phoneLabelsS=phoneLabels{i};
    Wt=W{i};
    axisLabel1=axisLabel(i);
    figure('units','normalized','outerposition',[0 0 1 1],'name',['Phone Annotation- ',char(axisLabel1),' body sensor']);
    ax(3)=subplot(3,1,1);plot(allTimes{i},Wt(:,2),allTimes{i},phoneLabelsS(:,1),'r');ylabel(strcat('X-axis for ',axisLabel1));xlabel('time (ms)');title('Video Annotation-Annotator 1');
    hleg=legend('raw acceleration signal','rock: 400/ flap-rock: 600/flap: 800','Location','NorthEastOutside');
    set(hleg);
    
    ax(2)=subplot(3,1,2);plot(allTimes{i},Wt(:,3),allTimes{i},phoneLabelsS(:,1),'r');ylabel(strcat('Y-axis for ',axisLabel1));xlabel('time (ms)');
    hleg=legend('raw acceleration signal','rock: 400/ flap-rock: 600/flap: 800','Location','NorthEastOutside');
    set(hleg);
    ax(1)=subplot(3,1,3);plot(allTimes{i},Wt(:,4),allTimes{i},phoneLabelsS(:,1),'r');ylabel(strcat('Z-axis for ',axisLabel1));xlabel('time (ms)');
    hleg=legend('raw acceleration signal','rock: 400/ flap-rock: 600/flap: 800','Location','NorthEastOutside');
    set(hleg);
    linkaxes([ax(3) ax(2) ax(1)],'x');
end
%% CHECK VIDEO LABELS
allTimes={tr,tl,tt};
W={W0,W1,W2};
axisLabel={' rigth',' left',' torso'};
for i=1:3
    videoLabels1s=videoLabels1{i};
    Wt=W{i};
    axisLabel1=axisLabel(i);
    figure('units','normalized','outerposition',[0 0 1 1],'name',strcat('Video Annotation-Annotator 1 ',char(axisLabel1),' body sensor'));
    ax(3)=subplot(3,1,1);plot(allTimes{i},Wt(:,2),allTimes{i},videoLabels1s(:,1),'r');ylabel(strcat('X-axis for ',axisLabel1));xlabel('time (ms)');title('Video Annotation-Annotator 1');
    ax(2)=subplot(3,1,2);plot(allTimes{i},Wt(:,3),allTimes{i},videoLabels1s(:,1),'r');ylabel(strcat('Y-axis for ',axisLabel1));xlabel('time (ms)');
    ax(1)=subplot(3,1,3);plot(allTimes{i},Wt(:,4),allTimes{i},videoLabels1s(:,1),'r');ylabel(strcat('Z-axis for ',axisLabel1));xlabel('time (ms)');
    linkaxes([ax(3) ax(2) ax(1)],'x');
end

% check video labels by annotator 2
if size(preprocessedDataAndLabels{2},2)>2
    videoLabels2=preprocessedDataAndLabels{2}{3};
    for i=1:3
        videoLabels2s=videoLabels2{i};
        Wt=W{i};
        axisLabel1=axisLabel(i);
        figure('units','normalized','outerposition',[0 0 1 1],'name',['Video Annotation-Annotator 2 ',char(axisLabel1),' body sensor']);
        ax(3)=subplot(3,1,1);plot(allTimes{i},Wt(:,2),allTimes{i},videoLabels2s(:,1),'r');ylabel(strcat('X-axis for ',axisLabel1));xlabel('time (ms)');title('Video Annotation-Annotator 2');
        ax(2)=subplot(3,1,2);plot(allTimes{i},Wt(:,3),allTimes{i},videoLabels2s(:,1),'r');ylabel(strcat('Y-axis for ',axisLabel1));xlabel('time (ms)');
        ax(1)=subplot(3,1,3);plot(allTimes{i},Wt(:,4),allTimes{i},videoLabels2s(:,1),'r');ylabel(strcat('Z-axis for ',axisLabel1));xlabel('time (ms)');
        linkaxes([ax(3) ax(2) ax(1)],'x');
    end
end




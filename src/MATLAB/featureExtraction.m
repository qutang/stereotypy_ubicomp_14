%% function featureVectorAndLabels=featureExtraction(featureExtractionParameters,preprocessedData,preprocessedLabels,Hd)
%  featureExtraction(featureExtractionParameters,preprocessedData,preprocessedLabels,Hd)
%  gets data and labels and parameters to extract the desired features.... 
% 
%   The inputs of the function:
%      featureExtractionParameters -
%      preprocessedData - 
%      preprocessedLabels -
%      Hd -
%
%   The outputs of the function:
%       featureVectorAndLabels - 
%
%%
function featureVectorAndLabels=featureExtraction(featureExtractionParameters,preprocessedData,preprocessedLabels,Hd)
% Steps:
% 1. filter data with hight-pass filter with 0.2 cut off frequency
% 2. extracting feature vector for each sample (1-sec window length)
%       (1) Stockwell transform
%       (2) ...?
%% Load Data & Labels
% data:
rightWristXYZ=preprocessedData{1};% =rightWristXYZ;
leftWristXYZ=preprocessedData{2};% =leftWristXYZ;
torsoXYZ=preprocessedData{3};  % =torsoXYZ;

% video labels:
rightLabel=preprocessedLabels{1}{1}(:,1);% load rightLabel;
leftLabel=preprocessedLabels{1}{2}(:,1);% load leftLabel;
torsoLabel=preprocessedLabels{1}{3}(:,1);% load torsoLabel;

% phone labels:
rightLabelPhone=preprocessedLabels{2}{1}(:,1);% load rightLabel;

% times
tr=rightWristXYZ(:,1);% load tr;
tl=leftWristXYZ(:,1);% load tl;
tt=torsoXYZ(:,1);% load tt;
% load('Hd.mat');
%% Filter data (high-pass IIR,fc= 0.1)
w0=filter(Hd,rightWristXYZ); 
w1=filter(Hd,leftWristXYZ);
w2=filter(Hd,torsoXYZ);
%% keep btw two sync only
% halfsize=floor(length(rightLabel)/2);sR=find(rightLabel(1:halfsize)==50,1,'last');eR=find(rightLabel(halfsize:end)==50,1,'first')+halfsize-1;
% % halfsize=floor(length(leftLabel)/2);sL=find(leftLabel(1:halfsize)==50,1,'last');eL=find(leftLabel(halfsize:end)==50,1,'first')+halfsize-1;
% % halfsize=floor(length(torsoLabel)/2);sT=find(torsoLabel(1:halfsize)==50,1,'last');eT=find(torsoLabel(halfsize:end)==50,1,'first')+halfsize-1;
% % if isempty(sR) || isempty(sL) || isempty(sT),
% if isempty(sR)
%     fprintf('missing begining sync');
%     rightLabel1=rightLabel(1:eR-1);w0=w0(1:eR-1,:);tr=tr(1:eR-1);
%     leftLabel1=leftLabel(1:eR-1);w1=w1(1:eR-1,:);tl=tl(1:eR-1);
%     torsoLabel1=torsoLabel(1:eR-1);w2=w2(1:eR-1,:);tt=tt(1:eR-1);
%     rightLabelPhone1=rightLabelPhone(1:eR-1);
% elseif isempty(eR) 
%     % % % % examples are 001-2010-04-30 & 001-2010-06-03 sessions %%
%     % 002-2010-04-27&002-2011-03-22
%     fprintf('missing finishing sync; we end with minimum length');
%     % min1=min([size(w0,1),size(w1,1),size(w2,1)]);
%     rightLabel1=rightLabel(sR+1:end);w0=w0(sR+1:end,:);tr=tr(sR+1:end);
%     leftLabel1=leftLabel(sR+1:end);w1=w1(sR+1:end,:);tl=tl(sR+1:end);
%     torsoLabel1=torsoLabel(sR+1:end);w2=w2(sR+1:end,:);tt=tt(sR+1:end);
%     rightLabelPhone1=rightLabelPhone(sR+1:end);
% else
%     rightLabel1=rightLabel(sR+1:eR-1);w0=w0(sR+1:eR-1,:);tr=tr(sR+1:eR-1);
%     leftLabel1=leftLabel(sR+1:eR-1);w1=w1(sR+1:eR-1,:);tl=tl(sR+1:eR-1);
%     torsoLabel1=torsoLabel(sR+1:eR-1);w2=w2(sR+1:eR-1,:);tt=tt(sR+1:eR-1);
%     rightLabelPhone1=rightLabelPhone(sR+1:eR-1);
% end

% downsampling of labelVectors
rightLabel1=downsample(rightLabel,10,5);
leftLabel1=downsample(leftLabel,10,5);
torsoLabel1=downsample(torsoLabel,10,5);
rightLabelPhone1=downsample(rightLabelPhone,10,5);
tr1=downsample(tr,10,5);
tl1=downsample(tl,10,5);
tt1=downsample(tt,10,5);
% rightLabel1=rightLabel;
% leftLabel1=leftLabel;
% torsoLabel1=torsoLabel;
% rightLabelPhone1=rightLabelPhone;
% tr1=tr;
% tl1=tl;
% tt1=tt;

% change freqsamplingrate input of stockwell function depending of data size
% freqsamplingrate=100;
% if size(w0,1)<90000
%     freqsamplingrate=100;
% else
% %     freqsamplingrate=500;
%     freqsamplingrate=250;
% end
%% Feature Extraction
% % (1) Stockwell transform
% %  1-sec window length ==> 90 sample
% % [st,t,f] = st(timeseries,minfreq,maxfreq,samplingrate,freqsamplingrate)
% % [st,t,f] = st(w0(:,2),-1,200,0.011,-1);
% % [st,t,f] = st(w0(:,2),-1,20,0.011,-1);
%  [st,t,f] = st(w2(:,2),-1,-1,(1/90),500);
%  ******************Hooman Added*****************************************
% timeseries = w2(:,2);

fs = 90;
Nyquist = fs;

maxfreq_org =3; % 5;
% maxfreq_old = fix(length(timeseries)/2);
% maxfreq = fix(maxfreq_old * maxfreq_org / (Nyquist / 2));

% [st,t,f] = st(timeseries,-1,maxfreq,(1/fs),500);
%  ***********************************************************************
% % st     -a complex matrix containing the Stockwell transform. The rows of STOutput are the frequencies and the
% % columns are the time values ie each column is the "local spectrum" for that point in time
% figure,surf(t,f,10*log10(abs(st)),'edgecolor','none');axis tight; view(0,90);
% colorbar;%caxis([-120,40]);
% ylim([0,maxfreq_org]);xlabel('Time (Seconds)'); ylabel('Hz');title('Stockwell transform');

% right--------------------------------------------------------------------
for i=2:4
    wi0=w0(:,i);
    maxfreq_old = fix(length(wi0)/2);
    maxfreq = fix(maxfreq_old * maxfreq_org / (Nyquist / 2));
    minfreq = 0;
    freqSteps = 51;
    freqsamplingrate = round((maxfreq - minfreq+1)/freqSteps);
    [st,t,f] = stockwell(wi0,-1,maxfreq,0.011,freqsamplingrate);
    %     figure,subplot(2,1,1);imagesc(log10(abs(stockwell(1:10,2e4:6e4))));axis tight;
    %     subplot(2,1,2);plot(rightLabel(2e4:6e4),'r');axis tight;
%     lf=length(f)
%     b=f
    endst=51;
    fv1=abs(st(2:endst,:));
    fv1=(downsample(fv1',10,5))';
    %     st2=sort(abs(st),1,'descend');
    clear st;
    if    i==2
        fvw0x=[fv1];
    elseif i==3
        fvw0y=[fv1];
    elseif i==4
        fvw0z=[fv1];
    end
end
clear fv1;
%     lf=length(f)
%     b=f
% left--------------------------------------------------------------------
for i=2:4
    wi1=w1(:,i);
%     disp(length(wi1))
    %   [st,t,f] = stockwell(wi1,-1,15,(1/90),-1);
    maxfreq_old = fix(length(wi1)/2);
    maxfreq = fix(maxfreq_old * maxfreq_org / (Nyquist / 2));
    freqsamplingrate = round((maxfreq - minfreq+1)/freqSteps);
    [st,t,f] = stockwell(wi1,-1,maxfreq,0.011,freqsamplingrate);
    %     figure,subplot(2,1,1);imagesc(log10(abs(stockwell(1:10,2e4:6e4))));axis tight;
    %     subplot(2,1,2);plot(rightLabel(2e4:6e4),'r');axis tight;
%     fv1=abs(st(2:11,:));
    fv1=abs(st(2:endst,:));
    fv1=(downsample(fv1',10,5))';
    %     st2=sort(abs(st),1,'descend');
    clear st;
    if    i==2
        fvw1x=[fv1];
    elseif i==3
        fvw1y=[fv1];
    elseif i==4
        fvw1z=[fv1];
    end
end
clear fv1;
% torso--------------------------------------------------------------------
for i=2:4
    wi2=w2(:,i);
%     disp(length(wi2))
    maxfreq_old = fix(length(wi2)/2);
    maxfreq = fix(maxfreq_old * maxfreq_org / (Nyquist / 2));
    freqsamplingrate = round((maxfreq - minfreq+1)/freqSteps);
    [st,t,f] = stockwell(wi2,-1,maxfreq,0.011,freqsamplingrate);
%     fv1=abs(st(2:11,:));
    fv1=abs(st(2:endst,:));
    fv1=(downsample(fv1',10,5))';
    clear st;
    if    i==2
        fvw2x=[fv1];
    elseif i==3
        fvw2y=[fv1];
    elseif i==4
        fvw2z=[fv1];
    end
end
clear fv1;
fv=[fvw0x;fvw0y;fvw0z;fvw1x;fvw1y;fvw1z;fvw2x;fvw2y;fvw2z]';
% fv=[fvw0x;fvw0y;fvw0z;fvw2x;fvw2y;fvw2z]';
fvt=[tr1 fv];
featureVectorAndLabels.fv=fv;
featureVectorAndLabels.fvt=fvt;
% fv=cat(1,fv1,fv2);
%% features from previous work
%% windowing
windowLength=90;  %1 sec-91samples involved
f2345=[];
for t=6:10:size(w0,1)
    winStart=t-windowLength/2;
    winEnd=t+windowLength/2;
    if winStart<1
        winStart=1;
    elseif winEnd>size(w0,1)
        winEnd=size(w0,1);
    end
    windowedDataRight=w0(winStart:winEnd,2:4);
    windowedDataLeft=w1(winStart:winEnd,2:4);
    windowedDataTorso=w2(winStart:winEnd,2:4);
    windowedData={windowedDataRight,windowedDataLeft,windowedDataTorso};
    %% feature(2):The distances between the means of the axes to capture sensor orientation
    % clear meanRight;clear meanLeft;clear meanTorso;
    meanRight=mean(windowedDataRight);meanLeft=mean(windowedDataLeft);meanTorso=mean(windowedDataTorso);
    meanAll=[meanRight;meanLeft;meanTorso];
    f2=[];
    for i=1:3
        m=meanAll(i,:);
        f2xy =m(1)-m(2);
        f2yz =m(2)-m(3);
        f2xz =m(1)-m(3);
        f2=[f2;f2xy;f2yz;f2xz];
    end
    % xAxisMeanRight=mean(w0(:,2));yAxisMeanRight=mean(w0(:,3));zAxisMeanRight=mean(w0(:,4));
    % xAxisMeanLeft=mean(w1(:,2));yAxisMeanLeft=mean(w1(:,3));zAxisMeanLeft=mean(w1(:,4));
    % xAxisMeanTorso=mean(w2(:,2));yAxisMeanTorso=mean(w2(:,3));zAxisMeanTorso=mean(w2(:,4))
    %% feature(3): Variance to capture variability in different movement directions
    varRight=var(windowedDataRight);varLeft=var(windowedDataLeft);varTorso=var(windowedDataTorso);
    f3=[varRight';varLeft';varTorso'];
    %% feature(4): Correlation coefficients to capture simultaneous motion in each axis direction;
    f4=[];
    for i=1:3
        windowedDataRLT=windowedData{i};
        xyCorr=corrcoef(windowedDataRLT(:,1),windowedDataRLT(:,2));
        xzCorr=corrcoef(windowedDataRLT(:,1),windowedDataRLT(:,3));
        yzCorr=corrcoef(windowedDataRLT(:,2),windowedDataRLT(:,3));
        f4=[f4;xyCorr(1,2);xzCorr(1,2);yzCorr(1,2)];
    end
    % xcorr(x,x,'coeff');
    % f4=[f4;];
    %% feature(5):Entropy to capture the type of stereotypical motor movement
    mult = 1; %multiplicative constant is important
    co = HShannon_kNN_k_initialization(mult); %initialize the entropy ('H') estimator
    %('Shannon_kNN_k'), including the value of k
    f5=[];
    for i=1:3
        entropyR = HShannon_kNN_k_estimation(windowedDataRight(:,i)',co);
        entropyL = HShannon_kNN_k_estimation(windowedDataLeft(:,i)',co);
        entropyT = HShannon_kNN_k_estimation(windowedDataTorso(:,i)',co);
        f5=[f5;entropyR;entropyL;entropyT];
    end
    %% feature(6):First and second dominant frequencies and their magnitude of each axis for each snesor
    [orderedAmpsR,orderedNdxR]=sort(abs(fft(windowedDataRight)),'descend');maxAmpsR=orderedAmpsR(1:2,:);maxfR=orderedNdxR(1:2,:);
    [orderedAmpsL,orderedNdxL]=sort(abs(fft(windowedDataLeft)),'descend');maxAmpsL=orderedAmpsL(1:2,:);maxfL=orderedNdxL(1:2,:);
    [orderedAmpsT,orderedNdxT]=sort(abs(fft(windowedDataTorso)),'descend');maxAmpsT=orderedAmpsT(1:2,:);maxfR=orderedNdxT(1:2,:);
    f6=[maxAmpsR(:);maxfR(:);maxAmpsL(:);maxfL(:);maxAmpsT(:);maxfR(:)];
    %% feature(7): Energy of each axis for each sensor
    energyRight=mean(windowedDataRight.^2);energyLeft=mean(windowedDataLeft.^2);energyTorso=mean(windowedDataTorso.^2);
    f7=[energyRight';energyLeft';energyTorso'];
    %%
    wr=[f2;f3;f4;f5;f6;f7];
    f2345=[f2345 wr];
end
fvNew=[fv f2345'];
featureVectorAndLabels.fvNew=fvNew;
%% forming labling vector
% rightLabelvec=zeros(size(rightLabel1,1),4);
% rightLabelvec(find(rightLabel1==0),1)=1;rightLabelvec(find(rightLabel1==400),2)=1;rightLabelvec(find(rightLabel1==600),3)=1;rightLabelvec(find(rightLabel1==800),4)=1;
% leftLabelvec=zeros(size(leftLabel1,1),4);
% leftLabelvec(find(leftLabel1==0),1)=1;leftLabelvec(find(leftLabel1==400),2)=1;leftLabelvec(find(leftLabel1==600),3)=1;leftLabelvec(find(leftLabel1==800),4)=1;
% torsoLabelvec=zeros(size(torsoLabel1,1),4);
% torsoLabelvec(find(torsoLabel1==0),1)=1;torsoLabelvec(find(torsoLabel1==400),2)=1;torsoLabelvec(find(torsoLabel1==600),3)=1;torsoLabelvec(find(torsoLabel1==800),4)=1;
% Labelvec=[rightLabelvec;rightLabelvec;rightLabelvec;leftLabelvec;leftLabelvec;leftLabelvec;torsoLabelvec;torsoLabelvec;torsoLabelvec];
% % %
% rightLabelvec=rightLabel1;
% phoneLabelvec=rightLabelPhone1;
rightLabelvec(find(rightLabel1==0))=1;rightLabelvec(find(rightLabel1==400))=2;rightLabelvec(find(rightLabel1==600))=3;rightLabelvec(find(rightLabel1==800))=4;
leftLabelvec(find(leftLabel1==0))=1;leftLabelvec(find(leftLabel1==400))=2;leftLabelvec(find(leftLabel1==600))=3;leftLabelvec(find(leftLabel1==800))=4;
torsoLabelvec(find(torsoLabel1==0))=1;torsoLabelvec(find(torsoLabel1==400))=2;torsoLabelvec(find(torsoLabel1==600))=3;torsoLabelvec(find(torsoLabel1==800))=4;
phoneLabelvec(find(rightLabelPhone1==0))=1;phoneLabelvec(find(rightLabelPhone1==400))=2;phoneLabelvec(find(rightLabelPhone1==600))=3;phoneLabelvec(find(rightLabelPhone1==800))=4;
Labelvec=[rightLabelvec]';
featureVectorAndLabels.videoLabelvec=Labelvec;
featureVectorAndLabels.phoneLabelvec=phoneLabelvec';
if featureExtractionParameters.saveFeatures
    save('featureVectorAndLabels','featureVectorAndLabels');
    disp('saved featureVectorAndLabels')
end

end
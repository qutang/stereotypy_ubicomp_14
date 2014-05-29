%% function stockwellVisualization(preprocessedDataAndLabels,Hd)
% This function gets preprocessedDataAndLabels and plots data and labels on
% the same axis for right wrist, left wrist, torso seperately. each plot
% contains x,y,x acceleration data and corresponded labels.
%   Inputs:
%         preprocessedDataAndLabels-
%%
function stockwellVisualization(preprocessedDataAndLabels,Hd)

% clear all;
close all;
%% Load Data & Labels
% load preprocessedDataAndLabels;
% load Hd;
preprocessedLabels=preprocessedDataAndLabels{2}{2};
preprocessedData=preprocessedDataAndLabels{1};
% data:
rightWristXYZ=preprocessedData{1};% =rightWristXYZ;
leftWristXYZ=preprocessedData{2};% =leftWristXYZ;
torsoXYZ=preprocessedData{3};  % =torsoXYZ;

% labels:
rightLabel=preprocessedLabels{1}(:,1);% load rightLabel;
leftLabel=preprocessedLabels{2}(:,1);% load leftLabel;
torsoLabel=preprocessedLabels{3}(:,1);% load torsoLabel;

% times
tr=rightWristXYZ(:,1);% load tr;
tl=leftWristXYZ(:,1);% load tl;
tt=torsoXYZ(:,1);% load tt;
% load('Hd.mat');
%% Filter data (high-pass IIR,fc= 0.1)
w0=filter(Hd,rightWristXYZ);w0=w0(:,2:4);
w1=filter(Hd,leftWristXYZ);w1=w1(:,2:4);
w2=filter(Hd,torsoXYZ);w2=w2(:,2:4);
% w0=w0-repmat(mean(w0),size(w0,1),1);
% w1=w1-repmat(mean(w1),size(w1,1),1);
% w2=w2-repmat(mean(w2),size(w2,1),1);
%% keep btw two sync only
halfsize=floor(length(rightLabel)/2);sR=find(rightLabel(1:halfsize)==50,1,'last');eR=find(rightLabel(halfsize:end)==50,1,'first')+halfsize-1;
halfsize=floor(length(leftLabel)/2);sL=find(leftLabel(1:halfsize)==50,1,'last');eL=find(leftLabel(halfsize:end)==50,1,'first')+halfsize-1;
halfsize=floor(length(torsoLabel)/2);sT=find(torsoLabel(1:halfsize)==50,1,'last');eT=find(torsoLabel(halfsize:end)==50,1,'first')+halfsize-1;
if isempty(sR) || isempty(sL) || isempty(sT),
    fprintf('missing begining sync');
    %     min1=min([tr(1),tl(1),tt(1)]);
    %     % min1=min([size(w0,1),size(w1,1),size(w2,1)]);
    %     rightLabel1=rightLabel(1:min1);w0=w0(1:min1,:);tr=tr(1:min1);
    %     leftLabel1=leftLabel(1:min1);w1=w1(1:min1,:);tl=tl(1:min1);
    %     torsoLabel1=torsoLabel(1:min1);w2=w2(1:min1,:);tt=tt(1:min1);
    rightLabel1=rightLabel; leftLabel1=leftLabel; torsoLabel1=torsoLabel;
elseif isempty(eR) || isempty(eL) || isempty(eT),
    % % % % examples are 001-2010-04-30 & 001-2010-06-03 sessions %%
    % 002-2010-04-27&002-2011-03-22
    fprintf('missing finishing sync; we end with minimum length');
    % min1=min([size(w0,1),size(w1,1),size(w2,1)]);
    rightLabel1=rightLabel(sR+1:end);w0=w0(sR+1:end,:);tr=tr(sR+1:end);
    leftLabel1=leftLabel(sL+1:end);w1=w1(sL+1:end,:);tl=tl(sL+1:end);
    torsoLabel1=torsoLabel(sT+1:end);w2=w2(sT+1:end,:);tt=tt(sT+1:end);
    min1=min([size(w0,1),size(w1,1),size(w2,1)]);
    rightLabel1=rightLabel1(1:min1);w0=w0(1:min1,:);tr=tr(1:min1);
    leftLabel1=leftLabel1(1:min1);w1=w1(1:min1,:);tl=tl(1:min1);
    torsoLabel1=torsoLabel1(1:min1);w2=w2(1:min1,:);tt=tt(1:min1);
else
    rightLabel1=rightLabel(sR+1:eR-1);w0=w0(sR+1:eR-1,:);tr=tr(sR+1:eR-1);
    leftLabel1=leftLabel(sL+1:eL-1);w1=w1(sL+1:eL-1,:);tl=tl(sL+1:eL-1);
    torsoLabel1=torsoLabel(sT+1:eT-1);w2=w2(sT+1:eT-1,:);tt=tt(sT+1:eT-1);
end

% downsampling of labelVectors
% rightLabel1=downsample(rightLabel1,10,5);
% leftLabel1=downsample(leftLabel1,10,5);
% torsoLabel1=downsample(torsoLabel1,10,5);
% tr1=downsample(tr,10,5);
% tl1=downsample(tl,10,5);
% tt1=downsample(tt,10,5);

% change freqsamplingrate input of stockwell function depending of data size
if size(w0,1)<90000
    freqsamplingrate=100;
else
    freqsamplingrate=500;
end
%% calculate stockwell transform of norm of each accelerometer
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
maxfreq_org = 5;
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
norm_w0 = sqrt(sum(w0.^2,2));
maxfreq_old = fix(length(norm_w0)/2);
maxfreq = fix(maxfreq_old * maxfreq_org / (Nyquist / 2));
[st,t,f] = stockwell(norm_w0',-1,maxfreq,0.011,freqsamplingrate);
% figure,subplot(2,1,1);imagesc(log10(abs(stockwell(1:10,2e4:6e4))));axis tight;
% subplot(2,1,2);plot(rightLabel(2e4:6e4),'r');axis tight;
%image
S=st;T=t;F=f;
plot_data = abs(S);
figure,ax(1)=subplot(4,1,1);imagesc(T,F(2:end),plot_data(2:end,:));axis tight;
colorbar;xlabel('Time(sec)');ylabel('Frequency(Hz)');
zlabel('Amplitude');title('right wrist Stockwell');

% left--------------------------------------------------------------------
norm_w1 = sqrt(sum(w1.^2,2));
maxfreq_old = fix(length(norm_w1)/2);
maxfreq = fix(maxfreq_old * maxfreq_org / (Nyquist / 2));
[st,t,f] = stockwell(norm_w1',-1,maxfreq,0.011,freqsamplingrate);
% figure,subplot(2,1,1);imagesc(log10(abs(stockwell(1:10,2e4:6e4))));axis tight;
% subplot(2,1,2);plot(rightLabel(2e4:6e4),'r');axis tight;
%image
S=st;T=t;F=f;
plot_data = abs(S);
ax(2)=subplot(4,1,2);imagesc(T,F(2:end),plot_data(2:end,:));axis tight;
colorbar;xlabel('Time(sec)');ylabel('Frequency(Hz)');
zlabel('Amplitude');title('left wrist Stockwell');

% torso--------------------------------------------------------------------
norm_w2 = sqrt(sum(w2.^2,2));
maxfreq_old = fix(length(norm_w2)/2);
maxfreq = fix(maxfreq_old * maxfreq_org / (Nyquist / 2));
[st,t,f] = stockwell(norm_w2',-1,maxfreq,0.011,freqsamplingrate);
% figure,subplot(2,1,1);imagesc(log10(abs(stockwell(1:10,2e4:6e4))));axis tight;
% subplot(2,1,2);plot(rightLabel(2e4:6e4),'r');axis tight;
%image
S=st;T=t;F=f;
plot_data = abs(S);
ax(3)=subplot(4,1,3);imagesc(T,F(2:end),plot_data(2:end,:));axis tight;
colorbar;xlabel('Time(sec)');ylabel('Frequency(Hz)');
zlabel('Amplitude');title('torso Stockwell');

rightLabelvec(find(rightLabel1==0))=1;rightLabelvec(find(rightLabel1==400))=2;rightLabelvec(find(rightLabel1==600))=3;rightLabelvec(find(rightLabel1==800))=4;
leftLabelvec(find(leftLabel1==0))=1;leftLabelvec(find(leftLabel1==400))=2;leftLabelvec(find(leftLabel1==600))=3;leftLabelvec(find(leftLabel1==800))=4;
torsoLabelvec(find(torsoLabel1==0))=1;torsoLabelvec(find(torsoLabel1==400))=2;torsoLabelvec(find(torsoLabel1==600))=3;torsoLabelvec(find(torsoLabel1==800))=4;
ax(4)=subplot(4,1,4);imagesc(T,[0 4],rightLabelvec,[1 4]);%colorbar;
colorbar('YTickLabel',{'uknown','rock','rock-flap','flap'});
pause(4)
linkaxes([ax(4) ax(3) ax(2) ax(1)],'x');
%% plot norms and stockwell for each accelerometer in one figure
% fs = 90;
% Nyquist = fs;
% maxfreq_org = 5;
% % maxfreq_old = fix(length(timeseries)/2);
% % maxfreq = fix(maxfreq_old * maxfreq_org / (Nyquist / 2));
% 
% % [st,t,f] = st(timeseries,-1,maxfreq,(1/fs),500);
% %  ***********************************************************************
% % % st     -a complex matrix containing the Stockwell transform. The rows of STOutput are the frequencies and the
% % % columns are the time values ie each column is the "local spectrum" for that point in time
% % figure,surf(t,f,10*log10(abs(st)),'edgecolor','none');axis tight; view(0,90);
% % colorbar;%caxis([-120,40]);
% % ylim([0,maxfreq_org]);xlabel('Time (Seconds)'); ylabel('Hz');title('Stockwell transform');
% % right--------------------------------------------------------------------
% norm_w0 = sqrt(sum(w0.^2,2));
% maxfreq_old = fix(length(norm_w0)/2);
% maxfreq = fix(maxfreq_old * maxfreq_org / (Nyquist / 2));
% [st,t,f] = stockwell(norm_w0',-1,maxfreq,0.011,freqsamplingrate);
% % figure,subplot(2,1,1);imagesc(log10(abs(stockwell(1:10,2e4:6e4))));axis tight;
% % subplot(2,1,2);plot(rightLabel(2e4:6e4),'r');axis tight;
% %image
% S=st;T0=t;F=f;
% plot_data = abs(S);
% % plot_data(:,find(rightLabel1~=400))=[];
% % T0(find(rightLabel1~=400))=[];
% % norm_w0(find(rightLabel1~=400))=[];
% figure,ax(1)=subplot(7,1,1);imagesc(T0,F(2:end),plot_data(2:end,:));axis tight;
% colorbar;xlabel('Time(sec)');ylabel('Frequency(Hz)');
% zlabel('Amplitude');title('right wrist Stockwell');
% ax(2)=subplot(7,1,2);plot(T0,norm_w0);colorbar;
% % left--------------------------------------------------------------------
% norm_w1 = sqrt(sum(w1.^2,2));
% maxfreq_old = fix(length(norm_w1)/2);
% maxfreq = fix(maxfreq_old * maxfreq_org / (Nyquist / 2));
% [st,t,f] = stockwell(norm_w1',-1,maxfreq,0.011,freqsamplingrate);
% % figure,subplot(2,1,1);imagesc(log10(abs(stockwell(1:10,2e4:6e4))));axis tight;
% % subplot(2,1,2);plot(rightLabel(2e4:6e4),'r');axis tight;
% %image
% S=st;T1=t;F=f;
% plot_data = abs(S);
% % plot_data(:,find(rightLabel1~=400))=[];
% % T1(find(rightLabel1~=400))=[];
% % norm_w1(find(rightLabel1~=400))=[];
% ax(3)=subplot(7,1,3);imagesc(T1,F(2:end),plot_data(2:end,:));axis tight;
% colorbar;xlabel('Time(sec)');ylabel('Frequency(Hz)');
% zlabel('Amplitude');title('left wrist Stockwell');
% ax(4)=subplot(7,1,4);plot(T1,norm_w1);ylabel('||a(t)||');colorbar;
% % torso--------------------------------------------------------------------
% norm_w2 = sqrt(sum(w2.^2,2));
% maxfreq_old = fix(length(norm_w2)/2);
% maxfreq = fix(maxfreq_old * maxfreq_org / (Nyquist / 2));
% [st,t,f] = stockwell(norm_w2',-1,maxfreq,0.011,freqsamplingrate);
% % figure,subplot(2,1,1);imagesc(log10(abs(stockwell(1:10,2e4:6e4))));axis tight;
% % subplot(2,1,2);plot(rightLabel(2e4:6e4),'r');axis tight;
% %image
% S=st;T2=t;F=f;
% plot_data = abs(S);
% % plot_data(:,find(rightLabel1~=400))=[];
% % T2(find(rightLabel1~=400))=[];
% % norm_w2(find(rightLabel1~=400))=[];
% ax(5)=subplot(7,1,5);imagesc(T2,F(2:end),plot_data(2:end,:));axis tight;
% colorbar;xlabel('Time(sec)');ylabel('Frequency(Hz)');
% zlabel('Amplitude');title('torso Stockwell');
% ax(6)=subplot(7,1,6);plot(T2,norm_w2);colorbar;
% 
% rightLabelvec(find(rightLabel1==0))=1;rightLabelvec(find(rightLabel1==400))=2;rightLabelvec(find(rightLabel1==600))=3;rightLabelvec(find(rightLabel1==800))=4;
% leftLabelvec(find(leftLabel1==0))=1;leftLabelvec(find(leftLabel1==400))=2;leftLabelvec(find(leftLabel1==600))=3;leftLabelvec(find(leftLabel1==800))=4;
% torsoLabelvec(find(torsoLabel1==0))=1;torsoLabelvec(find(torsoLabel1==400))=2;torsoLabelvec(find(torsoLabel1==600))=3;torsoLabelvec(find(torsoLabel1==800))=4;
% % rightLabelvec(find(rightLabel1~=400))=[];
% T3=t;
% % T3(find(rightLabel1==400))=[];
% ax(7)=subplot(7,1,7);imagesc(T3,[0 4],rightLabelvec,[1 4]);%colorbar;
% colorbar('YTickLabel',{'uknown','rock','rock-flap','flap'});
% pause(7)
% linkaxes([ax(7) ax(6) ax(5) ax(4) ax(3) ax(2) ax(1)],'x');
%% plot norms , intensity and stockwell for each accelerometer in 3 figures
% intensity calculation
windowLength=90;  %1 sec-91samples involved
RightIntensity=[];
LeftIntensity=[];
TorsoIntensity=[];
varRightIntensity=[];
varLeftIntensity=[];
varTorsoIntensity=[];
for t=1:size(norm_w0,1)
    winStart=t-windowLength/2;
    winEnd=t+windowLength/2;
    if winStart<1
        winStart=1;
    elseif winEnd>size(norm_w0,1)
        winEnd=size(norm_w0,1);
    end
    windowedDataRight=norm_w0(winStart:winEnd);
    windowedDataLeft=norm_w1(winStart:winEnd);
    windowedDataTorso=norm_w2(winStart:winEnd);
    windowedDataRightIntensity=sum(windowedDataRight.^2);
    windowedDataLeftIntensity=sum(windowedDataLeft.^2);
    windowedDataTorsoIntensity=sum(windowedDataTorso.^2);
    RightIntensity=[RightIntensity windowedDataRightIntensity];
    LeftIntensity=[LeftIntensity windowedDataLeftIntensity];
    TorsoIntensity=[TorsoIntensity windowedDataTorsoIntensity];
    windowedDataRightVarIntensity=var(windowedDataRight);
    windowedDataLeftVarIntensity=var(windowedDataLeft);
    windowedDataTorsoVarIntensity=var(windowedDataTorso);
    varRightIntensity=[varRightIntensity windowedDataRightVarIntensity];
    varLeftIntensity=[varLeftIntensity windowedDataLeftVarIntensity];
    varTorsoIntensity=[varTorsoIntensity windowedDataTorsoVarIntensity];
end
fs = 90;
Nyquist = fs;
maxfreq_org = 5;
%% right--------------------------------------------------------------------
norm_w0 = sqrt(sum(w0.^2,2));
maxfreq_old = fix(length(norm_w0)/2);
maxfreq = fix(maxfreq_old * maxfreq_org / (Nyquist / 2));
[st,t,f] = stockwell(norm_w0',-1,maxfreq,0.011,freqsamplingrate);
% figure,subplot(2,1,1);imagesc(log10(abs(stockwell(1:10,2e4:6e4))));axis tight;
% subplot(2,1,2);plot(rightLabel(2e4:6e4),'r');axis tight;
%image
S=st;T=t;F=f;
plot_data = abs(S);
figure,ax(1)=subplot(5,1,1);imagesc(T,F(2:end),plot_data(2:end,:));axis tight;
colorbar;
xlabel('Time(sec)');ylabel('Frequency(Hz)');
zlabel('Amplitude');title('right wrist Stockwell');
ax(2)=subplot(5,1,2);plot(T,norm_w0); ylabel('||a(t)||');colorbar;
ax(3)=subplot(5,1,3);plot(T,RightIntensity); ylabel('Intensity in windowns');colorbar;
rightLabelvec(find(rightLabel1==0))=1;rightLabelvec(find(rightLabel1==400))=2;rightLabelvec(find(rightLabel1==600))=3;rightLabelvec(find(rightLabel1==800))=4;
ax(4)=subplot(5,1,4);plot(T,varRightIntensity);ylabel('variance Intensity in windowns');colorbar;
ax(5)=subplot(5,1,5);imagesc(T,[0 4],rightLabelvec,[1 4]);
colorbar('YTickLabel',{'uknown','rock','rock-flap','flap'});
pause(5)
linkaxes([ax(5) ax(4) ax(3) ax(2) ax(1)],'x');
%% left--------------------------------------------------------------------
norm_w1 = sqrt(sum(w1.^2,2));
maxfreq_old = fix(length(norm_w1)/2);
maxfreq = fix(maxfreq_old * maxfreq_org / (Nyquist / 2));
[st,t,f] = stockwell(norm_w1',-1,maxfreq,0.011,freqsamplingrate);
% figure,subplot(2,1,1);imagesc(log10(abs(stockwell(1:10,2e4:6e4))));axis tight;
% subplot(2,1,2);plot(rightLabel(2e4:6e4),'r');axis tight;
%image
S=st;T=t;F=f;
plot_data = abs(S);
figure,ax(1)=subplot(5,1,1);imagesc(T,F(2:end),plot_data(2:end,:));axis tight;
colorbar;xlabel('Time(sec)');ylabel('Frequency(Hz)');
zlabel('Amplitude');title('left wrist Stockwell');
ax(2)=subplot(5,1,2);plot(T,norm_w1);ylabel('||a(t)||');colorbar;
ax(3)=subplot(5,1,3);plot(T,LeftIntensity); ylabel('Intensity in windowns');colorbar;
leftLabelvec(find(leftLabel1==0))=1;leftLabelvec(find(leftLabel1==400))=2;leftLabelvec(find(leftLabel1==600))=3;leftLabelvec(find(leftLabel1==800))=4;
ax(4)=subplot(5,1,4);plot(T,varLeftIntensity);ylabel('variance Intensity in windowns');colorbar;
ax(5)=subplot(5,1,5);imagesc(T,[0 4],rightLabelvec,[1 4]);%colorbar;
colorbar('YTickLabel',{'uknown','rock','rock-flap','flap'});
pause(5)
linkaxes([ax(5) ax(4) ax(3) ax(2) ax(1)],'x');
% torso--------------------------------------------------------------------
norm_w2 = sqrt(sum(w2.^2,2));
maxfreq_old = fix(length(norm_w2)/2);
maxfreq = fix(maxfreq_old * maxfreq_org / (Nyquist / 2));
[st,t,f] = stockwell(norm_w2',-1,maxfreq,0.011,freqsamplingrate);
% figure,subplot(2,1,1);imagesc(log10(abs(stockwell(1:10,2e4:6e4))));axis tight;
% subplot(2,1,2);plot(rightLabel(2e4:6e4),'r');axis tight;
%image
S=st;T=t;F=f;
plot_data = abs(S);
figure,ax(1)=subplot(5,1,1);imagesc(T,F(2:end),plot_data(2:end,:));axis tight;
colorbar;xlabel('Time(sec)');ylabel('Frequency(Hz)');
zlabel('Amplitude');title('torso Stockwell');
ax(2)=subplot(5,1,2);plot(T,norm_w2);ylabel('||a(t)||');colorbar;
ax(3)=subplot(5,1,3);plot(T,TorsoIntensity); ylabel('Intensity in windowns');colorbar;
torsoLabelvec(find(torsoLabel1==0))=1;torsoLabelvec(find(torsoLabel1==400))=2;torsoLabelvec(find(torsoLabel1==600))=3;torsoLabelvec(find(torsoLabel1==800))=4;
ax(4)=subplot(5,1,4);plot(T,varTorsoIntensity);ylabel('variance Intensity in windowns');colorbar;
ax(5)=subplot(5,1,5);imagesc(T,[0 4],rightLabelvec,[1 4]);%colorbar;
colorbar('YTickLabel',{'uknown','rock','rock-flap','flap'});
pause(5)
linkaxes([ax(5) ax(4) ax(3) ax(2) ax(1)],'x');

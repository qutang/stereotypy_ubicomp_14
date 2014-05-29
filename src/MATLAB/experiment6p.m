%% experiment#6p
%  This script generates table1 & 2 of ubicomp2014 paper which is Kinematic
%  parameters
%
% What is our output in this script:
% # table - which has same structure as table.2 of ubicomp2014 paper.
% # table1- which has same structure as table.1 of ubicomp2014 paper.
% # table2- anova on  kinematic parameters for each participant and each
% study for each session and across different sessions.
% # table3- t-test on  kinematic parameters of each participant across studies
% # table4-pair wise t-test p-values for  kinematic parameters for each
% participant and each study across different sessions
% # table5-detailed version of table1. (info for each session)
%
%%
clear all;
setRoot;
table=zeros(12,12);
table1=zeros(12,12);
table2=NaN*ones(12,84);
table3=NaN*ones(12,30);
table4=NaN*ones(12,36);
table5=NaN*ones(12,36);
% varN=['1','2'];
studyLabel=['1','2'];
col4id=[7,3];
load Hd;
for ii=1:6   % There are 6 subjects common in both studies
    totalDurationF2=[];engagementProportionF2=[];intensityF2=[];durationF2=[];temporalDistanceF2=[];numOfMovesF2=[];
    totalDurationR2=[];engagementProportionR2=[];intensityR2=[];durationR2=[];temporalDistanceR2=[];numOfMovesR2=[];
    totalDurationRF2=[];engagementProportionRF2=[];intensityRF2=[];durationRF2=[];temporalDistanceRF2=[];numOfMovesRF2=[];
    totalDurationFlabel2=[];engagementProportionFlabel2=[];intensityFlabel2=[];durationFlabel2=[];temporalDistanceFlabel2=[];numOfMovesFlabel2=[];
    totalDurationRlabel2=[];engagementProportionRlabel2=[];intensityRlabel2=[];durationRlabel2=[];temporalDistanceRlabel2=[];numOfMovesRlabel2=[];
    totalDurationRFlabel2=[];engagementProportionRFlabel2=[];intensityRFlabel2=[];durationRFlabel2=[];temporalDistanceRFlabel2=[];numOfMovesRFlabel2=[];
    for v=1:2
        studyXDataPath=strcat(rootPath,filesep,'data',filesep,'Study',studyLabel(v),filesep);
        sessionList0=dir(studyXDataPath);
        sessionListChar=sessionList0(3:end,:);
        
        sessionListCell={sessionListChar.name};
        sessionListChar=char(sessionListCell);

        selectedSubjectSessionList=sessionListChar(strcmp(cellstr(sessionListChar(:,col4id(v))),num2str(ii)),:);
        sessionNum=size(selectedSubjectSessionList,1);
        % for ii=1:str2num(AllPaths{end,2})
        %     for ii=1:6
%         subjectNdxs=find(strcmp(AllPaths(:,5),strcat(num2str(ii),'common')));
%         subjectSessions=AllPaths(subjectNdxs,:);
%         classSessions=subjectSessions(strcmp(subjectSessions(:,4),'Class'),:);
        
        
        % 2. load fvs of all subject sessions and conc to fv.
        totalDurationF=[];engagementProportionF=[];intensityF=[];durationF=[];temporalDistanceF=[];numOfMovesF=[];
        totalDurationR=[];engagementProportionR=[];intensityR=[];durationR=[];temporalDistanceR=[];numOfMovesR=[];
        totalDurationRF=[];engagementProportionRF=[];intensityRF=[];durationRF=[];temporalDistanceRF=[];numOfMovesRF=[];
        totalDurationFlabel=[];engagementProportionFlabel=[];intensityFlabel=[];durationFlabel=[];temporalDistanceFlabel=[];numOfMovesFlabel=[];
        totalDurationRlabel=[];engagementProportionRlabel=[];intensityRlabel=[];durationRlabel=[];temporalDistanceRlabel=[];numOfMovesRlabel=[];
        totalDurationRFlabel=[];engagementProportionRFlabel=[];intensityRFlabel=[];durationRFlabel=[];temporalDistanceRFlabel=[];numOfMovesRFlabel=[];
        
        for i2=1:sessionNum
                        sessionPath=strcat(studyXDataPath,selectedSubjectSessionList(i2,:));
                        cd(sessionPath);
            
            
            
%             sessionPath=char(classSessions{i2,3});
%             cd(sessionPath);
            if exist(strcat(sessionPath,filesep,'preprocessedDataAndLabels.mat'))
                load preprocessedDataAndLabels;
                timeseriesFeatures=timeseriesFeatureGenerator(preprocessedDataAndLabels,Hd);
                %             rateF=[rateF;timeseriesFeatures.rate.flap];
                %             rateR=[rateR;timeseriesFeatures.rate.rock];
                %             rateRF=[rateRF;timeseriesFeatures.rate.rockFlap];
                
                %             totalDurationF=[totalDurationF;timeseriesFeatures.rate.flap(2)];
                %             totalDurationR=[totalDurationR;timeseriesFeatures.rate.rock(2)];
                %             totalDurationRF=[totalDurationRF;timeseriesFeatures.rate.rockFlap(2)];
                
                engagementProportionF=[engagementProportionF;timeseriesFeatures.engagementProportion.flap];
                engagementProportionR=[engagementProportionR;timeseriesFeatures.engagementProportion.rock];
                engagementProportionRF=[engagementProportionRF;timeseriesFeatures.engagementProportion.rockFlap];
                
                intensityF=[intensityF,timeseriesFeatures.boutIntensities.flap];
                intensityR=[intensityR,timeseriesFeatures.boutIntensities.rock];
                intensityRF=[intensityRF,timeseriesFeatures.boutIntensities.rockFlap];
                intensityFlabel=[intensityFlabel,i2*ones(1,length(timeseriesFeatures.boutIntensities.flap))];
                intensityRlabel=[intensityRlabel,i2*ones(1,length(timeseriesFeatures.boutIntensities.rock))];
                intensityRFlabel=[intensityRFlabel,i2*ones(1,length(timeseriesFeatures.boutIntensities.rockFlap))];
                
                durationF=[durationF,timeseriesFeatures.boutsDuration.flap];
                durationR=[durationR,timeseriesFeatures.boutsDuration.rock];
                durationRF=[durationRF,timeseriesFeatures.boutsDuration.rockFlap];
                durationFlabel=[durationFlabel,i2*ones(1,length(timeseriesFeatures.boutsDuration.flap))];
                durationRlabel=[durationRlabel,i2*ones(1,length(timeseriesFeatures.boutsDuration.rock))];
                durationRFlabel=[durationRFlabel,i2*ones(1,length(timeseriesFeatures.boutsDuration.rockFlap))];
                
                temporalDistanceF=[temporalDistanceF,timeseriesFeatures.boutsTemporalDistance.flap];
                temporalDistanceR=[temporalDistanceR,timeseriesFeatures.boutsTemporalDistance.rock];
                temporalDistanceRF=[temporalDistanceRF,timeseriesFeatures.boutsTemporalDistance.rockFlap];
                temporalDistanceFlabel=[temporalDistanceFlabel,i2*ones(1,length(timeseriesFeatures.boutsTemporalDistance.flap))];
                temporalDistanceRlabel=[temporalDistanceRlabel,i2*ones(1,length(timeseriesFeatures.boutsTemporalDistance.rock))];
                temporalDistanceRFlabel=[temporalDistanceRFlabel,i2*ones(1,length(timeseriesFeatures.boutsTemporalDistance.rockFlap))];
                
                numOfMovesF=[numOfMovesF,timeseriesFeatures.numOfMoves.flap];
                numOfMovesR=[numOfMovesR,timeseriesFeatures.numOfMoves.rock];
                numOfMovesRF=[numOfMovesRF,timeseriesFeatures.numOfMoves.rockFlap];
                numOfMovesFlabel=[numOfMovesFlabel,i2*ones(1,length(timeseriesFeatures.numOfMoves.flap))];
                numOfMovesRlabel=[numOfMovesRlabel,i2*ones(1,length(timeseriesFeatures.numOfMoves.rock))];
                numOfMovesRFlabel=[numOfMovesRFlabel,i2*ones(1,length(timeseriesFeatures.numOfMoves.rockFlap))];
            end
        end
        
        if ~isempty(durationR)
            % average of intensity over bouts:
            table(1,v-1+2*ii-1)=sum(intensityR)/length(intensityR);
            [p,antable,stats]= anova1(intensityR,intensityRlabel,'off');
            if length(unique(intensityRlabel))>1
                c= multcompare(stats,'display','off');
                table4(1,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=c(:,6)';
            else
                table4(1,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=NaN;
            end
            U=unique(intensityRlabel);
            for i4=1:length(unique(intensityRlabel))
                table2(1,7*(v-1)+14*ii-(14-(2*U(i4)-1))) =mean(intensityR(intensityRlabel==U(i4)));
                table2(1,7*(v-1)+14*ii-(14-2*U(i4))) =var(intensityR(intensityRlabel==U(i4)));
            end
            table2(1,7*(v-1)+14*ii-7) =p;
            %             table2(1,v-1+8*ii-6) =
            %             table2(1,v-1+8*ii-5) =
            
            
            % rate: number of bout for each behaviour/total duration
            %         table(4,v-1+2*ii-1)=length(numOfMovesR)/sum(rateR(:,2));
            % average of bouts duration
            table(4,v-1+2*ii-1)=mean(durationR);
            [p,antable,stats]= anova1(durationR,durationRlabel,'off');
            U=unique(durationRlabel);
            if length(unique(durationRlabel))>1
                c= multcompare(stats,'display','off');table4(4,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=c(:,6)';
            else
                table4(4,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=NaN;
            end
            
            for i4=1:length(unique(durationRlabel))
                table2(4,7*(v-1)+14*ii-(14-(2*U(i4)-1))) =mean(durationR(durationRlabel==U(i4)));
                table2(4,7*(v-1)+14*ii-(14-2*U(i4))) =var(durationR(durationRlabel==U(i4)));
            end
            U=unique(durationRlabel);
            for i4=1:length(unique(durationRlabel))
                table5(7,3*(v-1)+6*ii-(6-U(i4)))=sum(durationR(find(durationRlabel==U(i4))));
                table5(4,3*(v-1)+6*ii-(6-U(i4)))=length(find(durationRlabel==U(i4)));
                table5(10,3*(v-1)+6*ii-(6-U(i4)))=sum(engagementProportionR(U(i4),2));
            end
            table2(4,7*(v-1)+14*ii-7) =p;
            %             table5()=
            % average of latency
            table(7,v-1+2*ii-1)=mean(temporalDistanceR);
            [p,antable,stats]= anova1(temporalDistanceR,temporalDistanceRlabel,'off');
            U=unique(temporalDistanceRlabel);
            if length(unique(temporalDistanceRlabel))>1
                c= multcompare(stats,'display','off');table4(7,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=c(:,6)';
            else
                table4(7,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=NaN;
            end
            
            for i4=1:length(unique(temporalDistanceRlabel))
                table2(7,7*(v-1)+14*ii-(14-(2*U(i4)-1))) =mean(temporalDistanceR(temporalDistanceRlabel==U(i4)));
                table2(7,7*(v-1)+14*ii-(14-2*U(i4))) =var(temporalDistanceR(temporalDistanceRlabel==U(i4)));
            end
            table2(7,7*(v-1)+14*ii-7) =p;
            
            % average of number of moves per bout
            table(10,v-1+2*ii-1)=mean(numOfMovesR);
            [p,antable,stats]= anova1(numOfMovesR,numOfMovesRlabel,'off');
            U=unique(numOfMovesRlabel);
            if length(unique(numOfMovesRlabel))>1
                c= multcompare(stats,'display','off');table4(10,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=c(:,6)';
            else
                table4(10,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=NaN;
            end
            
            for i4=1:length(unique(numOfMovesRlabel))
                table2(10,7*(v-1)+14*ii-(14-(2*U(i4)-1))) =mean(numOfMovesR(numOfMovesRlabel==U(i4)));
                table2(10,7*(v-1)+14*ii-(14-2*U(i4))) =var(numOfMovesR(numOfMovesRlabel==U(i4)));
            end
            table2(10,7*(v-1)+14*ii-7) =p;
            
            % total engaging time/ total session length
            table1(1,v-1+2*ii-1)=sum(engagementProportionR(:,1))/sum(engagementProportionR(:,2));
            %  total session length
            table1(4,v-1+2*ii-1)=sum(engagementProportionR(:,2));
            % number of bouts
            table1(7,v-1+2*ii-1)=length(durationR);
            table1(10,v-1+2*ii-1)=sum(durationR);
        end
        if ~isempty(durationF)
            % average of intensity over bouts:
            table(2,v-1+2*ii-1)=sum(intensityF)/length(intensityF);
            [p,antable,stats]= anova1(intensityF,intensityFlabel,'off');
            U=unique(intensityFlabel);
            if length(unique(intensityFlabel))>1
                c= multcompare(stats,'display','off');table4(2,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=c(:,6)';
            else
                table4(2,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=NaN;
            end
            
            for i4=1:length(unique(intensityFlabel))
                table2(2,7*(v-1)+14*ii-(14-(2*U(i4)-1))) =mean(intensityF(intensityFlabel==U(i4)));
                table2(2,7*(v-1)+14*ii-(14-2*U(i4))) =var(intensityF(intensityFlabel==U(i4)));
            end
            U=unique(durationFlabel);
            for i4=1:length(unique(durationFlabel))
                table5(8,3*(v-1)+6*ii-(6-U(i4)))=sum(durationF(find(durationFlabel==U(i4))));
                table5(5,3*(v-1)+6*ii-(6-U(i4)))=length(find(durationFlabel==U(i4)));
                table5(11,3*(v-1)+6*ii-(6-U(i4)))=sum(engagementProportionF(U(i4),2));
            end
            table2(2,7*(v-1)+14*ii-7)  =p;
            
            % number of bout for each behaviour/total duration
            %         table(5,v-1+2*ii-1)=length(numOfMovesF)/sum(rateF(:,2));
            
            % average of bouts duration
            table(5,v-1+2*ii-1)=mean(durationF);
            [p,antable,stats]= anova1(durationF,durationFlabel,'off');
            U=unique(durationFlabel);
            if length(unique(durationFlabel))>1
                c= multcompare(stats,'display','off');table4(5,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=c(:,6)';
            else
                table4(5,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=NaN;
            end
            
            for i4=1:length(unique(durationFlabel))
                table2(5,7*(v-1)+14*ii-(14-(2*U(i4)-1))) =mean(durationF(durationFlabel==U(i4)));
                table2(5,7*(v-1)+14*ii-(14-2*U(i4))) =var(durationF(durationFlabel==U(i4)));
            end
            table2(5,7*(v-1)+14*ii-7) =p;
            
            % average of latency
            table(8,v-1+2*ii-1)=mean(temporalDistanceF);
            [p,antable,stats]= anova1(temporalDistanceF,temporalDistanceFlabel,'off');
            U=unique(temporalDistanceFlabel);
            if length(unique(temporalDistanceFlabel))>1
                c= multcompare(stats,'display','off');table4(8,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=c(:,6)';
            else
                table4(8,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=NaN;
            end
            
            for i4=1:length(unique(temporalDistanceFlabel))
                table2(8,7*(v-1)+14*ii-(14-(2*U(i4)-1))) =mean(temporalDistanceF(temporalDistanceFlabel==U(i4)));
                table2(8,7*(v-1)+14*ii-(14-2*U(i4))) =var(temporalDistanceF(temporalDistanceFlabel==U(i4)));
            end
            table2(8,7*(v-1)+14*ii-7) =p;
            
            % average of number of moves per bout
            table(11,v-1+2*ii-1)=mean(numOfMovesF);
            [p,antable,stats]= anova1(numOfMovesF,numOfMovesFlabel,'off');
            U=unique(numOfMovesFlabel);
            if length(unique(numOfMovesFlabel))>1
                c= multcompare(stats,'display','off');table4(11,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=c(:,6)';
            else
                table4(11,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=NaN;
            end
            
            for i4=1:length(unique(numOfMovesFlabel))
                table2(11,7*(v-1)+14*ii-(14-(2*U(i4)-1))) =mean(numOfMovesF(numOfMovesFlabel==U(i4)));
                table2(11,7*(v-1)+14*ii-(14-2*U(i4))) =var(numOfMovesF(numOfMovesFlabel==U(i4)));
            end
            table2(11,7*(v-1)+14*ii-7) =p;
            
            % total engaging time/ total session length
            table1(2,v-1+2*ii-1)=sum(engagementProportionF(:,1))/sum(engagementProportionF(:,2));
            %  total session length
            table1(5,v-1+2*ii-1)=sum(engagementProportionF(:,2));
            % number of bouts
            table1(8,v-1+2*ii-1)=length(durationF);
            table1(11,v-1+2*ii-1)=sum(durationF);
        end
        if ~isempty(durationRF)
            % average of intensity over bouts:
            table(3,v-1+2*ii-1)=sum(intensityRF)/length(intensityRF);
            [p,antable,stats]= anova1(intensityRF,intensityRFlabel,'off');
            U=unique(intensityRFlabel);
            if length(unique(intensityRFlabel))>1
                c= multcompare(stats,'display','off');table4(3,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=c(:,6)';
            else
                table4(3,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=NaN;
            end
            
            for i4=1:length(unique(intensityRFlabel))
                table2(3,7*(v-1)+14*ii-(14-(2*U(i4)-1))) =mean(intensityRF(intensityRFlabel==U(i4)));
                table2(3,7*(v-1)+14*ii-(14-2*U(i4))) =var(intensityRF(intensityRFlabel==U(i4)));
            end
            U=unique(durationRFlabel);
            for i4=1:length(unique(durationRFlabel))
                table5(9,3*(v-1)+6*ii-(6-U(i4)))=sum(durationRF(find(durationRFlabel==U(i4))));
                table5(6,3*(v-1)+6*ii-(6-U(i4)))=length(find(durationRFlabel==U(i4)));
                table5(12,3*(v-1)+6*ii-(6-U(i4)))=sum(engagementProportionRF(U(i4),2));
            end
            table2(3,7*(v-1)+14*ii-7) =p;
            
            % number of bout for each behaviour/total duration
            %         table(6,v-1+2*ii-1)=length(numOfMovesRF)/sum(rateRF(:,2));
            
            % average of bouts duration
            table(6,v-1+2*ii-1)=mean(durationRF);
            [p,antable,stats]= anova1(durationRF,durationRFlabel,'off');
            U=unique(durationRFlabel);
            if length(unique(durationRFlabel))>1
                c= multcompare(stats,'display','off');table4(6,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=c(:,6)';
            else
                table4(6,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=NaN;
            end
            
            for i4=1:length(unique(durationRFlabel))
                table2(6,7*(v-1)+14*ii-(14-(2*U(i4)-1))) =mean(durationRF(durationRFlabel==U(i4)));
                table2(6,7*(v-1)+14*ii-(14-2*U(i4))) =var(durationRF(durationRFlabel==U(i4)));
            end
            table2(6,7*(v-1)+14*ii-7) =p;
            
            % average of latency
            table(9,v-1+2*ii-1)=mean(temporalDistanceRF);
            [p,antable,stats]= anova1(temporalDistanceRF,temporalDistanceRFlabel,'off');
            U=unique(temporalDistanceRFlabel);
            if length(unique(temporalDistanceRFlabel))>1
                c= multcompare(stats,'display','off');table4(9,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=c(:,6)';
            else
                table4(9,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=NaN;
            end
            
            for i4=1:length(unique(temporalDistanceRFlabel))
                table2(9,7*(v-1)+14*ii-(14-(2*U(i4)-1))) =mean(temporalDistanceRF(temporalDistanceRFlabel==U(i4)));
                table2(9,7*(v-1)+14*ii-(14-2*U(i4))) =var(temporalDistanceRF(temporalDistanceRFlabel==U(i4)));
            end
            table2(9,7*(v-1)+14*ii-7) =p;
            
            % average of number of moves per bout
            table(12,v-1+2*ii-1)=mean(numOfMovesRF);
            [p,antable,stats]= anova1(numOfMovesRF,numOfMovesRFlabel,'off');
            U=unique(numOfMovesRFlabel);
            if length(unique(numOfMovesRFlabel))>1
                c= multcompare(stats,'display','off');table4(12,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=c(:,6)';
            else
                table4(12,3*(v-1)+6*ii-5:3*(v-1)+6*ii-3)=NaN;
            end
            
            for i4=1:length(unique(numOfMovesRFlabel))
                table2(12,7*(v-1)+14*ii-(14-(2*U(i4)-1))) =mean(numOfMovesRF(numOfMovesRFlabel==U(i4)));
                table2(12,7*(v-1)+14*ii-(14-2*U(i4))) =var(numOfMovesRF(numOfMovesRFlabel==U(i4)));
            end
            table2(12,7*(v-1)+14*ii-7) =p;
            
            % total engaging time/ total session length
            %             table(15,v-1+2*ii-1)=sum(engagementProportionRF(:,1))/sum(engagementProportionRF(:,2));
            table1(3,v-1+2*ii-1)=sum(durationRF)/sum(engagementProportionRF(:,2));
            %  total session length
            table1(6,v-1+2*ii-1)=sum(engagementProportionRF(:,2));
            % number of bouts
            table1(9,v-1+2*ii-1)=length(durationRF);
            table1(12,v-1+2*ii-1)=sum(durationRF);
        end
        
        
        
        intensityF2=[intensityF2,intensityF];
        intensityR2=[intensityR2,intensityR];
        intensityRF2=[intensityRF2,intensityRF];
        intensityFlabel2=[intensityFlabel2,v*ones(1,length(intensityFlabel))];
        intensityRlabel2=[intensityRlabel2,v*ones(1,length(intensityRlabel))];
        intensityRFlabel2=[intensityRFlabel2,v*ones(1,length(intensityRFlabel))];
        
        durationF2=[durationF2,durationF];
        durationR2=[durationR2,durationR];
        durationRF2=[durationRF2,durationRF];
        durationFlabel2=[durationFlabel2,v*ones(1,length(durationFlabel))];
        durationRlabel2=[durationRlabel2,v*ones(1,length(durationRlabel))];
        durationRFlabel2=[durationRFlabel2,v*ones(1,length(durationRFlabel))];
        
        temporalDistanceF2=[temporalDistanceF2,temporalDistanceF];
        temporalDistanceR2=[temporalDistanceR2,temporalDistanceR];
        temporalDistanceRF2=[temporalDistanceRF2,temporalDistanceRF];
        temporalDistanceFlabel2=[temporalDistanceFlabel2,v*ones(1,length(temporalDistanceFlabel))];
        temporalDistanceRlabel2=[temporalDistanceRlabel2,v*ones(1,length(temporalDistanceRlabel))];
        temporalDistanceRFlabel2=[temporalDistanceRFlabel2,v*ones(1,length(temporalDistanceRFlabel))];
        
        numOfMovesF2=[numOfMovesF2,numOfMovesF];
        numOfMovesR2=[numOfMovesR2,numOfMovesR];
        numOfMovesRF2=[numOfMovesRF2,numOfMovesRF];
        numOfMovesFlabel2=[numOfMovesFlabel2,v*ones(1,length(numOfMovesFlabel))];
        numOfMovesRlabel2=[numOfMovesRlabel2,v*ones(1,length(numOfMovesRlabel))];
        numOfMovesRFlabel2=[numOfMovesRFlabel2,v*ones(1,length(numOfMovesRFlabel))];
    end
    
    if ~isempty(durationR2)
        % average of intensity over bouts:
        table3(1,5*ii-4)=mean(intensityR2(intensityRlabel2==1));
        table3(1,5*ii-3)=var(intensityR2(intensityRlabel2==1));
        table3(1,5*ii-2)=mean(intensityR2(intensityRlabel2==2));
        table3(1,5*ii-1)=var(intensityR2(intensityRlabel2==2));
        [p,antable,stats]= anova1(intensityR2,intensityRlabel2,'off');
        table3(1,5*ii) =p;
        
        % average of bouts duration
        table3(4,5*ii-4)=mean(durationR2(durationRlabel2==1));
        table3(4,5*ii-3)=var(durationR2(durationRlabel2==1));
        table3(4,5*ii-2)=mean(durationR2(durationRlabel2==2));
        table3(4,5*ii-1)=var(durationR2(durationRlabel2==2));
        [p,antable,stats]= anova1(durationR2,durationRlabel2,'off');
        table3(4,5*ii) =p;
        
        % average of latency
        table3(7,5*ii-4)=mean(temporalDistanceR2(temporalDistanceRlabel2==1));
        table3(7,5*ii-3)=var(temporalDistanceR2(temporalDistanceRlabel2==1));
        table3(7,5*ii-2)=mean(temporalDistanceR2(temporalDistanceRlabel2==2));
        table3(7,5*ii-1)=var(temporalDistanceR2(temporalDistanceRlabel2==2));
        [p,antable,stats]= anova1(temporalDistanceR2,temporalDistanceRlabel2,'off');
        table3(7,5*ii) =p;
        
        
        % average of number of moves per bout
        table3(10,5*ii-4)=mean(numOfMovesR2(numOfMovesRlabel2==1));
        table3(10,5*ii-3)=var(numOfMovesR2(numOfMovesRlabel2==1));
        table3(10,5*ii-2)=mean(numOfMovesR2(numOfMovesRlabel2==2));
        table3(10,5*ii-1)=var(numOfMovesR2(numOfMovesRlabel2==2));
        [p,antable,stats]= anova1(numOfMovesR2,numOfMovesRlabel2,'off');
        table3(10,5*ii) =p;
        
    end
    if ~isempty(durationF2)
        % average of intensity over bouts:
        table3(2,5*ii-4)=mean(intensityF2(intensityFlabel2==1));
        table3(2,5*ii-3)=var(intensityF2(intensityFlabel2==1));
        table3(2,5*ii-2)=mean(intensityF2(intensityFlabel2==2));
        table3(2,5*ii-1)=var(intensityF2(intensityFlabel2==2));
        [p,antable,stats]= anova1(intensityF2,intensityFlabel2,'off');
        table3(2,5*ii) =p;
        
        % average of bouts duration
        table3(5,5*ii-4)=mean(durationF2(durationFlabel2==1));
        table3(5,5*ii-3)=var(durationF2(durationFlabel2==1));
        table3(5,5*ii-2)=mean(durationF2(durationFlabel2==2));
        table3(5,5*ii-1)=var(durationF2(durationFlabel2==2));
        [p,antable,stats]= anova1(durationF2,durationFlabel2,'off');
        table3(5,5*ii) =p;
        
        % average of latency
        table3(8,5*ii-4)=mean(temporalDistanceF2(temporalDistanceFlabel2==1));
        table3(8,5*ii-3)=var(temporalDistanceF2(temporalDistanceFlabel2==1));
        table3(8,5*ii-2)=mean(temporalDistanceF2(temporalDistanceFlabel2==2));
        table3(8,5*ii-1)=var(temporalDistanceF2(temporalDistanceFlabel2==2));
        [p,antable,stats]= anova1(temporalDistanceF2,temporalDistanceFlabel2,'off');
        table3(8,5*ii) =p;
        
        
        % average of number of moves per bout
        table3(11,5*ii-4)=mean(numOfMovesF2(numOfMovesFlabel2==1));
        table3(11,5*ii-3)=var(numOfMovesF2(numOfMovesFlabel2==1));
        table3(11,5*ii-2)=mean(numOfMovesF2(numOfMovesFlabel2==2));
        table3(11,5*ii-1)=var(numOfMovesF2(numOfMovesFlabel2==2));
        [p,antable,stats]= anova1(numOfMovesF2,numOfMovesFlabel2,'off');
        table3(11,5*ii) =p;
    end
    if ~isempty(durationRF2)
        % average oRF intensity over bouts:
        table3(3,5*ii-4)=mean(intensityRF2(intensityRFlabel2==1));
        table3(3,5*ii-3)=var(intensityRF2(intensityRFlabel2==1));
        table3(3,5*ii-2)=mean(intensityRF2(intensityRFlabel2==2));
        table3(3,5*ii-1)=var(intensityRF2(intensityRFlabel2==2));
        [p,antable,stats]= anova1(intensityRF2,intensityRFlabel2,'off');
        table3(3,5*ii) =p;
        
        % average of bouts duration
        table3(6,5*ii-4)=mean(durationRF2(durationRFlabel2==1));
        table3(6,5*ii-3)=var(durationRF2(durationRFlabel2==1));
        table3(6,5*ii-2)=mean(durationRF2(durationRFlabel2==2));
        table3(6,5*ii-1)=var(durationRF2(durationRFlabel2==2));
        [p,antable,stats]= anova1(durationRF2,durationRFlabel2,'off');
        table3(6,5*ii) =p;
        
        % average of latency
        table3(9,5*ii-4)=mean(temporalDistanceRF2(temporalDistanceRFlabel2==1));
        table3(9,5*ii-3)=var(temporalDistanceRF2(temporalDistanceRFlabel2==1));
        table3(9,5*ii-2)=mean(temporalDistanceRF2(temporalDistanceRFlabel2==2));
        table3(9,5*ii-1)=var(temporalDistanceRF2(temporalDistanceRFlabel2==2));
        [p,antable,stats]= anova1(temporalDistanceRF2,temporalDistanceRFlabel2,'off');
        table3(9,5*ii) =p;
        
        % average of number of moves per bout
        table3(12,5*ii-4)=mean(numOfMovesRF2(numOfMovesRFlabel2==1));
        table3(12,5*ii-3)=var(numOfMovesRF2(numOfMovesRFlabel2==1));
        table3(12,5*ii-2)=mean(numOfMovesRF2(numOfMovesRFlabel2==2));
        table3(12,5*ii-1)=var(numOfMovesRF2(numOfMovesRFlabel2==2));
        [p,antable,stats]= anova1(numOfMovesRF2,numOfMovesRFlabel2,'off');
        table3(12,5*ii) =p;
    end
end
kinectTables = {table, table1, table2, table3, table4, table5};
cd(rootPath);
cd(strcat(rootPath,filesep,'results'));
save('kinectTables','kinectTables');

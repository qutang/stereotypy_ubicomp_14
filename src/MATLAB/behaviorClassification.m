%% function results=behaviorClassification(behaviorClassificationParameters,featureVectorAndLabels)
%  This function gets feature vector and labels applies LibSVM classifier
%  on data based on the input libSVM parameters which are defined in the
%  stereotypyParameters files.
%
% Inputs:
%       - behaviorClassificationParameters
%           .LibSVMparameters- for defining kernel type and so on.
%           .saveFlag- (1) for saving results
%           .featureVectorType- can be 'stockwell'or 'combined'
%
%       - featureVectorAndLabels
%
% Outputs:
%       - results.accuracy- results of 10 fold CV performance accuracy
%       - results.Precision
%       - results.Recall
%       - results.tpR
%       - results.tnR
%       - results.fpR
%       - results.fnR
%       - results.dataPointsInEachClass
%
% See also featureExtraction, stereotypyParameters,..
%%
function [results,model]=behaviorClassification(behaviorClassificationParameters,featureVectorAndLabels)
% choose feature vector type
if strcmp(behaviorClassificationParameters.featureVectorType,'combined')
    fv=featureVectorAndLabels.fvNew;
elseif strcmp(behaviorClassificationParameters.featureVectorType,'baseline')
    fv=featureVectorAndLabels.fvNew(:,451:end);
else
    fv=featureVectorAndLabels.fv;
end
% Labelvec=featureVectorAndLabels.Labelvec;
fv=normc(fv); % normalizing each dimension

% choose label vector type
if strcmp(behaviorClassificationParameters.labelTypeForClassification,'video')
    Labelvec=featureVectorAndLabels.videoLabelvec;
elseif  strcmp(behaviorClassificationParameters.labelTypeForClassification,'phone')
    Labelvec=featureVectorAndLabels.phoneLabelvec;
elseif strcmp(behaviorClassificationParameters.labelTypeForClassification,'agreement')
    
elseif strcmp(behaviorClassificationParameters.labelTypeForClassification,'disagreement')
    
end

% random premutation of data
randNdx=randperm(length(Labelvec));
fv=fv(randNdx,:);
Labelvec=Labelvec(randNdx);
%% temp analysis for low vs high, med and donig nothig class
% tempLabels=featureVectorAndLabels.intesityLabels;
% tempLabels(find(rightLabel1==0))=1;rightLabelvec(find(rightLabel1==400))=2;
% Labelvec=featureVectorAndLabels.Labelvec;
%%
% Counting number of data points in each class before resampling for balancing
rockClassNdx=(find(Labelvec==2));  %'rock'
uknownClassNdx=(find(Labelvec==1));    %'uknown'
rockflapClassNdx=(find(Labelvec==3));   %'rock-flap'
flapClassNdx=(find(Labelvec==4));   %'flap'
dataPointsInEachClass.rockClassNumPoints=length(rockClassNdx);  %'rock'
dataPointsInEachClass.uknownClassNumPoints=length(uknownClassNdx);    %'uknown'
dataPointsInEachClass.rockflapClassNumPoints=length(rockflapClassNdx);   %'rock-flap'
dataPointsInEachClass.flapClassNumPoints=length(flapClassNdx);   %'flap'
% disp('Ready for CV');
%% Cross-Validation using LibSVM with RBF kernel
% We have four class of "Unknown", "rocking", "flaprock", "flapping"
% % Scaling ?
% m=max(abs(fv(1:end-5,:)));
% m=max(m);
% fvn=fv(1:end-5,:)./m;
% i=0;j=0;
% for pg=-5:2:15
%     gamma=2^pg;
%     i=i+1;
%     for pc=-15:2:3
%         c=2^pc;
%         j=j+1;
%         %         op=['-s 1','-t 2','-g num2str(gamma)','-c num2str(c)',''];
%         op =['-c ' num2str(c) ' -g ' num2str(gamma) ' -v 10'];
%         %           cst=['-c ' num2str(2^c(i)) ' -g ' num2str(2^g(j)) ' -v 10']
%         acr(i,j) = svmtrain(Labelvec(1:end-5),fvn,op);
%     end
% end
% % pcolor(g,c,acr)
% % max(max(acr)')
%% Cross-Validation using LibSVM with Linear kernel
% LibSVMparameters =['-t 0 -v 10 -h 0'];
% size of libsvm input fv and labels shoud be just 10 multiplier so;
size10mul=size(fv,1)-mod(size(fv,1),10);  % for 10-fold cross validation
fv=fv(1:size10mul,:);
Labelvec=Labelvec(1:size10mul);
maxElement=max(max(fv));
fvNormalized=fv./maxElement;
% fvNormalized=fv;
if strcmp(behaviorClassificationParameters.labelTypeForClassification,'video')
    if behaviorClassificationParameters.onlyLearnModel
        %     model = svmtrain(Labelvec,fvNormalized,behaviorClassificationParameters.LibSVMparameters);
        model = train(Labelvec,sparse(fvNormalized),behaviorClassificationParameters.Liblinearparameters);  %liblinear
        results=[];
        % following function can be used for calculation of just accuracy not
        % tp,fp,...
        %   accuracy = svmtrain(Labelvec(1:size10mul),fvNormalized,behaviorClassificationParameters.LibSVMparameters);
        %   results=accuracy;
    else
        
        ac=0;
        tp=0;
        fp=0;
        fn=0;
        tn=0;
        randInd=randperm(size10mul);
        foldSize=size10mul/10;
        for i=1:foldSize:size10mul
            testInd= randInd(i:i+foldSize-1);
            trainData=fvNormalized;
            trainLabel=Labelvec;
            trainData(testInd,:)=[];
            trainLabel(testInd)=[];
            if behaviorClassificationParameters.trainingSetBalancingEnable
                % Counting number of data points in each class before resampling for balancing
                rockClassNdx=(find(trainLabel==2));  %'rock'
                uknownClassNdx=(find(trainLabel==1));    %'uknown'
                rockflapClassNdx=(find(trainLabel==3));   %'rock-flap'
                flapClassNdx=(find(trainLabel==4));   %'flap'
                
                % balancing number of samples in each class to give to the classifier
                % 1. find maximum number of samples in stereotypical classes
                %             targetNumOfSamplesInEachClass=max([length(rockClassNdx),length(rockflapClassNdx),length(flapClassNdx)]);
                % or: according to fahd's code total number of samples/
                targetNumOfSamplesInEachClass=floor(length(trainLabel)/length(unique(trainLabel)));
                
                
                % 2. randomly resampling two other class with less number of data
                % points to targetNumOfSamplesInEachClass
                if 0<length(rockClassNdx)&& length(rockClassNdx)<targetNumOfSamplesInEachClass
                    requiredSamplesLength=targetNumOfSamplesInEachClass-length(rockClassNdx);
                    if requiredSamplesLength <= length(rockClassNdx)
                        requiredSamples = randsample(rockClassNdx,requiredSamplesLength);
                    else
                        requiredSamples = datasample(rockClassNdx,requiredSamplesLength);
                    end
                    balancedFvRock=[trainData(rockClassNdx,:);trainData(requiredSamples,:)];
                elseif 0<length(rockClassNdx)&& length(rockClassNdx)>targetNumOfSamplesInEachClass
                    rockSubsampleNdx = randsample(rockClassNdx,targetNumOfSamplesInEachClass);
                    balancedFvRock=trainData(rockSubsampleNdx,:);
                else
                    balancedFvRock=trainData(rockClassNdx,:);
                end
                if 0<length(flapClassNdx)&& length(flapClassNdx)<targetNumOfSamplesInEachClass
                    requiredSamplesLength=targetNumOfSamplesInEachClass-length(flapClassNdx);
                    if requiredSamplesLength <= length(flapClassNdx)
                        requiredSamples = randsample(flapClassNdx,requiredSamplesLength);
                    else
                        requiredSamples = datasample(flapClassNdx,requiredSamplesLength);
                    end
                    balancedFvFlap=[trainData(flapClassNdx,:);trainData(requiredSamples,:)];
                elseif 0<length(flapClassNdx)&& length(flapClassNdx)>targetNumOfSamplesInEachClass
                    flapSubsampleNdx = randsample(flapClassNdx,targetNumOfSamplesInEachClass);
                    balancedFvFlap=trainData(flapSubsampleNdx,:);
                else
                    balancedFvFlap=trainData(flapClassNdx,:);
                end
                
                if 0<length(rockflapClassNdx) && length(rockflapClassNdx)<targetNumOfSamplesInEachClass
                    requiredSamplesLength=targetNumOfSamplesInEachClass-length(rockflapClassNdx);
                    if requiredSamplesLength <= length(rockflapClassNdx)
                        requiredSamples = randsample(rockflapClassNdx,requiredSamplesLength);
                    else
                        requiredSamples = datasample(rockflapClassNdx,requiredSamplesLength);
                    end
                    balancedFvRockFlap=[trainData(rockflapClassNdx,:);trainData(requiredSamples,:)];
                elseif 0<length(rockflapClassNdx)&& length(rockflapClassNdx)>targetNumOfSamplesInEachClass
                    rockflapSubsampleNdx = randsample(rockflapClassNdx,targetNumOfSamplesInEachClass);
                    balancedFvRockFlap=trainData(rockflapSubsampleNdx,:);
                else
                    balancedFvRockFlap=trainData(rockflapClassNdx,:);
                end
                % 3. randomly subsampling of unknown class
                %             if length(uknownClassNdx)>targetNumOfSamplesInEachClass
                %                 UknownSubsampleNdx = randsample(uknownClassNdx,targetNumOfSamplesInEachClass);
                %             else
                %                 UknownSubsampleNdx = datasample(uknownClassNdx,targetNumOfSamplesInEachClass);
                %             end
                %             balancedFvUnknown=fv(UknownSubsampleNdx,:);
                if 0<length(uknownClassNdx) && length(uknownClassNdx)<targetNumOfSamplesInEachClass
                    requiredSamplesLength=targetNumOfSamplesInEachClass-length(uknownClassNdx);
                    if requiredSamplesLength <= length(uknownClassNdx)
                        requiredSamples = randsample(uknownClassNdx,requiredSamplesLength);
                    else
                        requiredSamples = datasample(uknownClassNdx,requiredSamplesLength);
                    end
                    balancedFvUnknown=[trainData(uknownClassNdx,:);trainData(requiredSamples,:)];
                elseif 0<length(uknownClassNdx)&& length(uknownClassNdx)>targetNumOfSamplesInEachClass
                    UknownSubsampleNdx = randsample(uknownClassNdx,targetNumOfSamplesInEachClass);
                    balancedFvUnknown=trainData(UknownSubsampleNdx,:);
                else
                    balancedFvUnknown=trainData(uknownClassNdx,:);
                end
                
                fvBalanced=[balancedFvRock;balancedFvFlap;balancedFvRockFlap;balancedFvUnknown];
                labelVecBalanced=[2*ones(1,size(balancedFvRock,1)) 4*ones(1,size(balancedFvFlap,1)) 3*ones(1,size(balancedFvRockFlap,1)) ones(1,size(balancedFvUnknown,1))];
                
                randNdx=randperm(length(labelVecBalanced));
                fvBalanced=fvBalanced(randNdx,:);
                labelVecBalanced=labelVecBalanced(randNdx);
                
                trainData=fvBalanced;
                trainLabel=labelVecBalanced';
            else
                randNdx=randperm(length(trainLabel));
                trainData=trainData(randNdx,:);
                trainLabel=trainLabel(randNdx);
            end
            %         model1 = svmtrain(trainLabel,trainData,behaviorClassificationParameters.LibSVMparameters);
            model1 = train(trainLabel,sparse(trainData),behaviorClassificationParameters.Liblinearparameters);  %liblinear
            testData=fvNormalized(testInd,:);
            testLabel=Labelvec(testInd);
            %         [predictLabel, a, prob_values] = svmpredict(testLabel, testData, model1); % run the SVM model on the test data
            [predictLabel, a, prob_values] = predict(testLabel,sparse(testData), model1); % run the SVM model on the test data
            ac = ac + sum(testLabel==predictLabel);
            tp=tp+length(find(predictLabel~=1&testLabel~=1));
            % fpNum=fpNum+length(find(testLabel~=1&predictLabel~=testLabel));
            fp=fp+length(find(testLabel==1&predictLabel~=testLabel));
            % tnNum=tnNum+length(find(testLabel==1&predictLabel==testLabel));
            tn=tn+length(find(predictLabel==1&predictLabel==testLabel));
            % fnNum=fnNum+length(find(testLabel==1&predictLabel~=testLabel));
            fn=fn+length(find(predictLabel==1&predictLabel~=testLabel));
        end
        results.accuracy = ac / size10mul;
        tpR=tp/sum(Labelvec~=1);
        fpR=fp/sum(Labelvec==1);
        tnR=tn/sum(Labelvec==1);
        fnR=fn/sum(Labelvec~=1);
        % Precision = true_positive / (true_positive + false_positive)
        results.Precision=tp/(tp+fp);
        % Recall = true_positive / (true_positive + false_negative)
        results.Recall=tp/(tp+fn);
        
        results.tpR=tpR;
        results.fpR=fpR;
        results.tnR=tnR;
        results.fnR=fnR;
        % results.accuracy2=(tp+tn)/(tp+fn+fp+tn);
        % p=tp+fn
        % p1=sum(Labelvec~=1)
        % n=fp+tn
        % n1=sum(Labelvec==1)
        % results.accuracy2=(tp+tn)/size10mul;
        % % acr = svmtrain(Labelvec(1:end-3,1:3),fv(1:end-3,:),LibSVMparameters);
        % % pcolor(g,c,acr)
        % %
        % % model = svmtrain(training_label_vector, training_feature_vector,'-t 0 -c 10');
        % % [predicted_label, accuracy, decision_values] = svmpredict(testing_label_vector, testing_feature_vector, model);
        results.dataPointsInEachClass=dataPointsInEachClass;
        model=[];
    end
elseif strcmp(behaviorClassificationParameters.labelTypeForClassification,'phone')
    if behaviorClassificationParameters.onlyLearnModel
        %     model = svmtrain(Labelvec,fvNormalized,behaviorClassificationParameters.LibSVMparameters);
        model = train(Labelvec,sparse(fvNormalized),behaviorClassificationParameters.Liblinearparameters);  %liblinear
        results=[];
        % following function can be used for calculation of just accuracy not
        % tp,fp,...
        %   accuracy = svmtrain(Labelvec(1:size10mul),fvNormalized,behaviorClassificationParameters.LibSVMparameters);
        %   results=accuracy;
    else
        model = train(Labelvec,sparse(fvNormalized),behaviorClassificationParameters.Liblinearparameters);  %liblinear

            testData=fvNormalized;
            testLabel=featureVectorAndLabels.videoLabelvec(1:size10mul);
            %         [predictLabel, a, prob_values] = svmpredict(testLabel, testData, model1); % run the SVM model on the test data
            [predictLabel, a, prob_values] = predict(testLabel,sparse(fvNormalized), model); % run the SVM model on the test data
           results.accuracy=a;
    end
end

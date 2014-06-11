# run validation and summarize results in a dataframe for input dataset
# rm(list=ls())

# function to do cross validation
stereotypy_cross_validation = function(data, model_type="J48", nfold=10, iter=1,
                                       balanced=TRUE, rand=TRUE, seed=1, metrics=1:3){
    source("src/R/utils/train_model.stereotypy.R", local=TRUE)
    source("src/R/utils/normalize_dataset.stereotypy.R", local=TRUE)
    require("foreach")
    require("caret")
    require("RWeka")
    
    # iteration
    iters = 1:iter
    data = na.omit(data)
    data$LABEL = factor(data$LABEL, levels = STEREOTYPY_LEVELS)
    data$SEGMENT = NULL
    print("start normalizing data")
    fold_data = normalize_dataset(data)
    rm(data)
    size_data = nrow(fold_data)
    print(size_data)
    nfolds = 1:nfold
    size_test = ceiling(size_data/nfold)
    set.seed(seed)
    
    overall_result = foreach(i=iters) %do% {
        print(paste("Iter",i))
        # randomize data

        if(rand){
            perm = sample(size_data)
            fold_data = fold_data[perm,]
        }
        fold_predict = foreach(n=nfolds) %do% {
            # index for testing
            test_inds = seq(1+size_test*(n-1),min(size_test*n, size_data))
#             print(length(test_inds))
            # training set
            training_set = fold_data[-test_inds,]
            size_fold = nrow(training_set)
            # testing set
            testing_set = fold_data[test_inds,]
            # balance training set
            if(balanced){
#                 print(table(training_set$LABEL))
                balance_filter = make_Weka_filter("weka.filters.supervised.instance.Resample")
                training_set = balance_filter(formula=LABEL~., data=training_set, control=Weka_control(S=1, Z=100, B=1))
#                 print(table(balanced_train$LABEL))
            }
            # fit model
            model = stereotypy_train_model(training_set, model_type)
            # result
            predict_labels = as.character(predict(model, newdata=testing_set))
            return(predict_labels)
        }
        fold_predict = do.call(c, fold_predict)
        fold_test = as.character(fold_data$LABEL)
        l = union(unique(fold_predict), unique(fold_test))
        fold_test = factor(fold_test, levels=l)
        fold_predict = factor(fold_predict, levels=l)
        print(table(fold_predict))
        print(table(fold_test))
        
        fold_stats = confusionMatrix(fold_predict, fold_test)
        fold_result = list(fold_predict=as.character(fold_predict), fold_test=as.character(fold_test),fold_stats=fold_stats, fold_perm=perm)
        return(fold_result)
    }
    print("concating...")
    # concate the whole thing
    overall_predict = foreach(result=overall_result, .combine='c') %do% {
        return(result$fold_predict)
    }
    two_class_overall_predict = overall_predict
    overall_test = foreach(result=overall_result, .combine='c') %do% {
        return(result$fold_test)
    }

    # prepare prediction dataframe
    prediction_df = foreach(result=overall_result, .combine='list') %do% {
        result = data.frame(PERMUTATION=result$fold_perm, PREDICTION=result$fold_predict, TRUTH=result$fold_test)
        return(result)
    }

    two_class_overall_test =overall_test
    l = union(unique(overall_test), unique(overall_predict))
    overall_test = factor(overall_test, levels = l)
    overall_predict = factor(overall_predict, levels=l)
    print(table(overall_test))
    print(table(overall_predict))
    
    fold_stats = foreach(result=overall_result) %do% {
        return(result$fold_stats)
    }
    
    per_class_overall_stats = confusionMatrix(overall_predict, overall_test)
    sample_proportion = colSums(per_class_overall_stats$table)
    per_class_overall_stats$table = per_class_overall_stats$table/sum(per_class_overall_stats$table)

    # average stats for per class stats
    if(class(per_class_overall_stats$byClass) == "numeric"){
        per_class_average_overall_stats = data.frame(per_class_overall_stats$byClass)
    }else{
        per_class_average_overall_stats = data.frame(colMeans(per_class_overall_stats$byClass))
    }
    
    
    # two class performance
    two_class_overall_predict[two_class_overall_predict != "Others"] = "Movement"
    
    two_class_overall_test[two_class_overall_test != "Others"] = "Movement"
    two_class_overall_test = factor(two_class_overall_test)
    two_class_overall_predict = factor(two_class_overall_predict, levels=levels(two_class_overall_test))
    two_class_overall_stats = confusionMatrix(two_class_overall_predict, two_class_overall_test, positive="Movement")

    # customized way to compute the results
    customized_metrics = foreach(metric=metrics) %do% {
        result = as.data.frame(t(stereotypy_customized_metrics(overall_predict, overall_test, negative="Others", method=metric)))
    }
    
    # 

    output_result = list(two_class_overall_stats = two_class_overall_stats, 
                         per_class_overall_stats=per_class_overall_stats, 
                         per_class_average_overall_stats= per_class_average_overall_stats, 
                         customized_metrics = customized_metrics, 
                         fold_stats = fold_stats, 
                         sample_proportion = sample_proportion,
                         prediction_df = prediction_df)
    return(output_result)
}

stereotypy_train_test = function(train_data, test_data, model_type="J48", iter=1
                                 , balanced=TRUE, rand=TRUE, seed=1, metrics=1:3){
    source("src/R/utils/train_model.stereotypy.R", local=TRUE)
    source("src/R/utils/normalize_dataset.stereotypy.R", local=TRUE)
    require("foreach")
    require("caret")
    require("RWeka")
    
    # iteration
    iters = 1:iter
    train_data = na.omit(train_data)
    test_data = na.omit(test_data)
    gc()
    train_data$SEGMENT = NULL
    test_data$SEGMENT = NULL
    
    # normalize
    train_data = normalize_dataset(train_data)
    test_data = normalize_dataset(test_data)
    gc()
    size_train_data = nrow(train_data)
    size_test_data = nrow(test_data)
    print(size_train_data)
    print(size_test_data)
    set.seed(seed)

    train_data$LABEL = factor(train_data$LABEL, levels=STEREOTYPY_LEVELS)
    test_data$LABEL = factor(test_data$LABEL, levels=STEREOTYPY_LEVELS)
    
    overall_result = foreach(i=iters) %do% {
        print(paste("Iter",i))
        # randomize data
        
        if(rand){
            iter_train_data = train_data[sample(size_train_data),]
        }else{
            iter_train_data= train_data
        }
        rm(train_data)
        gc()
        print("Finish random")
        if(balanced){
            #                 print(table(training_set$LABEL))
            balance_filter = make_Weka_filter("weka.filters.supervised.instance.Resample")
            training_set = balance_filter(formula=LABEL~., data=iter_train_data, control=Weka_control(S=1, Z=100, B=1))
            rm(iter_train_data)
            gc()
            
            #                 print(table(balanced_train$LABEL))
        }
        testing_set = test_data
        rm(test_data)
        gc()
        print("Finish balancing")
        # fit model
        model = stereotypy_train_model(training_set, model_type)
        rm(training_set)
        gc()
        print("Finish fitting")
        # result
        predict_labels = as.character(predict(model, newdata=testing_set))
        testing_labels = as.character(testing_set$LABEL)
        print("Finish predicting")
        return(list(predict_labels=predict_labels, testing_labels=testing_labels))
    }
    print("Concolidating...")
    # concate the whole thing
    overall_predict = foreach(result=overall_result, .combine='c') %do% {
        return(result$predict_labels)
    }
    two_class_overall_predict = overall_predict
    
    
    overall_test = foreach(result=overall_result, .combine='c') %do% {
        return(result$testing_labels)
    }
    
    print(table(overall_predict))
    print(table(overall_test))
    
    two_class_overall_test =overall_test
    l = union(unique(overall_predict), unique(overall_test))
    overall_test = factor(overall_test, levels=l)
    overall_predict = factor(predict_labels, levels=l)
    
    per_class_overall_stats = confusionMatrix(overall_predict, overall_test)
    sample_proportion = colSums(per_class_overall_stats$table)
    per_class_overall_stats$table = per_class_overall_stats$table/sum(per_class_overall_stats$table)
    
    # average stats for per class stats
    if(class(per_class_overall_stats$byClass) == "numeric"){
        per_class_average_overall_stats = data.frame(per_class_overall_stats$byClass)
    }else{
        per_class_average_overall_stats = data.frame(colMeans(per_class_overall_stats$byClass))
    }
    
    
    # two class performance
    two_class_overall_predict[two_class_overall_predict != "Others"] = "Movement"
    
    two_class_overall_test[two_class_overall_test != "Others"] = "Movement"
    two_class_overall_test = factor(two_class_overall_test)
    two_class_overall_predict = factor(two_class_overall_predict, levels=levels(two_class_overall_test))
    two_class_overall_stats = confusionMatrix(two_class_overall_predict, two_class_overall_test, positive="Movement")
    
    # customized way to compute the results
    
    customized_metrics = foreach(metric=metrics) %do% {
        as.data.frame(t(stereotypy_customized_metrics(overall_predict, overall_test, negative="Others", method=metric)))
    }
    # 
    
    output_result = list(two_class_overall_stats = two_class_overall_stats, per_class_overall_stats=per_class_overall_stats, per_class_average_overall_stats= per_class_average_overall_stats, customized_metrics = customized_metrics, sample_proportion = sample_proportion)
    return(output_result)
}

# function to do LOSO validation: leave one session out
stereotypy_loso_validation = function(data, model_type="J48",iter=1,
                                       balanced=TRUE, rand=TRUE, seed=1, metrics=1:3){
    source("src/R/utils/train_model.stereotypy.R", local=TRUE)
    source("src/R/utils/normalize_dataset.stereotypy.R", local=TRUE)
    require("foreach")
    require("sampling")
    require("caret")
    require("RWeka")
    
    # iteration
    iters = 1:iter
    nfolds = 1:length(data)
#     print(summary(data))
    if(length(data) == 1){
        return(stereotypy_cross_validation(data[[1]]))
    }
    
    overall_result = foreach(i=iters) %do% {
#         print(paste("Iter",i))
        # randomize data
        
        fold_result = foreach(n=nfolds, .combine="rbind") %do% {
#             print(n)
            # testing set
            testing_set = data[[n]]
            size_fold = nrow(testing_set)
#             print(summary(testing_set))
            # training set
            training_set = foreach(d=data[-n],.combine="rbind") %do% return(d)
            
            size_train = nrow(training_set)
#              print(summary(training_set))
            
            training_set = na.omit(training_set)
            testing_set = na.omit(testing_set)
            
            training_set$SEGMENT = NULL
            testing_set$SEGMENT = NULL
            # normalize
            training_set = normalize_dataset(training_set)
            testing_set = normalize_dataset(testing_set)
            set.seed(seed)
            
            training_set$LABEL = factor(training_set$LABEL, levels=STEREOTYPY_LEVELS)
            testing_set$LABEL = factor(testing_set$LABEL, levels=STEREOTYPY_LEVELS)
            
            # randomize training data
            if(rand){
                training_set = training_set[sample(size_train),]
            }
            print("finish random")
            # balance training set
            if(balanced){
#                                 print(table(training_set$LABEL))
                balance_filter = make_Weka_filter("weka.filters.supervised.instance.Resample")
                training_set = balance_filter(formula=LABEL~., data=training_set, control=Weka_control(S=1, Z=100, B=1))
#                                 print(table(training_set$LABEL))
            }
            print("finish blancing")
            # fit model
            test <<- training_set
            model = stereotypy_train_model(training_set, model_type)
      
            print("finish training")
            # result
            predict_labels = as.character(predict(model, newdata=testing_set))
            test_labels = as.character(testing_set$LABEL)
            fold_result = cbind(predict_labels, test_labels)
            print("finish testing")
            return(fold_result)
        }
        print(summary(fold_result))
        fold_predict = fold_result[,1]
        fold_test = fold_result[,2]
        print(summary(fold_test))
        print(summary(fold_predict))
        l = union(unique(fold_predict), unique(fold_test))
        print(l)
        fold_test = factor(fold_test, levels=l)
        fold_predict = factor(fold_predict, levels=l)
        print(table(fold_predict))
        print(table(fold_test))
        
        fold_stats = confusionMatrix(fold_predict, fold_test)
        fold_result = list(fold_predict=as.character(fold_predict), fold_test=as.character(fold_test),fold_stats=fold_stats)
        return(fold_result)
    }
    print("concating...")
    # concate the whole thing
    overall_predict = foreach(result=overall_result, .combine='c') %do% {
        return(result$fold_predict)
    }
    two_class_overall_predict = overall_predict
    
    
    overall_test = foreach(result=overall_result, .combine='c') %do% {
        return(result$fold_test)
    }
    two_class_overall_test =overall_test
    l = union(unique(overall_test), unique(overall_predict))
    overall_test = factor(overall_test, levels = l)
    overall_predict = factor(overall_predict, levels=l)
    print(table(overall_test))
    print(table(overall_predict))
    
    fold_stats = foreach(result=overall_result) %do% {
        return(result$fold_stats)
    }
    
    per_class_overall_stats = confusionMatrix(overall_predict, overall_test)
    sample_proportion = colSums(per_class_overall_stats$table)
    per_class_overall_stats$table = per_class_overall_stats$table/sum(per_class_overall_stats$table)
    print("per_class")
    # average stats for per class stats
    if(class(per_class_overall_stats$byClass) == "numeric"){
        per_class_average_overall_stats = data.frame(per_class_overall_stats$byClass)
    }else{
        per_class_average_overall_stats = data.frame(colMeans(per_class_overall_stats$byClass))
    }
    print("per_class_average")
    
    # two class performance
    two_class_overall_predict[two_class_overall_predict != "Others"] = "Movement"
    
    two_class_overall_test[two_class_overall_test != "Others"] = "Movement"
    two_class_overall_test = factor(two_class_overall_test)
    two_class_overall_predict = factor(two_class_overall_predict, levels=levels(two_class_overall_test))
    two_class_overall_stats = confusionMatrix(two_class_overall_predict, two_class_overall_test, positive="Movement")
    print("two_class")
    # customized way to compute the results
    customized_metrics = foreach(metric=metrics) %do% {
        result = as.data.frame(t(stereotypy_customized_metrics(overall_predict, overall_test, negative="Others", method=metric)))
        result[,"NumOfSessions"]=length(data)
        return(result)
    }
    print("custom")
    
    output_result = list(two_class_overall_stats = two_class_overall_stats, per_class_overall_stats=per_class_overall_stats, per_class_average_overall_stats= per_class_average_overall_stats, customized_metrics = customized_metrics, fold_stats = fold_stats, sample_proportion = sample_proportion)
    print("done")
    return(output_result)
}

# function to do LOSO validation: leave one subject out, no average
stereotypy_loso2_validation = function(data, subj, model_type = "J48", iter=1, balanced=TRUE, rand=TRUE, seed=1, metrics=1:3){
  require("foreach")
  training_set = foreach(single_session=whole_sessions, .combine="rbind") %do% {
    if(single_session$subject != subj){
      print(paste(single_session$subject, "for training"))
      return(single_session$dataset)
    }else{
      return(NULL)
    }
  }
  
  testing_set = foreach(single_session=whole_sessions, .combine="rbind") %do% {
    if(single_session$subject == subj){
      print(paste(single_session$subject, "for testing"))
      return(single_session$dataset)
    }else{
      return(NULL)
    }
  }
  subj_result = stereotypy_train_test(train_data=training_set, test_data=testing_set, model_type=model_type, iter=iter, balanced=balanced, rand=rand, seed=seed, metrics=metrics)
  return(subj_result)
}

stereotypy_customized_metrics = function(overall_predict, overall_test, negative="Others", method=1){
    class_names = levels(overall_test)
    pos_class = setdiff(class_names, negative)
    neg_class = negative
    total = length(overall_test)
    
    calculate_metrics = function(tp, fp, tn, fn, total){
        # accuracy
        accuracy = (tp + tn) / total
        # precision or positive predictive value(PPV)
        precision = tp / (tp + fp)
        # recall or sensitivity or true positive rate (TPR)
        recall = tp / (tp + fn)
        # specificity or true negative rate (TNR)
        spec = tn / (tn + fp)
        # negative predictive value (NPV)
        npv = tn / (tn + fn)
        # false positive rate or fall-out
        fpr = fp / (fp + tn)
        # f1-score
        f1 = 2*tp / (2*tp + fp + fn)
        result = data.frame("Accuracy"=accuracy,  "TPR"=recall, "FPR"=fpr, "Precision"=precision, "TNR"=spec, "F1Score"=f1)
        return(result)
    }
    
    
    if(method == 2){
        tp = 0
        for(pos in pos_class){
            tp = tp + sum(overall_predict == pos & overall_test == pos)
        }
        tn = sum(overall_predict == neg_class & overall_test == neg_class)
        fp = sum(overall_test == neg_class & overall_predict != neg_class)
        fn = sum(overall_test != neg_class & overall_predict == neg_class)
        result = calculate_metrics(tp, fp, tn, fn, total)
    }else if(method == 3){
        tp = sum(overall_predict != neg_class & overall_test != neg_class)
        fp = sum(overall_test == neg_class & overall_predict != overall_test)
        tn = sum(overall_predict == neg_class & overall_test == overall_predict)
        fn = sum(overall_predict == neg_class & overall_predict != overall_test)
        result = calculate_metrics(tp, fp, tn, fn, total)
    }else if(method == 1){
        result = foreach(class_name=class_names, .combine="rbind") %do% {
            tp = sum(overall_predict == class_name & overall_test == class_name)
            fp = sum(overall_predict == class_name & overall_predict != overall_test)
            tn = sum(overall_predict != class_name & overall_test != class_name)
            fn = sum(overall_test == class_name & overall_predict != overall_test)
            r = calculate_metrics(tp, fp, tn, fn, total)
            return(r)
        }
    }
    result = colMeans(result, na.rm=TRUE)
    return(result)
}

# test codes

# source(file="Stereotypy//import_sessions.stereotypy.R")
# source(file="Stereotypy/get_segments.stereotypy.R")
# source(file="Stereotypy//get_feature_set.stereotypy.R")
# source(file="Stereotypy//train_model.stereotypy.R")
# session = choose.dir(default = "C:\\Users\\Qu\\Documents\\Stereotypy Data\\", caption = "Select Session")
# study_type = ifelse(test=grepl(pattern="1", x=basename(dirname(session)),perl=TRUE), yes=1, no=2)
# session.bundle = stereotypy_import_session(session,study_type)
# 
# session.bundle = stereotypy_get_segments(session.bundle, 1, 0.5)
# 
# feature_list = c("var","max_freq","entropy","meandist", "corcoef")
# session.bundle = stereotypy_get_feature_set(session.bundle, feature_list, b=FALSE)
# 
# label_matrix = session.bundle$label_matrix
# 
# annotator = "Annotator1Stereotypy"
# # annotator = "Phone"
# labels = label_matrix[[which(session.bundle$annotator == annotator)]]
# dataset = merge(session.bundle$feature_matrix, labels, by=SEGMENT_COL_NAME)
# 
# result = stereotypy_cross_validation(dataset)
# print(result)

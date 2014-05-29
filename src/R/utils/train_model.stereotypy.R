# rm(list=ls())
# train a classification model with given input training set
stereotypy_train_model = function(training_set, model_type="J48"){
    require("RWeka")
    if(model_type == "J48"){
#         ctl = 
#         print(ctl)
        fitted_model = J48(LABEL ~ ., data=training_set, control=Weka_control(C=0.25, M=5))
#         print(fitted_model)
    }else{
        stop(paste(model_type, " not found"))
    }
    return(fitted_model)
}

# Test codes
# require("caret")
# source(file="Stereotypy//import_sessions.stereotypy.R")
# source(file="Stereotypy/get_segments.stereotypy.R")
# source(file="Stereotypy//get_feature_set.stereotypy.R")
# session = choose.dir(default = "C:\\Users\\Qu\\Documents\\Stereotypy Data\\", caption = "Select Session")
# study_type = ifelse(test=grepl(pattern="1", x=basename(dirname(session)),perl=TRUE), yes=1, no=2)
# session.bundle = stereotypy_import_session(session,study_type)
# 
# session.bundle = stereotypy_get_segments(session.bundle, 5, 0.5)
# 
# feature_list = c("max_freq",'var','entropy','corcoef','meandist')
# session.bundle = stereotypy_get_feature_set(session.bundle, feature_list)
# 
# label_matrix = session.bundle$label_matrix
# 
# annotator = "Annotator1Stereotypy"
# annotator = "Phone"
# labels = label_matrix[[which(session.bundle$annotator == annotator)]]
# dataset = merge(session.bundle$feature_matrix, labels, by=SEGMENT_COL_NAME)
# 
# N = nrow(dataset)
# 
# M = floor(N / 5)
# 
# training_set = dataset[1:(4*M),]
# testing_set = dataset[(4*M+1):N,]
# 
# tree = stereotypy_train_model(dataset)
# evaluate_Weka_classifier(tree, numFolds=10)
# 
# tree2 = stereotypy_train_model(training_set)
# test_result = predict(tree2, newdata=testing_set)
# confusionMatrix(data=test_result, reference=testing_set$LABEL)

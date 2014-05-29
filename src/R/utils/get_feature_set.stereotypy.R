# construct feature and label matrix for each session
stereotypy_get_feature_set = function(session.bundle, feature_list, b=FALSE){
    require("foreach")
    require("plyr")
    fconstructor = feature_constructor.init()
    for(f in feature_list){
        if(grepl(pattern="max_freq", x=f, ignore.case=TRUE)){
            fconstructor = feature_constructor.add(fconstructor,feature.fft.mHealth.bundle, "MAX_FREQ", n_max_frequencies=2)
        }else if(grepl(pattern="var", x=f, ignore.case=TRUE)){
            fconstructor = feature_constructor.add(fconstructor,feature.variance.mHealth.bundle, "var")
        }else if(grepl(pattern="entropy", x=f, ignore.case=TRUE)){
            fconstructor = feature_constructor.add(fconstructor,feature.entropy.mHealth.bundle, "entropy")
        }else if(grepl(pattern="cor", x=f, ignore.case=TRUE)){
            fconstructor = feature_constructor.add(fconstructor,feature.corcoef.mHealth.bundle, "corcoef")
        }else if(grepl(pattern="meandist", x=f, ignore.case=TRUE)){
            fconstructor = feature_constructor.add(fconstructor,feature.meandist.mHealth.bundle, "meandist")
        }
    }
   
    # compute features
    session.bundle = feature_constructor.run(fconstructor, session.bundle)
    session.bundle$feature_matrix[-1] = scale(session.bundle$feature_matrix[-1])
#     print(colMeans(session.bundle$feature_matrix[-1]))  # faster version of apply(scaled.dat, 2, mean)
#     print(apply(session.bundle$feature_matrix[-1], 2, sd))
#     stop()
    # get labels
    segmented_labels = session.bundle$annotation.data
    label_matrix = foreach(label=segmented_labels) %do% {
        if(b){
            label_matrix = ddply(label, SEGMENT_COL_NAME, summarize, LABEL=stereotypy_decide_label(LABEL, TRUE))
        }else{
            label_matrix = ddply(label, SEGMENT_COL_NAME, summarize, LABEL=stereotypy_decide_label(LABEL, FALSE))
        }
        label_matrix$LABEL = factor(label_matrix$LABEL)
        return(label_matrix)
    }
    session.bundle$label_matrix = label_matrix
    
    return(session.bundle)
}


stereotypy_decide_label = function(labels, b=FALSE){
    if(b){
        counts = c(sum(labels != 0), sum(labels == 0))
        marks = c("Movement", "Others")
    }else{
        counts = c(sum(labels == 400), sum(labels == 600), sum(labels == 800), sum(labels == 0))
        marks = c("Rock", "Rock-Flap", "Flap", "Others")
    }
    
    major = max(counts)
    minor = length(labels) - major
    result = ifelse(test=major/minor>=1, yes=marks[counts == major], no="Others")
    
    return(result)
}

# Test codes
# session = choose.dir(default = "C:\\Users\\Qu\\Documents\\Stereotypy Data\\", caption = "Select Session")
# study_type = ifelse(test=grepl(pattern="1", x=basename(dirname(session)),perl=TRUE), yes=1, no=2)
# session.bundle = stereotypy_import_session(session,study_type)
# 
# session.bundle = stereotypy_get_segments(session.bundle, 5, 0.5)
# 
# feature_list = c("var")
# session.bundle = stereotypy_get_feature_set(session.bundle, feature_list, b=TRUE)
# summary(session.bundle)
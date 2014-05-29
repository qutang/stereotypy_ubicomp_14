parseFeatureMatFile = function(feature_mat_file){
    require("R.matlab")
    feature_mat = readMat(feature_mat_file)
    stockwell_feature_matrix = data.frame(feature_mat[[1]][[1]])
    time_feature_matrix = data.frame(feature_mat[[1]][[3]][,-(1:450)])
    together_feature_matrix = data.frame(feature_mat[[1]][[3]])
    
    label = data.frame(feature_mat[[1]][[4]])
    colnames(label) = c("LABEL")
    label[label==1]= "Others"
    label[label==2]= "Rock"
    label[label==3]= "Rock-Flap"
    label[label==4]= "Flap"
    
    stockwell_feature_matrix = cbind(stockwell_feature_matrix, label)
    time_feature_matrix = cbind(time_feature_matrix, label)
    together_feature_matrix = cbind(together_feature_matrix, label)
    
    result = list(time=time_feature_matrix, stockwell=stockwell_feature_matrix, joint=together_feature_matrix)
    
    return(result)
}
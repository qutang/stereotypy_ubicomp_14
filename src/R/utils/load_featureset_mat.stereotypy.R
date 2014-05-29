load_featureset_mat = function(folder, filename){
    require("R.matlab")
    require("SOAR")
    filename = file.path(folder, filename)
    session_name = basename(folder)
    stockwell_name = paste(session_name, "stockwell", sep=".")
    together_name = paste(session_name, "combined", sep=".")
    time_name =  paste(session_name, "baseline", sep=".")
    video_name = paste(session_name, "label", "offline", sep=".")
    phone_name = paste(session_name, "label", "realtime", sep=".")
    
    if(any(grepl(pattern=session_name, x=Objects(),perl=TRUE))){
      print(paste("Already cached:", session_name))
    }else{
      data = readMat(filename)
      stockwell_feature_matrix = data.frame(data[[1]][[1]])
      time_feature_matrix = data.frame(data[[1]][[3]][,-(1:450)])
      together_feature_matrix = data.frame(data[[1]][[3]])
      
      videoLabel = data.frame(data[[1]][[4]])
      phoneLabel = data.frame(data[[1]][[5]])
      colnames(videoLabel) = c("LABEL")
      colnames(phoneLabel) = c("LABEL")   
      
      
      assign(stockwell_name, stockwell_feature_matrix)
      assign(together_name, together_feature_matrix)
      assign(time_name, time_feature_matrix)
      assign(video_name, videoLabel)
      assign(phone_name, phoneLabel)
      
      Store(as.character(stockwell_name))
      Store(as.character(together_name))
      Store(as.character(time_name))
      Store(as.character(video_name))
      Store(as.character(phone_name))
      
      print(paste("processed", session_name))
    }
}

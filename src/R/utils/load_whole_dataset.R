load_whole_dataset = function(session_folder, study_type, feature_type, label_type, exclude_sessions, .combine="list"){
  require("foreach")
  # Specify the filename pattern for the chosen subject
  if(study_type == 1){
    p = paste("URI-[0-9]{3}-[0-9]{2}-[0-9]{2}-08",sep="")
  }else{
    p = paste("[0-9]{3}-[0-9]{4}-[0-9]{2}-[0-9]{2}", sep="")
  }
  
  # Retrieve all matched sessions
  subj_sessions = list.files(path=session_folder, pattern=p, full.names=TRUE, ignore.case=TRUE, include.dirs=TRUE)
  subj_sessions = setdiff(subj_sessions, exclude_sessions)
  
  whole_sessions = foreach(session=subj_sessions) %do% {
    if(study_type == 1){
      subj = strsplit(basename(session), split="-")[[1]][2]
    }else{
      subj = strsplit(basename(session), split="-")[[1]][1]
    }
    if(check_cached_dataset(basename(session), feature_type, label_type)){
      print(paste("find cache:", session))
      single_dataset = load_cached_dataset(basename(session), dataset_type, label_type)
    }else{
      stop(paste("Can't find the cached dataset, please check the data folder of session:", basename(session)))
    }
    single_session = list(subject=subj, dataset=single_dataset)
    return(single_session)
  }
  
  return(whole_sessions)
}
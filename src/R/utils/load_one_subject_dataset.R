load_one_subject_dataset = function(session_folder, subj, study_type, feature_type, label_type, exclude_sessions){
  require("foreach")
  # Specify the filename pattern for the chosen subject
  if(study_type == 1){
    p = paste("URI-", subj, "-[0-9]{2}-[0-9]{2}-08",sep="")
  }else{
    p = paste(subj, "-[0-9]{4}-[0-9]{2}-[0-9]{2}", sep="")
  }
  
  # Retrieve all matched sessions
  subj_sessions = list.files(path=session_folder, pattern=p, full.names=TRUE, ignore.case=TRUE, include.dirs=TRUE)
  subj_sessions = setdiff(subj_sessions, exclude_sessions)
  
  print(subj_sessions)
  
  source("src/R/utils/load_cached_dataset.stereotypy.R")
  subj_dataset = foreach(session=subj_sessions) %do% {
    if(check_cached_dataset(basename(session), feature_type, label_type)){
      single_dataset = load_cached_dataset(basename(session), feature_type, label_type)
    }else{
      stop(paste("Can't find the cached dataset, please check the data folder of session:", basename(session)))
    }
    return(single_dataset)
  }
  print("loaded")
  return(subj_dataset)
}
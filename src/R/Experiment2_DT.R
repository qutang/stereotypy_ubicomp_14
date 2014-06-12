# Experement 2 Decision Tree version: Trained using participant-dependent data and offline 
# annotations from the classroom. Tested using 10 fold cross validation

Experiment2_DT = function(session_folder, subjs){
  study_type = ifelse(test=grepl(pattern="1", x=basename(session_folder),perl=TRUE), yes=1, no=2)
  annotator = "Annotator1Stereotypy"
  label_type = "offline"
  result_folder = file.path(getwd(), "results", "DT", "experiment2")
  dir.create(result_folder,recursive=TRUE, showWarnings=FALSE)

  #Specify sessions to be excluded because of the bad 
  exclude = list.files(path=session_folder, pattern="nothing", full.names=TRUE, ignore.case=TRUE, include.dirs=TRUE)

  source("src/R/utils/load_one_subject_dataset.R")
  source("src/R/utils/evaluation.stereotypy.R")
  source("src/R/utils/generate_metrics.R")
  
  experiment_time = format(Sys.time(), "%d%b%Y%H%M%S")
  
  subjs_chosen = subjs
  
  subj_counter = 0
  for(subj in subjs_chosen){
    subj_counter = subj_counter + 1
    print(paste("Evaluating", subj))
    # Run for baseline feature set
    subj_baseline = load_one_subject_dataset(session_folder, subj, study_type, feature_type="baseline", label_type, exclude_sessions=exclude)
    subj_baseline_dataset = subj_baseline$subj_dataset
    subj_baseline_sessions = subj_baseline$subj_sessions
    
    subj_baseline_dataset = do.call(rbind, subj_baseline_dataset)
    subj_baseline_result = stereotypy_cross_validation(subj_baseline_dataset)
    # Generate metric dataframe and export to csv
    result_filename = paste("baseline",paste("study", study_type, sep=""), experiment_time, "csv", sep=".")
    generate_metrics(filename=file.path(result_folder,result_filename), result=subj_baseline_result, metric_type=2, row_name=subj_counter)
    print(paste("baseline feature set evaluation is done"))
    rm(subj_baseline_dataset)
    # Sort prediction dataframe
    subj_baseline_dataset = subj_baseline$subj_dataset
    prediction_csv = subj_baseline_result$prediction_df
    prediction_csv = prediction_csv[with(prediction_csv, order(PERMUTATION)),]
    
    # Split into sessions, get prediction and save in csv/xml
    session_prediction = list()
    for(i in 1:length(subj_baseline_sessions)){
      session_name = basename(subj_baseline_sessions[i])
      session_length = nrow(subj_baseline_dataset[[i]])
      
      prediction_filename = paste("baseline",paste("study", study_type, sep=""), session_name,"prediction.csv", sep=".")
      session_prediction = prediction_csv[1:session_length,]
      prediction_csv = prediction_csv[-c(1:session_length),]
      write.table(session_prediction, file = file.path(result_folder,prediction_filename), append = FALSE, quote = FALSE, sep = ",", row.names = FALSE)
    }
    
    #### Run for stockwell feature set ====
    subj_stockwell = load_one_subject_dataset(session_folder, subj, study_type, feature_type="stockwell", label_type, exclude_sessions=exclude)
    subj_stockwell_dataset = subj_stockwell$subj_dataset
    subj_stockwell_sessions = subj_stockwell$subj_sessions
    
    subj_stockwell_dataset = do.call(rbind, subj_stockwell_dataset)
    subj_stockwell_result = stereotypy_cross_validation(subj_stockwell_dataset)
    # Generate metric dataframe and export to csv
    result_filename = paste("stockwell",paste("study", study_type, sep=""), experiment_time, "csv", sep=".")
    generate_metrics(filename=file.path(result_folder,result_filename), result=subj_stockwell_result, metric_type=2, row_name=subj_counter)
    print(paste("stockwell feature set evaluation is done"))
    rm(subj_stockwell_dataset)
    # Sort prediction dataframe
    subj_stockwell_dataset = subj_stockwell$subj_dataset
    prediction_csv = subj_stockwell_result$prediction_df
    prediction_csv = prediction_csv[with(prediction_csv, order(PERMUTATION)),]
    
    # Split into sessions, get prediction and save in csv/xml
    session_prediction = list()
    for(i in 1:length(subj_stockwell_sessions)){
      session_name = basename(subj_stockwell_sessions[i])
      session_length = nrow(subj_stockwell_dataset[[i]])
      
      prediction_filename = paste("stockwell",paste("study", study_type, sep=""), session_name,"prediction.csv", sep=".")
      session_prediction = prediction_csv[1:session_length,]
      prediction_csv = prediction_csv[-c(1:session_length),]
      write.table(session_prediction, file = file.path(result_folder,prediction_filename), append = FALSE, quote = FALSE, sep = ",", row.names = FALSE)
    }
    
    # Run for combined feature set ====
    subj_combined = load_one_subject_dataset(session_folder, subj, study_type, feature_type="combined", label_type, exclude_sessions=exclude)
    subj_combined_dataset = subj_combined$subj_dataset
    subj_combined_dataset = do.call(rbind, subj_combined_dataset)
    subj_combined_result = stereotypy_cross_validation(subj_combined_dataset)
    # Generate metric dataframe and export to csv
    result_filename = paste("combined",paste("study", study_type, sep=""), experiment_time, "csv", sep=".")
    generate_metrics(filename=file.path(result_folder,result_filename), result=subj_combined_result, metric_type=2, row_name=subj_counter)
    print(paste("combined feature set evaluation is done"))
    rm(subj_combined_dataset)
  } 
}

### ==========================================================
# Note that due to memory issue, please run each study seperately, it's better to restart R session to refresh the memory if you have less than 16GB memory
source("src/R/constants.R")
# # For study 1
Experiment2_DT(session_folder=study1_folder, subjs=subj_study)

# For study 2
# Experiment2_DT(session_folder=study2_folder, subjs=subj_study)

# Experement 1 Decision Tree version: Trained using participant-dependent data and offline 
# annotations from the classroom. Tested using leave-one-session-out.

Experiment1_DT = function(session_folder, subjs){
  study_type = ifelse(test=grepl(pattern="1", x=basename(session_folder),perl=TRUE), yes=1, no=2)
  annotator = "Annotator1Stereotypy"
  label_type = "offline"
  result_folder = file.path(getwd(), "results", "DT", "experiment1")
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
    subj_baseline_dataset = load_one_subject_dataset(session_folder, subj, study_type, feature_type="baseline", label_type, exclude_sessions=exclude)
#     print(summary(subj_baseline_dataset))
    subj_baseline_result = stereotypy_loso_validation(subj_baseline_dataset)
    # Generate metric dataframe and export to csv
    result_filename = paste("baseline",paste("study", study_type, sep=""), experiment_time, "csv", sep=".")
    generate_metrics(filename=file.path(result_folder,result_filename), result=subj_baseline_result, metric_type=2, row_name=subj_counter)
    print(paste("baseline feature set evaluation is done"))

    # Run for stockwell feature set
    subj_stockwell_dataset = load_one_subject_dataset(session_folder, subj, study_type, feature_type="stockwell", label_type, exclude_sessions=exclude)
    subj_stockwell_result = stereotypy_loso_validation(subj_stockwell_dataset)
    # Generate metric dataframe and export to csv
    result_filename = paste("stockwell",paste("study", study_type, sep=""), experiment_time, "csv", sep=".")
    generate_metrics(filename=file.path(result_folder,result_filename), result=subj_stockwell_result, metric_type=2, row_name=subj_counter)
    print(paste("stockwell feature set evaluation is done"))
    
    # Run for combined feature set
    subj_combined_dataset = load_one_subject_dataset(session_folder, subj, study_type, feature_type="combined", label_type, exclude_sessions=exclude)
    subj_combined_result = stereotypy_loso_validation(subj_combined_dataset)
    # Generate metric dataframe and export to csv
    result_filename = paste("combined",paste("study", study_type, sep=""), experiment_time, "csv", sep=".")
    generate_metrics(filename=file.path(result_folder,result_filename), result=subj_combined_result, metric_type=2, row_name=subj_counter)
    print(paste("combined feature set evaluation is done"))
  } 
}

### ==========================================================
# Note that due to memory issue, 
# please run each study seperately by restarting R session in between 
# to refresh the memory if you have less than 16GB memory

source("src/R/constants.R")
# For study 1
# Experiment1_DT(session_folder=study1_folder, subjs=subj_study)

# # For study 2
Experiment1_DT(session_folder=study2_folder, subjs=subj_study)


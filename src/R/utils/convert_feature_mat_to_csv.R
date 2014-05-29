# Individual sessions's experiment: Trained using each session data for each 
# participant and offline annotations from the laboratory. Tested using 
# cross-validation.

rm(list=ls())
options( java.parameters = "-Xmx2g" )
require( "RWeka" )
require("foreach")
require("plyr")
require("rChoiceDialogs")
require("R.matlab")

source(file="StereotypyExperiments//import_sessions.stereotypy.R")
source(file="StereotypyExperiments//write_result_header.stereotypy.R")
source(file="StereotypyExperiments//load_cached_dataset.stereotypy.R")
source(file="StereotypyExperiments//normalize_dataset.stereotypy.R")
source(file="StereotypyExperiments//parseFeatureMatFile.R")

subj_study1 = c("006", "007", "008","009","010","011")
envir_study1 = c("07", "08") # 007 is lab, 008 is classroom for study 1
subj_study2 = c("001", "002", "004", "006", "008", "009", "010", "011", "012", "014")
feature_list = c("var","entropy","corcoef","meandist","max_freq")
window_size = 1
overlap_rate = 8/9

session_folder = rchoose.dir(getwd(), "Select Study Folder")

if(is.na(session_folder)){
    stop("Please select correct folder to run the experiment")
}

study_type = ifelse(test=grepl(pattern="1", x=basename(session_folder),perl=TRUE), yes=1, no=2)

annotator = "Annotator1Stereotypy"
label_type = "offline"
dataset_type = "previous"
from = "Marzieh"

# prepare dataset for each subject
subj_sessions = list.files(path=session_folder, full.names=TRUE, ignore.case=TRUE, include.dirs=TRUE, no..=TRUE)

if(study_type == 1){
    exclude = list.files(path=session_folder, pattern="URI-007-07-24-07", full.names=TRUE, ignore.case=TRUE, include.dirs=TRUE, no..=TRUE)
}else{
    exclude = list.files(path=session_folder, pattern="010-2011-03-23", full.names=TRUE, ignore.case=TRUE, include.dirs=TRUE)
}

subj_sessions = setdiff(subj_sessions, exclude)

print(subj_sessions)

for(session in subj_sessions[[1]]){
    mat_file = file.path(session, 'featureVectorAndLabels.mat')
    if(file.exists(mat_file)){
        print(paste("found feature Vector in mat", basename(session)))
        single_dataset = parseFeatureMatFile(mat_file)$time
        
    }
    else if(check_cached_dataset(basename(session), dataset_type, label_type, from)){
        print(paste("found cache", basename(session)))
        single_dataset = load_cached_dataset(basename(session), dataset_type, label_type, from)
    }
    csv_name = file.path(session, 'featureVectorAndLabel.csv')
    write.table(x=single_dataset, file=csv_name, quote=FALSE, row.names=FALSE, col.names=FALSE, sep=",")
}


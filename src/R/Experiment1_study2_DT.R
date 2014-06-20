# Experement 1 Decision Tree version: Trained using participant-dependent data and offline 
# annotations from the classroom. Tested using leave-one-session-out.

### ==========================================================
# Note that due to memory issue, 
# please restart R session in between each run
# to refresh the memory if you have less than 16GB memory

source("src/R/utils/Experiment1_DT.R")
source("src/R/constants.R")

# For study 2
Experiment1_DT(session_folder=study2_folder, subjs=subj_study)
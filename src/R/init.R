#!/usr/bin/env r
rm(list=ls())

### Set up root path
source("src/R/setRoot.R")

### Check libraries, if not install it ====
check_required_libraries <- function (package1, ...)  {   
  
  # convert arguments to vector
  packages <- c(package1, ...)
  
  # start loop to determine if each package is installed
  for(package in packages){
    
    # if package is installed locally, load
    if(package %in% rownames(installed.packages())){
      print(paste("Found", package))
      do.call('library', list(package))
    }
    # if package is not installed locally, download, then load
    else {
      print(paste("Installing", package))
      install.packages(package, verbose=FALSE, repos="http://cran.us.r-project.org")
      do.call("library", list(package))
    }
  } 
}

check_required_libraries("SOAR", "colorspace", "foreach", "R.matlab", "plyr", "caret", "sampling", "e1071", "rJava", "rChoiceDialogs", "XML", "RWeka")

### Constants ====
source("src/R/constants.R")

### Caching feature sets ====
source("src/R/utils/load_featureset_mat.stereotypy.R")

study1_session_folders = list.files(study1_folder, include.dirs=TRUE, full.names=TRUE, no..=TRUE)
study2_session_folders = list.files(study2_folder, include.dirs=TRUE, full.names=TRUE, no..=TRUE)

feature_filename = "featureVectorAndLabels.mat"
exclude_files = "nothing" # no bad dataset

for(folder in study1_session_folders){
  if(!grepl(pattern=exclude_files, x=folder, ignore.case=TRUE, perl=TRUE)){
    load_featureset_mat(folder, feature_filename)
  }else{
    print(paste("Bad dataset skipped:", basename(folder)))
  }
}

for(folder in study2_session_folders){
  if(!grepl(pattern=exclude_files, x=folder, ignore.case=TRUE, perl=TRUE)){
    load_featureset_mat(folder, feature_filename)
  }else{
    print(paste("Bad dataset skipped:", basename(folder)))
  }
}

### Set the maximum memory of JVM to be 16 gigabit
options( java.parameters = "-Xmx16g" )

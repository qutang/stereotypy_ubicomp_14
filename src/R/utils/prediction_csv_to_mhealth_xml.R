prediction_csv_to_mHealth_xml = function(csv_name, feature_type = NULL, study_type = NULL, session_id = NULL) {
    library("XML")
    library("plyr")
    source("src/R/utils/uuid.R")
    source("src/R/utils/time_conversion_helpers.R")
    
    if(is.character(csv_name)){
      # parse csv file name
      input_name = basename(csv_name)
      input_name_list = strsplit(input_name,split = ".", fixed = TRUE)
      input_name_list = input_name_list[[1]]
      feature_type = input_name_list[1]
      study_type = ifelse(grepl(pattern="1",input_name_list[2]), "1", "2")
      session_id = input_name_list[3]
      
      # read in csv file
      predict.df = read.table(file=csv_name, header = TRUE, sep=",", stringsAsFactors = FALSE)
    }else if(is.data.frame(csv_name)){
      predict.df = csv_name
    }
    
    # combine same labels in prediction
    prediction.label = factor(predict.df[["PREDICTION"]])
    prediction.index = predict.df[["PERMUTATION"]]
    prediction.num = as.numeric(prediction.label)
    prediction.sep = as.logical(diff(prediction.num))
    prediction.start = c(TRUE, prediction.sep)
    prediction.stop = c(prediction.sep, TRUE)
    
    # get session time range from good data info
    source("src/R/utils/convert_annotation_xml_to_csv.R")
    source("src/R/utils/get_annotation_xml_path.R")
    annotation.path = get_annotation_xml_path(session_id, study_type)
    annotation.df = convert_annotation_xml_to_csv(annotation.path)
    gooddata.row = annotation.df[annotation.df["LABEL"]=="Good Data",]
    session_start = gooddata.row["START_DT"]
    session_end = gooddata.row["STOP_DT"]
    
    session_start = mhealth_readable_to_posixlt(session_start)
    session_end = mhealth_readable_to_posixlt(session_end)
    
    # replace index with time (overlap rate is 8/9, so every tick is 1/9 sec, window size is 1 sec)
    options(digits.secs = 3)
    prediction.time = session_start + (prediction.index - 1)*1/9
    
    # create a prediction data frame with start and end time and label
    prediction.start.stop.df = data.frame(PREDICTION = prediction.label[prediction.start], 
               START_DT = prediction.time[prediction.start], 
               STOP_DT = prediction.time[prediction.stop]+1, 
               START_INDEX = prediction.index[prediction.start],
               STOP_INDEX = prediction.index[prediction.stop])
    
    # filter out "others" rows
#     prediction.start.stop.df = prediction.start.stop.df[prediction.start.stop.df["PREDICTION"] != "Others",]
    
    # seperate for each type
    prediction.rock = prediction.start.stop.df[prediction.start.stop.df["PREDICTION"] == "Rock",]
    prediction.flap = prediction.start.stop.df[prediction.start.stop.df["PREDICTION"] == "Flap",]
    prediction.rockflap = prediction.start.stop.df[prediction.start.stop.df["PREDICTION"] == "Rock-Flap",]
    prediction.others = prediction.start.stop.df[prediction.start.stop.df["PREDICTION"] == "Others",]

# TODO: convert to mHealth XML
#     
#     old.doc = xmlTreeParse(old.filepath, getDTD = F)
#     old.root = xmlRoot(old.doc)
#     old.data = old.root[[3]]
#     old.definition = old.root[[2]][[1]]
#     old.labels = xmlApply(old.definition, xmlGetAttr, "NAME")
#     
#     # process label entries
#     old.STARTTIMES = xmlApply(old.data, xmlGetAttr, "STARTTIME")
#     old.ENDTIMES = xmlApply(old.data, xmlGetAttr, "ENDTIME")
#     old.DATES = xmlApply(old.data, xmlGetAttr, "DATE")
#     old.DATES.transformed = format(strptime(old.DATES, "%m/%d/%Y"), "%Y-%m-%d")
#     if(is.na(old.DATES.transformed[[1]])){
#       old.STARTDATES =  xmlApply(old.data, xmlGetAttr, "STARTDATE")
#       old.ENDDATES =  xmlApply(old.data, xmlGetAttr, "ENDDATE")
#       if(length(strsplit(old.STARTDATES[[1]],'\\.')[[1]]) == 1){
#          for(i in 1:length(old.STARTDATES)){
#            old.STARTDATES[[i]] = paste(old.STARTDATES[[i]], strsplit(old.STARTTIMES[[i]],'\\.')[[1]][2], sep='.')
#            old.ENDDATES[[i]] = paste(old.ENDDATES[[i]], strsplit(old.ENDTIMES[[i]],'\\.')[[1]][2], sep='.')
#          }
#          old.STARTTIMES = old.STARTDATES
#          old.ENDTIMES = old.ENDDATES
#       }
#     }
#     old.VALUES = xmlApply(old.data, xmlChildren)
#     old.LABELS = sapply(old.VALUES, function(old.Value) {
#         xmlGetAttr(old.Value[[1]], "LABEL")
#     })
#     
#     # build mHealth format entries
#     new.root = newXMLNode("DATA", attrs = c(DATASET = "My Dataset"))
#     sapply(1:length(old.STARTTIMES), function(i) {
#         if(is.na(old.DATES.transformed[[1]])){
#           start_dt = old.STARTTIMES[[i]]
#           stop_dt = old.ENDTIMES[[i]]
#         }else{
#           start_dt = paste(old.DATES.transformed[[i]], old.STARTTIMES[[i]], sep = " ")
#           stop_dt = paste(old.DATES.transformed[[i]], old.ENDTIMES[[i]], sep = " ")
#         }
#         if (autism) {
#             #print(!grepl("Not", old.LABELS[i]))
#             if (!grepl("not", old.LABELS[i], perl=TRUE, ignore.case=TRUE)) {
#                 #print("autism")
#                 ## skip if contain Not in the label transform label
#                 label = ""
#                 meta = ""
#                 if (grepl(pattern="flap.*rock.*maybe", x=old.LABELS[[i]], perl=TRUE, ignore.case=TRUE)) {
#                   label = "Flap-Rock"
#                   meta = "1"
#                 } else if (grepl(pattern="flap.*rock", x=old.LABELS[[i]], perl=TRUE, ignore.case=TRUE)) {
#                   label = "Flap-Rock"
#                   meta = "3"
#                 } else if (grepl(pattern="flap.*maybe", x=old.LABELS[[i]], perl=TRUE, ignore.case=TRUE)) {
#                   label = "Flap"
#                   meta = "1"
#                 } else if (grepl(pattern="flap", x=old.LABELS[[i]], perl=TRUE, ignore.case=TRUE)) {
#                   label = "Flap"
#                   meta = "3"
#                 }
#                   else if (grepl(pattern="rock.*maybe", x=old.LABELS[[i]], perl=TRUE, ignore.case=TRUE)) {
#                   label = "Rock"
#                   meta = "1"
#                 }
#                   else if (grepl(pattern="rock", x=old.LABELS[[i]], perl=TRUE, ignore.case=TRUE)) {
#                   label = "Rock"
#                   meta = "3"
#                 } else if (grepl(pattern="good.*data", x=old.LABELS[[i]], perl=TRUE, ignore.case=TRUE)) {
#                   label = "Good Data"
#                   meta = "3"
#                 } else{
#                   label = old.LABELS[[i]]
#                   meta = "3"
#                 }
#                 node = newXMLNode("ANNOTATION", parent = new.root, attrs = c(GUID = uuid()))
#                 newXMLNode("LABEL", label, parent = node)
#                 newXMLNode("START_DT", start_dt, parent = node)
#                 newXMLNode("STOP_DT", stop_dt, parent = node)
#                 ratings = newXMLNode("RATINGS", parent = node)
#                 newXMLNode("RATING", attrs = c(METARATING = meta, VALUE = "1", TIMESTAMP = start_dt), parent = ratings)
#                 newXMLNode("RATING", attrs = c(METARATING = meta, VALUE = "0", TIMESTAMP = stop_dt), parent = ratings)
#                 newXMLNode("PROPERTIES", attrs = c(DATE_CREATED = stop_dt, LAST_MODIFIED = stop_dt, ANNOTATION_SET = "STEREOTYPY"), parent = node)
#             }
#         } else {
#             # not autism
#             #print("not autism")
#             node = newXMLNode("ANNOTATION", parent = new.root, attrs = c(GUID = uuid()))
#             newXMLNode("LABEL", old.LABELS[[i]], parent = node)
#             newXMLNode("START_DT", start_dt, parent = node)
#             newXMLNode("STOP_DT", stop_dt, parent = node)
#             ratings = newXMLNode("RATINGS", parent = node)
#             newXMLNode("RATING", attrs = c(METARATING = meta, VALUE = "1", TIMESTAMP = start_dt), parent = ratings)
#             newXMLNode("RATING", attrs = c(METARATING = meta, VALUE = "0", TIMESTAMP = stop_dt), parent = ratings)
#             newXMLNode("PROPERTIES", attrs = c(DATE_CREATED = stop_dt, LAST_MODIFIED = stop_dt, ANNOTATION_SET = "STEREOTYPY"), parent = node)
#         }
#     })
#    print(new.root)
#     return(new.root)
} 
csv_path = "results/DT/experiment2/baseline.study1.URI-001-01-18-08.prediction.csv"
prediction_csv_to_mHealth_xml(csv_path)
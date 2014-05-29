require("rChoiceDialogs")
require("foreach")

folder = rchoose.dir(getwd())

output_folder = rchoose.dir(getwd())

sessions = list.files(path=folder, full.names=FALSE, pattern="-")

### Copy from ready folder to public dataset folder by excluding some unnecessary files ======
# for(session in sessions){
#     session_folder = file.path(folder, session)
#     output_session_folder = file.path(output_folder, session)
#     dir.create(output_session_folder)
#     
#     all_raw = list.files(path=session_folder, pattern="*RAW_DATA.csv", full.names=TRUE)
# #     exclude_raw = list.files(path=session_folder, pattern="*RawCorrectedData*", full.names=TRUE)
# #     public_raw = setdiff(all_raw, exclude_raw)
#     public_raw = all_raw
#     file.copy(from=public_raw, to=output_session_folder, overwrite=FALSE)
#     
#     public_label = list.files(path=session_folder, pattern="*annotation.xml", full.names=TRUE)
#     file.copy(from=public_label, to=output_session_folder, overwrite=FALSE)
#     print(sprintf("Completed: %s", session))
# }

### Convert readable timestamps back to unixtime
# source("src/R/utils//mhealth_readable_to_unixtime_ms.R")
# for(session in sessions){
#     session_folder = file.path(folder, session)
#     all_raw = list.files(path=session_folder, pattern="*RAW_DATA.csv", full.names=TRUE)
#     for(raw in all_raw){
#       raw_data = read.table(raw,header=FALSE, sep=",", stringsAsFactors=FALSE)
#       if(class(raw_data[,1]) != "numeric"){
#         unix_ts = sapply(raw_data[,1], mhealth_readable_to_unixtime_ms)
#         unix_ts = unname(unix_ts)
#         raw_data[,1] = unix_ts
#         write.table(raw_data, file=raw, append=FALSE,sep=",", row.names=FALSE, col.names=FALSE)
#         print(paste("Write", raw))
#       }
#       else{
#         print(paste("Skip", raw))
#       }
#     }
#     print(sprintf("Completed: %s", session))
# }

### Copy annotationInterval files
folder = rchoose.dir(getwd())

output_folder = rchoose.dir(getwd())

sessions = list.files(path=folder, full.names=FALSE, pattern="-")

for(session in sessions){
    session_folder = file.path(folder, session)
    output_session_folder = file.path(output_folder, session)
    
    all_annotation_interval = list.files(path=session_folder, pattern="*Intervals.xlsx", full.names=TRUE)
    public_annotation_interval = all_annotation_interval
    file.copy(from=public_annotation_interval, to=output_session_folder, overwrite=FALSE)
    
}

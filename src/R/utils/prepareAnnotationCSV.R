require("rChoiceDialogs")
require("foreach")

folder = rchoose.dir("C:\\Users\\Qu\\Projects\\StereotypyRecognition\\StereotypyPaper_dropbox\\PublicDataAndSourceCode\\Raw Data")

sessions = list.files(path=folder, full.names=FALSE, pattern="-")

for(session in sessions){
    session_folder = file.path(folder, session)
    public_label = list.files(path=session_folder, pattern="*annotation.xml", full.names=TRUE)
    
    for(label_file in public_label){
        csv_name = gsub(x=label_file, pattern="xml", replacement="csv")
        csv_annotation = convert_annotation_xml_to_csv(label_file)
        write.table(x=csv_annotation, file=csv_name, quote=FALSE, row.names=FALSE, sep=",")
    }
    
    print(sprintf("Completed: %s", session))
}
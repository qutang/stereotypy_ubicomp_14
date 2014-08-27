get_annotation_xml_path = function(session_id, study_type){
  
  session_folder = file.path("data",paste("Study", study_type, sep=""), session_id)
  
  annotation_path = file.path(session_folder, "Annotator1Stereotypy.annotation.xml")
  
  return(annotation_path)
}
convert_annotation_xml_to_csv = function(xml_file){
    library("XML")
    xml.doc = xmlTreeParse(xml_file, getDTD = F)
    xml.root = xmlRoot(xml.doc)
    xml.nodes = xmlChildren(xml.root)
    xml.labels = xmlApply(xml.root, function(node){
        return(xmlValue(node[["LABEL"]]))
    })
    names(xml.labels) = c()
    xml.labels = sapply(xml.labels, as.character)
    xml.st = xmlApply(xml.root, function(node){
        return(xmlValue(node[["START_DT"]]))
    })
    names(xml.st) = c()
    xml.st = sapply(xml.st, as.character)
    
    xml.et = xmlApply(xml.root, function(node){
        return(xmlValue(node[["STOP_DT"]]))
    })
    names(xml.et) = c()
    xml.et = sapply(xml.et, as.character)
    df = data.frame(xml.st, xml.et, xml.labels, stringsAsFactors=FALSE)
    names(df) = c("START_DT", "STOP_DT", "LABEL")
    return(df)
}
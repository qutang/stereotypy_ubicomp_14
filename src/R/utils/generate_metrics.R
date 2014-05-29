generate_metrics = function(filename, result, metric_type, row_name){
  result = result$customized_metrics[[metric_type]]
  row.names(result) = c(row_name)
  if(file.exists(filename)){
    write.table(result, file=filename, append=TRUE, sep=",", quote=FALSE, col.names=FALSE, row.names=TRUE)
  }else{
    write.table(result, file=filename, append=TRUE, sep=",", quote=FALSE, col.names=TRUE, row.names=TRUE)
  }
}
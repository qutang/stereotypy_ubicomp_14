unixtime_second_to_mhealth_readable = function(seconds){
  readable = as.POSIXlt(seconds,tz="GMT",origin="1970-01-01")
  result = format(readable, "%Y-%m-%d %H:%M:%OS3")
  return(result)
}

# test

# test = unixtime_second_to_mhealth_readable(1200652984.111)
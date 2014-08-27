mhealth_readable_to_posixlt = function(readable){
  time_obj = strptime(readable, "%Y-%m-%d %H:%M:%OS", tz="GMT")
  return(time_obj)
}

mhealth_readable_to_unixtime_ms = function(readable){
  time_obj = mhealth_readable_to_posixlt(readable)
  result = as.numeric(time_obj) * 1000
  return(result)
}



# test
# options(scipen=100, digits=13)
# mhealth_readable_to_unixtime_ms(test)
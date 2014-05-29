normalize_dataset = function(dataset){
    require("plyr")
    colNorm = numcolwise(norm, "2")
    # normalize and scale
    col_data = colnames(dataset)
    col_data = setdiff(col_data, "LABEL")
    data_norms = as.matrix(colNorm(dataset[col_data]))
    dataset[col_data] = sweep(dataset[col_data], 2, data_norms, '/')
    
    max_value = max(dataset[col_data])
    dataset[col_data] = dataset[col_data]/max_value
    return(dataset)
}


# test_data =  data.frame(cbind(runif(10),runif(10)))
# 
# print(max(test_data))
# print(norm(test_data, "2"))
# 
# 
# normalized_data = normalize_dataset(test_data)
# 
# print(max(normalized_data))
# print(norm(normalized_data, "2"))
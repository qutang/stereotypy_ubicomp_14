load_cached_dataset = function(session_name, dataset_type, label_type, from="origin"){
    require("SOAR")
    if(from == "origin"){
        cache_name = paste(session_name, dataset_type, sep=".")
        label_name = paste(session_name, "label", label_type, sep=".")
        single_dataset = get(cache_name)
        label = get(label_name)
        label[label==1]= "Others"
        label[label==2]= "Rock"
        label[label==3]= "Rock-Flap"
        label[label==4]= "Flap"
       
        l = min(nrow(label), nrow(single_dataset))
        label = data.frame(label[1:l,'LABEL'])
        colnames(label) =c("LABEL")
        single_dataset = cbind(single_dataset[1:l,], label)
    }else{
        if(label_type == "offline"){
            cache_name = paste(session_name, sep=".")
        }else{
            cache_name = paste(session_name, "Phone", sep=".")
        }
        single_dataset = get(cache_name)
    }
    return(single_dataset)
}

check_cached_dataset = function(session_name, dataset_type, label_type, from="origin"){
    require("SOAR")
    if(from == "origin"){
        cache_name = paste(session_name, dataset_type, sep=".")
    }else{
        if(label_type == "offline"){
            cache_name = session_name
        }else{
            cache_name = paste(session_name, "Phone", sep=".")
        }       
    }
    p = paste("^", cache_name, "$", sep="")
    cache_flag = any(grepl(pattern=p, x=Objects(),perl=TRUE))
    return(cache_flag)
}
program maketime

if "${time}" == "month"{
    gen year = year(dofm(time))
    gen post = time > mofd(date("10-1-2007","MDY"))
    format time %tm
}

if "${time}" == "quarter"{
    gen year = year(dofq(time))
    gen post = time > qofd(date("10-1-2007","MDY"))
    format time %tq
}


end

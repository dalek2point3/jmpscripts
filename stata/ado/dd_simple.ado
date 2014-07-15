program dd_simple

use ${stash}panelfips, clear

local outcomes "`1'"
local mode `2'
local option `3'

di "Outcomes : `outcomes'"
di "Mode: `mode'"
di "Filename: `option'"

if "`mode'" == "run"{
    di "running"
    runreg "`outcomes'" 
}

if "`mode'" == "write"{
    di "writing"
    writereg "`outcomes'" `option'
}

end

program runreg

local outcomes "`1'"

est clear

foreach x in `outcomes'{
    gen ln`x' = ln(`x'+1)
    
    local model reg
    eststo: qui `model' ln`x' 1.treat#1.post 1.treat i.time pop_year, cluster(fips)
    estadd local countyfe "No", replace
    estadd local monthfe "Yes", replace
    estimates save ${tables}ddsimple_`x'_`model', replace

    local model xtreg
    eststo: qui `model' ln`x' 1.treat#1.post i.time pop_year, fe cluster(fips)
    estadd local countyfe "Yes", replace
    estadd local monthfe "Yes", replace
    estimates save ${tables}ddsimple_`x'_`model', replace

    
    local model xtpoisson
    eststo: qui `model' `x' 1.treat#1.post i.time pop_year, fe vce(robust)
    qui estadd local countyfe "Yes", replace
    qui estadd local monthfe "Yes", replace
    qui estimates save ${tables}ddsimple_`x'_`model', replace
    di "Just wrote `model' for `x'"
}
    
end

program writereg

est clear
local outcomes "`1'"
local filename `2'

foreach x in `outcomes'{
    foreach y in reg xtreg xtpoisson{
        di "`x' : `y'"
        qui estimates use ${tables}ddsimple_`x'_`y'
        qui eststo est`x'_`y'
    }
}



esttab using "${tables}`filename'.tex", keep(1.treat#1.post 1.treat) se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(1.treat "Treat" 1.treat#1.post "Post X Treat"  _cons "Constant") replace booktabs s(countyfe monthfe monthfe N N_g, label("County FE" "Year FE" "Population" "N" "Clusters")) label mgroups("OLS" "OLS" "Poisson QMLE" "OLS" "OLS" "Poisson QMLE" , pattern(1 1 1 1 1 1)) mtitles("Ln(Contrib)" "Ln(Contrib)" "Contrib" "Ln(Users)" "Ln(Users)" "Users")

end


program dd_simple

use ${stash}panelfips, clear

local outcomes "`1'"
local mode `2'
local option `3'

* local filename "crossreg"
* local outcomes "numcontrib numuser numserious90"

di "Outcomes : `outcomes'"
di "Mode: `mode'"
di "Filename: `option'"

if "`mode'" == "run"{
    di "running"
    runreg "`outcomes'" `option'
}

if "`mode'" == "write"{
    di "writing"
    writereg "`outcomes'" `option'
}

end

program runreg

local outcomes "`1'"
local model `2'

est clear
foreach x in `outcomes'{
    di "`x'"
    eststo: qui `model' `x' 1.treat#1.post i.year, fe vce(robust)
    estadd local countyfe "Yes", replace
    estadd local monthfe "Yes", replace
    estimates save ${tables}ddsimple_`x'_`model', replace
}

end

program writereg

est clear
local outcomes "`1'"
local filename `2'

foreach x in `outcomes'{
    foreach y in "xtreg xtpoisson"{
        di "`x'"
        estimates use ${tables}ddsimple_`x'_`y'
        eststo est`x'
    }
}

esttab using "${tables}`filename'.tex", keep(1.treat#1.post) se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(1.treat#1.post "Post X TIGER" _cons "Constant") replace booktabs s(countyfe monthfe N, label("County FE" "Month FE"))

end


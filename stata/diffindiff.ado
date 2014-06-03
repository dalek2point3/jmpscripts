program diffindiff

local model `1'
local dv `2'
local unit `3'
local cutoff `4'
local mode `5'

di "OK, you asked me to generate DD charts"
di "for `model', unit: `unit', DVs: `dv', mode: `mode'"
di "cutoff: `cutoff'"

if "`mode'" == "run"{
    drop if year > `cutoff'
    runreg `model' "`dv'" `unit' `cutoff'
}

if "`mode'" == "write"{
    loadreg `model' "`dv'" `unit' `cutoff'
    writereg `model'_`unit'_`cutoff'
}

end

program runreg
local model `1'
local dv `2'
local unit `3'
local cutoff `4'

est clear
di "-----"
di "  Running `model' for `dv'"
di "-----"
foreach x in `dv'{
di "now processing `x'"
local command "`model' `x' 1.treat#1.post i.month, fe vce(robust)"
di "`command'"
`model' `x' 1.treat#1.post i.month, fe vce(robust)
esttab, keep(1.treat#1.post) p
estimates save ${myestimates}`model'_`x'_`cutoff'_`unit', replace
}
end

program loadreg

local model `1'
local dv `2'
local unit `3'
local cutoff `4'

di "storing estimates from `model' for `dv' (`unit')"

est clear
foreach x in `dv'{
estimates use ${myestimates}`model'_`x'_`cutoff'_`unit'
estadd local unitfe "Yes", replace
estadd local monthfe "Yes", replace
eststo est`x'
}
end


program writereg

local filename `1'

esttab using "${tables}`filename'.tex", keep(1.treat#1.post) se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(1.treat#1.post "Post X TIGER" _cons "Constant") mtitles("Contrib" "Chngs" "Users" "New U" "New U(6+)" "New Super U" "Super Users") replace booktabs  s(unitfe monthfe N, label("County FE" "Month FE"))

end





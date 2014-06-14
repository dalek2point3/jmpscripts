program diffindiff

local model `1'
local dv `2'
local unit `3'
local cutoff `4'
local mode `5'
local table `6'
local t1 "`7'"
local t2 "`8'"
local t3 "`9'"

di "OK, you asked me to generate DD charts"
di "for `model', unit: `unit', DVs: `dv', mode: `mode'"
di "cutoff: `cutoff', titles: `titles'"

if "`mode'" == "run"{
    drop if year > `cutoff'
    runreg `model' "`dv'" `unit' `cutoff'
}

if "`mode'" == "write" & "`unit'" != "uid"{
    loadreg `model' "`dv'" `unit' `cutoff'
    writereg `model'_`unit'_`cutoff'_`table' "`t1'" "`t2'" "`t3'"
}

if "`mode'" == "write" & "`unit'" == "uid"{
    loadreg `model' "`dv'" `unit' `cutoff'
    writereguid `model'_`unit'_`cutoff'_`table'
}

end

program runreg
local model `1'
local dv `2'
local unit `3'
local cutoff `4'

local factor "1.treat"

if "`unit'" == "geoid10"{
    local factor "c.treat"
}


est clear
di "-----"
di "  Running `model' for `dv'"
di "-----"
foreach x in `dv'{
di "now processing `x'"
local command "`model' `x' `factor'#1.post i.month, fe vce(robust)"
di "`command'"
`model' `x' `factor'#1.post i.month, fe vce(robust)
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
local t1 "`2'"
local t2 "`3'"
local t3 "`4'"

di "Titles are: `t1' `t2' `t3'"

esttab using "${tables}`filename'.tex", keep(1.treat#1.post) se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(1.treat#1.post "Post X TIGER" _cons "Constant") mtitles("`t1'" "`t2'" "`t3'") replace booktabs  s(unitfe monthfe N, label("County FE" "Month FE"))

end

program writereguid

local filename `1'
di "processing uid"
esttab using "${tables}`filename'.tex", keep(1.treat#1.post) se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(1.treat#1.post "Post X TIGER" _cons "Constant") mtitles("Contrib" "Home County" "TIGER" "NO TIGER" "State (No TIGER)" "Number of Counties") replace booktabs  s(unitfe monthfe N, label("County FE" "Month FE"))

end





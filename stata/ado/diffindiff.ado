* diffindiff xtpoisson "`dv'" `unit' 2014 write tab_3.2.2 "New Users" "New Users(6+)" "New Super Users"

* diffindiff2 xtpoisson fips write tab_3.2.2 numcontrib numusers ...

* diffindiff2 xtpoisson fips run tab_test numcontrib


program diffindiff

* local dv `2'
* local cutoff `4'

local model `1'
local unit `2'
local mode `3'
local table `4'
local cutoff 2014

// this stores variable names in as t1, t2, t3 and so on
local i = 5
while "``i''" != "" {
    local count = `i' - 4
    local t`count' = "``i''"
    ** di "var is `t`count''" 
    local ++i
}


di "OK, you asked me to generate DD charts"
di "for `model', unit: `unit', mode: `mode'"

*if "`mode'" == "run"{
*    drop if year > `cutoff'
*    runreg `model' "`dv'" `unit' `cutoff'
*}

if "`mode'" == "run" {
    di "Running regressions ///"
    local i = 1
    while "`t`i''" != "" {
        local t "`t`i''"
        ** di "running `t'"
        run_reg `t' `table' `model'
        local ++i
    }
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

program run_reg

local t `1'
local tabname `2'
local model `3'

di "----"
di "model: `model', tab: `tabname'"
di "----"

save ${stash}tmp, replace

local command "`model' `t' 1.treat#1.post i.month"

di "now running for `t'"
di "--"
runcommand tmp "`command'" `tabname'_fips_`t'
di "--"

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





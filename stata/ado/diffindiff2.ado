* use ${stash}panelfips, clear

* bysort fips: gen tag = _n==1
* codebook cntypop if tag == 1
* tab large if tag == 1

// customize rule
* gen large = (cntypop > 100000)
* local var large
* local varlabel "LARGE"
local tabname tab_4.1
* local t1 numuser
* local t2 numuser6
* local t3 numserious90

program diffindiff2

local var `1'
local varlabel `2'
local tabname `3'
local t1 `4'
local t2 `5'
local t3 `6'
local mode `7'

di "var: `var', tab: `tabname'"
di "for `t1', `t2', `t3'"
di "in mode `mode'"

if "`mode'" == "run" {
    di "Running regressions"
    run_reg `t1' `t2' `t3' `tabname' `var'
}

if "`mode'" == "write" {
    load_reg `t1' `t2' `t3' `tabname' `var'
    write_reg  `t1' `t2' `t3' `tabname' `var' `varlabel'
}


end

program run_reg

local t1 `1'
local t2 `2'
local t3 `3'
local tabname `4'
local var `5'

di "----"
di "var: `var', tab: `tabname'"
di "for `t1', `t2', `t3'"
di "----"

foreach x in `t1' `t2' `t3'{
est clear



* eststo: reg `x' treat
eststo: xtpoisson `x' 1.treat#1.post 1.post#1.large 1.treat#1.post#1.large i.month, fe vce(robust)
estimates save ${myestimates}`tabname'_fips_`x'_`var', replace
}

end

program load_reg

local t1 `1'
local t2 `2'
local t3 `3'
local tabname `4'
local var `5'

est clear
foreach x in `t1' `t2' `t3'{
estimates use ${myestimates}`tabname'_fips_`x'_`var'
estadd local unitfe "Yes", replace
estadd local monthfe "Yes", replace
eststo est`x'
}
end

program write_reg

local t1 `1'
local t2 `2'
local t3 `3'
local tabname `4'
local var `5'
local varlabel `6'

esttab using "${tables}`tabname'_fips_`var'.tex", keep(1.treat#1.post 1.post#1.`var' 1.treat#1.post#1.`var') coeflabels(1.treat#1.post#1.large "TIGER X POST X `varlabel'" 1.treat#1.post "TIGER X POST" 1.post#1.`var' "POST X `varlabel'" ) order(1.treat#1.post#1.large 1.treat#1.post 1.post#1.`var') se ar2 nonotes mtitles("`t1'" "`t2'" "`t3'") replace booktabs  s(unitfe monthfe N, label("County FE" "Month FE"))

end

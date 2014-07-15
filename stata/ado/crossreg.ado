program crossreg

use ${stash}panelfips, clear

local controls "cntypop emp_earnings age_median"

local controlsfe "cntypop emp_earnings age_median i.division i.year"

local filename "crossreg"
local outcomes "numcontrib numuser numserious90"

replace cntypop = cntypop / 1000
replace emp_earn = emp_earn / 1000

est clear
foreach x in `outcomes'{
    di "`x'"
    eststo: qui reg `x' treat `controls', robust
    estadd local divisionfe "No", replace
    estadd local monthfe "No", replace
    eststo: qui reg `x' treat `controlsfe', robust
    estadd local divisionfe "Yes", replace
    estadd local monthfe "Yes", replace
}

esttab using "${tables}`filename'.tex", se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) drop(*division *year) coeflabels(treat "TIGER" _cons "Constant" cntypop "Population" emp_earnings "Earnings" age_median "Median Age") mtitles("Contrib." "Contrib." "Users" "Users" "Serious Users" "Serious Users") replace s(divisionfe monthfe N, label("9 Region FEs" "Year FEs")) booktabs

end



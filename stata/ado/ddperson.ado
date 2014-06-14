program ddperson

local mode `1'


if "`mode'" == "maketables"{
maketables
}

if "`mode'" == "makechart"{
makechart
}

end

program maketables

use ${stash}paneluid, replace

// this is need to avoid too thin data at the left
drop if month < 563

local dv "numcontrib numcontrib_home numcontrib_treat numcontrib_notreat numcontrib_statenotreat numcounties"

diffindiff xtreg "`dv'" "uid" "2014" "run"
diffindiff xtpoisson "`dv'" "uid" "2014" "run"

diffindiff xtreg "`dv'" "uid" "2014" "write"
diffindiff xtpoisson "`dv'" "uid" "2014" "write"

end

program makechart

use ${stash}paneluid, clear

gen duration = 574 - firstmonth

gen duration2 = round(duration / 6)

bysort uid: gen tag = (_n==1)
tab duration2 treat if tag == 1 

est clear
eststo: xtpoisson numcontrib post##treat##duration2 i.month, fe vce(robust)
estimates save ${myestimates}ddperson_chart4, replace
//estimates save ${myestimates}ddperson_chart6, replace

estimates use ${myestimates}ddperson_chart4
qui parmest, label list(parm estimate min* max* p) saving(${stash}pars_tmp, replace)

clear
use ${stash}pars_tmp, clear

keep if regexm(parm, "1.post.*treat.*duration*") == 1

gen duration = regexs(1) if regexm(parm, ".*#([0-9])d?\..*")

list estimate duration max min

graph dot estimate, over(duration)  legend(label(1 "Coefficient")) title("", span) ytitle("")

graph export ${tables}ddperson.eps, replace
shell epstopdf ${tables}ddperson.eps

}

end





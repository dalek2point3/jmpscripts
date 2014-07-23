program treat_person

use ${stash}paneluid, clear

bysort unitid: egen numtime = total(numcontrib>0)
bysort unitid: egen numtime_contrib = total(numcontrib)

local depvar "numcontrib numcontrib_home numcontrib_state numcounties numcontrib_statenotreat numtime numtime_contrib"

foreach x in `depvar'{
    gen ln`x' = ln(`x'+1)
}

gen firstq =  qofd(dofm(firstm))
bysort unitid: gen tag=_n==1
keep if tag==1
gen tmp = round(treat, .1)*10

reg lnnumtime i.tmp i.state, robust

qui parmest, label list(parm estimate min* max* p) saving(${stash}pars_tmp, replace)

clear
use ${stash}pars_tmp, clear

keep if regexm(parm, "[0-9].*tmp.*") == 1
drop if estimate == 0

gen time = regexs(1) if regexm(parm, "([0-9]+)\.tmp")
list time estimate max min
gen xaxis = 0
destring time, replace
replace time = time/10

graph twoway (bar estimate time, msize(small) lpattern(solid) lcolor(edkblue) lwidth(thin) barwidth(0.08)) (rcap min max time), legend(off) title("") xtitle("Treated")

end

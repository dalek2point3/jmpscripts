program ddchart

use ${stash}panelfips, clear

// need to exclude early months because of sparse data
// TODO! Far from complete, come back to this.

est clear
use ${stash}panelfips, clear

gen semester = hofd(dofm(month))
format semester %th

eststo: xtpoisson numuser 1.treat##b2007.year if month > 550, fe vce(robust)
estimates save ${myestimates}dd_numuser, replace

eststo: xtpoisson numuser 1.treat##b95.semester, fe vce(robust)
estimates save ${myestimates}dd_numuser, replace


drawchart numuser 2006

end

program drawchart

local var `1'
local cutoff `2'

estimates use ${myestimates}dd_`var'
qui parmest, label list(parm estimate min* max* p) saving(${stash}pars_tmp, replace)

clear
use ${stash}pars_tmp, clear

keep if regexm(parm, "1.*treat.*semester.*") == 1
gen semester = regexs(1) if regexm(parm, ".*#([0-9][0-9][0-9]?)b?\..*")

destring semester, replace
replace semester = semester - 95
label variable semester "Half-Year"

qui gen xaxis = 0
* list estimate min max month

graph twoway (connected estimate semester, msize(small) lpattern(solid) lcolor(edkblue) lwidth(thin)) (line min semester, lwidth(vthin) lpattern(-) lcolor(gs8)) (line max semester, lwidth(vthin) lpattern(-) lcolor(gs8)) (line xaxis semester, lwidth(vthin) lcolor(gs8)) if semester > -4, xline(0) legend(off) title("") xtitle("Semester")

graph export ${tables}timeline_`var'.eps, replace
shell epstopdf ${tables}timeline_`var'.eps

end



program old
est clear
use ${stash}panelfips, clear
eststo: xtpoisson numuser 1.treat##b573.month if month > 550, fe vce(robust)

eststo: xtpoisson numuser 1.treat##b2007.year if month > 550, fe vce(robust)

estimates save ${myestimates}dd_numuser, replace

est clear
use ${stash}panelfips, clear
eststo: xtreg numuser 1.treat##b573.month, fe vce(robust)
estimates save ${myestimates}dd_numnewusers, replace

est clear
use ${stash}panelfips, clear
eststo: xtpoisson numcontrib 1.treat##b573.month if month > 550, fe vce(robust)
estimates save ${myestimates}dd_numcontrib, replace

est clear
use ${stash}panelfips, clear
eststo: xtpoisson numserious90 1.treat##b573.month if month > 564, fe vce(robust)
estimates save ${myestimates}dd_numserious90, replace

drawchart numuser -15
drawchart numnewusers -8
drawchart numcontrib -15
drawchart numserious90 -15
end
 


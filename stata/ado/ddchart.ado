program ddchart

// need to exclude early months because of sparse data
// TODO! Far from complete, come back to this.
est clear
use ${stash}panelfips, clear


if "${time}" == "quarter"{
gen semester = hofd(dofq(time))
}

if "${time}" == "month"{
gen semester = hofd(dofm(time))
}

format semester %th

local outcomes `1'
local cutoff `2'
local mode `3'

di "Outcome: `outcomes'"
** local outcomes "numuser numserious90"

if "`mode'" == "run"{
    foreach x in `outcomes'{
        eststo: xtpoisson `x' 1.treat##b95.semester pop_year, fe vce(robust)
        estimates save ${myestimates}dd_`x', replace
    }
}
    
if "`mode'" == "write"{
    di "---"
    di "writing"
    foreach x in `outcomes'{
        drawchart `x' `cutoff'
    }
}
    

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
* replace semester = semester - 95
label variable semester "Half-Year"

qui gen xaxis = 0
**replace semester = semester / 2

replace min = . if semester < `cutoff'
replace max = . if semester < `cutoff'

graph twoway (connected estimate semester, msize(small) lpattern(solid) lcolor(edkblue) lwidth(thin)) (line min semester, lwidth(vthin) lpattern(-) lcolor(gs8)) (line max semester, lwidth(vthin) lpattern(-) lcolor(gs8)) (line xaxis semester, lwidth(vthin) lcolor(gs8)) if semester > `cutoff', xline(95) legend(off) title("") xtitle("Years") ysca(range(-1 1))

graph export ${tables}timeline_`var'.eps, replace
shell epstopdf ${tables}timeline_`var'.eps

list min est max semester
end




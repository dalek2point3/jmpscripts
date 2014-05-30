program diffindiff

use ${stash}panelfips, clear

gen post =  month > mofd(date("10-1-2007","MDY"))

local dv "numcontrib numuser numnewusers numnewusers6 numnewusers90 numserious90"

runreg xtreg "`dv'"
loadreg xtreg "`dv'"
writereg xtreg_all_2014

runreg xtpoisson "`dv'"
loadreg xtpoisson "`dv'"
writereg xtpoisson_all_2014

xtpoisson numcontrib 1.treat#1.post i.month, fe vce(robust)

end


program loadreg

local model `1'
local dv `2'

di "storing estimates from `model' for `dv'"

est clear
foreach x in `dv'{
estimates use ${myestimates}`model'_`x'_2014
estadd local unitfe "Yes", replace
estadd local monthfe "Yes", replace
eststo est`x'
}
end


program runreg
local model `1'
local dv `2'
est clear
di "-----"
di "  Running `model' for `dv'"
di "-----"
foreach x in `dv'{
di "now processing `x'"
`model' `x' 1.treat#1.post i.month, fe vce(robust)
esttab, keep(1.treat#1.post) p
estimates save ${myestimates}`model'_`x'_2014, replace
}
end


program writereg

local filename `1'

esttab using "${tables}`filename'.tex", keep(1.treat#1.post) se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(1.treat#1.post "Post X TIGER" _cons "Constant") mtitles("Contrib" "Users" "New Users" "New Users(6+)" "New Super Users" "Super Users") replace booktabs  s(unitfe monthfe N, label("County FE" "Month FE"))


end

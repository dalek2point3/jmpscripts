program makemeanline

use ${stash}panelfips, clear

* testing
* local var numcontri
* local time quarter
* local varlabel Contributions
* local cutoff 2011

gen quarter = qofd(dofm(month))
format quarter %tq
gen year = yofd(dofm(month))

local var `1'
local time `2'
local cutoff `3'
local varlabel `4'

drop if year > `cutoff'

collapse (mean) mean=`var' (semean) se=`var' , by(`time' treat) 

** replace mean = ln(mean*100000)

sort `time' treat
label variable mean "`varlabel'"

tw (connected mean `time' if treat == 0, msize(small) ) (connected mean `time' if treat == 1, msize(small)), legend(order(2 "TIGER Counties" 1 "Control Counties" )) xtitle("Quarter") title("`varlabel'") xline(191)

graph export ${tables}meanline_`var'.eps, replace
shell epstopdf ${tables}meanline_`var'.eps

end

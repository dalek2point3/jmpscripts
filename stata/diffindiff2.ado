program diffindiff2

// this stores variable names in as t1, t2, t3 and so on
local i = 5
while "``i''" != "" {
    local count = `i' - 4
    local t`count' = "``i''"
    di "var is `t`count''" 
    local ++i
}

local var `1'
local varlabel `2'
local tabname `3'
local mode `4'

di "var: `var', tab: `tabname'"
di "in mode `mode'"

if "`mode'" == "run" {
    di "Running regressions"
    * run_reg `t1' `t2' `t3' `tabname' `var'

    local i = 1
    while "`t`i''" != "" {
        local t "`t`i''"
        di "running `t'"
        * run_reg `t1' `t2' `t3' `tabname' `var'
        local ++i
    }


}

if "`mode'" == "write" {
    di "Writing"
    est clear
    local i = 1
    while "`t`i''" != "" {
        local t "`t`i''"
        di "loading `t'"
        load_reg `t' `tabname' `var' `varlabel'
        local ++i
    }
    write_reg  `tabname' `var' `varlabel'
}


end

program load_reg

local t `1'
local tabname `2'
local var `3'

** est clear
** foreach x in `t1' `t2' `t3'{
estimates use ${myestimates}`tabname'_fips_`t'_`var'
estadd local unitfe "Yes", replace
estadd local monthfe "Yes", replace
eststo est`t'
*}
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

save ${stash}tmp, replace

foreach x in `t1' `t2' `t3'{
est clear

local command "xtpoisson `x' 1.treat#1.post 1.post#1.large 1.treat#1.post#1.large i.month"

di "now running for `t1'"
runcommand tmp "`command'" `tabname'_fips_`x'_`var'

}

end



program write_reg

local tabname `1'
local var `2'
local varlabel `3'

esttab using "${tables}`tabname'_fips_`var'.tex", keep(1.treat#1.post 1.post#1.`var' 1.treat#1.post#1.`var') coeflabels(1.treat#1.post#1.large "TIGER X POST X `varlabel'" 1.treat#1.post "TIGER X POST" 1.post#1.`var' "POST X `varlabel'" ) order(1.treat#1.post#1.large 1.treat#1.post 1.post#1.`var') se ar2 nonotes replace booktabs  s(unitfe monthfe N, label("County FE" "Month FE")) label

end

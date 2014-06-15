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
    di "Running regressions ///"
    local i = 1
    while "`t`i''" != "" {
        local t "`t`i''"
        di "running `t'"
        run_reg `t' `tabname' `var'
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

program run_reg

local t `1'
local tabname `2'
local var `3'

di "----"
di "var: `var', tab: `tabname'"
di "----"

save ${stash}tmp, replace

local command "xtpoisson `t' 1.treat#1.post 1.post#1.`var' 1.treat#1.post#1.`var' i.month"

di "now running for `t'"
di "--"
runcommand tmp "`command'" `tabname'_fips_`t'_`var'
di "--"

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





program write_reg

local tabname `1'
local var `2'
local varlabel `3'

esttab using "${tables}`tabname'_fips_`var'.tex", keep(1.treat#1.post 1.post#1.`var' 1.treat#1.post#1.`var') coeflabels(1.treat#1.post#1.`var' "TIGER X POST X `varlabel'" 1.treat#1.post "TIGER X POST" 1.post#1.`var' "POST X `varlabel'" ) order(1.treat#1.post#1.`var' 1.treat#1.post 1.post#1.`var') se ar2 nonotes replace booktabs  s(unitfe monthfe N N_g, label("County FE" "Month FE" "N" "Clusters")) label

end

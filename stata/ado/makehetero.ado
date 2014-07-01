use ${stash}panelfips, clear

gen popdens = (cntypop / aland_sqmi)

local vars "cntypop popdens emp_earnings percent_white age_median educ_college"

local outcomes "numuser"
local num "50"
bysort fips: gen tag = (_n==1)
gen tmp = .

// generate the median vars
foreach x in `vars'{
    di "`x'"
    egen p`num' = pctile(`x') if tag == 1, p(`num')
    gen p_tmp = (`x' > p`num')
    bysort fips: egen p`num'_`x' = max(p_tmp)
    drop p`num' p_tmp
}

// run regressions
foreach x in `vars'{
    run_reg p`num'_`x'
}

local x cntypop
run_reg 

est clear
foreach x in `vars'{
    di "`x'"
    load_reg numuser hetero1 p`num'_`x'
    di "-----------"
}

write_reg

program run_reg

local var `1'
di "`var'"
replace tmp = `var'

est clear
eststo: xtpoisson numuser 1.post##1.treat##1.tmp i.year, fe vce(robust)
estimates save ${myestimates}hetero1_`var', replace

end

program load_reg

local t `1'
local tabname `2'
local var `3'

di "`t', `var'"
local bb "${myestimates}`tabname'_fips_`t'_`var'"
di "`bb'"
**estimates use ${myestimates}`tabname'_fips_`t'_`var'
estimates use ${myestimates}hetero1_`var'
estadd local unitfe "Yes", replace
estadd local monthfe "Yes", replace
eststo est`var'
end

program write_reg

local var tmp

esttab using "${tables}hetero1.tex", keep(1.post#1.treat 1.post#1.`var' 1.post#1.treat#1.`var' 1.post) order(1.post#1.treat#1.`var' 1.post#1.treat 1.post#1.`var' 1.post) se ar2 nonotes replace booktabs  s(unitfe monthfe N N_g, label("County FE" "Year FE" "N" "Clusters")) coeflabels(1.post#1.treat#1.`var' "TIGER X POST X AboveMedian" 1.post#1.treat "TIGER X POST" 1.post#1.`var' "POST X AboveMedian" 1.post "POST") mtitles("Population" "Pop. Density" "Earnings" "PercentWhite" "Age" "College" "" )

end   
    


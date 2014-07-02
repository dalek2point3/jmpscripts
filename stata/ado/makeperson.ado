program makeperson

use ${stash}cleanchangeset1, clear

drop if fips == "NA"
merge m:1 fips using ${stash}cleancnty, keep(master match) nogen keepusing(treat state)

gen tmp = 1
replace tmp = . if month > mofd(date("10-1-2007","MDY"))

bysort uid: egen avgtreat = mean(treat*tmp)
gen fipstreat = treat
replace treat = avgtreat

// drop lots of data
drop if avgtreat == .
drop tmp avgtreat

genvar
balance

replace treat = (treat > 0.2)

mergebasic

save ${stash}paneluid, replace

end


program genvar

// unit of obs -- user-month
// home county vs. non-home county

bysort uid month: gen numcontrib = _N
sort uid month

sort uid month
bysort uid: gen firstmonth = month[1]

bysort uid: gen firstcounty = fips[1]
gen ishomecounty = (fips == firstcounty)

bysort uid: gen firststate = state[1]
gen ishomestate = (state == firststate)

bysort uid month: egen numcontrib_home = total(ishomecounty)
bysort uid month: egen numcontrib_state = total(ishomestate & !ishomecounty)
bysort uid month: egen numcontrib_other = total(!ishomecounty & !ishomestate)

bysort uid month: egen numcontrib_notreat = total(!ishomecounty & !fipstreat)

bysort uid month: egen numcontrib_statenotreat = total(!ishomecounty & !fipstreat & ishomestate)

bysort uid month: egen numcontrib_treat = total(!ishomecounty & fipstreat)

drop firstc* firsts* is*

bysort uid month fips: gen tmp = (_n==1)
bysort uid month: egen numcounties = total(tmp)
drop tmp

end

program balance

destring uid, gen(unitid)

bysort unitid month: drop if _n > 1

// clean county level vars
** drop change num_changes lat lon fips geoid10 tstamp* region division state cnty* stname county color ua* 

// fill in zeros
tsset unitid month

** this fills in unitid and month from 2005m10 to 2015m5
** this includes blanks if first and last month are missing
tsfill, full

** fill in zeros if missing DVs are present
local outcomes "numcontrib numcontrib_home numcontrib_state numcontrib_other numcontrib_treat numcontrib_notreat numcontrib_statenotreat numcounties"

foreach x in `outcomes'{
    replace `x' = 0 if `x' == .
}

** fill in the covariates
local covars "user treat firstmonth state"

foreach x in `covars'{
    gsort unitid month
    bysort unitid: carryforward `x', gen(tmp1)
    gsort unitid -month
    bysort unitid: carryforward tmp1, gen(tmp2)
    replace `x' = tmp2
    drop tmp1 tmp2
    di "finished `x'"
    di "---"
}

// generate new vars
gen post =  month > mofd(date("10-1-2007","MDY"))
gen year = year(dofm(month))

gsort unitid month
xtset unitid month

end


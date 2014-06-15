program balancepanel

* local unit uid
local unit `0'
* destring `unit', gen(unitid)

bysort unitid month: drop if _n > 1

// clean user level vars
drop change uid num_c lat lon tstamp* minmonth nummonth numusercontrib 

// fill in zeros
tsset unitid month

** this fills in unitid and month from 2005m10 to 2015m5
** this includes blanks if first and last month are missing
tsfill, full

** fill in zeros if missing DVs are present
local outcomes "numcontrib numserious90 numnewusers numnewusers90 numuser numserious95  numnewusers6 numchanges"

foreach x in `outcomes'{
    replace `x' = 0 if `x' == .
}

** fill in the covariates
local covars "fips geoid10 region division state county stname cntyname cntypop color treat uaname uapop uahu uaarea uapopden uaclus"

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


label variable numcontrib "Contrib"
label variable numchanges "Changes"
label variable numuser "Users"
label variable numserious90 "Serious Users"
label variable numserious95 "Serious Users (95)"
label variable numnewusers "New Users"
label variable numnewusers6 "New Users(6+)"
label variable numnewusers6 "New Users(6+)"
label variable numnewusers90 "New Users(Super)"

end


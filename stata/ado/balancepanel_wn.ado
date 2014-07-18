program balancepanel_wn

bysort unitid time: drop if _n > 1

drop change uid num_c lat lon tstamp* mintime numtime numusercontrib month quarter user

** fill in zeros if missing DVs are present
local outcomes 
foreach x of varlist num*{
    local outcomes `outcomes' `x'
}

// fill in zeros
tsset unitid time

** this fills in unitid and month from 2005m10 to 2015m5
** this includes blanks if first and last month are missing
tsfill, full

foreach x in `outcomes'{
    replace `x' = 0 if `x' == .
}

fillcovars

end

program fillcovars

** fill in the covariates
local covars "fips geoid10"

foreach x in `covars'{
    gsort unitid time
    bysort unitid: carryforward `x', gen(tmp1)
    gsort unitid -time
    bysort unitid: carryforward tmp1, gen(tmp2)
    replace `x' = tmp2
    drop tmp1 tmp2
    di "finished `x'"
    di "---"
}


end

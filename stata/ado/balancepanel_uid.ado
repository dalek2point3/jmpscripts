program balancepanel_uid

bysort unitid time: drop if _n > 1

drop change uid num_c lat lon tstamp* mintime numtime numusercontrib month quarter user

** fill in zeros if missing DVs are present
local outcomes "numcontrib numchanges numuser numserious1 numserious2 numserious5 numserious18 numserious56 numserious100 numserious200 numserious560 numnewusers numnewusers_t1 numnewusers_t2 numnewusers_t3 numnewusers_t4 numnewusers_t5 numnewusers_t6 numnewusers_c2 numnewusers_c5 numnewusers_c18 numnewusers_c56 numnewusers_c100 numnewusers_c200 numnewusers_c560 numfirstseen numnonus10 numnonus20 numnonus100"

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

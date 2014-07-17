program makedv_uid

di "**** **** **** **** **** **** "
di "generating county-level vars"
di "**** **** **** **** **** **** "

*local unit fips
*local time quarter

local unit `1'

drop if `unit' == "NA"

gen quarter = qofd(dofm(month))
format quarter %tq
gen time = ${time}

egen unitid = group(`unit')

// useful vars
bysort uid: gen numusercontrib = _N
bysort uid: egen mintime = min(time)

bysort `unit' uid time: gen tmp1 = (_n==1)
bysort `unit' uid: egen numtime = total(tmp1)
drop tmp1

// a) contribs
di "numcontrib"
bysort `unit' time: gen numcontrib = _N
bysort `unit' time: egen numchanges = total(num_changes)

// b) users
di "numuser"
bysort `unit' time uid: gen tmp1 = (_n==1)
bysort `unit' time: egen numusers = total(tmp1)
drop tmp1

// c) serious users
// 90 percentile == 18, 95 is 56
foreach num of numlist 1 2 5 18 56 100 200 560 {
    di "numserious`num'"
    bysort `unit' time uid: gen tmp = (_n==1)*(numuserc > `num')
    bysort `unit' time: egen numserious`num' = total(tmp)
    label variable numserious`num' "Users (`num'+)"
    drop tmp
}

// d) new users

// new users
di "numnewusers"
bysort `unit' time uid: gen tmp1 = (_n==1) * (time==mintime)
bysort `unit' time: egen numnewusers = total(tmp1)
drop tmp1 

// new committed users
foreach num of numlist 1 2 3 4 5 6 {
    di "numnewusers_t`num'"
    bysort `unit' time uid: gen tmp1 = (_n==1) * (time==mintime) * (numtime >= `num')
    bysort `unit' time: egen numnewusers_t`num' = total(tmp1)
    label variable numnewusers_t`num' "New Users (`num')"
    drop tmp1
}

// new super users
foreach num of numlist 1 2 5 18 56 100 200 560 {
    di "numserious_c`num'"
    bysort `unit' time uid: gen tmp1 = (_n==1) * (time==mintime) * (numuserc >= `num')
    bysort `unit' time: egen numnewusers_c`num' = total(tmp1)
    label variable numnewusers_c`num' "New Users (`num')"
    drop tmp1
}


// new first time users in unit
di "numfirstseen"
sort `unit' uid time
bysort `unit' uid: gen tmp1 = (_n==1)
bysort `unit' time: egen numfirstseen = total(tmp1)
drop tmp1

// e) Non US Users

// Non US users above a certain threshold for first edits
foreach num of numlist 10 20 100 {
    di "nonus`num'"
    bysort `unit' time uid: gen tmp = (_n==1)*(nonus`num' > `num' - 2)
    bysort `unit' time: egen numnonus`num' = total(tmp)
    label variable numnonus`num' "Int. Users (`num'+)"
    drop tmp
}

// create labels
label variable numchanges "Changes"
label variable numcontrib "Contrib"
label variable numusers "Users"
label variable numnewusers "New Users"
label variable numfirstseen "News Users(F)"



di "**** **** **** **** **** **** "


end

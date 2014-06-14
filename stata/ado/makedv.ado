program makedv

* use ${stash}mergemaster1, clear

// unit = fips, geoid10 or tileid

local unit `0'
* local unit "uid"

drop if `unit' == "NA"

egen unitid = group(`unit')
genvar unitid

end

program genvar

local unit `1'

// useful vars
bysort uid: gen numusercontrib = _N
bysort uid: egen minmonth = min(month)

bysort `unit' uid month: gen tmp1 = (_n==1)
bysort `unit' uid: egen nummonth = total(tmp1)
drop tmp1

// a) contribs
bysort `unit' month: gen numcontrib = _N
bysort `unit' month: egen numchanges = total(num_change)

// b) users
bysort `unit' month uid: gen tmp1 = (_n==1)
bysort `unit' month: egen numuser = total(tmp1)
drop tmp1

// c) serious users
// 90 percentile == 18, 95 is 56

bysort `unit' month uid: gen tmp1 = (_n==1)*(numuserc > 18)
bysort `unit' month: egen numserious90 = total(tmp1)

bysort `unit' month uid: gen tmp2 = (_n==1)*(numuserc > 56)
bysort `unit' month: egen numserious95 = total(tmp2)
drop tmp1 tmp2

// d) new users

// new users
bysort `unit' month uid: gen tmp1 = (_n==1) * (month==minmonth)
bysort `unit' month: egen numnewusers = total(tmp1)
drop tmp1 

// new committed users
bysort `unit' month uid: gen tmp1 = (_n==1) * (month==minmonth) * (nummonth >= 6)
bysort `unit' month: egen numnewusers6 = total(tmp1)
drop tmp1

// new super users
bysort `unit' month uid: gen tmp1 = (_n==1) * (month==minmonth) * (numuserc >= 18)
bysort `unit' month: egen numnewusers90 = total(tmp1)
drop tmp1

end


program makedv

local unit `1'
local mode `2'

drop if `unit' == "NA"

egen unitid = group(`unit')
genvar unitid

if "`mode'" == "node"{
    gennodevar unitid
}

if "`mode'" == "way"{
    genwayvar unitid
}

if "`mode'" == ""{
    genchangevar unitid
}

end


program genchangevar

local unit `1'
di "generating change-specific vars"
bysort `unit' month: egen numchanges = total(num_change)

end


program gennodevar

local unit `1'
di "generating node-specific vars"

// note: things can have multiple tags
// num amenity
bysort `unit' month: gen tmp1 = (amenity!="NA")
bysort `unit' month: egen numamenity = total(tmp1)
drop tmp1

// num address
bysort `unit' month: gen tmp1 = (addr!="NA")
bysort `unit' month: egen numaddr = total(tmp1)
drop tmp1

end


program genwayvar

local unit `1'
di "generating way-specific vars"


// gen userfulvars
gen istiger = (tigercfcc == "NA" & tigercounty == "NA" & highway != "NA")


// non tiger highways added
bysort `unit' month: gen tmp1 = (highway!="NA")

tab version if tigercfcc != "NA"
tab version if tigercfcc == "NA" & highway != "NA"







                                     

                                     
count if highway != "NA"
count if highway != "NA" & tigercfcc != "NA"



// tiger highways updated

// metadata added

// buildings / amenities added // parking added




// highway, amenity, building, parking
// access, oneway, maxspeed, lanes



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

// new first time users in unit
sort `unit' uid month
bysort `unit' uid: gen tmp1 = (_n==1)
bysort `unit' month: egen numfirstseen = total(tmp1)
drop tmp1

end


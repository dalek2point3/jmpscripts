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


program genvar

di "generating county-level vars"

local unit `1'

// useful vars
bysort uid: gen numusercontrib = _N
bysort uid: egen minmonth = min(month)

bysort `unit' uid month: gen tmp1 = (_n==1)
bysort `unit' uid: egen nummonth = total(tmp1)
drop tmp1

// a) contribs
di "numcontrib"
bysort `unit' month: gen numcontrib = _N


// b) users
di "numuser"
bysort `unit' month uid: gen tmp1 = (_n==1)
bysort `unit' month: egen numuser = total(tmp1)
drop tmp1

// c) serious users
// 90 percentile == 18, 95 is 56
di "numserious90, numserious95"
bysort `unit' month uid: gen tmp1 = (_n==1)*(numuserc > 18)
bysort `unit' month: egen numserious90 = total(tmp1)

bysort `unit' month uid: gen tmp2 = (_n==1)*(numuserc > 56)
bysort `unit' month: egen numserious95 = total(tmp2)
drop tmp1 tmp2

// d) new users

// new users
di "numnewusers"
bysort `unit' month uid: gen tmp1 = (_n==1) * (month==minmonth)
bysort `unit' month: egen numnewusers = total(tmp1)
drop tmp1 

// new committed users
di "numnewusers6"
bysort `unit' month uid: gen tmp1 = (_n==1) * (month==minmonth) * (nummonth >= 6)
bysort `unit' month: egen numnewusers6 = total(tmp1)
drop tmp1

// new super users
di "numnewusers90"
bysort `unit' month uid: gen tmp1 = (_n==1) * (month==minmonth) * (numuserc >= 18)
bysort `unit' month: egen numnewusers90 = total(tmp1)
drop tmp1

// new first time users in unit
di "numfirstseen"
sort `unit' uid month
bysort `unit' uid: gen tmp1 = (_n==1)
bysort `unit' month: egen numfirstseen = total(tmp1)
drop tmp1

end

program genchangevar

local unit `1'
di "generating change-specific vars"
bysort `unit' month: egen numchanges = total(num_change)

end

//////////////////////////////
/// GEN WAY VAR
//////////////////////////////
    
program genwayvar

local unit `1'
di "generating way-specific vars"

// gen userfulvars
gen ishighway = (highway!="NA")
gen isbuilding = (building!="NA")
gen isparking = (parking!="NA")
gen isamenity = (amenity!="NA")

gen type = ""
replace type = type + "highway " if ishighway == 1
replace type = type + "building " if isbuilding == 1
replace type = type + "parking " if isparking == 1
replace type = type + "amenity " if isamenity == 1

gen istiger = (tigercfcc == "NA" & tigercounty == "NA" & highway != "NA")
replace istiger = !istiger
replace istiger = . if ishighway == 0

gen hasattrib = (maxspeed != "NA") | (oneway != "NA") | (lanes != "NA") | (access != "NA")
replace hasattrib = . if ishighway == 0

makehighwayclass

// highway, building, parking, amenity

// outcomes
// how many highway, building, amenity were added?
bysort `unit' month: egen numhighway = total(ishighway)
bysort `unit' month: egen numbuilding = total(isbuilding)
bysort `unit' month: egen numamenity = total(isamenity)
bysort `unit' month: egen numparking = total(isparking)
bysort `unit' month: gen numways = _N

// how many non tiger highway added?
bysort `unit' month: egen numnontiger = total(ishighway*(istiger==0))

// how many tiger ways touched?
bysort `unit' month: egen numtiger = total(ishighway*(istiger==1))

// how many of different classes
forvalues x = 1/4{
    bysort `unit' month: egen numclass`x' = total(ishighway*(highwayclass==`x'))
}    

//how many attrib
bysort `unit' month: egen numattrib = total(hasattrib)

//attrib by class
forvalues x = 1/4{
    bysort `unit' month: egen numclass`x' = total(ishighway*(highwayclass==`x'))
}    


end

program makehighwayclass

gen highwayclass = .
replace highwayclass = 1 if highway == "motorway"
replace highwayclass = 1 if highway == "motorway_link"
replace highwayclass = 1 if highway == "trunk"
replace highwayclass = 1 if highway == "trunk_link"

replace highwayclass = 2 if highway == "primary"
replace highwayclass = 2 if highway == "primary_link"
replace highwayclass = 2 if highway == "secondary"
replace highwayclass = 2 if highway == "secondary_link"

replace highwayclass = 3 if highway == "tertiary"
replace highwayclass = 3 if highway == "tertiary_link"
replace highwayclass = 3 if highway == "residential"
replace highwayclass = 3 if highway == "unclassified"
replace highwayclass = 3 if highway == "road"
replace highwayclass = 3 if highway == "service"

replace highwayclass = 4 if highway == "footway"
replace highwayclass = 4 if highway == "track"
replace highwayclass = 4 if highway == "path"
replace highwayclass = 4 if highway == "cycleway"
replace highwayclass = 4 if highway == "pedestrian"
replace highwayclass = 4 if highway == "steps"

replace highwayclass = -1 if ishighway == 1 & highwayclass == .

end

// GEN NODE VAR

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


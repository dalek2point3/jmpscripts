program makedv_wn

di "**** **** **** **** **** **** "
di "generating county-level vars"
di "**** **** **** **** **** **** "

local unit `1'
local unit fips

drop if `unit' == "NA"

gen quarter = qofd(dofm(month))
format quarter %tq
gen time = ${time}

egen unitid = group(`unit')

// generate useful vars
gen ishighway = (highway!="NA")*(isnode==0)
gen isbuilding = (building!="NA")*(isnode==0)
gen isparking = (parking!="NA")*(isnode==0)
gen isamenity = (amenity!="NA")
gen isaddr = (addr!="NA")*(isnode==1)

makehighwayclass
replace highwayclass = -1 if ishighway == 1 & highwayclass == .

// highway attrib
gen hasattrib = (maxspeed != "NA") | (oneway != "NA") | (lanes != "NA") | (access != "NA")
replace hasattrib = . if ishighway == 0

// tiger
gen istiger = (tigercfcc == "NA" & tigercounty == "NA" & highway != "NA")
replace istiger = !istiger
replace istiger = . if ishighway == 0

// outcomes
// how many highway, building, amenity were added?
bysort `unit' month: egen numhighway = total(ishighway)
bysort `unit' month: egen numbuilding = total(isbuilding)
bysort `unit' month: egen numamenity = total(isamenity)
bysort `unit' month: egen numparking = total(isparking)
bysort `unit' month: gen numways = _N

// how many non tiger highway added?
bysort `unit' month: egen numnontiger = total(ishighway*(istiger==0))

// how many of different classes
forvalues x = 1/4{
    bysort `unit' month: egen numclass`x' = total(ishighway*(highwayclass==`x'))
}    

//how many attrib
bysort `unit' month: egen numattrib = total(hasattrib)

//attrib by class
forvalues x = 1/4{
    bysort `unit' month: egen numattrib`x' = total(ishighway*(highwayclass==`x')*(hasattrib==1))
}    

// addresses
bysort `unit' month: egen numaddr = total(isaddr)

end

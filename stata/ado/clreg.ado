insheet using ${rawosm}cl_notes_gc.csv, clear

rename v1 timestamp
rename v2 id
rename v3 lat
rename v4 lon
rename v5 link
rename v6 status
rename v7 fips
rename v8 geoid10

drop if fips == "NA"

merge m:1 fips using ${stash}cleancnty

drop if _m == 1

gen isbug = (id!=.)

** merge m:1 geoid10 using ${stash}cleanua, keep(master match) nogen

bysort fips: egen hasurban = total((geoid10!="NA"))
replace hasurban = (hasurban > 0)

local unit fips

bysort `unit': egen bugs = total(isbug)
bysort `unit': egen open = total(status=="open")
bysort `unit': egen closed = total(status=="closed")

bysort `unit': drop if _n > 1

drop if geoid10 == ""

gen percent = closed / (closed + open)
gen c2 = cntypop^2
gen isc = (status == "closed")


reg bugs treat, robust

reg bugs treat##hasurb cntypop c2, robust


poisson bugs treat cntypop c2, robust

gen hasbugs = bugs > 0
gen hasopen = open > 0

logit hasbugs treat cntypop c2, robust


reg bugs treat##hasurban cntypop c2, robust

probit bugs treat##hasurban cntypop c2, robust


tab treat hasurban


reg bugs treat cntypop c2, robust

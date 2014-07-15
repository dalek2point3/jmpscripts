program county_pop

local dat_name "${rawmaps}us.1990_2012.singleages.adjusted.txt"

local dta_name "${rawmaps}seer_pop"

local dct_name "${rawmaps}seer_pop.dct"

infile using "`dct_name'", using("`dat_name'") clear

gen str3 tmp1=string(county, "%03.0f")
gen str2 tmp2=string(stfips, "%02.0f")
gen fips = tmp2 + tmp1
drop tmp1 tmp2

drop if year < 2005
bysort year fips: egen pop_year = total(pop)

bysort year fips: drop if _n > 1
keep year fips pop_year

expolate

save ${rawmaps}county_pop, replace

end

program expolate

bysort fips: gen tmp = _N
drop if tmp < 8

local num = 3138

local new = _N + (`num'*2)
set obs `new'

sort year fips
replace fips = fips[_n-`num'*8] if fips == "" & _n < (_N+`num')

sort fips year
bysort fips: replace year = 2013 if year == . & _n == 9
bysort fips: replace year = 2014 if year == . & _n == 10

bysort fips: ipolate pop_year year, gen (y2) epolate
replace pop_year = y2 if pop_year == .

drop tmp

end








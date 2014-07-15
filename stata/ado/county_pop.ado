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

save ${rawmaps}county_pop, replace


end

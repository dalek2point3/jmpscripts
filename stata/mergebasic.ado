program mergebasic
use ${stash}cleanchangeset1, clear

drop if fips == "NA"

merge m:1 fips using ${stash}cleancnty, keep(master match) nogen

merge m:1 geoid10 using ${stash}cleanua, keep(master match) nogen

gen post =  month > mofd(date("10-1-2007","MDY"))
gen year = year(tstamp_date)

save ${stash}mergemaster1, replace
end

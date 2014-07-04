program preparecl

insheet using ${clist}areas_geo.tsv, clear
rename v1 state
rename v2 areaname
rename v3 lat
rename v4 lon
rename v5 hostname
rename v6 country
rename v7 fips
rename v8 geoid10
save ${stash}cl_tmp, replace

insheet using ${clist}cl_parsed.tsv, clear
rename v1 postid
rename v2 ismap
rename v3 ispic
rename v4 date
rename v5 price
rename v6 section
rename v7 link
rename v8 area
rename v9 hostname
drop v10

merge m:1 hostname using ${stash}cl_tmp, keep(match) nogen

drop if fips == "NA"
drop state country

save ${clist}clpostings, replace

use ${clist}clpostings, clear

merge m:1 fips using ${stash}cleancnty, keep(match) nogen

merge m:1 geoid10 using ${stash}cleanua, keep(master match) nogen

save ${clist}mergemaster1_cl, replace

end


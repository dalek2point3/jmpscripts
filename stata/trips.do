clear
set more off

global path "/mnt/nfs6/wikipedia.proj/jmp/"
global rawosm "/mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/"
global rawmaps "/mnt/nfs6/wikipedia.proj/jmp/rawdata/maps/"
global rawtrips "/mnt/nfs6/wikipedia.proj/jmp/rawdata/trips/"
global stash "/mnt/nfs6/wikipedia.proj/jmp/rawdata/stash/"

cd `path'

********************************************
*************** datasets ********************
********************************************

insheet using ${rawtrips}trips_oct-feb_final.csv, clear

renamevar

trimvar

gennewtripvar

merge m:1 fips using ${rawmaps}county_lookup, keep(match) nogen

genmapvar

savetemp 1


// wilmingoton -- 95833
// charleston -- 15508

tabstat summsa if geoid10 == 95833
tabstat summsa if geoid10 == 15508

unique device if geoid10 == 95833
unique device if geoid10 == 15508


reg1



///// program library

program drop renamevar
program renamevar
rename v1 timeutc
rename v2 deviceuid
rename v3 lat
rename v4 lon
rename v5 trackstart
rename v6 featureid
rename v7 speed
rename v8 azimuth
rename v9 altitude
rename v10 cnt
rename v11 numtrips
rename v12 isnewtrip
rename v13 geoid10
rename v14 fips
end

program drop trimvar
program trimvar
drop if cnt == "cnt"
keep timeutc fips geoid10 numtrips cnt device lat lon
drop if fips == "NA"
drop if geoid == "NA"
destring, replace
end

program drop makecountylookup
program makecountylookup
insheet using ${rawmaps}county_lookup.csv, clear
keep name state_name fips treat area population color
save ${rawmaps}county_lookup, replace
end

// TODO
program drop makemsalookup
program makemsalookup
insheet using ${rawmaps}CSA-EST2013-alldata.csv, clear
drop if cbsa == .
end

program drop savetemp
program savetemp
save `stash'tmp`1', replace
end

program drop gennewtripvar
program gennewtripvar

gen x_tmp = round(lon, .01)
gen y_tmp = round(lat, .01)
gen tilename = string(x_tmp) + " / " + string(y_tmp)
egen tileid = group(tilename)

bysort fips: gen sumcounty = _N
bysort fips: gen fips_flag = (_n == 1)

bysort geoid10: gen summsa = _N
bysort geoid10: gen msa_flag = (_n == 1)

bysort tileid: gen sumtile = _N
bysort tileid: gen tile_flag = (_n == 1)

end

program drop genmapvar
program genmapvar

gen p2 = (population*population)
gen a2 = (area*area)

gen tmp_treat_fips = (treat) if fips_f == 1
gen tmp_treat_tile = (treat) if tile_f == 1

bysort geoid: egen avgtreat_msa = mean(tmp_treat_fips)
gen mixedmsa = (avgtreat > 0.1 & avgtreat < 0.9)

bysort geoid: egen numcounty = sum(fips_f)

end

program drop reg1
program reg1

tab treat if tile_f == 1

gen lnsumtile = ln(sumtile)

reg sumtile treat area a2 pop p2 if tile_f == 1

set matsize 11000

reg sumtile treat area a2 pop p2 i.geoid if tile_f == 1

& mixedmsa == 1

poisson sumtile treat area a2 pop p2 i.geoid if tile_f == 1 & mixedmsa == 1



poisson sumtile treat area a2 pop p2 if tile_f == 1, irr




codebook pop if fips_f == 1

tab name if pop > 60 & fips_f == 1, sort

codebook geoid if msa_f == 1 & avgtreat > 0.1 & avgtreat < 0.9

codebook geoid10 if mixedmsa == 1
codebook fips if mixedmsa == 1


list fips treat avgtreat if geoid10 == 16264 & fips_f == 1 
gen lnumc = ln(sumcounty)

reg lnumc  treat population p2 area a2 i.geoid10 if mixedmsa == 1 & fips_f == 1 & sumcnty > 10

reg sumcounty treat population p2 area a2 i.geoid10 if mixedmsa == 1 & fips_f == 1 & sumcnty > 10


reg sumcounty treat if fips_f ==1 & mixedmsa == 1


tab sumcnty if mixedmsa == 1



reg sumcounty treat population p2 area a2 if fips_flag == 1

reg sumcounty treat population p2 if fips_flag == 1

reg sumcounty treat population p2 if fips_flag == 1 & 


reg summsa treat population if msa_flag == 1


end

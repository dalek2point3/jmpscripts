clear
set more off

global path "/mnt/nfs6/wikipedia.proj/jmp/"
global rawosm "/mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/"
global rawmaps "/mnt/nfs6/wikipedia.proj/jmp/rawdata/maps/"
global rawtrips "/mnt/nfs6/wikipedia.proj/jmp/rawdata/trips/"
global stash "/mnt/nfs6/wikipedia.proj/jmp/rawdata/stash/"
global myestimates "/mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/estimates/"
global tables "/mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/tables/"

cd `path'

********************************************
*************** datasets ********************
********************************************

insheet using ${rawtrips}trips_oct-feb_final.csv, clear

renamevar

trimvar

savetemp 1
usetemp 1

gentripvar

merge m:1 fips using ${rawmaps}county_lookup, keep(match) nogen

genmapvar

savetemp 2
usetemp 2

// find counts for wilmingoton -- 95833 & charleston -- 15508

tabstat summsa if geoid10 == 95833
tabstat summsa if geoid10 == 15508

unique device if geoid10 == 95833
unique device if geoid10 == 15508

// cross sectional regression
crossreg1
makecrosstable


//////////////////////////////
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

program drop usetemp
program usetemp
use `stash'tmp`1', clear
end


program drop gentripvar
program gentripvar

gen x_tmp = round(lon, .01)
gen y_tmp = round(lat, .01)
gen tilename = string(x_tmp) + " / " + string(y_tmp)
egen tileid = group(tilename)

bysort fips: gen sumcounty = _N
bysort fips device: gen tmp = (_n==1)
bysort fips: egen sumcounty_device = sum(tmp)
bysort fips: gen fips_flag = (_n == 1)

bysort geoid10: gen summsa = _N
bysort geoid10 device: replace tmp = (_n==1)
bysort geoid10: egen summsa_device = sum(tmp)
bysort geoid10: gen msa_flag = (_n == 1)

bysort tileid: gen sumtile = _N
bysort tileid device: replace tmp = (_n==1)
bysort tileid: egen sumtile_device = sum(tmp)
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

program drop crossreg1
program crossreg1

est clear
foreach x in "" "_d" {
    eststo: poisson sumtile`x' treat area a2 pop p2 if tile_f == 1
    estadd local blockfe "Yes", replace
    estadd local monthfe "Yes", replace
    estimates save "${myestimates}cross1`x'", replace
}
end

program drop makecrosstable
program makecrosstable

est clear
foreach x in "" "_d"{
estimates use ${myestimates}cross1`x'
eststo est1`x'
}

esttab using "${tables}cross1.tex", keep(treat) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(Treat "Treat" _cons "Constant") mtitles("Num. Trips" "Num. Users") replace booktabs  s(blockfe monthfe N, label("Size Controls" "Population Controls")) width(0.75\hsize)

end






eststo: xtpoisson `x' 1.post#1.istreat i.month msadummy*, vce(robust) irr fe



est clear
eststo: poisson sumtile treat if tile_f == 1


poisson sumtile_d treat if tile_f == 1
poisson sumtile_d treat area a2 pop p2 if tile_f == 1




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

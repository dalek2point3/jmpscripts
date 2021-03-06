/// 0. program lib for prepare basic data
// THIS PROGRAM MAKES THE CHANGESET FILE
// AND THE CLEAN COUNTY FILE

program preparebasic

// 0.1 clean changeset data
insheet using ${osmchange}changesets-geocoded.csv, clear
insheet using ${osmchange}world-geocode.csv, clear
renamevar
cleanvar
droplargeuser
save ${stash}cleanchangeset1, replace

// 0.2 clean Urban Area (UA) data
import excel ${rawmaps}ua_list_all.xls, clear firstrow
qui cleanua
save ${stash}cleanua, replace

// 0.3.1 clean my county color data
// TODO: doublecheck the color data
insheet using ${rawmaps}county_lookup.csv, clear
// TODO: calculate area
// TODO: match to census data from
// http://www.census.gov/support/USACdataDownloads.html#PEN
// American Fact Finder - "download center"

keep fips color treat
gen str5 fips2 = string(fips, "%05.0f")
drop fips
rename fips2 fips
save ${stash}countylookup, replace

// 0.3.2.1 clean related county data == census (race, pop)
census_pop

// 0.3.2.2 make annual population file (seer data)
county_pop

// 0.3.3 clean related county data == acs (educ, income etc)
acs_pop

// 0.3.4 area (adds land area for county)
savearea

// 0.3.5 clean county data and merge

insheet using ${rawmaps}CO-EST2012-Alldata.csv, clear
cleancnty

merge 1:1 fips using ${stash}countylookup, keep(match) nogen

merge 1:1 fips using ${rawmaps}census_pop, keep(match) nogen

merge 1:1 fips using ${rawmaps}acs, keep(match) nogen

merge 1:1 fips using ${stash}area_tmp, keep(match) nogen

save ${stash}cleancnty, replace

end


program savearea

insheet using ${rawmaps}area.txt, clear names

gen str5 fips = string(geoid, "%05.0f")
keep fips aland_sqmi

save ${stash}area_tmp, replace

end


program cleancnty

// TODO: add income, race, poverty information
// layout: http://www.census.gov/popest/data/counties/totals/2012/files/CO-EST2012-alldata.pdf


// this drops all the states
drop if sumlev == 40

gen str5 fips = string(state, "%02.0f") + string(county, "%03.0f")
rename census2010 cntypop
rename ctyname cntyname

keep fips region division state county stname cntyname cntypop

end

program cleanua
// see here for descriptions:
// http://www.census.gov/geo/reference/ua/ualists_layout.html

// UACE and geoid10 are the same thing
rename UACE geoid10
rename NAME uaname
rename POP uapop
rename HU uahu
rename AREALANDSQMI uaarealand
rename POPDEN uapopden
gen uaclustertype = "area" if LSADC == "75"
replace uaclustertype = "cluster" if LSADC == "76"
drop AREA* LSADC
end

program droplargeuser
// drop large users
// TODO: make this process more systematic?
drop if user == "DaveHansenTiger"
drop if user == "woodpeck_fixbot"
drop if user == "woodpeck_repair"
drop if user == "nmixter"
drop if user == "jumbanho"
drop if user == "-"
drop if user == "balrog-kun"
drop if user == "jremillard-massgis"
drop if user == "pnorman_mechanical"
drop if user == "CanvecImports"
drop if user == "TIGERcnl"
drop if user == "canvec_fsteggink"
drop if user == "OSMF Redaction Account"
drop if user == "bot-mode"
drop if num_changes > 40000
end

program renamevar
rename v1 changesetid
rename v2 uid
rename v3 created_at
rename v4 min_lat
rename v5 max_lat
rename v6 min_lon
rename v7 max_lon
rename v8 closed_at
rename v9 open
rename v10 num_changes
rename v11 user
rename v12 lat
rename v13 lon
rename v14 fips
rename v15 geoid10
end

program cleanvar

gen tstamp = clock(created_at, "YMD#hms#")
format tstamp %tc

gen tstamp_date = dofc(tstamp)
format tstamp_date %td

gen month = mofd(tstamp_date)
format month %tm

drop if abs(min_lat - max_lat) > 1
drop if abs(min_lon - max_lon) > 1

find_nonus

// drop non-US changesets
drop if fips == "NA" & geoid10 == "NA"
drop if fips == "I"

drop open closed_at created_at min_* max_* 

end

program find_nonus

sort uid tstamp
gen tmp = (fips=="NA" & geoid10=="NA")
replace tmp = 1 if fips == "I"

bysort uid: egen nonus = total(tmp)
bysort uid: egen nonus10 = total(tmp & _n < 11)
bysort uid: egen nonus20 = total(tmp & _n < 21)
bysort uid: egen nonus100 = total(tmp & _n < 101)
drop tmp

end



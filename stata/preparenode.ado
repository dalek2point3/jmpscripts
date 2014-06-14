insheet using ${rawhist}way_gc.csv, clear

rename v1 highway
rename v2 amenity
rename v3 building
rename v4 parking
rename v5 user
rename v6 uid
rename v7 timestamp
rename v8 version
rename v9 changeset
rename v10 lat
rename v11 lon
rename v12 id
rename v13 name
rename v14 tigercfcc
rename v15 tigercounty
rename v16 tigerr
rename v17 access
rename v18 oneway
rename v19 maxspeed
rename v20 lanes
rename v41 fips
rename v42 geoid10
drop v21-v40


insheet using ${rawhist}node_gc.csv, clear

renamevar
cleanvar

mergevar

save ${stash}tmp, replace

program drop _all

makedv fips
// TODO: makevar
// TODO: balancepanel

save ${stash}tmp2, replace

xtpoisson numcontrib 1.treat#1.post i.month, fe vce(robust)

xtpoisson numcontrib 1.treat#1.post i.month, fe vce(robust)

xtpoisson numcontrib 1.treat#1.post i.year, fe vce(robust)

xtpoisson numuser 1.treat#1.post i.month, fe vce(robust)


program mergevar

merge m:1 fips using ${stash}cleancnty, keep(master match) nogen

end


program cleanvar

gen tstamp = timestamp*1000 + msofhours(24)*3653 - msofhours(5)
format tstamp %tc

gen tstamp_date = dofc(tstamp)
format tstamp_date %td

gen month = mofd(tstamp_date)
format month %tm

drop if month == .

// drop non-US items
drop if fips == "NA" & geoid10 == "NA"

// drop gnis data
drop if gnisfid != "NA" & version == 1


end


program renamevar
rename v1 amenity
rename v2 addr
rename v3 place
rename v4 user
rename v5 uid
rename v6 timestamp
rename v7 version
rename v8 changeset
rename v9 lon
rename v10 lat
rename v11 id
rename v12 name
rename v13 gnisfid
rename v14 gnisfcode
rename v15 fips
rename v16 geoid10
end




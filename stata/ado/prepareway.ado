insheet using ${rawhist}way_gc.csv, clear

renamevar
cleanvar
droplargeuser
** mergevar

save ${stash}mergemaster_way, replace

** save ${stash}way_stash2, replace
**use ${stash}way_stash, clear


program renamevar

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

end

program droplargeuser

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
drop if user == "Milenko"

end


program cleanvar

drop if timestamp == "NA"
drop if timestamp == ""
drop if lon == "NA"

destring timestamp, replace
destring version, replace
destring lon, replace

gen tstamp = timestamp*1000 + msofhours(24)*3653 - msofhours(5)
format tstamp %tc

gen tstamp_date = dofc(tstamp)
format tstamp_date %td

gen month = mofd(tstamp_date)
format month %tm

// drop non-US items
drop if fips == "NA" & geoid10 == "NA"

end




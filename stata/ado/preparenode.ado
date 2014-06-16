insheet using ${rawhist}node_gc.csv, clear

renamevar
cleanvar
droplargeuser
mergevar

save ${stash}mergemaster_node, replace

program makenodevar

use ${stash}mergemaster_node, clear

makedv fips node

program drop _all




end


program mergevar

drop if fips == "NA"
merge m:1 fips using ${stash}cleancnty, keep(master match) nogen
merge m:1 geoid10 using ${stash}cleanua, keep(master match) nogen

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




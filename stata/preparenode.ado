
insheet using ${rawhist}node_gc.csv, clear

renamevar
cleanvar


program cleanvar

gen tstamp = timestamp*1000 + msofhours(24)*3653 - msofhours(5)
format tstamp %tc

gen tstamp_date = dofc(tstamp)
format tstamp_date %td

gen month = mofd(tstamp_date)
format month %tm

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




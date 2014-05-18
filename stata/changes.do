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

insheet using ${rawosm}ne_final_head.csv, clear
insheet using ${rawosm}ne_final_sed.csv, clear

renamevar

keepvar

gennewvar


//// programlib
program drop keepvar
program keepvar

// drop non US
drop if fips == "NA" & geoid10 == "NA" 
drop if otype == "v1"

gen keeptag = 0

local keeplist "building amenity highway maxspeed gnisfcode gnisfeatureid oneway waterway natural place leisure foot access wheelchair cycleway addr sidewalk import_uuid"

foreach x in `keeplist' {
    capture replace keeptag = 1 if `x' != ""
    capture replace keeptag = 1 if `x' != .    
}

drop if keeptag == 0
drop keeptag

end



program drop renamevar
program renamevar
rename v1 otype
rename v2 id
rename v3 lon
rename v4 lat
rename v5 version
rename v6 timestamp
rename v7 changeset
rename v8 uid
rename v9 user
rename v10 highway
rename v11 name
rename v12 amenity
rename v13 building
rename v14 waterway
rename v15 natural
rename v16 oneway
rename v17 maxspeed
rename v18 place
rename v19 leisure
rename v20 foot
rename v21 access
rename v22 wheelchair
rename v23 cycleway
rename v24 gnisfeatureid
rename v25 gnisfcode
rename v26 nhdfcode
rename v27 addr
rename v28 import_uuid
rename v29 sidewalk
rename v30 lon_tmp
rename v31 lat_tmp
rename v32 tilename
rename v33 geoid10
rename v34 msaname
rename v35 x_tmp
rename v36 y_tmp
rename v37 fips
rename v38 countyname
rename v39 class
rename v40 mergevar
end


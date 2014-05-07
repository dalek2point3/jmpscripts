clear
set more off

local path "/mnt/nfs6/wikipedia.proj/jmp/"
local rawosm "/mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/"
local rawmaps "/mnt/nfs6/wikipedia.proj/jmp/rawdata/maps/"
local stash "/mnt/nfs6/wikipedia.proj/jmp/rawdata/stash/"

cd `path'


// Steps
// 1. create csv files with non problematic tile ids and dta file
// 2. process osm history data into csv and clean for quote
// 3. match history data to cleant tiles

// Create the tile DTA file
insheet using `rawmaps'goodtiles_county.csv, clear
gen x_tmp = round(v2, .01)
gen y_tmp = round(v3, .01)
rename v4 fips
gen tilename = string(x_tmp) + " / " + string(y_tmp)
rename v5 countyname

outsheet tilename fips using `rawmaps'tilenames_county, replace
save `rawmaps'goodtiles_county, replace

insheet using `rawmaps'goodtiles_msa.csv, clear
gen x_tmp = round(v2, .01)
gen y_tmp = round(v3, .01)
rename v4 geoid10
gen tilename = string(x_tmp) + " / " + string(y_tmp)

outsheet tilename geoid using `rawmaps'tilenames_msa.csv, replace
save `rawmaps'goodtiles_msa, replace

// merge to create tile lookup
use `rawmaps'goodtiles_msa, clear

merge 1:1 tilename using `rawmaps'goodtiles_county

drop v1 v2 v3 
gen class = ""
replace class = "both" if _m == 3
replace class = "msa" if _m == 1
replace class = "county" if _m == 2

drop _merge

save `rawmaps'tilelookup, replace
outsheet using `rawmaps'tilelookup.csv, replace


// Identify points that do not need to be classified

insheet using `rawosm'test.csv, clear

gen lon_tmp = 0.01 * floor(lon/0.01) 
gen lat_tmp = 0.01 * floor(lat/0.01) 

gen tilename = string(lon_tmp) + " / " + string(lat_tmp)

merge m:1 tilename using `rawmaps'goodtiles
, keep(match master)

outsheet id lon lat _merge using `stash'test.csv if _m !=2, replace


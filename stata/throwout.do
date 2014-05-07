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
insheet using `rawmaps'goodtiles_small.csv, clear

gen x_tmp = round(v2, .01)
gen y_tmp = round(v3, .01)
rename v4 cnty_fips
gen tilename = string(x_tmp) + " / " + string(y_tmp)
save `rawmaps'goodtiles, replace

// Identify points that do not need to be classified

insheet using `rawosm'test.csv, clear

gen lon_tmp = 0.01 * floor(lon/0.01) 
gen lat_tmp = 0.01 * floor(lat/0.01) 

gen tilename = string(lon_tmp) + " / " + string(lat_tmp)

merge m:1 tilename using `rawmaps'goodtiles
, keep(match master)

outsheet id lon lat _merge using `stash'test.csv if _m !=2, replace


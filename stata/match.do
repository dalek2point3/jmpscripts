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

// Identify points that do not need to be classified

local filenum 00
local region mw
args filenum region

di "now processing `filenum'"
di "now processing `region'"

insheet using `rawosm'`region'chunk/`region'`filenum'.csv, clear nonames

drop if _n == 1 & v1[1] == "@oname" 

rename v9 username
drop if username == "DaveHansenTiger"
drop if username == "woodpeck_fixbot"
drop if username == "nmixter"
drop if username == "jumbanho"
drop if username == "MassGIS Import"

destring v3 v4, replace
gen lon_tmp = 0.01 * floor(v3/0.01) 
gen lat_tmp = 0.01 * floor(v4/0.01) 

gen tilename = string(lon_tmp) + " / " + string(lat_tmp)

merge m:1 tilename using `rawmaps'tilelookup, keep(match master)

outsheet using `rawosm'`region'chunk/x_`region'`filenum'.csv, replace

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

di `tmp'

// local filenum 00
// local region mw
args filenum region

di "now processing `filenum'"
di "now processing `region'"

// insheet using `rawosm'x_`region'.csv, clear
// outsheet if class=="" using `rawosm'xx_`region'.csv, replace

forval x = 0(1)9 {
    insheet using `rawosm'`region'chunk/x_`region'0`x'.csv, clear
    outsheet if class=="" using `rawosm'`region'chunk/xx_`region'0`x'.csv, replace

}

forval x = 10(1)`filenum' {
    insheet using `rawosm'`region'chunk/x_`region'`x'.csv, clear
    outsheet if class=="" using `rawosm'`region'chunk/xx_`region'`x'.csv, replace

}

// insheet using `rawosm'nechunk/xx_tmp.csv, clear
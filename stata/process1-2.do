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

insheet using `rawosm'x_`region'.csv, clear
outsheet if class=="" using `rawosm'xx_`region'.csv, replace

forval x = 0(1)9 {
    log using tmp.log, append
    insheet using `rawosm'`region'chunk/x_`region'00`x'.csv, clear
    outsheet if class!="" using `rawosm'`region'chunk/xx_`region'00`x'.csv, replace
    log close

}

forval x = 10(1)99 {
    log using tmp.log, append
    insheet using `rawosm'`region'chunk/x_`region'0`x'.csv, clear
    outsheet if class=="" using `rawosm'`region'chunk/xx_`region'0`x'.csv, replace
    log close

}

forval x = 100(1)`filenum' {
    log using tmp.log, append
    insheet using `rawosm'`region'chunk/x_`region'`x'.csv, clear
    outsheet if class=="" using `rawosm'`region'chunk/xx_`region'`x'.csv, replace
    log close

}


// insheet using `rawosm'nechunk/xx_tmp.csv, clear
insheet using `stash'ne_0-100000.csv, clear

insheet using `stash'tmp.csv, clear

codebook v33 v37 if v39 == "msa"

codebook v33 v37 if v39 == ""

tab v37, sort

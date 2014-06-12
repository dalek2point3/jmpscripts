clear all
set more off
set matsize 11000
global path "/mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/"
global rawosm "/mnt/nfs6/wikipedia.proj/jmp/rawdata/osm/"
global osmchange "/mnt/nfs6/wikipedia.proj/jmp/rawdata/osmchange/"
global rawmaps "/mnt/nfs6/wikipedia.proj/jmp/rawdata/maps/"
global rawtrips "/mnt/nfs6/wikipedia.proj/jmp/rawdata/trips/"
global stash "/mnt/nfs6/wikipedia.proj/jmp/rawdata/stash/"
global myestimates "/mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/estimates/"
global tables "/mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/tables/"

cd ${path}

// steps
    // 1. changeset file (all changesets, lat, lon, user, time)
    // 2. create the grid merge
    // 3. merge with tile descriptions
    // 4. perform diff in diff

program drop _all

args datafile model dv unit cutoff mode

log using logs/ddlog_`dv'_`cutoff', text replace

use ${stash}`datafile', clear

** droppre

diffindiff `model' `dv' `unit' `cutoff' `mode'

log close

* testing
* local datafile panelfips
* local model xtpoisson
* local dv numcontrib
* local unit fipsbig
* local cutoff 2014
* local mode run

program droppre

local unit fips
local var contrib

bysort `unit': egen tot`var' = total(num`var')
bysort `unit' post: egen totpost`var' = total(num`var'*(1-post))
bysort `unit': egen totpre`var' = max(totpost`var')
drop totpost`var'

codebook fips if totpre`var' > 0
keep if totpre`var' > 10

end


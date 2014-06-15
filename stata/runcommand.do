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

adopath + "/mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/ado"

local datafile `1'
local command `2'
local saveas `3'

cd ${path}

log using logs/ddlog_`saveas', text replace

shell echo "`command'"

di "datafile: `datafile'"
di "model: `command'"
di "saveas: `saveas'"

use ${stash}`datafile', clear

est clear
eststo: `command', fe vce(robust)

estimates save ${myestimates}`saveas', replace

log close




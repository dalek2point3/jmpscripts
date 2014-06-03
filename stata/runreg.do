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

diffindiff `model' `dv' `unit' `cutoff' `mode'

log close

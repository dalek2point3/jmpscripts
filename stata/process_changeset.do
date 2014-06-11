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

// STEP 0 -- clean 3 datasets (change, msa, county)
// TODO: add tileid logic
preparebasic

// STEP 1.1 - merge clean with msa / county
mergebasic

// Step 1.2 -- create outcome variables
// Step 1.3 -- fills in blanks and xtset the data

// for fips
use ${stash}mergemaster1, clear
makedv fips
balancepanel fips
save ${stash}panelfips, replace

// for geoid10-fips
use ${stash}mergemaster1, clear
makedv "fips geoid10"
balancepanel geoid10
save ${stash}panelfips_geoid10, replace

// just geoid
use ${stash}mergemaster1, clear
drop if geoid10 == "NA"
bysort geoid10 fips: gen tmp = _n==1
gen treattmp = treat
replace treattmp = . if tmp == 0
bysort geoid10: egen avgtreat = mean(treattmp)
replace treat = avgtreat
drop treattmp tmp avgtreat

makedv "geoid10"
balancepanel geoid10
save ${stash}panelgeoid10, replace

// what more do I need?

** Analysis Stage 0
// summary stats
// convince that we have a good experiment

// 1. summary stats
// 2. histograms (population, division) TODO: more covars
// 3. ttests

use ${stash}panelfips, clear

// this makes basic summary stats table
makesummary

// make population histogram
makehist cntypop kdensity
makehist region hist

** Analysis Stage 1

// 1.1 Mean Charts
makemeanline numchanges quarter 2011 "Changes"
makemeanline numcontrib quarter 2011 "Contributions"
makemeanline numuser quarter 2011 "Users"
makemeanline numserious90 quarter 2011 "Super Users"
makemeanline numnewusers quarter 2011 "New Users"
makemeanline numnewusers6 quarter 2011 "New Users (Stay for 6+ Months)"
makemeanline numnewusers90 quarter 2011 "New Users (who become super users)"

// 1.2 Produce Diff in diff Latex tables
// rundd -> batchreg.sh -> runreg.do -> diffindiff.ado
program drop _all

// TODO: fix manual process
// have to do this manually
rundd panelgeoid10



// 1.3 Produce Diff in diff Pictures
ddchart

** person level regressions
// person level
makeperson
ddperson maketables
ddperson makechart


// Analysis

// 1. Summary stats

// 2. Treatment vs. control charts

// 3. Baseline effects (xtpoisson, cluster at unit level)

//  0. Meanline charts (raw data) 

// outcomes vars: County Sample -- DD Main Specification

    // a. contribs, users, super users
    // b. new users, newusers, newusers+
    // c. street contribs, non street contribs, amenities
    // d. completeness

//  e. Repeat (a) by dropping empty counties
//  f. Repeat (a) by dropping west
//  g. Repeat (a) for Tile Sample, MSA sample
//  h. Repeat (a) with matched estimators
//  i. Repeat (a) with spatially clustered se, Region X Time trends

// 4 Heterogenous Effects

// a. engaged vs. non-engaged county
// b. urban vs rural
// c. university vs non university
// d. rich vs poor

// 5 Person Level Regressions

// [A] outcome vars: County sample -- DD spec

   // a. Contributions
   // b. Street, Non Street
   // b. TIGER vs. Non Tiger
   // d. Home county, Num Counties

// [B] heterogenous

   // a. Junior vs Senior

// 6 Impacts on Navigation

// PENDING







// GEOID Level


// TASKS for tomorrow




// TODOs for Tuesday Jun 3
// GEOID dataset
// TILEID diff in diff
// What happened to previous people?
// What happened at the street/amenity level?
// Urban vs Rural (framework for third level diff)




// 1.4 Robust: product diff in diff for GEOID

use ${stash}panelfips_geoid10, clear


** Analysis Stage 2
// 




// PROGRAMS







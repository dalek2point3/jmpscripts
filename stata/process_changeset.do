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
 global rawhist "/mnt/nfs6/wikipedia.proj/jmp/rawdata/osmhistory/"

adopath + "/mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/ado"

cd ${path}

program drop _all

 // STEP 0 -- clean 3 datasets (change, msa, county)
 // TODO: add tileid logic

 // Step 1.2 -- create outcome variables
 // Step 1.3 -- fills in blanks and xtset the data


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

 ** Analysis 

// 0. Data

// 0.1 make fips dataset
preparebasic
mergebasic

use ${stash}mergemaster1, clear
makedv fips
balancepanel fips
save ${stash}panelfips, replace

// 0.2 make node dataset
preparenode

use ${stash}mergemaster_node, clear
makedv fips node
balancepanel fips node
save ${stash}panelnode, replace


// Analysis

// 1. Summary stats
use ${stash}panelfips, clear
makesummary

// 2. Treatment vs. control charts
use ${stash}panelfips, clear
makehist cntypop kdensity
makehist region hist

// 3. Baseline effects (xtpoisson, cluster at unit level)

//  3.1 Meanline charts (raw data) 
makemeanline numchanges quarter 2011 "Changes"
makemeanline numcontrib quarter 2011 "Contributions"
makemeanline numuser quarter 2011 "Users"
makemeanline numserious90 quarter 2011 "Super Users"
makemeanline numnewusers quarter 2011 "New Users"
makemeanline numnewusers6 quarter 2011 "New Users (Stay for 6+ Months)"
makemeanline numnewusers90 quarter 2011 "New Users (who become super users)"

// 3.2 FIPS Sample -- DD

/// 3.2.1 -- contrib, users, superu
program drop _all

clear
local dv "numcontrib numuser numserious90"
local unit fips
rundd panelfips `unit' "`dv'"
diffindiff xtpoisson "`dv'" `unit' 2014 write tab_3.2.1 "Contributions" "Users" "Super Users"

/// 3.2.2 -- newusers, newusers6, newuserssuper
clear
local dv "numnewusers numnewusers6 numnewusers90"
local unit fips
rundd panelfips `unit' "`dv'"
diffindiff xtpoisson "`dv'" `unit' 2014 write tab_3.2.2 "New Users" "New Users(6+)" "New Super Users"

/// 3.2.3 -- streetcontrib, nonstreet contrib, amenities
// TODO

/// 3.2.4 -- completeness
// TODO

// 3.2.5 -- Diff in Diff charts
// TODO : make this more flexible
// TODO : this works only for fips
ddchart

// 3.3 Robustness : Drop empty counties
// TODO
//  e. Repeat (a) by dropping empty counties
//  f. Repeat (a) by dropping west
//  g. Repeat (a) for Tile Sample, MSA sample
//  h. Repeat (a) with matched estimators
//  i. Repeat (a) with spatially clustered se, Region X Time trends

// 4 Heterogenous Effects

// 1. Large vs. small
use ${stash}panelfips, clear
gen large = (cntypop > 100000)

diffindiff2 large LARGE tab_4.1 run numcontrib numuser numserious90 numnewusers6

diffindiff2 large LARGE tab_4.1 write numcontrib numuser numserious90 numnewusers6

// 2. engaged vs. non-engaged county

use ${stash}panelfips, clear

bysort fips post: egen tmp = total(numcontrib > 0)
replace tmp = . if post == 1
bysort fips: egen precontrib = max(tmp)
bysort fips: egen totcontrib = total(numcontrib)
drop tmp

drop if precontrib == 0
gen active = (prec > 1)

diffindiff2 active ACTIVE tab_4.2 run numcontrib numuser numserious90 numnewusers6

diffindiff2 active ACTIVE tab_4.2 write numcontrib numuser numserious90 numnewusers6

// 3. populated vs. not

use ${stash}panelfips, clear

gen iseast = (region==1 | region == 2)

diffindiff2 iseast EAST tab_4.3 run numcontrib numuser numserious90 numnewusers6

diffindiff2 iseast EAST tab_4.3 write numcontrib numuser numserious90 numnewusers6




// 3. urban vs rural
// 4. university vs non university
// 5. rich vs poor

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


// STASH

 // 1.1 Mean Charts

 // 1.2 Produce Diff in diff Latex tables
 // rundd -> batchreg.sh -> runreg.do -> diffindiff.ado
 program drop _all

 // TODO: fix manual process
 // have to do this manually

 // 1.3 Produce Diff in diff Pictures

 ** person level regressions
 // person level
 makeperson
 ddperson maketables
 ddperson makechart


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







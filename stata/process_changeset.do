clear all
set more off
set matsize 11000
program drop _all

qui adopath + "/mnt/nfs6/wikipedia.proj/jmp/jmpscripts/stata/ado"
cd ${path}

// this declares global vars
declare_global
global time "quarter"

// 0. Data

// 0.1 make cleancnty, changesets data
clear
preparebasic

// 0.2 make relevant dependent variables
program drop _all
use ${stash}cleanchangeset1, clear
makedv_uid fips
balancepanel_uid fips
maketime
mergebasic
qui destring, replace
save ${stash}panelfips, replace

// 0.3 make node and way datasets producing mergemaster_x datasets
preparenode
prepareway

// append the two datasets
use ${stash}mergemaster_way, clear
append using ${stash}mergemaster_node, gen(isnode)
save ${stash}mergemaster_way, replace

// make the data and balance
use ${stash}mergemaster_way, clear
makedv_wn fips
save ${stash}wn_stash, replace

use ${stash}wn_stash, clear
balancepanel fips node
maketime
mergebasic
qui destring, replace
save ${stash}panel_wn, replace

//0.4 make person level data
program drop _all
use ${stash}cleanchangeset1, clear
makedv_person fips
save ${stash}tmp, replace

balancepanel_person uid
maketime
**mergebasic
qui destring, replace
save ${stash}paneluid, replace

////////////////////////////////
//// ANALYSIS


// 1. Summary Stats
// Panel A: By county Level
program drop _all
use ${stash}panelfips, clear
bysort fips: drop if _n > 1
global tabname "summary_county"
local vars "treat aland_sqmi emp_earnings age_median educ_college emp_computer"
makesummary "`vars'"

// Panel B: By county/time Level
use ${stash}panelfips, clear
global tabname "summary_panel"
local vars "year pop_year numcontrib numusers numnewusers numserious18 numnewusers_t2 numnewusers_c18"
makesummary "`vars'"

// 2. Treatment Control Balance
use ${stash}panelfips, clear
makehist cntypop kdensity "Population"
makehist emp_earnings kdensity "Earnings"
makehist age_median kdensity "Median Age"
makehist educ_college kdensity "Num. College Educated"

// 2. TODO: TTest or regressions treatment / control

//  3.1 Meanline charts (raw data) 
makemeanline numcontrib time 2011 "Contributions"
makemeanline numusers time 2011 "Users"
makemeanline numserious18 time 2011 "Super Users"

// 3.2 Cross Sectional Regressions
//crossreg

// 3.2 Diff in Diff --- Baseline
local outcomes "numcontrib numusers"
dd_simple "`outcomes'" run
dd_simple "`outcomes'" write ddsimple_baseline

// 3.3 Diff in Diff Picture
ddchart numuser 92 write
ddchart numserious56 92 write
ddchart numnewusers_t2

// 3.4 Diff in Diff --- Additional
local outcomes "numnewusers numnewusers_t2 numnewusers90"
dd_simple "`outcomes'" run xtreg
dd_simple "`outcomes'" run xtpoisson
dd_simple "`outcomes'" write ddsimple_additional

// 3.5 Impact on new users of different types
newusers_reg run
newusers_reg write

// 3.6 Impact on Existing Users
reg_person
treat_person



// 4.0 Map Quality


// 4.1 Battlegrid
reg_battle

// 4.2 Other Layers + Attributes
reg_layers




// 4.2 Craigslist
reg_cl









// 3.7 Impact on individuals

// next steps
//1. individual facts
//2. other layers
//3. completeness / quality
//4. model, predictions and whether they confirm?

// 4. How do results vary?
// takes a while
makehetero

// 5. Individual Level Data

// 5.0 create data
makeperson

//5.1 Summary
use ${stash}paneluid, clear

label variable treat "TIGER"
label variable year "YEAR"
label variable numcontrib "Contribs"
label variable numcontrib_home "Home County"
label variable numcontrib_treat "TIGER"
label variable numcontrib_notreat "Non-TIGER"
label variable numcontrib_statenotreat "State(Control)"
label variable numcounties "Num. Counties"

local vars "treat year numcontrib numcontrib_home numcontrib_treat numcontrib_notreat numcontrib_statenotreat numcounties"
global tabname "summary_uid"
makesummary "`vars'"

//Regressions
ddperson maketables
ddperson makechart

// 6. Map Quality

//6.0 summary
use ${stash}panelotherlayers, clear

label variable treat "TIGER"
label variable year "Year"
label variable otherlayer "NonStreet Layers"
label variable amenities "Amenities"
label variable bld_addr "Building/Addresses"
label variable numclass4 "Trails/Bikepaths"

label variable numattrib1 "Attributes:Major Highway"
label variable numattrib2 "Attributes:Class2"
label variable numattrib3 "Attributes:Class3"
label variable numattrib4 "Attributes:Trails etc."

local vars "treat year otherlayer amenities bld_addr numclass4 numattrib1 numattrib2 numattrib3 numattrib4"
global tabname "summary_otherl"
makesummary "`vars'"

// 6.1 Street data completeness


// 6.2 Other layers
reg_layers

// 6.3 Highway level regressions


// 7. Craiglist



////////// OLD // 
 ** Analysis 

// 0. Data

// 0.1 make fips dataset
use ${stash}mergemaster1, clear

balancepanel fips
save ${stash}panelfips, replace

// 0.2 make node dataset
preparenode

use ${stash}mergemaster_node, clear
makedv fips node
balancepanel fips node
save ${stash}panelnode, replace

// 0.3 make way dataset
prepareway
makedv fips way
balancepanel fips way
save ${stash}panelway, replace



// 3. Baseline effects (xtpoisson, cluster at unit level)


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

use ${stash}panelnode, clear
program drop _all

diffindiff xtpoisson fips run tab_test numcontrib numuser 

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

// 5 Street Level Regressions

// 6 Person Level Regressions

// [A] outcome vars: County sample -- DD spec

   // a. Contributions
   // b. Street, Non Street
   // b. TIGER vs. Non Tiger
   // d. Home county, Num Counties

// [B] heterogenous

   // a. Junior vs Senior


// 7 Impacts on Craigslist

preparecl



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







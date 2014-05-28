clear
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

// STEP 1.2 -- make new vars, collapse and fill data

use ${stash}mergemaster1, clear

// this creates outcome variables
makedv fips

// this fills in blanks and xtsets the data
balancepanel fips




// TOMORROW May 28: check DVs, collapse and fill for FIPS


// what more do I need?

** Data Stage 3
// collapse data at diff levels and then expand
// store these datasets

** Analysis Stage 0
// summary stats
// basic means graph

** Analysis Stage 1
// diff in diff, DD chart --> users, super users, contribs
// at MSA, County, Tile level


** Analysis Stage 2
// 




// PROGRAMS

/// 1. program lib for merge data
program mergebasic
use ${stash}cleanchangeset1, clear

drop if fips == "NA"

merge m:1 fips using ${stash}cleancnty, keep(master match) nogen

merge m:1 geoid10 using ${stash}cleanua, keep(master match) nogen

save ${stash}mergemaster1, replace
end









/////////////////////
// scratch

// check dv calculation
// all vars OK

label variable numuser "Number of Unique Users in Unit/Month"
label variable numcontrib "Contribs in Unit/Month"

label variable numserious90 "Num of Top 90 Users (lifetime contribs) in Unit/Month"
label variable numserious95 "Num of Top 95 Users (lifetime contribs) in Unit/Month"

label variable numnewusers "Number of Users making their first ever contrib in Unit/Month"
label variable numnewusers6 "Number of Users joining who will stay in this unit for 6 months or more"

label variable numnewusers90 "Number of users joining who will go on to become super contribs"

label variable nummonth "Number of months in given unit"
label variable numusercontrib "Number of lifetime contribs"

// testing

bysort fips month: gen tmp = (_n==1)
sort fips month
gen istag = .
format minmonth %tm

local testvar "numnewusers90"
codebook fips if `testvar' != 0
local fip "06073"
codebook month if fips == "`fip'" & `testvar' == 1

replace istag = (month == mofd(date("7-1-2013","MDY")))

gen tmp2 = (month == minmonth)
list tmp2 user numnewusers `testvar' numuserc if fips == "`fip'" & istag == 1, sepby(tmp2)


list month user numcontrib numuser numserious* if fips == "22089" & istag == 1

sort fips mont user

format minm %tm
list user tmp1 numuserc numnew* minm if fips == "`fip'" & istag == 1


codebook numnew if tmp ==1


// quick analysis

use ${stash}mergemaster1, clear

unique user if post == 0
unique fips if post == 0
unique geoid10 if post == 0

drop if geoid10 == "NA"

bysort month fips: gen sumcontrib = _N
bysort month fips: gen tag = (_n==1)
drop if tag == 0

gen post =  month > mofd(date("10-1-2007","MDY"))
gen cutoff = month > mofd(date("10-1-2010","MDY"))

destring fips, gen(fipsid)

xtset fipsid month

xtpoisson sumcontrib post##treat i.month, vce(robust) fe

xtpoisson numnewusers6 post##treat i.month if cutoff == 1, vce(robust) fe



// identify imports

bysort user: gen useredits = _N
gen isimport = (num_changes > 5000)
bysort user: egen userimports = total(isimport)
gen percentimport = userimports / useredits

tabstat percent if percent > 0.5 & useredits > 50, by(user) stats(mean n)

// outsheet something useful
outsheet lat lon using ${stash}tmp.csv if user == "DaveHansenTiger", replace


//////////////// OLD /////
/////////////////////////////////////////////////




// step 0 : prepare county lookup
insheet using ${rawmaps}county_lookup.csv, clear
drop state_fips cnty_fips 
destring, replace
save ${rawmaps}county_lookup, replace

// step 1: prepare changes data 
insheet using ${osmchange}change-pp.csv, clear
processvar
save ${stash}change-tile, replace

// step 2 : merge changed with county
use ${stash}change-tile, clear
merge m:1 fips using ${rawmaps}county_lookup, keep(match) nogen
save ${stash}change-tile-merge, replace

// step 3 : create vars for analysis and collapse
use ${stash}change-tile-merge, clear
makenewvar
bysort tileid month: drop if _n > 1
save ${stash}change-group, replace

// step 4: fill dataset
use ${stash}change-group, clear
filldataset
save ${stash}change-fill, replace

// step 5: perform analyses
use ${stash}change-fill, clear





//////////////////////
/// programs

program drop filldataset
program filldataset

sort tileno month
tsset tileno month
tsfill, full

bysort tileno: egen treaty = max(treat)
bysort tileno: egen tilepop = max(population)
bysort tileno: egen msaid = max(geoid10)

bysort msaid tileno: gen mtag = (_n==1)
bysort msaid: egen msapop = total(tilepop*tag)

/* gsort msaid -msaname */
/* bysort msaid: gen msaname2 = msaname[1] */
/* drop msaname */
/* rename msaname2 msaname */

replace numchange = 0 if numchange == .
replace numuser = 0 if numuser == .
replace numserioususer = 0 if numserioususer == .
replace numnewuser = 0 if numnewuser == .
replace numuser3 = 0 if numuser3 == .
replace numuser12  = 0 if numuser12 == .
replace numsmallchange1  = 0 if numsmallchange1 == .
replace numsmallchange2  = 0 if numsmallchange2 == .
replace numsmallchange10  = 0 if numsmallchange10 == .

gen post =  month > mofd(date("10-1-2007","MDY"))
gen istreat = (treaty > .1)
gen istreat5 = (treaty > .5)

xtset tileno month

drop nummonth

save ${stash}temp2, replace

use ${stash}temp2, clear
keep tileno msaid month msaid num* post istreat tileid

end




program drop makenewvar
program makenewvar

drop if state_name == "Massachusetts"

bysort userid: gen totalc = _N

bysort tileid month userid : gen tmp1 = (_n==1)
bysort tileid month userid : gen tmp2 = (_n==1)*(totalc >= 10)

bysort tileid month userid : gen tmp5 = (_n==1)*(nummonth >= 3)

bysort userid tileid month: gen tmp3 = (_n==1)
bysort userid tileid: egen minmonth = min(month)
bysort userid tileid: gen firstc = (month==minmont)*tmp3

bysort tileid month: gen smallchange1 = (num_change < 2)
bysort tileid month: gen smallchange2 = (num_change < 3)
bysort tileid month: gen smallchange10 = (num_change < 11)

bysort tileid month: gen numchange = _N
bysort tileid month: egen numsmallchange1 = total(smallchange1)
bysort tileid month: egen numsmallchange2 = total(smallchange2)
bysort tileid month: egen numsmallchange10 = total(smallchange10)
bysort tileid month: egen numuser = total(tmp1)
bysort tileid month: egen numserioususer = total(tmp2)
bysort tileid month: egen numnewuser = total(firstc)
bysort tileid month: egen numuser3 = total(tmp5)


bysort tileid userid month: gen tmp4 = (_n==1)
bysort tileid userid: egen nummonth = total(tmp4)
bysort tileid month userid : gen tmp6 = (_n==1)*(nummonth >= 12)
bysort tileid month: egen numuser12 = total(tmp6)


bysort tileno: egen totuser = total(numuser)
bysort tileno: gen tag = (_n==1)

drop tmp* firstc minmonth small*

end


program drop processvar
program processvar

rename v1 userid
rename v2 lat
rename v3 lon
rename v4 num_changes
rename v5 tstamp
rename v6 changeid
rename v7 username
rename v8 fips
rename v9 geoid10
rename v10 pieceid

drop pieceid

drop if username == "woodpeck_fixbot"
drop if username == "nmixter"
drop if username == "jumbanho"

gen temp_lat = float(round(lat, 0.1))
gen temp_lon = float(round(lon, 0.1))
gen tileid = string(temp_lat) + "/" + string(temp_lon)
drop temp_*

gen tstamp_stata = clock(tstamp, "YMD#hms#")
format tstamp_stata %tc

gen tstamp_date = dofc(tstamp_stata)
format tstamp_date %td

gen month = mofd(tstamp_date)
format month %tm

egen tileno = group(tileid)

drop if fips == "NA"

destring, replace
end



////













********************************************
*************** datasets ********************
********************************************
    
** $$$$$$$$$$$$$$$$$
** 1a. Grid
** $$$$$$$$$$$$$$$$$

insheet using `rawdata'usa/gridfinal3.csv, clear

gen temp_lat = float(round(ymax, 0.1))
gen temp_lon = float(round(xmax, 0.1))
gen tileid = string(temp_lat) + "/" + string(temp_lon)

local msa "gridcountymsajoin_"
local cnty "gridcountyjoin_"

rename `msa'name10 msaname
rename `msa'geoid10 msaid
rename `msa'population msapop
rename `msa'uaty uatype
rename `msa'area msa_area

rename pop_sum population
rename hh_sum households
rename inc_mean income

rename `cnty'state_name state_name
rename `cnty'name county_name
rename `cnty'fips county_fips
rename `cnty'color county_color
rename `cnty'treat county_treat

drop temp_*
drop xmax ymax 
drop `cnty'*

save `filedata'gridfinal, replace

** $$$$$$$$$$$$$$$$$
** 1b. Changes
** $$$$$$$$$$$$$$$$$

insheet using `filedata'change-pp.csv, clear



********************************************
*************** 2. Merge  ********************
********************************************

** $$$$$$$$$$$$$$$$$
** 2. Merge changesets
** $$$$$$$$$$$$$$$$$

use `filedata'gridfinal, clear    

merge 1:m tileid using `filedata'change-tile
drop if _m == 2

rename treat_mean treat
save `filedata'allchanges, replace

********************************************
*************** 3. Final data  ********************
********************************************

use `filedata'allchanges, clear

drop if tstamp == ""
drop _m
drop if state_name == "Massachusetts"

gen tstamp_stata = clock(tstamp, "YMD#hms#")
format tstamp_stata %tc

gen tstamp_date = dofc(tstamp_stata)
format tstamp_date %td

gen month = mofd(tstamp_date)
format month %tm

egen tileno = group(tileid)

bysort userid: gen totalc = _N

bysort tileid month userid : gen tmp1 = (_n==1)
bysort tileid month userid : gen tmp2 = (_n==1)*(totalc >= 10)

bysort tileid userid month: gen tmp4 = (_n==1)
bysort tileid userid: egen nummonth = total(tmp4)
bysort tileid month userid : gen tmp5 = (_n==1)*(nummonth >= 3)
bysort tileid month userid : gen tmp6 = (_n==1)*(nummonth >= 12)

bysort userid tileid month: gen tmp3 = (_n==1)
bysort userid tileid: egen minmonth = min(month)
bysort userid tileid: gen firstc = (month==minmont)*tmp3

bysort tileid month: gen smallchange1 = (num_change < 2)
bysort tileid month: gen smallchange2 = (num_change < 3)
bysort tileid month: gen smallchange10 = (num_change < 11)

bysort tileid month: gen numchange = _N
bysort tileid month: egen numsmallchange1 = total(smallchange1)
bysort tileid month: egen numsmallchange2 = total(smallchange2)
bysort tileid month: egen numsmallchange10 = total(smallchange10)
bysort tileid month: egen numuser = total(tmp1)
bysort tileid month: egen numserioususer = total(tmp2)
bysort tileid month: egen numnewuser = total(firstc)
bysort tileid month: egen numuser3 = total(tmp5)
bysort tileid month: egen numuser12 = total(tmp6)

drop tmp* firstc minmonth small*
bysort tileid month: drop if _n > 1

save `filedata'tempdta/tempchange, replace

use `filedata'tempdta/tempchange, clear

sort tileno month
tsset tileno month
tsfill, full

bysort tileno: egen treaty = max(treat)
bysort tileno: egen tilepop = max(population)
bysort tileno: egen msaid2 = max(msaid)
drop msaid
rename msaid2 msaid

bysort msaid tileno: gen tag = (_n==1)
bysort msaid: egen msapop2 = total(tilepop*tag)
drop msapop 
rename msapop2 msapop

gsort msaid -msaname
bysort msaid: gen msaname2 = msaname[1]
drop msaname
rename msaname2 msaname

replace numchange = 0 if numchange == .
replace numuser = 0 if numuser == .
replace numserioususer = 0 if numserioususer == .
replace numnewuser = 0 if numnewuser == .
replace numuser3 = 0 if numuser3 == .
replace numuser12  = 0 if numuser12 == .
replace numsmallchange1  = 0 if numsmallchange1 == .
replace numsmallchange2  = 0 if numsmallchange2 == .
replace numsmallchange10  = 0 if numsmallchange10 == .

gen post =  month > mofd(date("10-1-2007","MDY"))
gen istreat = (treaty > .1)
gen istreat5 = (treaty > .5)

xtset tileno month

drop nummonth

save `filedata'temp2, replace

use `filedata'temp2, clear
keep tileno msaid month msaid num* msapop msaname post istreat id tileid

bysort tileno: egen totuser = total(numuser)
bysort tileno post: egen totpostuser = total(numuser*(1-post))
bysort tileno: egen totpreuser = max(totpostuser)
drop totpostuser

bysort tileno: gen tag = (_n==1)
save `filedata'changetilemonth, replace



********************************************
*************** 4. Analysis  ********************
********************************************

*** 4.1 Summary Stats

use `filedata'changetilemonth, clear

drop if totpreuser < 1
drop if month > 593
drop if msaid == .


bysort id: replace tag = (_n==1)
outsheet id istreat tileno month using `tables'crossec.csv if tag == 1, replace

format month %tm
estpost tabstat istreat tileno month, s(mean median sd min max) columns(statistics)

codebook tilen msaname

ttest msapop , by(istreat)

reg msapop istreat

*** 4.2 regressions
use `filedata'changetilemonth, clear

drop if totpreuser < 1
drop if month > 593
drop if msaid == .

qui tabulate msaid, gen(msadummy)

forval x = 1 2 to 261{
    qui replace msadummy`x' = msadummy`x'*(month-554)
}


local var "numuser"
local var "numnewuser"
local var "numuser12"
local var "numuser3"
collapse (mean) mean=`var' (semean) se=`var' , by(istreat month)

sort month istreat
gen min = mean - 1.96 * se
gen max = mean + 1.96 * se

drop if month > 600

tw (line mean month if istreat == 0) (line mean month if istreat == 1) (line min month if istreat == 0, lwidth(vthin) lpattern(-) lcolor(gs8)) (line min month if istreat == 1, lwidth(vthin) lpattern(-) lcolor(gs8)) (line max month if istreat == 0, lwidth(vthin) lpattern(-) lcolor(gs8)) (line max month if istreat == 1, lwidth(vthin) lpattern(-) lcolor(gs8)), xline(574) xline(576) legend(off) title("Red = Treat and Blue=Control") 

graph export `tables'meanline2.eps, replace
shell epstopdf `tables'meanline2.eps

(rcap min max month if istreat == 0) (rcap min max month if istreat == 1), xline(573)


*** 4.2 Diff in Diff

** a) create the estimate files

use `filedata'changetilemonth, clear

drop if totpreuser < 1
drop if month > 593
drop if msaid == .

qui tabulate msaid, gen(msadummy)

forval x = 1 2 to 261{
    qui replace msadummy`x' = msadummy`x'*(month-554)
}


est clear
foreach x in numuser numchange numnew numserioususer {
eststo: xtpoisson `x' 1.post#1.istreat i.month msadummy*, vce(robust) irr fe
estadd local blockfe "Yes", replace
estadd local monthfe "Yes", replace
estimates save "./tables/new-4.3.`x'", replace
}


** b) create the latex table

est clear
foreach x in numuser numchange numnew numserioususer{
estimates use ./tables/new-4.2.`x'
eststo est`x'
}

esttab, keep(1.post#1.istreat) se star(* 0.10 ** 0.05 *** 0.01) eform

esttab using "tables/dd_change_msa.tex", keep(1.post#1.istreat) order(1.post#1.istreat 1.post) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.post "Post Import" 1.post#1.istreat "Post X Treat" _cons "Constant") mtitles("Users" "Contributions" "Super Users" "New Users") replace booktabs  s(blockfe monthfe N, label("Block/Month FE" "MSAXMonth Trends")) width(0.75\hsize)

esttab using "tables/dd_change2.tex", keep(1.post#1.istreat) order(1.post#1.istreat 1.post) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.post "Post Import" 1.post#1.istreat "Post X Treat" _cons "Constant") mtitles("Users" "Contributions" "Super Users" "New Users") replace booktabs  s(blockfe monthfe N, label("Block FE" "Month FE")) width(0.75\hsize) eform

*** 4.3 Time Varying Picture

use `filedata'changetilemonth, clear

bysort tileno: egen totuser = total(numuser)
bysort tileno post: egen totpostuser = total(numuser*(1-post))
bysort tileno: egen totpreuser = max(totpostuser)
drop totpostuser

bysort tileno: gen tag = (_n==1)
drop if totpreuser < 2
drop if month > 593


est clear

eststo: xtpoisson numuser istreat##b573.month, fe vce(robust)
estimates save "./tables/new-time1", replace
estimates save "./tables/new-time2", replace

estimates use "./tables/new-time1"
qui parmest, label list(parm estimate min* max* p) saving(`filedata'tempdta/mypars2, replace)

clear
use `filedata'tempdta/mypars2

keep if regexm(parm, "1.*treat.*mont.*") == 1
gen month = regexs(1) if regexm(parm, ".*#([0-9][0-9][0-9])b?\..*")

destring month, replace
replace month = month - 573

qui gen xaxis = 0
list estimate min max month
drop if month < -10

** graph twoway (line estimate month, msize(small) lpattern(dash) lcolor(edkblue) lwidth(thin)) (rcap min max month, lwidth(vthin) lpattern(-) lcolor(gs8)) (line xaxis month, lwidth(vthin) lcolor(gs8)) if month > -16, yscale(range(-0.75 0.7)) xtitle("Month") ytitle("Number of Users") xlabel(-8(4)18) legend(off) title("") ylabel(-0.8 (0.4) 0.8) xline(0)

graph twoway (line estimate month, msize(small) lpattern(solid) lcolor(edkblue) lwidth(thin)) (line min month, lwidth(vthin) lpattern(-) lcolor(gs8)) (line max month, lwidth(vthin) lpattern(-) lcolor(gs8)) (line xaxis month, lwidth(vthin) lcolor(gs8)) if month > -16, yscale(range(-0.75 0.7)) xtitle("Month") ytitle("Number of Users") xlabel(-8(4)20) legend(off) title("") ylabel(-1.8 (0.4) 1.2) xline(0)

graph export `tables'timeline5.eps, replace
shell epstopdf `tables'timeline5.eps


** $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
** 3a. Change-level regression -- MSA/Grid
** $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


use `filedata'changetilemonth, clear


estpost tabstat post treatvar numchange numuser numserioususer, s(mean median sd min max n) columns(statistics)

label var numchange "Contributions"
label var numuser "Num. Users"
label var numseriousu "Num. Super Users"

***********************************
** calculate estimates



est clear

eststo: qui xtpoisson numuser 1.post#1.istreat i.month if month < 594 & msaid != ., vce(robust) fe
estadd local fixed "Yes", replace
estadd local month "Yes", replace
estimates save "./tables/change-est1", replace

eststo: qui xtpoisson numchange post##istreat i.month if month < 594 & msaid != ., vce(robust) fe
estadd local fixed "Yes", replace
estadd local month "Yes", replace
estimates save "./tables/change-est2", replace

eststo: qui xtpoisson numserioususer post##istreat i.month if month < 594 & msaid != ., vce(robust) fe
estadd local fixed "Yes", replace
estadd local month "Yes", replace

estimates save "./tables/change-est3", replace

eststo: qui xtpoisson numnewuser post##istreat i.month if month < 594 & msaid != ., vce(robust) fe
estadd local fixed "Yes", replace
estadd local month "Yes", replace
estimates save "./tables/change-est4", replace

eststo: qui xtpoisson numuser3 post##istreat i.month if month < 594 & msaid != ., vce(robust) fe
estadd local fixed "Yes", replace
estadd local month "Yes", replace
estimates save "./tables/change-est5", replace


est clear

forval num = 1/5{
estimates use ./tables/change-est`num'
eststo est`num'

}

esttab, keep(1.post#1.istreat) se

esttab using "tables/dd_change.tex", keep(1.post#1.istreat) order(1.post#1.istreat 1.post) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.post "Post Import" 1.post#1.istreat "Post X Treat" _cons "Constant") mtitles("Contributions" "Users" "Super Users" "New Users" "+3 Months") replace booktabs  s(fixed month N, label("Region FE" "Month FE")) width(0.75\hsize) 

esttab using "tables/dd_change2.tex", keep(1.post#1.istreat) order(1.post#1.istreat 1.post) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.post "Post Import" 1.post#1.istreat "Post X Treat" _cons "Constant") mtitles("Contributions" "Users" "Super Users" "New Users" "+3 Months") replace booktabs  s(fixed month N, label("Region FE" "Month FE")) width(0.75\hsize) eform


**********************************
** calculate picture

use `filedata'changetilemonth, clear
drop if msaid == .
keep if month < 594

bysort tileno: egen maxuser = max(numuser)
drop if maxuser == 0

bysort tileno post: egen maxuser2 = max(numuser)
bysort tileno post: gen tag = (_n==1)
replace maxuser2 = (maxuser2 > 0)
rename maxuser2 isuser

** simple diff in diff (no fe)

poisson isuser post##istreat if tag == 1, clust(tileno) irr
poisson isuser post##istreat if tag == 1 & msaid != ., clust(tileno) irr

** simple diff with FE
xtpoisson isuser 1.post 1.post#1.istreat if tag == 1, vce(robust) fe irr
xtpoisson isuser 1.post 1.post#1.istreat if tag == 1 & msaid != ., vce(robust) fe irr

** full diff in diff

xtpoisson numuser 1.post#1.istreat i.month if month < 594 & msaid != ., vce(robust) irr fe

xtpoisson numuser 1.post#1.istreat i.month if month < 594, vce(robust) irr fe

xtpoisson numchange 1.post#1.istreat i.month, vce(robust) irr fe

xtpoisson numuser 1.post#1.istreat i.month, vce(robust) irr fe
estimates save "./tables/change-est11", replace

xtpoisson numuser 1.post#1.istreat i.month if msaid != ., vce(robust) irr fe
estimates save "./tables/change-est12", replace

xtpoisson numuser 1.post#1.istreat i.month if month < 594, vce(robust) irr fe
estimates save "./tables/change-est13", replace

xtpoisson numuser 1.post#1.istreat i.month if month < 594 & msaid != ., vce(robust) irr fe
estimates save "./tables/change-est14", replace

*** picture

use `filedata'changetilemonth, clear
drop if msaid == .
drop if month > 593



xtpoisson numuser 1.istreat#1.post i.month if totpreuser > 1, fe vce(robust)
estimates save "./tables/change-est22", replace

xtpoisson numuser 1.istreat#1.post i.month if totpreuser > 1 & month < 594, fe vce(robust)
estimates save "./tables/change-est23", replace

xtpoisson numuser istreat##b573.month if totpreuser > 1 & month < 594, fe vce(robust)
estimates save "./tables/change-timeline7", replace

drop if totuser == 0

xtpoisson numuser 1.istreat#1.post i.month if totpreuser > 1, fe vce(robust)

xtpoisson numuser 1.istreat##b573.month if totpreuser > 1 & month < 594, fe vce(robust)




xtpoisson numuser 1.istreat#1.post i.month if totuser > 2, fe vce(robust)

xtpoisson numuser istreat##b573.month if totuser > 2, fe vce(robust)
estimates save "./tables/change-timeline5", replace

estimates save "./tables/change-timeline6", replace



xtpoisson numuser istreat##b573.month, fe vce(robust)

xtpoisson numchange istreat##b573.month, fe vce(robust)
estimates save "./tables/change-est16", replace

xtpoisson numuser istreat##b573.month if msapop > 500, fe vce(robust)
estimates save "./tables/change-est15", replace


poisson numuser istreat#b573.month, vce(robust)

estimates save "./tables/est-timeline1", replace
estimates use ./tables/est-timeline1

qui parmest, label list(parm estimate min* max* p) saving(`filedata'tempdta/mypars2, replace)

clear
use `filedata'tempdta/mypars2

keep if regexm(parm, "1.*treat.*mont.*") == 1
gen month = regexs(1) if regexm(parm, ".*#([0-9][0-9][0-9])b?\..*")

destring month, replace
replace month = month - 573

qui gen xaxis = 0
drop if month < -9


graph twoway (line estimate month, msize(small) lpattern(dash) lcolor(edkblue) lwidth(thin)) (rcap min max month, lwidth(vthin) lpattern(-) lcolor(gs8)) (line xaxis month, lwidth(vthin) lcolor(gs8)) if month > -16, yscale(range(-0.4 0.6)) xtitle("Month") ytitle("Number of Users") xlabel(-8(4)18) legend(off) title("") ylabel(-0.8 (0.4) 0.8) xline(0)

graph export `tables'timeline6.eps, replace
shell epstopdf `tables'timeline6.eps

//////////


use `filedata'changetilemonth, clear

drop if msaid == .
drop if month > 593

bysort tileno: egen maxuser = max(numuser)
drop if maxuser == 0

tab msaname if msapop > 1000000

list month numuser if tileno == 3992

xtpoisson numuser 1.post#1.istreat i.month if msapop > 1000000, vce(robust) fe
estimates save "./tables/est-xtp_bigmsa", replace

xtpoisson numuser 1.post#1.istreat i.month if msapop < 1000000 & msapop > 10000, vce(robust) fe
estimates save "./tables/est-xtp_smallmsa", replace

xtpoisson numuser 1.post#1.istreat i.month if month < 594, vce(robust) fe
estimates save "./tables/est-xtp_allm594", replace

xtpoisson numuser 1.post#1.istreat i.month, vce(robust) fe
estimates save "./tables/est-xtp_all", replace

bysort msaid: gen tag = (_n==1)
codebook msapop if tag == 1

unique msaid if msapop < 1000
tabstat msapop if msapop > 1000000, by(msaname)




xtpoisson numuser 1.post#1.istreat i.month, vce(robust) fe

xtpoisson numuser 1.post#1.istreat i.month, vce(robust) fe


poisson numuser3 1.post#1.istreat i.month i.msaid, vce(robust) 


poisson numuser 1.post#1.istreat i.month, vce(robust)


xtpoisson numuser3 post##istreat i.month if month < 594 & msaid != ., vce(robust) fe




xtpoisson numuser post##istreat i.month if month < 594, vce(robust) fe

poisson numuser post##istreat if month < 594, 


reg numuser3 post












reg sumdevice30 treat lnpop lninc income population i2 p2 i.msaid if msaid!=. & ismix == 1, cluster(msaid)

poisson sumtrips treat lnpop lninc income population i2 p2 i.msaid if msaid!=. & ismix == 1, cluster(msaid)


poisson sumdevice10 treat lnpop lninc income population i2 p2 msa_area if msaid!=., cluster(msaid)

poisson sumdevice10 treat lnpop lninc if msaid!=., cluster(msaid)
poisson sumdevice10 treat lnpop lninc income if msaid!=., cluster(msaid)
poisson sumdevice10 treat lnpop lninc income popu if msaid!=., cluster(msaid)

list id popu income temp if msaname == "Houston, TX"


bysort msaname: egen temp = mean(income)

poisson sumtrips treat lnpop lninc income population i2 p2 if msaid!=., cluster(msaid)

poisson sumdevice10 treat lnpop lninc income population i2 p2 if msaid!=., cluster(msaid)

poisson sumdevice30 treat lnpop lninc income population i2 p2 if msaid!=., cluster(msaid)

poisson sumdevice10 treat lnpop lninc if msaid!=., cluster(msaid)

poisson sumtrips treat lnpop lninc lnhh if msaid!=., cluster(msaid) irr
poisson sumdevice10 treat lnpop lninc lnhh if msaid!=., cluster(msaid) irr


poisson sumdevice10 treat lnpop lninc income population i2 p2 if msaid!=., cluster(msaid) irr



poisson sumdevice10 treat lnpop lninc income population i2 p2 i.msaid if msaid != . & msapop < 20, cluster(msaid)


reg sumdevice10 treat lnpop lninc income i

poisson sumdevice10 treat lnpop lninc income population i2 p2 i.msaid if msaid != . & msapop < 20, cluster(msaid)


poisson sumdevice10 treat lnpop lninc income population i2 p2 i.msaid if msaid != . & msapop < 20, cluster(msaid)


poisson sumdevice10 treat population income, cluster(state_name)

reg sumdevice10 treat lnpop lninc, cluster(state_name)



reg sumtrips treat population income, vce(cluster county_fips)

reg sumtrips treat income lnpop population, vce(cluster county_fips)

poisson sumtrips treat income lnpop population, vce(cluster county_fips)

poisson sumtrips treat lnpop lninc, vce(cluster county_fips)

poisson sumdevice0 treat lnpop lninc, vce(cluster state_name)
poisson sumdevice30 treat lnpop lninc, vce(cluster state_name)





1. Use the PP files to create tileids
2. Use the grid file to create tileids
3. Combine
4. Perform analysis

************** 1. Creating TILEID

insheet using `filedata'change-pp.csv, clear
rename v1 userid
rename v2 lat
rename v3 lon
rename v4 num_changes
rename v5 tstamp
rename v6 changeid
rename v7 username
rename v8 fips
rename v9 geoid10
rename v10 pieceid

bysort changeid: gen tmp = _n
drop if tmp > 1
drop if fips == "NA"
drop tmp

gen temp_lat = float(round(lat, 0.1))
gen temp_lon = float(round(lon, 0.1))
gen tileid = string(temp_lat) + "/" + string(temp_lon)

save `filedata'change-tile, replace

insheet using `filedata'trips-pp.csv, clear
  
save `filedata'trips-tile, replace

insheet using gridfinal3.csv, clear

gen temp_lat = float(round(ymax, 0.1))
gen temp_lon = float(round(xmax, 0.1))
gen tileid = string(temp_lat) + "/" + string(temp_lon)

local msa "gridcountymsajoin_"
local cnty "gridcountyjoin_"

rename `msa'name10 msaname
rename `msa'geoid10 msaid
rename `msa'population msapop
rename `msa'uaty uatype

rename pop_sum population
rename hh_sum households
rename inc_mean income

rename `cnty'fips state_name
rename `cnty'cnty_fips county_name
rename `msa'xmin fips

drop pop_* hh_* inc_* temp_*
drop xmin xmax ymin ymax 
drop `msa'*
drop `cnty'*
  
save grid-tile, replace

************* 2. Merge everything ***************

use grid-tile, clear


TODO: same for the change data


************* 3. Analysis ***************

use trip-grid, clear

drop if treat == .
drop if population == 0
drop if income == 0

rename gridcountyjoin_state_name state_name
rename gridcountyjoin_state_fips state_fips

drop if state_name == "Massachusetts"

gen lnpop = ln(population)
gen lninc = ln(income)

gen ismix = (treat>0) & (treat < 1)

gen p2 = population * population
gen p3 = p2 * population
gen p4 = p3 * population

gen i2 = income * income


reg sumtrip treat lnpop lninc income population p2 , cluster(state_fips)

reg sumtrip treat lnpop lninc income population i2 p2 , cluster(state_fips)

reg sumdevice10 treat lnpop lninc income population i2 p2 if ismix == 1, cluster(state_fips)


poisson sumdevice10 treat lnpop lninc income population i2 p2, cluster(fips)

poisson sumtrip treat lnpop lninc income population i2 p2 i.state_fips, cluster(fips) irr

poisson sumdevice10 treat lnpop lninc house population p2 if ismix == 1, cluster(fips) irr





reg sumdevice30 treat lnpop lninc income population p2 , cluster(state_fips)


poisson sumdevice10 treat lnpop lninc population income i.state_fips, cluster(state_fips)

tab state_name if ismix == 1, sort



tab state_name, sort


poisson sumtrip treat lnpop lninc if ismix == 1


poisson sumtrip treat lnpop population lninc i.state_fips if ismix == 1, cluster(state_fips)


reg lnpop treat i.state_fips


reg sumtrip treat population i.state_fips

reg numtrips treat population if ismix == 1



codebook treat



************************
1. dta-fy the pp csv files
************************

insheet using `filedata'battle-pp.csv, clear
rename v1 numerrors
rename v2 lat
rename v3 lon
rename v4 fips
rename v5 geoid10
rename v6 pieceid

** these tend to be mostly in the water
drop if fips == "NA"

save `filedata'tempdta/battle-pp, replace

insheet using `filedata'change-pp.csv, clear
rename v1 userid
rename v2 lat
rename v3 lon
rename v4 num_changes
rename v5 tstamp
rename v6 changeid
rename v7 username
rename v8 fips
rename v9 geoid10
rename v10 pieceid

bysort changeid: gen tmp = _n
drop if tmp > 1
drop if fips == "NA"
drop tmp

save `filedata'tempdta/change-pp, replace

insheet using `filedata'trips-pp.csv, clear
rename v1 tstamp
rename v2 deviceuid
rename v3 lat
rename v4 lon
rename v5 fips
rename v6 geoid10
rename v7 pieceid

drop if fips == "NA"

bysort tstamp deviceuid lat lon: gen tmp = _n
drop if tmp > 1
drop tmp

save `filedata'tempdta/trips-pp, replace

******************************
2. prepare county and related cross section files
******************************

insheet using `rawdata'usa/msapop.csv, clear
rename cbsacode geoid10_official
rename areaname msa_name_official
rename pop2012 msa_pop_official

keep geoid10 msa_name_ msa_pop_official

save `filedata'tempdta/msapop, replace

insheet using `rawdata'usa/msamap.csv, clear
rename population msapop
rename area msaarea
rename name10 msaname
keep geoid10 msapop msaname msaarea

save `filedata'tempdta/msamap,replace

insheet using `rawdata'usa/UScounties_Color.csv, clear
rename area countyarea
rename pop countypop
rename name countyname
save `filedata'tempdta/UScounties_Color, replace

insheet using `rawdata'usa/countyfacts.txt, clear
rename pst040 county_pop_official
rename hsd410 households
rename inc910 income
rename lnd110210 county_area_official
rename pop06 popdensity

keep county_* households income popdensity fips

save `filedata'tempdta/countyfacts, replace

*********************************************
2b. make a changeset file by month and county
********************************************

use `filedata'tempdta/change-pp, clear

gen tstamp_stata = clock(tstamp, "YMD#hms#")
format tstamp_stata %tc

gen tstamp_date = dofc(tstamp_stata)
format tstamp_date %td

gen month = mofd(tstamp_date)
format month %tm

destring, replace

merge m:1 pieceid using `filedata'tempdta/piecemap_merge, keep(match) nogen

gen import_date = date("2-1-2008","MDY")
format import_date %td

gen post = tstamp_date > import_date

save `filedata'tempdta/panelchange, replace

*********************************************
3. mash everything together to prep piecemap
********************************************

insheet using `rawdata'usa/regions.csv, clear names
save `filedata'regions, replace

insheet using `rawdata'usa/piecemap.csv, clear
insheet using `rawdata'usa/piecemapv2.csv, clear

bysort pieceid: egen areapiece_sum = total(areapiece)
bysort pieceid: egen population_sum = total(cen_pop_su)
bysort pieceid: egen income = mean(cen_inc_me)
bysort pieceid: egen hh = sum(cen_hh_sum)

replace areapiece = areapiece_sum
replace population = population_sum
drop areapiece_sum population_sum cen_*

bysort pieceid: drop if _n > 1

merge m:1 state_name using `filedata'regions, keep(match master) nogen

merge m:1 geoid10 using `filedata'tempdta/msamap, keep(match master) nogen

merge m:1 fips using `filedata'tempdta/UScounties_Color, keep(match master) nogen

merge m:1 fips using `filedata'tempdta/countyfacts, keep(match) nogen

gen ismsa = (geoid != -1)
gen treat = (color != "White")

save `filedata'tempdta/piecemap_merge, replace


************************************************
4. Convert the three pp to piece files
************************************************

use `filedata'tempdta/trips-pp, clear

gen tstamp_stata = clock(tstamp, "DMY hms")
format tstamp_stata %tc

gen tstamp_date = dofc(tstamp_stata)
format tstamp_date %td

gen month = mofd(tstamp_date)
format month %tm

bysort pieceid: gen tag = (_n == 1)
bysort pieceid: gen sumtrips = _N

bysort deviceuid: gen numtrips = _N

bysort pieceid deviceuid: gen temp1 = (_n==1)
bysort pieceid deviceuid: gen temp2 = (_n==1)*(numtrips > 5)
bysort pieceid deviceuid: gen temp3 = (_n==1)*(numtrips > 10)
bysort pieceid deviceuid: gen temp4 = (_n==1)*(numtrips > 25)

bysort pieceid: egen sumdevice = total(temp1)
bysort pieceid: egen sumdevice_serious = total(temp2)
bysort pieceid: egen sumdevice_serious10 = total(temp3)
bysort pieceid: egen sumdevice_serious25 = total(temp4)

drop temp*
drop if tag == 0

keep pieceid sum*
destring, replace
save `filedata'tempdta/trips-piece, replace

use `filedata'tempdta/battle-pp, clear
bysort pieceid: egen sumerrors = total(numerrors)
bysort pieceid: keep if _n == 1
keep pieceid sumerror
destring, replace
save `filedata'tempdta/battle-piece, replace

use `filedata'tempdta/change-pp, clear
bysort pieceid: gen sumchanges = _N
bysort pieceid userid: gen temp1 = (_n == 1)
bysort pieceid: egen sumusers = total(temp1)
bysort pieceid userid: gen temp2 = _N
bysort pieceid: egen sumsuperusers = total(temp1 * (temp2 > 10))

drop temp*

bysort pieceid: drop if _n > 1
keep pieceid sum*
destring pieceid, replace

save `filedata'tempdta/change-piece, replace

************************************************
6. Merge piece outcome to maps
************************************************
  
use `filedata'tempdta/piecemap_merge, clear

merge 1:1 pieceid using `filedata'tempdta/change-piece, keep(match master) nogen

replace sumchanges = 0 if sumchanges == .
replace sumusers = 0 if sumusers == .
replace sumsuperusers = 0 if sumsuperusers == .

merge 1:1 pieceid using `filedata'tempdta/trips-piece, keep(match master) nogen

replace sumtrips = 0 if sumtrips == .
replace sumdevice = 0 if sumdevice == .
replace sumdevice_serious = 0 if sumdevice_serious == .
replace sumdevice_serious10 = 0 if sumdevice_serious10 == .
replace sumdevice_serious25 = 0 if sumdevice_serious25 == .

merge 1:1 pieceid using `filedata'tempdta/battle-piece, keep(match master) nogen

drop if state_name == "Alaska"
drop if state_name == "Hawaii"

save `filedata'tempdta/masterpiece, replace

************************************************
6. Intermediate dataset
************************************************

use `filedata'tempdta/masterpiece, clear

drop if ismsa == 0

**** create variables

gen lnpopulation = ln(population)
gen lnhh = ln(hh)
gen lnincome = ln(income)
gen lnareap = ln(areap)

gen a2 = areapiece^2
gen p2 = population^2
gen p3 = population^3
gen p4 = population^4
gen p5 = population^5

bysort geoid: egen sumtreat = total(population*treat)
bysort geoid: egen sumpop = total(population)
bysort geoid: gen avgtreat = sumtreat / sumpop

gen ismix = 1 if avgtreat < 0.96 & avgtreat > 0.051
replace ismix = 0 if ismix == .

save `filedata'tempdta/masterpiece2, replace


**********************************************
7. Create county dataset
*********************************************

use `filedata'tempdta/masterpiece, clear
bysort fips: egen numtrips = total(sumtrips)
bysort fips: egen numdevice = total(sumdevice)
bysort fips: egen numdevice_serious = total(sumdevice_serious)
bysort fips: egen numdevice_serious10 = total(sumdevice_serious10)
bysort fips: egen numdevice_serious25 = total(sumdevice_serious25)

bysort fips: egen numchanges = total(sumchanges)
bysort fips: egen numusers = total(sumusers)
bysort fips: egen numsuperusers = total(sumsuperusers)
bysort fips: egen numerrors = total(sumerrors)

drop countypop county_pop_ county_area_

bysort fips: egen countypop = total(population)
bysort fips: egen countyhh = total(hh)

gen tmp1 = income * population
bysort fips: egen countyinc = sum(tmp1)
replace countyinc = countyinc / countypop

bysort fips: drop if _n > 1

drop sum* msaname geoid pieceid income hh population

gen lnhh = ln(countyhh)
gen lnpopulation = ln(countypop)
gen lnarea = ln(countyarea)
gen lninc = ln(countyinc)

save `filedata'tempdta/masterpiece3, replace

*** steps

1. compare county with and without treatment on baseline
2. regress outcomes on treatment with and without controls
3. perform matching and then comapre

3. consider only MSAs and compare baseline with and without treatment
4. regress outcomes with geo fixed effects in mixed MSAs
5. perform matching and then compare, in non-mixed and in complete

*** results

******************************************
8. Analyze This! -- County
******************************************

use `filedata'tempdta/masterpiece3, clear

*** summary stats

estpost tabstat treat countypop countyinc countyhh countyarea, s(mean median sd min max) columns(statistics)

estpost tabstat numtrips numdevice numdevice_serious25 numchange numusers numsuperusers, s(mean median sd min max) columns(statistics)

*** treatment vs. control

foreach x in numtrips numdevice numdevice_serious10 numchange numsuperusers {
    gen ln`x' = ln(`x') if `x' > 0
    * replace ln`x' = ln(`x'+0.1) if `x' == 0
}

local varname lnpop
local varname lninc
foreach varname in lnpop lninc lnarea lnhh numdevice_serious10 numsuperusers{
    qui sum `varname' if treat == 0
    local a1 = r(mean)
    qui sum `varname' if treat == 1
    local a2 = r(mean)

    qui ttest `varname', by(treat)
    local se = round(r(se),.001)
    local diff = round(r(mu_2)-r(mu_1),.01)

    twoway (histogram `varname' if treat==1, color(green) width(.1)) (histogram `varname' if treat==0, fcolor(none) lcolor(black) width(.1)), legend(order(1 "Treat" 2 "Control" )) xline(`a1',lcolor(black)) xline(`a2',lcolor(green)) text(-8 -4 "Diff = `diff'(`se')", place(w))
    graph export `tables'avgtreat_hist_cnty_`varname'.eps, replace


    twoway (kdensity `varname' if treat==1) (kdensity `varname' if treat==0)
    graph export `tables'avgtreat_kdens_cnty_`varname'.eps, replace

}

di "MEAN DIFFERENCES"
foreach varname in lnpop lninc lnarea lnhh {
    qui ttest `varname', by(treat)
    local se = round(r(se),.001)
    local diff = round(r(mu_2)-r(mu_1),.01)

    di "`varname'"
    di `diff'
    di `se'
    di "-----"
}

**** basic regression

use `filedata'tempdta/masterpiece3, clear

** simple mean comparisons

ttest numtrip, by(treat)
ttest numdevice, by(treat)
ttest numdevice_serious10, by(treat)

ttest numchange, by(treat)
ttest numuser, by(treat)
ttest numsuperuser, by(treat)

** with controls

egen regionid = group(region)

local depvar "treat"
local controls ""
local controls "lnpop lninc lnhh"
local controls "lnpop lninc lnhh lnarea"
local cluster ", cluster(state_fips)"

est clear
eststo: qui poisson numtrip `depvar' `controls' `cluster'
eststo: qui poisson numdevice `depvar' `controls' `cluster'
eststo: qui poisson numdevice_serious25 `depvar' `controls' `cluster'

eststo: qui poisson numchange `depvar' `controls' `cluster'
eststo: qui poisson numusers `depvar' `controls' `cluster'
eststo: qui poisson numsuperusers `depvar' `controls' `cluster'

esttab est1 est2 est3, keep(treat) se width(0.75\hsize) mtitles("Trips" "Devices" "Regular Users") star(* 0.10 ** 0.05 *** 0.01) 

esttab est1 est2 est3, keep(treat) se width(0.75\hsize) mtitles("Trips" "Devices" "Regular Users") star(* 0.10 ** 0.05 *** 0.01) eform

esttab est4 est5 est6, keep(treat) se width(0.75\hsize) mtitles("Changes" "Contribs" "Super Contribs") star(* 0.10 ** 0.05 *** 0.01)

esttab est4 est5 est6, keep(treat) se width(0.75\hsize) mtitles("Changes" "Contribs" "Super Contribs") star(* 0.10 ** 0.05 *** 0.01) eform

******************************************
8. Analyze This! -- MSA
******************************************

use `filedata'tempdta/masterpiece2, clear

*** balance checks

foreach x in sumtrips sumdevice sumdevice_serious10 sumchange sumsuperusers {
    gen ln`x' = ln(`x') if `x' > 0
    * replace ln`x' = ln(`x'+0.1) if `x' == 0
}

foreach varname in lnpop lnincome lnareap lnsumtrips lnsumdevice_serious lnsumsuperusers{
    qui sum `varname' if treat == 0
    local a1 = r(mean)
    qui sum `varname' if treat == 1
    local a2 = r(mean)

    qui ttest `varname', by(treat)
    local se = round(r(se),.001)
    local diff = round(r(mu_2)-r(mu_1),.01)

    twoway (histogram `varname' if treat==1, color(green) width(.1)) (histogram `varname' if treat==0, fcolor(none) lcolor(black) width(.1)), legend(order(1 "Treat" 2 "Control" )) xline(`a1',lcolor(black)) xline(`a2',lcolor(green)) text(-8 -4 "Diff = `diff'(`se')", place(w))
    graph export `tables'avgtreat_hist_msa_`varname'.eps, replace
}

******************************************
10. Analyze This! -- Change Panel
******************************************

use `filedata'tempdta/panelchange, clear

bysort userid: gen totalc = _N
bysort fips month userid : gen tmp1 = (_n==1)
bysort fips month userid : gen tmp2 = (_n==1)*(totalc >= 10)

bysort fips month: gen numchange = _N
bysort fips month: egen numuser = total(tmp1)
bysort fips month: egen numserioususer = total(tmp2)

bysort fips month: drop if _n > 1

keep treat post fips month numchange numuser numserioususer 

sort fips month
tsset fips month
tsfill, full

bysort fips: carryforward treat, gen(treaty)

gsort fips - month
bysort fips: carryforward treaty, gen(treatfinal)
drop treat treaty

replace post =  month > mofd(date("1-1-2008","MDY"))

replace numchange = 0 if numchange == .
replace numuser = 0 if numuser == .
replace numserioususer = 0 if numserioususer == .

save `filedata'panelchange2, replace

******************************************
10b. Analyze This! -- Estimates
******************************************

use `filedata'panelchange2, clear

gen quarter = qofd(dofm(month))

xtset fips month

estpost tabstat post treat numchange numuser numserioususer, s(mean median sd min max) columns(statistics)

xtreg numchange post##treat i.mont, vce(cluster fips) fe

xtpoisson sumchange post##treat i.startmonth, vce(robust) fe


xtpoisson numuser post##treat i.month, vce(robust) fe
xtpoisson numserious post##treat i.fips, vce(robust) fe
xtpoisson numchange post##treat i.month, vce(robust) fe



xtpoisson numuser post##treat i.month, vce(robust) fe


xtpoisson sumseriou post##treat

xtpoisson sumseriou post##treat i.startm


xtpoisson num post##treat i.mont, vce(robust) fe


est clear
eststo: qui xtreg numchange post##treat i.mont, vce(cluster fips) fe
eststo: qui xtreg numuser post##treat i.mont, vce(cluster fips) fe
eststo: qui xtreg numserioususer post##treat i.mont, vce(cluster fips) fe

eststo: qui xtpoisson numchange post##treat, vce(robust) fe
eststo: qui xtpoisson numuser post##treat i.mont, vce(robust) fe

esttab est5, keep(1.post 1.post#1.treatfinal) se
esttab est1 est2 est3, keep(1.post 1.post#1.treat) se
esttab est4 est5 est6, keep(1.post 1.post#1.treat) se

******************************************
10c. Analyze This! -- Time varying
******************************************

use `filedata'panelchange2, clear
    
xtpoisson numserioususer treat##b576.month, fe vce(robust)

qui parmest, label list(parm estimate min* max* p) saving(`filedata'tempdta/mypars, replace)

clear
use `filedata'tempdta/mypars

keep if regexm(parm, "1.*treatfinal.*mont.*") == 1
gen month = regexs(1) if regexm(parm, ".*#([0-9][0-9][0-9])b?\..*")

destring month, replace
    
qui gen xaxis = 0

graph twoway (line estimate month, msize(small) lpattern(dash) lcolor(edkblue) lwidth(thin))  if month < 595 & month > 560

graph twoway (line estimate month, msize(small) lpattern(dash) lcolor(edkblue) lwidth(thin)) (line max month, lwidth(vthin) lpattern(-) lcolor(gs8)) (line min month, lwidth(vthin) lpattern(-) lcolor(gs8)) (line xaxis month, lwidth(vthin) lcolor(gs8)) if month < 595 & month > 565

, yscale(range(-0.3 0.8)) xtitle("") ytitle("`yt'") xlabel(2006(1)2012) legend(off) title("Panel `vartitle' Players") ylabel(-0.2 (0.2) 0.8)

graph export `tables'timeline.eps, replace

graph export "../tables/timeline`var'.eps", replace
shell epstopdf  "../tables/timeline`var'.eps"


******************************************************
11. Cross Section Positive Estimates
******************************************************


    

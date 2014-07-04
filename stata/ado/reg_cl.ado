program reg_cl

makechange_cl
makebugs

run_reg_map


program run_reg_bugs

use ${clist}bugs, clear

bysort fips: gen bugs = _N
bysort fips: drop if _n > 1

gen percent = closed / (closed + open)
gen c2 = cntypop^2

gen hi_comp = (emp_comp > 20000)

label variable bugs "Bugs"

est clear
eststo: reg bugs 1.treat cntypop emp_earn, robust
qui estadd local statefe "No"
qui estadd local controls "Yes"
estimates save ${myestimates}reg_cl5, replace

est clear
eststo: reg bugs treat##hi_comp cntypop emp_earn, robust
qui estadd local statefe "No"
qui estadd local controls "Yes"
estimates save ${myestimates}reg_cl6, replace

end


program run_reg_map

use ${clist}mergemaster1_cl, clear
merge m:1 fips using ${clist}change_cl, keep(match master)
drop _m

gen map = (ismap == "map")
gen hi_comp = (emp_comp > 20000)
gen hi_user = (numuser > 300)
label variable map "HasMap"

est clear
eststo: qui reg map 1.treat i.state, robust
qui estadd local statefe "Yes"
qui estadd local controls "No"
estimates save ${myestimates}reg_cl1, replace

eststo: qui reg map 1.treat i.state cntypop emp_earn, robust
qui estadd local statefe "Yes"
qui estadd local controls "Yes"
estimates save ${myestimates}reg_cl2, replace

eststo: qui reg map treat##hi_user i.state cntypop emp_earn, robust
qui estadd local statefe "Yes"
qui estadd local controls "Yes"
estimates save ${myestimates}reg_cl3, replace

eststo: qui reg map treat##hi_comp i.state cntypop emp_earn, robust
qui estadd local statefe "Yes"
qui estadd local controls "Yes"
estimates save ${myestimates}reg_cl4, replace

end


program load_reg

est clear
forval x = 1(1)6{
    estimates use ${myestimates}reg_cl`x'
    eststo est`x'
}

end

program write_reg

esttab using "${tables}reg_cl.tex", drop(*.state _cons cntypop emp_earnings 0b* 1o*) se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(1.treat "TIGER" 1.hi_user "HiUser" 1.treat#1.hi_user "TIGER X HiUser" 1.hi_comp "HiComputerScience" 1.treat#1.hi_comp "TIGER X HiComputerScience" _cons "Constant") replace booktabs  s(statefe controls N, label("State FE" "Controls")) mtitles("HasMap" "HasMap" "HasMap" "HasMap" "Bugs" "Bugs")

end


program makebugs

insheet using ${rawosm}cl_notes_gc.csv, clear

rename v1 timestamp
rename v2 id
rename v3 lat
rename v4 lon
rename v5 link
rename v6 status
rename v7 fips
rename v8 geoid10

drop if fips == "NA"

merge m:1 fips using ${stash}cleancnty, keep(match) nogen

save ${clist}bugs, replace

end


program makechange_cl

use ${stash}cleanchangeset1, clear
bysort fips: gen numcontrib = _N

bysort fips uid: gen tmp = (_n==1)
bysort fips: egen numuser = total(tmp)

bysort fips: drop if _n > 1
keep fips numcontrib numuser
save ${clist}change_cl, replace

end

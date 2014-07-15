program kingcounty

makedata
makedv_county
balancepanel_county
save ${stash}hway_county, replace

end


program run_reg

use ${stash}hway_county, clear

replace highwayid = unitid

**gen treat = (fips=="06047")
gen year = year(dofm(month))

gen didowner = (numowner > 0)

poisson numowner istiger##treat i.year, robust

est clear
eststo: reg numowner istiger##treat i.year, cluster(fips)
eststo: poisson numowner istiger##treat i.year, cluster(fips)

poisson numusers istiger##treat i.year, cluster(fips)
poisson numchanges istiger##treat i.year, cluster(fips)

esttab using "${tables}reg_county.tex", drop(*.year 0b* 1o*) star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(1.treat "TREATED COUNTY" 1.istiger "GOVT. CREATED" 1.istiger#1.treat "TREAT X GOVT") replace s(N N_g, label(N "Clusters")) mtitles("OwnerEdits (OLS)" "OwnerEdits (Poisson)") nocons booktabs


poisson numowner istiger##treat i.year i.highwayclass if highwayclass>0, cluster(fips)


poisson numowner istiger##treat i.year, cluster(fips)

codebook cntypop

reg numowner istiger##treat i.year, cluster(fips)

logit didowner istiger##treat i.year, cluster(fips)

codebook firstuser if istiger==1 & treat==1

codebook numowner




bysort highwayid fips: gen tmp = (_n==1)
bysort highwayid: egen numfips = total(tmp)

codebook highwayid if numfips  == 2
codebook highwayid if numfips  == 1

bysort highwayid: gen htag = (_n==1)

tab istiger if numfips == 2 & htag==1
tab name if numfips == 2 & htag==1

poisson numchanges istiger i.year


end

program explore_reg

use ${stash}hway_county, clear

sort unitid month
format firstm %tm

keep if treat == 1

bysort istiger month: egen newadded = total(month==firstmonth)
bysort istiger month: egen numupdated = total(numchanges>0)
bysort istiger month: egen avgattr = mean(hasattr)
bysort istiger month: egen avguser = mean(numusers)
bysort istiger month: egen avgowner = mean(numowner)
bysort istiger month: egen totowner = total(numowner)
bysort istiger month: egen didowner = total((numowner>0)/numupd)


bysort istiger month: gen tag = (_n==1)

gen newa_tiger = sum(newadd * (istiger==1)*(tag==1))
gen newa_control = sum(newadd * (istiger==0)*(tag==1))
gen newa_sum = .
replace newa_sum = newa_tiger if ist == 1
replace newa_sum = newa_control if ist == 0
drop newa_ti newa_cont

gen percentupdated = numupd / newa_sum

list newadd newa_ numupd month istiger if month == 621 & tag == 1


local var didown
local var avgown
local var totown
local var newa
local var newa_sum
local var numupd
local var avgattr
local var percentup


replace `var' = 10 if `var' > 10

tw (connected `var' month if istiger == 0 & tag==1) (connected `var' month if istiger == 1 &tag==1), legend(order(2 "TIGER Counties" 1 "Control Counties" )) 

graph export ${tables}tmp1.eps, replace
 
codebook 

end

program makedv_county

**use ${stash}king_tmp, clear

use ${stash}county_tmp, clear

keep if highwayclass == 3
keep if stname == "Washington"

**bysort highwayid: egen mixtiger = mean(istiger)

bysort highwayid month: gen numchanges = _N
bysort highwayid month: egen maxattrib = max(hasattrib)
bysort highwayid: gen firstmonth = month[1]
bysort highwayid: gen firstuser = user[1]
bysort highwayid month: egen numowner = total(firstuser==user)

bysort highwayid month user: gen tmp = (_n==1)
bysort highwayid month: egen numusers = total(tmp)
drop tmp

drop if firstuser == ""

end

program balancepanel_county

bysort highwayid month: drop if _n > 1
drop unitid
gen unitid = highwayid

drop if stname == "Massachusetts"
** allegheny county, PA
drop if fips == "42003"

tsset unitid month
tsfill, full

local outcomes "numchanges maxattrib numowner numusers"

foreach x in `outcomes'{
    replace `x' = 0 if `x' == .
}


local covars "istiger firstmonth name hasattr fips highwayclass state treat cntypop"

foreach x in `covars'{
    gsort unitid month
    bysort unitid: carryforward `x', gen(tmp1)
    gsort unitid -month
    bysort unitid: carryforward tmp1, gen(tmp2)
    replace `x' = tmp2
    drop tmp1 tmp2
    di "finished `x'"
    di "---"
}

end


program makedata

use ${stash}mergemaster_way, clear

merge m:1 fips using ${stash}cleancnty, keep(match) nogen keepusing(treat state stname cntypop)

// control: fresno == 06019
// control: santa clara = 06085 / 1.8 million

// control: madera = 06039
// treat : merced = 06047 

// treat: stanislaus = 06099 
// treat: san joaquin = 06077 / pop 702k

**keep if (fips == "06039" | fips == "06047")

egen highwayid = group(name)
replace highwayid = . if ishighway == 0
replace highwayid = . if name == "NA"
drop if highwayid == .

**save ${stash}king_tmp, replace
**save ${stash}ca_tmp, replace
save ${stash}county_tmp, replace

end

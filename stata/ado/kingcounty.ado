program kingcounty

makedata
makedv_county
balancepanel_county

end


program run_reg

sort unitid month
format firstm %tm

bysort istiger month: egen newadded = total(month==firstmonth)
bysort istiger month: egen numupdated = total(numchanges>0)
bysort istiger month: egen avgattr = mean(hasattr)

bysort istiger month: gen tag = (_n==1)

gen newa_tiger = sum(newadd * (istiger==1)*(tag==1))
gen newa_control = sum(newadd * (istiger==0)*(tag==1))
gen newa_sum = .
replace newa_sum = newa_tiger if ist == 1
replace newa_sum = newa_control if ist == 0
drop newa_ti newa_cont

gen percentupdated = numupd / newa_sum

list newadd newa_ numupd month istiger if month == 621 & tag == 1


local var newa
local var newa_sum
local var numupd
local var avgattr
local var percentup


replace `var' = 1200 if `var' > 1200

tw (connected `var' month if istiger == 0 & tag==1) (connected `var' month if istiger == 1 &tag==1), legend(order(2 "TIGER Counties" 1 "Control Counties" )) 

graph export ${tables}tmp1.eps, replace

codebook 

end

program makedv_county

**use ${stash}king_tmp, clear
use ${stash}ca_tmp, clear

keep if highwayclass == 3

**bysort highwayid: egen mixtiger = mean(istiger)

bysort highwayid month: gen numchanges = _N
bysort highwayid month: egen maxattrib = max(hasattrib)
bysort highwayid: gen firstmonth = month[1]

end

program balancepanel_county

bysort highwayid month: drop if _n > 1
drop unitid
gen unitid = highwayid

tsset unitid month
tsfill, full

local outcomes "numchanges maxattrib"

foreach x in `outcomes'{
    replace `x' = 0 if `x' == .
}


local covars "istiger firstmonth name hasattr"

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

// control: fresno == 06019
// control: santa clara = 06085 / 1.8 million

// control: madera = 06039
// treat : merced = 06047 

// treat: stanislaus = 06099 
// treat: san joaquin = 06077 / pop 702k

keep if (fips == "06039" | fips == "06047")

egen highwayid = group(name)
replace highwayid = . if ishighway == 0
replace highwayid = . if name == "NA"
drop if highwayid == .

**save ${stash}king_tmp, replace
save ${stash}ca_tmp, replace

end

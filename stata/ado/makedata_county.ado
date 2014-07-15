program makedata_county

make_data
makedv_county
balancepanel_county
save ${stash}hway_WA, replace

end


program make_data

use ${stash}mergemaster_way, clear

merge m:1 fips using ${stash}cleancnty, keep(match) nogen keepusing(treat state stname cntypop)

egen highwayid = group(name)
replace highwayid = . if ishighway == 0
replace highwayid = . if name == "NA"
drop if highwayid == .

save ${stash}county_tmp, replace


end

program makedv_county

use ${stash}county_tmp, clear

keep if highwayclass == 3
keep if stname == "Washington"

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

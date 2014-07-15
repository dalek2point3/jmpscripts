program reg_layers

make_data
run_reg
run_reg_attrib

load_reg
write_reg

load_reg _attr
write_reg_attr

end

program make_data

use ${stash}panelway, clear

rename numamenity numamenity_way

merge 1:1 fips month using ${stash}panelnode
drop if _m==1

gen otherlayer = numbuilding + numamenity + numparking +numamenity_way + numaddr

gen amenities = numamenity + numamenity_way
gen bld_addr = numbuilding + numaddr

bysort fips: gen tag = (_n==1)

save ${stash}panelotherlayers, replace

end


program run_reg

local cutoff 200169
**local cutoff 315000

use ${stash}panelotherlayers, clear


est clear
eststo: qui xtpoisson otherl treat##post i.year if cntypop < `cutoff' & year > 2006, fe vce(robust)
qui estadd local yearfe "Yes"
qui estadd local countyfe "Yes"
estimates save ${myestimates}reg_layers1, replace

eststo: qui xtpoisson amenities treat##post i.year if cntypop < `cutoff' & year > 2006, fe vce(robust)
qui estadd local yearfe "Yes"
qui estadd local countyfe "Yes"
estimates save ${myestimates}reg_layers2, replace

eststo: qui xtpoisson bld_addr treat##post i.year if cntypop < `cutoff' & year > 2006, fe vce(robust)
qui estadd local yearfe "Yes"
qui estadd local countyfe "Yes"
estimates save ${myestimates}reg_layers3, replace

eststo: qui xtpoisson numclass4 treat##post i.year if cntypop < `cutoff' & year > 2006, fe vce(robust)
qui estadd local yearfe "Yes"
qui estadd local countyfe "Yes"
estimates save ${myestimates}reg_layers4, replace

end


program run_reg_attrib

est clear
local cutoff 200169

forval x = 1(1)4{
    eststo: qui xtpoisson numattrib`x' treat##post i.year if cntypop < `cutoff' & year > 2006, fe vce(robust)
    qui estadd local yearfe "Yes"
    qui estadd local countyfe "Yes"
    estimates save ${myestimates}reg_layers_attr`x', replace
}


end

program load_reg

local attr `1'
est clear
forval x = 1(1)4{
    estimates use ${myestimates}reg_layers`attr'`x'
    eststo est`x'
}

end

program write_reg

esttab using "${tables}reg_layers.tex", drop(*.year 0b* 1o* 1.treat) star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(1.treat "TIGER" 1.post "POST" 1.treat#1.post "TIGER X POST") replace booktabs order(1.treat#1.post 1.post) s(countyfe yearfe N N_g, label("County FE" "Year FE" N "Clusters")) mtitles("NonStreet Layers" "Amenities" "Buildings/Addresses" "Trails/Bikepaths Added")

end


program write_reg_attr

esttab using "${tables}reg_attr.tex", drop(*.year 0b* 1o* 1.treat) star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(1.treat "TIGER" 1.post "POST" 1.treat#1.post "TIGER X POST") replace booktabs order(1.treat#1.post 1.post) s(countyfe yearfe N N_g, label("County FE" "Year FE" N "Clusters")) mtitles("Major Highways" "Class 2 Roads" "Class 3 Roads" "Trails and Bikepaths")

end

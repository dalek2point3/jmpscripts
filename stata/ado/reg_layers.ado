program reg_layers

make_data
run_reg
write_reg


run_reg_attrib


load_reg _attr
write_reg_attr

end

program make_data

use ${stash}panel_wn, clear

gen otherlayer = numbuilding + numamenity + numparking + numaddr
gen bld_addr = numbuilding + numaddr

** save ${stash}panelotherlayers, replace

end


program run_reg

use ${stash}panel_wn, clear


gen otherlayer = numbuilding + numamenity + numparking + numaddr
gen bld_addr = numbuilding + numaddr
gen other = numparking + numamenity + numclass4

gen lnotherlayer = ln(otherlayer+1)
gen lnbld_addr = ln(bld_addr+1)
gen lnnumamenity = ln(numamenity+1)
gen lnnumclass4 = ln(numclass4+1)
gen lnnumbuilding = ln(numbuilding+1)
gen lnnumaddr = ln(numaddr+1)
gen lnother = ln(other+1)

local depvars "otherlayer bld_addr numamenity numclass4 "
local depvars "numbuilding numaddr"
local depvars "other"

foreach x in `depvars'{
    est clear

    eststo est1: qui xtreg ln`x' treat##post, fe cluster(fips)
    qui estadd local yearfe "No"
    qui estadd local countyfe "Yes"
    estimates save ${myestimates}reg_layers_`x'_1, replace
    
    eststo est2: qui xtreg ln`x' treat##post i.year, fe cluster(fips)
    qui estadd local yearfe "Yes"
    qui estadd local countyfe "Yes"
    estimates save ${myestimates}reg_layers_`x'_2, replace

    eststo est3: qui xtpoisson `x' treat##post i.year, fe vce(robust)
    qui estadd local yearfe "Yes"
    qui estadd local countyfe "Yes"
    estimates save ${myestimates}reg_layers_`x'_3, replace

}

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
local x `1'
est clear
forval y = 1(1)3{
    estimates use ${myestimates}reg_layers_`x'_`y'
    eststo est`x'_`y'
  }
end


program localdef

global top "drop(*.year 0b* 1o* 1.post _cons) star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(1.treat#1.post "TIGER X POST") booktabs order(1.treat#1.post)  stats(, labels()) nomtitles nocons replace width(\hsize) postfoot(\end{tabular*} }) prefoot("") varwidth(25) eqlabels("") noisily"

global middle "drop(*.year 0b* 1o* 1.post _cons) star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(1.treat#1.post "TIGER X POST") booktabs order(1.treat#1.post)  stats(, labels()) nomtitles nocons width(\hsize) postfoot(\end{tabular*} }) prefoot("") append collabels(none) prehead(`"{"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' \begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}) nonumbers eqlabels("")"

global end "drop(*.year 0b* 1o* _cons 1.post) star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(1.treat#1.post "TIGER X POST") booktabs order(1.treat#1.post) s(countyfe yearfe N N_g, label("County FE" "Year FE" N "Clusters")) nomtitles nocons append width(\hsize) nonumbers prehead(`"{"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' \begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}) eqlabels("")"
/* \""'' */
   
end

program write_reg

localdef

load_reg otherlayer
esttab using "${tables}reg_layers.tex", ${top} posthead("\midrule \textbf{Panel A : Other Layers}\\")

load_reg bld_addr
esttab using "${tables}reg_layers.tex",  ${middle} posthead("\midrule \textbf{Panel B : Bld/Address}\\")

load_reg numamenity
esttab using "${tables}reg_layers.tex",   ${middle} posthead("\midrule \textbf{Panel C: Num Amenity}\\")

load_reg numclass4
esttab using "${tables}reg_layers.tex",  ${end} posthead("\midrule \textbf{Panel D : Class4 Roads}\\")

end


program write_reg_attr

esttab using "${tables}reg_attr.tex", drop(*.year 0b* 1o* 1.treat) star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(1.treat "TIGER" 1.post "POST" 1.treat#1.post "TIGER X POST") replace booktabs order(1.treat#1.post 1.post) s(countyfe yearfe N N_g, label("County FE" "Year FE" N "Clusters")) mtitles("Major Highways" "Class 2 Roads" "Class 3 Roads" "Trails and Bikepaths")

end

program run_reg_old

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

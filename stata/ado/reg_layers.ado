program reg_layers

make_data
run_reg
write_reg

end

program make_data

use ${stash}panel_wn, clear

gen otherlayer = numbuilding + numamenity + numparking + numaddr
gen bld_addr = numbuilding + numaddr

** save ${stash}panelotherlayers, replace

end


program run_reg

use ${stash}panel_wn, clear

gen otherlayer = numbuilding + numamenity + numparking + numaddr + numclass4
gen bld_addr = numbuilding + numaddr
gen other = numparking + numamenity + numclass4
gen numattrib12 = numattrib1 + numattrib2
gen numattrib34 = numattrib3 + numattrib4

local depvars "otherlayer bld_addr numamenity numclass4 "
local depvars "numbuilding numaddr"
local depvars "otherlayer numattrib12 numattrib3"
local depvars "otherlayer"

foreach x in `depvars'{
    est clear

    gen ln`x' = ln(`x'+1)
    eststo est1: qui xtreg ln`x' treat##post if year>2006, fe cluster(fips)
    qui estadd local yearfe "No"
    qui estadd local countyfe "Yes"
    estimates save ${myestimates}reg_layers_`x'_1, replace
    
    eststo est2: qui xtreg ln`x' treat##post i.year if year>2006, fe cluster(fips)
    qui estadd local yearfe "Yes"
    qui estadd local countyfe "Yes"
    estimates save ${myestimates}reg_layers_`x'_2, replace

    eststo est3: qui xtpoisson `x' treat##post i.year if year>2006, fe vce(robust)
    qui estadd local yearfe "Yes"
    qui estadd local countyfe "Yes"
    estimates save ${myestimates}reg_layers_`x'_3, replace

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
/* \""' */
** ""

end

program write_reg

localdef

load_reg otherlayer
esttab using "${tables}reg_layers.tex", ${top} posthead("\midrule \textbf{Panel A : Other Layers}\\")

load_reg numattrib12
esttab using "${tables}reg_layers.tex",  ${middle} posthead("\midrule \textbf{Panel B : Class1 Attrib}\\")

load_reg numattrib3
esttab using "${tables}reg_layers.tex",   ${end} posthead("\midrule \textbf{Panel C : Class3 Attrib}\\")

/*load_reg numattrib4
esttab using "${tables}reg_layers.tex",  ${end} posthead("\midrule \textbf{Panel D : Class4 Roads}\\")
*/

end


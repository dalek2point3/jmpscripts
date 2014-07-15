program reg_owner

makedata_county


end


program load_reg

end

program run_reg

use ${stash}hway_WA, clear

replace highwayid = unitid

gen year = year(dofm(month))
gen didowner = (numowner > 0)
gen post = (month > 573)

gen nonowner = numchanges - numowner

bysort highwayid: egen tmp = mean(treat)
gen ismix = tmp > 0 & tmp < 1
drop tmp

*outcomes "numchanges maxattrib numowner numusers"

reg numchanges istiger##treat i.year, robust

eststo: xtreg nonowner istiger##treat i.year, robust

eststo: xtreg numchanges istiger##treat i.year, robust


xtnbreg numchanges treat##post i.year, fe

est clear

reg numowner istiger##treat i.year, vce(robust)
reg nonowner istiger##treat i.year, vce(robust)
reg numchanges istiger##treat i.year, vce(robust)


eststo: reg numowner istiger##treat i.year, vce(robust)
qui estadd local streetfe "No"
qui estadd local yearfe "Yes"
estimates save ${myestimates}reg_ownernofe, replace

eststo: xtreg numowner istiger##treat i.year, vce(robust) fe
qui estadd local streetfe "Yes"
qui estadd local yearfe "Yes"
estimates save ${myestimates}reg_ownerfe, replace

esttab est1 est2, keep(1.istiger 1.treat 1.istiger#1.treat) stat(N N_g)




xtreg numchanges istiger##treat i.year, robust fe


destring fips, replace


xtreg numowner istiger##treat i.year, robust fe

xtreg numchanges istiger##treat i.year, robust fe

bysort unitid: egen avgtreat = mean(treat)

codebook avgtreat
unique unitid if avgtreat > 0 & avgtreat < 1

poisson numowner istiger##treat i.year, robust

est clear
eststo: reg numowner istiger##treat i.year, cluster(fips)
eststo: poisson numowner istiger##treat i.year, cluster(fips)

poisson numusers istiger##treat i.year, cluster(fips)
poisson numchanges istiger##treat i.year, cluster(fips)

esttab using "${tables}reg_county.tex", drop(*.year 0b* 1o*) star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(1.treat "TREATED COUNTY" 1.istiger "GOVT. CREATED" 1.istiger#1.treat "TREAT X GOVT") replace s(N N_g, label(N "Clusters")) mtitles("OwnerEdits (OLS)" "OwnerEdits (Poisson)") nocons booktabs



end

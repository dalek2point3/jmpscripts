** this ado produces 2 kinds of density plots
* with option "kdensity" it logs the var and produces density
* with option "hist" it adds value labels for 1/4 and produceds hist

program makehist

local mode `2'
gen var = `1'

di "---"
di "    generating histogram(`mode') for `1'   "
di "---"

makehist_`mode'

drop lnvar var

end

program makehist_kdensity

gen lnvar = ln(var)

twoway (kdensity lnvar if treat==1) (kdensity lnvar if treat==0), title(Population Distribution) legend(order(1 "TIGER Counties" 2 "Control Counties")) ytitle("")

graph export ${tables}kdens_cnty.eps, replace
shell epstopdf ${tables}kdens_cnty.eps

end


program makehist_hist

gen lnvar = var

label define divisionl 1 "Northeast" 2 "Midwest" 3 "South" 4 "West"
label values lnvar divisionl

** region hist

twoway (hist lnvar if treat==1, discrete color(green) barwidth(0.8)) (hist lnvar if treat==0, discrete fcolor(none) lcolor(black) barwidth(0.8)), title(Regional Distribution) legend(order(1 "TIGER Counties" 2 "Control Counties")) ytitle("") xlabel(1/4, valuelabel noticks) xtitle("") 

graph export ${tables}hist_cnty.eps, replace
shell epstopdf ${tables}hist_cnty.eps

** division hist

label define division2 1 "New England" 2 "Middle Atlantic" 3 "East North Central" 4 "West North Central" 5 "South Atlantic" 6 "East South Central" 7 "West South Central" 8 "Mountain" 9 "Pacific"

label values division division2

twoway (hist division if treat==1, discrete color(green) barwidth(0.8)) (hist division if treat==0, discrete fcolor(none) lcolor(black) barwidth(0.8)), title(Regional Distribution) legend(order(1 "TIGER Counties" 2 "Control Counties")) ytitle("") xlabel(1/9, valuelabel noticks labsize(tiny)) xtitle("") 

graph export ${tables}hist_cnty_div.eps, replace
shell epstopdf ${tables}hist_cnty_div.eps

end



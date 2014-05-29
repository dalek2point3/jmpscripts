program makehist

gen lnvar = ln(`0')
di "generating histogram for `0'"

twoway (kdensity lnvar if treat==1) (kdensity lnvar if treat==0), title(Population Distribution) legend(order(1 "TIGER Counties" 2 "Control Counties")) ytitle("")

graph export ${tables}kdens_cnty_`0'.eps, replace
drop lnvar

end

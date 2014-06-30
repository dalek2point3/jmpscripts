
program makesummary

label variable treat "1(TIGER)"
label variable cntypop "Population"
label variable year "Year"
label variable age_median "Median Age"
label variable emp_earnings "Earnings"
label variable num_households "Households"


* label variable numcontrib "Contributions"
* label variable numuser "Users"
* label variable numserious90 "Serious Users / Month"
* label variable numnewusers "New Users / Month"

est clear

** local vars "treat year cntypop emp_earnings age_median num_households numcontrib numuser numserious90 numnewusers numnewusers6 numnewusers90 numfirstseen numchanges"

local vars "treat year cntypop emp_earnings age_median num_households numcontrib numuser numserious90 numnewusers"

estpost tabstat `vars', s(mean median sd min max) columns(statistics)

esttab using "${tables}summary.tex", cells ("mean(fmt(2) label(Mean)) sd(label(SD)) p50(label(Median)) min(label(Min)) max(label(Max))" ) coeflabels("Mean" "SD" "Median" "Min" "Max") replace nonum noobs label booktabs width(\hsize) alignment(rrrrr)

end

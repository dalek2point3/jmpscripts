
program makesummary


est clear

** local vars "treat year cntypop emp_earnings age_median num_households numcontrib numuser numserious90 numnewusers numnewusers6 numnewusers90 numfirstseen numchanges"

local vars `0'

estpost tabstat `vars', s(mean median sd min max) columns(statistics)

esttab using "${tables}${tabname}.tex", cells ("mean(fmt(2) label(Mean)) sd(label(SD)) p50(label(Median)) min(label(Min)) max(label(Max))" ) coeflabels("Mean" "SD" "Median" "Min" "Max") replace nonum noobs label booktabs width(\hsize) alignment(rrrrr)

end

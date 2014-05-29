
program makesummary
label variable treat "1(TIGER)"
label variable cntypop "Population"
label variable numcontrib "Contributions / Month"
label variable numuser "Users / Month"
label variable numserious90 "Serious Users / Month"
label variable numnewusers "New Users / Month"

est clear

estpost tabstat treat cntypop numcontrib numuser numserious90 numnewusers, s(mean median sd min max) columns(statistics)

esttab using "${tables}summary.tex", cells ("mean(fmt(2) label(Mean)) sd(label(SD)) p50(label(Median)) min(label(Min)) max(label(Max))" ) coeflabels("Mean" "SD" "Median" "Min" "Max") replace nonum noobs label booktabs width(\hsize) alignment(rrrrr)

end

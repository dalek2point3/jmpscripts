program reg_layers

make_data
run_reg
write_reg

end

program make_data

use ${stash}paneluid, clear

bysort unitid: egen numtime = total(numcontrib>0)
bysort unitid: egen numtime_contrib = total(numcontrib)

replace treat = (treat>0.20)

gen firstq =  qofd(dofm(firstm))

bysort unitid: gen tag=_n==1
format firstm %tm

gen regular = (firstq < 191)

end


program run_reg

local depvars "numcontrib numcontrib_notreat numcontrib_statenotreat"

local controls "treat##post i.time"

est clear

foreach x in `depvars'{

    gen ln`x' = ln(`x'+1)
    eststo: qui xtpoisson `x' `controls', fe vce(robust)
    qui estadd local controls "Yes"
    qui estadd local statefe "Yes"
}

esttab, keep(1.treat#1.post) p

esttab using "${tables}reg_person.tex", keep(1.treat#1.post) star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(1.treat#1.post "TIGER X POST") replace booktabs s(controls statefe N, label("Controls" "State FE" N)) mtitles("Contributions" "Control" "Control(State)")

end


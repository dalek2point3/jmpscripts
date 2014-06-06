program ddperson

local mode `1'

if "`mode'" == "maketables"{
maketables
}

if "`mode'" == "makechart"{
makechart
}

end

program maketables

use ${stash}paneluid, replace

// this is need to avoid too thin data at the left
drop if month < 563

local dv "numcontrib numcontrib_home numcontrib_treat numcontrib_notreat numcontrib_statenotreat numcounties"

diffindiff xtreg "`dv'" "uid" "2014" "run"
diffindiff xtpoisson "`dv'" "uid" "2014" "run"

diffindiff xtreg "`dv'" "uid" "2014" "write"
diffindiff xtpoisson "`dv'" "uid" "2014" "write"

end

program makechart

end

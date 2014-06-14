** local dv "numcontrib numuser numserious90 numnewusers numnewusers6 numnewusers90"

program rundd
di "treat"

local dataset `1'
local unit `2'
local dv `3'
local cutoffs "2014"

di "----- DD Module -----"
di "Dataset: `dataset'"
di "Unit   : `unit'"
di "DVs    : `dv'"
di "---------------------"

// this runs the regressions
foreach y in `cutoffs'{
    foreach x in `dv'{
        shell ./batchreg.sh `dataset' xtpoisson `x' `unit' `y' run
    }
}

end
    
/* foreach x in `dv'{ */
/*    shell ./batchreg.sh `dataset' xtreg `x' `unit' 2014 run */
/* } */

// this loads and writes the regressions to tex
/* program drop _all */

/* foreach y in `cutoffs'{ */
/*     diffindiff xtpoisson "`dv'" `unit' `y' write */
/* } */

/* diffindiff xtreg "`dv'" fips 2014 write */


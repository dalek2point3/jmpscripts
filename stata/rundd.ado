local dv "numcontrib numuser numnewusers numnewusers6 numnewusers90 numserious90"
local cutoffs "2011 2012 2013 2014"

// this runs the regressions
foreach y in `cutoffs'{
    foreach x in `dv'{
        shell ./batchreg.sh panelfips xtpoisson `x' fips `x' run
    }
}

foreach x in `dv'{
   shell ./batchreg.sh panelfips xtreg `x' fips 2014 run
}


// this loads and writes the regressions to tex

foreach y in `cutoffs'{
    diffindiff xtpoisson "`dv'" fips `y' write

}

diffindiff xtreg "`dv'" fips 2014 write


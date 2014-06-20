program acs_pop


insheet using ${rawmaps}ACS_12_5YR_DP02_with_ann.csv, clear

drop if _n == 1

rename hc01_vc80 educ_college
rename hc03_vc80 educ_college_pct

rename hc01_vc91 educ_grad
rename hc03_vc91 educ_grad_pct

rename geoid2 fips

drop hc* geo*

destring educ*, replace ignore("-")


end

program acs_pop

makeemp
makeedu

use ${stash}acs_tmp2, clear
merge 1:1 fips using ${stash}acs_tmp1, nogen
save ${rawmaps}acs, replace

end

program makeemp
insheet using ${rawmaps}acs_emp.csv, clear names

drop if _n == 1

rename hc04_est_vc01 emp_earnings
rename hc01_est_vc02 emp_business
rename hc01_est_vc06 emp_computer

rename geoid2 fips

drop hc* geo*

destring emp*, replace ignore("-")

save ${stash}acs_tmp2, replace
end

program makeedu

// dataset
insheet using ${rawmaps}acs_educ.csv, clear

drop if _n == 1


rename hc01_vc80 educ_college
rename hc03_vc80 educ_college_pct

rename hc01_vc91 educ_grad
rename hc03_vc91 educ_grad_pct

rename geoid2 fips

drop hc* geo*

destring educ*, replace ignore("-")

save ${stash}acs_tmp1, replace


end

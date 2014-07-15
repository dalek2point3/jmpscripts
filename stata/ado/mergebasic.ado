program mergebasic
** use ${stash}cleanchangeset1, clear

merge m:1 fips using ${stash}cleancnty, keep(master match) nogen

merge m:1 geoid10 using ${stash}cleanua, keep(master match) nogen

merge m:1 fips year using ${rawmaps}county_pop, keep(master match) nogen

labelvar

** save ${stash}mergemaster1, replace
end


program labelvar

label variable fips "FIPS"
label variable geoid10 "MetroID"
label variable year "Year"
label variable time "quarter"
label variable post "POST"

label variable treat "1(Treat)"
label variable cntypop "Population"
label variable pop_year "Population"

label variable age_median "Median Age"
label variable emp_earnings "Earnings"
label variable num_households "Households"
label variable percent_white "Pct. White"
label variable educ_college "College Students"
label variable emp_computer "Scientific Workforce"
label variable age_young "Young Pop (<25)"

label variable aland_sqmi "Area (Sq. Miles)"

end

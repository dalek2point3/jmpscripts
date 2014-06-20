
program census_pop

insheet using ${rawmaps}census_pop.csv, clear names

drop if _n == 1

makeage

rename geoid2 fips
* rename geodisplaylabel countyname
* rename hd01_s001 county_population
rename hd02_s026 percent_male
rename hd02_s078 percent_white
rename hd02_s106 num_households

drop hd*
drop geo*

destring percent* num*, replace

save ${rawmaps}census_pop, replace

end



program makeage

forvalues x = 2/19{
    gen str2 tmp=string(`x', "%02.0f")
    local y = tmp
    local z = 5*(`x'-1)
    rename hd02_s0`y' age`z'
    drop tmp
}

qui destring age*, replace

gen age_young = age5 + age10 + age15 + age20 + age25 
gen age_mid = age30 + age35 + age40 + age45 + age50 + age55 + age60
gen age_old = age65 + age70 + age75 + age80 + age85 + age90

keep age_y age_m age_o hd* geo*

rename hd01_s020 age_median

end

program mergebasic
** use ${stash}cleanchangeset1, clear

merge m:1 fips using ${stash}cleancnty, keep(master match) nogen

merge m:1 geoid10 using ${stash}cleanua, keep(master match) nogen

merge m:1 fips year using ${rawmaps}county_pop, keep(master match)



** save ${stash}mergemaster1, replace
end

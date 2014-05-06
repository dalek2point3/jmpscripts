insheet using goodtiles.csv, clear

gen x_tmp = round(xmin, .1)
gen y_tmp = round(ymin, .1)

gen tilename = string(x_tmp) + " / " + string(y_tmp)

save goodtiles, replace

insheet using us1.csv, clear

gen x_tmp = 0.1 * floor(lon/0.1) 
gen y_tmp = 0.1 * floor(lat/0.1) 

gen tilename = string(x_tmp) + " / " + string(y_tmp)

merge m:1 tilename using goodtiles

outsheet id lon lat x_tmp y_tmp _merge using tmp.csv if _m !=2, replace

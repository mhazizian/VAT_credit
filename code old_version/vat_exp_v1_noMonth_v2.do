clear

local year 1401

use "./total_HH_exp_U_`year'.dta"

gen ur = 1
append using "./total_HH_exp_R_`year'.dta", force

replace ur = 0 if missing(ur)

// gen paid_vat = simple_tv_9 * 0.09 / 1.09
// tabstat paid_vat [w=weight], format(%10.0gc)

tabstat paid_vat [w=weight], by(ur) format(%10.0gc)

tabstat paid_vat_cat* [w=weight], format(%10.0gc) by(C09New)
tabstat vat_exp_cat* [w=weight], format(%10.0gc) by(C09New)
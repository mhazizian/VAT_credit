

********************************
// Reshape data
keep address category is_urban tv_* cat_*
duplicates drop

reshape wide cat_*, i(address) j(category)
order address is_urban tv_* cat_*

	
local cats 13 1 3 4 5 6 7 8 9 10 11 12
foreach cat of local cats {
    replace cat_exm_`cat' 	= 0 if missing(cat_exm_`cat')
	replace cat_9_`cat' 	= 0 if missing(cat_9_`cat')
	replace cat_other_`cat' = 0 if missing(cat_other_`cat')
}


tempfile expenditure_tempfile
save `expenditure_tempfile', replace


********************************
// import data summary

clear
tempfile sum_tempfile
save `sum_tempfile', replace empty

foreach RU in "U" "R" {
	import excel "$dir_sum/Sum`RU'${year}.xls", firstrow clear //

	// rename ADDRESS address
	foreach v in ADDRESS Address { 
	   capture confirm var `v' 
	   if _rc == 0  { 
				rename `v' address 
	   }
	}
	destring address, replace
	destring B24, replace
	
	append using `sum_tempfile'
	save `sum_tempfile', replace
}

merge 1:1 address using `expenditure_tempfile'

drop if _merge == 1
drop _merge

order address is_urban tv_* cat_* *

replace C09New = C09New + 1
gen ln_NHazine = ln(NHazine)
gen ln_GHazine = ln(GHazine)
// replace weight = int(weight)

*******************************
// Ratio calculation 

gen calculated_exp 		= (tv_exm + tv_9 + tv_other)
gen cal_exp_to_SC_exp 	= calculated_exp / NHazine
gen cal_exp_to_SC_exp_G = calculated_exp / GHazine

gen ratio_tv_9   = tv_9 / calculated_exp
gen ratio_tv_exm = tv_exm / calculated_exp

gen ratio_tv_exm_SC 	= tv_exm / NHazineh
gen ratio_tv_9_SC 		= tv_9 / NHazineh
gen ratio_tv_other_SC 	= tv_other / NHazineh

replace ratio_tv_exm_SC	= . if ratio_tv_exm_SC < 0 | ratio_tv_exm_SC > 1
replace ratio_tv_9_SC	= . if ratio_tv_9_SC < 0 | ratio_tv_9_SC > 1
replace ratio_tv_other_SC	= . if ratio_tv_other_SC < 0 | ratio_tv_other_SC > 1


gen tax_exp = tv_exm * 0.09
gen tax_exp_MT = tax_exp / 10 / 1000 / 1000

********************************
// Ratios in category

local cats 13 1 3 4 5 6 7 8 9 10 11 12
foreach cat of local cats {
    gen ratio_cat_9_SC_`cat' = cat_9_`cat' / NHazineh
    gen ratio_cat_exm_SC_`cat' = cat_exm_`cat' / NHazineh
    
    gen ratio_cat_9_`cat' = cat_9_`cat' / calculated_exp
    gen ratio_cat_exm_`cat' = cat_exm_`cat' / calculated_exp
	
	gen share_cat_9_`cat' = cat_9_`cat' / tv_9
	gen share_cat_exm_`cat' = cat_exm_`cat' / tv_exm
	
	
	replace ratio_cat_9_`cat' 		= . if ratio_cat_9_`cat' < 0 		| ratio_cat_9_`cat' > 1
	replace ratio_cat_9_SC_`cat' 	= . if ratio_cat_9_SC_`cat' < 0 	| ratio_cat_9_SC_`cat' > 1
	replace ratio_cat_exm_`cat' 	= . if ratio_cat_exm_`cat' < 0 		| ratio_cat_exm_`cat' > 1
	replace ratio_cat_exm_SC_`cat' 	= . if ratio_cat_exm_SC_`cat' < 0 	| ratio_cat_exm_SC_`cat' > 1
}

clear

// local year 94
local year 1401

// local RU U

// local dir "~/Documents/Data/HEIS/`year'/csv"
local dir "~/Documents/Data/HEIS/101/csv"

// local dir_sum "~/Documents/Data/HEIS/DataSummary/13`year'"
local dir_sum "~/Documents/Data/HEIS/DataSummary/`year'"

/* clear
local path "`dir'/R/R`year'P3S01.csv"
import delimited "`path'", delimiter(",") clear //
des

list */


// #######################################################################
// #######################################################################
// ########################### Monthly ANALYSIS ##########################
// #######################################################################
// #######################################################################

tempfile monthly_tempfile
save `monthly_tempfile', replace empty

local RU_options R U
foreach RU of local RU_options {
	local tables 01 02
	foreach table of local tables {
		local path "`dir'/`RU'/`RU'`year'P3S`table'.csv"
		import delimited "`path'", delimiter(",") clear //

		destring dycol06 dycol02, replace
		// keep only if HH has paid for it.
		// drop if dycol02 != 1

		rename dycol06 value
		rename dycol01 good_code
		
		keep address good_code value

		append using `monthly_tempfile'
		save `monthly_tempfile', replace
	}


	local tables 03 05 06 07 08 09 11 12
	foreach table of local tables {
		local path "`dir'/`RU'/`RU'`year'P3S`table'.csv"
		import delimited "`path'", delimiter(",") clear //
		destring dycol03 dycol02, replace

		// keep only if HH has paid for it.
		//drop if dycol02 != 1

		rename dycol03 value
		rename dycol01 good_code
		keep address good_code value

		append using `monthly_tempfile'
		save `monthly_tempfile', replace
	}


	disp "## table 04 ###"
	local tables 04
	foreach table of local tables {
		local path "`dir'/`RU'/`RU'`year'P3S`table'.csv"
		import delimited "`path'", delimiter(",") clear //
		
		// keep only if HH has paid for it.
		destring dycol03, replace
		destring dycol02 dycol04, replace
		
		//drop if dycol03 != 1

		rename dycol04 value
		rename dycol01 good_code
		
		// Rahn value adjustment (3 to 100)
		replace value = value + (dycol02 / 100 * 3) if !missing(dycol02)

		keep address good_code value

		append using `monthly_tempfile'
		save `monthly_tempfile', replace
	}
} 
replace value = int(value)
save `monthly_tempfile', replace

/* save "`RU'_`year'_monthly_HH_exp.dta", replace */

des

clear

import excel "../HEIS_Month_VAT_rate.xlsx", firstrow

/* gen good_code = string(cat) + string(sub_cat) */
destring good_code, replace

keep vat_rate good_code
merge 1:m good_code using `monthly_tempfile'
/* merge 1:m good_code using "`RU'_`year'_monthly_HH_exp.dta" */

/* list vat_rate good_code if _merge == 2 */

drop if _merge == 1
drop _merge

tab vat_rate [w=value]

/* preserve 
egen total_good_exp = sum(value), by(good_code)
keep total_good_exp good_code
duplicates drop
egen weight_sum = sum(total_good_exp)
gen weight = total_good_exp / weight_sum * 100

keep good_code weight
export excel using "monthly_good_weight_`year'_`RU'.xlsx", replace firstrow(variables)
/* gsort -avg_good_exp */
/* tab good_code [w=int(avg_good_exp)], sort */
restore */

/* drop good_cat */

gen good_cat = ""
replace good_cat = "0" + substr(string(good_code), 1, 3) if length(string(good_code)) == 5
replace good_cat = substr(string(good_code), 1, 4) if length(string(good_code)) == 6

/* drop category */

gen category = 0
replace category = 1  if substr(good_cat, 1, 2) == "01" | substr(good_cat, 1, 3) == "021"
/* replace category = 2  if substr(good_cat, 1, 2) == "02" */

replace category = 3  if substr(good_cat, 1, 2) == "03"
replace category = 4  if substr(good_cat, 1, 2) == "04"
replace category = 5  if substr(good_cat, 1, 2) == "05"
replace category = 6  if substr(good_cat, 1, 2) == "06"
replace category = 7  if substr(good_cat, 1, 2) == "07"
replace category = 8  if substr(good_cat, 1, 2) == "08"
replace category = 9  if substr(good_cat, 1, 2) == "09"
replace category = 11 if substr(good_cat, 1, 2) == "11"
// 12 is others => zode zero


/* label define good_cat_label_fa ///
    0 "سایر" ///
    1 "خوراکی و نوشیدنی" ///
    3 "پوشاک" ///
    4 "مسکن، آب و فاضلاب و روشنایی" ///
    5 "مبلمان و لوازم خانگی و نگهداری" ///
    6 "بهداشتی و درمانی" ///
    7 "حمل و نقل" ///
    8 "ارتباطات، تلفن و موبایل" ///
    9 "سرگرمی و تجهیزات سمعی-بصری و یارانه" ///
    10 "آموزش" ///
    11 "غذای آماده، هتل و رستوران" 
    12 "بیمه" */

label define good_cat_label_en ///
    0 "others" ///
    1 "foods & drinks" ///
    3 "clothes" ///
    4 "home, water, light" ///
    5 "sofa, hose exp" ///
    6 "Healthcare" ///
    7 "tranportation" ///
    8 "connections, phone & mobile" ///
    9 "entertainment, multimedia, computer" ///
    10 "learning" ///
    11 "hotel, restrunt" ///
    12 "Insurance" 

label values category good_cat_label_en

tab category [w = value]

drop if vat_rate == -1
replace value = 12 * value
gen is_monthly = 1

save `monthly_tempfile', replace

// #######################################################################
// #######################################################################
// ############################### YEARLY ANALYSIS #######################
// #######################################################################
// #######################################################################


clear
tempfile yearly_tempfile
save `yearly_tempfile', replace empty

local RU_options R U
foreach RU of local RU_options {
	local tables 13
	foreach table of local tables {
		local path "`dir'/`RU'/`RU'`year'P3S`table'.csv"
		import delimited "`path'", delimiter(",") clear //
		
		rename dycol05 value
		rename dycol01 good_code

		// keep only if HH has paid for it.
		destring dycol04 value good_code dycol06, replace force
		//drop if dycol04 != 1

		/* drop if (dycol06 > 0 && !missing(dycol06)) */
		
		keep address good_code value

		append using `yearly_tempfile'
		save `yearly_tempfile', replace
	}
}
replace value = int(value)

save `yearly_tempfile', replace

clear

import excel "../HEIS_Yearly_VAT_rate.xlsx", firstrow

/* gen good_code = string(cat) + string(sub_cat) */
destring good_code, replace

keep vat_rate good_code
merge 1:m good_code using `yearly_tempfile'
/* merge 1:m good_code using "`RU'_`year'_monthly_HH_exp.dta" */

/* list vat_rate good_code if _merge == 1 */

drop if _merge == 1
drop _merge

tab vat_rate [w=value]


/* drop good_cat */

gen good_cat = ""
replace good_cat = "0" + substr(string(good_code), 1, 3) if length(string(good_code)) == 5
replace good_cat = substr(string(good_code), 1, 4) if length(string(good_code)) == 6

/* drop category */

gen category = 0
/* replace category = 1  if substr(good_cat, 1, 3) == "01" */
replace category = 3  if substr(good_cat, 1, 2) == "03"
replace category = 4  if substr(good_cat, 1, 2) == "04"
replace category = 5  if substr(good_cat, 1, 2) == "05"
replace category = 6  if substr(good_cat, 1, 2) == "06"
replace category = 7  if substr(good_cat, 1, 2) == "07"
replace category = 8  if substr(good_cat, 1, 2) == "08"
replace category = 9  if substr(good_cat, 1, 2) == "09"
replace category = 10 if substr(good_cat, 1, 2) == "10"
// to 11
// 12 is others => code zero
replace category = 12 if substr(good_cat, 1, 3) == "125"
// 127 => others


/* label define good_cat_label ///
    0 "سایر" ///
    1 "خوراکی" ///
    3 "پوشاک" ///
    4 "مسکن، آب و فاضلاب و روشنایی" ///
    5 "مبلمان و لوازم خانگی و نگهداری" ///
    6 "بهداشتی و درمانی" ///
    7 "حمل و نقل" ///
    11 "غذای آماده، هتل و رستوران"
    10 "آموزش" ///
    11 "بیمه" */

label define good_cat_label_en ///
    0 "others" ///
    1 "foods & drinks" ///
    3 "clothes" ///
    4 "home, water, light" ///
    5 "sofa, hose exp" ///
    6 "Healthcare" ///
    7 "tranportation" ///
    8 "connections, phone & mobile" ///
    9 "entertainment, multimedia, computer" ///
    10 "learning" ///
    11 "hotel, restrunt" ///
    12 "Insurance" 

label values category good_cat_label_en

tab category [w = value]


save `yearly_tempfile', replace


// #######################################################################
// #######################################################################
// ############################### MERGE #################################
// #######################################################################
// #######################################################################
clear

use `yearly_tempfile'
append using `monthly_tempfile'
replace is_monthly = 0 if missing(is_monthly)

tempfile expenditure_tempfile
save `expenditure_tempfile', replace

clear
tempfile sum_tempfile
import excel "`dir_sum'/SumR`year'.xlsx", firstrow clear
destring B24, replace
save `sum_tempfile', replace

import excel "`dir_sum'/SumU`year'.xlsx", firstrow clear
destring B24, replace
append using `sum_tempfile'

// rename ADDRESS
foreach v in ADDRESS Address { 
       capture confirm var `v' 

       if _rc == 0  { 
                rename `v' address 
       }
}

destring address, replace

merge 1:m address using `expenditure_tempfile'

drop if _merge == 1
drop _merge



// egen sum_weights = sum(weight), by(good_code)
// weights are for 1401. 
gen sum_weights = 27145813.59482246

gen sum_weights_decile = .
replace sum_weights_decile = 2676100.490991835 if C09New == 0
replace sum_weights_decile = 2717105.578151941 if C09New == 1
replace sum_weights_decile = 2718616.583222227 if C09New == 2
replace sum_weights_decile = 2719019.525054331 if C09New == 3
replace sum_weights_decile = 2720334.753074153 if C09New == 4
replace sum_weights_decile = 2718827.426345994 if C09New == 5
replace sum_weights_decile = 2719687.396211344 if C09New == 6
replace sum_weights_decile = 2719470.443566352 if C09New == 7
replace sum_weights_decile = 2718525.181035145 if C09New == 8
replace sum_weights_decile = 2718126.217169136 if C09New == 9


egen total_sum_weighted_value = sum(value * weight)
egen sum_weighted_value = sum(value * weight), by(good_code)
egen sum_weighted_value_decile = sum(value * weight), by(good_code C09New)

egen sum_weighted_NHazineh_decile = sum(NHazineh * weight), by(C09New)


gen good_weight = sum_weighted_value / total_sum_weighted_value
gen average_value = sum_weighted_value_decile / sum_weights_decile
gen average_cons = sum_weighted_value / sum_weights
// gen percent_of_NHazineh = ///
// 	(sum_weighted_value_decile / sum_weights_decile) / ///
// 	(sum_weighted_NHazineh_decile / sum_weights_decile)


// egen average_value = wtmean(value), by(good_code C09New) weight( weight )


keep good_code C09New is_monthly vat_rate category good_weight average_cons ///
	average_value
duplicates drop


reshape wide average_value, i(good_code) j(C09New)
gsort -good_weight


export excel using "good_weight_decile_`year'_allExp.xlsx", replace firstrow(variables)






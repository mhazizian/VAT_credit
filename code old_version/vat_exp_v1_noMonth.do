clear

// local year 94
local year 1401

local RU U

// local dir "~/Documents/Data/HEIS/`year'/csv"
local dir "~/Documents/Data/HEIS/101/csv"

// local dir_sum "~/Documents/Data/HEIS/DataSummary/13`year'"
local dir_sum "~/Documents/Data/HEIS/DataSummary/`year'"

/* clear
local path "`dir'/R/R`year'P3S01.csv"
import delimited "`path'", delimiter(",") clear //
des

list */

tempfile monthly_tempfile
save `monthly_tempfile', replace empty

local tables 01 02
foreach table of local tables {
    local path "`dir'/`RU'/`RU'`year'P3S`table'.csv"
    import delimited "`path'", delimiter(",") clear //

    destring dycol06 dycol02, replace
    // keep only if HH has paid for it.
    drop if dycol02 != 1

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
    drop if dycol02 != 1

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
    
    drop if dycol03 != 1

    rename dycol04 value
    rename dycol01 good_code
    
    // Rahn value adjustment (3 to 100)
    replace value = value + (dycol02 / 100 * 3) if !missing(dycol02)

    keep address good_code value

    append using `monthly_tempfile'
    save `monthly_tempfile', replace
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

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// drop if vat_rate == 100

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

/* drop tv* */

egen monthly_tv_exm = sum(value * (vat_rate == 0)), by(address)
egen monthly_tv_9 = sum(value * (vat_rate == 9)), by(address)
egen monthly_tv_other = sum(value * ((vat_rate != 9) & (vat_rate != 0))), by(address)

egen monthly_cat_exm_ = sum(value * (vat_rate == 0)), by(address category)
egen monthly_cat_9_ = sum(value * (vat_rate == 9)), by(address category)
egen monthly_cat_other_ = sum(value * ((vat_rate != 9) & (vat_rate != 0))), by(address category)

keep address category monthly_tv* monthly_cat*
duplicates drop

reshape wide monthly_cat*, i(address) j(category)

des monthly_cat_9_*

save `monthly_tempfile', replace
/* save "monthly_exp_`RU'_`year'.dta", replace */
/* save "`RU'_`year'_monthly_HH_exp_by_vat.dta", replace */

clear
tempfile yearly_tempfile
save `yearly_tempfile', replace empty

local tables 13
foreach table of local tables {
    local path "`dir'/`RU'/`RU'`year'P3S`table'.csv"
    import delimited "`path'", delimiter(",") clear //
    
    rename dycol05 value
    rename dycol01 good_code

    // keep only if HH has paid for it.
    destring dycol04 value good_code dycol06, replace force
    drop if dycol04 != 1

    /* drop if (dycol06 > 0 && !missing(dycol06)) */
    
    keep address good_code value

    append using `yearly_tempfile'
    save `yearly_tempfile', replace
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

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// drop if vat_rate == 100

preserve 
egen total_good_exp = sum(value), by(good_code)
keep total_good_exp good_code
duplicates drop
egen weight_sum = sum(total_good_exp)
gen weight = total_good_exp / weight_sum * 100

keep good_code weight
export excel using "yearly_good_weight_`year'_`RU'.xlsx", replace
/* gsort -avg_good_exp */
/* tab good_code [w=int(avg_good_exp)], sort */
restore

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

/* tv = total_value */
/* drop tv* */

egen yearly_tv_exm = sum(value * (vat_rate == 0)), by(address)
egen yearly_tv_9 = sum(value * (vat_rate == 9)), by(address)
egen yearly_tv_other = sum(value * ((vat_rate != 9) & (vat_rate != 0) & (vat_rate != -1))), by(address)

egen yearly_cat_exm_ = sum(value * (vat_rate == 0)), by(address category)
egen yearly_cat_9_ = sum(value * (vat_rate == 9)), by(address category)
egen yearly_cat_other_ = sum(value * ((vat_rate != 9) & (vat_rate != 0) & (vat_rate != -1))), by(address category)

keep address category yearly_tv* yearly_cat*
duplicates drop

reshape wide yearly_cat*, i(address) j(category)

des yearly_cat_9_*

keep address yearly_tv* yearly_cat*
duplicates drop

save `yearly_tempfile', replace
/* save "yearly_exp_`RU'_`year'.dta", replace */
/* save "`RU'_`year'_monthly_HH_exp_by_vat.dta", replace */

clear
use `monthly_tempfile'
merge 1:1 address using `yearly_tempfile'

drop _merge
/* des */

foreach var of varlist _all {
    replace `var' = 0 if missing(`var')
}

/* local vars monthly_tv_exm monthly_tv_9 monthly_tv_other
foreach var of local vars {
    replace `var' = 0 if missing(`var')
}

local vars yearly_tv_exm yearly_tv_9 yearly_tv_other
foreach var of local vars {
    replace `var' = 0 if missing(`var')
} */



/* drop simple_tv* */
gen simple_tv_exm = 12 * monthly_tv_exm + yearly_tv_exm
gen simple_tv_9 = 12 * monthly_tv_9 + yearly_tv_9
gen simple_tv_other = 12 * monthly_tv_other + yearly_tv_other

gen monthly_exm_ratio = monthly_tv_exm / (monthly_tv_exm + monthly_tv_9 + monthly_tv_other)
gen simple_exm_ratio = simple_tv_exm / (simple_tv_exm + simple_tv_9 + simple_tv_other)

codebook simple_exm_ratio

// hist simple_exm_ratio, percent ///
//     title("Exempt expenditure ratio histogram") ///
//     xtitle("exempt ratio")
	

tempfile expenditure_tempfile
save `expenditure_tempfile', replace
/* save "total_exp_`RU'_`year'.dta", replace */
/* save "`RU'_`year'_monthly_HH_exp_by_vat.dta", replace */

clear

import excel "`dir_sum'/Sum`RU'`year'.xlsx", firstrow clear //

// rename ADDRESS address
foreach v in ADDRESS Address { 
       capture confirm var `v' 

       if _rc == 0  { 
                rename `v' address 
       }
}
// rename Address address

destring address, replace

merge 1:1 address using `expenditure_tempfile'
/* merge 1:1 address using "`RU'_`year'_monthly_HH_exp_by_vat.dta" */

drop if _merge == 1
drop _merge

kdensity simple_exm_ratio [aw=weight], ///
    title("Exempt expenditure ratio histogram") ///
    xtitle("exempt ratio") name(simple_exm_ratio, replace)

gen calculated_exp = (simple_tv_exm + simple_tv_9 + simple_tv_other)
gen cal_exp_to_SC_exp = calculated_exp / NHazine
gen cal_exp_to_SC_exp_G = calculated_exp / GHazine

gen simple_exm_ratio_SC = simple_tv_exm / NHazineh
gen simple_vat_ratio_SC = simple_tv_9 / NHazineh
gen simple_other_ratio_SC = simple_tv_other / NHazineh
tabstat simple_vat_ratio_SC [w=weight], by(C09New)
tabstat simple_other_ratio_SC [w=weight], by(C09New)


graph bar (mean) NHazine calculated_exp [w=weight], over(C09New) ///
    title("NHazine") ///
    ytitle("percentile mean - %")

graph bar (mean) cal_exp_to_SC_exp_G [w=weight], over(C09New) ///
    title("calculated_Exp to SC_Exp") ///
    ytitle("percentile mean - %")

graph bar (mean) simple_exm_ratio simple_exm_ratio_SC [w=weight], over(C09New) ///
    title("Exempt expenditure / Total expenditure") ///
    ytitle("percentile mean - %") name(exm_ration_percentile, replace)
	
graph bar (mean) simple_vat_ratio simple_vat_ratio_SC [w=weight], over(C09New) ///
    title("VAT expenditure / Total expenditure") ///
    ytitle("percentile mean - %") name(exm_ration_percentile, replace)
	
graph bar (mean) simple_other_ratio simple_other_ratio_SC [w=weight], over(C09New) ///
    title("Other expenditure / Total expenditure") ///
    ytitle("percentile mean - %") name(exm_ration_percentile, replace)	

tabstat simple_exm_ratio, by(C09New)
/* tabstat simple_exm_ratio_SC, by(C09New) */

tabstat simple_tv_exm [w=weight], s(sum, mean) 
tabstat simple_tv_9 [w=weight], s(sum, mean) 
tabstat simple_tv_other [w=weight], s(sum, mean) 

/* drop simple_cat_*  */

local cats 0 3 4 5 6 7 8 9
foreach cat of local cats {
    gen simple_cat_exm_`cat'   = 12 * monthly_cat_exm_`cat'     + yearly_cat_exm_`cat'
    gen simple_cat_9_`cat'     = 12 * monthly_cat_9_`cat'       + yearly_cat_9_`cat'
    gen simple_cat_other_`cat' = 12 * monthly_cat_other_`cat'   + yearly_cat_other_`cat'
    gen simple_exm_ratio_cat_`cat' = simple_cat_exm_`cat' / (simple_cat_9_`cat' + simple_cat_exm_`cat' + simple_cat_other_`cat')
}

local cats 1 11
foreach cat of local cats {
    gen simple_cat_exm_`cat'   = 12 * monthly_cat_exm_`cat'  
    gen simple_cat_9_`cat'     = 12 * monthly_cat_9_`cat'    
    gen simple_cat_other_`cat' = 12 * monthly_cat_other_`cat'
    gen simple_exm_ratio_cat_`cat' = simple_cat_exm_`cat' / (simple_cat_9_`cat' + simple_cat_exm_`cat' + simple_cat_other_`cat')
}

local cats 10 12
foreach cat of local cats {
    gen simple_cat_exm_`cat'   = yearly_cat_exm_`cat'
    gen simple_cat_9_`cat'     = yearly_cat_9_`cat'
    gen simple_cat_other_`cat' = yearly_cat_other_`cat'
    gen simple_exm_ratio_cat_`cat' = simple_cat_exm_`cat' / (simple_cat_9_`cat' + simple_cat_exm_`cat' + simple_cat_other_`cat')
}


local cats 0 1 3 4 5 6 7 8 9 10 11 12
foreach cat of local cats {
    gen simple_ratio_SC_9_cat_`cat' = simple_cat_9_`cat' / NHazineh
    gen simple_ratio_SC_exm_cat_`cat' = simple_cat_9_`cat' / NHazineh
    
    gen simple_ratio_9_cat_`cat' = simple_cat_9_`cat' / calculated_exp
    gen simple_ratio_exm_cat_`cat' = simple_cat_9_`cat' / calculated_exp
}

local cat 1
kdensity simple_exm_ratio_cat_`cat' [aw=weight], ///
    title("Exempt ratio for cat=`cat' histogram") ///
    xtitle("exempt ratio")

	
graph bar (mean) simple_ratio_SC_9_cat_1 simple_ratio_SC_9_cat_3 ///
simple_ratio_SC_9_cat_4 simple_ratio_SC_9_cat_5 ///
    simple_ratio_SC_9_cat_6 simple_ratio_SC_9_cat_7 simple_ratio_SC_9_cat_8 ///
	simple_ratio_SC_9_cat_9 simple_ratio_SC_9_cat_10 ///
	simple_ratio_SC_9_cat_11 simple_ratio_SC_9_cat_12 ///
	simple_ratio_SC_9_cat_0 ///
    [w=weight] , over(C09New) stack ///
    title("exp on taxable goods and services / total exp (SC)") ///
    ytitle("percentile mean - %") ///
    legend(order(  ///
        1 "foods & drinks" ///
        2 "clothes" ///
        3 "home, water, light" ///
        4 "sofa, hose exp" ///
        5 "Healthcare" ///
        6 "tranportation" ///
        7 "connections, phone & mobile" ///
        8 "entertainment, multimedia, computer" ///
        9 "learning" ///
        10 "hotel, restrunt" ///
        11 "Insurance" ///
        12 "others" ///
    )) name(paid_ratio_detail_sc, replace)

graph bar (mean) simple_ratio_9_cat_1 simple_ratio_9_cat_3 simple_ratio_9_cat_4 simple_ratio_9_cat_5 ///
    simple_ratio_9_cat_6 simple_ratio_9_cat_7 simple_ratio_9_cat_8 simple_ratio_9_cat_9 simple_ratio_9_cat_10 simple_ratio_9_cat_11 simple_ratio_9_cat_12 simple_ratio_9_cat_0 ///
    [w=weight], over(C09New) stack ///
    title("exp on taxable goods and services / total exp (no SC)") ///
    ytitle("percentile mean - %") ///
    legend(order(  ///
        1 "foods & drinks" ///
        2 "clothes" ///
        3 "home, water, light" ///
        4 "sofa, hose exp" ///
        5 "Healthcare" ///
        6 "tranportation" ///
        7 "connections, phone & mobile" ///
        8 "entertainment, multimedia, computer" ///
        9 "learning" ///
        10 "hotel, restrunt" ///
        11 "Insurance" ///
        12 "others" ///
    )) name(paid_ratio_detail_nosc, replace)

// graph bar (mean) simple_tv_exm [w=weight], over(C09New)  ///
//     title("expenditure on exempt goods and services") ///
//     ytitle("percentile mean - Rial")

graph bar (mean) simple_cat_exm_1 simple_cat_exm_3 simple_cat_exm_4 ///
	simple_cat_exm_5 ///
	simple_cat_exm_6 simple_cat_exm_7 simple_cat_exm_8 	///	
	simple_cat_exm_9 simple_cat_exm_10 simple_cat_exm_11 ///
	simple_cat_exm_12 simple_cat_exm_0 ///
    [w=weight], over(C09New) stack ///
    title("expenditure on exempt goods and services") ///
    ytitle("percentile mean - Rial") ///
    legend(order(  ///
        1 "foods & drinks" ///
        2 "clothes" ///
        3 "home, water, light" ///
        4 "sofa, hose exp" ///
        5 "Healthcare" ///
        6 "tranportation" ///
        7 "connections, phone & mobile" ///
        8 "entertainment, multimedia, computer" ///
        9 "learning" ///
        10 "hotel, restrunt" ///
        11 "Insurance" ///
        12 "others" ///
    ))

graph bar (mean) simple_cat_exm_1 simple_cat_exm_3 simple_cat_exm_4 ///
	simple_cat_exm_5 ///
    simple_cat_exm_6 simple_cat_exm_7 simple_cat_exm_8 simple_cat_exm_9 ///
	simple_cat_exm_10 simple_cat_exm_11 simple_cat_exm_12 simple_cat_exm_0 ///
    [w=weight], over(C09New) stack percentages ///
    title("expenditure on exempt goods and services") ///
    ytitle("percentile mean - percent") ///
    legend(order(  ///
        1 "foods & drinks" ///
        2 "clothes" ///
        3 "home, water, light" ///
        4 "sofa, hose exp" ///
        5 "Healthcare" ///
        6 "tranportation" ///
        7 "connections, phone & mobile" ///
        8 "entertainment, multimedia, computer" ///
        9 "learning" ///
        10 "hotel, restrunt" ///
        11 "Insurance" ///
        12 "others" ///
    )) name(exm_exp_detail, replace)

graph bar (mean) simple_cat_9_1 simple_cat_9_3 simple_cat_9_4 ///
	simple_cat_9_5 ///
    simple_cat_9_6 simple_cat_9_7 simple_cat_9_8 simple_cat_9_9 ///
	simple_cat_9_10 simple_cat_9_11 simple_cat_9_12 simple_cat_9_0 ///
    [w=weight], over(C09New) stack  ///
    title("VAT * 100/9") ///
    ytitle("percentile mean - Rial") ///
    legend(order(  ///
        1 "foods & drinks" ///
        2 "clothes" ///
        3 "home, water, light" ///
        4 "sofa, hose exp" ///
        5 "Healthcare" ///
        6 "tranportation" ///
        7 "connections, phone & mobile" ///
        8 "entertainment, multimedia, computer" ///
        9 "learning" ///
        10 "hotel, restrunt" ///
        11 "Insurance" ///
        12 "others" ///
    ))

graph bar (mean) simple_cat_9_1 simple_cat_9_3 simple_cat_9_4 ///
	simple_cat_9_5 ///
    simple_cat_9_6 simple_cat_9_7 simple_cat_9_8 simple_cat_9_9 ///
	simple_cat_9_10 simple_cat_9_11 simple_cat_9_12 simple_cat_9_0 ///
    [w=weight], over(C09New) stack per ///
    title("VAT * 100/9") ///
    ytitle("percentile mean - Rial") ///
    legend(order(  ///
        1 "foods & drinks" ///
        2 "clothes" ///
        3 "home, water, light" ///
        4 "sofa, hose exp" ///
        5 "Healthcare" ///
        6 "tranportation" ///
        7 "connections, phone & mobile" ///
        8 "entertainment, multimedia, computer" ///
        9 "learning" ///
        10 "hotel, restrunt" ///
        11 "Insurance" ///
        12 "others" ///
    )) name(vat_detail, replace)

// graph bar (mean) monthly_cat_exm_1 monthly_cat_exm_3 monthly_cat_exm_4 ///
// 	monthly_cat_exm_5 ///
//     monthly_cat_exm_6 monthly_cat_exm_7 monthly_cat_exm_8 monthly_cat_exm_9 ///
// 	monthly_cat_exm_11 monthly_cat_exm_0 ///
//     [w=weight], over(C09New) stack  ///
//     title("Monthly: Exp on exempt goods and services") ///
//     ytitle("percentile mean - Rial")


// graph bar (mean) monthly_cat_exm_1 monthly_cat_exm_3 monthly_cat_exm_4 ///
// 	monthly_cat_exm_5 ///
//     monthly_cat_exm_6 monthly_cat_exm_7 monthly_cat_exm_8 monthly_cat_exm_9 ///
// 	monthly_cat_exm_11 monthly_cat_exm_0 ///
//     [w=weight], over(C09New) stack per ///
//     title("Monthly: Exp on exempt goods and services") ///
//     ytitle("percentile mean - Rial")


// graph bar (mean)  yearly_cat_exm_3 yearly_cat_exm_4 yearly_cat_exm_5 ///
//     yearly_cat_exm_6 yearly_cat_exm_7 yearly_cat_exm_8 yearly_cat_exm_9 yearly_cat_exm_10 yearly_cat_exm_0 ///
//     [w=weight], over(C09New) stack  ///
//     title("Yearly: Exp on exempt goods and services") ///
//     ytitle("percentile mean - Rial")


// graph bar (mean)  yearly_cat_exm_3 yearly_cat_exm_4 yearly_cat_exm_5 ///
//     yearly_cat_exm_6 yearly_cat_exm_7 yearly_cat_exm_8 yearly_cat_exm_9 yearly_cat_exm_10 yearly_cat_exm_0 ///
//     [w=weight], over(C09New) stack per ///
//     title("Yearly: Exp on exempt goods and services") ///
//     ytitle("percentile mean - Rial")


/* drop simple_exm_ratio_cat_* my_exp exp_to_SC_exp simple_exm_ratio_SC */

gen simple_exm_ratio_cat_1_ = simple_cat_exm_1 / (simple_tv_exm + simple_tv_9 + simple_tv_other)
gen simple_exm_ratio_cat_6_12_ = (simple_cat_exm_6 + simple_cat_exm_12 ) / (simple_tv_exm + simple_tv_9 + simple_tv_other)
gen simple_exm_ratio_cat_inc_ = (simple_cat_exm_6 + simple_cat_exm_12 + simple_cat_exm_0) / (simple_tv_exm + simple_tv_9 + simple_tv_other)

gen simple_exm_ratio_cat_1_SC = simple_cat_exm_1 / NHazine
gen simple_exm_ratio_cat_6_12_SC = (simple_cat_exm_6 + simple_cat_exm_12) / NHazine
gen simple_exm_ratio_cat_inc_SC = (simple_cat_exm_6 + simple_cat_exm_12 + simple_cat_exm_0) / NHazine

/* graph bar (mean) simple_exm_ratio, over(C09New) ///
    title("Exempt expenditure / Total taxable expenditure") ///
    ytitle("percentile mean - %") */

	
graph bar (mean) simple_exm_ratio simple_exm_ratio_SC [w=weight] ///
	, over(C09New) ///
    title("Exempt expenditure / Total expenditure") ///
    ytitle("percentile mean - %")

graph bar (mean) simple_exm_ratio_cat_1_ [w=weight], over(C09New) ///
    title("Exempt expenditure / Total  taxable expenditure") ///
    subtitle("on foods") ///
    ytitle("percentile mean - %") name(exm_ratio_dec, replace)
    
/* graph bar (mean) simple_exm_ratio_cat_1_ simple_exm_ratio_cat_1_SC, over(C09New) ///
    title("Exempt expenditure(Cat1) / Total expenditure") ///
    ytitle("percentile mean - %") */

graph bar (mean) simple_exm_ratio_cat_inc_ [w=weight], over(C09New) ///
    title("Exempt expenditure / Total  taxable expenditure") ///
    subtitle("on healthcare, insurance and other goods") ///
    ytitle("percentile mean - %") name(exm_ratio_inc, replace)


/* graph bar (mean) simple_exm_ratio_cat_inc_ simple_exm_ratio_cat_inc_SC, over(C09New) ///
    title("Exempt expenditure(Cat 6 , 13, 14, 0) / Total expenditure") ///
    ytitle("percentile mean - %") */

// graph bar (mean) simple_exm_ratio_cat_1 simple_exm_ratio_cat_7 ///
// simple_exm_ratio_cat_9  simple_exm_ratio_cat_12 simple_exm_ratio_cat_0 ///
//     [w=weight], over(C09New) ///
//     title("Exempt expenditure / Total expenditure") ///
//     ytitle("percentile mean - %")


gen paid_vat = simple_tv_9 * 0.09 / 1.09

tabstat paid_vat [w=weight], format(%20.0gc)
sum paid_vat [w=weight]
/* codebook paid_vat */

disp "HH average paid vat is " r(mean) " Rial"
disp "total paid VAT is " r(mean) * 26384000 / 10 / 10E9 " Billion Toman"

gen paid_vat_cat_0 =  simple_cat_9_0 * 0.09 / 1.09
gen paid_vat_cat_1 =  simple_cat_9_1 * 0.09 / 1.09
gen paid_vat_cat_3 =  simple_cat_9_3 * 0.09 / 1.09
gen paid_vat_cat_4 =  simple_cat_9_4 * 0.09 / 1.09
gen paid_vat_cat_5 =  simple_cat_9_5 * 0.09 / 1.09
gen paid_vat_cat_6 =  simple_cat_9_6 * 0.09 / 1.09
gen paid_vat_cat_7 =  simple_cat_9_7 * 0.09 / 1.09
gen paid_vat_cat_8 =  simple_cat_9_8 * 0.09 / 1.09
gen paid_vat_cat_9 =  simple_cat_9_9 * 0.09 / 1.09
gen paid_vat_cat_10 =  simple_cat_9_10 * 0.09 / 1.09
gen paid_vat_cat_11 =  simple_cat_9_11 * 0.09 / 1.09
gen paid_vat_cat_12 =  simple_cat_9_12 * 0.09 / 1.09


tabstat paid_vat_cat* [w=weight], format(%10.0gc)
// tabstat paid_vat_cat* [w=weight], format(%10.0gc) by(C09New)

gen vat_exp_cat_0 =  simple_cat_exm_0 * 0.09 / 1.09
gen vat_exp_cat_1 =  simple_cat_exm_1 * 0.09 / 1.09
gen vat_exp_cat_3 =  simple_cat_exm_3 * 0.09 / 1.09
gen vat_exp_cat_4 =  simple_cat_exm_4 * 0.09 / 1.09
gen vat_exp_cat_5 =  simple_cat_exm_5 * 0.09 / 1.09
gen vat_exp_cat_6 =  simple_cat_exm_6 * 0.09 / 1.09
gen vat_exp_cat_7 =  simple_cat_exm_7 * 0.09 / 1.09
gen vat_exp_cat_8 =  simple_cat_exm_8 * 0.09 / 1.09
gen vat_exp_cat_9 =  simple_cat_exm_9 * 0.09 / 1.09
gen vat_exp_cat_10 =  simple_cat_exm_10 * 0.09 / 1.09
gen vat_exp_cat_11 =  simple_cat_exm_11 * 0.09 / 1.09
gen vat_exp_cat_12 =  simple_cat_exm_12 * 0.09 / 1.09

tabstat vat_exp_cat* [w=weight], format(%10.0gc)
// tabstat vat_exp_cat* [w=weight], format(%10.0gc) by(C09New)


/* save `expenditure_tempfile', replace */
save "total_HH_exp_`RU'_`year'.dta", replace
/* save "`RU'_`year'_monthly_HH_exp_by_vat_char.dta", replace */



gen paid_vat_ratio = simple_tv_9 / NHazineh
tabstat paid_vat_ratio [w=weight]


gen paid_vat_ratio_other = simple_tv_other / NHazineh
tabstat paid_vat_ratio_other [w=weight]


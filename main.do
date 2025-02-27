// ssc install gtools
// net install cleanplots, from("https://tdmize.github.io/data/cleanplots") replace
// set scheme s2color, perm
set scheme cleanplots, perm


clear all
frame reset
graph set window fontface "B Nazanin"
graph drop _all

global year 1402
global paid_exp_only = 1

global dir "~/Documents/Data/HEIS/$year/csv"
global dir_sum "~/Documents/Data/HEIS/DataSummary/$year"


// load data from HEIS
do "./load_HEIS_tables.do"

save "./dta files/vat_exp_data_${year}_paidOnly_${paid_exp_only}__long.dta", replace
use  "./dta files/vat_exp_data_${year}_paidOnly_${paid_exp_only}__long.dta", replace

do "./graph_drawer_longD.do"

**********

// load data from data_sum
do "./load_data_sum.do"

save "./dta files/vat_exp_data_${year}_paidOnly_${paid_exp_only}__wide.dta", replace
use  "./dta files/vat_exp_data_${year}_paidOnly_${paid_exp_only}__wide.dta", replace

do "./graph_drawer_wideD.do"
	
**********

// category 

collapse (mean) tv_* cat_* NHazine calculated_exp  [aweight = weight], by(C09New)
	
local cats 13 1 3 4 5 6 7 8 9 10 11 12
foreach cat of local cats {
    gen ratio_cat_exm_`cat' 	= cat_exm_`cat' / calculated_exp
	gen ratio_in_cat_exm_`cat'  = cat_exm_`cat' / (cat_9_`cat' + cat_exm_`cat' + cat_other_`cat')
  
}

foreach var in "ratio_cat_exm" "ratio_in_cat_exm" "cat_9" "cat_exm" {
		
	label variable `var'_1 "خوراکی و نوشیدنی"
    label variable `var'_3 "پوشاک"
    label variable `var'_4 "مسکن، آب و فاضلاب و روشنایی"
    label variable `var'_5 "مبلمان و لوازم خانگی و نگهداری"
    label variable `var'_6 "بهداشتی و درمانی"
    label variable `var'_7 "حمل و نقل"
    label variable `var'_8 "ارتباطات، تلفن و موبایل"
    label variable `var'_9 "سرگرمی و تجهیزات سمعی-بصری و یارانه"
    label variable `var'_10 "آموزش"
    label variable `var'_11 "غذای آماده، هتل و رستوران"
    label variable `var'_12 "بیمه"
	label variable `var'_13 "سایر"
}


//     label variable `var'_1  "foods & drinks"
//     label variable `var'_3  "clothes"
//     label variable `var'_4  "housing, water, light, fuel"
//     label variable `var'_5  "sofa, house exp"
//     label variable `var'_6  "Healthcare"
//     label variable `var'_7  "tranportation"
//     label variable `var'_8  "connections, phone & mobile"
//     label variable `var'_9  "entertainment, multimedia, computer"
//     label variable `var'_10 "learning"
//     label variable `var'_11 "hotel, restrunt"
//     label variable `var'_12 "Insurance"
// 	label variable `var'_13 "others"


// upward cat:		13 6* 7* 9 10* 11 
// downward cat:	1 4
// flat:			12*
// close to zero:	8 5* 3

local cats 13 1 3 4 5 6 7 8 9 10 11 12
foreach cat of local cats {
	line ratio_cat_exm_`cat' C09New, ///
		name(ratio_cat_exm_`cat', replace)
}
	
//  TODO: create upward and downward serires. only important categories


graph bar (asis) ///
	cat_exm_1 ///
	cat_exm_3 ///
	cat_exm_4 ///
	cat_exm_5 ///
    cat_exm_6 ///
	cat_exm_7 ///
	cat_exm_8 ///
	cat_exm_9 ///
	cat_exm_10 ///
	cat_exm_11 ///
	cat_exm_12 ///
	cat_exm_13 ///
    , over(C09New) stack percentage ///
	legend(pos(6) rows(4) symxsize(*1.5) size(*1.2)) ///
    title(مخارج معاف از مالیات بر ارزش افزوده در دهک‌های مختلف, size(large)) ///
    ytitle(سهم از کل مخارج معاف, size(medium)) ///
	b1title(دهک هزینه‌ای, size(medium) margin(medium)) ///
	yscale(titlegap(1.5)) ///
	name(exm_exp_share, replace)
	

graph bar (asis) ///
	cat_9_1 ///
	cat_9_3 ///
	cat_9_4 ///
	cat_9_5 ///
    cat_9_6 ///
	cat_9_7 ///
	cat_9_8 ///
	cat_9_9 ///
	cat_9_10 ///
	cat_9_11 ///
	cat_9_12 ///
	cat_9_13 ///
    , over(C09New) stack percentage ///
    title("taxable exp shares by category") ///
    ytitle("percent") ///
	name(vat_exp_share, replace)

	
	
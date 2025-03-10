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

do "./graph_drawer_category.do"

**********
// tax credit policy impact

do "./tax_credit.do"


	
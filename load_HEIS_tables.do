
tempfile monthly_tempfile
save `monthly_tempfile', replace empty

foreach UR in "U" "R" {
	local tables 01 02
	foreach table of local tables {
		local path "$dir/`UR'/`UR'${year}P3S`table'.csv"
		import delimited "`path'", delimiter(",") clear

		destring dycol06 dycol02, replace
		
		// keep only if HH has paid for it.
		if $paid_exp_only == 1 {
			drop if dycol02 != 1
		}
		
		rename dycol06 value
		rename dycol01 good_code
		
		keep address good_code value

		append using `monthly_tempfile'
		save `monthly_tempfile', replace
	}

	local tables 03 05 06 07 08 09 11 12
	foreach table of local tables {
		local path "$dir/`UR'/`UR'${year}P3S`table'.csv"
		import delimited "`path'", delimiter(",") clear //
		destring dycol03 dycol02, replace

		// keep only if HH has paid for it.
		if $paid_exp_only == 1 {
			drop if dycol02 != 1
		}

		rename dycol03 value
		rename dycol01 good_code
		keep address good_code value

		append using `monthly_tempfile'
		save `monthly_tempfile', replace
	}

	local tables 04
	foreach table of local tables {
		local path "$dir/`UR'/`UR'${year}P3S`table'.csv"
		import delimited "`path'", delimiter(",") clear //
		
		// keep only if HH has paid for it.
		destring dycol03, replace
		destring dycol02 dycol04, replace
		
		// keep only if HH has paid for it.
		if $paid_exp_only == 1 {
			drop if dycol03 != 1
		}

		rename dycol04 value
		rename dycol01 good_code
		
		// Rahn value adjustment (3 to 100)
		replace value = value + (dycol02 / 100 * 3) if !missing(dycol02)

		keep address good_code value

		append using `monthly_tempfile'
		save `monthly_tempfile', replace
	}

	gen is_`UR' = 1
	save `monthly_tempfile', replace
}

gen is_urban = 0
replace is_urban = 1 if is_U == 1
drop is_U is_R

replace value = int(value)


tempfile monthly_tempfile
save `monthly_tempfile', replace

*****************************
// Add VAT tag for each good.

import excel "./HEIS_Month_VAT_rate.xlsx", firstrow clear

/* gen good_code = string(cat) + string(sub_cat) */
destring good_code, replace

keep vat_rate good_code
merge 1:m good_code using `monthly_tempfile'

drop if _merge == 1
drop _merge

gen is_monthly = 1
// tab vat_rate [w=value]

save `monthly_tempfile', replace


//############################ YEARLY Tables ###########################

clear
tempfile yearly_tempfile
save `yearly_tempfile', replace empty

foreach RU in "U" "R" {
	local tables 13
	foreach table of local tables {
		local path "$dir/`RU'/`RU'${year}P3S`table'.csv"
		import delimited "`path'", delimiter(",") clear //
		
		rename dycol05 value
		rename dycol01 good_code

		destring dycol04 value good_code dycol06, replace force
		
		// keep only if HH has paid for it.
		if $paid_exp_only == 1 {
			drop if dycol04 != 1
		}
		
		/* drop if (dycol06 > 0 && !missing(dycol06)) */
		
		keep address good_code value

		append using `yearly_tempfile'
		save `yearly_tempfile', replace
	}
	gen is_`RU' = 1
	save `yearly_tempfile', replace
}

gen is_urban = 0
replace is_urban = 1 if is_U == 1
drop is_U is_R

replace value = int(value)
save `yearly_tempfile', replace

******************************
// Add VAT tag for each good

import excel "./HEIS_Yearly_VAT_rate.xlsx", firstrow clear

destring good_code, replace

keep vat_rate good_code
merge 1:m good_code using `yearly_tempfile'


drop if _merge == 1
drop _merge

// tab vat_rate [w=value]

*****************************
//  Merge two dataSet

append using `monthly_tempfile'
replace is_monthly = 0 if missing(is_monthly)
replace value = value * 12 if is_monthly == 1

if $paid_exp_only == 1 {
    drop if vat_rate == 01
}
else {
	replace vat_rate = 0 if vat_rate == -1
}

*****************************
// Add category

gen good_cat = ""
replace good_cat = "0" + substr(string(good_code), 1, 3) if length(string(good_code)) == 5
replace good_cat = substr(string(good_code), 1, 4) if length(string(good_code)) == 6


gen category = 13
replace category = 1  if substr(good_cat, 1, 2) == "01" | substr(good_cat, 1, 3) == "021"
/* replace category = 2  if substr(good_cat, 1, 2) == "02" */ // Tanbaco

replace category = 3  if substr(good_cat, 1, 2) == "03"
replace category = 4  if substr(good_cat, 1, 2) == "04"
replace category = 5  if substr(good_cat, 1, 2) == "05"
replace category = 6  if substr(good_cat, 1, 2) == "06"
replace category = 7  if substr(good_cat, 1, 2) == "07"
replace category = 8  if substr(good_cat, 1, 2) == "08"
replace category = 9  if substr(good_cat, 1, 2) == "09"
replace category = 10 if substr(good_cat, 1, 2) == "10"
replace category = 11 if substr(good_cat, 1, 2) == "11"
replace category = 12 if substr(good_cat, 1, 3) == "125"
// in data, 12 is others => code 13
// 13 into others (religious expenditure)

label define good_cat_label_fa ///
    1 "خوراکی و نوشیدنی" ///
    3 "پوشاک" ///
    4 "مسکن، آب و فاضلاب و روشنایی" ///
    5 "مبلمان و لوازم خانگی و نگهداری" ///
    6 "بهداشتی و درمانی" ///
    7 "حمل و نقل" ///
    8 "ارتباطات، تلفن و موبایل" ///
    9 "سرگرمی و تجهیزات سمعی-بصری و یارانه" ///
    10 "آموزش" ///
    11 "غذای آماده، هتل و رستوران" ///
    12 "بیمه" ///
	13 "سایر"

label define good_cat_label_en ///
    1 "foods & drinks" ///
    3 "clothes" ///
    4 "housing, water, light, fuel" ///
    5 "sofa, house exp" ///
    6 "Healthcare" ///
    7 "tranportation" ///
    8 "connections, phone & mobile" ///
    9 "entertainment, multimedia, computer" ///
    10 "learning" ///
    11 "hotel, restrunt" ///
    12 "Insurance" ///
	13 "others"

	
label values category good_cat_label_fa

tab category [w = value]


*******************************
// Calculate total value for each VAT tag:

gen value_exm = value * (vat_rate == 0)
gen value_9   = value * (vat_rate > 0)

egen tv_exm		= sum(value * (vat_rate == 0)), by(address)
egen tv_9 		= sum(value * (vat_rate == 9)), by(address)
egen tv_other 	= sum(value * ((vat_rate != 9) & (vat_rate != 0))), by(address)

egen cat_exm_ 	= sum(value * (vat_rate == 0)), by(address category)
egen cat_9_		= sum(value * (vat_rate == 9)), by(address category)
egen cat_other_ = sum(value * ((vat_rate != 9) & (vat_rate != 0))), by(address category)


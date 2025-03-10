frame change default
graph drop _all

graph set svg fontface "B Nazanin"

frame copy default graph_frame, replace
frame change graph_frame

********************************
// prepare data

	collapse (mean) tv_* cat_* NHazine calculated_exp  [aweight = weight], by(C09New)

	gen ratio_tv_exm = tv_exm / calculated_exp
		
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

	// checking result of collapse:
// 	graph bar (asis) ///
// 		ratio_tv_exm ///
// 		, over(C09New) stack ///
// 		title("exempt exp shares") ///
// 		ytitle("percent") ///
// 		blabel(bar, format(%4.2f) size(small)) ///
// 		name(exmp_exp_share, replace)

		
	// Paid only data:
	// upward cat:		13 6 7 9 10 11 12*
	// downward cat:	1 4
	// flat:			-
	// close to zero:	8 5* 3

// 	local cats 13 1 3 4 5 6 7 8 9 10 11 12
// 	foreach cat of local cats {
// 		line ratio_cat_exm_`cat' C09New, ///
// 			name(ratio_cat_exm_`cat', replace)
// 	}
		
		
	gen cat_upward_exm = cat_exm_12 + cat_exm_7 + cat_exm_6  + cat_exm_10 
	gen cat_downward_exm = cat_exm_1 + cat_exm_4
	gen cat_neutral_exm = cat_exm_8 + cat_exm_5 + cat_exm_3 + cat_exm_13 + cat_exm_9 + cat_exm_11

	gen ratio_cat_upward_exm  	= cat_upward_exm / calculated_exp * 100
	gen ratio_cat_downward_exm  = cat_downward_exm / calculated_exp * 100
	gen ratio_cat_neutral_exm   = cat_neutral_exm / calculated_exp * 100

	label variable ratio_cat_upward_exm 	"بهداشتی و درمانی، حمل و نقل، آموزش، بیمه"
	label variable ratio_cat_downward_exm 	"خوراکی و آشامیدنی، هزینه‌های مسکن و آب و فاضلاب"
	label variable ratio_cat_neutral_exm 	"سایر هزینه‌ها"

	graph bar (asis) ///
		ratio_cat_downward_exm ///
		ratio_cat_upward_exm ///
		ratio_cat_neutral_exm ///
		, over(C09New) stack ///
		title(سهم مخارج معاف از مالیات از کل مخارج خانوار در دهک - سال $year, size(large)) ///
		ytitle("نسبت از کل مخارج خانوار نمونه", size(medium)) ///
		b1title(دهک هزینه‌ای (1 = کمترین مخارج), size(medium) margin(medium)) ///
		legend(pos(6) row(1) ) ///
		bar(2, color(236 107 86))  ///
		bar(1, color(71  179 156)) ///
		name(exm_ration_cat_percentile, replace)
	graph export "./out/r_cat_exm_perc_${year}_paidOnly_${paid_exp_only}.png", replace

	
***********************
	
	
	gen cat_exm_13_2 = cat_exm_13 + cat_exm_3 + cat_exm_5 + cat_exm_8 + cat_exm_9 + cat_exm_11
	label variable cat_exm_13_2 "سایر"
	graph bar (asis) ///
		cat_exm_1 ///
		/* cat_exm_3 */ ///
		cat_exm_4 ///
		/* cat_exm_5 */ ///
		cat_exm_6 ///
		cat_exm_7 ///
		/* cat_exm_8 */ ///
		/* cat_exm_9 */ ///
		cat_exm_10 ///
		/* cat_exm_11 */ ///
		cat_exm_12 ///
		cat_exm_13_2 ///
		, over(C09New) stack percentage ///
		legend(pos(6) rows(3) symxsize(*1.5) size(*1.2)) ///
		title(مخارج معاف از مالیات بر ارزش افزوده در دهک‌های مختلف, size(large)) ///
		ytitle(سهم از کل مخارج معاف, size(medium)) ///
		b1title(دهک هزینه‌ای, size(medium) margin(medium)) ///
		yscale(titlegap(1.5)) ///
		intensity(50) ///
		name(exm_exp_share, replace)
	graph export "./out/share_cat_exm_perc_${year}_paidOnly_${paid_exp_only}.png", replace

	
*******************
	
	gen cat_9_13_3 = cat_9_13 + cat_9_9 + cat_9_10 + cat_9_6
	label variable cat_9_13_3 "سایر"
	graph bar (asis) ///
		cat_9_1 ///
		cat_9_3 ///
		cat_9_4 ///
		cat_9_5 ///
		/* cat_9_6 */ ///
		cat_9_7 ///
		cat_9_8 ///
		/* cat_9_9 */ ///
		/* cat_9_10 */ ///
		cat_9_11 ///
		cat_9_12 ///
		cat_9_13_3 ///
		, over(C09New) stack percentage ///
		legend(pos(6) rows(4) symxsize(*1.5) size(*1.2)) ///
		title(مخارج مشمول مالیات بر ارزش افزوده در دهک‌های مختلف, size(large)) ///
		ytitle(سهم از کل مخارج مشمول, size(medium)) ///
		b1title(دهک هزینه‌ای, size(medium) margin(medium)) ///
		yscale(titlegap(1.5)) ///
		intensity(50) ///
		name(vat_exp_share, replace)
	graph export "./out/share_cat_9_perc_${year}_paidOnly_${paid_exp_only}.png", replace

	
frame change default
frame drop graph_frame




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
//     label variable `var'_13 "others"
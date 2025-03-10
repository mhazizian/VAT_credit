frame change default
// graph drop _all

graph set svg fontface "B Nazanin"

frame copy default tax_credit_frame, replace
frame change tax_credit_frame


********************************
// calculation

gen tax_expenditure = tv_exm * 0.09

egen total_tax_exp = sum(tax_expenditure * weight)
egen total_population = sum(weight * C01)

gen tax_credit_indv = total_tax_exp / total_population
gen tax_credit_family = tax_credit_indv * C01

gen is_tax_credit_gt = 0
replace is_tax_credit_gt = 100 if tax_credit_family > tax_expenditure

******************

tabstat tax_credit_indv, s(mean min max)


graph bar is_tax_credit_gt [aw=weight] ///
	, over(C09New) ///
	title(درصد خانوار منتفع از سیاست اعتبار ارزش افزوده در هر دهک- سال $year, size(large)) ///
	ytitle("درصد خانوار منتفع در دهک", size(medium)) ///
	b1title(دهک هزینه‌ای, size(medium) margin(medium)) ///
	blabel(bar, format(%4.0f) size(small)) ///
	bar(1, color(71  179 156)) ///
	name(tax_credit_eff_dist, replace)
graph export "./out/tax_credit_eff_dist_${year}_paidOnly_${paid_exp_only}.png", replace


*****************
// Average family in percentile


collapse (mean) tv_* cat_* NHazine calculated_exp ///
	tax_expenditure tax_credit_indv tax_credit_family is_tax_credit_gt C01 [aweight = weight], by(C09New)


gen family_income_change = (tax_credit_family - tax_expenditure) / 1000 / 1000 / 10
	
graph bar C01, over(C09New)	///
	blabel(bar, format(%4.2f) size(small)) ///
	title(متوسط بعد خانوار در هر دهک - سال $year, size(large)) ///
	name(family_size, replace)
	
	
graph bar tax_expenditure, over(C09New)	///
	blabel(bar, format(%4.2f) size(small)) ///
	title(متوسط مخارج مالیاتی در خانوار نمونه - سال $year, size(large)) ///
	name(tax_exp, replace)
		
// graph bar tax_credit_family, over(C09New)	///
// 	blabel(bar, format(%4.2f) size(small)) ///
// 	title(متوسط اعتبار مالیاتی خانوار نمونه - سال $year, size(large))

gen is_positive = family_income_change > 0

graph bar family_income_change ///
	, over(is_positive) asyvars  over(C09New) ///
	title(میزان انتفاع یا ضرر خانوار نمونه در هر دهک - سال $year, size(large)) ///
	ytitle("میلیون تومان در سال", size(medium)) ///
	b1title(دهک هزینه‌ای, size(medium) margin(medium)) ///
	blabel(bar, format(%4.2f) size(small)) ///
	legend(off) ///
	bar(2, color(71  179 156)) ///
	bar(1, color(236 107 86))  ///
	name(tax_credit_eff_perc, replace)
graph export "./out/tax_credit_eff_perc_${year}_paidOnly_${paid_exp_only}.png", replace
	
	
frame change default
frame drop tax_credit_frame
	
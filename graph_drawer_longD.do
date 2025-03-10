frame change default
// graph drop _all

graph set svg fontface "B Nazanin"

frame copy default graph_frame, replace
frame change graph_frame


********************************
// Charts:

	graph hbar value_exm value_9, over(category, sort(1)) stack percentage ///
		bar(1, color(236 107 86))  ///
		bar(2, color(71  179 156)) ///
		legend(row(1) pos(6) order(1 "مخارج معاف از مالیات" 2 "مخارج مشمول مالیات")) ///
		title(مقایسه مخارج مشمول و مخارج معاف از مالیات بر ارزش افزوده در دسته‌های مختلف) ///
		ytitle(درصد) ///
		name(exm_exp_share_$year, replace)
	graph export "./out/exm_exp_share_${year}_paidOnly_${paid_exp_only}.png", replace
		
		

	// graph pie value, over(category)	
		
	gen is_exm = 0
	replace is_exm = 1 if vat_rate == 0

	label define is_exm_label ///
		1 "معاف از مالیات بر ارزش افزوده" ///
		0 "مشمول مالیات بر ارزش افزوده"
	label values is_exm is_exm_label


	graph pie value, over(category) ///
		by(is_exm, rows(1) ///
			title("مقایسه حجم کل مخارج خانوار در دسته‌های مختلف", size(large)) ///
			note("") ///
		) ///
		subtitle(, alignment(middle)) ///
		line(lcolor(black) lwidth(0.2)) ///
		graphregion(color(white)) ///
		legend(rows(4) symxsize(*1.5) size(*1.2) ring(0)) ///
		name(exp_description, replace)
	// 	plabel(_all percent, format(%2.0f) color(black) gap(-12)) ///

	graph export "./out/exp_description_${year}_paidOnly_${paid_exp_only}.png", replace


	// graph pie value_9, over(category) ///
	// 	title(مخارج بر کالا و خدمات مشول مالیات) ///
	// 	name(exp_on_taxable, replace)
	// graph combine exp_on_exm exp_on_taxable







frame change default
frame drop graph_frame
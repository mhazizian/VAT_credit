frame change default
graph drop _all

graph set svg fontface "B Nazanin"

frame copy default graph_frame, replace
frame change graph_frame


*******************************

	kdensity ratio_tv_exm [aw=weight], ///
		title("Exempt expenditure ratio histogram") ///
		xtitle("exempt ratio") ///
		name(ratio_tv_exm, replace)


********************************
// exm ratio across dffrent levels of expenditure:

	tabstat ratio_tv_exm 	[aw=weight], by(C09New)
	tabstat ratio_tv_exm_SC [aw=weight], by(C09New)
	tabstat ratio_tv_9 		[aw=weight], by(C09New)

	reg ratio_tv_exm C09New [aw=weight] // negetive relationship
	reg ratio_tv_exm ln_GHazine [aw=weight] // no relationship

	graph twoway scatter ratio_tv_exm ln_GHazine [aw=weight], m(smplus) || lfit ratio_tv_exm ln_GHazine [aw=weight]

*******************************

	gen nweight = weight * calculated_exp
		
	graph bar (mean) ratio_tv_exm [aw=weight], over(C09New) ///
		title(سهم مخارج بر کالای و خدمات معاف از مالیات از کل مخارج خانوار در دهک - سال $year, size(large)) ///
		ytitle("متوسط نرخ در دهک - درصد", size(medium)) ///
		b1title(دهک هزینه‌ای, size(medium) margin(medium)) ///
		legend(pos(6)) ///
		blabel(bar, format(%4.2f) size(small)) ///
		name(exm_ration_percentile1, replace)
	graph export "./out/r_tv_exm_perc_${year}_paidOnly_${paid_exp_only}.png", replace
		
	graph bar (mean) ratio_tv_exm [aw=nweight], over(C09New) ///
		title(سهم مخارج بر کالای و خدمات معاف از مالیات از کل مخارج خانوار در دهک - سال $year, size(large)) ///
		ytitle("نسبت مخارج معاف به کل مخارج در خانوار نمونه", size(medium)) ///
		b1title(دهک هزینه‌ای, size(medium) margin(medium)) ///
		legend(pos(6)) ///
		blabel(bar, format(%4.2f) size(small)) ///
		name(exm_ration_percentile2, replace)
	graph export "./out/r_tv_exm_perc_w_${year}_paidOnly_${paid_exp_only}.png", replace
		
	graph box ratio_tv_exm [aw=weight], over(C09New) nooutsides nolabel ///
		title(توزیع سهم مخارج بر کالا و خدمات معاف از مالیات از کل مخارج خانوار در دهک - سال $year, size(large)) ///
		ytitle("نسبت مخارج بر کالای معاف به کل مخارج", size(medium)) ///
		b1title(دهک هزینه‌ای, size(medium) margin(medium)) ///
		legend(pos(6)) ///
		note("") ///
		name(exm_ration_percentile3, replace)
	graph export "./out/r_tv_exm_perc_bp_${year}_paidOnly_${paid_exp_only}.png", replace
			
	graph bar (mean) tax_exp_MT [aw=weight], over(C09New) 	///
		title(متوسط بهره‌مندی خانوار از معافیت‌های مالیات بر ارزش افزوده در طول سال, size(large)) ///
		ytitle(میلیون تومان در سال, size(medium)) ///
		b1title(دهک هزینه‌ای, size(medium) margin(medium)) ///
		yscale(titlegap(1.5)) ///
		name(hh_tax_exp, replace)
	graph export "./out/tax_exp_${year}_paidOnly_${paid_exp_only}.png", replace
	


frame change default
frame drop graph_frame
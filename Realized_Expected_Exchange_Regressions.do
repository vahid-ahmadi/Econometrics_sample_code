preserve

keep if NoPegSample == 1
keep if regsample == 1

*drop if missing(ln_theta_12m_avg)

*collapse (mean) ln_FXfcst_12m_consensus epu_adj ln_spotexr_fwd ln_ir_diff_12m_avg ,by(EM date)


eststo: reghdfe ln_spotexr_fwd ln_FXfcst_12m_consensus  if EM == 1, cluster(id date) 
qui{
	estadd local countryfe "No",replace
	estadd local timefe "No",replace
	scalar r2 = e(r2)
	estadd scalar r2, replace
	scalar r2_within = e(r2_within)
	estadd scalar r2_within, replace
}

eststo: reghdfe ln_spotexr_fwd ln_FXfcst_12m_consensus  if EM == 1, absorb(id) cluster(id date) 
qui{
	estadd local countryfe "Yes",replace
	estadd local timefe "No",replace
	scalar r2 = e(r2)
	estadd scalar r2, replace
	scalar r2_within = e(r2_within)
	estadd scalar r2_within, replace
}

eststo: reghdfe ln_spotexr_fwd ln_FXfcst_12m_consensus  if EM == 1, absorb(date) cluster(id date) 
qui{
	estadd local countryfe "No",replace
	estadd local timefe "Yes",replace
	scalar r2 = e(r2)
	estadd scalar r2, replace
	scalar r2_within = e(r2_within)
	estadd scalar r2_within, replace
}

eststo: reghdfe ln_spotexr_fwd ln_FXfcst_12m_consensus  if EM == 1, absorb(id date) cluster(id date) 
qui{
	estadd local countryfe "Yes",replace
	estadd local timefe "Yes",replace
	scalar r2 = e(r2)
	estadd scalar r2, replace
	scalar r2_within = e(r2_within)
	estadd scalar r2_within, replace
}


esttab * using "${tables}/realized_expected_20feb_EM.tex", ///
se(%10.3f) b(%10.3f) fragment label replace ///
mgroups( "Log Realized Exchange Rate", ///
pattern(1 0 0 0)  ///
prefix(\multicolumn{@span}{c}{) suffix(}) ///
span erepeat(\cmidrule(lr){@span})) ///
booktabs ///
coeflabels(ln_FXfcst_12m_consensus "Log Expected Exchange Rate" ln_ir_diff_12m_avg "Log Interest Differential") ///
star(* 0.10 ** 0.05 *** 0.01)  ///
stats(N r2 r2_within countryfe timefe, fmt(%9.0g %9.4f %9.4f) ///
labels("Obs." "$\vspace{0pt}R^2$" "Within $\vspace{0pt}R^2$" "Currency FE" "Time FE")) ///
substitute(\_ _) ///
drop(_cons) ///
nomtitles
eststo clear

restore



preserve

keep if NoPegSample == 1
keep if regsample == 1

*drop if missing(ln_theta_12m_avg)

*collapse (mean) ln_FXfcst_12m_consensus epu_adj ln_spotexr_fwd ln_ir_diff_12m_avg ,by(EM date)


eststo: reghdfe ln_spotexr_fwd ln_FXfcst_12m_consensus ln_ir_diff_12m_avg if EM == 0, cluster(id date) 
qui{
	estadd local countryfe "No",replace
	estadd local timefe "No",replace
	scalar r2 = e(r2)
	estadd scalar r2, replace
	scalar r2_within = e(r2_within)
	estadd scalar r2_within, replace
}

eststo: reghdfe ln_spotexr_fwd ln_FXfcst_12m_consensus ln_ir_diff_12m_avg if EM == 0, absorb(id) cluster(id date) 
qui{
	estadd local countryfe "Yes",replace
	estadd local timefe "No",replace
	scalar r2 = e(r2)
	estadd scalar r2, replace
	scalar r2_within = e(r2_within)
	estadd scalar r2_within, replace
}

eststo: reghdfe ln_spotexr_fwd ln_FXfcst_12m_consensus ln_ir_diff_12m_avg if EM == 0, absorb(date) cluster(id date) 
qui{
	estadd local countryfe "No",replace
	estadd local timefe "Yes",replace
	scalar r2 = e(r2)
	estadd scalar r2, replace
	scalar r2_within = e(r2_within)
	estadd scalar r2_within, replace
}

eststo: reghdfe ln_spotexr_fwd ln_FXfcst_12m_consensus ln_ir_diff_12m_avg if EM == 0, absorb(id date) cluster(id date) 
qui{
	estadd local countryfe "Yes",replace
	estadd local timefe "Yes",replace
	scalar r2 = e(r2)
	estadd scalar r2, replace
	scalar r2_within = e(r2_within)
	estadd scalar r2_within, replace
}


esttab * using "${tables}/realized_expected_20feb_AE.tex", ///
se(%10.3f) b(%10.3f) fragment label replace ///
mgroups( "Log Realized Exchange Rate", ///
pattern(1 0 0 0)  ///
prefix(\multicolumn{@span}{c}{) suffix(}) ///
span erepeat(\cmidrule(lr){@span})) ///
booktabs ///
coeflabels(ln_FXfcst_12m_consensus "Log Expected Exchange Rate" ln_ir_diff_12m_avg "Log Interest Differential") ///
star(* 0.10 ** 0.05 *** 0.01)  ///
stats(N r2 r2_within countryfe timefe, fmt(%9.0g %9.4f %9.4f) ///
labels("Obs." "$\vspace{0pt}R^2$" "Within $\vspace{0pt}R^2$" "Currency FE" "Time FE")) ///
substitute(\_ _) ///
drop(_cons) ///
nomtitles
eststo clear

restore



preserve

keep if NoPegSample == 1
keep if regsample == 1

*drop if missing(ln_theta_12m_avg)

*collapse (mean) ln_FXfcst_12m_consensus epu_adj ln_spotexr_fwd ln_ir_diff_12m_avg ,by(EM date)


eststo: ivreghdfe ln_spotexr_fwd ln_FXfcst_12m_consensus (ln_ir_diff_12m_avg = epu_adj) if EM == 1, cluster(id date) 
qui{
	estadd local countryfe "No",replace
	estadd local timefe "No",replace
	scalar r2 = e(r2)
	estadd scalar r2, replace
	scalar r2_within = e(r2_within)
	estadd scalar r2_within, replace
	scalar f_stat = e(widstat)
	estadd scalar f_stat, replace
}

eststo: ivreghdfe ln_spotexr_fwd ln_FXfcst_12m_consensus (ln_ir_diff_12m_avg = epu_adj) if EM == 1, absorb(id) cluster(id date) first
qui{
	estadd local countryfe "Yes",replace
	estadd local timefe "No",replace
	scalar r2 = e(r2)
	estadd scalar r2, replace
	scalar r2_within = e(r2_within)
	estadd scalar r2_within, replace
	scalar f_stat = e(widstat)
	estadd scalar f_stat, replace
}

eststo: ivreghdfe ln_spotexr_fwd ln_FXfcst_12m_consensus (ln_ir_diff_12m_avg = epu_adj) if EM == 1, absorb(date) cluster(id date) first
qui{
	estadd local countryfe "No",replace
	estadd local timefe "Yes",replace
	scalar r2 = e(r2)
	estadd scalar r2, replace
	scalar r2_within = e(r2_within)
	estadd scalar r2_within, replace
	scalar f_stat = e(widstat)
	estadd scalar f_stat, replace
}


esttab * using "${tables}/realized_expected_20feb_fstat_EM.tex", ///
se(%10.3f) b(%10.3f) fragment label replace ///
mgroups( "Log Realized Exchange Rate", ///
pattern(1 0 0 0 0 0)  ///
prefix(\multicolumn{@span}{c}{) suffix(}) ///
span erepeat(\cmidrule(lr){@span})) ///
booktabs ///
coeflabels(ln_FXfcst_12m_consensus "Log Expected Exchange Rate" ln_ir_diff_12m_avg "Log Interest Differential" epu_adj "EPU") ///
star(* 0.10 ** 0.05 *** 0.01)  ///
stats(N r2 r2_within f_stat countryfe timefe, fmt(%9.0g %9.4f %9.4f) ///
labels("Obs." "$\vspace{0pt}R^2$" "Within $\vspace{0pt}R^2$" "Cragg-Donald Wald F stat." "Cragg-Donald Wald F stat." "Kleibergen-Paap Wald F stat." "Currency FE" "Time FE")) ///
substitute(\_ _) ///
drop(_cons) ///
nomtitles
eststo clear

restore
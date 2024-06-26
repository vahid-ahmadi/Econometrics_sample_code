preserve

keep if NoPegSample == 1


collapse (mean) ln_vix_avg epu_adj ///
                  ,by(EM country date)
				  

* Dates and Colors
global datestart 1996m12
global dateend 2018m10
global ourwidth 36

global ourred " "220 50 32" "
global ourblue " "0 90 181" "
global ourgreen " "86 117 114" "



*-------------------- EPU TASK
qui pwcorr ln_vix_avg epu_adj if inrange(date,tm($datestart ),tm($dateend)) & EM == 1 & country == "Mexico", sig
local rho_epu_vix: display %5.3f r(rho)
matrix A = r(sig)
local rho_epu_vix_sig: display %5.3f A[2,1]

twoway (scatter epu_adj date if EM == 1 & country == "Mexico",  yaxis(2) connect(l) msymbol(i) lcolor(black) msize(large) )  ///
(scatter ln_vix_avg date if EM == 1 & country == "Mexico", yaxis(1) connect(l) msymbol(i) lcolor($ourblue) msize(large) ) ///
if inrange(date, tm($datestart), tm($dateend)) ///
, legend(label(1 "EPU") label(2 "VIX") region(lcolor(white)) symysize(2) symxsize(5)  rows(1) ring(1) position(6)) ///
ytitle("EPU", axis(2)) ///
ylabel(2.3(0.5)4.3)  ytitle("", axis(1)) ///
xtitle("") ysc(titlegap(1)) ///
tlabel($datestart($ourwidth)$dateend $dateend, valuelabel labsize(medsmall) angle(45)) ///
caption("Corr(VIX, EPU) = `rho_epu_vix', P-value = `rho_epu_vix_sig'")  	 ///
graphregion(color(white)) plotregion(margin(1 0 0 0)) bgcolor(white) tlabel($datestart($ourwidth)$dateend $dateend) yline(0) 
gr export "/.../vix_epu_EM_Mexico.pdf", replace 

*-------------------- END OF EPU TASk








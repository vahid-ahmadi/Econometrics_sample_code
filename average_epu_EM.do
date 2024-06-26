clear

use "/Users/janansadeqian/Library/CloudStorage/Dropbox/UIP/vahid/empirics_alvaro/codes/latest_data.dta"


*drop if missing(epu_adj)
keep if NoPegSample == 1 
collapse epu_adj if EM == 1, by(date)

global datestart 1996m12
global dateend 2018m1



twoway (line epu_adj date, lcolor($ourblue)) || pcarrowi 2.55 475 2 465 (3) "Russian Fin. Crisis" 1.8 500 1.45 500 (1) "Turkey Currency Crisis" ///
1.6 510 0.75 510 (2) "Argentina Default Declar." 0.9 585 0.45 585 (11) "South Africa Currency Volatility" ///
1.47 671 0.55 668 (12) "Chinese Stock Market Crash" 1.75 623 0.55 628 (2) "Argentina YPF Nationalization" /// 
1.4 520 0.75 513 (2) "Turkey Econ. Crisis & Reforms" 1.15 605 0.6 605 (11) "European (Greece) Debt Crisis" ///
1.97 610 1.05 622 (12) "China Downgrade of US Sovereign Credit Rating" 1 648 0.4 648 (12) "Russo-Ukrainian War" ///
-0.85 686 0.1 686 (6) "Brazil Political Turmoil" -0.6 677 -0.17 677 (7) "Istanbul Airport bombing" ///
1.23 693 0.9 682 (12) "NAFTA Trump Threat" -1 454 0.25 454 (3) "Asian Fin. Crisis (South Korea Hit)" ///
0.7 557 0.2 557 (12) "Slovakia Political Change" -0.85 532 -0.3 532 (5) "India Political Transition" ///
-0.85 590 -0.1 590 (5) "Hungary Currency Crisis" 2.18 490 1.05 490 (1) "Argentina Debt Run" ///
-0.6 484 -0.4 484 (6) "Indonesia Political Transition" ///
,xlabel(444(12)697, angle(45)) ylabel(-1(0.5)3,) xtitle("") ///
ytitle("EPU") title("Average Economic Policy Uncertainty For Emerging Markets Over Time") legend(off) color(gray) ///
mlabcolor(gray) ysize(10) xsize(20) 


egen country_index = group(country)
twoway (line epu_adj date, lcolor($ourblue)) if inrange(country_index, 1, 6), by(country, cols(2) note("")) ///
ysize(15) xsize(30) ytitle("") xtitle("") title("") ///
xlabel(444(12)697, angle(45)) ylabel(-1(1)4,)



* ----------------------------------------------------------------------------------------------------------------------------

clear
*use "C:\Users\AHMADIV\Dropbox\UIP\vahid\empirics_alvaro\codes\latest_data.dta"
use "/Users/janansadeqian/Library/CloudStorage/Dropbox/UIP/vahid/empirics_alvaro/codes/latest_data.dta"


*drop if missing(ln_theta_12m_avg)
*keep if NoPegSample == 1 
collapse ln_theta_12m_avg epu_adj if EM == 1, by(date)

global datestart 1996m12
global dateend 2018m1



qui pwcorr ln_theta_12m_avg epu_adj if inrange(date,tm($datestart),tm($dateend)), sig
local rho_uip_prp: display %5.3f r(rho)
matrix A = r(sig)
local rho_uip_prp_sig: display %5.3f A[2,1]



twoway (line epu_adj date, yaxis(1) lcolor($ourblue)) (line ln_theta_12m_avg date, yaxis(2) lpattern("-") lcolor(red)) ///
|| pcarrowi 2.9 475 2.1 465 (2) "Russian Fin. Crisis" 2.4 500 1.45 500 (1) "Turkey Currency Crisis" ///
2.2 510 1.2 510 (2) "Argentina Default Declar." 1.45 585 1.25 585 (11) "South Africa Currency Volatility" ///
1.7 653 0.75 668 (12) "Chinese Stock Market Crash" 2.1 618 0.8 628 (2) "Argentina YPF Nationalization" /// 
1.9 520 1.2 513 (2) "Turkey Econ. Crisis & Reforms" 1.65 605 0.7 605 (11) "European (Greece) Debt Crisis" ///
2.5 610 1.15 622 (12) "China Downgrade of US Sovereign Credit Rating" -0.65 648 -0.25 648 (9) "Russo-Ukrainian War" ///
-0.85 686 -0.5 687 (6) "Brazil Political Turmoil" -0.8 677 -0.5 677 (9) "Istanbul Airport bombing" ///
1.4 682 1.1 682 (12) "NAFTA Trump Threat" -1 450 0 454 (3) "Asian Fin. Crisis (South Korea Hit)" ///
0.7 550 0.2 557 (12) "Slovakia Political Change" -0.85 532 -0.5 532 (5) "India Political Transition" ///
-0.85 590 -0.1 590 (5) "Hungary Currency Crisis" 2.8 490 1.2 490 (3) "Argentina Debt Run" ///
-0.6 484 -0.4 484 (6) "Indonesia Political Transition" ///
, xlabel(444(12)702, angle(45) nogrid) ylabel(-1(0.5)3, axis(1) nogrid) ylabel(-0.05(0.05)0.25, axis(2) nogrid) xtitle("") ///
ytitle("UIP Premium", axis(2) color(red)) ytitle("Policy Risk Premium", axis(1) color($ourblue)) legend(off) color(gray) ///
mlabcolor(gray) ysize(10) xsize(20) caption(`"Corr(PRP, UIP) = `rho_uip_prp', P-value = `rho_uip_prp_sig'"') graphregion(color(white))
graph export ${plots}/epu_event.pdf, replace




* ----------------------------------------------------------------------------------------------------------------------------


clear
*use "C:\Users\AHMADIV\Dropbox\UIP\vahid\empirics_alvaro\codes\latest_data.dta"
use "/Users/janansadeqian/Library/CloudStorage/Dropbox/UIP/vahid/empirics_alvaro/codes/latest_data.dta"


*drop if missing(ln_theta_12m_avg)
*keep if NoPegSample == 1 
collapse ln_theta_12m_avg epu_adj if EM == 1, by(date)

global datestart 1996m12
global dateend 2018m1

qui pwcorr ln_theta_12m_avg epu_adj if inrange(date,tm($datestart),tm($dateend)), sig
local rho_uip_prp1: display %5.3f r(rho)
matrix A = r(sig)
local rho_uip_prp_sig1: display %5.3f A[2,1]


// 452-455
// 463-466
// 483-485
// 488-491
// 498-502
// 507-514
// 530-532
// 584-586
// 589-591
// 604-606
// 620-624
// 627-629
// 647-649
// 667-669
// 676-678
// 681-685

local seg1 "date < 452"
local seg2 "date > 454 & date < 461"
local seg3 "date > 464 & date < 484"
local seg4 "date > 490 & date < 499"
local seg5 "date > 501 & date < 510"
local seg6 "date > 513 & date < 585"
local seg7 "date > 590 & date < 620"
local seg8 "date > 623 & date < 647"
local seg9 "date > 649 & date < 667"
local seg10 "date > 669 & date < 681"
local seg11 "date > 685"


qui pwcorr ln_theta_12m_avg epu_adj if inrange(date, tm($datestart), tm($dateend)) & (`seg1' | `seg2' | `seg3' | `seg4' | `seg5' | `seg6' | `seg7' | `seg8' | `seg9' | `seg10' | `seg11'), sig
local rho_uip_prp: display %5.3f r(rho)
matrix A = r(sig)
local rho_uip_prp_sig: display %5.3f A[2,1]





* Plot each segment for epu_adj
twoway (line epu_adj date, yaxis(1) lpattern("-") lcolor($ourblue)) ///
	   (line epu_adj date if `seg1', yaxis(1) lcolor($ourblue)) ///
       (line epu_adj date if `seg2', yaxis(1) lcolor($ourblue)) ///
       (line epu_adj date if `seg3', yaxis(1) lcolor($ourblue)) ///
       (line epu_adj date if `seg4', yaxis(1) lcolor($ourblue)) ///
       (line epu_adj date if `seg5', yaxis(1) lcolor($ourblue)) ///
       (line epu_adj date if `seg6', yaxis(1) lcolor($ourblue)) ///
       (line epu_adj date if `seg7', yaxis(1) lcolor($ourblue)) ///
       (line epu_adj date if `seg8', yaxis(1) lcolor($ourblue)) ///
       (line epu_adj date if `seg9', yaxis(1) lcolor($ourblue)) ///
       (line epu_adj date if `seg10', yaxis(1) lcolor($ourblue)) ///
       (line epu_adj date if `seg11', yaxis(1) lcolor($ourblue)) ///
	   (line ln_theta_12m_avg date, yaxis(2) lpattern("-") lcolor(red)) ///
       (line ln_theta_12m_avg date if `seg1', yaxis(2) lcolor(red)) ///
       (line ln_theta_12m_avg date if `seg2', yaxis(2) lcolor(red)) ///
       (line ln_theta_12m_avg date if `seg3', yaxis(2) lcolor(red)) ///
       (line ln_theta_12m_avg date if `seg4', yaxis(2) lcolor(red)) ///
       (line ln_theta_12m_avg date if `seg5', yaxis(2) lcolor(red)) ///
       (line ln_theta_12m_avg date if `seg6', yaxis(2) lcolor(red)) ///
       (line ln_theta_12m_avg date if `seg7', yaxis(2) lcolor(red)) ///
       (line ln_theta_12m_avg date if `seg8', yaxis(2) lcolor(red)) ///
       (line ln_theta_12m_avg date if `seg9', yaxis(2) lcolor(red)) ///
       (line ln_theta_12m_avg date if `seg10', yaxis(2) lcolor(red)) ///
       (line ln_theta_12m_avg date if `seg11', yaxis(2) lcolor(red)) ///
|| pcarrowi 2.9 475 2.1 465 (2) "Russian Fin. Crisis" 2.4 500 1.45 500 (1) "Turkey Currency Crisis" ///
2.2 510 1.2 510 (2) "Argentina Default Declar." 1.45 585 1.25 585 (11) "South Africa Currency Volatility" ///
1.7 653 0.75 668 (12) "Chinese Stock Market Crash" 2.1 618 0.8 628 (2) "Argentina YPF Nationalization" /// 
1.9 520 1.2 513 (2) "Turkey Econ. Crisis & Reforms" 1.65 605 0.7 605 (11) "European (Greece) Debt Crisis" ///
2.5 610 1.15 622 (12) "China Downgrade of US Sovereign Credit Rating" -0.65 648 -0.25 648 (9) "Russo-Ukrainian War" ///
-0.85 686 -0.5 687 (6) "Brazil Political Turmoil" -0.8 677 -0.5 677 (9) "Istanbul Airport bombing" ///
1.4 682 1.1 682 (12) "NAFTA Trump Threat" -1 450 0 454 (3) "Asian Fin. Crisis (South Korea Hit)" ///
0.7 550 0.2 557 (12) "Slovakia Political Change" -0.85 532 -0.5 532 (5) "India Political Transition" ///
-0.85 590 -0.1 590 (5) "Hungary Currency Crisis" 2.8 490 1.2 490 (3) "Argentina Debt Run" ///
-0.6 484 -0.4 484 (6) "Indonesia Political Transition" ///
, xlabel(444(12)702, angle(45) nogrid) ylabel(-1(0.5)3, axis(1) nogrid) ylabel(-0.05(0.05)0.25, axis(2) nogrid) xtitle("") ///
ytitle("UIP Premium", axis(2) color(red)) ytitle("Policy Risk Premium", axis(1) color($ourblue)) legend(off) color(gray) ///
mlabcolor(gray) ysize(10) xsize(20) graphregion(color(white)) /// 
caption(`"Corr(PRP, UIP) = `rho_uip_prp1', P-value = `rho_uip_prp_sig1'"' `"Excluding bad events: Corr(PRP, UIP) = `rho_uip_prp', P-value = `rho_uip_prp_sig'"')
graph export ${plots}/epu_event_dropped.pdf, replace



* ----------------------------------------------------------------------------------------------------------------------------



egen country_index = group(country)

twoway (line ln_theta_12m_avg date, lcolor($ourblue)) if inrange(country_index, 7, 12), by(country, cols(2) note("")) ///
ysize(15) xsize(30) ytitle("") xtitle("") title("") ///
xlabel(444(12)697, angle(45)) ylabel(,)



global path "/Users/janansadeqian/Library/CloudStorage/Dropbox"



* ---------------------------- EM_Realized

do "$path/UIP/vahid/empirics_alvaro/codes//00_table.do"
keep if NoPegSample == 1
keep if regsample == 1
keep if EM == 1
xtset id date
gen TED = f.lag_TEDRATE
gen FEDFUNDS = f.lag_FEDFUNDS
gen all_DB_inflow_IMF_GDP = f.all_DB_inflow_IMF_GDPi_lag
gen US_term_1 = i_treasury_24m_avg - FEDFUNDS
gen US_term_2 = i_treasury_10yr_avg - i_treasury_24m_avg


keep date id spotexr_avg TED US_term_1 US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield 
gen exchange_rate = log(spotexr_avg)
bys id: egen mean = mean(exchange_rate)
gen s = exchange_rate - mean
drop mean exchange_rate spotexr_avg
collapse (mean) TED US_term_1 US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield s ,by(date)
gen t=[_n]
gen currency = "SA"

egen curr_id = group(currency)
xtset curr_id t

gen fd24_s=f24.s-s
gen fd12_s=f12.s-s
gen fd3_s=f3.s-s
gen fd1_s=f1.s-s

// local diff=1

foreach diff in 1 3 12 24 {
foreach x in SA{
foreach z in TED US_term_1 US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield{
preserve

local date1=264
drop if currency!="`x'"
gen z=`z'
gen fitted_s=.
gen R2=.
gen fitted_s_small=.
gen R2_small=.
local r_window=60
local p=`date1'-`diff'-`r_window'
local q=`p'-1
disp "`q'"
gen obs=`p'+`r_window'
disp "`diff'""-""`z'""-""obs`obs'"
forvalues t=0/`q' {

sort t
quietly reg fd`diff'_s  `z' if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"  
quietly predict xb_reg if t==(1+`r_window'+`t')&currency=="`x'"
quietly replace fitted_s=xb_reg if t==(1+`r_window'+`t')&currency=="`x'"
quietly replace R2=e(r2_a) if t==(1+`r_window'+`t')&currency=="`x'"
quietly drop xb_reg

}

disp "-o-o-"

gen model_small_re_sq=(fd`diff'_s)^2 if s!=.&z!=.
gen model_big_re_sq=(fitted_s-fd`diff'_s)^2 if s!=.&z!=.
gen adj=(fitted_s)^2 if s!=.&z!=.
gen new_fhat=model_small_re_sq-(model_big_re_sq-adj) if s!=.&z!=.
**
gen CW_stat_reg=.

sort curr_id t
local lag_num=`diff'-1
newey new_fhat if currency=="`x'",lag(`lag_num')
gen CW_beta`x'=e(b)[1,1]
gen CW_se`x'=(e(V)[1,1])^(1/2)
replace CW_stat_reg=CW_beta`x'/CW_se`x' if currency=="`x'"

sort currency date
keep currency CW_stat_reg
collapse (mean) CW_stat_reg ,by (currency)
gen diff="`diff'"
gen macro_var="`z'"
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_`z'.dta",replace
restore
}
}
}



clear all 
// local diff=1
foreach diff in 1 3 12 24 {
foreach x in SA{
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_US_term_1.dta"
foreach z in TED US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield {
append using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_`z'.dta"
rm "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_`z'.dta"
}
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_all.dta",replace
}
}

clear all 
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_SA_d1_all.dta"
foreach diff in 3 12 24 {
append using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_SA_d`diff'_all.dta"
}
drop currency
replace macro_var = "Log VIX" if macro_var == "ln_vix_avg"
replace macro_var = "PRP" if macro_var == "epu_adj"
replace macro_var = "US Term spread (2y-FF)" if macro_var == "US_term_1"
replace macro_var = "US Term spread (10y-2y)" if macro_var == "US_term_2"
replace macro_var = "Convenience Yield/Liquidity Premium" if macro_var == "global_convenience_yield"
replace macro_var = "Inflows/GDP" if macro_var == "all_DB_inflow_IMF_GDP"
rename  macro_var Independent_variables
rename diff Horizon
rename CW_stat_reg EM_Realized
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//EM_Realized.dta",replace



* ---------------------------- AE_Realized

do "$path/UIP/vahid/empirics_alvaro/codes//00_table.do"
keep if NoPegSample == 1
keep if regsample == 1
keep if EM == 0
xtset id date
gen TED = f.lag_TEDRATE
gen FEDFUNDS = f.lag_FEDFUNDS
gen all_DB_inflow_IMF_GDP = f.all_DB_inflow_IMF_GDPi_lag
gen US_term_1 = i_treasury_24m_avg - FEDFUNDS
gen US_term_2 = i_treasury_10yr_avg - i_treasury_24m_avg


keep date id spotexr_avg TED US_term_1 US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield 
gen exchange_rate = log(spotexr_avg)
bys id: egen mean = mean(exchange_rate)
gen s = exchange_rate - mean
drop mean exchange_rate spotexr_avg
collapse (mean) TED US_term_1 US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield s ,by(date)
gen t=[_n]
gen currency = "SA"

egen curr_id = group(currency)
xtset curr_id t

gen fd24_s=f24.s-s
gen fd12_s=f12.s-s
gen fd3_s=f3.s-s
gen fd1_s=f1.s-s

// local diff=1

foreach diff in 1 3 12 24 {
foreach x in SA{
foreach z in TED US_term_1 US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield{
preserve

local date1=264
drop if currency!="`x'"
gen z=`z'
gen fitted_s=.
gen R2=.
gen fitted_s_small=.
gen R2_small=.
local r_window=60
local p=`date1'-`diff'-`r_window'
local q=`p'-1
disp "`q'"
gen obs=`p'+`r_window'
disp "`diff'""-""`z'""-""obs`obs'"
forvalues t=0/`q' {

sort t
quietly reg fd`diff'_s  `z' if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"  
quietly predict xb_reg if t==(1+`r_window'+`t')&currency=="`x'"
quietly replace fitted_s=xb_reg if t==(1+`r_window'+`t')&currency=="`x'"
quietly replace R2=e(r2_a) if t==(1+`r_window'+`t')&currency=="`x'"
quietly drop xb_reg

}

disp "-o-o-"

gen model_small_re_sq=(fd`diff'_s)^2 if s!=.&z!=.
gen model_big_re_sq=(fitted_s-fd`diff'_s)^2 if s!=.&z!=.
gen adj=(fitted_s)^2 if s!=.&z!=.
gen new_fhat=model_small_re_sq-(model_big_re_sq-adj) if s!=.&z!=.
**
gen CW_stat_reg=.

sort curr_id t
local lag_num=`diff'-1
newey new_fhat if currency=="`x'",lag(`lag_num')
gen CW_beta`x'=e(b)[1,1]
gen CW_se`x'=(e(V)[1,1])^(1/2)
replace CW_stat_reg=CW_beta`x'/CW_se`x' if currency=="`x'"

sort currency date
keep currency CW_stat_reg
collapse (mean) CW_stat_reg ,by (currency)
gen diff="`diff'"
gen macro_var="`z'"
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_`z'.dta",replace
restore
}
}
}



clear all 
// local diff=1
foreach diff in 1 3 12 24 {
foreach x in SA{
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_US_term_1.dta"
foreach z in TED US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield {
append using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_`z'.dta"
rm "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_`z'.dta"
}
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_all.dta",replace
}
}

clear all 
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_SA_d1_all.dta"
foreach diff in 3 12 24 {
append using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_SA_d`diff'_all.dta"
}
drop currency
replace macro_var = "Log VIX" if macro_var == "ln_vix_avg"
replace macro_var = "PRP" if macro_var == "epu_adj"
replace macro_var = "US Term spread (2y-FF)" if macro_var == "US_term_1"
replace macro_var = "US Term spread (10y-2y)" if macro_var == "US_term_2"
replace macro_var = "Convenience Yield/Liquidity Premium" if macro_var == "global_convenience_yield"
replace macro_var = "Inflows/GDP" if macro_var == "all_DB_inflow_IMF_GDP"
rename  macro_var Independent_variables
rename diff Horizon
rename CW_stat_reg AE_Realized
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//AE_Realized.dta",replace







* ---------------------------- EM_Expected

do "$path/UIP/vahid/empirics_alvaro/codes//00_table.do"
keep if NoPegSample == 1
keep if regsample == 1
keep if EM == 1
xtset id date
gen TED = f.lag_TEDRATE
gen FEDFUNDS = f.lag_FEDFUNDS
gen all_DB_inflow_IMF_GDP = f.all_DB_inflow_IMF_GDPi_lag
gen US_term_1 = i_treasury_24m_avg - FEDFUNDS
gen US_term_2 = i_treasury_10yr_avg - i_treasury_24m_avg


keep date id spotexr_avg TED US_term_1 US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield FXfcst_1m_consensus FXfcst_3m_consensus FXfcst_12m_consensus FXfcst_24m_consensus



gen FXfcst_1m = log(FXfcst_1m_consensus)
gen FXfcst_3m = log(FXfcst_3m_consensus)
gen FXfcst_12m = log(FXfcst_12m_consensus)
gen FXfcst_24m = log(FXfcst_24m_consensus)

bys id: egen mean_FXfcst_1m = mean(FXfcst_1m)
bys id: egen mean_FXfcst_3m = mean(FXfcst_3m)
bys id: egen mean_FXfcst_12m = mean(FXfcst_12m)
bys id: egen mean_FXfcst_24m = mean(FXfcst_24m)

gen expected_1 = FXfcst_1m - mean_FXfcst_1m
gen expected_3 = FXfcst_3m - mean_FXfcst_3m
gen expected_12 = FXfcst_12m - mean_FXfcst_12m
gen expected_24 = FXfcst_24m - mean_FXfcst_24m
drop FXfcst_1m_consensus FXfcst_3m_consensus FXfcst_12m_consensus FXfcst_24m_consensus
drop FXfcst_1m FXfcst_3m FXfcst_12m FXfcst_24m mean_FXfcst_1m mean_FXfcst_3m mean_FXfcst_12m mean_FXfcst_24m

gen exchange_rate = log(spotexr_avg)
bys id: egen mean = mean(exchange_rate)
gen s = exchange_rate - mean
drop mean exchange_rate spotexr_avg
collapse (mean) TED US_term_1 US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield s expected_1 expected_3 expected_12 expected_24,by(date)
gen t=[_n]
gen currency = "SA"

egen curr_id = group(currency)
xtset curr_id t

gen fd24_s=f24.expected_24-expected_24
gen fd12_s=f12.expected_12-expected_12
gen fd3_s=f3.expected_3-expected_3
gen fd1_s=f1.expected_1-expected_1

// local diff=1

foreach diff in 1 3 12 24 {
foreach x in SA{
foreach z in TED US_term_1 US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield{
preserve

local date1=264
drop if currency!="`x'"
gen z=`z'
gen fitted_s=.
gen R2=.
gen fitted_s_small=.
gen R2_small=.
local r_window=60
local p=`date1'-`diff'-`r_window'
local q=`p'-1
disp "`q'"
gen obs=`p'+`r_window'
disp "`diff'""-""`z'""-""obs`obs'"
forvalues t=0/`q' {

sort t
quietly reg fd`diff'_s  `z' if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"  
quietly predict xb_reg if t==(1+`r_window'+`t')&currency=="`x'"
quietly replace fitted_s=xb_reg if t==(1+`r_window'+`t')&currency=="`x'"
quietly replace R2=e(r2_a) if t==(1+`r_window'+`t')&currency=="`x'"
quietly drop xb_reg

}

disp "-o-o-"

gen model_small_re_sq=(fd`diff'_s)^2 if s!=.&z!=.
gen model_big_re_sq=(fitted_s-fd`diff'_s)^2 if s!=.&z!=.
gen adj=(fitted_s)^2 if s!=.&z!=.
gen new_fhat=model_small_re_sq-(model_big_re_sq-adj) if s!=.&z!=.
**
gen CW_stat_reg=.

sort curr_id t
local lag_num=`diff'-1
newey new_fhat if currency=="`x'",lag(`lag_num')
gen CW_beta`x'=e(b)[1,1]
gen CW_se`x'=(e(V)[1,1])^(1/2)
replace CW_stat_reg=CW_beta`x'/CW_se`x' if currency=="`x'"

sort currency date
keep currency CW_stat_reg
collapse (mean) CW_stat_reg ,by (currency)
gen diff="`diff'"
gen macro_var="`z'"
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_`z'.dta",replace
restore
}
}
}



clear all 
// local diff=1
foreach diff in 1 3 12 24 {
foreach x in SA{
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_US_term_1.dta"
foreach z in TED US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield {
append using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_`z'.dta"
rm "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_`z'.dta"
}
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_all.dta",replace
}
}

clear all 
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_SA_d1_all.dta"
foreach diff in 3 12 24 {
append using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_SA_d`diff'_all.dta"
}
drop currency
replace macro_var = "Log VIX" if macro_var == "ln_vix_avg"
replace macro_var = "PRP" if macro_var == "epu_adj"
replace macro_var = "US Term spread (2y-FF)" if macro_var == "US_term_1"
replace macro_var = "US Term spread (10y-2y)" if macro_var == "US_term_2"
replace macro_var = "Convenience Yield/Liquidity Premium" if macro_var == "global_convenience_yield"
replace macro_var = "Inflows/GDP" if macro_var == "all_DB_inflow_IMF_GDP"
rename  macro_var Independent_variables
rename diff Horizon
rename CW_stat_reg EM_Expected
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//EM_Expected.dta",replace



* ---------------------------- EM_Expected

do "$path/UIP/vahid/empirics_alvaro/codes//00_table.do"
keep if NoPegSample == 1
keep if regsample == 1
keep if EM == 0
xtset id date
gen TED = f.lag_TEDRATE
gen FEDFUNDS = f.lag_FEDFUNDS
gen all_DB_inflow_IMF_GDP = f.all_DB_inflow_IMF_GDPi_lag
gen US_term_1 = i_treasury_24m_avg - FEDFUNDS
gen US_term_2 = i_treasury_10yr_avg - i_treasury_24m_avg


keep date id spotexr_avg TED US_term_1 US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield FXfcst_1m_consensus FXfcst_3m_consensus FXfcst_12m_consensus FXfcst_24m_consensus



gen FXfcst_1m = log(FXfcst_1m_consensus)
gen FXfcst_3m = log(FXfcst_3m_consensus)
gen FXfcst_12m = log(FXfcst_12m_consensus)
gen FXfcst_24m = log(FXfcst_24m_consensus)

bys id: egen mean_FXfcst_1m = mean(FXfcst_1m)
bys id: egen mean_FXfcst_3m = mean(FXfcst_3m)
bys id: egen mean_FXfcst_12m = mean(FXfcst_12m)
bys id: egen mean_FXfcst_24m = mean(FXfcst_24m)

gen expected_1 = FXfcst_1m - mean_FXfcst_1m
gen expected_3 = FXfcst_3m - mean_FXfcst_3m
gen expected_12 = FXfcst_12m - mean_FXfcst_12m
gen expected_24 = FXfcst_24m - mean_FXfcst_24m
drop FXfcst_1m_consensus FXfcst_3m_consensus FXfcst_12m_consensus FXfcst_24m_consensus
drop FXfcst_1m FXfcst_3m FXfcst_12m FXfcst_24m mean_FXfcst_1m mean_FXfcst_3m mean_FXfcst_12m mean_FXfcst_24m

gen exchange_rate = log(spotexr_avg)
bys id: egen mean = mean(exchange_rate)
gen s = exchange_rate - mean
drop mean exchange_rate spotexr_avg
collapse (mean) TED US_term_1 US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield s expected_1 expected_3 expected_12 expected_24,by(date)
gen t=[_n]
gen currency = "SA"

egen curr_id = group(currency)
xtset curr_id t

gen fd24_s=f24.expected_24-expected_24
gen fd12_s=f12.expected_12-expected_12
gen fd3_s=f3.expected_3-expected_3
gen fd1_s=f1.expected_1-expected_1


// local diff=1

foreach diff in 1 3 12 24 {
foreach x in SA{
foreach z in TED US_term_1 US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield{
preserve

local date1=264
drop if currency!="`x'"
gen z=`z'
gen fitted_s=.
gen R2=.
gen fitted_s_small=.
gen R2_small=.
local r_window=60
local p=`date1'-`diff'-`r_window'
local q=`p'-1
disp "`q'"
gen obs=`p'+`r_window'
disp "`diff'""-""`z'""-""obs`obs'"
forvalues t=0/`q' {

sort t
quietly reg fd`diff'_s  `z' if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"  
quietly predict xb_reg if t==(1+`r_window'+`t')&currency=="`x'"
quietly replace fitted_s=xb_reg if t==(1+`r_window'+`t')&currency=="`x'"
quietly replace R2=e(r2_a) if t==(1+`r_window'+`t')&currency=="`x'"
quietly drop xb_reg

}

disp "-o-o-"

gen model_small_re_sq=(fd`diff'_s)^2 if s!=.&z!=.
gen model_big_re_sq=(fitted_s-fd`diff'_s)^2 if s!=.&z!=.
gen adj=(fitted_s)^2 if s!=.&z!=.
gen new_fhat=model_small_re_sq-(model_big_re_sq-adj) if s!=.&z!=.
**
gen CW_stat_reg=.

sort curr_id t
local lag_num=`diff'-1
newey new_fhat if currency=="`x'",lag(`lag_num')
gen CW_beta`x'=e(b)[1,1]
gen CW_se`x'=(e(V)[1,1])^(1/2)
replace CW_stat_reg=CW_beta`x'/CW_se`x' if currency=="`x'"

sort currency date
keep currency CW_stat_reg
collapse (mean) CW_stat_reg ,by (currency)
gen diff="`diff'"
gen macro_var="`z'"
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_`z'.dta",replace
restore
}
}
}



clear all 
// local diff=1
foreach diff in 1 3 12 24 {
foreach x in SA{
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_US_term_1.dta"
foreach z in TED US_term_2 ln_vix_avg epu_adj all_DB_inflow_IMF_GDP global_convenience_yield {
append using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_`z'.dta"
rm "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_`z'.dta"
}
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_`x'_d`diff'_all.dta",replace
}
}

clear all 
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_SA_d1_all.dta"
foreach diff in 3 12 24 {
append using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//T2i_SA_d`diff'_all.dta"
}
drop currency
replace macro_var = "Log VIX" if macro_var == "ln_vix_avg"
replace macro_var = "PRP" if macro_var == "epu_adj"
replace macro_var = "US Term spread (2y-FF)" if macro_var == "US_term_1"
replace macro_var = "US Term spread (10y-2y)" if macro_var == "US_term_2"
replace macro_var = "Convenience Yield/Liquidity Premium" if macro_var == "global_convenience_yield"
replace macro_var = "Inflows/GDP" if macro_var == "all_DB_inflow_IMF_GDP"
rename  macro_var Independent_variables
rename diff Horizon
rename CW_stat_reg AE_Expected
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//AE_Expected.dta",replace




* ------------- merge all dta

clear all 
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//AE_Expected.dta"
merge 1:1 Horizon Independent_variables using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//EM_Expected.dta", nogen
merge 1:1 Horizon Independent_variables using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//AE_Realized.dta", nogen
merge 1:1 Horizon Independent_variables using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//EM_Realized.dta", nogen

export delimited using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/results//RW_outsample.csv", replace




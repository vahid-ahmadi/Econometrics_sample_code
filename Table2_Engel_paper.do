*Engel and Wu: Forecasting the U.S. Dollar in the 21st Century (Journal of International Economics)




*to reproduce the results, change the global path line below to correctly specify the folder path

// global path "/Users/janansadeqian/Library/CloudStorage/Dropbox/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package"

global path "/Users/janansadeqian/Library/CloudStorage/Dropbox"



*****JIE table 2

***********fd60

****(i) Risk factor compared to rw, h=60
clear all
set matsize 11000
cd "$path"
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Data/data_replication.dta"
***********regressions!

rename WeightedAverage WA
rename etaWA etaSA
gen t=[_n]
drop ITL FRF
gen group=0
replace group=1 if Month==1|Month==2|Month==12
replace group=2 if Month==4|Month==5|Month==3
replace group=3 if Month==7|Month==8|Month==6
replace group=4 if Month==10|Month==11|Month==9
gen group_year=Year
replace group_year=Year-1 if Month==1|Month==2
gen CPI_AUD_q=CPI_AUD
gen CPI_NZD_q=CPI_NZD
drop CPI_AUD CPI_NZD
gen group_date=yq(group_year,group)
bys group_date: egen CPI_AUD=mean(CPI_AUD_q)
bys group_date: egen CPI_NZD=mean(CPI_NZD_q)
drop if t<236
drop if t>490

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
gen q_`x'=`x'-log(CPI_USD)+log(CPI_`x')
}

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
egen mean_`x'=mean(`x')
}
foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
gen dmean_`x'=`x'-mean_`x'
}

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
egen mean_q_`x'=mean(q_`x')
}
foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
gen dmean_q_`x'=q_`x'-mean_q_`x'
}
gen SA=(dmean_AUD+dmean_CAD+dmean_CHF+dmean_DEM+dmean_GBP+dmean_JPY+dmean_NOK+dmean_NZD+dmean_SEK)/9
gen q_SA=(dmean_q_AUD+dmean_q_CAD+dmean_q_CHF+dmean_q_DEM+dmean_q_GBP+dmean_q_JPY+dmean_q_NOK+dmean_q_NZD+dmean_q_SEK)/9

rename intermediary_capital_ratio I_cap_ratio
rename intermediary_capital_risk_factor I_cap_risk_factor
rename intermediary_value_weighted_inve I_cap_return
rename intermediary_leverage_ratio_squa I_cap_ratio_sqr
*detrend Adrian Etula Shin series
gen ln_ComPaper=ln(ComPaper) 
gen ln_Repo=ln(Repo)
regress ln_ComPaper t
predict linear_ComPaper , re 
regress ln_Repo t
predict linear_Repo , re 

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK SA {
rename `x' s_`x'
}

tsset t
foreach x in SP_500 VXO VIX {
gen ln_`x'=ln(`x')
gen lnR_`x'=ln_`x'-l1.ln_`x'
}
regress ln_SP_500 t if t>=236
predict linear_SP_500 if t>=236, re 

drop if t<200
reshape long s_, i(qdate) j(currency) string
egen curr_id=group (currency)
xtset curr_id t
rename s_ s

gen fd60_s=f60.s-s
gen fd36_s=f36.s-s
gen fd12_s=f12.s-s
gen fd1_s=f1.s-s

local diff=60
*
foreach x in SA{
foreach z in q_`x' eta`x'  GF_MAR GZ_spr2 PDratio ln_VIX Tspr_5mFF Tspr_10m2 TED I_cap_ratio I_cap_return linear_Repo linear_ComPaper s {
preserve

if "`z'"=="linear_ComPaper" {

	local date1=255 - 24
	local date2=235 + 24
	local date3=`date2'+1

}
else if "`z'"=="linear_Repo" {
	local date1=255 - 7
	local date2=235 + 7
	local date3=`date2'+1
} 
else {
	local date1=255
	local date2=235
	local date3=`date2'+1
}

drop if currency!="`x'"
drop if t<`date3'
replace t=t-`date2'
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
**disp "`t'"

if "`z'"=="linear_ComPaper" {
	drop linear_ComPaper
	quietly regress ln_ComPaper t if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"
	quietly predict linear_ComPaper if (t>=1+`t')&(t<=1+`r_window'+`t')&currency=="`x'", re 
}
else if "`z'"=="linear_Repo" {
	drop linear_Repo
	quietly regress ln_Repo t if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"
	quietly predict linear_Repo if (t>=1+`t')&(t<=1+`r_window'+`t')&currency=="`x'", re 
} 
else if "`z'"=="linear_SP_500" {
	drop linear_SP_500
	quietly regress ln_SP_500 t if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"
	quietly predict linear_SP_500 if (t>=1+`t')&(t<=1+`r_window'+`t')&currency=="`x'", re 
} 
else {
}


sort t
quietly reg fd`diff'_s  `z' if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"  
*quietly   reg d_s q d_eta  d_i_diff  eta i_diff dummyc1-dummyc8  if t>=133&(t<=(`t'-1))&Country2=="`x'" 
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

sort currency qdate
keep currency CW_stat_reg
collapse (mean) CW_stat_reg ,by (currency)
gen diff="`diff'"
gen macro_var="`z'"
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_`z'.dta",replace
restore
}
}

*combine files
clear all 
local diff=60
foreach x in SA{
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_q_`x'.dta"
foreach z in  eta`x'  GF_MAR GZ_spr2 PDratio ln_VIX Tspr_5mFF Tspr_10m2 TED I_cap_ratio I_cap_return linear_Repo linear_ComPaper s{
append using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_`z'.dta"
rm "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_`z'.dta"
}
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_all.dta",replace
}


****************fd36
****(i) Risk factor compared to rw, h=36
clear all
set matsize 11000
cd "$path"
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Data/data_replication.dta"
***********regressions!

rename WeightedAverage WA
rename etaWA etaSA
gen t=[_n]
drop ITL FRF
gen group=0
replace group=1 if Month==1|Month==2|Month==12
replace group=2 if Month==4|Month==5|Month==3
replace group=3 if Month==7|Month==8|Month==6
replace group=4 if Month==10|Month==11|Month==9
gen group_year=Year
replace group_year=Year-1 if Month==1|Month==2
gen CPI_AUD_q=CPI_AUD
gen CPI_NZD_q=CPI_NZD
drop CPI_AUD CPI_NZD
gen group_date=yq(group_year,group)
bys group_date: egen CPI_AUD=mean(CPI_AUD_q)
bys group_date: egen CPI_NZD=mean(CPI_NZD_q)
drop if t<236
drop if t>490

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
gen q_`x'=`x'-log(CPI_USD)+log(CPI_`x')
}

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
egen mean_`x'=mean(`x')
}
foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
gen dmean_`x'=`x'-mean_`x'
}

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
egen mean_q_`x'=mean(q_`x')
}
foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
gen dmean_q_`x'=q_`x'-mean_q_`x'
}
gen SA=(dmean_AUD+dmean_CAD+dmean_CHF+dmean_DEM+dmean_GBP+dmean_JPY+dmean_NOK+dmean_NZD+dmean_SEK)/9
gen q_SA=(dmean_q_AUD+dmean_q_CAD+dmean_q_CHF+dmean_q_DEM+dmean_q_GBP+dmean_q_JPY+dmean_q_NOK+dmean_q_NZD+dmean_q_SEK)/9

rename intermediary_capital_ratio I_cap_ratio
rename intermediary_capital_risk_factor I_cap_risk_factor
rename intermediary_value_weighted_inve I_cap_return
rename intermediary_leverage_ratio_squa I_cap_ratio_sqr
*detrend Adrian Etula Shin series
gen ln_ComPaper=ln(ComPaper) 
gen ln_Repo=ln(Repo)
regress ln_ComPaper t
predict linear_ComPaper , re 
regress ln_Repo t
predict linear_Repo , re 

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK SA {
rename `x' s_`x'
}

tsset t
foreach x in SP_500 VXO VIX {
gen ln_`x'=ln(`x')
gen lnR_`x'=ln_`x'-l1.ln_`x'
}
regress ln_SP_500 t if t>=236
predict linear_SP_500 if t>=236, re 

drop if t<200
reshape long s_, i(qdate) j(currency) string
egen curr_id=group (currency)
xtset curr_id t
rename s_ s

gen fd60_s=f60.s-s
gen fd36_s=f36.s-s
gen fd12_s=f12.s-s
gen fd1_s=f1.s-s

local diff=36
*
foreach x in SA{
foreach z in q_`x' eta`x'  GF_MAR GZ_spr2 PDratio ln_VIX Tspr_5mFF Tspr_10m2 TED I_cap_ratio I_cap_return linear_Repo linear_ComPaper s {
preserve

if "`z'"=="linear_ComPaper" {

	local date1=255 - 24
	local date2=235 + 24
	local date3=`date2'+1

}
else if "`z'"=="linear_Repo" {
	local date1=255 - 7
	local date2=235 + 7
	local date3=`date2'+1
} 
else if "`z'"=="eta`x'" {

	local date1=255 - 26
	local date2=235 + 26
	local date3=`date2'+1
}
else {
	local date1=255
	local date2=235
	local date3=`date2'+1
}

drop if currency!="`x'"
drop if t<`date3'
replace t=t-`date2'
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
**disp "`t'"

if "`z'"=="linear_ComPaper" {
	drop linear_ComPaper
	quietly regress ln_ComPaper t if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"
	quietly predict linear_ComPaper if (t>=1+`t')&(t<=1+`r_window'+`t')&currency=="`x'", re 
}
else if "`z'"=="linear_Repo" {
	drop linear_Repo
	quietly regress ln_Repo t if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"
	quietly predict linear_Repo if (t>=1+`t')&(t<=1+`r_window'+`t')&currency=="`x'", re 
} 
else if "`z'"=="linear_SP_500" {
	drop linear_SP_500
	quietly regress ln_SP_500 t if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"
	quietly predict linear_SP_500 if (t>=1+`t')&(t<=1+`r_window'+`t')&currency=="`x'", re 
} 
else {
}


sort t
quietly reg fd`diff'_s  `z' if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"  
*quietly   reg d_s q d_eta  d_i_diff  eta i_diff dummyc1-dummyc8  if t>=133&(t<=(`t'-1))&Country2=="`x'" 
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

sort currency qdate
keep currency CW_stat_reg
collapse (mean) CW_stat_reg ,by (currency)
gen diff="`diff'"
gen macro_var="`z'"
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_`z'.dta",replace
restore
}
}

*combine files
clear all 
local diff=36
foreach x in SA{
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_q_`x'.dta"
foreach z in  eta`x'  GF_MAR GZ_spr2 PDratio ln_VIX Tspr_5mFF Tspr_10m2 TED I_cap_ratio I_cap_return linear_Repo linear_ComPaper s{
append using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_`z'.dta"
rm "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_`z'.dta"
}
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_all.dta",replace
}


****************fd12

****(i) Risk factor compared to rw, h=12
clear all
set matsize 11000
cd "$path"
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Data/data_replication.dta"
***********regressions!

rename WeightedAverage WA
rename etaWA etaSA
gen t=[_n]
drop ITL FRF
gen group=0
replace group=1 if Month==1|Month==2|Month==12
replace group=2 if Month==4|Month==5|Month==3
replace group=3 if Month==7|Month==8|Month==6
replace group=4 if Month==10|Month==11|Month==9
gen group_year=Year
replace group_year=Year-1 if Month==1|Month==2
gen CPI_AUD_q=CPI_AUD
gen CPI_NZD_q=CPI_NZD
drop CPI_AUD CPI_NZD
gen group_date=yq(group_year,group)
bys group_date: egen CPI_AUD=mean(CPI_AUD_q)
bys group_date: egen CPI_NZD=mean(CPI_NZD_q)
drop if t<236
drop if t>490

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
gen q_`x'=`x'-log(CPI_USD)+log(CPI_`x')
}

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
egen mean_`x'=mean(`x')
}
foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
gen dmean_`x'=`x'-mean_`x'
}

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
egen mean_q_`x'=mean(q_`x')
}
foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
gen dmean_q_`x'=q_`x'-mean_q_`x'
}
gen SA=(dmean_AUD+dmean_CAD+dmean_CHF+dmean_DEM+dmean_GBP+dmean_JPY+dmean_NOK+dmean_NZD+dmean_SEK)/9
gen q_SA=(dmean_q_AUD+dmean_q_CAD+dmean_q_CHF+dmean_q_DEM+dmean_q_GBP+dmean_q_JPY+dmean_q_NOK+dmean_q_NZD+dmean_q_SEK)/9

rename intermediary_capital_ratio I_cap_ratio
rename intermediary_capital_risk_factor I_cap_risk_factor
rename intermediary_value_weighted_inve I_cap_return
rename intermediary_leverage_ratio_squa I_cap_ratio_sqr
*detrend Adrian Etula Shin series
gen ln_ComPaper=ln(ComPaper) 
gen ln_Repo=ln(Repo)
regress ln_ComPaper t
predict linear_ComPaper , re 
regress ln_Repo t
predict linear_Repo , re 

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK SA {
rename `x' s_`x'
}

tsset t
foreach x in SP_500 VXO VIX {
gen ln_`x'=ln(`x')
gen lnR_`x'=ln_`x'-l1.ln_`x'
}
regress ln_SP_500 t if t>=236
predict linear_SP_500 if t>=236, re 

drop if t<200
reshape long s_, i(qdate) j(currency) string
egen curr_id=group (currency)
xtset curr_id t
rename s_ s

gen fd60_s=f60.s-s
gen fd36_s=f36.s-s
gen fd12_s=f12.s-s
gen fd1_s=f1.s-s

local diff=12
*
foreach x in SA{
foreach z in q_`x' eta`x'  GF_MAR GZ_spr2 PDratio ln_VIX Tspr_5mFF Tspr_10m2 TED I_cap_ratio I_cap_return linear_Repo linear_ComPaper s {
preserve

if "`z'"=="linear_ComPaper" {

	local date1=255 - 24
	local date2=235 + 24
	local date3=`date2'+1

}
else if "`z'"=="linear_Repo" {
	local date1=255 - 7
	local date2=235 + 7
	local date3=`date2'+1
} 
else if "`z'"=="eta`x'" {

	local date1=255 - 26
	local date2=235
	local date3=`date2'+1
}
else {
	local date1=255
	local date2=235
	local date3=`date2'+1
}

drop if currency!="`x'"
drop if t<`date3'
replace t=t-`date2'
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
**disp "`t'"

if "`z'"=="linear_ComPaper" {
	drop linear_ComPaper
	quietly regress ln_ComPaper t if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"
	quietly predict linear_ComPaper if (t>=1+`t')&(t<=1+`r_window'+`t')&currency=="`x'", re 
}
else if "`z'"=="linear_Repo" {
	drop linear_Repo
	quietly regress ln_Repo t if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"
	quietly predict linear_Repo if (t>=1+`t')&(t<=1+`r_window'+`t')&currency=="`x'", re 
} 
else if "`z'"=="linear_SP_500" {
	drop linear_SP_500
	quietly regress ln_SP_500 t if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"
	quietly predict linear_SP_500 if (t>=1+`t')&(t<=1+`r_window'+`t')&currency=="`x'", re 
} 
else {
}


sort t
quietly reg fd`diff'_s  `z' if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"  
*quietly   reg d_s q d_eta  d_i_diff  eta i_diff dummyc1-dummyc8  if t>=133&(t<=(`t'-1))&Country2=="`x'" 
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

sort currency qdate
keep currency CW_stat_reg
collapse (mean) CW_stat_reg ,by (currency)
gen diff="`diff'"
gen macro_var="`z'"
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_`z'.dta",replace
restore
}
}

*combine files
clear all 
local diff=12
foreach x in SA{
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_q_`x'.dta"
foreach z in  eta`x'  GF_MAR GZ_spr2 PDratio ln_VIX Tspr_5mFF Tspr_10m2 TED I_cap_ratio I_cap_return linear_Repo linear_ComPaper s{
append using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_`z'.dta"
rm "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_`z'.dta"
}
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_all.dta",replace
}


****(i) Risk factor compared to rw, h=1
clear all
set matsize 11000
cd "$path"
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Data/data_replication.dta"
***********regressions!

rename WeightedAverage WA
rename etaWA etaSA
gen t=[_n]
drop ITL FRF
gen group=0
replace group=1 if Month==1|Month==2|Month==12
replace group=2 if Month==4|Month==5|Month==3
replace group=3 if Month==7|Month==8|Month==6
replace group=4 if Month==10|Month==11|Month==9
gen group_year=Year
replace group_year=Year-1 if Month==1|Month==2
gen CPI_AUD_q=CPI_AUD
gen CPI_NZD_q=CPI_NZD
drop CPI_AUD CPI_NZD
gen group_date=yq(group_year,group)
bys group_date: egen CPI_AUD=mean(CPI_AUD_q)
bys group_date: egen CPI_NZD=mean(CPI_NZD_q)
drop if t<236
drop if t>490

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
gen q_`x'=`x'-log(CPI_USD)+log(CPI_`x')
}

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
egen mean_`x'=mean(`x')
}
foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
gen dmean_`x'=`x'-mean_`x'
}

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
egen mean_q_`x'=mean(q_`x')
}
foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK{
gen dmean_q_`x'=q_`x'-mean_q_`x'
}
gen SA=(dmean_AUD+dmean_CAD+dmean_CHF+dmean_DEM+dmean_GBP+dmean_JPY+dmean_NOK+dmean_NZD+dmean_SEK)/9
gen q_SA=(dmean_q_AUD+dmean_q_CAD+dmean_q_CHF+dmean_q_DEM+dmean_q_GBP+dmean_q_JPY+dmean_q_NOK+dmean_q_NZD+dmean_q_SEK)/9

rename intermediary_capital_ratio I_cap_ratio
rename intermediary_capital_risk_factor I_cap_risk_factor
rename intermediary_value_weighted_inve I_cap_return
rename intermediary_leverage_ratio_squa I_cap_ratio_sqr
*detrend Adrian Etula Shin series
gen ln_ComPaper=ln(ComPaper) 
gen ln_Repo=ln(Repo)
regress ln_ComPaper t
predict linear_ComPaper , re 
regress ln_Repo t
predict linear_Repo , re 

foreach x in AUD CAD CHF DEM GBP JPY NOK NZD SEK SA {
rename `x' s_`x'
}

tsset t
foreach x in SP_500 VXO VIX {
gen ln_`x'=ln(`x')
gen lnR_`x'=ln_`x'-l1.ln_`x'
}
regress ln_SP_500 t if t>=236
predict linear_SP_500 if t>=236, re 

drop if t<200
reshape long s_, i(qdate) j(currency) string
egen curr_id=group (currency)
xtset curr_id t
rename s_ s

gen fd60_s=f60.s-s
gen fd36_s=f36.s-s
gen fd12_s=f12.s-s
gen fd1_s=f1.s-s

local diff=1
*
foreach x in SA{
foreach z in q_`x' eta`x'  GF_MAR GZ_spr2 PDratio ln_VIX Tspr_5mFF Tspr_10m2 TED I_cap_ratio I_cap_return linear_Repo linear_ComPaper s {
preserve

if "`z'"=="linear_ComPaper" {

	local date1=255 - 24
	local date2=235 + 24
	local date3=`date2'+1

}
else if "`z'"=="linear_Repo" {
	local date1=255 - 8
	local date2=235 + 7
	local date3=`date2'+1
} 
else if "`z'"=="GF_MAR" {

	local date1=255 - 25
	local date2=235 
	local date3=`date2'+1
}
else if "`z'"=="eta`x'" {

	local date1=255 - 10
	local date2=235 
	local date3=`date2'+1
}
else if "`z'"=="I_cap_ratio" {

	local date1=255 - 15
	local date2=235 
	local date3=`date2'+1
}
else if "`z'"=="I_cap_return" {

	local date1=255 - 15
	local date2=235 
	local date3=`date2'+1
}
else {
	local date1=255
	local date2=235
	local date3=`date2'+1
}

drop if currency!="`x'"
drop if t<`date3'
replace t=t-`date2'
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
**disp "`t'"

if "`z'"=="linear_ComPaper" {
	drop linear_ComPaper
	quietly regress ln_ComPaper t if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"
	quietly predict linear_ComPaper if (t>=1+`t')&(t<=1+`r_window'+`t')&currency=="`x'", re 
}
else if "`z'"=="linear_Repo" {
	drop linear_Repo
	quietly regress ln_Repo t if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"
	quietly predict linear_Repo if (t>=1+`t')&(t<=1+`r_window'+`t')&currency=="`x'", re 
} 
else if "`z'"=="linear_SP_500" {
	drop linear_SP_500
	quietly regress ln_SP_500 t if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"
	quietly predict linear_SP_500 if (t>=1+`t')&(t<=1+`r_window'+`t')&currency=="`x'", re 
} 
else {
}


sort t
quietly reg fd`diff'_s  `z' if (t>=1+`t')&(t<=`r_window'+`t')&currency=="`x'"  
*quietly   reg d_s q d_eta  d_i_diff  eta i_diff dummyc1-dummyc8  if t>=133&(t<=(`t'-1))&Country2=="`x'" 
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

sort currency qdate
keep currency CW_stat_reg
collapse (mean) CW_stat_reg ,by (currency)
gen diff="`diff'"
gen macro_var="`z'"
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_`z'.dta",replace
restore
}
}

*combine files
clear all 
local diff=1
foreach x in SA{
use "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_q_`x'.dta"
foreach z in  eta`x'  GF_MAR GZ_spr2 PDratio ln_VIX Tspr_5mFF Tspr_10m2 TED I_cap_ratio I_cap_return linear_Repo linear_ComPaper s{
append using "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_`z'.dta"
rm "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_`z'.dta"
}
save "$path/UIP/vahid/empirics_alvaro/codes/Random_walk/JIE_replication_package/Result_storage//T2i_`x'_d`diff'_all.dta",replace
}

/*empirical analysis*/
/*Author: Masanori Matsuura*/
clear all
set more off
* Install reghdfe
cap ado uninstall reghdfe
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")
* Install ftools (remove program if it existed previously)
cap ado uninstall ftools
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")
* Install ivreg2, the core package
cap ado uninstall ivreg2
ssc install ivreg2

* Finally, install this package
cap ado uninstall ivreghdfe
net install ivreghdfe, from(https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/)

ssc install ranktest

*set the pathes
global climate = "C:\Users\user\Documents\Masterthesis\climatebang"
global BIHS18Community = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2018\dataverse_files\BIHSRound3\Community"
global BIHS18Female = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2018\dataverse_files\BIHSRound3\Female"
global BIHS18Male = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2018\dataverse_files\BIHSRound3\Male"
global BIHS15 = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2015"
global BIHS12 = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2012"
global table = "C:\Users\user\Documents\Masterthesis\NTUtemplate\table"
global figure = "C:\Users\user\Documents\Masterthesis\NTUtemplate\figures"
cd "C:\Users\user\Documents\Masterthesis\BIHS\Do"
use panel.dta, clear 
/*creating a panel dataset*/
use 2015.dta, clear
append using 2012.dta, force
append using 2018.dta, force
drop if dvcode==.


/*some cleaning*/
gen lnfrm=log(farmsize) // logarithem of farm size 100 decimal = 0.4 ha
label var lnfrm "Farmsize (log)"
recode year (2012=1)(nonm=0), gen(year2012) //year dummy
recode year (2015=1)(nonm=0), gen(year2015)
label var year2012 "Year 2012"
label var year2015 "Year 2015"
recode dvcode (55=1)(nonm=0), gen(Rangpur) //division dummy
label var Rangpur "Rangpur division (dummy)"
label var ttinc "Total yearly income (taka)"
gen ttinc10000=ttinc/10000
label var ttinc10000 "Total yearly income (10,000taka)"
gen lninc=log(ttinc)
label var lninc "Total yearly income (log)"

/*gen rinmn2=rinmn_1000*rinmn_1000
label var rinmn2 "Squared yearly mean rainfall"
gen lnrinmn2=log(rinmn2)
gen tmpmn2=tmpmn*tmpmn
label var tmpmn2 "Squared monthly mean temperature"
gen lntmpmn2=log(tmpmn2)*/
label var frmdiv "Farm diversification (Num of species of crop, livestocks, and fish)" 
label var frm_div "Farm diversification index"

*create peer effect variables
sort uncode year
by uncode year: egen adaptation_n=count(a01) if frmdiv>1
by uncode year: egen total_n=count(a01)
gen preff_frmdiv=(adaptation_n-1)/total_n //creating peer effect
sort uncode year
by uncode year: egen adaptation_nf=count(a01) if 1>frm_div>0
by uncode year: egen total_nf=count(a01)
gen preff_frm_div=(adaptation_nf-1)/total_nf //creating peer effect
sort uncode year
by uncode year: egen adaptation_nc=count(a01) if crp_div>0
by uncode year: egen total_nc=count(a01)
gen preff_crpdiv=(adaptation_nc-1)/total_nc //creating peer effect
sort uncode year
by uncode year: egen adaptation_ni=count(a01) if inc_div>0
by uncode year: egen total_ni=count(a01)
gen preff_incdiv=(adaptation_ni-1)/total_ni //creating peer effect

label var preff_crpdiv "share of crop diversification household within the union"
label var preff_frmdiv "share of farm diversification household within the union"
label var preff_frm_div "share of farm diversification household within the union"
label var preff_incdiv "share of income diversification household within the union"
replace frm_div=. if frm_div==1
replace inc_div=. if inc_div==1


*create interaction term
gen ln_wet=ln_twet*ln_rwet
gen ln_dry=ln_tdry*ln_rdry
*create log hdds and expenditure
gen lnhdds=log(hdds)
gen lnexp=log(pc_expm_d)
gen lnfexp=log(pc_foodxm_d)



*label market participation variable
label var marketp "Market participation (=1 if yes)"
save panel.dta, replace

export delimited using panel.csv, replace //output as csv


**poisson with control function fixed effect HDDS
xtset a01 year

reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015  if frm_div<1, absorb(a01) vce(robust) res //first stage
predict double v2h_fe, r
xtpoisson hdds frm_div v2h_fe ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015  if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv
drop v2h_fe

*ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw
reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh  lnfrm marketp market road irrigation year2012 year2015, vce(r) absorb(a01) res //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, r
xtpoisson hdds inc_div v2h_fe ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh  lnfrm marketp market road irrigation year2012 year2015, fe vce(r) //second stage
drop v2h_fe 


**2SRI fixed effect household food consumption expenditure

reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe, r
reghdfe lnfexp frm_div v2h_fe ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
drop v2h_fe

/*reghdfe frmdiv preff_frmdiv ln_rwet ln_rdry ln_tdry ln_twet  Male age_hh hh_size schll_hh lnfrm marketp irrigation i.year if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe, r
reghdfe lnfexp frmdiv v2h_fe ln_rwet ln_rdry ln_tdry ln_twet   Male age_hh hh_size schll_hh lnfrm marketp irrigation i.year if frm_div<1, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
drop v2h_fe*/

reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 , vce(r) absorb(a01) res //first stage
predict double v2h_fe, r
reghdfe lnfexp inc_div v2h_fe ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw   Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 , absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
drop v2h_fe

**weak IV
ivreghdfe lnfexp ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 (frm_div=preff_frm_div) if frm_div<1, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure

ivreghdfe lnfexp ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 (inc_div=preff_incdiv) if inc_div<1, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure

/*reg lnfexp inc_div ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta   Male age_hh hh_size schll_hh  lnfrm marketp irrigation year2012 year2015 if inc_div<1, vce(r) 
reg lnfexp frm_div ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm marketp irrigation year2012 year2015 if frm_div<1,vce(r) //robustness check
*/
**heterogeneous analysis
xtile quanths = farmsize, nq(4)
tab quanths, gen(q)
gen incq1=inc_div*q1
gen incq2=inc_div*q2
gen incq3=inc_div*q3
gen incq4=inc_div*q4
gen frmq1=frm_div*q1
gen frmq2=frm_div*q2
gen frmq3=frm_div*q3
gen frmq4=frm_div*q4

gen pincq1=preff_incdiv*q1
gen pincq2=preff_incdiv*q2
gen pincq3=preff_incdiv*q3
gen pincq4=preff_incdiv*q4
gen pfrmq1=preff_frm_div*q1
gen pfrmq2=preff_frm_div*q2
gen pfrmq3=preff_frm_div*q3
gen pfrmq4=preff_frm_div*q4

*1st stage frm q
reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe, r
reghdfe frmq2 pfrmq2 ln_rwet ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe2, r
reghdfe frmq3 pfrmq3 ln_rwet ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe3, r
reghdfe frmq4 pfrmq4 ln_rwet ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe4, r
**hdds frm q
xtpoisson hdds frm_div frmq2 frmq3 frmq4 q2 q3 q4 v2h_fe v2h_fe2 v2h_fe3 v2h_fe4 ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, fe vce(r) //hdds

**lnfexp frm q
reghdfe lnfexp frm_div frmq2 frmq3 frmq4 q2 q3 q4 v2h_fe v2h_fe2 v2h_fe3 v2h_fe4 ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, absorb(a01) vce(r) 
drop v2h_fe v2h_fe2 v2h_fe3 v2h_fe4


*1st stage inc
reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe, r
reghdfe incq2 pincq2 ln_rwet ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe2, r
reghdfe incq3 pincq3 ln_rwet ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe3, r
reghdfe incq4 pincq4 ln_rwet ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe4, r

**hdds inc q
xtpoisson hdds inc_div incq2 incq3 incq4 q2 q3 q4 v2h_fe v2h_fe2 v2h_fe3 v2h_fe4 ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 , fe vce(r) 
**lnfexp inc q
reghdfe lnfexp inc_div incq2 incq3 incq4 q2 q3 q4 v2h_fe v2h_fe2 v2h_fe3 v2h_fe4 ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 , absorb(a01) vce(r) 
drop v2h_fe v2h_fe2 v2h_fe3 v2h_fe4



/*output*/
**Descriptive statistics
eststo clear
sort year
by year: eststo: quietly estpost summarize hdds pc_foodxm_d frm_div inc_div  preff_frm_div preff_incdiv rw rs rr ra tw ts tr ta Male age_hh hh_size schll_hh farmsize marketp market road extension irrigation, listwise

esttab using $table\dessta.tex, cells("mean(fmt(2)) sd(fmt(2))") label nodepvar replace addnote(Source: Bangladesh Integrated Household Survey 2011/12, 2015, 2018/19, 100 decimal is 0.4 ha, currency is Bangladesh taka)

**histgram of crop diversification index
twoway (kdensity crp_div if year==2012, color("blue%50"))(kdensity crp_div if year==2015, color("purple%50"))(kdensity crp_div if year==2018, color("red%50")), title(Crop diversificatioin index ) xtitle(Crop diversification index) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(2 "2012" 1 "2015" 3 "2018")) //hist of crop diversification index
graph display, scheme(s1mono)
graph export $figure\crpdiv.pdf, replace

**histgram of income diversification index
twoway (kdensity inc_div if year==2012, color("blue%50"))(kdensity inc_div if year==2015, color("purple%50"))(kdensity inc_div if year==2018, color("red%50")), title(Income diversificatioin index ) xtitle(Income diversification index) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(2 "2012" 1 "2015" 3 "2018")) //hist of inc diversification index
graph display, scheme(s1mono)
graph export $figure\incdiv.pdf, replace

**histgram of farm diversification index
twoway (kdensity frm_div if year==2012, color("blue%50"))(kdensity frm_div if year==2015, color("purple%50"))(kdensity frm_div if year==2018, color("red%50")), title(Farm diversificatioin) xtitle(Farm diversification) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(2 "2012" 1 "2015" 3 "2018")) //hist of inc diversification index
graph display, scheme(s1mono)
graph export $figure\frm_div.pdf, replace

**first stage estimation
*first stage
eststo clear
xtset a01 year


/*eststo: xtreg frmdiv preff_frmdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, vce(r) fe //first stage
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace*/

eststo: reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015  if frm_div<1, absorb(a01) vce(robust) res 

quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo: reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 , vce(r) absorb(a01) res //first stage
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

esttab using $table\ffe_manu.tex,  b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order("\textbf{Peer effect}"  preff_frm_div preff_incdiv "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw "\textbf{Control variables}" Male age_hh hh_size schll_hh lnfrm irrigation marketp market road extension year2012 year2015) mtitles("Farm diversification" "Income diversification") r2 

esttab using $table\ffe.tex,  b(%4.3f) se replace wide nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep("\textbf{Peer Effect}" preff_frm_div preff_incdiv "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw) order("\textbf{Peer Effect}"  preff_frm_div preff_incdiv "\textbf{Climate variables}"ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw) s(fe year control F N, label("HH FE" "Year dummy" "Control Variables" "F statistic" "Observations")) mtitles("Farm diversification " "Income diversification ")

*second stage analysis*
eststo clear
xtset a01 year

/*xtreg frmdiv preff_frmdiv ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, vce(r) fe //first stage
predict double v2h_fe, e
eststo: xtpoisson hdds frmdiv v2h_fe  ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, fe vce(r) //second stage  idcrp idliv idi_crp_liv
drop v2h_fe
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace
quietly estadd local control Yes, replace*/

reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe, r
eststo: xtpoisson hdds frm_div v2h_fe ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv
drop v2h_fe
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace
quietly estadd local control Yes, replace

reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 , vce(r) absorb(a01) res //first stage
predict double v2h_fe, r
eststo: xtpoisson hdds inc_div  v2h_fe ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw   Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015, fe vce(r) //second stage 
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
label var v2h_fe "Residual"
drop v2h_fe 

reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe, r
eststo: reghdfe lnfexp frm_div v2h_fe ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure

label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 

reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe, r
eststo: reghdfe lnfexp inc_div v2h_fe ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 if inc_div<1, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace


esttab using $table\scnd.tex,  b(%4.3f) se replace nodepvar nogaps wide starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( "\textbf{Diversification}"  frm_div inc_div  "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw ) order("\textbf{Diversification}"  frm_div inc_div   "\textbf{Climate variables}" ln_rw ln_rwet ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw) s(fe year control N, label("HH FE" "Year dummy" "Control Variables" "Observations")) addnote("Instrumental variables (\% of diversification within unions)")  mgroups("HDDS" "Per capita food expenditure (log)" , pattern(1 0 1 0))


esttab using $table\scnd_manu.tex,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order( "\textbf{Diversification}" frm_div inc_div  "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw "\textbf{Control variables}" Male age_hh hh_size schll_hh lnfrm  marketp market road extension irrigation year2012 year2015 v2h_fe) addnote("Instrumental variables  (\% of diversification household within unions)") n mgroups("HDDS" "Per capita food expenditure (log)" , pattern(1 0 1 0))

drop v2h_fe 



**heterogeneous impact of livelihood diversification on food secuirty
eststo clear
xtset a01 year
*1st stage frm q
reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe, r
reghdfe frmq2 pfrmq2 ln_rwet ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe2, r
reghdfe frmq3 pfrmq3 ln_rwet ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe3, r
reghdfe frmq4 pfrmq4 ln_rwet ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe4, r
**hdds frm q
eststo: xtpoisson hdds frm_div frmq2 frmq3 frmq4 q2 q3 q4 v2h_fe v2h_fe2 v2h_fe3 v2h_fe4 ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, fe vce(r) //hdds
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
**lnfexp frm q
eststo: reghdfe lnfexp frm_div frmq2 frmq3 frmq4 q2 q3 q4 v2h_fe v2h_fe2 v2h_fe3 v2h_fe4 ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, absorb(a01) vce(r) 
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

drop v2h_fe v2h_fe2 v2h_fe3 v2h_fe4


*1st stage inc
reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe, r
reghdfe incq2 pincq2 ln_rwet ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe2, r
reghdfe incq3 pincq3 ln_rwet ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe3, r
reghdfe incq4 pincq4 ln_rwet ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fe4, r

**hdds inc q
eststo: xtpoisson hdds inc_div incq2 incq3 incq4 q2 q3 q4 v2h_fe v2h_fe2 v2h_fe3 v2h_fe4 ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 , fe vce(r) 
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
**lnfexp inc q
eststo: reghdfe lnfexp inc_div incq2 incq3 incq4 q2 q3 q4 v2h_fe v2h_fe2 v2h_fe3 v2h_fe4 ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 , absorb(a01) vce(r) 
label var v2h_fe "Residual"
drop v2h_fe v2h_fe2 v2h_fe3 v2h_fe4
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace


esttab using $table\scnd_manu_hetero.tex,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( frm_div inc_div frmq2 frmq3 frmq4 incq2 incq3 incq4 q2 q3 q4  ) order( frm_div inc_div frmq2 frmq3 frmq4 incq2 incq3 incq4 q2 q3 q4) s(climate fe year control N, label("Climate variables" "HH FE" "Year dummy" "Control Variables" "Observations")) addnote("Instrumental variables (share of diversification household within unions and their interaction with a quartile of farmland size, which is exogenous in the model)")  mgroups("HDDS" "Per capita food expenditure (log)" , pattern(1 0 1 0))
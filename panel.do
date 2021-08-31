/*empirical analysis*/
/*Author: Masanori Matsuura*/
clear all
set more off
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
/*create binary adoption
recode frmdiv (1=0 "No")(2/max=1 "Yes"), gen(frmdivadp)
label var frmdivadp "Farm diversification"*/

*create interaction term
gen cr=crp_div*ln_rr
gen csd=crp_div*ln_rinsd
gen ir=inc_div*ln_rr
gen fr=frmdiv*ln_rr
gen isd=inc_div*ln_rinsd
gen fsd=frm_div*ln_rinsd
gen isdt=inc_div*ln_tmpsd
gen fsdt=frmdiv*ln_tmpsd

label var ir "Income diversification*Rainy season rainfall"
label var fr "Farm diversification*Rainy season rainfall"

/*create square term
gen sqcrp=crp_div*crp_div
gen sqfrm=frmdiv*frmdiv
gen sqinc=inc_div*inc_div*/

*create log hdds and expenditure
gen lnhdds=log(hdds)
gen lnexp=log(pc_expm_d)
gen lnfexp=log(pc_foodxm_d)
gen lnnfexp=log(pc_nonfxm_d)

save panel.dta, replace

export delimited using panel.csv, replace //output as csv

**hausman test 
xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta idcrp idliv ln_rinsd Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015  if frm_div<1,   fe //first stage  idcrp
estimates store fixed
xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta idcrp idliv ln_rinsd Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015  if frm_div<1,   re
estimates store random
hausman fixed random

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta idcrp idliv ln_rinsd Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015  if frm_div<1,   fe //first stage  idcrp
estimates store fixed
xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta idcrp idliv ln_rinsd Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015  if frm_div<1,   re
estimates store random
hausman fixed random
**poisson with control function fixed effect HDDS
drop v2h_fe 
xtset a01 year
/*xtreg crp_div preff_crpdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, vce(r)  fe //first ln_rw ln_rs ln_ra ln_tw ln_ts ln_ta
predict double v2h_fe, e 
xtpoisson hdds crp_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, fe vce(r) //second stage idcrp ln_tw ln_ts ln_tr ln_ta  tmpsd
drop v2h_fe */

xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  ln_rinsd Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015  if frm_div<1, vce(robust) fe  //first stage
predict double v2h_fe, e
xtpoisson hdds frm_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015  if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv
drop v2h_fe

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta  idcrp idliv Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
xtpoisson hdds inc_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta  idcrp idliv Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015, fe vce(r) //second stage
drop v2h_fe 

**2SRI fixed effect household food consumption expenditure
xtset a01 year
xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if frm_div<1, vce(r) fe //first stage
predict double v2h_fe, e
xtreg lnfexp frm_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta  idcrp idliv Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015 if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
drop v2h_fe

xtreg frmdiv preff_frmdiv ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if frm_div<1, vce(r) fe //first stage
predict double v2h_fe, e
xtreg lnfexp frmdiv v2h_fe ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta  idcrp idliv Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015 if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
drop v2h_fe


xtset a01 year
xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if frm_div<1, vce(r) fe //first stage
predict double v2h_fe, e
xtreg lnexp frm_div v2h_fe  ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv, consumption expenditure 
drop v2h_fe

xtset a01 year
xtreg frmdiv preff_frmdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if frm_div<1, vce(r) fe //first stage
predict double v2h_fe, e
xtreg lnexp frmdiv v2h_fe  ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv, consumption expenditure 
drop v2h_fe

xtset a01 year
xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if frm_div<1, vce(r) fe //first stage
predict double v2h_fe, e
xtreg lnnfexp frm_div v2h_fe  ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv, non food consumption expenditure 
drop v2h_fe

xtset a01 year
xtreg frmdiv preff_frmdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if frm_div<1, vce(r) fe //first stage
predict double v2h_fe, e
xtreg lnnfexp frmdiv v2h_fe  ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv, consumption expenditure 
drop v2h_fe

xtset a01 year
xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if frm_div<1, vce(r) fe //first stage
predict double v2h_fe, e
xtreg lnnfexp frm_div v2h_fe  ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv, consumption expenditure 
drop v2h_fe

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta  idcrp idliv Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if inc_div<1, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
xtreg lnfexp inc_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta  idcrp idliv Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if inc_div<1, fe vce(r) //second stage, food consumption expenditure
drop v2h_fe 

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta  idcrp idliv Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if inc_div<1, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
xtreg lnexp inc_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta  idcrp idliv Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if inc_div<1, fe vce(r) //second stage, food consumption expenditure
drop v2h_fe 

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta  idcrp idliv Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if inc_div<1, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
xtreg lnnfexp inc_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta  idcrp idliv Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if inc_div<1, fe vce(r) //second stage, non-food consumption expenditure
drop v2h_fe 


/*output*/
**Descriptive statistics
eststo clear
sort year
by year: eststo: quietly estpost summarize hdds pc_expm_d pc_foodxm_d pc_nonfxm_d frm_div inc_div frmdiv preff_frm_div preff_incdiv rw rs rr ra rinsd tw ts tr ta idcrp idliv Male age_hh hh_size schll_hh farmsize, listwise

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


eststo: xtreg frmdiv preff_frmdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, vce(r) fe //first stage
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo: xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015  if frm_div<1, vce(robust) fe //first stage

quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo: xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, vce(r) fe //first stage  idcrp idliv idi_crp_liv 
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

esttab using $table\ffe_manu.tex,  b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order("\textbf{Peer effect}" preff_frmdiv preff_frm_div preff_incdiv "\textbf{Climate variables}" ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta "\textbf{Control variables}" Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015) mtitles("Farm diversification"  "Farm diversification index" "Income diversification") 

esttab using $table\ffe.tex,  b(%4.3f) se replace wide nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep("\textbf{Peer Effect}" preff_frmdiv preff_incdiv "\textbf{Climate variables}" ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta) order("\textbf{Peer Effect}"  preff_frmdiv preff_incdiv "\textbf{Climate variables}"ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta ln_tmpsd) s(fe year control F N, label("HH FE" "Year dummy" "Control Variables" "F statistics" "Observations")) mtitles("Farm diversification" "Farm diversification index" "Income diversification index")

*second stage analysis HDDS*
eststo clear
drop v2h_fe

xtset a01 year

xtreg frmdiv preff_frmdiv ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, vce(r) fe //first stage
predict double v2h_fe, e
eststo: xtpoisson hdds frmdiv v2h_fe  ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, fe vce(r) //second stage  idcrp idliv idi_crp_liv
drop v2h_fe
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace
quietly estadd local control Yes, replace

xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  ln_rinsd Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015  if frm_div<1, vce(robust) fe //first stage
predict double v2h_fe, e
eststo: xtpoisson hdds frm_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015  if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv
drop v2h_fe
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace
quietly estadd local control Yes, replace

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta   Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
eststo: xtpoisson hdds inc_div  v2h_fe ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta   Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015, fe vce(r) //second stage 
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
label var v2h_fe "Residual"




esttab using $table\scnd_hdds.tex,  b(%4.3f) se replace nogaps wide starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( "\textbf{Diversification}" frmdiv frm_div inc_div  "\textbf{Climate variables}" ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta ) order("\textbf{Diversification}" frmdiv frm_div inc_div   "\textbf{Climate variables}" ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta) s(fe year control chi2 N, label("HH FE" "Year dummy" "Control Variables" "Wald $x^2$" "Observations")) addnote("Instrumental variables (\% of diversification within unions)") 

esttab using $table\scnd_manu_hdds.tex,  b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order( "\textbf{Diversification}"frmdiv frm_div inc_div  "\textbf{Climate variables}" ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta "\textbf{Control variables}" Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 v2h_fe) addnote("Instrumental variables  (\% of diversification household within unions)") stats(chi2  N, label("Wald $x^2$" "Observations"))

**second stage analysis expenditure
eststo clear
xtset a01 year
xtreg frmdiv preff_frmdiv ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, vce(r) fe //first stage
predict double v2h_fe, e
eststo: xtreg lnfexp frmdiv  v2h_fe  ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, fe vce(r) //second stage  idcrp idliv idi_crp_liv
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 

xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, vce(r) fe //first stage
predict double v2h_fe, e
eststo: xtreg lnfexp frm_div v2h_fe  ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, fe vce(r) //second stage  idcrp idliv idi_crp_liv
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
eststo: xtreg lnfexp inc_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta   Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015, fe vce(r) //second stage
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

esttab using $table\scnd.tex,  b(%4.3f) se replace nogaps wide starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( "\textbf{Diversification}" frmdiv frm_div inc_div  "\textbf{Climate variables}" ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta ) order("\textbf{Diversification}" frmdiv inc_div fr ir  "\textbf{Climate variables}" ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta) s(fe year control chi2 N, label("HH FE" "Year dummy" "Control Variables" "Wald $x^2$" "Observations")) addnote("Instrumental variables (share of diversification household within unions)") 

esttab using $table\scnd_manu_fexp.tex,  b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order("\textbf{Diversification}"frmdiv frm_div inc_div "\textbf{Climate variables}" ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta "\textbf{Control variables}" Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 v2h_fe) addnote("Instrumental variables  (share of diversification household within unions)") 

**heterogeneous impact of livelihood diversification on food secuirty (food expenditure)
xtile quanths = hh_size, nq(4)
eststo clear
xtset a01 year
*Q1
xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==1,  vce(r) fe //first stage
predict double v2h_fe, e
eststo: xtreg lnfexp frm_div v2h_fe  ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==1,  fe vce(r) //second stage  idcrp idliv idi_crp_liv
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==1, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
eststo: xtreg lnfexp inc_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta   Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==1, fe vce(r)  //second stage
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 
*Q2
xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==2,  vce(r) fe //first stage
predict double v2h_fe, e
eststo: xtreg lnfexp frm_div v2h_fe  ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==2, fe vce(r) //second stage  idcrp idliv idi_crp_liv
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==2, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
eststo: xtreg lnfexp inc_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta   Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==2, fe vce(r)  //second stage
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 
*Q3
xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==3, vce(r) fe //first stage
predict double v2h_fe, e
eststo: xtreg lnfexp frm_div v2h_fe  ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==3, fe vce(r) //second stage  idcrp idliv idi_crp_liv
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==3, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
eststo: xtreg lnfexp inc_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta   Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==3, fe vce(r) //second stage
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 
*Q4
xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==4, vce(r) fe //first stage
predict double v2h_fe, e
eststo: xtreg lnfexp frm_div v2h_fe  ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==4, fe vce(r) //second stage  idcrp idliv idi_crp_liv
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==4, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
eststo: xtreg lnfexp inc_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta   Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==4, fe vce(r)  //second stage
label var v2h_fe "Residual"
quietly estadd local climate Yes, replace 
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 

esttab using $table\scnd_manu_heterofex.tex,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( "\textbf{Diversification}"frm_div inc_div  ) order("\textbf{Diversification}"  frm_div inc_div) s(climate fe year control N, label("Climate variables" "HH FE" "Year dummy" "Control Variables" "Obs")) mgroups("Q1" "Q2" "Q3" "Q4" , pattern(1 0 1 0 1 0 1 0)) addnote("Instrumental variables (share of diversification household within unions)") 


**heterogeneous impact of livelihood diversification on food secuirty HDDS
xtile quanths = hh_size, nq(4)
eststo clear
xtset a01 year
*Q1
xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==1,  vce(r) fe //first stage
predict double v2h_fe, e
eststo: xtpoisson hdds frm_div v2h_fe  ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==1,  fe vce(r) //second stage  idcrp idliv idi_crp_liv
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==1, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
eststo: xtpoisson hdds inc_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta   Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==1, fe vce(r)  //second stage
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 
*Q2
xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==2,  vce(r) fe //first stage
predict double v2h_fe, e
eststo: xtpoisson hdds frm_div v2h_fe  ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==2, fe vce(r) //second stage  idcrp idliv idi_crp_liv
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==2, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
eststo: xtpoisson hdds inc_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta   Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==2, fe vce(r)  //second stage
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 
*Q3
xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==3, vce(r) fe //first stage
predict double v2h_fe, e
eststo: xtpoisson hdds frm_div v2h_fe  ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==3, fe vce(r) //second stage  idcrp idliv idi_crp_liv
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==3, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
eststo: xtpoisson hdds inc_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta   Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==3, fe vce(r) //second stage
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 
*Q4
xtreg frm_div preff_frm_div ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==4, vce(r) fe //first stage
predict double v2h_fe, e
eststo: xtpoisson hdds frm_div v2h_fe  ln_rw ln_rs ln_rr ln_ra  ln_tw ln_ts ln_tr ln_ta  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 if quanths==4, fe vce(r) //second stage  idcrp idliv idi_crp_liv
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local climate Yes, replace 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==4, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
eststo: xtpoisson hdds inc_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta   Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 if quanths==4, fe vce(r)  //second stage
label var v2h_fe "Residual"
quietly estadd local climate Yes, replace 
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables 
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 

esttab using $table\scnd_manu_heterohdds.tex,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( "\textbf{Diversification}" frm_div inc_div  ) order("\textbf{Diversification}"  frm_div inc_div) s(climate fe year control N, label("Climate variables" "HH FE" "Year dummy" "Control Variables" "Obs")) mgroups("Q1" "Q2" "Q3" "Q4" , pattern(1 0 1 0 1 0 1 0)) addnote("Instrumental variables (share of diversification household within unions)") 
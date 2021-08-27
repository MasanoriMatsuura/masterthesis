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

sort uncode year
by uncode year: egen adaptation_n=count(a01) if frmdiv>1
by uncode year: egen total_n=count(a01)
gen preff_frmdiv=adaptation_n/total_n //creating peer effect
sort uncode year
by uncode year: egen adaptation_nc=count(a01) if crp_div>0
by uncode year: egen total_nc=count(a01)
gen preff_crpdiv=adaptation_nc/total_nc //creating peer effect
sort uncode year
by uncode year: egen adaptation_ni=count(a01) if inc_div>0
by uncode year: egen total_ni=count(a01)
gen preff_incdiv=adaptation_ni/total_ni //creating peer effect

label var preff_crpdiv "\% of crop diversification within the union"
label var preff_frmdiv "\% of farm diversification within the union"
label var preff_incdiv "\% of income diversification within the union"

*create binary adoption
recode frmdiv (1=0 "No")(2/max=1 "Yes"), gen(frmdivadp)
label var frmdivadp "Farm diversification"
save panel.dta, replace
export delimited using panel.csv, replace //output as csv

*create interaction term
gen cr=crp_div*ln_rr
gen csd=crp_div*ln_rinsd
gen ir=inc_div*ln_rr
gen fr=frmdiv*ln_rr
gen isd=inc_div*ln_rinsd
gen fsd=frmdiv*ln_rinsd
gen isdt=inc_div*ln_tmpsd
gen fsdt=frmdiv*ln_tmpsd

label var ir "Income diversification*Rainy season rainfall"
label var fr "Farm diversification*Rainy season rainfall"

/*create square term
gen sqcrp=crp_div*crp_div
gen sqfrm=frmdiv*frmdiv
gen sqinc=inc_div*inc_div*/

*create log hdds
gen lnhdds=log(hdds)


**hausman test 
xtreg crp_div preff_crpdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta ln_tmpsd Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015,   fe //first stage  idcrp
estimates store fixed
xtreg crp_div preff_crpdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta ln_tmpsd Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015,   re
estimates store random
hausman fixed random
**poisson with control function fixed effect 
drop v2h_fe 
xtset a01 year
/*xtile quant = hdds, nq(4)*/
/*xtreg crp_div preff_crpdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta  idcrp Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015, vce(r)  fe //first ln_rw ln_rs ln_ra ln_tw ln_ts ln_ta
predict double v2h_fe, e 
xtpoisson lnhdds crp_div cr v2h_fe  ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta   idcrp  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, fe vce(r) //second stage idcrp ln_tw ln_ts ln_tr ln_ta  tmpsd
drop v2h_fe */

xtreg frmdiv preff_frmdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, vce(r) fe //first stage
predict double v2h_fe, e
xtpoisson lnhdds frmdiv fr v2h_fe  ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, fe vce(r) //second stage  idcrp idliv idi_crp_liv
drop v2h_fe

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta  idcrp idliv Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
xtpoisson lnhdds inc_div ir v2h_fe ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta  idcrp idliv Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015, fe vce(r) //second stage
drop v2h_fe 


/*output*/
**Descriptive statistics
eststo clear
sort year
by year: eststo: quietly estpost summarize hdds frmdiv inc_div preff_frmdiv preff_incdiv rw rs rr ra rinsd tw ts tr ta idcrp idliv Male age_hh hh_size schll_hh farmsize Rangpur, listwise

esttab using $table\dessta.tex, cells("mean(fmt(2)) sd(fmt(2))") label nodepvar replace addnote(Source: Bangladesh Integrated Household Survey 2011/12, 2015, 2018/19 \\ 100 decimal is 0.4 ha)

**histgram of crop diversification index
twoway (kdensity crp_div if year==2012, color("blue%50"))(kdensity crp_div if year==2015, color("purple%50"))(kdensity crp_div if year==2018, color("red%50")), title(Crop diversificatioin index ) xtitle(Crop diversification index) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(2 "2012" 1 "2015" 3 "2018")) //hist of crop diversification index
graph display, scheme(s1mono)
graph export $figure\crpdiv.pdf, replace

**histgram of income diversification index
twoway (kdensity inc_div if year==2012, color("blue%50"))(kdensity inc_div if year==2015, color("purple%50"))(kdensity inc_div if year==2018, color("red%50")), title(Income diversificatioin index ) xtitle(Income diversification index) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(2 "2012" 1 "2015" 3 "2018")) //hist of inc diversification index
graph display, scheme(s1mono)
graph export $figure\incdiv.pdf, replace

**histgram of farm diversification index
twoway (kdensity frmdiv if year==2012, color("blue%50"))(kdensity frmdiv if year==2015, color("purple%50"))(kdensity frmdiv if year==2018, color("red%50")), title(Farm diversificatioin) xtitle(Farm diversification) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(2 "2012" 1 "2015" 3 "2018")) //hist of inc diversification index
graph display, scheme(s1mono)
graph export $figure\frmdiv.pdf, replace

**first stage estimation
*first stage
eststo clear
xtset a01 year
/*eststo: xtreg crp_div preff_crpdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta ln_tmpsd  Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015, vce(r)  fe //first stage  idcrp
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace*/

eststo: xtreg frmdiv preff_frmdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, vce(r) fe //first stage
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo: xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, vce(r) fe //first stage  idcrp idliv idi_crp_liv 
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

esttab using $table\ffe_manu.tex,  b(%4.3f) se replace nogaps wide starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order("\textbf{Peer effect}" preff_frmdiv preff_incdiv "\textbf{Climate variables}" ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta "\textbf{Control variables}" idcrp idliv Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015) mtitles("Farm diversification" "Income diversification") 

esttab using $table\ffe.tex,  b(%4.3f) se replace wide nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep("\textbf{Peer Effect}" preff_frmdiv preff_incdiv "\textbf{Climate variables}" ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta) order("\textbf{Peer Effect}"  preff_frmdiv preff_incdiv "\textbf{Climate variables}"ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta ln_tmpsd) s(fe year control F N, label("HH FE" "Year dummy" "Control Variables" "F statistics" "Observations")) mtitles("Farm diversification" "Income diversification")

*second stage analysis*
eststo clear
xtset a01 year
drop v2h_fe

/*xtreg crp_div preff_crpdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta ln_tmpsd  Male age_hh hh_size schll_hh  lnfrm  irrigation i.year, vce(r)  fe //first stage  idcrp
predict double v2h_fe, e
eststo: xtpoisson hdds crp_div v2h_fe ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta ln_tmpsd  Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, fe vce(r) //second stage idcrp
quietly estadd local fixedm Yes, replace
quietly estadd local fixedy No, replace
quietly estadd local control Yes, replace*/


xtreg frmdiv preff_frmdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, vce(r) fe //first stage
predict double v2h_fe, e
eststo: xtpoisson lnhdds frmdiv fr v2h_fe  ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, fe vce(r) //second stage  idcrp idliv idi_crp_liv
drop v2h_fe
quietly estadd local fixedm Yes, replace
quietly estadd local fixedy No, replace
quietly estadd local control Yes, replace

xtreg inc_div preff_incdiv ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta  idcrp idliv Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015, vce(r) fe //first stage  idcrp idliv idi_crp_liv
predict double v2h_fe, e
eststo: xtpoisson lnhdds inc_div ir v2h_fe ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta  idcrp idliv Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015, fe vce(r) //second stage 
label var v2h_fe "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fe 



esttab using $table\scnd.tex,  b(%4.3f) se replace nogaps wide starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( "\textbf{Diversification}" frmdiv inc_div fr ir "\textbf{Climate variables}" ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta ) order("\textbf{Diversification}" frmdiv inc_div fr ir  "\textbf{Climate variables}" ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta) s(fe year control chi2 N, label("HH FE" "Year dummy" "Control Variables" "Wald $x^2$" "Observations")) addnote("Instrumental variables (\% of diversification within unions)") 

esttab using $table\scnd_manu.tex,  b(%4.3f) se replace wide nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order("\textbf{Diversification}"frmdiv inc_div fr ir "\textbf{Climate variables}" ln_rw ln_rs ln_rr ln_ra ln_rinsd ln_tw ln_ts ln_tr ln_ta "\textbf{Control variables}" idcrp idliv Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015 v2h_fe) addnote("Instrumental variables  (\% of diversification within unions)") stats(chi2  N, label("Wald $x^2$" "Observations"))
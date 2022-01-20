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

*install quantile regression
ssc install xtqreg

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
//use panel.dta, clear 
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
label var aginc "Farm self"
label var frmwage "Farm wage"
label var nonself "Non-farm self"
label var nonwage "Non-farm wage and salary"
label var nonearn "Non-earned"

replace crp_div=. if crp_div==1
replace inc_div=. if inc_div==1
replace shnc=. if crp_div==1
replace shni=. if inc_div==1

*create peer effect variables
/*sort uncode year
by uncode year: egen adaptation_n=count(a01) if frmdiv>1
by uncode year: egen total_n=count(a01)
gen preff_frmdiv=(adaptation_n-1)/total_n //creating peer effect*/
recode crp_div (0=0)(nonm=1), gen(crp_div_i)
recode inc_div (0=0)(nonm=1), gen(inc_div_i)
recode shnc (0=0)(nonm=1), gen(shnc_i)
recode shni (0=0)(nonm=1), gen(shni_i)

sort uncode year
by uncode year: egen adaptation_nc=sum(crp_div_i) 
by uncode year: egen total_nc=count(a01)
gen preff_crp_div=(adaptation_nc-crp_div_i)/(total_nc) //creating peer effect
sort uncode year
/*by uncode year: egen adaptation_nc=count(a01) if crp_div>0
by uncode year: egen total_nc=count(a01)
gen preff_crpdiv=(adaptation_nc-1)/total_nc //creating peer effect
sort uncode year*/
by uncode year: egen adaptation_ni=sum(inc_div_i) 
by uncode year: egen total_ni=count(a01)
gen preff_incdiv=(adaptation_ni-inc_div_i)/(total_ni) //creating peer effect
sort uncode year
by uncode year: egen adaptation_nshc=sum(shnc_i)
by uncode year: egen total_nshc=count(a01)
gen preff_shc=(adaptation_nshc-shnc_i)/(total_nshc) //creating peer effect shannon farm
sort uncode year
by uncode year: egen adaptation_nshi=sum(shni_i)
by uncode year: egen total_nshi=count(a01)
gen preff_shi=(adaptation_nshi-shni_i)/(total_nshi) //creating peer effect shannon income

/*label var preff_crpdiv "share of crop diversification household within the union"*/
/*label var preff_frmdiv "share of farm diversification household within the union"*/
label var preff_crp_div "share of households adopting crop diversification within the union"
label var preff_incdiv "share of households adopting income diversification within the union"


*create log hdds and expenditure
gen lnhdds=log(hdds)
gen lnexp=log(pc_expm_d)
gen lnfexp=log(pc_foodxm_d)

*shannon index
label var shnc "Crop diversificaion (Shannon)"
label var shni "Income diversification (Shannon)"


/*label market participation variable
label var marketp "Market participation (=1 if yes)"*/
save panel.dta, replace

export delimited using panel.csv, replace //output as csv

** dependent variable by regional level
collapse (mean) divfexp=pc_foodxm_d divhdds=hdds, by(dcode)
destring(dcode), replace
save dependent.dta, replace
**Visualization

label var lnfexp "Per capita food consumption expenditure(log)"
graph twoway (scatter hdds farmsize , msymbol(circle_hollow) yaxis(1) ytitle("HDDS", axis(1))) (scatter lnfexp farmsize, msymbol(triangle_hollow) yaxis(2) ytitle("Per capita food consumption expenditure(log)", axis(2))), xtitle("Farmland size (decimal)")  title("Household food security over the scale of farmers")  note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author")
graph display, scheme(s1mono) 
graph export $figure\fsecurity_farm.png, replace



**poisson with control function fixed effect HDDS
xtset a01 year 

reghdfe crp_div preff_crp_div srshock rrshock arshock wrshock stshock rtshock atshock wtshock Male age_hh hh_size  schll_hh lvstck lnfrm market road irrigation extension year2012 year2015, vce(r) absorb(a01) res //first stage lsrshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt
predict double v2h_fec, r
xtpoisson hdds crp_div v2h_fec srshock rrshock arshock wrshock stshock rtshock atshock wtshock Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension year2012 year2015, fe vce(r) //second stage   ln_sds ln_sdr ln_sda ln_sdw  ln_sdst ln_sdrt ln_sdat ln_sdwt
drop v2h_fec

reghdfe inc_div preff_incdiv srshock rrshock arshock wrshock stshock rtshock atshock wtshock Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension year2012 year2015, vce(r) absorb(a01) res //first stage ln_sds ln_sdr ln_sda ln_sdw n_sdst ln_sdrt ln_sdat ln_sdwt
predict double v2h_fei, r
xtpoisson hdds inc_div v2h_fei srshock rrshock arshock wrshock stshock rtshock atshock wtshock Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension year2012 year2015, fe vce(r) //second stage
drop v2h_fei



**2SRI fixed effect household food consumption expenditure

reghdfe crp_div preff_crp_div srshock rrshock arshock wrshock  stshock rtshock atshock wtshock  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension year2012 year2015, vce(r) absorb(a01) res //first stage
predict double v2h_fec, r
reghdfe lnfexp crp_div v2h_fec srshock rrshock arshock wrshock  stshock rtshock atshock wtshock  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension year2012 year2015, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
drop v2h_fec


reghdfe inc_div preff_incdiv srshock rrshock arshock wrshock stshock rtshock atshock wtshock Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension year2012 year2015 , vce(r) absorb(a01) res //first stage
predict double v2h_fei, r
reghdfe lnfexp inc_div v2h_fei srshock rrshock arshock wrshock stshock rtshock atshock wtshock  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension year2012 year2015 , absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
drop v2h_fei


**weak IV
ivreghdfe lnexp srshock rrshock arshock wrshock  stshock rtshock atshock wtshock  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension year2012 year2015 (crp_div=preff_crp_div), absorb(a01) vce(r) //second stage  ln_sds ln_sdr ln_sda ln_sdw ln_sdst ln_sdrt ln_sdat ln_sdwt
ivreghdfe lnfexp srshock rrshock arshock wrshock  stshock rtshock atshock wtshock Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 (inc_div=preff_incdiv), absorb(a01) vce(r) //second stage ln_sds ln_sdr ln_sda ln_sdw ln_sdst ln_sdrt ln_sdat ln_sdwt



**heterogeneous analysis
xtset a01 year

*smallholder
recode farmsize (min/47=1 "Yes")(47/max=0 "No"), gen("small")
label var small "Smallholder (=1 if yes)"

gen frms=frm_div*small
gen incs=inc_div*small

gen pincs=preff_incdiv*small
gen pfrms=preff_frm_div*small
*1st stage frm q
reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm market road extension irrigation year2012 year2015  if frm_div<1,  res vce(r) absorb(a01) //first stage
predict double res, r

/*reghdfe frmq1 pfrmq1 ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm  market road extension irrigation year2012 year2015 if frm_div<1, res vce(r) absorb(a01) //first stage
predict double v2h_fef1, r

reghdfe frmq2 pfrmq2 ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm  market road extension irrigation year2012 year2015 if frm_div<1, res vce(r) absorb(a01) //first stage
predict double v2h_fef2, r

reghdfe frmq3 pfrmq3 ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm  market road extension irrigation year2012 year2015 if frm_div<1, res vce(r) absorb(a01) //first stage
predict double v2h_fef3, r*/

reghdfe frms pfrms ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm market road extension irrigation year2012 year2015 if frm_div<1, res vce(r) absorb(a01) //first stage
predict double sres, r

**hdds frm q
xtpoisson hdds frm_div frms small res sres ln_ra ln_rr ln_rs ln_rw  ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road extension irrigation year2012 year2015 if frm_div<1, fe vce(r) //with interaction term
 
xtpoisson hdds frm_div small res ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road extension irrigation year2012 year2015 if frm_div<1, fe vce(r) //without interaction term

**lnfexp frm q
reghdfe lnfexp frm_div frms small res sres ln_ra ln_rr ln_rs ln_rw  ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road extension irrigation year2012 year2015 if frm_div<1, absorb(a01) vce(r) // with interaction term

reghdfe lnfexp frm_div small res ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road extension irrigation year2012 year2015 if frm_div<1, absorb(a01) vce(r) // without interaction term

drop res sres //res2 res3 res4 resf  v2h_fef4 frmq1 frmq2 frmq3
drop v2h_fef2 v2h_fef3 
drop v2h_fef1

*1st stage inc
reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double res, r

/*reghdfe incq2 pincq2  ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double res1, r
 
reghdfe incq2 pincq2  ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double res2, r
reghdfe incq3 pincq3 ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm  market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double res3, r*/

reghdfe incs pincs ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm market road extension irrigation year2012 year2015 , res vce(r) absorb(a01) //first stage
predict double sres, r

**hdds inc q
xtpoisson hdds inc_div incs res sres small ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road irrigation year2012 year2015 , fe vce(r) //with interaction

xtpoisson hdds inc_div res small ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road irrigation year2012 year2015 , fe vce(r) //without interaction

**lnfexp inc q
reghdfe lnfexp inc_div incs res sres small ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road irrigation year2012 year2015 , absorb(a01) vce(r) //with interaction

reghdfe lnfexp inc_div res small ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road irrigation year2012 year2015 , absorb(a01) vce(r) //without interaction

drop res sres //res2 res3 res4 resf  v2h_fef4 frmq1 frmq2 frmq3

***Quantile regression
xtset a01 year

reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fef, r
xtqreg lnfexp frm_div v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frm_div<1, i(a01) quantile( .1 .25  .5  .75  .9 ) //second stage  idcrp idliv idi_crp_liv, food expenditure
drop v2h_fef

reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation year2012 year2015 , vce(r) absorb(a01) res //first stage
predict double v2h_fei, r

xtqreg lnfexp inc_div v2h_fei ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw   Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation year2012 year2015, i(a01) quantile(.1 .25  .5  .75  .9 )  //second stage  idcrp idliv idi_crp_liv, food expenditure
drop v2h_fei


/*output*/
**Descriptive statistics
eststo clear
sort year
by year: eststo: quietly estpost summarize hdds pc_foodxm_d crp_div inc_div preff_crp_div preff_incdiv hs hr ha hw sds sdr sda sdw s r a w hst hrt hat hwt sdst sdrt sdat sdwt ts tr ta tw Male age_hh hh_size schll_hh lvstck farmsize market road extension irrigation
by year: summarize hdds pc_foodxm_d crp_div inc_div preff_crp_div preff_incdiv hs hr ha hw sds sdr sda sdw s r a w hst hrt hat hwt sdst sdrt sdat sdwt ts tr ta tw Male age_hh hh_size schll_hh lvstck farmsize market road extension irrigation
esttab using $table\dessta.rtf, cells("mean(fmt(2)) sd(fmt(2))") label nodepvar replace addnote(Source: Bangladesh Integrated Household Survey 2011/12, 2015, 2018/19, 100 decimal is 0.4 ha, currency is Bangladesh taka) //cells("mean(fmt(2)) sd(fmt(2)) N(fmt(4))")


**histgram of diversification index
twoway (kdensity inc_div if year==2012, color("blue%50") lp(solid))(kdensity inc_div if year==2015, color("purple%50") lp(dash))(kdensity inc_div if year==2018, color("red%50") lp(longdash)), title(Income diversificatioin index ) xtitle(Income diversification index) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(1 "2012" 2 "2015" 3 "2018")) saving(income) //hist of inc diversification index
twoway (kdensity frm_div if year==2012 & frm_div<1, color("blue%50") lp(solid))(kdensity frm_div if year==2015 & frm_div<1, color("purple%50") lp(dash))(kdensity frm_div if year==2018 & frm_div<1, color("red%50") lp(longdash)), title(Farm diversificatioin index) xtitle(Farm diversification) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(1 "2012" 2 "2015" 3 "2018")) saving(farm)  //hist of farm diversification index
gr combine income.gph farm.gph
graph display, scheme(s1mono) 
graph export $figure\div.png, replace

*pie chart of income composition
graph pie aginc frmwage nonself nonwage nonearn if year==2012, plabel(_all percent, color(white)) subtitle("2011/12") saving(pie12) 
graph pie aginc frmwage nonself nonwage nonearn if year==2015,  plabel(_all percent, color(white)) saving(pie15) subtitle("2015")
graph pie aginc frmwage nonself nonwage nonearn if year==2018,  plabel(_all percent, color(white)) saving(pie18) subtitle("2018/19")
gr combine pie12.gph pie15.gph pie18.gph, title("Breakdown of household income by source") note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") 
graph display, scheme(s1mono) 
graph export $figure\income_dist.png, replace




**first stage estimation
*first stage
eststo clear
xtset a01 year


/*eststo: xtreg frmdiv preff_frmdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, vce(r) fe //first stage
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace*/

eststo: reghdfe crp_div preff_crp_div srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015, absorb(a01) vce(robust)  

quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo: reghdfe inc_div preff_incdiv srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation  extension  year2012 year2015 , vce(r) absorb(a01)  //first stage
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

esttab using $table\ffe_manu.rtf,  b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order("\textbf{Peer effect}"  preff_crp_div preff_incdiv "\textbf{Climate variables}" srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt"\textbf{Control variables}" Male age_hh hh_size schll_hh lnfrm lvstck irrigation market road extension year2012 year2015) mtitles("Farm diversification" "Income diversification") r2 

esttab using $table\ffe.tex,  b(%4.3f) se replace wide nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep("\textbf{Peer Effect}" preff_crp_div preff_incdiv "\textbf{Climate variables}" srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt ) order("\textbf{Peer Effect}"  preff_frm_div preff_incdiv "\textbf{Climate variables}"ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw)  s(fe year control F N, label("HH FE" "Year dummy" "Control Variables" "F statistic" "Observations")) mtitles("Farm diversification " "Income diversification ")

*second stage analysis*
eststo clear
xtset a01 year

reghdfe crp_div preff_crp_div srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 , vce(r) absorb(a01) res //first stage
predict double v2h_fec, r
eststo: xtpoisson hdds crp_div v2h_fec srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 , fe vce(r) //second stage  
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace
quietly estadd local control Yes, replace
label var v2h_fec "Residual-farm"

eststo: reghdfe lnfexp crp_div v2h_fec srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt Male age_hh hh_size schll_hh lvstck lnfrm market road extension  irrigation year2012 year2015, absorb(a01) vce(r) //second stage 
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

reghdfe inc_div preff_incdiv srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension  extension year2012 year2015 , vce(r) absorb(a01) res //first stage
predict double v2h_fei, r
eststo: xtpoisson hdds inc_div  v2h_fei srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension year2012 year2015, fe vce(r) //second stage 
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
label var v2h_fei "Residual-income"


eststo: reghdfe lnfexp inc_div v2h_fei srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt Male age_hh hh_size schll_hh lvstck lnfrm market road  irrigation extension  year2012 year2015, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace


esttab using $table\scnd.tex,  b(%4.3f) se replace nodepvar nogaps wide starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( "\textbf{Diversification}"  frm_div inc_div  "\textbf{Climate variables}" srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt) order("\textbf{Diversification}"  crp_div inc_div   "\textbf{Climate variables}" lsrshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt) s(fe year control N, label("HH FE" "Year dummy" "Control Variables" "Observations")) addnote("Instrumental variables (\% of diversification within unions)")  mgroups("HDDS" "Per capita food expenditure (log)" , pattern(1 0 1 0 ))


esttab using $table\scnd_manu.rtf,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order( "\textbf{Diversification}" crp_div inc_div  "\textbf{Climate variables}" srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt "\textbf{Control variables}" Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 v2_fef v2h_fei ) addnote("Instrumental variables  (\% of diversification household within unions)") n mtitles("HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)")
drop v2h_fef v2h_fei 

**Heterogeneous visualization
label var lnfexp "Per capita food consumption expenditure(log)"
graph twoway (scatter hdds farmsize , msymbol(circle_hollow) yaxis(1) ytitle("HDDS", axis(1))) (scatter lnfexp farmsize, msymbol(triangle_hollow) yaxis(2) ytitle("Per capita food consumption expenditure(log)", axis(2))), xtitle("Farmland size (decimal)")  title("Household food security over the scale of farmers")  note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author")
graph display, scheme(s1mono) 
graph export $figure\fsecurity_farm.png, replace


**heterogeneous impact of livelihood diversification on food secuirty
eststo clear
xtset a01 year
*1st stage frm q
reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015  if frm_div<1,  res vce(r) absorb(a01) //first stage
predict double res, r

reghdfe frms pfrms ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck market road extension irrigation year2012 year2015 if frm_div<1, res vce(r) absorb(a01) //first stage
predict double sres, r
**hdds frm q
eststo: xtpoisson hdds frm_div frms small res sres ln_ra ln_rr ln_rs ln_rw  ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck market road extension irrigation year2012 year2015 if frm_div<1, fe vce(r) //with interaction term
 

quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace

**lnfexp frm q
eststo: reghdfe lnfexp frm_div frms small res sres ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck market road extension irrigation year2012 year2015 if frm_div<1, absorb(a01) vce(r) // with interaction term


label var res "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace

drop res sres //v2h_fe2 v2h_fe3 


*1st stage inc
reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension  year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double res, r

reghdfe incs pincs ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck market road extension irrigation  extension year2012 year2015 , res vce(r) absorb(a01) //first stage
predict double sres, r


**hdds inc q
eststo: xtpoisson hdds inc_div incs res sres small ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck market road irrigation extension year2012 year2015 , fe vce(r) //with interaction

quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace

**lnfexp inc q
eststo: reghdfe lnfexp inc_div incs res sres small ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck market road irrigation extension  year2012 year2015 , absorb(a01) vce(r) //with interaction

label var res "Residual"
/*drop v2h_fe v2h_fe2 v2h_fe3 */
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace 
/*label var frmq1 "Farm diversification*Q1"
label var frmq2 "Farm diversification*Q2"
label var frmq3 "Farm diversification*Q3"
label var incq1 "Income diversification*Q1"
label var incq2 "Income diversification*Q2"
label var incq3 "Income diversification*Q3"
label var q1 "less than 0.2ha"
label var q2 "0.2ha to 0.5ha"
label var q3 "0.5ha to 0.9"*/
label var incs "Income diversification $\times$ Smallholder"
label var frms "Farm diversification $\times$ Smallholder"
drop res sres
esttab using $table\scnd_hetero.tex,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( frm_div inc_div incs frms small ) order( frm_div inc_div frmq2 frmq3  incq2 incq3  q2 q3 ) s(climate fe year control N, label("Climate variables" "HH FE" "Year dummy" "Control Variables" "Observations")) mtitles("HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)")

esttab using $table\scnd_manu_hetero.tex,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep(frm_div inc_div incs frms small "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh lvstck market road extension irrigation) order( frm_div inc_div incs frms small "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh lvstck market road extension irrigation) s( fe year residual N, label( "HH FE" "Year dummy" "residual" "Observations")) mtitles("HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)")


***heterogeneous reference, without interaction
eststo clear
xtset a01 year
*1st stage frm q
reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015  if frm_div<1,  res vce(r) absorb(a01) //first stage
predict double res, r

reghdfe frms pfrms ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck market road extension irrigation year2012 year2015 if frm_div<1, res vce(r) absorb(a01) //first stage
predict double sres, r

eststo: xtpoisson hdds frm_div small res ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck market road extension irrigation year2012 year2015 if frm_div<1, fe vce(r) //without interaction term
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace

eststo: reghdfe lnfexp frm_div small res ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck market road extension irrigation year2012 year2015 if frm_div<1, absorb(a01) vce(r) // without interaction term
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace
drop res sres

*1st stage inc
reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension  year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double res, r

reghdfe incs pincs ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck market road extension irrigation  extension year2012 year2015 , res vce(r) absorb(a01) //first stage
predict double sres, r

eststo: xtpoisson hdds inc_div res small ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck market road irrigation extension  year2012 year2015 , fe vce(r) //without interaction

quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace

eststo: reghdfe lnfexp inc_div res small ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck market road irrigation  extension year2012 year2015 , absorb(a01) vce(r) //without interaction
/*drop v2h_fe v2h_fe2 v2h_fe3 */
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace 
drop res sres

esttab using $table\scnd_hetero_woint.tex,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( frm_div inc_div small ) order( frm_div inc_div frmq2 frmq3  incq2 incq3  q2 q3 ) s(climate fe year control N, label("Climate variables" "HH FE" "Year dummy" "Control Variables" "Observations")) mtitles("HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)")
esttab using $table\scnd_manu_hetero_woint.tex,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep(frm_div inc_div small "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh lvstck market road extension irrigation) order( frm_div inc_div incs frms small "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh lvstck market road extension irrigation) s( fe year residual N, label( "HH FE" "Year dummy" "residual" "Observations")) mtitles("HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)")


** Quantile regression 
eststo clear
xtset a01 year

** quantile fe-ols
reghdfe crp_div preff_crp_div srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015, vce(r) absorb(a01) res //first stage
predict double v2h_fec, r
eststo: xtqreg lnfexp crp_div v2h_fec srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt  Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015, i(a01) quantile( .25 ) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo: xtqreg lnfexp crp_div v2h_fec srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt  Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015, i(a01) quantile(  .5  ) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo: xtqreg lnfexp crp_div v2h_fec srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015, i(a01) quantile( .75 ) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
label var v2h_fec "Residual-farm"
drop v2h_fec

**quantile inc
reghdfe inc_div preff_incdiv srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension  year2012 year2015 , vce(r) absorb(a01) res //first stage
predict double v2h_fei, r

eststo: xtqreg lnfexp inc_div v2h_fei srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation  extension year2012 year2015, i(a01) quantile(.25)  //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
eststo: xtqreg lnfexp inc_div v2h_fei srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension  year2012 year2015, i(a01) quantile(  .5 )  //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
eststo: xtqreg lnfexp inc_div v2h_fei srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension  year2012 year2015, i(a01) quantile(  .75)  //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
label var v2h_fei "Residual-income"
drop v2h_fei 


esttab using $table\quantile.tex,  b(%4.3f) se replace nogaps nodepvar wide starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( "\textbf{Diversification}"  frm_div inc_div ) order("\textbf{Diversification}" frm_div inc_div) s(fe year control N, label("FE" "Year dummy" "Control Variables" "Observations")) addnote("Instrumental variables (\% of diversification within unions)")  mtitles("\nth{25} quantile" "\nth{50} quantile" "\nth{75} quantile" "\nth{25} quantile" "\nth{50} quantile" "\nth{75} quantile")

esttab using $table\quantile_full.tex,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order("\textbf{Diversification}" crp_div inc_div  "\textbf{Climate variables}" srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt "\textbf{Control variables}" Male age_hh hh_size schll_hh lvstck market road extension irrigation) mtitles("\nth{25} quantile" "\nth{50} quantile" "\nth{75} quantile" "\nth{25} quantile" "\nth{50} quantile" "\nth{75} quantile")
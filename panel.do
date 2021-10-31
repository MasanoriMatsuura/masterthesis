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
label var Rangpur "Rangpur division (dummy)"
label var ttinc "Total yearly income (taka)"
gen ttinc10000=ttinc/10000
label var ttinc10000 "Total yearly income (10,000taka)"
gen lninc=log(ttinc)
label var lninc "Total yearly income (log)"

label var frmdiv "Farm diversification (Num of species of crop, livestocks, and fish)" 
label var frm_div "Farm diversification index"
/*label var rinsd "Monthly st.dev rainfall(mm)"
label var tmpsd "Monthly st.dev temperature(\textdegree{}C)"*/
label var rw "Winter rainfall(mm)"
label var rs "Summer rainfall(mm)" 
label var rr "Rainy season rainfall(mm)"
label var ra "Autumn rainfall(mm)"
label var tw "Winter average temperature(\textdegree{}C)"
label var ts "Summer average temperature(\textdegree{}C)"
label var tr "Rainy season average temperature(\textdegree{}C)"
label var ta "Autumn season average temperature(\textdegree{}C)"
//rw rs rr ra tmpsd tw ts tr ta rinsd
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
/*by uncode year: egen adaptation_nc=count(a01) if crp_div>0
by uncode year: egen total_nc=count(a01)
gen preff_crpdiv=(adaptation_nc-1)/total_nc //creating peer effect
sort uncode year*/
by uncode year: egen adaptation_ni=count(a01) if inc_div>0
by uncode year: egen total_ni=count(a01)
gen preff_incdiv=(adaptation_ni-1)/total_ni //creating peer effect
sort uncode year
by uncode year: egen adaptation_nshf=count(a01) if shnf>0
by uncode year: egen total_nshf=count(a01)
gen preff_shf=(adaptation_nshf-1)/total_nshf //creating peer effect shannon farm

/*label var preff_crpdiv "share of crop diversification household within the union"*/
/*label var preff_frmdiv "share of farm diversification household within the union"*/
label var preff_frm_div "share of farm diversification household within the union"
label var preff_incdiv "share of income diversification household within the union"
replace frm_div=. if frm_div==1
replace inc_div=. if inc_div==1

*create log hdds and expenditure
gen lnhdds=log(hdds)
gen lnexp=log(pc_expm_d)
gen lnfexp=log(pc_foodxm_d)



/*label market participation variable
label var marketp "Market participation (=1 if yes)"*/
save panel.dta, replace

export delimited using panel.csv, replace //output as csv

**Visualization
gen lnincdiv=log(inc_div)

twoway(scatter lnfexp  lnincdiv if year==2012 & small==1)(scatter lnfexp lnincdiv if year==2012 & small==0)(lfit lnfexp lnincdiv if year==2012 & small==1)(lfit lnfexp  lnincdiv if year==2012 & small==0) ,legend(order(1 "small" 2 "others" 3 "small" 4 "others")) 

twoway(scatter lnhdds frm_div if year==2012 & small==1)(scatter lnhdds frm_div if year==2012 & small==0)(lfit lnhdds frm_div if year==2012 & small==1)(lfit lnhdds frm_div if year==2012 & small==0) ,legend(order(1 "small" 2 "others" 3 "small" 4 "others")) 

graph twoway scatter  preff_incdiv inc_div, by(year)

kdensity lnfexp 

**first stage CRE
xtset a01 year

bysort a01: egen preff_frm_divb=mean(preff_frm_div)
bysort a01: egen ln_rab=mean(ln_ra)
bysort a01: egen ln_rrb=mean(ln_rr)
bysort a01: egen ln_rsb=mean(ln_rs)
bysort a01: egen ln_rwb=mean(ln_rw)
bysort a01: egen ln_tab=mean(ln_ta)
bysort a01: egen ln_trb=mean(ln_tr)
bysort a01: egen ln_tsb=mean(ln_ts)
bysort a01: egen ln_twb=mean(ln_tw)
bysort a01: egen ln_rinsdb=mean(ln_rinsd)
bysort a01: egen ln_tmpsdb=mean(ln_tmpsd)
bysort a01: egen Maleb=mean(Male)
bysort a01: egen age_hhb=mean(age_hh)
bysort a01: egen hh_sizeb=mean(hh_size)
bysort a01: egen schll_hhb=mean(schll_hh)
bysort a01: egen lnfrmb=mean(lnfrm)
bysort a01: egen marketb=mean(market)
bysort a01: egen roadb=mean(road)
bysort a01: egen extensionb=mean(extension)
bysort a01: egen irrigationb=mean(irrigation)




xttobit frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm market road extension irrigation preff_frm_divb ln_rab ln_rrb ln_rsb ln_rwb ln_rinsdb ln_tmpsdb ln_tab ln_trb ln_tsb ln_twb Maleb age_hhb hh_sizeb schll_hhb lnfrmb marketb roadb extensionb irrigationb year2012 year2015 i.dcode // if frm_div<1
predict double xb, ystar(0,1)
gen v2h_fef=frm_div-xb
drop v2h_fef xb

xttobit inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm market road irrigation year2012 year2015 i.dcode, ll(0) tobit

**poisson with control function fixed effect HDDS
xtset a01 year

reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage 
predict double v2h_fef, r
xtpoisson hdds frm_div v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015  if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv ln_rinsd ln_tmpsd
drop v2h_fef

reghdfe frmdiv preff_frmdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage ln_rwet ln_rdry ln_tdry ln_twet
predict double v2h_fef, r
xtpoisson hdds frmdiv v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015  if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv ln_rinsd ln_tmpsd 
drop v2h_fef //shannon farm index


reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation year2012 year2015 , vce(r) absorb(a01) res //first stage
predict double v2h_fei, r
xtpoisson hdds inc_div v2h_fei ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation year2012 year2015, fe vce(r) //second stage

xtpoisson hdds frm_div inc_div v2h_fef v2h_fei ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh  lnfrm marketp market road irrigation year2012 year2015, fe vce(r) //second stage joint
drop v2h_fef v2h_fei


**2SRI fixed effect household food consumption expenditure

reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fef, r
reghdfe lnfexp frm_div v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm market road extension irrigation year2012 year2015 if frm_div<1, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
drop v2h_fef


reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm market road irrigation year2012 year2015 , vce(r) absorb(a01) res //first stage
predict double v2h_fei, r
reghdfe lnfexp inc_div v2h_fei ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw   Male age_hh hh_size schll_hh lnfrm market road irrigation year2012 year2015 , absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
drop v2h_fei


reghdfe lnfexp inc_div frm_div v2h_fef v2h_fei ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw   Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 , absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure joint

**weak IV
ivreghdfe lnfexp ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 (frm_div=preff_frm_div) if frm_div<1, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure

ivreghdfe lnfexp ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 (inc_div=preff_incdiv) if inc_div<1, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure

*robustness check
/*reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm marketp market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res 
reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm marketp market road irrigation year2012 year2015 , vce(r) absorb(a01) res 
*/

**heterogeneous analysis
xtset a01 year

*smallholder
sum farmsize, d
recode farmsize (min/47=1 "Yes")(47/max=0 "No"), gen("small")
label var small "Smallholder (=1 if yes)"
/*recode farmsize (min/50=1)(50/125=2)(125/222=3)(222/max=4), gen(q)
tab q, gen(q)

gen incq1=inc_div*q1
gen incq2=inc_div*q2
gen incq3=inc_div*q3

gen frmq1=frm_div*q1
gen frmq2=frm_div*q2
gen frmq3=frm_div*q3

gen pincq1=preff_incdiv*q1
gen pincq2=preff_incdiv*q2
gen pincq3=preff_incdiv*q3

gen pfrmq1=preff_frm_div*q1
gen pfrmq2=preff_frm_div*q2
gen pfrmq3=preff_frm_div*q3*/

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


/*output*/
**Descriptive statistics
eststo clear
sort year
by year: eststo: quietly estpost summarize hdds pc_foodxm_d frm_div inc_div  preff_frm_div preff_incdiv rw rs rr ra rsd tw ts tr ta tsd Male age_hh hh_size schll_hh farmsize market road extension irrigation if frm_div < 1, listwise

esttab using $table\dessta.tex, cells("mean(fmt(2)) sd(fmt(2))") label nodepvar replace addnote(Source: Bangladesh Integrated Household Survey 2011/12, 2015, 2018/19, 100 decimal is 0.4 ha, currency is Bangladesh taka)


**histgram of diversification index
twoway (kdensity inc_div if year==2012, color("blue%50") lp(solid))(kdensity inc_div if year==2015, color("purple%50") lp(dash))(kdensity inc_div if year==2018, color("red%50") lp(longdash)), title(Income diversificatioin index ) xtitle(Income diversification index) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(2 "2012" 1 "2015" 3 "2018")) saving(income) //hist of inc diversification index
twoway (kdensity frm_div if year==2012 & frm_div<1, color("blue%50") lp(solid))(kdensity frm_div if year==2015 & frm_div<1, color("purple%50") lp(dash))(kdensity frm_div if year==2018 & frm_div<1, color("red%50") lp(longdash)), title(Farm diversificatioin index) xtitle(Farm diversification) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(2 "2012" 1 "2015" 3 "2018")) saving(farm)  //hist of farm diversification index
gr combine income.gph farm.gph
graph display, scheme(s1mono) 
graph export $figure\div.pdf, replace

** bar graph
graph bar frm_div if frm_div < 1 & year==2012, over(small) legend( label(1 "Smallholder") label(0 "Not smallholder") ) ytitle(Farm diversification)   saving(2012frm)
graph bar inc_div if inc_div < 1 & year==2012, over(small) ytitle(Income diversification) saving(2012inc) legend( label(1 "Smallholder") label(0 "Not smallholder") )
graph bar frm_div if frm_div < 1 & year==2015, over(small) ytitle(Farm diversification)   saving(2015frm) legend( label(1 "Smallholder") label(0 "Not smallholder") )
graph bar inc_div if inc_div < 1 & year==2015, over(small) ytitle(Income diversification) saving(2015inc) legend( label(1 "Smallholder") label(0 "Not smallholder") )
graph bar frm_div if frm_div < 1 & year==2018, over(small) ytitle(Farm diversification)  saving(2018frm) legend( label(1 "Smallholder") label(0 "Not smallholder") )
graph bar inc_div if inc_div < 1 & year==2018, over(small) ytitle(Income diversification) saving(2018inc) legend( label(1 "Smallholder") label(0 "Not smallholder") )

gr combine 2012frm.gph 2012inc.gph note("Source: BIHS 2011/12, 15, 18/19")
graph display, scheme(s1mono) 
**first stage estimation
*first stage
eststo clear
xtset a01 year


/*eststo: xtreg frmdiv preff_frmdiv ln_rw ln_rs ln_rr ln_ra ln_tw ln_ts ln_tr ln_ta Male age_hh hh_size schll_hh lnfrm  irrigation year2012 year2015, vce(r) fe //first stage
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace*/

eststo: reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw ln_rinsd ln_tmpsd Male age_hh hh_size schll_hh lnfrm market road extension irrigation year2012 year2015  if frm_div<1, absorb(a01) vce(robust) res 

quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo: reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  ln_rinsd ln_tmpsd Male age_hh hh_size schll_hh lnfrm market road irrigation year2012 year2015 , vce(r) absorb(a01) res //first stage
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

esttab using $table\ffe_manu.tex,  b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order("\textbf{Peer effect}"  preff_frm_div preff_incdiv "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh lnfrm irrigation market road extension year2012 year2015) mtitles("Farm diversification" "Income diversification") r2 

esttab using $table\ffe.tex,  b(%4.3f) se replace wide nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep("\textbf{Peer Effect}" preff_frm_div preff_incdiv "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd ) order("\textbf{Peer Effect}"  preff_frm_div preff_incdiv "\textbf{Climate variables}"ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw) s(fe year control F N, label("HH FE" "Year dummy" "Control Variables" "F statistic" "Observations")) mtitles("Farm diversification " "Income diversification ")

*second stage analysis*
eststo clear
xtset a01 year

reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fef, r
eststo: xtpoisson hdds frm_div v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm market road extension irrigation year2012 year2015 if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace
quietly estadd local control Yes, replace
label var v2h_fef "Residual-farm"

eststo: reghdfe lnfexp frm_div v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm market road extension  irrigation year2012 year2015 if frm_div<1, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace


/*eststo: xtpoisson hdds frm_div inc_div v2h_fef v2h_fei ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm market road extension irrigation year2012 year2015 if frm_div < 1 , fe vce(r)
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace*/ //second stage joint


reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm market road irrigation year2012 year2015 , vce(r) absorb(a01) res //first stage
predict double v2h_fei, r
eststo: xtpoisson hdds inc_div  v2h_fei ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw   Male age_hh hh_size schll_hh lnfrm market road irrigation year2012 year2015, fe vce(r) //second stage 
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
label var v2h_fei "Residual-income"


eststo: reghdfe lnfexp inc_div v2h_fei ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm market road  irrigation year2012 year2015, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

/*eststo: reghdfe lnfexp inc_div frm_div v2h_fef v2h_fei ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm  market road extension irrigation year2012 year2015 if frm_div <1  , absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure joint
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace*/

esttab using $table\scnd.tex,  b(%4.3f) se replace nodepvar nogaps wide starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( "\textbf{Diversification}"  frm_div inc_div  "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd) order("\textbf{Diversification}"  frm_div inc_div   "\textbf{Climate variables}" ln_rw ln_rwet ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd) s(fe year control N, label("HH FE" "Year dummy" "Control Variables" "Observations")) addnote("Instrumental variables (\% of diversification within unions)")  mgroups("HDDS" "Per capita food expenditure (log)" , pattern(1 0  1 0 ))


esttab using $table\scnd_manu.tex,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order( "\textbf{Diversification}" frm_div inc_div  "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh lnfrm market road extension irrigation year2012 year2015 v2_fef v2h_fei ) addnote("Instrumental variables  (\% of diversification household within unions)") n mtitles("HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)")
drop v2h_fef v2h_fei 



**heterogeneous impact of livelihood diversification on food secuirty
eststo clear
xtset a01 year
*1st stage frm q
reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm market road extension irrigation year2012 year2015  if frm_div<1,  res vce(r) absorb(a01) //first stage
predict double res, r

reghdfe frms pfrms ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road extension irrigation year2012 year2015 if frm_div<1, res vce(r) absorb(a01) //first stage
predict double sres, r
**hdds frm q
eststo: xtpoisson hdds frm_div frms small res sres ln_ra ln_rr ln_rs ln_rw  ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road extension irrigation year2012 year2015 if frm_div<1, fe vce(r) //with interaction term
 

quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace

**lnfexp frm q
eststo: reghdfe lnfexp frm_div frms small res sres ln_ra ln_rr ln_rs ln_rw  ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road extension irrigation year2012 year2015 if frm_div<1, absorb(a01) vce(r) // with interaction term


label var res "Residual"
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace

drop res sres //v2h_fe2 v2h_fe3 


*1st stage inc
reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double res, r

reghdfe incs pincs ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh market road extension irrigation year2012 year2015 , res vce(r) absorb(a01) //first stage
predict double sres, r


**hdds inc q
eststo: xtpoisson hdds inc_div incs res sres small ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road irrigation year2012 year2015 , fe vce(r) //with interaction

quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace

**lnfexp inc q
eststo: reghdfe lnfexp inc_div incs res sres small ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road irrigation year2012 year2015 , absorb(a01) vce(r) //with interaction

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
esttab using $table\scnd_manu_hetero.tex,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep(frm_div inc_div incs frms small "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh  market road extension irrigation) order( frm_div inc_div incs frms small "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh  market road extension irrigation) s( fe year residual N, label( "HH FE" "Year dummy" "residual" "Observations")) mtitles("HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)")


***heterogeneous reference, without interaction
eststo clear
xtset a01 year
*1st stage frm q
reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm market road extension irrigation year2012 year2015  if frm_div<1,  res vce(r) absorb(a01) //first stage
predict double res, r

reghdfe frms pfrms ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road extension irrigation year2012 year2015 if frm_div<1, res vce(r) absorb(a01) //first stage
predict double sres, r

eststo: xtpoisson hdds frm_div small res ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road extension irrigation year2012 year2015 if frm_div<1, fe vce(r) //without interaction term
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace

eststo: reghdfe lnfexp frm_div small res ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road extension irrigation year2012 year2015 if frm_div<1, absorb(a01) vce(r) // without interaction term
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace
drop res sres

*1st stage inc
reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm market road irrigation year2012 year2015 if inc_div<1, vce(r) absorb(a01) res //first stage
predict double res, r

reghdfe incs pincs ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh market road extension irrigation year2012 year2015 , res vce(r) absorb(a01) //first stage
predict double sres, r

eststo: xtpoisson hdds inc_div res small ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road irrigation year2012 year2015 , fe vce(r) //without interaction

quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace

eststo: reghdfe lnfexp inc_div res small ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh market road irrigation year2012 year2015 , absorb(a01) vce(r) //without interaction
/*drop v2h_fe v2h_fe2 v2h_fe3 */
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local residual Yes, replace 
drop res sres

esttab using $table\scnd_hetero_woint.tex,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( frm_div inc_div small ) order( frm_div inc_div frmq2 frmq3  incq2 incq3  q2 q3 ) s(climate fe year control N, label("Climate variables" "HH FE" "Year dummy" "Control Variables" "Observations")) mtitles("HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)")
esttab using $table\scnd_manu_hetero_woint.tex,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep(frm_div inc_div small "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh  market road extension irrigation) order( frm_div inc_div incs frms small "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh  market road extension irrigation) s( fe year residual N, label( "HH FE" "Year dummy" "residual" "Observations")) mtitles("HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)")

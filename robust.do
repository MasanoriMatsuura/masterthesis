*Robustness checks

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
label var frmdiv "Farm diversification (Num of species of crop, livestock, and fish)"
label var shnf "Farm diversification (Shannon)"
label var lnfexp "Per capita food expenditure (log)"
label var hdds "HDDS"
sort uncode year
by uncode year: egen adaptation_nshi=count(a01) if shni>0
by uncode year: egen total_nshi=count(a01)
gen preff_shi=(adaptation_nshi-1)/total_nshi
save robust.dta, replace
*** First stage Tobit model
** first stage CRE
xtset a01 year

bysort a01: egen preff_frm_divb=mean(preff_frm_div)
bysort a01: egen preff_inc_divb=mean(preff_incdiv)
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
bysort a01: egen lvstckb=mean(lvstck)




** First stage
eststo clear
reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //to remove singleton

eststo: xttobit frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 preff_frm_divb ln_rab ln_rrb ln_rsb ln_rwb ln_rinsdb ln_tmpsdb ln_tab ln_trb ln_tsb ln_twb Maleb age_hhb hh_sizeb schll_hhb lvstckb lnfrmb marketb roadb extensionb irrigationb if frm_div<1 & _reghdfe_resid!=., ll(0)  
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

drop _reghdfe_resid

reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation year2012 year2015 , vce(r) absorb(a01) res //to remove singleton

eststo: xttobit inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw   Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation preff_inc_divb ln_rab ln_rrb ln_rsb ln_rwb ln_rinsdb ln_tmpsdb ln_tab ln_trb ln_tsb ln_twb Maleb age_hhb hh_sizeb schll_hhb lvstckb lnfrmb marketb roadb extensionb irrigationb year2012 year2015 if _reghdfe_resid!=., ll(0) 
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

esttab using $table\robust_first.tex,  b(%4.3f) se replace wide nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep("\textbf{Peer Effect}" preff_frm_div preff_incdiv ) order("\textbf{Peer Effect}"  preff_frm_div preff_incdiv) s( year control N, label("HH" "Year dummy" "Control Variables" "Observations")) ///
 mtitles("Farm diversification " "Income diversification")

esttab using $table\robust_first_full.tex,  b(%4.3f) se replace wide nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons s(year control N, label("HH"  "Year dummy" "Control Variables" "Observations")) mtitles("Farm diversification" "Income diversification") order("\textbf{Peer effect}"  preff_frm_div preff_incdiv "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh lnfrm lvstck irrigation market road extension year2012 year2015) keep("\textbf{Peer effect}"  preff_frm_div preff_incdiv "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh lnfrm lvstck irrigation market road extension year2012 year2015)

** Second stage
*farm diversification
eststo clear
reghdfe frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //to remove singleton

xttobit frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 preff_frm_divb ln_rab ln_rrb ln_rsb ln_rwb ln_rinsdb ln_tmpsdb ln_tab ln_trb ln_tsb ln_twb Maleb age_hhb hh_sizeb schll_hhb lvstckb lnfrmb marketb roadb extensionb irrigationb if frm_div<1 & _reghdfe_resid!=., ll(0) vce(bootstrap)

/*xttobit frm_div preff_frm_div ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frm_div<1, ll(0)*/
predict double xb, ystar(0,1)
gen v2h_fef=frm_div-xb


*hdds
eststo: xtpoisson hdds frm_div v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015  if frm_div<1, fe vce(r)
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

*food expenditure
eststo: reghdfe lnfexp frm_div v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frm_div<1, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

drop v2h_fef xb _reghdfe_resid

**income diversification
reghdfe inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation year2012 year2015 , vce(r) absorb(a01) res //to remove singleton


xttobit inc_div preff_incdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw   Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation preff_inc_divb ln_rab ln_rrb ln_rsb ln_rwb ln_rinsdb ln_tmpsdb ln_tab ln_trb ln_tsb ln_twb Maleb age_hhb hh_sizeb schll_hhb lvstckb lnfrmb marketb roadb extensionb irrigationb year2012 year2015 if _reghdfe_resid!=., ll(0) 
predict double xb, ystar(0,1)
gen v2h_fei=inc_div-xb


*hdds
eststo: xtpoisson hdds inc_div v2h_fei ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation year2012 year2015, fe vce(r)
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

*food expenditure
eststo: reghdfe lnfexp inc_div v2h_fei ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw   Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation year2012 year2015 , absorb(a01) vce(r) 
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
label var v2h_fef "Residual-farm"
label var v2h_fei "Residual-income"
drop v2h_fei xb _reghdfe_resid


esttab using $table\robust_tobit.tex,  b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( "\textbf{Diversification}"  frm_div inc_div) order("\textbf{Diversification}"  frm_div inc_div ) s(fe year control N, label("HH FE" "Year dummy" "Control Variables" "Observations")) addnote("Instrumental variables (\% of diversification within unions)") 

esttab using $table\robust_tobit_full.tex,  b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons addnote("Instrumental variables (\% of diversification within unions)") order( "\textbf{Diversification}" frm_div inc_div  "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 ) s(control N, label("HH FE" "Year dummy" "Control Variables" "Observations"))


*** Alternative indicators
** count of farm products
eststo clear
xtset a01 year

reghdfe frmdiv preff_frmdiv ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frmdiv>0, vce(r) absorb(a01) res //first stage
predict double v2h_fef, r
eststo: xtpoisson hdds frmdiv v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frmdiv>0, fe vce(r) //second stage  idcrp idliv idi_crp_liv
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace
quietly estadd local control Yes, replace
label var v2h_fef "Residual-farm"

eststo: reghdfe lnfexp frmdiv v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension  irrigation year2012 year2015  if frmdiv>0, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

drop v2h_fef

** shannon index

reghdfe shnf preff_shf ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fef, r

eststo: xtpoisson hdds shnf v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frm_div<1, fe vce(r) //second stage  idcrp idliv idi_crp_liv
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace
quietly estadd local control Yes, replace
label var v2h_fef "Residual-farm"

eststo: reghdfe lnfexp shnf v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension  irrigation year2012 year2015 if frm_div<1, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace


/*eststo: xtpoisson hdds frm_div inc_div v2h_fef v2h_fei ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lnfrm market road extension irrigation year2012 year2015 if frm_div < 1 , fe vce(r)
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace*/ //second stage joint


reghdfe shni preff_shi ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation year2012 year2015 if shni>=0, vce(r) absorb(a01) res //first stage
predict double v2h_fei, r

eststo: xtpoisson hdds shni v2h_fei ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw   Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation year2012 year2015 if shni>=0, fe vce(r) //second stage 
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
label var v2h_fei "Residual-income"


eststo: reghdfe lnfexp shni v2h_fei ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road  irrigation year2012 year2015 if shni>=0, absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

/*eststo: reghdfe lnfexp inc_div frm_div v2h_fef v2h_fei ln_ra ln_rr ln_rs ln_rw ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lnfrm  market road extension irrigation year2012 year2015 if frm_div <1  , absorb(a01) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure joint
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace*/
label var v2h_fef "Residual-farm"
label var v2h_fei "Residual-income"
drop v2h_fef v2h_fei 

esttab using $table\robust_alt.tex,  b(%4.3f) se replace nogaps wide starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( "\textbf{Diversification}"  frmdiv shnf shni ) order("\textbf{Diversification}"  frmdiv shnf shni ) s(fe year control N, label("HH FE" "Year dummy" "Control Variables" "Observations")) addnote("Instrumental variables (\% of diversification within unions)")  


esttab using $table\robust_alt_full.tex,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order( "\textbf{Diversification}" frmdiv shnf shni  "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 v2_fef v2h_fei ) addnote("Instrumental variables  (\% of diversification household within unions)") n mtitles("HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)")


** household expenditure

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
label var shnc "Farm diversification (Shannon)"
label var lnfexp "Per capita food expenditure (log)"
label var hdds "HDDS"
label var preff_shc "share of households adopting farm diversification within the union"
label var preff_shi "share of households adopting income diversification within the union"
save robust.dta, replace


** shannon index
** First stage
eststo clear
reghdfe frm_div extension srshock rrshock arshock wrshock  stshock rtshock atshock wtshock Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res 

eststo: reghdfe shnc preff_shc srshock rrshock arshock wrshock  stshock rtshock atshock wtshock Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation, vce(r) absorb(a01 year) //first stage
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo: reghdfe shni preff_shi srshock rrshock arshock wrshock  stshock rtshock atshock wtshock  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension, vce(r) absorb(a01 year)
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

esttab using $table\robust_first.rtf,  b(%4.3f) se replace wide nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep("\textbf{Peer Effect}" preff_shc preff_shi ) order("\textbf{Peer Effect}"  preff_shc preff_shi) s( fe year control N, label("Individual FE" "Year FE" "Control Variables" "Observations")) 

esttab using $table\robust_first_full.rtf,  b(%4.3f) se replace wide nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons s(fe year  N, label("Individual FE"  "Year FE" "Observations"))  order(  preff_shc preff_shi srshock rrshock arshock wrshock  stshock rtshock atshock wtshock Male age_hh hh_size schll_hh lnfrm lvstck irrigation market road extension) keep( preff_shc preff_shi srshock rrshock arshock wrshock  stshock rtshock atshock wtshock  Male age_hh hh_size schll_hh lnfrm lvstck irrigation market road extension )


** Second stage
eststo clear
xtset a01 year

reghdfe shnc preff_shc srshock rrshock arshock wrshock  stshock rtshock atshock wtshock Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation, vce(r) absorb(a01 year) res //first stage
predict double v2h_fec, r

eststo: xtpoisson hdds shnc v2h_fec srshock rrshock arshock wrshock  stshock rtshock atshock wtshock  Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015, fe vce(r) //second stage  idcrp idliv idi_crp_liv
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace
quietly estadd local control Yes, replace
label var v2h_fec "Residual-crop"

eststo: ivreghdfe lnexp srshock rrshock arshock wrshock  stshock rtshock atshock wtshock  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension (shnc=preff_shc), absorb(a01 year) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace



reghdfe shni preff_shi srshock rrshock arshock wrshock  stshock rtshock atshock wtshock Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension, vce(r) absorb(a01 year) res //first stage
predict double v2h_fei, r

eststo: xtpoisson hdds shni v2h_fei srshock rrshock arshock wrshock  stshock rtshock atshock wtshock Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension year2012 year2015, fe vce(r) //second stage 
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
label var v2h_fei "Residual-income"


eststo: ivreghdfe lnfexp srshock rrshock arshock wrshock  stshock rtshock atshock wtshock Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation (shni=preff_shi), absorb(a01 year) vce(r) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fec v2h_fei 

esttab using $table\robust_alt.rtf,  b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( "\textbf{Diversification}"  shnc shni ) order("\textbf{Diversification}" shnc shni ) s(fe year control N, label("Individual FE" "Year FE" "Control Variables" "Number of households")) addnote("Instrumental variables (\% of households adopting diversification within the union)")  mtitles("HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)")


esttab using $table\robust_alt_full.rtf,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order(shnc shni   srshock rrshock arshock wrshock  stshock rtshock atshock wtshock  Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation v2h_fec v2h_fei ) keep(shnc shni   srshock rrshock arshock wrshock  stshock rtshock atshock wtshock  Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation v2h_fec v2h_fei) addnote("Instrumental variables  (\% of households adopting diversification within the union)") n mtitles("HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)")  s(fe year  N, label("Individual FE" "Year FE"  "Number of households"))




*robust quantile frm
eststo clear
xtset a01 year

** quantile frm
reghdfe shnf preff_shf ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frm_div<1, vce(r) absorb(a01) res //first stage
predict double v2h_fef, r
eststo: xtqreg lnfexp shnf v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frm_div<1, i(a01) quantile( .25 ) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo: xtqreg lnfexp  shnf v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frm_div<1, i(a01) quantile(  .5  ) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo: xtqreg lnfexp shnf v2h_fef ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 if frm_div<1, i(a01) quantile( .75 ) //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fef

**quantile inc
reghdfe shni preff_shi ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw  Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation  extension year2012 year2015 , vce(r) absorb(a01) res //first stage
predict double v2h_fei, r

eststo: xtqreg lnfexp shni v2h_fei ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw   Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension year2012 year2015, i(a01) quantile(.25)  //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
eststo: xtqreg lnfexp shni v2h_fei ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw   Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension  year2012 year2015, i(a01) quantile(  .5 )  //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
eststo: xtqreg lnfexp shni v2h_fei ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_tmpsd ln_ta ln_tr ln_ts ln_tw   Male age_hh hh_size schll_hh lvstck lnfrm market road irrigation extension  year2012 year2015, i(a01) quantile(  .75)  //second stage  idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
drop v2h_fei 

esttab using $table\quantile_robust.tex,  b(%4.3f) se replace nogaps nodepvar wide starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep( "\textbf{Diversification}" shnf shni ) order("\textbf{Diversification}" shnf shni ) s(fe year control N, label("FE" "Year dummy" "Control Variables" "Observations")) addnote("Instrumental variables (\% of diversification within unions)") mtitles("\nth{25} quantile" "\nth{50} quantile" "\nth{75} quantile" "\nth{25} quantile" "\nth{50} quantile" "\nth{75} quantile")


esttab using $table\quantile_full_robust.tex,  b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order( "\textbf{Diversification}" shnf shni  "\textbf{Climate variables}" ln_ra ln_rr ln_rs ln_rw ln_rinsd ln_ta ln_tr ln_ts ln_tw ln_tmpsd "\textbf{Control variables}" Male age_hh hh_size schll_hh lvstck lnfrm market road extension irrigation year2012 year2015 v2_fef v2h_fei ) addnote("Instrumental variables  (\% of diversification household within unions)") n mtitles("\nth{25} quantile" "\nth{50} quantile" "\nth{75} quantile" "\nth{25} quantile" "\nth{50} quantile" "\nth{75} quantile")


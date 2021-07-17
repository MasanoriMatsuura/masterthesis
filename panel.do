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
save panel.dta, replace

/*some cleaning*/
gen lnfrm=log(farmsize) // logarithem of farm size 100 decimal = 0.4 ha
label var lnfrm "Farmsize (log)"
recode year (2012=1)(nonm=0), gen(year2012) //year dummy
recode year (2015=1)(nonm=0), gen(year2015)
label var year2012 "Year 2012"
label var year2015 "Year 2015"

recode dvcode (55=1)(nonm=0), gen(Rangpur)
label var Rangpur "Rangpur division (dummy)"

gen rinmn2=rinmn_1000*rinmn_1000
label var rinmn2 "Yearly mean rainfall^2"
gen lnrinmn2=log(rinmn2)
gen tmpmn2=tmpmn*tmpmn
label var tmpmn2 "Monthly mean temperature^2"
gen lntmpmn2=log(tmpmn2)
/*determinants of crop diversification*/
bysort year: summarize crp_div frmdivnm rinmn_1000 rinsd_1000 tmpmn tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh farmsize 
**pooled ols
bysort year: reg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size edu_hh  farmsize , vce(robust) //better than cluster

reg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size edu_hh  farmsize , cl(dcode)

reg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size edu_hh  lnfrm , vce(robust) //better than cluster
**fixed ols
xtset a01 year
xtreg crp_div rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd idcrp Male age_hh hh_size schll_hh lnfrm year2012, vce(robust) fe //better than cluster crp index
xtreg frmdivnm rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd idcrp Male age_hh hh_size schll_hh lnfrm year2012, vce(robust) fe //better than cluster crop number

xtreg crp_div ln_rinmn  rinsd_1000 ln_tmpmn  tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size edu_hh lnfrm  , vce(robust) fe //better than cluster

xtreg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd Male age_hh hh_size edu_hh  lnfrm , vce(robust) fe //better than cluster
xtreg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp Male age_hh hh_size edu_hh  lnfrm , vce(robust) fe //better than cluster

**pooled tobit
tobit crp_div rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp Male age_hh hh_size schll_hh  lnfrm year2012 year2015, vce(robust) ll(0)   //better than cluster, most reliable crop index, square climate
tobit frmdivnm rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp Male age_hh hh_size schll_hh  lnfrm year2012 year2015, vce(robust) ll(0)   //better than cluster, most reliable  crop number, square climate

tobit crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd  idcrp Male age_hh hh_size schll_hh  lnfrm year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable, crop index

tobit frmdivnm ln_rinmn rinsd_1000 ln_tmpmn tmpsd  idcrp Male age_hh hh_size schll_hh  lnfrm year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable, crop number

**random tobit
xttobit crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd  Male age_hh hh_size schll_hh  lnfrm, ll(crp_div)
xttobit crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd  Male age_hh hh_size schll_hh  lnfrm, vce(boot)

**output
**Descriptive statistics
eststo clear
by year: eststo: quietly estpost summarize frmdivnm crp_div rinmn_1000 rinsd_1000 tmpmn tmpsd idcrp Male age_hh hh_size schll_hh farmsize Rangpur, listwise

esttab using $table\dessta.tex, cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") label nodepvar replace
**histgram of diversification index
twoway (kdensity crp_div if year==2012, color("blue%50"))(kdensity crp_div if year==2015, color("purple%50"))(kdensity crp_div if year==2018, color("red%50")), title(Crop diversificatioin index ) xtitle(Crop diversification index) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(2 "2012" 1 "2015" 3 "2018")) //hist of crop diversification index
graph display, scheme(s1mono)
graph export $figure\crpdiv.pdf, replace
**first stage estimation
*tobit
eststo clear
eststo: tobit crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp Male age_hh hh_size schll_hh  lnfrm year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable
eststo: tobit frmdivnm ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp Male age_hh hh_size schll_hh  lnfrm year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable
eststo: tobit crp_div rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp Male age_hh hh_size schll_hh  lnfrm year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable  crop index, square climate
eststo: tobit frmdivnm rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp Male age_hh hh_size schll_hh  lnfrm year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable  crop number, square climate
esttab using $table\tbt.tex,  se replace nodepvars nogaps starlevels(* 0.05 ** 0.01 *** 0.001) b(%4.3f) label nocons
*fixed effect 
eststo clear
xtset a01 year
eststo: xtreg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp Male age_hh hh_size schll_hh lnfrm year2012, vce(robust) fe //better than cluster
eststo: xtreg frmdivnm ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp Male age_hh hh_size schll_hh lnfrm year2012, vce(robust) fe //better than cluster
eststo: xtreg crp_div rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp Male age_hh hh_size schll_hh lnfrm year2012, vce(robust) fe
eststo: xtreg frmdivnm rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp Male age_hh hh_size schll_hh lnfrm year2012, vce(robust) fe
esttab using $table\ffe.tex,  se replace nodepvars nogaps starlevels(* 0.05 ** 0.01 *** 0.001) b(%4.3f) label nocons 

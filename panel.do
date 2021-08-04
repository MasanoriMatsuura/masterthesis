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
save panel.dta, replace

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

gen rinmn2=rinmn_1000*rinmn_1000
label var rinmn2 "Yearly mean rainfall^2"
gen lnrinmn2=log(rinmn2)
gen tmpmn2=tmpmn*tmpmn
label var tmpmn2 "Monthly mean temperature^2"
gen lntmpmn2=log(tmpmn2)
label var frmdiv "Farm diversification (Num of species of crop, livestocks, and fish)"

/*determinants of crop diversification*/
bysort year: summarize crp_div frmdiv inc_div rinmn_1000 rinsd_1000 tmpmn tmpsd idcrp idliv Male age_hh hh_size schll_hh farmsize 
**pooled ols
bysort year: reg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size edu_hh  farmsize , vce(robust) //better than cluster

reg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size edu_hh  farmsize , cl(dcode)

reg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size edu_hh  lnfrm , vce(robust) //better than cluster
**fixed ols
xtset a01 year
xtreg crp_div rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd idcrp Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015, vce(robust) fe //better than cluster crp index
xtreg frmdiv rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015, vce(robust) fe //better than cluster farm diversificatioin
xtreg inc_div rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015, vce(robust) fe //better than cluster income diversificatioin

xtreg crp_div ln_rinmn  rinsd_1000 ln_tmpmn  tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size edu_hh lnfrm  , vce(robust) fe //better than cluster

xtreg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd Male age_hh hh_size edu_hh  lnfrm , vce(robust) fe //better than cluster
xtreg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp Male age_hh hh_size edu_hh  lnfrm , vce(robust) fe //better than cluster

**mixed effect
metobit
meintreg
**panel poisson
xtset a01 year
xtpoisson frmdivnm ln_rinmn  rinsd_1000 ln_tmpmn  tmpsd idcrp Male age_hh hh_size edu_hh lnfrm year2012, vce(robust) fe
xtpoisson frmdivnm rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp Male age_hh hh_size schll_hh  lnfrm year2012, vce(robust) fe

**pooled tobit
tobit crp_div rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp Male age_hh hh_size schll_hh  lnfrm irrigation year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable crop index, square climate
tobit frmdiv rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh  lnfrm irrigation year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable  farm div number, square climate
tobit inc_div rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 Rangpur, vce(robust) ll(0) // robust income div, square climate

tobit crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd  idcrp Male age_hh hh_size schll_hh  lnfrm year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable, crop index

tobit frmdivnm ln_rinmn rinsd_1000 ln_tmpmn tmpsd  idcrp Male age_hh hh_size schll_hh  lnfrm year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable, crop number

**SUR 
sureg (crp_div rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp Male age_hh hh_size schll_hh  lnfrm irrigation year2012 year2015 Rangpur) (frmdiv rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh  lnfrm irrigation year2012 year2015 Rangpur) (inc_div rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh  lnfrm  irrigation year2012 year2015 Rangpur)

**random tobit
xtset a01 year
xttobit crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd  Male age_hh hh_size schll_hh  lnfrm year2012, ll(0) 
xttobit frmdivnm ln_rinmn rinsd_1000 ln_tmpmn tmpsd  Male age_hh hh_size schll_hh  lnfrm year2012, ll(0) 

**second stage analysis from adaptation to dietary diversity
xtset a01 year
xtivreg  hdds idcrp Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015 (crp_div = rinsd_1000 tmpsd rinmn_1000 rinmn2  tmpmn tmpmn2 ),vce(r) fe
xtivreg hdds idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015 (frmdiv = rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd ), vce(r) fe //better than cluster farm diversificatioin
xtivreg hdds  idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015 (inc_div = rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd), vce(robust) fe //better than cluster income diversificatioin


xtivreg  hdds idcrp lninc Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015 (crp_div = rinsd_1000 tmpsd rinmn_1000 rinmn2  tmpmn tmpmn2 ),vce(r) fe
xtivreg hdds idcrp idliv idi_crp_liv lninc Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015 (frmdiv = rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd ), vce(r) fe //better than cluster farm diversificatioin
xtivreg hdds  idcrp idliv idi_crp_liv lninc Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015 (inc_div = rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd), vce(robust) fe //better than cluster income diversificatioin

/*output*/
**Descriptive statistics
eststo clear
sort year
by year: eststo: quietly estpost summarize hdds crp_div frmdiv inc_div rinmn_1000 rinsd_1000 tmpmn tmpsd idcrp idliv ttinc10000 Male age_hh hh_size schll_hh farmsize Rangpur, listwise

esttab using $table\dessta.tex, cells("mean(fmt(2)) sd(fmt(2))") label nodepvar replace
**histgram of crop diversification index
twoway (kdensity crp_div if year==2012, color("blue%50"))(kdensity crp_div if year==2015, color("purple%50"))(kdensity crp_div if year==2018, color("red%50")), title(Crop diversificatioin index ) xtitle(Crop diversification index) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(2 "2012" 1 "2015" 3 "2018")) //hist of crop diversification index
graph display, scheme(s1mono)
graph export $figure\crpdiv.pdf, replace
**histgram of income diversification index
twoway (kdensity inc_div if year==2012, color("blue%50"))(kdensity inc_div if year==2015, color("purple%50"))(kdensity inc_div if year==2018, color("red%50")), title(Income diversificatioin index ) xtitle(Income diversification index) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(2 "2012" 1 "2015" 3 "2018")) //hist of inc diversification index
graph display, scheme(s1mono)
graph export $figure\incdiv.pdf, replace

**histgram of farm diversification index
twoway (hist frmdiv if year==2012, color("blue%50"))(hist frmdiv if year==2015, color("purple%50"))(hist frmdiv if year==2018, color("red%50")), title(Farm diversificatioin) xtitle(Farm diversification index) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(2 "2012" 1 "2015" 3 "2018")) //hist of inc diversification index
graph display, scheme(s1mono)
graph export $figure\frmdiv.pdf, replace

**first stage estimation
*tobit
eststo clear
eststo: tobit crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp Male age_hh hh_size schll_hh  lnfrm year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable
eststo: tobit frmdiv ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp Male age_hh hh_size schll_hh  lnfrm year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable
*climate square term
eststo: tobit crp_div rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp Male age_hh hh_size schll_hh  lnfrm year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable  crop index, square climate
eststo: tobit frmdiv rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh  lnfrm year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable  crop number, square climate
eststo: tobit inc_div rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh  lnfrm year2012 year2015 Rangpur, vce(robust) ll(0)   //better than cluster, most reliable  crop number, square climate
esttab using $table\tbt.tex, se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) b(%4.3f) label nocons 

*fixed effect 
eststo clear
xtset a01 year
eststo: xtreg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp Male age_hh hh_size schll_hh lnfrm year2012, vce(robust) fe //better than cluster
eststo: xtreg frmdiv ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp Male age_hh hh_size schll_hh lnfrm year2012, vce(robust) fe //better than cluster  farm diversificatioin
*climate square term
eststo: xtreg crp_div rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp Male age_hh hh_size schll_hh lnfrm year2012 year2015, vce(robust) fe 
eststo: xtreg frmdiv rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh lnfrm year2012 year2015, vce(robust) fe
eststo: xtreg inc_div rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd  idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh lnfrm year2012 year2015, vce(robust) fe
esttab using $table\ffe.tex,  b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons  

*second stage analysis*
eststo clear
xtset a01 year
eststo: xtivreg  hdds idcrp lninc Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015 (crp_div = rinsd_1000 tmpsd rinmn_1000 rinmn2  tmpmn tmpmn2 ),vce(r) fe
eststo: xtivreg hdds idcrp idliv idi_crp_liv lninc Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015 (frmdiv = rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd ), vce(r) fe //better than cluster farm diversificatioin
eststo: xtivreg hdds  idcrp idliv idi_crp_liv  lninc Male age_hh hh_size schll_hh lnfrm irrigation year2012 year2015 (inc_div = rinmn_1000 rinmn2 rinsd_1000 tmpmn tmpmn2 tmpsd), vce(robust) fe //better than cluster income diversificatioin
esttab using $table\scnd.tex,  b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep(crp_div frmdiv inc_div idcrp idliv idi_crp_liv) o(crp_div frmdiv inc_div idcrp idliv idi_crp_liv)addnote("Instrumental variables are agroclimate variables (rainfall, temperatures)") mtitles("HDDS" "HDDS" "HDDS")

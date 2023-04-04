/*Climate Variability, Livelihood Diversification, and Household Food Security: analysis*/
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
global table = "C:\Users\user\Documents\Masterthesis\NTUtemplate\table"
global figure = "C:\Users\user\Documents\Masterthesis\NTUtemplate\figures"
cd "C:\Users\user\Documents\Masterthesis\BIHS\Do"
//use panel.dta, clear 
/*creating a panel dataset*/
use C:\Users\user\Documents\research\saiful\mobile_phone\BIHS\Do\panel, clear

/*some cleaning*/
replace crp_div=. if crp_div==1
replace inc_div=. if inc_div==1
replace shnc=. if crp_div==1
replace shni=. if inc_div==1
replace irrigation=0 if irrigation==.
*create peer effect variables
recode crp_div (0=0)(nonm=1), gen(crp_div_i)
recode inc_div (0=0)(nonm=1), gen(inc_div_i)
recode shnc (0=0)(nonm=1), gen(shnc_i)
recode shni (0=0)(nonm=1), gen(shni_i)

sort uncode year
drop total_nc
by uncode year: egen adaptation_nc=sum(crp_div_i) 
by uncode year: egen total_nc=count(a01)
gen preff_crp_div=(adaptation_nc-crp_div_i)/(total_nc) //creating peer effect
sort uncode year
by uncode year: egen adaptation_ni=sum(inc_div_i) 
by uncode year: egen total_ni=count(a01)
gen preff_incdiv=(adaptation_ni-inc_div_i)/(total_ni) //creating peer effect
sort uncode year
by uncode year: egen adaptation_nshc=sum(shnc_i)
by uncode year: egen total_nshc=count(a01)
gen preff_shc=(adaptation_nshc-shnc_i)/(total_nshc) //creating peer effect shannon crop
sort uncode year
by uncode year: egen adaptation_nshi=sum(shni_i)
by uncode year: egen total_nshi=count(a01)
gen preff_shi=(adaptation_nshi-shni_i)/(total_nshi) //creating peer effect shannon income

label var preff_crp_div "Share of households adopting crop diversification within the union"
label var preff_incdiv "Share of households adopting income diversification within the union"
label var lstshock "Temperature shock 1-year lag in Kharif"
label var lrtshock "Temperature shock 1-year lag in Rabi"

gen lnhrt=log(hst)
gen lnhkt=log(lrt)
label var lnhrt "20-year average temperature in Kharif(log)"
label var lnhkt "20-year average temperature in Rabi(log)"
*shannon index
label var shnc "Crop diversificaion (Shannon)"
label var shni "Income diversification (Shannon)"


/*label market participation variable
label var marketp "Market participation (=1 if yes)"*/
save panel.dta, replace

export delimited using panel.csv, replace //output as csv
bysort year: sum lrtshock lstshock
kdensity lrtshock
** dependent variable by regional level
collapse (mean) divfexp=pc_foodxm_d divhdds=hdds, by(dcode)
destring(dcode), replace
save dependent.dta, replace
**Visualization

label var lnfexp "Per capita food consumption expenditure(log)"
graph twoway (scatter hdds farmsize , msymbol(circle_hollow) yaxis(1) ytitle("HDDS", axis(1))) (scatter lnfexp farmsize, msymbol(triangle_hollow) yaxis(2) ytitle("Per capita food consumption expenditure(log)", axis(2))), xtitle("Farmland size (decimal)")  title("Household food security over the scale of farmers")  note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author")
graph display, scheme(s1mono) 
graph export $figure\fsecurity_farm.png, replace


/*output*/
**Descriptive statistics
eststo clear
sort year

by year: summarize hdds pc_foodxm_d crp_div inc_div preff_crp_div preff_incdiv floodkl droughtrl lstshock Male age_hh hh_size schll_hh asset lnfrm market road extension irrigation if hdds!=.

**Breakdown of farmland
use $BIHS18Male\021_bihs_r3_male_mod_h1, clear //crop diversification 
rename crop_a_h1 crop_a
gen year=2018
append using $BIHS15\015_r2_mod_h1_male
replace year=2015 if year==.
append using $BIHS12\011_mod_h1_male
replace year=2012 if year==.
rename  h1_03 plntd
keep a01 crop_a  plntd year
recode crop_a (10/30=1 "Major cereals")(41/45=2 "Fiber crops" ) (51/59=3 "Pulses")(61/67=4 "Oil seeds")(71/77=5 "Spices")(101/131=6 "Vegetables")(201/213=7 "Leafy vegetables")(301/326=8 "Fruits")(411/900=9 "Other crops"), gen(crop_type)
collapse (sum) typ_plntd=plntd, by(crop_type year)
graph pie typ_plntd, over(crop_type) by(year) plabel(4 percent,  format("%2.0f") color(white)) plabel(3 percent,  format("%2.0f") color(white))plabel(2 percent,  format("%2.0f") color(white)) plabel(1 percent,  format("%2.0f") color(white)) legend(size(*0.8) c(4))
graph display, scheme(s1mono)
graph export $figure\farmallocation.png, replace

**histgram of diversification index
twoway (kdensity inc_div if year==2012, color("blue%50") lp(solid))(kdensity inc_div if year==2015, color("purple%50") lp(dash))(kdensity inc_div if year==2018, color("red%50") lp(longdash)), title(Income diversificatioin index ) xtitle(Income diversification index) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(1 "2012" 2 "2015" 3 "2018")) saving(income) //hist of inc diversification index
twoway (kdensity crp_div if year==2012 , color("blue%50") lp(solid))(kdensity crp_div if year==2015 , color("purple%50") lp(dash))(kdensity crp_div if year==2018 , color("red%50") lp(longdash)), title(Crop diversificatioin index) xtitle(Crop diversification) ytitle(Density)note(Source: "BIHS2011/12, 2015, and 2018/19 calculated by author") legend(ring(0) pos(2) col(1) order(1 "2012" 2 "2015" 3 "2018")) saving(crop)  //hist of crop diversification index
gr combine income.gph crop.gph
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
eststo clear
xtset a01 year
eststo: reghdfe crp_div preff_crp_div floodkl droughtrl lstshock Male age_hh hh_size schll_hh asset lnfrm market road extension irrigation year2012 year2015, absorb(a01) vce(robust) // ln_sdst ln_sdrt

quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo: reghdfe inc_div preff_incdiv floodkl droughtrl lstshock Male age_hh hh_size schll_hh asset lnfrm market road extension irrigation year2012 year2015, vce(r) absorb(a01)  //first stage ln_sdst ln_sdrt
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace


esttab using $table\1st_manu.rtf,  b(%4.3f) se replace nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order(preff_crp_div preff_incdiv floodkl droughtrl lstshock Male age_hh hh_size schll_hh lnfrm irrigation market road extension) mtitles("Crop diversification" "Income diversification") s(fe year N, label("Individual FE" "Year FE" "Observations")) 


*second stage analysis*
eststo clear
xtset a01 year

reghdfe crp_div preff_crp_div floodkl droughtrl lstshock Male age_hh hh_size schll_hh asset lnfrm market road extension irrigation year2012 year2015, vce(r) absorb(a01) res //first stage
predict double v2h_fec, r

eststo: bootstrap: xtpoisson hdds crp_div v2h_fec Male age_hh hh_size schll_hh asset lnfrm market road extension irrigation year2012 year2015 , fe vce(r) //second stage srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat  
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace
quietly estadd local control Yes, replace
label var v2h_fec "Residual-crop"

eststo: ivreghdfe lnexp Male age_hh hh_size schll_hh asset lnfrm market road irrigation extension year2012 year2015 (crp_div=preff_crp_div floodkl droughtrl lstshock), absorb(a01) vce(r) //second stage  floodr floodk stshock rtshock droughtkl droughtrl 
quietly estadd local fe Yes, replace
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

reghdfe inc_div preff_incdiv floodkl droughtrl lstshock Male age_hh hh_size schll_hh asset lnfrm market road irrigation extension year2012 year2015, vce(r) absorb(a01) res //first stage
predict double v2h_fei, 


eststo: bootstrap: xtpoisson hdds inc_div v2h_fei Male age_hh hh_size schll_hh asset lnfrm market road irrigation extension year2012 year2015, fe vce(r) //second stage  srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
label var v2h_fei "Residual-income"


eststo: ivreghdfe lnfexp Male age_hh hh_size schll_hh asset lnfrm market road extension irrigation year2012 year2015 (inc_div=preff_incdiv floodkl droughtrl lstshock), absorb(a01) vce(r) //second stage idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo: bootstrap: xtpoisson hdds crp_div inc_div v2h_fec v2h_fei Male age_hh hh_size schll_hh asset lnfrm market road irrigation extension year2012 year2015, fe vce(r) //second stage  srshock rrshock arshock wrshock ln_sds ln_sdr ln_sda ln_sdw stshock rtshock atshock wtshock ln_sdst ln_sdrt ln_sdat ln_sdwt
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace
label var v2h_fei "Residual-income"


eststo: ivreghdfe lnfexp Male age_hh hh_size schll_hh asset lnfrm market road extension irrigation year2012 year2015 (crp_div inc_div=preff_crp_div preff_incdiv floodkl droughtrl lstshock), absorb(a01) vce(r) //second stage idcrp idliv idi_crp_liv, food expenditure
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace


esttab using $table\scnd_manu.rtf,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order( crp_div inc_div Male age_hh hh_size schll_hh asset lnfrm market road extension irrigation v2h_fec v2h_fei) s(fe year N, label("Individual FE" "Year FE" "Observations")) addnote("Instrumental variables (\% of households adopting diversification within a union)") mtitles("HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)" "HDDS" "Per capita food expenditure (log)")

** Quantile regression 
eststo clear
xtset a01 year
** quantile fe-ols
eststo: bootstrap: xtqreg lnfexp crp_div v2h_fec Male age_hh hh_size schll_hh asset lnfrm market road irrigation extension year2012 year2015 if _reghdfe_resid!=., q(0.10) i(a01)  //second stage 
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo:  bootstrap:xtqreg lnfexp crp_div v2h_fec Male age_hh hh_size schll_hh asset lnfrm market road irrigation extension year2012 year2015 if _reghdfe_resid!=., q(0.5) i(a01) //second stage 
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo: bootstrap: xtqreg lnfexp crp_div v2h_fec Male age_hh hh_size schll_hh asset lnfrm market road irrigation extension year2012 year2015 if _reghdfe_resid!=., q(0.90) i(a01) //second stage 
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

**quantile inc
eststo:  bootstrap: xtqreg lnfexp inc_div v2h_fei Male age_hh hh_size schll_hh asset lnfrm market road irrigation extension year2012 year2015 if _reghdfe_resid!=., q(0.10) i(a01)
 //second stage  
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo:  bootstrap: xtqreg lnfexp inc_div v2h_fei Male age_hh hh_size schll_hh asset lnfrm market road irrigation extension  year2012 year2015 if _reghdfe_resid!=., q(0.5) i(a01)  //second stage  
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

eststo:  bootstrap: xtqreg lnfexp inc_div v2h_fei Male age_hh hh_size schll_hh asset lnfrm market road irrigation extension  year2012 year2015 if _reghdfe_resid!=., i(a01) quantile(  .90)   //second stage  
quietly estadd local fe Yes, replace //add the raw of fe, year dummy, and control variables
quietly estadd local year Yes, replace 
quietly estadd local control Yes, replace

esttab using $table\quantile.rtf,  b(%4.3f) se replace nogaps nodepvar starlevels(* 0.1 ** 0.05 *** 0.01) label nocons keep(   crp_div inc_div ) order(crp_div inc_div) s(fe year control N, label("Individual FE" "Year FE" "Control Variables" "Observations")) addnote("Instrumental variables (\% of household adopting diversification within a union)")  mtitles("\nth{10} quantile" "\nth{50} quantile" "\nth{90} quantile" "\nth{10} quantile" "\nth{50} quantile" "\nth{90} quantile") 

esttab using $table\quantile_full.rtf,  b(%4.3f) se replace nodepvar nogaps starlevels(* 0.1 ** 0.05 *** 0.01) label nocons order(crp_div inc_div droughtkl droughtrl Male age_hh hh_size schll_hh asset lnfrm market road extension irrigation v2h_fec v2h_fei) mtitles("\nth{25} quantile" "\nth{50} quantile" "\nth{75} quantile" "\nth{25} quantile" "\nth{50} quantile" "\nth{75} quantile") s(fe year N, label("Individual FE" "Year FE" "Observations")) 
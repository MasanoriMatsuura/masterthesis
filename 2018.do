/*create 2015 dataset for regression*/
/*Author: Masanori Matsuura*/
clear all
set more off
*set the pathes
global climate = "C:\Users\user\Documents\Masterthesis\climatebang"
global BIHS18Community = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2018\BIHSRound3\Community"
global BIHS18Female = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2018\BIHSRound3\Female"
global BIHS18Male = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2018\BIHSRound3\Male"
global BIHS15 = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2015"
global BIHS12 = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2012"
cd "C:\Users\user\Documents\Masterthesis\BIHS\Do"

ssc install outreg2, replace
*BIHS2015 data cleaning 
**keep geographical code
use $BIHS18Male\009_bihs_r3_male_mod_a, clear
keep a01 dvcode district upazila union mouza village
rename (district upazila union mouza village)(dcode uzcode uncode mzcode Village)
duplicates drop a01, force
save 2018, replace

** keep age gender education occupation of HH
use $BIHS18Male\010_bihs_r3_male_mod_b1.dta, clear
bysort a01: egen hh_size=count(a01)
label var hh_size "Household size"
keep if b1_03==1 
keep a01 mid b1_01 b1_02 b1_04 b1_04a b1_08 b1_10 b1_13a b1_13b hh_size
rename (b1_01 b1_02 b1_04 b1_04a b1_08 b1_10 b1_13a b1_13b)(gender_hh age_hh marital_hh age_marital_hh edu_hh ocu_hh main_earning_1 main_earning_2)
recode edu_hh(99=0 "Non-schooling") (22=5)(33=9)(66=0 "Non-schooling")(67=0 "Non-schooling")(74=16)(76=.)(99=0 "Non-schooling"), gen(schll_hh) // convert  education into schoolling year 
label var age_hh "Age of HH"
label var schll_hh "Schooling year of HH"
recode gender_hh (1=1 "Man")(2=0 "Woman"), gen(Male)
label var Male "Male(=1)"
duplicates drop a01, force
save sciec18.dta, replace

**keep agronomic variables
use $BIHS18Male\020_bihs_r3_male_mod_g, clear
collapse (sum) farmsize=g02 ,by(a01)
label var farmsize "Farm Size(decimal)"
gen ln_farm=log(farmsize)
label var ln_farm "Farm size(log)"
save agrnmic18.dta, replace

**non-earned income
use $BIHS18Male\076_bihs_r3_male_mod_v4, clear
drop hh_type
bysort a01: gen nnearn=v4_01+v4_02+v4_03+v4_04+v4_05+v4_06+v4_07+v4_08+v4_09+v4_10+v4_11+v4_12
label var nnearn "Non-earned income"
keep a01 nnearn
save nnrn18.dta, replace //non-earned  income

**Social safety net program
use $BIHS18Male\070_bihs_r3_male_mod_u.dta, replace
bysort a01: gen trsfr=sum(u02)
label var trsfr "Social safety net program transfer"
keep a01 trsfr
duplicates drop a01, force
save ssnp18.dta, replace

**crop type, farm income and diversification

/*use $BIHS18Male\015_r2_mod_h1_male, clear // crop type
keep a01 crop_a crop_b h1_02 h1_03
rename (h1_02 h1_03)(crp_typ plntd)
bysort a01 crop_a: egen typ_plntd=sum(plntd)
duplicates drop a01 crop_a, force
save crp15.dta, replace*/

use $BIHS18Male\021_bihs_r3_male_mod_h1, clear //crop diversification 
keep a01 crop_a_h1 h1_03
rename  h1_03 plntd
collapse (sum) typ_plntd=plntd, by(a01 crop_a)
/*bysort a01 crop_a: egen typ_plntd=sum(plntd) //area of each crop */
label var typ_plntd "Area of each crop"
bysort a01: egen ttl_frm=sum(typ_plntd)  //total planted area
label var ttl_frm "total farm area"

gen es=(typ_plntd/ttl_frm)^2
label var es "enterprise share (planted area)"
bysort a01: egen es_crp=sum(es) 
label var es_crp "Herfindahl-Hirschman index (crop)"
drop if crop_a==.
gen crp_div=1-es_crp
label var crp_div "Crop Diversification Index"
keep a01 crp_div
duplicates drop a01, force
hist crp_div
save crp_div18.dta, replace

use $BIHS18Male\058_bihs_r3_male_mod_m1, clear //crop income
keep a01 m1_10 m1_18 m1_20
collapse (sum) crp_vl=m1_10 (mean) dstnc_sll_=m1_18 trnsctn=m1_20,by(a01)
label var crp_vl "farm income"
label var dstnc_sll_ "distance to selling place" 
label var trnsctn "transaction time"
save crpincm18.dta, replace

/*use $BIHS18Male\039_r2_mod_m1_male, clear //crop income diversification 
keep a01 m1_10
bysort a01: egen ttl_frminc=sum(m1_10) 
label var ttl_frminc "total farm income"
gen es=(m1_10/ttl_frminc)^2
label var es "enterprise share (farm income)"
bysort a01: egen es1=sum(es)
drop if m1_10==.
hist es1 */

**keep livestock variables
use $BIHS18Male\043_bihs_r3_male_mod_k1, clear //animal
bysort a01: gen livstck=sum(k1_04)
recode livstck (1/max=1 "yes")(0=0 "no"),gen(lvstck)
label var lvstck "Livestock ownership(=1)"
keep a01 livestock k1_18 lvstck
save lvstck18.dta, replace
keep a01 lvstck
duplicates drop a01, force
save lvstckown18.dta, replace //ownership

/*Livestock product*/
use $BIHS18Male\049_bihs_r3_male_mod_k2, clear //milk and egg
keep a01 k2_12
label var k2_12 "Total value of livestock product"
save lvstckpr18.dta, replace //livestock product

/*create livestock income*/
use lvstck18, clear 
rename k1_18 k2_12 //rename livestock income
keep a01 k2_12
append using lvstckpr18.dta
bysort a01: egen ttllvstck=sum(k2_12) // livestock product income
label var ttllvstck "Livestock income"
drop k2_12
duplicates drop a01, force
save lvinc18.dta, replace
use lvstckown18.dta, clear //merge currently ownership and livestock income
merge 1:1 a01 using lvinc18, nogen
save lvstckinc18.dta, replace

**keep non-farm income
use $BIHS18Male\012_bihs_r3_male_mod_c.dta, clear
keep a01 c14
replace c14=0 if c14==.
bysort a01: egen nnfrminc=sum(c14)
keep a01 nnfrminc
label var nnfrminc "Non-farm income"
duplicates drop a01, force
save nnfrminc18.dta, replace

/*Non-agricultural enterprise*/
use $BIHS18Male\041_r2_mod_n_male.dta, clear

**off-farm but related to agriculture
use $BIHS18Male\013_bihs_r3_male_mod_c1, clear
keep a01 c1_5 c1_9 c1_13
replace c1_5=0 if c1_5==.
replace c1_9=0 if c1_9==.
replace c1_13=0 if c1_13==.
gen nnfrm=c1_5+c1_9+c1_13
bysort a01: egen offrmagr=sum(nnfrm)
label var offrmagr "Off-farm income related with agriculture"
keep a01 offrmagr
duplicates drop a01, force
save offfrmagr18.dta, replace

/*Non-agricultural enterprise*/
use $BIHS18Male\042_r2_mod_o1_female.dta, clear

/*food consumption*/
use $BIHS18Male\064_r2_mod_x1_1_female.dta
use $BIHS18Male\065_r2_mod_x1_2_female.dta

/*Idiosyncratic shocks*/
use $BIHS18Male\067_bihs_r3_male_mod_t1b.dta, clear
recode t1b_02 (9 = 1 "Yes") (nonm=0 "No"), gen(c)
recode t1b_02 (11 12 13=1 "Yes")(nonm=0 "No"), gen(l)
bysort a01: egen idi_crp=sum(c) 
bysort a01: egen idi_lvstck=sum(l)
keep a01 idi_crp idi_lvstck
recode idi_crp (1/max=1 "Yes") (0=0 "No"), gen(idcrp)
label var idcrp "Crop shock(=1 if yes)"
recode idi_lvstck (1/max=1 "Yes") (0=0 "No"), gen(idliv)
label var idliv "Livestock shock(=1 if yes)"
keep a01 idcrp idliv
duplicates drop a01, force
gen idi_crp_liv=idcrp*idliv
label var idi_crp_liv "Crop shock*Livestock shock "
save idisyn18.dta, replace

**agricultural extension

**climate variables 
use climate, clear
rename (district dcode) (dcode District_Name) //renaming
drop rinmn1 rinmn2 rinsd1 rinsd2 tmpmn1 tmpmn2 tmpsd1 tmpsd2
rename (rinmn3 rinsd3 tmpmn3 tmpsd3)(rinmn rinsd tmpmn tmpsd)
gen rinmn_1000=rinmn/1000
gen rinsd_1000=rinsd/1000
gen ln_rinmn=log(rinmn)
gen ln_rinsd=log(rinsd)
gen ln_tmpmn=log(tmpmn)
gen ln_tmpsd=log(tmpsd)
label var rinmn "Yearly mean rainfall"
label var rinsd "Yearly st.dev. rainfall"
label var tmpmn "Monthly mean temperature"
label var tmpsd "Monthly st.dev. temperature"
label var rinmn_1000 "Yearly mean rainfall(1,000mm)"
label var rinsd_1000 "Yearly st.dev rainfall (1,000mm)"
label var ln_rinmn "Yearly mean rainfall (log)"
label var ln_tmpmn "Monthly mean temperature (log)"
save climate18, replace

**merge all 2018 dataset
use 2018.dta,clear
merge m:1 dcode using climate18, nogen
merge 1:1 a01 using sciec18, nogen
merge 1:1 a01 using agrnmic18, nogen
merge 1:1 a01 using nnrn18, nogen
merge 1:1 a01 using crp_div18, nogen
merge 1:1 a01 using idisyn18.dta, nogen
merge 1:1 a01 using lvstckinc18.dta,nogen
merge 1:1 a01 using crpincm18,nogen
merge 1:1 a01 using offfrmagr18.dta,nogen
merge 1:1 a01 using ssnp18,nogen
merge 1:1 a01 using nnfrminc18,nogen
label var rinmn_1000 "Yearly mean rainfall(1,000mm)"
label var farmsize "Farm Size(decimal)"
label var ln_farm "Farm size(log)"
gen lnoff=log(offrmagr)
gen year=2018
save 2018.dta, replace

/*preliminary analysis*/
use 2018.dta, clear

**descriptive statistics
eststo clear

estpost summarize crp_div rinmn_1000 rinsd_1000 tmpmn tmpsd Male age_hh hh_size schll_hh farmsize 

esttab using table.tex, cells("count mean sd min max") l replace

hist crp_div , percent title(Crop diversificatioin index distribution) note(Source: BIHS2018 calculated by author) //hist of crop diversification index
graph display, scheme(s1mono)
graph export crpdiv.pdf, replace
**estimation
reg crp_div rinmn rinsd tmpmn tmpsd edu_hh age_hh hh_size
estat hettest
reg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size edu_hh  farmsize , vce(robust) //better than cluster

qreg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh  ln_farm , quantile(0.25) //better than cluster
qreg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh  ln_farm, quantile(0.50)  //better than cluster
qreg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh  ln_farm, quantile(0.75) //better than cluster
qreg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size schll_hh  ln_farm , quantile(0.90)  //better than cluster 

quietly reg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size edu_hh  farmsize //test for heteroskedasticity
estat hettest

reg crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd idcrp idliv idi_crp_liv Male age_hh hh_size edu_hh  farmsize, vce(cluster Village) 

tobit crp_div ln_rinmn ln_rinsd ln_tmpmn ln_tmpsd edu_hh age_hh hh_size , vce(cluster Village)

tobit crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd  Male age_hh hh_size schll_hh  ln_farm , vce(robust) //better than cluster //better than cluster, most reliable
**output
eststo clear
eststo: quietly tobit crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd  Male age_hh hh_size schll_hh  ln_farm, vce(robust) //better than cluster
esttab using frst_stg.tex, l replace
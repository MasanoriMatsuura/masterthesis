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

*BIHS2018 data cleaning 
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
save sciec18.dta, replace

**keep agronomic variables
use $BIHS18Male\020_bihs_r3_male_mod_g, clear
collapse (sum) farmsize=g02 ,by(a01)
label var farmsize "Farm Size(decimal)"
gen ln_farm=log(farmsize)
label var ln_farm "Farm size(log)"
save agrnmic18.dta, replace

/*irrigation*/
use $BIHS18Male\022_bihs_r3_male_mod_h2.dta, clear
recode h2_02 (.=0 "No")(1=0 "No") (nonm=1 "Yes"), gen(irri)
label var irri "Irrigation(=1)"
collapse (sum) i1=irri, by(a01)
recode i1 (0=0 "No")(nonm=1 "Yes"), gen(irrigation)
label var irrigation "Irrigation(=1)"
keep a01 irrigation
save irri18.dta, replace

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

use $BIHS18Male\021_bihs_r3_male_mod_h1, clear // crop type
keep a01 crop_a_h1 h1_03
bysort a01 crop_a_h1: egen typ_plntd=sum(h1_03)
duplicates drop a01 crop_a_h1, force
bysort a01: egen crpdivnm=count(crop_a_h1) //crop diversification (Number of crop species including vegetables and fruits produced by the household in the last year (number))
label var crpdivnm "Crop diversity"
keep a01 crpdivnm
duplicates drop a01, force
save crp18.dta, replace

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

**market access 
use $BIHS18Male\058_bihs_r3_male_mod_m1, clear //Marketing of Paddy, Rice, Banana, Mango, and Potato
keep a01 m1_16 m1_18
recode m1_16 (2/5=1 "yes")(nonm=0 "no"), gen(market)
bysort a01: egen market_participation=sum(market) 
recode market_participation (1/max=1 "Yes")(nonm=0 "No"), gen(marketp1)
duplicates drop a01, force 
keep a01 marketp1
save marketstaple18.dta, replace
use $BIHS18Male\059_bihs_r3_male_mod_m2, clear //Marketing of Livestock, Jute, Wheat, Pulses, Fish, Fruits, Vegetable
keep a01 m2_16 m2_18
recode m2_16 (2/5=1 "yes")(nonm=0 "no"), gen(market)
bysort a01: egen market_participation=sum(market) 
recode market_participation (1/max=1 "Yes")(nonm=0 "No"), gen(marketp2)
duplicates drop a01, force 
keep a01 marketp2
merge 1:1 a01 using marketstaple15, nogen
gen mrkt=marketp1+marketp2
recode mrkt (1/max=1 "yes")(nonm=0 "no"), gen(marketp)
keep a01 marketp
save mrkt18, replace

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
keep a01 k2_12 bprod
rename bprod livestock
save lvstckpr18.dta, replace //livestock product

/*create livestock income*/
use lvstck18, clear 
rename k1_18 k2_12 //rename livestock income
keep a01 k2_12 livestock
append using lvstckpr18.dta
save eli18, replace //save a file for farm diversification index

bysort a01: egen ttllvstck=sum(k2_12) // livestock product income
label var ttllvstck "Livestock income"
drop k2_12
duplicates drop a01, force
save lvinc18.dta, replace
use lvstckown18.dta, clear //merge currently ownership and livestock income
merge 1:1 a01 using lvinc18, nogen
save lvstckinc18.dta, replace

**livestock diversification
use $BIHS18Male\043_bihs_r3_male_mod_k1, clear 
drop if k1_04==0
bysort a01: egen livdiv=count(livestock)
keep a01 livdiv
duplicates drop a01, force
save livdiv18.dta, replace

/*fishery income*/
use $BIHS18Male\052_bihs_r3_male_mod_l2.dta, clear
bysort a01:egen fshinc=sum(l2_12)
bysort a01:egen fshdiv=count(l2_01)
keep a01 fshdiv fshinc
label var fshdiv "fish diversification"
label var fshinc "fishery income"
duplicates drop a01, force
save fsh18.dta, replace

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
use $BIHS18Male\060_bihs_r3_male_mod_n.dta, clear
bysort a01: egen nnagent=sum(n05)
label var nnagent "non-agricultural enterprise"
keep a01 nnagent
duplicates drop a01, force
save nnagent18.dta, replace

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

**off-farm income*
use $BIHS18Male\012_bihs_r3_male_mod_c.dta, clear
keep a01 c14
gen yc14=12*c14
bysort a01: egen offrm=sum(yc14)
label var offrm "Off-farm income "
keep a01 offrm
duplicates drop a01, force
save offfrm18.dta, replace
merge 1:1 a01 using offfrmagr18, nogen
gen offrminc=offrm+offrmagr
label var offrminc "Off-farm income"
keep a01 offrminc
save offfrm18.dta, replace

/*Non-agricultural enterprise*/
use $BIHS18Male\042_r2_mod_o1_female.dta, clear

*food consumption
use $BIHS18Female\105_bihs_r3_female_mod_x1.dta
recode x1_05 (1/16 277/297 303/305 323 2771/2776 2782 2781 2782 2791 2792 2801 2802 2811 2812  2813 2841/2843 2851/2852 2861/2863 2871/2876 2891/2896 2901/2907 2951/2952 2961 2971 2981 3031 3032=1 "Cereals")(61 82 302 306 621 622 3231 =2 "White roots and tubers")(41/60 63/69 80 81 86/115 298 300 441 905 2921/2923 2881/2886 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 70/79 299 301 317 320 2911/2913 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3123 =10 "Oils and fats")(307/11 321=11 "Sweets")(246/251 253/264 266/276 314/316 318 319 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(hdds_i)
keep a01 hdds_i
duplicates drop a01 hdds_i, force
bysort a01: egen hdds=count(a01)
drop hdds_i
label var hdds "Household Dietary Diversity"
duplicates drop a01, force
save fd18.dta, replace
/*use $BIHS18Male\065_r2_mod_x1_2_female.dta */

**Consumption expenditure
use BIHS_hh_variables_r123, clear
keep if round==3
keep a01 pc_expm_d pc_foodxm_d pc_nonfxm_d
save expend18.dta, replace

/*Idiosyncratic shocks*/
use $BIHS18Male\067_bihs_r3_male_mod_t1b.dta, clear
recode t1b_01 (9= 1 "Yes") (nonm=0 "No"), gen(c)
recode t1b_01 (11 12 13=1 "Yes")(nonm=0 "No"), gen(l)
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

**Farm diversification index
use $BIHS18Male\058_bihs_r3_male_mod_m1, clear //crop income
keep a01 m1_02 m1_10 m1_18 m1_20
bysort a01 m1_02: egen eis=sum(m1_10)
keep a01 m1_02 eis
duplicates drop a01 m1_02, force
save eci18, replace
use $BIHS18Male\052_bihs_r3_male_mod_l2.dta, clear
keep a01 l2_12 l2_01
bysort a01 l2_01: egen eis=sum(l2_12)
keep a01 eis l2_01
duplicates drop a01 l2_01, force
tempfile efi12
save efi18, replace
use eli18, clear //livestock income
bysort a01 livestock: egen eis=sum(k2_12)
keep a01 eis livestock 
duplicates drop a01 livestock, force
append using efi18
append using eci18
bysort a01: egen frminc=sum(eis) //total farm income
gen seir=(eis/frminc)^2 //squared each farm income ratio 
bysort a01: egen frm_div1=sum(seir)
bysort a01: gen frm_div=1-frm_div1
duplicates drop a01, force
keep a01 frm_div
save frm_div18, replace

**Farm diversification
use crp18.dta, clear
merge 1:1 a01 using livdiv18, nogen
merge 1:1 a01 using fsh18, nogen
replace livdiv=0 if livdiv==.
replace crpdivnm=0 if crpdivnm==.
replace fshdiv=0 if fshdiv==.
gen frmdiv=crpdivnm+livdiv+fshdiv
save frmdiv18.dta, replace

**Income diversification
use crpincm18.dta, clear
merge 1:1 a01 using nnrn18.dta, nogen
merge 1:1 a01 using ssnp18.dta, nogen
merge 1:1 a01 using lvstckinc18.dta, nogen
merge 1:1 a01 using offfrm18.dta, nogen
merge 1:1 a01 using fsh18.dta, nogen
merge 1:1 a01 using nnagent18.dta, nogen
drop dstnc_sll_ trnsctn lvstck fshdiv
replace crp_vl=0 if crp_vl==.
replace offrminc=0 if offrminc==.
replace nnearn=0 if nnearn==.
replace fshinc=0 if fshinc==.
replace ttllvstck=0 if ttllvstck==.
gen ttinc= crp_vl+nnearn+trsfr+ttllvstck+offrminc+fshinc+nnagent //total income
gen i1=(crp_vl/ttinc)^2
gen i2=(nnearn/ttinc)^2
gen i3=(trsfr/ttinc)^2
gen i4=(ttllvstck/ttinc)^2
gen i5=(offrminc/ttinc)^2
gen i6=(fshinc/ttinc)^2
gen i7=(nnagent/ttinc)^2
gen es=i1+i2+i3+i4+i5+i6+i7
gen inc_div=1-es

label var inc_div "Income diversification index"
keep a01 inc_div ttinc
save incdiv18.dta, replace

**climate variables 
use climate, clear
rename (district dcode) (dcode District_Name) //renaming
drop rw1 rs1 rr1 ra1 rw2 rs2 rr2 ra2 tw1 ts1 tr1 ta1 tw2 ts2 tr2 ta2 tmpsd1 tmpsd2 rinsd1 rinsd2
rename (rw3 rs3 rr3 ra3 rinsd3 tw3 ts3 tr3 ta3 tmpsd3)(rw rs rr ra rinsd tw ts tr ta tmpsd)
gen rinsd_1000=rinsd/1000
gen ln_rw=log(rw)
gen ln_rs=log(rs)
gen ln_rr=log(rr)
gen ln_ra=log(ra)
gen ln_rinsd=log(rinsd)
gen ln_tw=log(tw)
gen ln_ts=log(ts)
gen ln_tr=log(tr)
gen ln_ta=log(ta)
gen ln_tmpsd=log(tmpsd)
label var rinsd "Yearly st.dev rainfall"
label var tmpsd "Monthly st.dev temperature"
label var ln_tmpsd "Monthly st.dev temperature (log)"
label var rinsd_1000 "Yearly st.dev rainfall (1,000mm)"
label var ln_rinsd  "Yearly st.dev rainfall (log) "
label var ln_rw "Winter rainfall (log)"
label var ln_rs "Summer rainfall (log)"
label var ln_rr "Rainy season rainfall (log)"
label var ln_ra "Autumn rainfall (log)"
label var ln_tw "Winter mean temperature (log)"
label var ln_ts "Summar mean temperature (log)"
label var ln_tr "Rainy season mean temperature (log)"
label var ln_ta "Autumn mean temperature (log)"
save climate18, replace

**merge all 2018 dataset
use 2018.dta,clear
merge m:1 dcode using climate18, nogen
duplicates drop a01, force
merge 1:1 a01 using sciec18, nogen
merge 1:1 a01 using agrnmic18, nogen
merge 1:1 a01 using nnrn18, nogen
merge 1:1 a01 using crp_div18, nogen
merge 1:1 a01 using idisyn18.dta, nogen
merge 1:1 a01 using lvstckinc18.dta,nogen
merge 1:1 a01 using crpincm18,nogen
merge 1:1 a01 using offfrm18.dta,nogen
merge 1:1 a01 using ssnp18,nogen
merge 1:1 a01 using nnfrminc18,nogen
merge 1:1 a01 using ssnp18,nogen
merge 1:1 a01 using nnfrminc18,nogen
merge 1:1 a01 using crp18,nogen
merge 1:1 a01 using irri18, nogen
merge 1:1 a01 using incdiv18, nogen
merge 1:1 a01 using frmdiv18.dta, nogen
merge 1:1 a01 using fd18.dta, nogen
merge 1:1 a01 using expend18, nogen
merge 1:1 a01 using frm_div18, nogen
merge 1:1 a01 using mrkt18, nogen
label var farmsize "Farm Size(decimal)"
label var ln_farm "Farm size(log)"
//gen lnoff=log(offrmagr)
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
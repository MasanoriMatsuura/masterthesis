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


*BIHS2015 data cleaning 
**keep geographical code
use $BIHS15\001_r2_mod_a_male, clear
keep a01 dvcode dcode District_Name uzcode uncode mzcode Village
save 2015, replace

** keep age gender education occupation of HH
use $BIHS15\003_r2_male_mod_b1.dta, clear
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
save sciec15.dta, replace

**keep agronomic variables
use $BIHS15\014_r2_mod_g_male, clear
collapse (sum) farmsize=g02 ,by(a01)
label var farmsize "Farm Size(decimal)"
gen ln_farm=log(farmsize)
label var ln_farm "Farm size(log)"
save agrnmic15.dta, replace

/*Irrigation*/
use $BIHS15/016_r2_mod_h2_male.dta, clear
recode h2_02 (1=0 "No") (nonm=1 "Yes"), gen(irri)
label var irri "Irrigation(=1)"
collapse (sum) i1=irri, by(a01)
recode i1 (0=0 "No")(nonm=1 "Yes"), gen(irrigation)
label var irrigation "Irrigation(=1)"
keep a01 irrigation
save irri15.dta, replace
**non-earned income
use $BIHS15\056_r2_mod_v4_male, clear
drop hh_type
bysort a01: gen nnearn=v4_01+v4_02+v4_03+v4_04+v4_05+v4_06+v4_07+v4_08+v4_09+v4_10+v4_11+v4_12
label var nnearn "Non-earned income"
keep a01 nnearn
save nnrn15.dta, replace //non-earned  income

**Social safety net program
use $BIHS15\052_r2_mod_u_male.dta, replace
bysort a01: gen trsfr=sum(u02)
label var trsfr "Social safety net program transfer"
keep a01 trsfr
duplicates drop a01, force
save ssnp15.dta, replace

**crop type, farm income and diversification
use $BIHS15\015_r2_mod_h1_male, clear // crop type
keep a01 crop_a crop_b h1_02 h1_03
rename (h1_02 h1_03)(crp_typ plntd)
bysort a01 crop_a: egen typ_plntd=sum(plntd)
duplicates drop a01 crop_a, force
bysort a01: egen crpdivnm=count(crop_a) //crop diversification (Number of crop species including vegetables and fruits produced by the household in the last year (number))
label var crpdivnm "Crop diversity"
keep a01 crpdivnm
duplicates drop a01, force
save crp15.dta, replace

use $BIHS15\015_r2_mod_h1_male, clear //crop diversification 
keep a01 crop_a crop_b h1_03
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
save crp_div15.dta, replace

use $BIHS15\039_r2_mod_m1_male, clear //crop income
keep a01 m1_10 m1_18 m1_20
collapse (sum) crp_vl=m1_10 (mean) dstnc_sll_=m1_18 trnsctn=m1_20,by(a01)
label var crp_vl "crop income"
label var dstnc_sll_ "distance to selling place" 
label var trnsctn "transaction time"
save crpincm15.dta, replace

/*use $BIHS15\039_r2_mod_m1_male, clear //crop income diversification 
keep a01 m1_10
bysort a01: egen ttl_frminc=sum(m1_10) 
label var ttl_frminc "total farm income"
gen es=(m1_10/ttl_frminc)^2
label var es "enterprise share (farm income)"
bysort a01: egen es1=sum(es)
drop if m1_10==.
hist es1 */



**keep livestock variables
use $BIHS15\034_r2_mod_k1_male.dta, clear //animal
bysort a01: gen livstck=sum(k1_04)
recode livstck (1/max=1 "yes")(0=0 "no"),gen(lvstck)
label var lvstck "Livestock ownership(=1)"
keep a01 livestock k1_18 lvstck
save lvstck15.dta, replace
keep a01 lvstck
duplicates drop a01, force
save lvstckown15.dta, replace //ownership

/*Livestock product*/
use $BIHS15\035_r2_mod_k2_male.dta, clear //milk and egg
keep a01 k2_12
label var k2_12 "Total value of livestock product"
save lvstckpr15.dta, replace //livestock product

/*create livestock income*/
use lvstck15, clear 
rename k1_18 k2_12 //rename livestock income
keep a01 k2_12
append using lvstckpr15.dta
bysort a01: egen ttllvstck=sum(k2_12) // livestock product income
label var ttllvstck "Livestock income"
drop k2_12
duplicates drop a01, force
save lvinc15.dta, replace
use lvstckown15.dta, clear //merge currently ownership and livestock income
merge 1:1 a01 using lvinc15, nogen
save lvstckinc15.dta, replace

**livestock diversification
use $BIHS15\034_r2_mod_k1_male.dta, clear 
drop if k1_04==0
bysort a01: egen livdiv=count(livestock)
keep a01 livdiv
duplicates drop a01, force
save livdiv15.dta, replace

/*fishery income*/
use $BIHS15\038_r2_mod_l2_male.dta, clear
bysort a01:egen fshinc=sum(l2_12)
bysort a01:egen fshdiv=count(l2_01)
keep a01 fshdiv fshinc
label var fshdiv "fish diversification"
label var fshinc "fishery income"
duplicates drop a01, force
save fsh15.dta, replace

**keep non-farm income
use $BIHS15\008_r2_mod_c_male.dta, clear
keep a01 c14
replace c14=0 if c14==.
bysort a01: egen nnfrminc=sum(c14)
keep a01 nnfrminc
label var nnfrminc "Non-farm income"
duplicates drop a01, force
save nnfrminc15.dta, replace

/*Non-agricultural enterprise*/
use $BIHS15\041_r2_mod_n_male.dta, clear
bysort a01: egen nnagent=sum(n05)
label var nnagent "non-agricultural enterprise"
keep a01 nnagent
duplicates drop a01, force
save nnagent15.dta, replace

**off-farm but related to agriculture
use $BIHS15\009_r2_mod_c1_male.dta, clear
keep a01 c1_05 c1_09 c1_13
replace c1_05=0 if c1_05==.
replace c1_09=0 if c1_09==.
replace c1_13=0 if c1_13==.
gen nnfrm=c1_05+c1_09+c1_13
bysort a01: egen offrmagr=sum(nnfrm)
label var offrmagr "Off-farm income related with agriculture"
keep a01 offrmagr
duplicates drop a01, force
save offfrmagr15.dta, replace

**off-farm income
use $BIHS15\008_r2_mod_c_male.dta, clear
gen yc14=12*c14
bysort a01: egen offrm=sum(yc14)
label var offrm "Off-farm income "
keep a01 offrm
duplicates drop a01, force
save offfrm15.dta, replace
merge 1:1 a01 using offfrmagr18, nogen
gen offrminc=offrm+offrmagr
label var offrminc "Off-farm income"
keep a01 offrminc
save offfrm15.dta, replace 

/*food consumption*/
use $BIHS15\064_r2_mod_x1_1_female.dta //create Household dietary diversity score (HDDS)
recode x1_05 (1/16 277/297 303/305 323 2771/2776 2782 2781 2782 2791 2792 2801 2802 2811 2812  2813 2841/2843 2851/2852 2861/2863 2871/2876 2891/2896 2901/2907 2951/2952 2961 2971 2981 3031 3032=1 "Cereals")(61 82 302 306 621 622 3231 =2 "White roots and tubers")(41/60 63/69 80 81 86/115 298 300 441 905 2921/2923 2881/2886 2921/2923 2981 3001 =3 "Vegetables")(141/170 907 1421 1422 1461 1462=4 "Fruits")(121/129 322 906 =5 "Meat")(130/131 1301 1302 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 31/32 70/79 299 301 317 320 2911/2913 2991=8 "Leagumes, nuts and seeds")(132/135 1321/1323 2941/2943=9 "Milk and milk products")(33/36 312/313 902 903 3121/3123 =10 "Oils and fats")(307/11 321=11 "Sweets")(246/251 253/264 266/276 314/316 318 319 2521 2522 2721/2724 3131 3132 = 12 "Spices, condiments, and beverages"), gen(hdds_i)
keep a01 hdds_i
duplicates drop a01 hdds_i, force
bysort a01: egen hdds=count(a01)
drop hdds_i
label var hdds "Household Dietary Diversity"
duplicates drop a01, force
save fd15.dta, replace
/*foreach var of varlist x1_07_01 x1_07_02 x1_07_03 x1_07_04 x1_07_05 x1_07_06 x1_07_07 x1_07_08 x1_07_09 x1_07_10 x1_07_11 x1_07_12 x1_07_13 x1_07_14 x1_07_15{
recode `var' (1/16=1 "Cereals")(2 "White roots and tubers")(3 "Vitamin a rich vegetables and tubers")(4 "Dark grenn leafy vegetables")(5 "Other vegetables")(6 "Vitamin a rich fruits")(7"Other fruits")(8 "Organ meat")(9 "Fresh meat")(10 "Eggs")(11 "Fish and seafood")(21/28=12 "Leagumes, nuts and seeds")(31/32=12 "Leagumes, nuts and seeds")(13 "Milk and milk products")(14 "Oils and fats")(15 "Sweets")(16 "Spices, condiments, and beverages"), gen(hdds_`var')
}*/


use $BIHS15\065_r2_mod_x1_2_female.dta //create Woman Dietary Diversity Score (WDDS)

/*Idiosyncratic shocks*/
use $BIHS15\050_r2_mod_t1_male.dta, clear
recode t1_02 (9 10= 1 "Yes") (nonm=0 "No"), gen(c)
recode t1_02 (11 12 13=1 "Yes")(nonm=0 "No"), gen(l)
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
save idisyn15.dta, replace

**agricultural extension


**Farm diversification
use crp15.dta, clear
merge 1:1 a01 using livdiv15, nogen
merge 1:1 a01 using fsh15, nogen
replace livdiv=0 if livdiv==.
replace crpdivnm=0 if crpdivnm==.
replace fshdiv=0 if fshdiv==.
gen frmdiv=crpdivnm+livdiv+fshdiv
save frmdiv15.dta, replace

**Income diversification
use crpincm15.dta, clear
merge 1:1 a01 using nnrn15.dta, nogen
merge 1:1 a01 using ssnp15.dta, nogen
merge 1:1 a01 using lvstckinc15.dta, nogen
merge 1:1 a01 using offfrm15.dta, nogen
merge 1:1 a01 using fsh15.dta, nogen
merge 1:1 a01 using nnagent15.dta, nogen
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
keep a01 inc_div
save incdiv15.dta, replace
/*gen es=(typ_plntd/ttl_frm)^2
label var es "enterprise share (planted area)"
bysort a01: egen es_crp=sum(es) 
label var es_crp "Herfindahl-Hirschman index (crop)"
drop if crop_a==.
gen crp_div=1-es_crp
label var crp_div "Crop Diversification Index"
keep a01 crp_div
duplicates drop a01, force
hist crp_div
save crp_div15.dta, replace*/

**climate variables 
use climate, clear
rename (district dcode) (dcode District_Name) //renaming
drop rinmn1 rinmn3 rinsd1 rinsd3 tmpmn1 tmpmn3 tmpsd1 tmpsd3
rename (rinmn2 rinsd2 tmpmn2 tmpsd2)(rinmn rinsd tmpmn tmpsd)
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
save climate15, replace

**merge all 2015 dataset
use 2015.dta,clear
merge m:1 dcode using climate15, nogen
merge 1:1 a01 using sciec15, nogen
merge 1:1 a01 using agrnmic15, nogen
merge 1:1 a01 using nnrn15, nogen
merge 1:1 a01 using crp_div15, nogen
merge 1:1 a01 using idisyn15.dta, nogen
merge 1:1 a01 using lvstckinc15.dta,nogen
merge 1:1 a01 using crpincm15,nogen
merge 1:1 a01 using offfrm15.dta,nogen
merge 1:1 a01 using ssnp15,nogen
merge 1:1 a01 using nnfrminc15,nogen
merge 1:1 a01 using crp15,nogen
merge 1:1 a01 using irri15, nogen
merge 1:1 a01 using incdiv15, nogen
merge 1:1 a01 using frmdiv15.dta, nogen
merge 1:1 a01 using fd15.dta, nogen
label var rinmn_1000 "Yearly mean rainfall(1,000mm)"
label var farmsize "Farm Size(decimal)"
label var ln_farm "Farm size(log)"
gen lnoff=log(offrmagr)
gen year=2015
save 2015.dta, replace

/*preliminary analysis*/
use 2015.dta, clear

**descriptive statistics
eststo clear

estpost summarize crp_div rinmn_1000 rinsd_1000 tmpmn tmpsd Male age_hh hh_size schll_hh farmsize 

esttab using table.tex, cells("count mean sd min max") l replace

hist crp_div , percent title(Crop diversificatioin index distribution) note(Source: BIHS2015 calculated by author) //hist of crop diversification index
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
tobit frmdiv ln_rinmn rinsd_1000 ln_tmpmn tmpsd  Male age_hh hh_size schll_hh  ln_farm , vce(robust)
tobit inc_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd  Male age_hh hh_size schll_hh  ln_farm , vce(robust) //better than cluster //better than cluster, most reliable
**output
eststo clear
eststo: quietly tobit crp_div ln_rinmn rinsd_1000 ln_tmpmn tmpsd  Male age_hh hh_size schll_hh  ln_farm, vce(robust) //better than cluster
esttab using frst_stg.tex, l replace
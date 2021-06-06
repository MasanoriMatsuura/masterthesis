/*create dataset for regression*/
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
save sciec15.dta, replace

**keep agronomic variables
use $BIHS15\014_r2_mod_g_male, clear
collapse (sum) farmsize=g02 ,by(a01)
label var farmsize "Farm Size"
save agrnmic15.dta

**keep farm and off-farm income variables
use $BIHS15\056_r2_mod_v4_male, clear
drop hh_type
bysort a01: gen offearn=v4_01+v4_02+v4_03+v4_04+v4_05+v4_06+v4_07+v4_08+v4_09+v4_10+v4_11+v4_12
label var offearn "Non-earned income"
keep a01 offearn
save incm15.dta, replace //off-earned  income

**crop type, farm income and diversification
/*use $BIHS15\015_r2_mod_h1_male, clear // crop type
keep a01 crop_a crop_b h1_02 h1_03
rename (h1_02 h1_03)(crp_typ plntd)
bysort a01 crop_a: egen typ_plntd=sum(plntd)
duplicates drop a01 crop_a, force
save crp15.dta, replace*/

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
label var crp_vl "farm income"
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
use $BIHS15\034_r2_mod_k1_male.dta, clear
**keep non-farm income
use $BIHS15\008_r2_mod_c_male.dta, clear

**off-farm but related to agriculture
use $BIHS15\009_r2_mod_c1_male.dta, clear

**keep consumptin variables
use $BIHS15\042_r2_mod_o1_female.dta, clear
**Idiosyncratic shocks
use $BIHS2015\050_r2_mod_t1_male.dta, clear

**climate variables 
use climate, clear
rename district_n dcode //renaming
save climate, replace

**merge all 2015 dataset
use 2015.dta,clear
merge m:1 dcode using climate, nogen
drop rinmn1 rinmn3 rinsd1 rinsd3 tmpmn1 tmpmn3 tmpsd1 tmpsd3
label var rinmn2 "Yearly mean rainfall"
label var rinsd2 "Yearly st.dev. rainfall"
label var tmpmn2 "Monthly mean temperature"
label var tmpsd2 "Monthly st.dev. temperature"
drop if a01==.
merge 1:1 a01 using sciec15, nogen
merge 1:1 a01 using agrnmic15, nogen
merge 1:1 a01 using incm15, nogen
merge 1:1 a01 using crp_div15, nogen
merge 1:1 a01 using 
save 2015.dta, replace

/*preliminary analysis*/
mean crp_div\
reg crp_div rinmn2 rinsd2 tmpmn2 tmpsd2 edu_hh age_hh hh_size
estat hettest
reg crp_div rinmn2 rinsd2 tmpmn2 tmpsd2 edu_hh age_hh hh_size , vce(robust) //better than cluster
reg crp_div rinmn2 rinsd2 tmpmn2 tmpsd2 edu_hh age_hh hh_size, vce(cluster Village) 

tobit crp_div rinmn2 rinsd2 tmpmn2 tmpsd2 edu_hh age_hh hh_size , vce(cluster Village)
tobit crp_div rinmn2 rinsd2 tmpmn2 tmpsd2 edu_hh age_hh hh_size, vce(robust) //better than cluster

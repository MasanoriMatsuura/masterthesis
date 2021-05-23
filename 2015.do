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
keep if b1_03==1 
keep a01 mid b1_01 b1_02 b1_04 b1_04a b1_08 b1_10 b1_13a b1_13b
rename (b1_01 b1_02 b1_04 b1_04a b1_08 b1_10 b1_13a b1_13b)(gender_hh age_hh marital_hh age_marital_hh edu_hh ocu_hh main_earning_1 main_earning_2)
save sciec15.dta

**keep agronomic variables
use $BIHS15\014_r2_mod_g_male, clear
collapse (sum) farmsize=g02 ,by(a01)
label var farmsize "Farm Size"
save agrnmic15.dta

**keep farm and off-farm income variables
use $BIHS15\056_r2_mod_v4_male, clear
drop hh_type
bysort a01: gen offearn=v4_01+v4_02+v4_03+v4_04+v4_05+v4_06+v4_07+v4_08+v4_09+v4_10+v4_11+v4_12

save incm15.dta //off-earned  income
use incm15

**crop type and farm income
use $BIHS15\015_r2_mod_h1_male, clear
keep a01 crop_a crop_b h1_02 h1_03
rename (h1_02 h1_03)(crp_typ plntd)
save crp15.dta 
use $BIHS15\039_r2_mod_m1_male, clear
keep a01 m1_10 m1_18
collapse (sum) crp_vl=m1_10 (mean) dstnc_sll_=m1_18,by(a01)
label var crp_vl "farm income"
label var dstnc_sll_ "distance to selling place" 
save crpincm15.dta

**keep non-farm income
use \BIHS15\008_r2_mod_c_male.dta 
//009_r2_mod_c1_male off-farm but related to agriculture

**keep livestock variables

**keep consumptin variables
use $BIHS15\042_r2_mod_o1_female

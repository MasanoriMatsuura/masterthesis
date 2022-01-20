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
keep a01 dvcode div div_name district upazila union mouza village
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
recode h2_02 (1=0 "No") (nonm=1 "Yes"), gen(irri)
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

**remittance
use $BIHS18Male\073_bihs_r3_male_mod_v2, clear
keep a01 v2_06
bysort a01: egen remi=sum(v2_06)
duplicates drop a01, force
label var remi "remittance"
save rem18.dta, replace

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
gen es_sh=(typ_plntd/ttl_frm)
gen lnc=log(es_sh)
bysort a01: egen _shnc=sum(lnc*es_sh)
gen shnc=-1*_shnc
keep a01 crp_div shnc
label var shnc "Crop diversification index (shannon)"
keep a01 crp_div shnc
duplicates drop a01, force
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

**access to facility
use $BIHS18Male\066_bihs_r3_male_mod_s, clear
keep a01 s_01 s_06
keep if s_01==3 
drop s_01
rename s_06 road
label var road "Road access (minute)"
tempfile cal
save `cal'
use $BIHS18Male\066_bihs_r3_male_mod_s, clear
keep a01 s_01 s_06
keep if s_01==6
drop s_01
rename s_06 market
label var market "Market access (minute)"
merge 1:1 a01 using `cal', nogen
save facility18, replace
use $BIHS18Male\066_bihs_r3_male_mod_s, clear
keep a01 s_01 s_06
keep if s_01==7 
drop s_01
rename s_06 town
label var town "Distance to near town (minute)"
tempfile town
save `town'
use $BIHS18Male\066_bihs_r3_male_mod_s, clear
keep a01 s_01 s_06
keep if s_01==9 
drop s_01
rename s_06 agri
label var agri "Agricultural office (minute)"
merge 1:1 a01 using facility18, nogen
merge 1:1 a01 using `town', nogen
save facility18, replace

**Agricultural extension
use $BIHS18Male\038_bihs_r3_male_mod_j1, clear 
keep a01 j1_01 j1_04
recode j1_01 (1=1 "yes")(nonm=0 "no"), gen(agent)
recode j1_04 (1=1 "yes")(nonm=0 "no"), gen(phone)
gen aes=agent+phone
recode aes (1/max=1 "yes")(nonm=0 "no"), gen(extension)
label var extension "Access to agricultural extension service (=1 if yes)"
keep a01 extension
save extension18, replace



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

**keep non-farm wage
use $BIHS18Male\012_bihs_r3_male_mod_c.dta, clear
keep a01 c14
replace c14=0 if c14==.
bysort a01: egen nnfrminc=sum(c14)
keep a01 nnfrminc
label var nnfrminc "non-farm wage"
duplicates drop a01, force
save nnfrminc18.dta, replace

**farm wage
use $BIHS18Male\012_bihs_r3_male_mod_c.dta, clear
keep if c05== 1 
keep a01 c14
replace c14=0 if c14==.
bysort a01: egen frmwage=sum(c14) 
keep a01 frmwage
label var frmwage "farm wage"
duplicates drop a01, force
save frmwage18.dta, replace


/*Non-agricultural enterprise*/
use $BIHS18Male\060_bihs_r3_male_mod_n, clear
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

/*Non-agricultural enterprise
use $BIHS18Male\042_r2_mod_o1_female.dta, clear*/

*food consumption
use $BIHS18Female\096_bihs_r3_female_mod_o1.dta, clear
recode o1_01 (1/16 277/290 297 901 296 302 =1 "Cereals")(61 62 621 622 295 301 3231 3232=2 "White tubers and roots")(41/60 63/82 86/115 904 905 291 292 298 441=3 "Vegetables")(141/170 317 319 907=4 "Fruits")(121/129 906 322 =5 "Meat")(130/135 =6 "Eggs")(176/205 211/243 908 909 =7 "Fish and seafood")(21/28 902 299=8 "Legumes, nuts and seeds")(132/135 1321/1323 2941/2943 294=9 "Milk and milk products")(31/36 903 312 =10 "Oils and fats")(266/271 293 303/311=11 "Sweets")(246/251 253/264 272/276 318 323 910 300 314/321 2521 2522 252 313= 12 "Spices, condiments and beverages"), gen(hdds_i)
drop if o1_01==2524
duplicates drop a01 hdds_i, force
bysort a01: egen hdds=count(a01)
drop hdds_i
label var hdds "Household Dietary Diversity"
duplicates drop a01, force
save fd18.dta, replace

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
gen p=eis/frminc 
gen lnp=log(p)
gen shnn1=p*lnp
bysort a01: egen shn1=sum(shnn1)
gen shnf=-1*(shn1)
duplicates drop a01, force
keep a01 frm_div shnf
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
merge 1:1 a01 using rem18.dta, nogen
merge 1:1 a01 using frmwage18.dta, nogen
drop dstnc_sll_ trnsctn lvstck fshdiv
replace crp_vl=0 if crp_vl==.
replace offrminc=0 if offrminc==.
replace nnearn=0 if nnearn==.
replace fshinc=0 if fshinc==.
replace ttllvstck=0 if ttllvstck==.
replace remi=0 if remi==.
replace nnagent=0 if nnagent==.
replace frmwage=0 if frmwage==.
gen ttinc= crp_vl+nnearn+trsfr+ttllvstck+offrminc+fshinc+nnagent+remi+frmwage //total income
gen aginc=ttllvstck+crp_vl+fshinc
gen nonself=nnagent //non-farm self
gen nonwage=offrminc //non-farm wage
gen nonearn=remi+trsfr+nnearn //non-earned 
gen i1=(aginc/ttinc)^2
gen i2=(frmwage/ttinc)^2
gen i3=(nonself/ttinc)^2
gen i4=(nonwage/ttinc)^2
gen i5=(nonearn/ttinc)^2
gen es=i1+i2+i3+i4+i5
gen inc_div=1-es
label var inc_div "Income diversification index" //simpson
gen p1=(aginc/ttinc)
gen p2=(frmwage/ttinc)
gen p3=(nonself/ttinc)
gen p4=(nonwage/ttinc)
gen p5=(nonearn/ttinc)
gen lnp1=log(p1)
gen lnp2=log(p2)
gen lnp3=log(p3)
gen lnp4=log(p4)
gen lnp5=log(p5)
gen shn1=p1*lnp1
gen shn2=p2*lnp2
gen shn3=p3*lnp3
gen shn4=p4*lnp4
gen shn5=p5*lnp5
egen shnni = rowtotal(shn1 shn2 shn3 shn4 shn5)
gen shni=-1*(shnni) //shannon
keep a01 inc_div shni aginc frmwage nonself nonwage nonearn //ttinc ttinc crp_vl nnearn trsfr ttllvstck offrminc fshinc nnagent
save incdiv18.dta, replace

**climate variables 
use climate, clear
/*rename (district dcode) (dcode District_Name) //renaming*/
keep dvcode division hs3 hr3 ha3 hw3 sds3 sdr3 sda3 sdw3 s3 r3 w3 a3 hst3 hrt3 hat3 hwt3 sdst3 sdrt3 sdat3 sdwt3 ts3 tr3 ta3 tw3 
rename (hs3 hr3 ha3 hw3 sds3 sdr3 sda3 sdw3 s3 r3 w3 a3 hst3 hrt3 hat3 hwt3 sdst3 sdrt3 sdat3 sdwt3 ts3 tr3 ta3 tw3)(hs hr ha hw sds sdr sda sdw s r w a hst hrt hat hwt sdst sdrt sdat sdwt ts tr ta tw)

gen srshock=log(s)-log(hs)
gen rrshock=log(r)-log(hr)
gen arshock=log(a)-log(ha)
gen wrshock=log(w)-log(hw)
gen ln_sds=log(sds)
gen ln_sdr=log(sdr)
gen ln_sda=log(sda)
gen ln_sdw=log(sdw)
gen stshock=log(ts)-log(hst)
gen rtshock=log(tr)-log(hrt)
gen atshock=log(ta)-log(hat)
gen wtshock=log(tw)-log(hwt)
gen ln_sdst=log(sdst)
gen ln_sdrt=log(sdrt)
gen ln_sdat=log(sdat)
gen ln_sdwt=log(sdwt)
label var s "Summer rainfall(mm)" 
label var r "Rainy season rainfall(mm)"
label var a "Autumn rainfall(mm)"
label var w "Winter rainfall(mm)"
label var hs "30-year summer rainfall"
label var hr "30-year rainy season rainfall"
label var ha "30-year autumn rainfall"
label var hw "30-year winter rainfall"
label var ts "Summer average temperature(\textdegree{}C)"
label var tr "Rainy season average temperature(\textdegree{}C)"
label var ta "Autumn season average temperature(\textdegree{}C)"
label var tw "Winter average temperature(\textdegree{}C)"
label var hst "30-year summer average temperature(\textdegree{}C)"
label var hrt "30-year rainy season average temperature(\textdegree{}C)"
label var hat "30-year autumn average temperature(\textdegree{}C)"
label var hwt "30-year winter average temperature(\textdegree{}C)"
label var ln_sds "30-year summer rainfall SD(log)"
label var ln_sdr  "30-year rainy season rainfall SD(log)"
label var ln_sda  "30-year autumn rainfall SD(log)"
label var ln_sdw  "30-year winter rainfall SD(log)"
label var ln_sdst "30-year summer temperature SD(log)"
label var ln_sdrt "30-year rainy season temperature SD(log)"
label var ln_sdat "30-year autumn temperature SD(log)"
label var ln_sdwt "30-year winter temperature SD(log)"
label var srshock "Rainfall shock in summer"
label var rrshock "Rainfall shock in rainy season"
label var arshock "Rainfall shock in autumn"
label var wrshock "Rainfall shock in winter"
label var stshock "Temperature shock in summer"
label var rtshock "Temperature shock in rainy season"
label var atshock "Temperature shock in autumn"
label var wtshock "Temperature shock in winter"

/*replace dcode=1 if District_Name=="Dhaka"
replace dcode=2 if District_Name=="Gazipur"
replace dcode=3 if District_Name=="Manikganj"
replace dcode=4 if District_Name=="Munshiganj"
replace dcode=5 if District_Name=="Narayanganj"
replace dcode=6 if District_Name=="Narsingdi"
replace dcode=7 if District_Name=="Faridpur"
replace dcode=8 if District_Name=="Gopalganj"
replace dcode=9 if District_Name=="Madaripur"
replace dcode=10 if District_Name=="Rajbari"
replace dcode=11 if District_Name=="Shariatpur"
replace dcode=12 if District_Name==""
replace dcode=13 if District_Name=="Sherpur"
replace dcode=14 if District_Name==""
replace dcode=15 if District_Name==""
replace dcode=16 if District_Name=="Netrakona"
replace dcode=17 if District_Name=="Tangail"
replace dcode=18 if District_Name==""
replace dcode=19 if District_Name=="Cox's Bazar"
replace dcode=20 if District_Name==""
replace dcode=21 if District_Name==""
replace dcode=22 if District_Name=="Rangamati"
replace dcode=23 if District_Name==""
replace dcode=24 if District_Name=="Chandpur"
replace dcode=25 if District_Name==""
replace dcode=26 if District_Name==""
replace dcode=27 if District_Name==""
replace dcode=28 if District_Name=="Noakhali"
replace dcode=29 if District_Name==""
replace dcode=30 if District_Name==""
replace dcode=31 if District_Name==""
replace dcode=32 if District_Name==""
replace dcode=33 if District_Name==""
replace dcode=34 if District_Name==""
replace dcode=35 if District_Name=="Satkhira"
replace dcode=36 if District_Name==""
replace dcode=37 if District_Name==""
replace dcode=38 if District_Name==""
replace dcode=39 if District_Name=="Rajshahi"
replace dcode=40 if District_Name=="Naogon"
replace dcode=41 if District_Name=="Chapai Nawabganj"
replace dcode=42 if District_Name=="Natore"
replace dcode=43 if District_Name=="Pabna"
replace dcode=44 if District_Name=="Sirajganj"
replace dcode=45 if District_Name=="Bogra"
replace dcode=46 if District_Name==""
replace dcode=47 if District_Name==""
replace dcode=48 if District_Name==""
replace dcode=49 if District_Name==""
replace dcode=50 if District_Name=="Nilphamari"
replace dcode=51 if District_Name=="Rangpur"
replace dcode=52 if District_Name=="Dinajpur"
replace dcode=53 if District_Name=="Thakurgaon" 
replace dcode=54 if District_Name=="Panchagarh"
replace dcode=55 if District_Name=="Sylhet"
replace dcode=56 if District_Name==""
replace dcode=57 if District_Name==""
replace dcode=58 if District_Name=="Sunamganj"
replace dcode=59 if District_Name==""
replace dcode=60 if District_Name==""
replace dcode=61 if District_Name==""
replace dcode=62 if District_Name=="Pirojpur"
replace dcode=63 if District_Name==""
replace dcode=64 if District_Name=="Patuakhali"*/

save climate18, replace

**merge all 2018 dataset
use 2018.dta,clear

merge m:1 dvcode using climate18, nogen
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
merge 1:1 a01 using facility18, nogen
merge 1:1 a01 using extension18, nogen
label var farmsize "Farm Size(decimal)"
label var ln_farm "Farm size(log)"
//gen lnoff=log(offrmagr)
gen year=2018
save 2018.dta, replace


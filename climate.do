/*create dataset for regression*/
/*Author: Masanori Matsuura*/
ssc install geonear
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


*install district data and cleaning 
import delimited using $climate\districts.csv,  clear //import new district data which are comparable with BIHS
save district.dta, replace

import delimited District_n Division_n District district latitude longitude  url using $climate\districts.txt, stringcols(1/7) clear
save districts.dta, replace
drop district url //cleaning
 
replace District="Bogra" if District=="Bogura"
replace District="Chapai Nawabganj" if District== "Chapainawabganj"
replace District="Chittagong" if District=="Chattogram"
replace District="Cox's Bazar" if District=="Coxsbazar"
replace District="Jessore" if District=="Jashore"
replace District="Jhalokati" if District=="Jhalakathi"
replace District="Maulvibazar" if District=="Moulvibazar"
replace District="Netrakona" if District=="Netrokona"

destring District_n, gen(district_n)
destring Division_n, gen(division_n)
replace latitude="." if (latitude=="NULL") 
replace longitude="." if (longitude=="NULL")
destring latitude, gen(lat)
destring longitude, gen(lon)
drop District_n Division_n latitude longitude
replace lat=22.6333308 if (district_n==4) //replace missing value with true
replace lon=92.1999992 if (district_n==4)
replace lat=21.583331 if(district_n==9)
replace lon=92.0166666 if (district_n==9)
replace lat=24.373309 if (district_n==15)
replace lon=88.604872 if (district_n==15)
replace lat=25.105101 if (district_n==17)
replace lon=89.028877 if (district_n==17)
replace lat=24.91316 if (district_n==19)
replace lon=88.753095 if (district_n==19)
replace lat=22.35 if (district_n==21)
replace lon=89.15 if (district_n==21)
replace lat=22.57208 if (district_n==30)
replace lon=90.186964 if (district_n==30)
replace lat=22.5367 if (district_n==32)
replace lon=90.0003 if (district_n==32) 
replace lat=22.7029212 if (district_n==33)
replace lon=90.34659710000005 if (district_n==33)
replace lat=22.095292 if (district_n==35)
replace lon=90.11207 if (district_n==35)
replace lat=23.242321 if (district_n==42)
replace lon=90.434771 if (district_n==42)
replace lat=24.2498400 if (district_n==44)
replace lon= 89.9165500 if (district_n==44)
replace lat=23.8667 if (district_n==46)
replace lon=89.9500 if (district_n==46)
replace lat=23.498093 if (district_n==48)
replace lon=90.412662 if (district_n==48)
replace lat=26.0000 if (district_n==55)
replace lon=89.2500 if (district_n==55)
save districts, replace //replace missing value with latitude and longitudes
rename District dcode
save districts.dta, replace 

merge 1:1 dcode using district, nogen
replace lat=24.8500 if (district==10)
replace lon=89.3667 if (district==10) //replace missing value with true
replace lat=24.6000 if (district==70)
replace lon=88.2667 if (district==70)
replace lat=22.341900 if (district==15)
replace lon=91.815536 if (district==15)
replace lat=21.5833 if (district==22)
replace lon=92.0167 if (district==22)
replace lat=23.170664 if (district==41)
replace lon=89.212418 if (district==41)
replace lat=22.6000 if (district==42)
replace lon=90.2000 if (district==42)
replace lat=24.4778 if (district==58)
replace lon=91.7667 if (district==58)
replace lat=24.934725 if (district==72)
replace lon=90.751511 if (district==72)
keep district dcode lat lon
drop if district==.
save district.dta, replace //true district data and comparable with BIHS

/*import excel $climate\division.xlsx, firstrow clear
save division.dta, replace*/

import delimited using $climate\rain1.csv, clear
rename v1 nid
save rain1.dta, replace
import delimited using $climate\temp1.csv, clear
rename v1 nid
save temp1.dta, replace

import delimited using $climate\rain2.csv, clear
rename (v1 var1 var2)(nid lon lat)
save rain2.dta, replace
import delimited using $climate\temp2.csv, clear
rename v1 nid
save temp2.dta, replace


*** rainfall
use district, clear
geonear district lat lon using rain1.dta, neighbors(nid lat lon) //match with rain and dcode
geonear district lat lon using rain2.dta, neighbors(nid lat lon) //match with rain and 
save climate.dta, replace
use climate, clear
drop km_to_nid
merge m:m nid using rain1.dta, nogen //merge dvcode data and  rain data
merge m:m nid using rain2.dta, nogen //merge dvcode data and  rain data
drop if district==.
destring (hs1 hr1 ha1 hw1 hs2 hr2 ha2 hw2 hs3 hr3 ha3 hw3 s1 r1 a1 w1 s2 r2 a2 w2 s3 r3 a3 w3 sds1 sdr1 sda1 sdw1 sds2 sdr2 sda2 sdw2 sds3 sdr3 sda3 sdw3), replace
label var sds1 "30-year summer rainfall SD"
label var sds2 "30-year summer rainfall SD"
label var sds3 "30-year summer rainfall SD"
label var sdr1 "30-year rainy season rainfall SD"
label var sdr2 "30-year rainy season rainfall SD"
label var sdr3 "30-year rainy season rainfall SD"
label var sda1 "30-year autumn rainfall SD"
label var sda2 "30-year autumn rainfall SD"
label var sda3 "30-year autumn rainfall SD"
label var sdw1 "30-year winter rainfall SD"
label var sdw2 "30-year winter rainfall SD"
label var sdw3 "30-year winter rainfall SD"
save climate, replace

*** temperature
geonear district lat lon using temp1.dta, neighbors(nid lat lon) //merge dvcode data and temperature data
geonear district lat lon using temp2.dta, neighbors(nid lat lon) //merge dvcode data and temperature data
drop km_to_nid
merge m:m nid using temp1.dta, nogen //merge
merge m:m nid using temp2.dta, nogen //merge

drop if district==.
save qgis_climate.dta, replace
drop nid nid lat lon 
label var sdst1 "30-year summer temperature SD"
label var sdst2 "30-year summer temperature SD"
label var sdst3 "30-year summer temperature SD"
label var sdrt1 "30-year rainy season temperature SD"
label var sdrt2 "30-year rainy season temperature SD"
label var sdrt3 "30-year rainy season temperature SD"
label var sdat1 "30-year autumn temperature SD"
label var sdat2 "30-year autumn temperature SD"
label var sdat3 "30-year autumn temperature SD"
label var sdwt1 "30-year winter temperature SD"
label var sdwt2 "30-year winter temperature SD"
label var sdwt3 "30-year winter temperature SD"
save climate, replace

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
import delimited District_n Division_n District district latitude longitude  url using $climate\districts.txt, stringcols(1/7) clear
save districts.dta, replace
drop district url //cleaning 
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
import delimited using $climate\districts.csv,  clear //import new district data which are comparable with BIHS
save district.dta, replace
merge 1:1 dcode using districts, nogen
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
** match using geonear
use district, clear

geonear district lat lon using rain1.dta, neighbors(nid lat lon) //match with rain and district
geonear district lat lon using rain2.dta, neighbors(nid lat lon) //match with rain and 
save climate.dta, replace
use climate, clear
drop km_to_nid
merge m:m nid using rain1.dta, nogen //merge district data and  rain data
merge m:m nid using rain2.dta, nogen //merge district data and  rain data


rename (s1 r1 a1 w1 s2 r2 a2 w2 s3 r3 a3 w3 sd1 sd2 sd3)(rs1 rr1 ra1 rw1 rs2 rr2 ra2 rw2 rs3 rr3 ra3 rw3 rsd1 rsd2 rsd3)
drop if district==.

destring (rs1 rr1 ra1 rw1 rs2 rr2 ra2 rw2 rs3 rr3 ra3 rw3 rsd1 rsd2 rsd3), replace
gen rw1=(rw11+rw12+rw13)/3
gen rs1=(rs11+rs12+rs13)/3
gen rr1=(rr11+rr12+rr13)/3
gen ra1=(ra11+ra12+ra13)/3
label var rw1 "Winter rainfall"
label var rs1 "Summer rainfall"
label var rr1 "Rainy rainfall"
label var ra1 "Autumn rainfall"
gen rw2=(rw21+rw22+rw23)/3
gen rs2=(rs21+rs22+rs23)/3
gen rr2=(rr21+rr22+rr23)/3
gen ra2=(ra21+ra22+ra23)/3
label var rw2 "Winter rainfall"
label var rs2 "Summer rainfall"
label var rr2 "Rainy rainfall"
label var ra2 "Autumn rainfall"
gen rw3=(rw31+rw32+rw33)/3
gen rs3=(rs31+rs32+rs33)/3
gen rr3=(rr31+rr32+rr33)/3
gen ra3=(ra31+ra32+ra33)/3
label var rw3 "Winter rainfall"
label var rs3 "Summer rainfall"
label var rr3 "Rainy rainfall"
label var ra3 "Autumn rainfall"


label var rsd1 "St.dev monthly rainfall"
label var rsd2 "St.dev monthly rainfall"
label var rsd3 "St.dev monthly rainfall"
save climate, replace

geonear district lat lon using temp1.dta, neighbors(nid lat lon) //merge district data and temperature data
geonear district lat lon using temp2.dta, neighbors(nid lat lon) //merge district data and temperature data
drop km_to_nid
merge m:m nid using temp1.dta, nogen //merge
merge m:m nid using temp2.dta, nogen //merge


rename (s1 r1 a1 w1 s2 r2 a2 w2 s3 r3 a3 w3 sd1 sd2 sd3)(ts1 tr1 ta1 tw1 ts2 tr2 ta2 tw2 ts3 tr3 ta3 tw3 tsd1 tsd2 tsd3)
drop if district==.
save qgis_climate.dta, replace
drop nid nid lat lon 
gen tw1=(tw11+tw12+tw13)/3
gen ts1=(ts11+ts12+ts13)/3
gen tr1=(tr11+tr12+tr13)/3
gen ta1=(ta11+ta12+ta13)/3
label var tw1 "Winter temperature"
label var ts1 "Summer temperature"
label var tr1 "Rainy temperature"
label var ta1 "Autumn temperature"
gen tw2=(tw21+tw22+tw23)/3
gen ts2=(ts21+ts22+ts23)/3
gen tr2=(tr21+tr22+tr23)/3
gen ta2=(ta21+ta22+ta23)/3
label var tw2 "Winter temperature"
label var ts2 "Summer temperature"
label var tr2 "Rainy temperature"
label var ta2 "Autumn temperature"
gen tw3=(tw31+tw32+tw33)/3
gen ts3=(ts31+ts32+ts33)/3
gen tr3=(tr31+tr32+tr33)/3
gen ta3=(ta31+ta32+ta33)/3
label var tw3 "Winter temperature"
label var ts3 "Summer temperature"
label var tr3 "Rainy temperature"
label var ta3 "Autumn temperature"

label var tsd1 "St.dev monthly temperature"
label var tsd2 "St.dev monthly temperature"
label var tsd3 "St.dev monthly temperature"
drop ta12 tw13 ts13 tr13 ta13 tw21 tr21 ts21 ta21 tw22 ts22 tr22 ta22 tw23 tr23 ts23 ta23 tw31 ts31 tr31 ta31 tw32 ts32 tr32 ta32 tw33 ts33 tr33 ta33 rw11 rs11 rr11 ra11 rw12 rs12 rr12 ra12 rw13 rs13 rr13 ra13 rw21 rr21 rs21 ra21 rw22 rs22 rr22 ra22 rw23 rr23 rs23 ra23 rw31 rs31 rr31 ra31 rw32 rs32 rr32 ra32 rw33 rs33 rr33 ra33
save climate, replace

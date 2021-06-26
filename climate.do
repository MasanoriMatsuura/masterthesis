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

** match climate data with district
import delimited using $climate\rain.csv, clear
rename v1 nid
save rain.dta, replace
import delimited using $climate\temp.csv, clear
rename v1 nid
save temp.dta, replace


** match using geonear
use district, clear
ssc install geonear
geonear district lat lon using rain.dta, neighbors(nid lat lon) //match with rain and district
save climate.dta, replace
use climate, clear
drop km_to_nid
merge m:m nid using rain.dta, nogen //merge district data and  rain data

rename (mean1 mean2 mean3 sd1 sd2 sd3)(rinmn1 rinmn2 rinmn3 rinsd1 rinsd2 rinsd3) //cleaning
drop if district==.
destring (rinmn1 rinmn2 rinmn3 rinsd1 rinsd2 rinsd3), replace
save climate, replace
geonear district lat lon using temp.dta, neighbors(nid lat lon) //merge district data and temperature data
drop km_to_nid
merge m:m nid using temp.dta, nogen //merge
rename (mean1 mean2 mean3 sd1 sd2 sd3)(tmpmn1 tmpmn2 tmpmn3 tmpsd1 tmpsd2 tmpsd3) //renaming 
drop if district==.
drop nid nid lat lon 
save climate, replace

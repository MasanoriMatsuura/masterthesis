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

cd "C:\Users\mm_wi\Documents\Masterthesis\BIHS\Do"

*install district data and cleaning 
import delimited District_n Division_n District district latitude longitude  url using $climate\districts.txt, stringcols(1/7) clear
save districts.dta
drop district url //cleaning 
destring District_n, gen(district_n)
destring Division_n, gen(division_n)
replace latitude="." if (latitude=="NULL") 
replace longitude="." if (longitude=="NULL")
destring latitude, gen(lat)
destring longitude, gen(lon)
drop District_n Division_n latitude longitude
replace lat=22.375999 if (district_n==4)
replace lon=92.116000 if (district_n==4)
replace lat=21.2910 if(district_n==9)
replace lon=91.5470 if (district_n==9)
replace lat=24.222640 if (district_n==15)
replace lon=88.364010 if (district_n==15)
replace lat=25.503012 if (district_n==17)
replace lon=89.023012 if (district_n==17)
replace lat=24.481505 if (district_n==19)
replace lon=88.565550 if (district_n==19)
replace lat=22.422941 if (district_n==21)
replace lon=89.041866 if (district_n==21)
replace lat=22.341948 if (district_n==30)
replace lon=90.111307 if (district_n==30)
replace lat=22.34467 if (district_n==32)
replace lon=89.58308 if (district_n==32) 
replace lat=22.421789 if (district_n==33)
replace lon=90.221247 if (district_n==33)
replace lat=22.421789 if (district_n==35)
replace lon=90.221247 if (district_n==35)
replace lat=23.1236 if (district_n==42)
replace lon=90.2059 if (district_n==42)
replace lat=24.145942 if (district_n==44)
replace lon=89.545958 if (district_n==44)
replace lat=23.330000 if (district_n==48)
replace lon=90.220012 if (district_n==48)
replace lat=23.520012 if (district_n==46)
replace lon=89.570000 if (district_n==46)
replace lat=26.000000 if (district_n==55)
replace lon=89.150000 if (district_n==55)
save districts, replace

* match climate data with district
import delimited using $climate\rain.csv, clear
save rain.dta
use rain, clear
rename v1 nid
import delimited using $climate\temp.csv, clear
save temp.dta
use districts, clear
ssc install geonear
geonear district_n lat lon using rain.dta, neighbors(v1 lat lon) //match
save climate.dta
use climate, clear
rename nid v1 //cleaning 
drop km_to_nid
merge m:m v1 using rain.dta, nogen //merge
drop if district_n==.
rename (mean1 mean2 mean3 sd1 sd2 sd3)(rinmn1 rinmn2 rinmn3 rinsd1 rinsd2 rinsd3) //cleaning
replace rinmn1=". " if(rinmn1=="NA")
replace rinmn2=". " if(rinmn2=="NA")
replace rinmn3=". " if(rinmn3=="NA")
replace rinsd1=". " if(rinsd1=="NA")
replace rinsd2=". " if(rinsd2=="NA")
replace rinsd3=". " if(rinsd3=="NA")
destring (rinmn1 rinmn2 rinmn3 rinsd1 rinsd2 rinsd3), replace
save climate, replace
geonear district_n lat lon using temp.dta, neighbors(v1 lat lon) //match
drop km_to_nid
merge m:m v1 using temp.dta, nogen //merge
rename (mean1 mean2 mean3 sd1 sd2 sd3)(tmpmn1 tmpmn2 tmpmn3 tmpsd1 tmpsd2 tmpsd3) //cleaning
drop if district_n==.
drop v1 nid lat lon 
save climate, replace

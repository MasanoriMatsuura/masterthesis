/*create dataset for regression*/
/*Author: Masanori Matsuura*/
clear all
set more off
*set the pathes
global climate = "C:\Users\mm_wi\Documents\Masterthesis\climatebang"
global BIHS18Community = "C:\Users\mm_wi\Documents\Masterthesis\BIHS\BIHS2018\dataverse_files\BIHSRound3\Community"
global BIHS18Female = "C:\Users\mm_wi\Documents\Masterthesis\BIHS\BIHS2018\dataverse_files\BIHSRound3\Female"
global BIHS18Male = "C:\Users\mm_wi\Documents\Masterthesis\BIHS\BIHS2018\dataverse_files\BIHSRound3\Male"
global BIHS15 = "C:\Users\mm_wi\Documents\Masterthesis\BIHS\BIHS2015"
global BIHS12 = "C:\Users\mm_wi\Documents\Masterthesis\BIHS\BIHS2012"
cd "C:\Users\mm_wi\Documents\Masterthesis\BIHS\Do"

*BIHS2015 data cleaning 
**keep geographical code
use $BIHS15\001_r2_mod_a_male, clear
keep a01 dvcode dcode District_Name uzcode uncode mzcode Village
save 2015, replace
** keep age gender education of HH
use $BIHS15\003_r2_male_mod_b1.dta, clear
keep if b1_03==1 
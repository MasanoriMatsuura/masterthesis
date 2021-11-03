*set the pathes
global climate = "C:\Users\user\Documents\Masterthesis\climatebang"
global BIHS18Community = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2018\dataverse_files\BIHSRound3\Community"
global BIHS18Female = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2018\dataverse_files\BIHSRound3\Female"
global BIHS18Male = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2018\dataverse_files\BIHSRound3\Male"
global BIHS15 = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2015"
global BIHS12 = "C:\Users\user\Documents\Masterthesis\BIHS\BIHS2012"
global table = "C:\Users\user\Documents\Masterthesis\NTUtemplate\table"
global figure = "C:\Users\user\Documents\Masterthesis\NTUtemplate\figures"
global shape = "C:\Users\user\Documents\QGIS\mthesis\bgd_adm_bbs_20201113_shp\bgd_adm_bbs_20201113_SHP"
cd "C:\Users\user\Documents\Masterthesis\BIHS\Do"

/*https://medium.com/the-stata-guide/maps-in-stata-ii-fcb574270269*/

** install packages
ssc install geo2xy, replace
ssc install palettes, replace
ssc install schemepack, replace
ssc install spmap, replace
graph set window fontface "Arial Narrow"

** shapefile
spshape2dta "$shape/bgd_admbnda_adm2_bbs_20201113.shp", replace saving(nuts2)

use nuts2, clear 
spmap using nuts2_shp, id(_ID) // identifier of each region

** coloring
spmap _ID using nuts2_shp, id(_ID) cln(5) fcolor(Heat) ///
legend(pos(1) size(2.5)) legstyle(2)

** Map labels
keep _ID _CY _CX ADM2_EN
compress
save nuts2_labels, replace

*** add climate data
use nuts2, clear
rename ADM2_EN dcode
replace dcode = "Brahmanbaria" if dcode == "Brahamanbaria"
replace dcode = "Chapai Nawabganj" if dcode == "Nawabganj"
merge 1:1 dcode using climate
drop _m

***  plot the st.dev rainfall first wave
spmap rsd1 using nuts2_shp, ///
 id(_ID) cln(5) fcolor(Heat) ///
 legend(pos(11) size(2.5))  legstyle(2) ///
 legend(pos(1) size(2.5))
 //label(data(nuts2_labels) x(_CX) y(_CY) label(ADM2_EN) color(black) size(1.5)) legend(pos(1) size(2.5))



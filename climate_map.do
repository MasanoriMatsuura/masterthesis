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

***  plot the st.dev rainfall for three waves
gen aversd=(rsd1+rsd2+rsd3)/3 //average standard deviation of rainfall

spmap aversd using nuts2_shp, ///
 id(_ID) cln(10)  fcolor(Heat) ///
 ocolor(gs2 ..) osize(0.03 ..) ///
 legstyle(2) legend(pos(1) size(2)) ///
 polygon(data("nuts2_shp") ocolor(black) osize(0.08) legenda(on) legl("Districts")) ///
 title("{fontface Arial Bold: St.dev of rainfall for three waves}", size(medsmall)) ///
 note("Data source: Bangladesh Meteorological Department Climate Data Library. Computed by authers")
graph export $figure\stdev_rain.pdf, replace

***  plot the rainy season rainfall for three waves
gen averr=(rr1+rr2+rr3)/3 //rainy season rainfall

spmap averr using nuts2_shp, ///
 id(_ID) cln(10)  fcolor(Heat) ///
 ocolor(gs2 ..) osize(0.03 ..) ///
 legstyle(2) legend(pos(1) size(2)) ///
 polygon(data("nuts2_shp") ocolor(black) osize(0.08) legenda(on) legl("Districts")) ///
 title("{fontface Arial Bold: Average rainy season rainfall for three waves}", size(medsmall)) ///
 note("Data source: Bangladesh Meteorological Department Climate Data Library. Computed by authers")
graph export $figure\rainy_rain.pdf, replace
 
***  plot the rainy season temperature for three waves
gen avetr=(tr1+tr2+tr3)/3 //rainy season temperature

spmap avetr using nuts2_shp, ///
 id(_ID) cln(10)  fcolor(Heat) ///
 ocolor(gs2 ..) osize(0.03 ..) ///
 legstyle(2) legend(pos(1) size(2)) ///
 polygon(data("nuts2_shp") ocolor(black) osize(0.08) legenda(on) legl("Districts")) ///
 title("{fontface Arial Bold: Average rainy season temperature for three waves}", size(medsmall)) ///
 note("Data source: Bangladesh Meteorological Department Climate Data Library. Computed by authers")
graph export $figure\rainy_rain.pdf, replace

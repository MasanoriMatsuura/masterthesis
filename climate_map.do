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

/*Manual: https://medium.com/the-stata-guide/maps-in-stata-ii-fcb574270269*/

** install packages
ssc install geo2xy, replace
ssc install palettes, replace
ssc install schemepack, replace
ssc install spmap, replace
 ssc install colrspace, replace
** graph setting
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




*** plot the rainy season rainfall for three waves
gen averr=(sdr1+sdr2+sdr3)/3  

colorpalette HCL blues , n(8) nograph reverse //colorpalette 
local colors `r(p)'


spmap averr using nuts2_shp, ///
 id(_ID) cln(8)  fcolor(`r(p)') ///
 ocolor(gs2 ..) osize(0.03 ..) ///
 legstyle(2) legend(pos(1) size(2)) ///
 polygon(data("nuts2_shp") ocolor(black) osize(0.08) legenda(on) legl("Districts")) ///
 title("{fontface Arial Bold: 30-year rainy season rainfall SD}", size(medsmall)) ///
saving(rainy_rain) 


***  plot the rainy season temperature for three waves
gen avetr=(sdrt1+sdrt2+sdrt3)/3 //rainy season temperature

spmap avetr using nuts2_shp, ///
 id(_ID) cln(8)  fcolor(Heat) ///
 ocolor(gs2 ..) osize(0.03 ..) ///
 legstyle(2) legend(pos(1) size(2)) ///
 polygon(data("nuts2_shp") ocolor(black) osize(0.08) legenda(on) legl("Districts")) ///
 title("{fontface Arial Bold: 30-year rainy season temperature SD for three waves}", size(medsmall)) ///
  saving(rainy_temp)
 
*** combine figures
gr combine rainy_rain.gph rainy_temp.gph, note("Data source: Bangladesh Meteorological Department Climate Data Library. Computed by authers")
graph display, scheme(s1color)
graph export $figure\climate.png, replace

** Appendix figures for climate indicators
***  plot the summer season rainfall for three waves
gen avers=(sds1+sds2+sds3)/3 //summer season rainfall
colorpalette HCL blues , n(8) nograph reverse //colorpalette 
local colors `r(p)'
spmap avers using nuts2_shp, ///
 id(_ID) cln(8)  fcolor(`r(p)') ///
 ocolor(gs2 ..) osize(0.03 ..) ///
 legstyle(2) legend(pos(1) size(2)) ///
 polygon(data("nuts2_shp") ocolor(black) osize(0.08) legenda(on) legl("Districts")) ///
 title("{fontface Arial Bold: 30-year summer rainfall SD for three waves}", size(medsmall)) ///
saving(summer_rain) 

gen avets=(sdst1+sdst2+sdst3)/3 //summer temperature

spmap avets using nuts2_shp, ///
 id(_ID) cln(8)  fcolor(Heat) ///
 ocolor(gs2 ..) osize(0.03 ..) ///
 legstyle(2) legend(pos(1) size(2)) ///
 polygon(data("nuts2_shp") ocolor(black) osize(0.08) legenda(on) legl("Districts")) ///
 title("{fontface Arial Bold: 30-year summer temperature SD for three waves}", size(medsmall)) ///
  saving(summer_temp)
**autumn 
gen avera=(sda1+sda2+sda3)/3 //autumn rainfall
colorpalette HCL blues , n(8) nograph reverse //colorpalette 
local colors `r(p)'
spmap avera using nuts2_shp, ///
 id(_ID) cln(8)  fcolor(`r(p)') ///
 ocolor(gs2 ..) osize(0.03 ..) ///
 legstyle(2) legend(pos(1) size(2)) ///
 polygon(data("nuts2_shp") ocolor(black) osize(0.08) legenda(on) legl("Districts")) ///
 title("{fontface Arial Bold: 30-year autum rainfall SD for three waves}", size(medsmall)) ///
saving(autumn_rain) 

gen aveta=(sdat1+sdat2+sdat3)/3 //autumn temperature

spmap aveta using nuts2_shp, ///
 id(_ID) cln(8)  fcolor(Heat) ///
 ocolor(gs2 ..) osize(0.03 ..) ///
 legstyle(2) legend(pos(1) size(2)) ///
 polygon(data("nuts2_shp") ocolor(black) osize(0.08) legenda(on) legl("Districts")) ///
 title("{fontface Arial Bold: 30-year autumn temperature SD for three waves}", size(medsmall)) ///
  saving(autumn_temp)
  
**winter
gen averw=(sdw1+sdw2+sdw3)/3 //winter rainfall
colorpalette HCL blues , n(8) nograph reverse //colorpalette 
local colors `r(p)'
spmap averw using nuts2_shp, ///
 id(_ID) cln(8)  fcolor(`r(p)') ///
 ocolor(gs2 ..) osize(0.03 ..) ///
 legstyle(2) legend(pos(1) size(2)) ///
 polygon(data("nuts2_shp") ocolor(black) osize(0.08) legenda(on) legl("Districts")) ///
 title("{fontface Arial Bold: 30-year winter rainfall SD for three waves}", size(medsmall)) ///
saving(winter_rain) 

gen avetw=(sdwt1+sdwt2+sdwt3)/3 //winter temperature

spmap avetw using nuts2_shp, ///
 id(_ID) cln(8)  fcolor(Heat) ///
 ocolor(gs2 ..) osize(0.03 ..) ///
 legstyle(2) legend(pos(1) size(2)) ///
 polygon(data("nuts2_shp") ocolor(black) osize(0.08) legenda(on) legl("Districts")) ///
 title("{fontface Arial Bold: 30-year winter temperature SD for three waves}", size(medsmall)) ///
  saving(winter_temp)
  


** combine
gr combine winter_rain.gph winter_temp.gph, note("Data source: BIHS2011/12, 2015, 2018/2019. Computed by authers")
graph display, scheme(s1color) 
graph export $figure\winter.png, replace
 gr combine summer_rain.gph summer_temp.gph, note("Data source: BIHS2011/12, 2015, 2018/2019. Computed by authers")
graph display, scheme(s1color) 
graph export $figure\summer.png, replace
gr combine autumn_rain.gph autumn_temp.gph, note("Data source: BIHS2011/12, 2015, 2018/2019. Computed by authers")
graph display, scheme(s1color) 
graph export $figure\autumn.png, replace


** add food security data
use dependent, clear

decode dcode, gen(dcode1)
drop dcode
rename dcode1 dcode
drop if dcode==""
save dependent, replace
use nuts2, clear
rename ADM2_EN dcode
replace dcode = "Brahmanbaria" if dcode == "Brahamanbaria"
replace dcode = "Chapai Nawabganj" if dcode == "Nawabganj"
merge 1:1 dcode using dependent
drop _m

** consumption expenditure
colorpalette HCL greens , n(8) nograph reverse //colorpalette 
local colors `r(p)'

spmap divfexp using nuts2_shp, ///
 id(_ID) cln(8)  fcolor(`r(p)') ///
 ocolor(gs2 ..) osize(0.03 ..) ///
 legstyle(2) legend(pos(1) size(2)) ///
 polygon(data("nuts2_shp") ocolor(black) osize(0.08) legenda(on) legl("Districts")) ///
 title("{fontface Arial Bold: Average per capita food expenditure for three waves}", size(medsmall))  ///
 saving(fexp)
 
** hdds
colorpalette HCL greens , n(8) nograph reverse //colorpalette 
local colors `r(p)'

spmap divhdds using nuts2_shp, ///
id(_ID) cln(8)  fcolor(`r(p)') ///
ocolor(gs2 ..) osize(0.03 ..) ///
legstyle(2) legend(pos(1) size(2)) ///
polygon(data("nuts2_shp") ocolor(black) osize(0.08) legenda(on) legl("Districts")) ///
title("{fontface Arial Bold: Average HDDS for three waves}", size(medsmall)) ///
saving(hdds)

*** combine figures
gr combine fexp.gph hdds.gph, note("Data source: BIHS2011/12, 2015, 2018/2019. Computed by authers")
graph display, scheme(s1color)
graph export $figure\fsecurity.png, replace



  
 
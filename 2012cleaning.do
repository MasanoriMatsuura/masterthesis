cd "C:\Users\mm_wi\Documents\Masterthesis\data\2012_FIES\detail_data\Data_file"

***import 2012 FIES data***
infix using "C:\Users\mm_wi\Documents\Masterthesis\data\2012_FIES\detail_data\Data_file\Exported.dct", using("C:\Users\mm_wi\Documents\Masterthesis\data\2012_FIES\detail_data\Data_file\Exported.txt"), clear

save "2012FIES.dta", replace
use "2012FIES.dta"

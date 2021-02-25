cd "C:\Users\mm_wi\Documents\Masterthesis\data\2015_FIES\detail_data"
***import 2015 FIES data***
infix using "Exported.dct", using("Exported.txt")
save "2015FIES.dta", replace
use "2015FIES.dta"


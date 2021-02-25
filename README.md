# masterthesis
how to convert puf file into dta format using CSPro
## 1 Open "exsiting file" and choose dcf file 
## 2 click "tools" and click "Export data"
## 3 select dcf file
## 4 select Stata as a export format
## 5 click "file" and Run (ctrl+R)
## 6 select dat file and open and OK
## then success! 
 Open stata and import the data 
## the command is 
infix using"~/Exported.dct", using("~/Exported.txt")
check the data set using browse! Done ;)

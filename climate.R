###data cleaning for climate variables
pacman::p_load('ncdf4','dplyr')
#extract rainfall data (Jan 1981 to Mar 2021)
ncpath <- "C:/Users/user/Documents/Masterthesis/climatebang/"
ncname_r <- "rain"
ncfname_r <- paste(ncpath, ncname_r, ".nc", sep = "")
dname_r <- "rfe_merged"
ncin_r <- nc_open(ncfname_r)
print(ncin_r)
###get coordinate variables (lon, lat, time)
lat_r <- ncvar_get(ncin_r, "Y")
nlat_r<-dim(lat_r)
lon_r <- ncvar_get(ncin_r, "X")
nlon_r <- dim(lon_r)
print(c(nlon_r,nlat_r))

time_r <- ncvar_get(ncin_r, "T")
tunits_r <- ncatt_get(ncin_r, "T", "units")
nt_r <-dim(time_r)
nt_r
tunits_r
#get rain
rin_array <- ncvar_get(ncin_r, dname_r)
dlname_r <- ncatt_get(ncin_r, dname_r, "long_name")
dunits_r<- ncatt_get(ncin_r, dname_r, "units")
fillvalue <- ncatt_get(ncin_r, dname_r, "_FillValue")
dim(rin_array)
title_r <- ncatt_get(ncin_r,0,"title")
institution_r <- ncatt_get(ncin_r,0,"institution")
datasource_r <-ncatt_get(ncin_r, 0, "source")
references_r <- ncatt_get(ncin_r, 0, "reference")
history_r <- ncatt_get(ncin_r, 0, "history")
Conventions_r <- ncatt_get(ncin_r,0,"Conventions")
nc_close(ncin_r) #close netCDF
ls()
#Reshaping from raster to rectangular
library(chron)
library(lattice)
library(RColorBrewer)
rustr <- strsplit(tunits_r$value, " ")
rdstr <- strsplit(unlist(rustr)[3], "-")
rmonth <- as.integer(unlist(rdstr)[2])
rday <- as.integer(unlist(rdstr)[3])
ryear <- as.integer(unlist(rdstr)[1])
chron(time_r,origin=c(rmonth, rday, ryear))


#reshape the array into vector for whole time
rin_vec_long <- as.vector(rin_array)
length(rin_vec_long)

rin_mat <- matrix(rin_vec_long, nrow=nlon_r*nlat_r, ncol = nt_r)
dim(rin_mat)
#head(na.omit(tmp_mat))
lonlat_r <- as.matrix(expand.grid(lon_r,lat_r))
rin_df02 <- data.frame(cbind(lonlat_r),rin_mat)
names(rin_df02) <- c("lon", "lat")

#30 years historical
rin_hist1 <- rin_df02[c(17:376)] #1982 March-2012 Feb monthly data without lon and lat
rin_hist2 <- rin_df02[c(47:412)]# 1985 March-2015 Feb
rin_hist3 <- rin_df02[c(95:460)]# 1989 March-2019 Feb
s <- rin_hist1[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)] %>% View() # 30 years historical summer for 2011
r <- rin_hist1[, c(FALSE,FALSE,FALSE,TALSE,TALSE,TALSE,TALSE,FALSE,FALSE,FALSE,FALSE,FALSE)] %>% View() # 30 years historical summer for 2011
a <- rin_hist1[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)] %>% View() # 30 years historical summer for 2011
w <- rin_hist1[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)] %>% View() # 30 years historical summer for 2011

rin_data1$s1 <- apply(rin_data1[3:5],1,sum)
rin_data1$r1 <- apply(rin_data1[6:9],1,sum)
rin_data1$a1 <- apply(rin_data1[10:11],1,sum)
rin_data1$w1 <- apply(rin_data1[12:14],1,sum) #30 years historical 2012 winter
rin_data1$s2 <- apply(rin_data1[39:41],1,sum) #2014 summer
rin_data1$r2 <- apply(rin_data1[42:45],1,sum)
rin_data1$a2 <- apply(rin_data1[46:47],1,sum)
rin_data1$w2 <- apply(rin_data1[48:50],1,sum) #2015 winter
rin_data1$s3 <- apply(rin_data1[87:89],1,sum) #2018 summer
rin_data1$r3 <- apply(rin_data1[90:93],1,sum)
rin_data1$a3 <- apply(rin_data1[94:95],1,sum)
rin_data1$w3 <- apply(rin_data1[96:98],1,sum) #2019 winter

rin_data_sta1 <- subset(rin_data1,select=c(1,2,124:141))

### Main
rin_data2 <- rin_df02[c(1,2,365:460)] #2011 March -2019 Feb
rin_data2$s1 <- apply(rin_data2[3:5],1,sum)#2011 summer
rin_data2$r1 <- apply(rin_data2[6:9],1,sum)
rin_data2$a1 <- apply(rin_data2[10:11],1,sum)
rin_data2$w1 <- apply(rin_data2[12:14],1,sum) #2012 winter
rin_data2$s2 <- apply(rin_data2[39:41],1,sum) #2014 summer
rin_data2$r2 <- apply(rin_data2[42:45],1,sum)
rin_data2$a2 <- apply(rin_data2[46:47],1,sum)
rin_data2$w2 <- apply(rin_data2[48:50],1,sum) #2015 winter
rin_data2$s3 <- apply(rin_data2[87:89],1,sum) #2018 summer
rin_data2$r3 <- apply(rin_data2[90:93],1,sum)
rin_data2$a3 <- apply(rin_data2[94:95],1,sum)
rin_data2$w3 <- apply(rin_data2[96:98],1,sum) #2019 winter

rin_data_sta2 <- subset(rin_data2,select=c(1,2,99:110))

###convert into csv

head(rin_data_sta1)
write.csv(rin_data_sta1, file.choose())

head(rin_data_sta2)
write.csv(rin_data_sta2, file.choose())

#extract temperature data
setwd("C:/Users/user/Documents/Masterthesis/climatebang/")
ncpath <- "C:/Users/user/Documents/Masterthesis/climatebang/"
ncname_t <- "temp"
ncfname_t <- paste(ncpath, ncname_t, ".nc", sep = "")
dname <- "tmean" #note: tmp means temperature

ncin_t <- nc_open(ncfname_t)
print(ncin_t)


#get coordinate variables (lon, lat, time)
lat_t <- ncvar_get(ncin_t, "Y")
nlat_t<-dim(lat_t)
lon_t <- ncvar_get(ncin_t, "X")
nlon_t <- dim(lon_t)
print(c(nlon_t,nlat_t))

time_t <- ncvar_get(ncin_t, "T")
tunits <- ncatt_get(ncin_t, "T", "units")
nt <-dim(time_t)
nt
tunits

#get temperature
tmp_array <- ncvar_get(ncin_t, dname)
dlname <- ncatt_get(ncin_t, dname, "long_name")
dunits<- ncatt_get(ncin_t, dname, "units")
fillvalue <- ncatt_get(ncin_t, dname, "_FillValue")
dim(tmp_array)
title <- ncatt_get(ncin_t,0,"title")
institution <- ncatt_get(ncin_t,0,"institution")
datasource <-ncatt_get(ncin_t, 0, "source")
references <- ncatt_get(ncin_t, 0, "reference")
history <- ncatt_get(ncin_t, 0, "history")
Conventions <- ncatt_get(ncin_t,0,"Conventions")
nc_close(ncin_t) #close netCDF
ls()
#Reshaping from raster to rectangular
library(chron)
library(lattice)
library(RColorBrewer)
tustr <- strsplit(tunits$value, " ")
tdstr <- strsplit(unlist(tustr)[3], "-")
tmonth <- as.integer(unlist(tdstr)[2])
tday <- as.integer(unlist(tdstr)[3])
tyear <- as.integer(unlist(tdstr)[1])
chron(time_t,origin=c(tmonth, tday, tyear))

#replace netCDF fill values with NA's
#tmp_array[tmp_array==fillvalue$value] <- NA
#length(na.omit(as.vector(tmp_array[,,1])))

#get a single time slice of the data, create R data frame and write a csv file
m <-300
tmp_slice <- tmp_array[,,m]
image(lon_t,lat_t,tmp_slice,col=rev(brewer.pal(10,"RdBu")))
grid <- expand.grid(lon=lon_t, lat=lat_t)
cutpts <- c(-5,0,5,10,15,20,25,30,35,40,45)
levelplot(tmp_slice ~ lon * lat, data=grid, at=cutpts, cuts=11, pretty=T, 
          col.regions=(rev(brewer.pal(10,"RdBu"))))

#create data frame
lonlat_t <-as.matrix(expand.grid(lon_t,lat_t))
dim(lonlat_t)
tmp_vec <- as.vector(tmp_slice)
length(tmp_vec)
tmp_df01 <- data.frame(cbind(lonlat_t,tmp_vec))
names(tmp_df01)<- c("lon", "lat", paste(dname, as.character(m), sep = "_"))


#set path and filename
csvpath <- "C:/Users/mm_wi/Documents/Masterthesis/climatebang/"
csvname <- "tmp_1.csv"
csvfile <- paste(csvpath, csvname, sep = "")
#write.table(na.omit(tmp_df01), csvfile, row.names = FALSE,sep = ",")

#reshape the array into vector for whole time
tmp_vec_long <- as.vector(tmp_array)
length(tmp_vec_long)

tmp_mat <- matrix(tmp_vec_long, nrow=nlon_t*nlat_t, ncol = nt)
dim(tmp_mat)
#head(na.omit(tmp_mat))
lonlat_t <- as.matrix(expand.grid(lon_t,lat_t))
tmp_df02 <- data.frame(cbind(lonlat_t),tmp_mat)
names(tmp_df02) <- c("lon", "lat")


#dry and wet
tmp_data1 <- tmp_df02[c(1,2,324:444)] #2007 Nov-2017 Oct monthly data 
tmp_data1$dry11 <- apply(tmp_data1[3:6],1,mean) # first wave
tmp_data1$wet11 <- apply(tmp_data1[7:14],1,mean) 
tmp_data1$dry12 <- apply(tmp_data1[15:18],1,mean) 
tmp_data1$wet12 <- apply(tmp_data1[19:26],1,mean)
tmp_data1$dry13 <- apply(tmp_data1[27:30],1,mean)
tmp_data1$wet13 <- apply(tmp_data1[31:38],1,mean) 
tmp_data1$dry21 <- apply(tmp_data1[51:54],1,mean) #second wave
tmp_data1$wet21 <- apply(tmp_data1[55:62],1,mean) 
tmp_data1$dry22 <- apply(tmp_data1[63:66],1,mean) 
tmp_data1$wet22 <- apply(tmp_data1[67:74],1,mean)
tmp_data1$dry23 <- apply(tmp_data1[75:78],1,mean)
tmp_data1$wet23 <- apply(tmp_data1[79:86],1,mean)
tmp_data1$dry31 <- apply(tmp_data1[87:90],1,mean)
tmp_data1$wet31 <- apply(tmp_data1[91:98],1,mean)
tmp_data1$dry32 <- apply(tmp_data1[99:102],1,mean)
tmp_data1$wet32 <- apply(tmp_data1[103:110],1,mean)
tmp_data1$dry33 <- apply(tmp_data1[111:114],1,mean)
tmp_data1$wet33 <- apply(tmp_data1[115:122],1,mean)
tmp_data_sta1 <- subset(tmp_data1,select=c(1,2,124:141))


#main
tmp_data2 <- tmp_df02[c(1,2,365:460)] #2011 March -2019 Feb
tmp_data2$s1 <- apply(tmp_data2[3:5],1,mean)#2011 summer
tmp_data2$r1 <- apply(tmp_data2[6:9],1,mean)
tmp_data2$a1 <- apply(tmp_data2[10:11],1,mean)
tmp_data2$w1 <- apply(tmp_data2[12:14],1,mean) #2012 winter
tmp_data2$s2 <- apply(tmp_data2[39:41],1,mean) #2014 summer
tmp_data2$r2 <- apply(tmp_data2[42:45],1,mean)
tmp_data2$a2 <- apply(tmp_data2[46:47],1,mean)
tmp_data2$w2 <- apply(tmp_data2[48:50],1,mean) #2015 winter
tmp_data2$s3 <- apply(tmp_data2[87:89],1,mean) #2018 summer
tmp_data2$r3 <- apply(tmp_data2[90:93],1,mean)
tmp_data2$a3 <- apply(tmp_data2[94:95],1,mean)
tmp_data2$w3 <- apply(tmp_data2[96:98],1,mean) #2019 winter
tmp_data_sta2 <- subset(tmp_data2,select=c(1,2,99:110))
###extract temperature data set and convert into csv
head(tmp_data_sta)
write.csv(tmp_data_sta, file.choose())
head(tmp_data_sta1)
write.csv(tmp_data_sta1, file.choose())
head(tmp_data_sta2)
write.csv(tmp_data_sta2, file.choose())




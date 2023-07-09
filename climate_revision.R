###data cleaning for climate variables
pacman::p_load('ncdf4','dplyr','matrixStats')
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

#20 years historical // Rabi: December-February, Kharif: March-November
rin_lonlat <- rin_df02[c(1:2)] #longitude and latitude
rin_hist1 <- rin_df02[c(122:361)]#1990 Dec-2011 Nov monthly data without lon and lat
rin_hist2 <- rin_df02[c(158:397)]#1993 Dec-2014 Nov
rin_hist3 <- rin_df02[c(206:445)]#1997 Dec-2018 Nov
hs1 <- rin_hist1[, c(FALSE, FALSE, FALSE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE)] # 20 years historical Kharif for 2011 March to November
hr1 <- rin_hist1[, c(TRUE, TRUE, TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)]  # 20 years historical Rabi for 2010 December to February 
sds1 <- rowSds(as.matrix(hs1), na.rm=TRUE)
sdr1 <- rowSds(as.matrix(hr1), na.rm=TRUE)
hs1 <- rowSums(hs1)/20
hr1 <- rowSums(hr1)/20


hs2 <- rin_hist2[, c(FALSE, FALSE, FALSE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE)] # 20 years historical Kharif for 2014 March to November
hr2 <- rin_hist2[, c(TRUE, TRUE, TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)]  # 20 years historical Rabi for 2013 December to 2014 February 
sds2 <- rowSds(as.matrix(hs2), na.rm=TRUE)
sdr2 <- rowSds(as.matrix(hr2), na.rm=TRUE)

hs2 <- rowSums(hs2)/20
hr2 <- rowSums(hr2)/20


hs3 <- rin_hist3[, c(FALSE, FALSE, FALSE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE)] # 20 years historical Kharif for 2018 March to November
hr3 <- rin_hist3[, c(TRUE, TRUE, TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)] # 20 years historical Rabi for 2017 December to 2018 February 
sds3 <- rowSds(as.matrix(hs3), na.rm=TRUE)
sdr3 <- rowSds(as.matrix(hr3), na.rm=TRUE)

hs3 <- rowSums(hs3)/20
hr3 <- rowSums(hr3)/20
rin_data_sta1 <- data.frame(rin_lonlat, hs1, hr1, sds1, sdr1, hs2, hr2, sds2, sdr2, hs3, hr3, sds3, sdr3)


### survey year rainfall
rin_data2 <- rin_df02[c(1,2,362:457)] #2010 Dec-2018 Nov
rin_data2$s1 <- apply(rin_data2[6:14],1,sum)  #2011 Kharif
rin_data2$r1 <- apply(rin_data2[3:5],1,sum) #2010/2011 Rabi
rin_data2$s2 <- apply(rin_data2[42:50],1,sum) #2014 Kharif
rin_data2$r2 <- apply(rin_data2[39:41],1,sum) #2013/2014Rabi
rin_data2$s3 <- apply(rin_data2[90:98],1,sum) #2018 Kharif
rin_data2$r3 <- apply(rin_data2[95:97],1,sum) #2017/2018Rabi

rin_data_sta2 <- subset(rin_data2,select=c(1,2,99:104))

### lagged year rainfall
rin_data3 <- rin_df02[c(1,2,350:445)] #2009 Dec-2017 Nov
rin_data3$ls1 <- apply(rin_data3[6:14],1,sum)  #2010 Kharif
rin_data3$lr1 <- apply(rin_data3[3:5],1,sum) #2009/2010 Rabi
rin_data3$ls2 <- apply(rin_data3[42:50],1,sum) #2013 Kharif
rin_data3$lr2 <- apply(rin_data3[39:41],1,sum) #2012/2013Rabi
rin_data3$ls3 <- apply(rin_data3[90:98],1,sum) #2017 Kharif
rin_data3$lr3 <- apply(rin_data3[95:97],1,sum) #2016/2017Rabi

rin_data_sta3 <- subset(rin_data3,select=c(1,2,99:104))

### 2-year lagged year rainfall
rin_data4 <- rin_df02[c(1,2,338:433)] #2009 March -2017 Feb
rin_data4$tls1 <- apply(rin_data4[6:14],1,sum)  #2009 Kharif
rin_data4$tlr1 <- apply(rin_data4[3:5],1,sum) #2008/2009 Rabi
rin_data4$tls2 <- apply(rin_data4[42:50],1,sum) #2012 Kharif
rin_data4$tlr2 <- apply(rin_data4[39:41],1,sum) #2011/2012Rabi
rin_data4$tls3 <- apply(rin_data4[90:98],1,sum) #2016 Kharif
rin_data4$tlr3 <- apply(rin_data4[95:97],1,sum) #2015/2016Rabi

rin_data_sta4 <- subset(rin_data4,select=c(1,2,99:104))

###convert into csv
head(rin_data_sta1)
write.csv(rin_data_sta1, file.choose())

head(rin_data_sta2)
write.csv(rin_data_sta2, file.choose())

head(rin_data_sta3)
write.csv(rin_data_sta3, file.choose())

head(rin_data_sta4)
write.csv(rin_data_sta4, file.choose())

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
names(tmp_df02) <- c("lon", "lat") #1981 Jan~


#historical temperature
#20 years historical // Rabi: December-February, Kharif: March-November
tmp_lonlat <- tmp_df02[c(1:2)] #longitude and latitude
tmp_hist1 <- tmp_df02[c(122:361)]#1990 Dec-2011 Nov monthly data without lon and lat
tmp_hist2 <- tmp_df02[c(158:397)]#1993 Dec-2014 Nov
tmp_hist3 <- tmp_df02[c(206:445)]#1997 Dec-2018 Nov
hst1 <- tmp_hist1[, c(FALSE, FALSE, FALSE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE)] # 20 years historical Kharif for 2011 March to November
hrt1 <- tmp_hist1[, c(TRUE, TRUE, TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)]  # 20 years historical Rabi for 2010 December to February 
sdst1 <- rowSds(as.matrix(hst1), na.rm=TRUE)
sdrt1 <- rowSds(as.matrix(hrt1), na.rm=TRUE)
hst1 <- rowMeans(hst1)
hrt1 <- rowMeans(hrt1)


hst2 <- tmp_hist2[, c(FALSE, FALSE, FALSE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE)] # 20 years historical Kharif for 2014 March to November
hrt2 <- tmp_hist2[, c(TRUE, TRUE, TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)]  # 20 years historical Rabi for 2013 December to 2014 February 
sdst2 <- rowSds(as.matrix(hst2), na.rm=TRUE)
sdrt2 <- rowSds(as.matrix(hrt2), na.rm=TRUE)

hst2 <- rowMeans(hst2)
hrt2 <- rowMeans(hrt2)


hst3 <- tmp_hist3[, c(FALSE, FALSE, FALSE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE)] # 20 years historical Kharif for 2018 March to November
hrt3 <- tmp_hist3[, c(TRUE, TRUE, TRUE, FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)] # 20 years historical Rabi for 2017 December to 2018 February 
sdst3 <- rowSds(as.matrix(hst3), na.rm=TRUE)
sdrt3 <- rowSds(as.matrix(hrt3), na.rm=TRUE)

hst3 <- rowMeans(hst3)
hrt3 <- rowMeans(hrt3)
tmp_data_sta1 <- data.frame(tmp_lonlat, hst1, hrt1, sdst1, sdrt1, hst2, hrt2, sdst2, 
                            sdrt2, hst3, hrt3, sdst3, sdrt3)


### survey year temperature
tmp_data2 <- tmp_df02[c(1,2,362:457)] #2010 Dec-2018 Nov
tmp_data2$ts1 <- apply(tmp_data2[6:14],1,mean)  #2011 Kharif
tmp_data2$tr1 <- apply(tmp_data2[3:5],1,mean) #2010/2011 Rabi
tmp_data2$ts2 <- apply(tmp_data2[42:50],1,mean) #2014 Kharif
tmp_data2$tr2 <- apply(tmp_data2[39:41],1,mean) #2013/2014Rabi
tmp_data2$ts3 <- apply(tmp_data2[90:98],1,mean) #2018 Kharif
tmp_data2$tr3 <- apply(tmp_data2[95:97],1,mean) #2017/2018Rabi

tmp_data_sta2 <- subset(tmp_data2,select=c(1,2,99:104))

### lagged year temperature
tmp_data3 <- tmp_df02[c(1,2,350:445)] #2009 Dec-2017 Nov
tmp_data3$lts1 <- apply(tmp_data3[6:14],1,mean)  #2010 Kharif
tmp_data3$ltr1 <- apply(tmp_data3[3:5],1,mean) #2009/2010 Rabi
tmp_data3$lts2 <- apply(tmp_data3[42:50],1,mean) #2013 Kharif
tmp_data3$ltr2 <- apply(tmp_data3[39:41],1,mean) #2012/2013Rabi
tmp_data3$lts3 <- apply(tmp_data3[90:98],1,mean) #2017 Kharif
tmp_data3$ltr3 <- apply(tmp_data3[95:97],1,mean) #2016/2017Rabi

tmp_data_sta3 <- subset(tmp_data3,select=c(1,2,99:104))

### 2-year lagged year temperature
tmp_data4 <- tmp_df02[c(1,2,338:433)] #2009 March -2017 Feb
tmp_data4$tlts1 <- apply(tmp_data4[6:14],1,mean)  #2009 Kharif
tmp_data4$tltr1 <- apply(tmp_data4[3:5],1,mean) #2008/2009 Rabi
tmp_data4$tlts2 <- apply(tmp_data4[42:50],1,mean) #2012 Kharif
tmp_data4$tltr2 <- apply(tmp_data4[39:41],1,mean) #2011/2012Rabi
tmp_data4$tlts3 <- apply(tmp_data4[90:98],1,mean) #2016 Kharif
tmp_data4$tltr3 <- apply(tmp_data4[95:97],1,mean) #2015/2016Rabi

tmp_data_sta4 <- subset(tmp_data4,select=c(1,2,99:104))
###convert into csv
head(tmp_data_sta1)
write.csv(tmp_data_sta1, file.choose())
head(tmp_data_sta2)
write.csv(tmp_data_sta2, file.choose())
head(tmp_data_sta3)
write.csv(tmp_data_sta3, file.choose())
head(tmp_data_sta4)
write.csv(tmp_data_sta4, file.choose())



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

#30 years historical
rin_lonlat <- rin_df02[c(1:2)] #longitude and latitude
rin_hist1 <- rin_df02[c(17:376)] #1982 March-2012 Feb monthly data without lon and lat
rin_hist2 <- rin_df02[c(47:412)]# 1985 March-2015 Feb
rin_hist3 <- rin_df02[c(95:460)]# 1989 March-2019 Feb
hs1 <- rin_hist1[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)] # 30 years historical summer for 2011
hr1 <- rin_hist1[, c(FALSE,FALSE,FALSE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE)]  # 30 years historical summer for 2011
ha1 <- rin_hist1[, c(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,FALSE,FALSE,FALSE)]  # 30 years historical summer for 2011
hw1 <- rin_hist1[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,TRUE)]  # 30 years historical summer for 2011
sds1 <- rowSds(as.matrix(hs1), na.rm=TRUE)
sdr1 <- rowSds(as.matrix(hr1), na.rm=TRUE)
sda1 <- rowSds(as.matrix(ha1), na.rm=TRUE)
sdw1 <- rowSds(as.matrix(hw1), na.rm=TRUE)
hs1 <- rowSums(hs1)/30
hr1 <- rowSums(hr1)/30
ha1 <- rowSums(ha1)/30
hw1 <- rowSums(hw1)/30

hs2 <- rin_hist2[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)] # 30 years historical summer for 2011
hr2 <- rin_hist2[, c(FALSE,FALSE,FALSE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE)]  # 30 years historical summer for 2011
ha2 <- rin_hist2[, c(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,FALSE,FALSE,FALSE)]  # 30 years historical summer for 2011
hw2 <- rin_hist2[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,TRUE)]  # 30 years historical summer for 2011
sds2 <- rowSds(as.matrix(hs2), na.rm=TRUE)
sdr2 <- rowSds(as.matrix(hr2), na.rm=TRUE)
sda2 <- rowSds(as.matrix(ha2), na.rm=TRUE)
sdw2 <- rowSds(as.matrix(hw2), na.rm=TRUE)
hs2 <- rowSums(hs2)/30
hr2 <- rowSums(hr2)/30
ha2 <- rowSums(ha2)/30
hw2 <- rowSums(hw2)/30
hs3 <- rin_hist3[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)] # 30 years historical summer for 2011
hr3 <- rin_hist3[, c(FALSE,FALSE,FALSE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE)]  # 30 years historical summer for 2011
ha3 <- rin_hist3[, c(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,FALSE,FALSE,FALSE)]  # 30 years historical summer for 2011
hw3 <- rin_hist3[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,TRUE)]  # 30 years historical summer for 2011
sds3 <- rowSds(as.matrix(hs3), na.rm=TRUE)
sdr3 <- rowSds(as.matrix(hr3), na.rm=TRUE)
sda3 <- rowSds(as.matrix(ha3), na.rm=TRUE)
sdw3 <- rowSds(as.matrix(hw3), na.rm=TRUE)
hs3 <- rowSums(hs3)/30
hr3 <- rowSums(hr3)/30
ha3 <- rowSums(ha3)/30
hw3 <- rowSums(hw3)/30
rin_data_sta1 <- data.frame(rin_lonlat, hs1, hr1, ha1, hw1, sds1, sdr1, sda1, sdw1, hs2, hr2, ha2, hw2, sds2, sdr2, sda2, sdw2, hs3, hr3, ha3, hw3, sds3, sdr3, sda3, sdw3)

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


#historical temperature
tmp_lonlat <- tmp_df02[c(1:2)] #longitude and latitude
tmp_hist1 <- tmp_df02[c(17:376)] #1982 March-2012 Feb monthly data without lon and lat
tmp_hist2 <- tmp_df02[c(47:412)]# 1985 March-2015 Feb
tmp_hist3 <- tmp_df02[c(95:460)]# 1989 March-2019 Feb
hst1 <- tmp_hist1[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)] # 30 years historical summer for 2011
hrt1 <- tmp_hist1[, c(FALSE,FALSE,FALSE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE)]  # 30 years historical summer for 2011
hat1 <- tmp_hist1[, c(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,FALSE,FALSE,FALSE)]  # 30 years historical summer for 2011
hwt1 <- tmp_hist1[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,TRUE)]  # 30 years historical summer for 2011
sdst1 <- rowSds(as.matrix(hst1), na.rm=TRUE)
sdrt1 <- rowSds(as.matrix(hrt1), na.rm=TRUE)
sdat1 <- rowSds(as.matrix(hat1), na.rm=TRUE)
sdwt1 <- rowSds(as.matrix(hwt1), na.rm=TRUE)
hst1 <- rowMeans(hst1)
hrt1 <- rowMeans(hrt1)
hat1 <- rowMeans(hat1)
hwt1 <- rowMeans(hwt1)

hst2 <- tmp_hist2[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)] # 30 years historical summer for 2011
hrt2 <- tmp_hist2[, c(FALSE,FALSE,FALSE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE)]  # 30 years historical summer for 2011
hat2 <- tmp_hist2[, c(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,FALSE,FALSE,FALSE)]  # 30 years historical summer for 2011
hwt2 <- tmp_hist2[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,TRUE)]  # 30 years historical summer for 2011
sdst2 <- rowSds(as.matrix(hst2), na.rm=TRUE)
sdrt2 <- rowSds(as.matrix(hrt2), na.rm=TRUE)
sdat2 <- rowSds(as.matrix(hat2), na.rm=TRUE)
sdwt2 <- rowSds(as.matrix(hwt2), na.rm=TRUE)
hst2 <- rowMeans(hst2)
hrt2 <- rowMeans(hrt2)
hat2 <- rowMeans(hat2)
hwt2 <- rowMeans(hwt2)
hst3 <- tmp_hist3[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)] # 30 years historical summer for 2011
hrt3 <- tmp_hist3[, c(FALSE,FALSE,FALSE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE)]  # 30 years historical summer for 2011
hat3 <- tmp_hist3[, c(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,FALSE,FALSE,FALSE)]  # 30 years historical summer for 2011
hwt3 <- tmp_hist3[, c(TRUE, TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,TRUE)]  # 30 years historical summer for 2011
sdst3 <- rowSds(as.matrix(hst3), na.rm=TRUE)
sdrt3 <- rowSds(as.matrix(hrt3), na.rm=TRUE)
sdat3 <- rowSds(as.matrix(hat3), na.rm=TRUE)
sdwt3 <- rowSds(as.matrix(hwt3), na.rm=TRUE)
hst3 <- rowMeans(hst3)
hrt3 <- rowMeans(hrt3)
hat3 <- rowMeans(hat3)
hwt3 <- rowMeans(hwt3)
tmp_data_sta1 <- data.frame(tmp_lonlat, hst1, hrt1, hat1, hwt1, sdst1, sdrt1, sdat1, sdwt1, hst2, hrt2, hat2, hwt2, sdst2, sdrt2, sdat2, sdwt2, hst3, hrt3, hat3, hwt3, sdst3, sdrt3, sdat3, sdwt3)



#main
tmp_data2 <- tmp_df02[c(1,2,365:460)] #2011 March -2019 Feb
tmp_data2$ts1 <- apply(tmp_data2[3:5],1,mean)#2011 summer
tmp_data2$tr1 <- apply(tmp_data2[6:9],1,mean)
tmp_data2$ta1 <- apply(tmp_data2[10:11],1,mean)
tmp_data2$tw1 <- apply(tmp_data2[12:14],1,mean) #2012 winter
tmp_data2$ts2 <- apply(tmp_data2[39:41],1,mean) #2014 summer
tmp_data2$tr2 <- apply(tmp_data2[42:45],1,mean)
tmp_data2$ta2 <- apply(tmp_data2[46:47],1,mean)
tmp_data2$tw2 <- apply(tmp_data2[48:50],1,mean) #2015 winter
tmp_data2$ts3 <- apply(tmp_data2[87:89],1,mean) #2018 summer
tmp_data2$tr3 <- apply(tmp_data2[90:93],1,mean)
tmp_data2$ta3 <- apply(tmp_data2[94:95],1,mean)
tmp_data2$tw3 <- apply(tmp_data2[96:98],1,mean) #2019 winter
tmp_data_sta2 <- subset(tmp_data2,select=c(1,2,99:110))
###extract temperature data set and convert into csv

head(tmp_data_sta1)
write.csv(tmp_data_sta1, file.choose())
head(tmp_data_sta2)
write.csv(tmp_data_sta2, file.choose())




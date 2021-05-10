###data cleaning for climate variables
library(ncdf4)

#extract rainfall data
ncpath <- "C:/Users/mm_wi/Documents/Masterthesis/climatebang/"
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
chron(time_t,origin=c(rmonth, rday, ryear))


#reshape the array into vector for whole time
rin_vec_long <- as.vector(rin_array)
length(rin_vec_long)

rin_mat <- matrix(rin_vec_long, nrow=nlon_r*nlat_r, ncol = nt_r)
dim(rin_mat)
#head(na.omit(tmp_mat))
lonlat_r <- as.matrix(expand.grid(lon_r,lat_r))
rin_df02 <- data.frame(cbind(lonlat_r),rin_mat)
names(rin_df02) <- c("lon", "lat")

rin_data <- rin_df02[c(1,2,339:458)] #2008-2017 monthly data
#get the year rain mean, sd
rin_data$sum11 <- apply(rin_data[3:14],1,sum) #2008
rin_data$sum12 <- apply(rin_data[15:26],1,sum) #2009
rin_data$sum13 <- apply(rin_data[27:38],1,sum) #2010
rin_data$sum21 <- apply(rin_data[51:62],1,sum) #2012
rin_data$sum22 <- apply(rin_data[63:74],1,sum) #2013
rin_data$sum23 <- apply(rin_data[75:86],1,sum) #2014
rin_data$sum31 <- apply(rin_data[87:98],1,sum) #2015
rin_data$sum32 <- apply(rin_data[99:110],1,sum) #2016
rin_data$sum33 <- apply(rin_data[111:122],1,sum) #2017
rin_data$mean1 <- apply(rin_data[138:140],1,mean) #2008-2010 mean
rin_data$mean2 <- apply(rin_data[141:143],1,mean) #2012-2014 mean
rin_data$mean3 <- apply(rin_data[144:146], 1, mean) #2015-2017 mean
rin_data$sd1 <-apply(rin_data[3:38],1,sd) #2008-2010 montly sd
rin_data$sd2 <-apply(rin_data[51:86],1,sd) #2012-2014 monthly sd
rin_data$sd3 <- apply(rin_data[87:122],1,sd) #2015-2017 monthly sd

rin_data_sta <- subset(rin_data,select=c(1,2,123:128))

###extract temperature data set and convert into csv
head(rin_data_sta)
write.csv(rin_data_sta, file.choose())

#extract temperature data
setwd("C:/Users/mm_wi/Documents/Masterthesis/climatebang/")
ncpath <- "C:/Users/mm_wi/Documents/Masterthesis/climatebang/"
ncname_t <- "temp"
ncfname_t <- paste(ncpath, ncname_t, ".nc", sep = "")
dname <- "tmean" #note: tmp means temperature

ncin_t <- nc_open(ncfname_t)
print(ncin_t)


#get coordinate variables (lon, lat, time)
lat_r <- ncvar_get(ncin_t, "Y")
nlat_r<-dim(lat_t)
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
grid <- expand.grid(lon=lon, lat=lat)
cutpts <- c(-5,0,5,10,15,20,25,30,35,40,45)
levelplot(tmp_slice ~ lon * lat, data=grid, at=cutpts, cuts=11, pretty=T, 
          col.regions=(rev(brewer.pal(10,"RdBu"))))

#create data frame
lonlat_t <-as.matrix(expand.grid(lon,lat))
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

tmp_data <- tmp_df02[c(1,2,339:458)] #2008-2017 monthly data

#get the annual mean
tmp_data$mean1 <- apply(tmp_data[3:38],1,mean) # mtwa
tmp_data$mean2 <- apply(tmp_data[51:86],1,mean) # mtco
tmp_data$mean3 <- apply(tmp_data[87:122],1,mean) # annual (i.e. row) means
tmp_data$sd1 <-apply(tmp_data[3:38],1,sd)
tmp_data$sd2 <-apply(tmp_data[51:86],1,sd)
tmp_data$sd3 <- apply(tmp_data[87:122],1,sd)
tmp_data_sta <- subset(tmp_data,select=c(1,2,123:128))
###extract temperature data set and convert into csv
head(tmp_data_sta)
write.csv(tmp_data_sta, file.choose())





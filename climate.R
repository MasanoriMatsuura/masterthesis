###data cleaning for climate variables
library(ncdf4)

#extract rainfall data
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

rin_data <- rin_df02[c(1,2,325:445)] #2007 Dec-2017 Nov monthly data 
#get the year rain summation, SD
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
rin_data$sd1 <-apply(rin_data[3:38],1,sd) #2008-2010 monthly sd
rin_data$sd2 <-apply(rin_data[51:86],1,sd) #2012-2014 monthly sd
rin_data$sd3 <- apply(rin_data[87:122],1,sd) #2015-2017 monthly sd

rin_data$w11 <- apply(rin_data[3:5],1,sum)#2008 winter December(2007) to February 2 
rin_data$s11 <- apply(rin_data[6:8],1,sum) #2008 summer march to may 2 
rin_data$r11 <- apply(rin_data[9:12],1,sum)#2008 rain June to September 3 
rin_data$a11 <- apply(rin_data[13:14],1,sum)#2008 autumn October to November 1  
rin_data$w12 <- apply(rin_data[15:17],1,sum) #2009
rin_data$s12 <- apply(rin_data[18:20],1,sum)
rin_data$r12 <- apply(rin_data[21:24],1,sum)
rin_data$a12 <- apply(rin_data[25:26],1,sum)
rin_data$w13 <- apply(rin_data[27:29],1,sum)  #2010
rin_data$s13 <- apply(rin_data[30:32],1,sum) 
rin_data$r13 <- apply(rin_data[33:36],1,sum) 
rin_data$a13 <- apply(rin_data[37:38],1,sum) 
rin_data$w21 <- apply(rin_data[50:52],1,sum) #2012
rin_data$s21 <- apply(rin_data[53:55],1,sum)
rin_data$r21 <- apply(rin_data[56:59],1,sum)
rin_data$a21 <- apply(rin_data[60:61],1,sum)
rin_data$w22 <- apply(rin_data[62:64],1,sum) #2013
rin_data$s22 <- apply(rin_data[65:67],1,sum)
rin_data$r22 <- apply(rin_data[68:71],1,sum)
rin_data$a22 <- apply(rin_data[72:74],1,sum)
rin_data$w23 <- apply(rin_data[75:77],1,sum) #2014
rin_data$s23 <- apply(rin_data[78:80],1,sum)
rin_data$r23 <- apply(rin_data[81:84],1,sum)
rin_data$a23 <- apply(rin_data[85:86],1,sum)
rin_data$w31 <- apply(rin_data[87:89],1,sum) #2015
rin_data$s31 <- apply(rin_data[90:92],1,sum)
rin_data$r31 <- apply(rin_data[93:96],1,sum)
rin_data$a31 <- apply(rin_data[97:98],1,sum) 
rin_data$w32 <- apply(rin_data[99:101],1,sum)  #2016
rin_data$s32 <- apply(rin_data[102:104],1,sum)
rin_data$r32 <- apply(rin_data[105:108],1,sum)
rin_data$a32 <- apply(rin_data[109:110],1,sum)
rin_data$w33 <- apply(rin_data[111:113],1,sum) #2017
rin_data$s33 <- apply(rin_data[114:116],1,sum)
rin_data$r33 <- apply(rin_data[117:120],1,sum)
rin_data$a33 <- apply(rin_data[121:122],1,sum)

rin_data_sta <- subset(rin_data,select=c(1,2,124:162))

#wet season and dry season
rin_data1 <- rin_df02[c(1,2,324:444)] #2007 Nov-2017 Oct monthly data 
rin_data1$dry11 <- apply(rin_data1[3:6],1,sum) # first wave
rin_data1$wet11 <- apply(rin_data1[7:14],1,sum) 
rin_data1$dry12 <- apply(rin_data1[15:18],1,sum) 
rin_data1$wet12 <- apply(rin_data1[19:26],1,sum)
rin_data1$dry13 <- apply(rin_data1[27:30],1,sum)
rin_data1$wet13 <- apply(rin_data1[31:38],1,sum) 
rin_data1$dry21 <- apply(rin_data1[51:54],1,sum) #second wave
rin_data1$wet21 <- apply(rin_data1[55:62],1,sum) 
rin_data1$dry22 <- apply(rin_data1[63:66],1,sum) 
rin_data1$wet22 <- apply(rin_data1[67:74],1,sum)
rin_data1$dry23 <- apply(rin_data1[75:78],1,sum)
rin_data1$wet23 <- apply(rin_data1[79:86],1,sum)
rin_data1$dry31 <- apply(rin_data1[87:90],1,sum)
rin_data1$wet31 <- apply(rin_data1[91:98],1,sum)
rin_data1$dry32 <- apply(rin_data1[99:102],1,sum)
rin_data1$wet32 <- apply(rin_data1[103:110],1,sum)
rin_data1$dry33 <- apply(rin_data1[111:114],1,sum)
rin_data1$wet33 <- apply(rin_data1[115:122],1,sum)
rin_data_sta1 <- subset(rin_data1,select=c(1,2,124:141))

###convert into csv
head(rin_data_sta)
write.csv(rin_data_sta, file.choose())

head(rin_data_sta1)
write.csv(rin_data_sta1, file.choose())

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

tmp_data <- tmp_df02[c(1,2,325:445)] #2007 Dec-2017 Dec monthly data

#get the annual mean
tmp_data$mean1 <- apply(tmp_data[3:38],1,mean) # monthly average
tmp_data$mean2 <- apply(tmp_data[51:86],1,mean) 
tmp_data$mean3 <- apply(tmp_data[87:122],1,mean) 
tmp_data$sd1 <-apply(tmp_data[3:38],1,sd)
tmp_data$sd2 <-apply(tmp_data[51:86],1,sd)
tmp_data$sd3 <- apply(tmp_data[87:122],1,sd)
tmp_data$w11 <- apply(tmp_data[3:5],1,mean)#2008 winter December(2007) to February 2 
tmp_data$s11 <- apply(tmp_data[6:8],1,mean) #2008 summer march to may 2 
tmp_data$r11 <- apply(tmp_data[9:12],1,mean)#2008 rain June to September 3 
tmp_data$a11 <- apply(tmp_data[13:14],1,mean)#2008 autumn October to November 1  
tmp_data$w12 <- apply(tmp_data[15:17],1,mean) #2009
tmp_data$s12 <- apply(tmp_data[18:20],1,mean)
tmp_data$r12 <- apply(tmp_data[21:24],1,mean)
tmp_data$a12 <- apply(tmp_data[25:26],1,mean)
tmp_data$w13 <- apply(tmp_data[27:29],1,mean)  #2010
tmp_data$s13 <- apply(tmp_data[30:32],1,mean) 
tmp_data$r13 <- apply(tmp_data[33:36],1,mean) 
tmp_data$a13 <- apply(tmp_data[37:38],1,mean) 
tmp_data$w21 <- apply(tmp_data[50:52],1,mean) #2012
tmp_data$s21 <- apply(tmp_data[53:55],1,mean)
tmp_data$r21 <- apply(tmp_data[56:59],1,mean)
tmp_data$a21 <- apply(tmp_data[60:61],1,mean)
tmp_data$w22 <- apply(tmp_data[62:64],1,mean) #2013
tmp_data$s22 <- apply(tmp_data[65:67],1,mean)
tmp_data$r22 <- apply(tmp_data[68:71],1,mean)
tmp_data$a22 <- apply(tmp_data[72:74],1,mean)
tmp_data$w23 <- apply(tmp_data[75:77],1,mean) #2014
tmp_data$s23 <- apply(tmp_data[78:80],1,mean)
tmp_data$r23 <- apply(tmp_data[81:84],1,mean)
tmp_data$a23 <- apply(tmp_data[85:86],1,mean)
tmp_data$w31 <- apply(tmp_data[87:89],1,mean) #2015
tmp_data$s31 <- apply(tmp_data[90:92],1,mean)
tmp_data$r31 <- apply(tmp_data[93:96],1,mean)
tmp_data$a31 <- apply(tmp_data[97:98],1,mean) 
tmp_data$w32 <- apply(tmp_data[99:101],1,mean)  #2016
tmp_data$s32 <- apply(tmp_data[102:104],1,mean)
tmp_data$r32 <- apply(tmp_data[105:108],1,mean)
tmp_data$a32 <- apply(tmp_data[109:110],1,mean)
tmp_data$w33 <- apply(tmp_data[111:113],1,mean) #2017
tmp_data$s33 <- apply(tmp_data[114:116],1,mean)
tmp_data$r33 <- apply(tmp_data[117:120],1,mean)
tmp_data$a33 <- apply(tmp_data[121:122],1,mean)

tmp_data_sta <- subset(tmp_data,select=c(1,2,124:162))

#dry and wet
tmp_data1 <- tmp_df02[c(1,2,324:444)] #2007 Nov-2017 Oct monthly data 
tmp_data1$dry11 <- apply(tmp_data1[3:6],1,sum) # first wave
tmp_data1$wet11 <- apply(tmp_data1[7:14],1,sum) 
tmp_data1$dry12 <- apply(tmp_data1[15:18],1,sum) 
tmp_data1$wet12 <- apply(tmp_data1[19:26],1,sum)
tmp_data1$dry13 <- apply(tmp_data1[27:30],1,sum)
tmp_data1$wet13 <- apply(tmp_data1[31:38],1,sum) 
tmp_data1$dry21 <- apply(tmp_data1[51:54],1,sum) #second wave
tmp_data1$wet21 <- apply(tmp_data1[55:62],1,sum) 
tmp_data1$dry22 <- apply(tmp_data1[63:66],1,sum) 
tmp_data1$wet22 <- apply(tmp_data1[67:74],1,sum)
tmp_data1$dry23 <- apply(tmp_data1[75:78],1,sum)
tmp_data1$wet23 <- apply(tmp_data1[79:86],1,sum)
tmp_data1$dry31 <- apply(tmp_data1[87:90],1,sum)
tmp_data1$wet31 <- apply(tmp_data1[91:98],1,sum)
tmp_data1$dry32 <- apply(tmp_data1[99:102],1,sum)
tmp_data1$wet32 <- apply(tmp_data1[103:110],1,sum)
tmp_data1$dry33 <- apply(tmp_data1[111:114],1,sum)
tmp_data1$wet33 <- apply(tmp_data1[115:122],1,sum)
tmp_data_sta1 <- subset(tmp_data1,select=c(1,2,124:141))

###extract temperature data set and convert into csv
head(tmp_data_sta)
write.csv(tmp_data_sta, file.choose())
head(tmp_data_sta1)
write.csv(tmp_data_sta1, file.choose())




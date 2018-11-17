## Process NWS soil temp data ##

### Download just the recent soil temp/moisture from US Climate Reference Network ###
library(RCurl)
library(RNetCDF)
library(ncdf)

Files<-dir(path="ftp://ftp.ncdc.noaa.gov/pub/data/uscrn/products/soilsip01/",pattern="CRNS",all.files=TRUE)
txt<-getURL("ftp://ftp.ncdc.noaa.gov/pub/data/uscrn/products/soilsip01/")
txt2<-unlist(strsplit(txt,"\r"))
txt3<-rep(NA,length(txt2))
for(i in 1:length(txt2)){
  temp<-txt2[i]
  if(grepl(":50",temp)) txt3[i]<-strsplit(temp,":50 ")[[1]][2] else 
    if(grepl(":51",temp)) txt3[i]<-strsplit(temp,":51 ")[[1]][2] else txt3[i]<-NA
}
txt3<-txt3[1:115]
write.csv(txt3,"F:/Observations/NWS/USCRN/FileNames.csv",row.names=FALSE)


ftp.root<-"ftp://ftp.ncdc.noaa.gov/pub/data/uscrn/products/soilsip01/"
dropbox.root<-"F:/Observations/NWS/USCRN"

outputs<-rep(NA,length(txt3))
for(filename in txt3){
  sourcefile<-paste(ftp.root,filename,sep="")
  targetfile<-paste(dropbox.root,filename,sep="")
  wget<-paste("wget",sourcefile,targetfile,sep=" ")
  system(wget)
}

## The SIP files do not have air temperature. Download the complete CRND files for the sites that were in the SIP files, 2010-2014
CRND2010<-sub("CRNSIP01_","CRND0103-2010-",txt3)
ftp.root<-"http://www1.ncdc.noaa.gov/pub/data/uscrn/products/daily01"
dropbox.root<-"F:/Observations/NWS/USCRN2"

for(year in 2010:2014){
  print(year)
  filenames<-sub("CRNSIP01_",paste("CRND0103-",year,"-",sep=""),txt3)
    
  for(filename in filenames){
    sourcefile<-paste(ftp.root,year,filename,sep="/")
    targetfile<-paste(dropbox.root,year,filename,sep="/")
    wget<-paste("wget -O",targetfile,"--no-check-certificate",sourcefile,sep=" ")
    system(wget)
  }
}

#########################################################
#  Import the weather station data, join all four years #
#########################################################
STA<-sub("CRNSIP01_","",txt3)
STA<-sub(".txt","",STA)
colNames<-read.csv("F:/Observations/NWS/USCRN2/HEADERS_colnames.csv")
colNames<-names(colNames)

all.Results<-as.data.frame(matrix(data=NA,nrow=length(STA),ncol=15,dimnames=list(STA,c("Site","Lat","Lon","Ta","Precip","Moist.10","Ts.5","Ts.100","Toff.5","Toff.100","Amp.air","Amp.5","Amp.100","Atten.5","Atten.100"))))

for(sta in STA[79:115]){
  print(sta)
  tmp.Results<-as.data.frame(matrix(data=NA,nrow=5,ncol=15,dimnames=list(2010:2014,c("Site","Lat","Lon","Ta","Precip","Moist.10","Ts.5","Ts.100","Toff.5","Toff.100","Amp.air","Amp.5","Amp.100","Atten.5","Atten.100"))))
  
  for(year in 2010:2014){
    
    tmp<-try(read.table(file=paste("F:/Observations/NWS/USCRN2/",year,"/CRND0103-",year,"-",sta,".txt",sep=""),header=FALSE,na.strings=c("-99","-9999.0","-99.0")),silent=TRUE)
  
    ## If file is empty, skip to next year
    if(class(tmp)=="try-error") {tmp.Results[as.character(year),1]<-sta
                                 tmp.Results[as.character(year),2:15]<-rep(NA,14)
                                 tmp<-c(as.numeric(paste(year,"0101",sep="")),rep(NA,12))
                                 assign(paste("tmp",year,sep=""),tmp)
                                 next()}
    
    colnames(tmp)<-colNames
    tmp[tmp== -99]<-NA
    tmp.Results[year-2009,"Site"]<-sta
    tmp.Results[year-2009,"Lon"]<-as.numeric(tmp[1,"LONGITUDE"])
    tmp.Results[year-2009,"Lat"]<-as.numeric(tmp[1,"LATITUDE"])
    
    tmp<-tmp[,c(2,9,10,15,20,24:28)]
    tmp$YEAR<-substr(tmp$LST_DATE,1,4)
    tmp$MONTH<-substr(tmp$LST_DATE,5,6)
    tmp$DAY<-substr(tmp$LST_DATE,7,8)
    assign(paste("tmp",year,sep=""),tmp)
    
    ## Count the percent observations. Only calculate results if N>85% ##
    tmp.N<-apply(tmp,2,function(x) round(length(which(!is.na(x)))/365,2))
    
    if(tmp.N[2]>0.85) {
      tmp.Results[year-2009,"Ta"]<-mean(tmp[,2],na.rm=TRUE) 
      tmp.Results[year-2009,"Amp.air"]<-max(tapply(tmp[,2],tmp$MONTH,mean,na.rm=TRUE))-min(tapply(tmp[,2],tmp$MONTH,mean,na.rm=TRUE))} else {
        tmp.Results[year-2009,"Ta"]<-NA
        tmp.Results[year-2009,"Amp.air"]<-NA }
    
    if(tmp.N[3]>0.85) tmp.Results[year-2009,"Precip"]<-sum(tmp[,3],na.rm=TRUE) else tmp.Results[year-2009,"Precip"]<-NA
    
    if(tmp.N[5]>0.85) tmp.Results[year-2009,"Moist.10"]<-mean(tmp[,5],na.rm=TRUE) else tmp.Results[year-2009,"Moist.10"]<-NA
   
    if(tmp.N[6]>0.85) {
      tmp.Results[year-2009,"Ts.5"]<-mean(tmp[,6],na.rm=TRUE) 
      tmp.Results[year-2009,"Amp.5"]<-max(tapply(tmp[,6],tmp$MONTH,mean,na.rm=TRUE))-min(tapply(tmp[,6],tmp$MONTH,mean,na.rm=TRUE))
      } else {
        tmp.Results[year-2009,"Ts.5"]<-NA
        tmp.Results[year-2009,"Amp.5"]<-NA
        }
    
    if(tmp.N[10]>0.85) {
      tmp.Results[year-2009,"Ts.100"]<-mean(tmp[,10],na.rm=TRUE) 
      tmp.Results[year-2009,"Amp.100"]<-max(tapply(tmp[,10],tmp$MONTH,mean,na.rm=TRUE))-min(tapply(tmp[,10],tmp$MONTH,mean,na.rm=TRUE))
      } else {
        tmp.Results[year-2009,"Ts.100"]<-NA
        tmp.Results[year-2009,"Amp.100"]<-NA
      }
  
    tmp.Results[year-2009,"Toff.5"]<-tmp.Results[year-2009,"Ts.5"]- tmp.Results[year-2009,"Ta"]
    tmp.Results[year-2009,"Atten.5"]<-tmp.Results[year-2009,"Amp.5"]/tmp.Results[year-2009,"Amp.air"]
    tmp.Results[year-2009,"Toff.100"]<-tmp.Results[year-2009,"Ts.100"]-tmp.Results[year-2009,"Ta"]
    tmp.Results[year-2009,"Atten.100"]<-tmp.Results[year-2009,"Amp.100"]/tmp.Results[year-2009,"Amp.5"]
    
}
  all.Results[sta,1]<-sta
  all.Results[sta,2:15]<-apply(tmp.Results[,2:15],2,mean,na.rm=TRUE)
  
  tmpALL<-rbind(tmp2010,tmp2011,tmp2012,tmp2013,tmp2014)
  write.csv(tmpALL,paste(dropbox.root,"/All/",sta,".csv",sep=""),row.names=FALSE)
}

write.csv(all.Results,paste(dropbox.root,"/All/","Results.csv",sep=""),row.names=FALSE)

names(all.Results)
par(mfrow=c(2,3),mar=c(4,4,1,1),mgp=c(2,0.5,0),tck=0.03)
plot(Toff.5~Ta,data=all.Results)
plot(Toff.5~Precip,data=all.Results,xlim=c(0,2000))
plot(Ta~Precip,data=all.Results,xlim=c(0,2000))

plot(Atten.5~Ta,data=all.Results)
plot(Atten.5~Precip,data=all.Results)
plot(Atten.100~Precip,data=all.Results,xlim=c(0,2000))
plot(Amp.5~Ta,data=all.Results)
plot(Atten.100~Ta,data=all.Results)
plot(Ta~Precip,data=all.Results,xlim=c(0,2000))
library(scatterplot3d)
scatterplot3d(all.Results$Ta,all.Results$Precip,all.Results$Toff.5)
library(rgl)
plot3d(all.Results$Ta,all.Results$Precip,all.Results$Toff.5)

##################################################
## Try to download older stations ##

rm(list=ls())

files <- list.files("data/raw")
header.widths<-c(4,3,8,4,2,4,2,4,3)
data.widths<-rep(c(2,2,1,5,1,1),31)

batch<-seq(25000,725000,25000)
SOlines<-NA
SXlines<-NA

for(i in batch[20:29]){
  `Test<-read.delim("F:/Observations/NWS/Loose/Alaska.txt",skip=batch[i],nrows=25000)
  SOlines.temp<-grep("SO",Test)
  SOlines<-c(SOlines,(SOlines.temp+batch[i]))
  SXlines.temp<-grep("SX",Test)
  SXlines<-c(SXlines,(SXlines.temp+batch[i]))
}
countLines("F:/Observations/NWS/Loose/Alaska.txt")
#725740

Alaska<-read.fwf("F:/Observations/NWS/Loose/Alaska.txt",widths=list(header.widths,data.widths),n=2,sep=" ")
colnames(Alaska)<-c("WH","RecType","ST ID","ElemType","UNIT","YR","MO","FILL","NUM VAL",rep(c("DY","HR","S","DATA"),31))
column.widths <- c(4, 6, 5, 4, 2, 2, 2, 2, 1, 6,
                   + 7, 5, 5, 5, 4, 3, 1, 1, 4, 1, 5, 1, 1, 1, 6,
                   + 1, 1, 1, 5, 1, 5, 1, 5, 1)
> stations <- as.data.frame(matrix(NA, length(files),
                                   + 6))
> names(stations) <- c("USAFID", "WBAN", "YR", "LAT",
                       + "LONG", "ELEV")
> for (i in 1:length(files)) {
  + data <- read.fwf(paste("data/raw/", files[i],
                           + sep = ""), column.widths)
  + data <- data[, c(2:8, 10:11, 13, 16, 19, 29,
                     + 31, 33)]
  + names(data) <- c("USAFID", "WBAN", "YR", "M",
                     + "D", "HR", "MIN", "LAT", "LONG", "ELEV",
                     + "WIND.DIR", "WIND.SPD", "TEMP", "DEW.POINT",
                     + "ATM.PRES")
  + data$LAT <- data$LAT/1000
  + data$LONG <- data$LONG/1000
  + data$WIND.SPD <- data$WIND.SPD/10
  + data$TEMP <- data$TEMP/10
  + data$DEW.POINT <- data$DEW.POINT/10
  + data$ATM.PRES <- data$ATM.PRES/10
  + write.csv(data, file = paste("data/csv/", files[i],
                                 + ".csv", sep = ""), row.names = FALSE)
  + stations[i, 1:3] <- data[1, 1:3]
  + stations[i, 4:6] <- data[1, 8:10]
  + }
> write.csv(stations, file = "data/stations.csv", row.names = FALSE)

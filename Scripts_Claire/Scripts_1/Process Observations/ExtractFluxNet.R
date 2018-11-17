## Extract data from Euroflux ##
rm(list=ls())
Directory<-"F:/Observations/Euroflux/Loose"
Files<-list.files(Directory)
Files<-Files[grep("EFDC",Files,ignore.case=TRUE)]
Files

SiteYr<-sub("EFDC_L2_Flx_","",Files)
SiteYr<-strsplit(SiteYr,"_")
Site<-sapply(SiteYr,as.character)[1,]

Site.splt<-paste(substr(Site,1,2),substr(Site,3,5),sep="-")
Yr<-sapply(SiteYr,as.numeric)[2,]
SiteYr<-paste(Site,Yr,sep=".")
Site.unq<-unique(Site)

# For each unique site
# Read in all the files with that site name
# Get mean and amp of TA,TS1,TS2, TS3
# Get % of observations
# Append to a list
# Summarize list by site
remove_outliers <- function(x, na.rm = TRUE, ...) {
  qnt <- quantile(x, probs=c(.25, .75), na.rm = na.rm, ...)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
}
ColNames<-c("ISODate","DTime","Ta_1","Ts_1","Ts_2","Ts_3")
Results<-data.frame(Site=c(NA),Ta.mean=c(NA),Ta.min=c(NA),Ta.max=c(NA),Ta.amp=c(NA),Ts_1.mean=c(NA),Ts_1.min=c(NA),Ts_1.max=c(NA),Ts_1.amp=c(NA),Ts_2.mean=c(NA),Ts_2.min=c(NA),Ts_2.max=c(NA),Ts_2.amp=c(NA),Ts_3.mean=c(NA),Ts_3.min=c(NA),Ts_3.max=c(NA),Ts_3.amp=c(NA), Ts_1.offset=c(NA),Ts_2.offset=c(NA),Ts_3.offset=c(NA), Ts_1.atten=c(NA),Ts_2.atten=c(NA),Ts_3.atten=c(NA))

ShortTable<-data.frame(ISODate=c(NA),DTime=c(NA),Ta_1=c(NA),Ts_1=c(NA),Ts_2=c(NA),Ts_3=c(NA))

for(i in 44: length(Site.unq)){
  FileNum<-which(Site==Site.unq[i])
  df.temp0<-read.table(paste(Directory,Files[FileNum[1]],sep="/"),sep=",",header=TRUE)
  colnames(df.temp0)<-ColNames[1:ncol(df.temp0)]
  if(ncol(df.temp0)<6){df.temp<-merge(ShortTable,df.temp0,all=TRUE);df.temp<-df.temp[-nrow(df.temp),]} else {df.temp<-df.temp0}
  
  if(length(FileNum)>1){
    for(j in 2:length(FileNum)){
    Files.temp0<-read.table(paste(Directory,Files[FileNum[j]],sep="/"),sep=",",header=TRUE)
    colnames(Files.temp0)<-ColNames[1:ncol(Files.temp0)]
    if(ncol(Files.temp0)<6){Files.temp<-merge(ShortTable,Files.temp0,all=TRUE);Files.temp<-Files.temp[-nrow(Files.temp),]} else {Files.temp<-Files.temp0}
    df.temp<-rbind(df.temp,Files.temp)
    }
  }
  dim(df.temp)
  df.temp$Year<-substr(df.temp$ISODate,1,4)
  df.temp$DOY<-floor(df.temp$DTime)
  df.temp[df.temp== -9999]<-NA
      
  Ta.N<-round(tapply(df.temp$Ta_1,df.temp$Year,function(x) length(which(!is.na(x))))/tapply(df.temp$Ta_1,df.temp$Year,length),4)
  tmp.Ta<-tapply(df.temp$Ta_1,INDEX=list(df.temp$Year,df.temp$DOY),mean,na.rm=TRUE)
  tmp.Ta[tmp.Ta=="NaN"]<-NA
  Ta.mean<-apply(tmp.Ta,1,mean,na.rm=TRUE)
  Ta.mean<-mean(remove_outliers(Ta.mean),na.rm=TRUE)
  Ta.min<-apply(tmp.Ta,1,min,na.rm=TRUE)
    Ta.min<-mean(remove_outliers(Ta.min),na.rm=TRUE)
  Ta.max<-apply(tapply(df.temp$Ta_1,INDEX=list(df.temp$Year,df.temp$DOY),mean,na.rm=TRUE),1,max,na.rm=TRUE)
    Ta.max<-mean(remove_outliers(Ta.max),na.rm=TRUE)
  Ta.amp<-Ta.max-Ta.min
  Ta.mean;Ta.min;Ta.max;Ta.amp
  
  Ts_1.mean<-apply(tapply(df.temp$Ts_1,INDEX=list(df.temp$Year,df.temp$DOY),mean,na.rm=TRUE),1,mean,na.rm=TRUE)
  Ts_1.mean<-mean(remove_outliers(Ts_1.mean),na.rm=TRUE)
  Ts_1.min<-apply(tapply(df.temp$Ts_1,INDEX=list(df.temp$Year,df.temp$DOY),mean,na.rm=TRUE),1,min,na.rm=TRUE)
  Ts_1.min<-mean(remove_outliers(Ts_1.min),na.rm=TRUE)
  Ts_1.max<-apply(tapply(df.temp$Ts_1,INDEX=list(df.temp$Year,df.temp$DOY),mean,na.rm=TRUE),1,max,na.rm=TRUE)
  Ts_1.max<-mean(remove_outliers(Ts_1.max),na.rm=TRUE)
  Ts_1.amp<-Ts_1.max-Ts_1.min
  Ts_1.mean;Ts_1.min;Ts_1.max;Ts_1.amp
  
  Ts_2.mean<-apply(tapply(df.temp$Ts_2,INDEX=list(df.temp$Year,df.temp$DOY),mean,na.rm=TRUE),1,mean,na.rm=TRUE)
  Ts_2.mean<-mean(remove_outliers(Ts_2.mean),na.rm=TRUE)
  Ts_2.min<-apply(tapply(df.temp$Ts_2,INDEX=list(df.temp$Year,df.temp$DOY),mean,na.rm=TRUE),1,min,na.rm=TRUE)
  Ts_2.min<-mean(remove_outliers(Ts_2.min),na.rm=TRUE)
  Ts_2.max<-apply(tapply(df.temp$Ts_2,INDEX=list(df.temp$Year,df.temp$DOY),mean,na.rm=TRUE),1,max,na.rm=TRUE)
  Ts_2.max<-mean(remove_outliers(Ts_2.max),na.rm=TRUE)
  Ts_2.amp<-Ts_2.max-Ts_2.min
  Ts_2.mean;Ts_2.min;Ts_2.max;Ts_2.amp

  Ts_3.mean<-apply(tapply(df.temp$Ts_3,INDEX=list(df.temp$Year,df.temp$DOY),mean,na.rm=TRUE),1,mean,na.rm=TRUE)
  Ts_3.mean<-mean(remove_outliers(Ts_3.mean),na.rm=TRUE)
  Ts_3.min<-apply(tapply(df.temp$Ts_3,INDEX=list(df.temp$Year,df.temp$DOY),mean,na.rm=TRUE),1,min,na.rm=TRUE)
  Ts_3.min<-mean(remove_outliers(Ts_3.min),na.rm=TRUE)
  Ts_3.max<-apply(tapply(df.temp$Ts_3,INDEX=list(df.temp$Year,df.temp$DOY),mean,na.rm=TRUE),1,max,na.rm=TRUE)
  Ts_3.max<-mean(remove_outliers(Ts_3.max),na.rm=TRUE)
  Ts_3.amp<-Ts_3.max-Ts_3.min
  Ts_3.mean;Ts_3.min;Ts_3.max;Ts_3.amp
  
Results[i,"Site"]<-Site.unq[i]
Results[i,"Ta.mean"]<-Ta.mean
Results[i,"Ta.min"]<-Ta.min
Results[i,"Ta.max"]<-Ta.max
Results[i,"Ta.amp"]<-Ta.amp
Results[i,"Ts_1.mean"]<-Ts_1.mean
Results[i,"Ts_1.min"]<-Ts_1.min
Results[i,"Ts_1.max"]<-Ts_1.max
Results[i,"Ts_1.amp"]<-Ts_1.amp
Results[i,"Ts_2.mean"]<-Ts_1.mean
Results[i,"Ts_2.min"]<-Ts_2.min
Results[i,"Ts_2.max"]<-Ts_2.max
Results[i,"Ts_2.amp"]<-Ts_2.amp
Results[i,"Ts_3.mean"]<-Ts_1.mean
Results[i,"Ts_3.min"]<-Ts_3.min
Results[i,"Ts_3.max"]<-Ts_3.max
Results[i,"Ts_3.amp"]<-Ts_3.amp
Results[i,"Ts_1.offset"]<-Ts_1.mean-Ta.mean
Results[i,"Ts_2.offset"]<-Ts_2.mean-Ta.mean
Results[i,"Ts_3.offset"]<-Ts_3.mean-Ta.mean
Results[i,"Ts_1.atten"]<-(Ts_1.max-Ts_1.min)/(Ta.max-Ta.min)
Results[i,"Ts_2.atten"]<-(Ts_2.max-Ts_2.min)/(Ta.max-Ta.min)
Results[i,"Ts_3.atten"]<-(Ts_3.max-Ts_3.min)/(Ta.max-Ta.min)
}
  
write.csv(Results,paste(Directory,"EurofluxSummary2.csv"),row.names=FALSE)
# Import SD-DEM
SDDEM<-read.csv("F:/Observations/Euroflux/SD-DEM_Temperature.csv")
dim(SDDEM); names(SDDEM)
TA.mean<-mean(apply(tapply(SDDEM$TA,INDEX=list(SDDEM$Year,SDDEM$Julian.Day),mean,na.rm=TRUE),1,mean,na.rm=TRUE))
TA.min<-mean(apply(tapply(SDDEM$TA,INDEX=list(SDDEM$Year,SDDEM$Julian.Day),mean,na.rm=TRUE),1,min,na.rm=TRUE))
TA.max<-mean(apply(tapply(SDDEM$TA,INDEX=list(SDDEM$Year,SDDEM$Julian.Day),mean,na.rm=TRUE),1,max,na.rm=TRUE))
TA.amp<-TA.max-TA.min
TA.mean;TA.min;TA.max;TA.amp

TS.3.Grass.mean<-mean(apply(tapply(SDDEM$TS.3.Grass,INDEX=list(SDDEM$Year,SDDEM$Julian.Day),mean,na.rm=TRUE),1,mean,na.rm=TRUE))
TS.3.Grass.min<-mean(apply(tapply(SDDEM$TS.3.Grass,INDEX=list(SDDEM$Year,SDDEM$Julian.Day),mean,na.rm=TRUE),1,min,na.rm=TRUE))
TS.3.Grass.max<-mean(apply(tapply(SDDEM$TS.3.Grass,INDEX=list(SDDEM$Year,SDDEM$Julian.Day),mean,na.rm=TRUE),1,max,na.rm=TRUE))
TS.3.Grass.amp<-TS.3.Grass.max-TS.3.Grass.min
TS.3.Grass.mean;TS.3.Grass.min;TS.3.Grass.max;TS.3.Grass.amp

TS.30.mean<-mean(apply(tapply(SDDEM$TS.30,INDEX=list(SDDEM$Year,SDDEM$Julian.Day),mean,na.rm=TRUE),1,mean,na.rm=TRUE))
TS.30.min<-mean(apply(tapply(SDDEM$TS.30,INDEX=list(SDDEM$Year,SDDEM$Julian.Day),mean,na.rm=TRUE),1,min,na.rm=TRUE))
TS.30.max<-mean(apply(tapply(SDDEM$TS.30,INDEX=list(SDDEM$Year,SDDEM$Julian.Day),mean,na.rm=TRUE),1,max,na.rm=TRUE))
TS.30.amp<-TS.30.max-TS.30.min
TS.30.mean;TS.30.min;TS.30.max;TS.30.amp

TS.60.mean<-mean(apply(tapply(SDDEM$TS.60,INDEX=list(SDDEM$Year,SDDEM$Julian.Day),mean,na.rm=TRUE),1,mean,na.rm=TRUE))
TS.60.min<-mean(apply(tapply(SDDEM$TS.60,INDEX=list(SDDEM$Year,SDDEM$Julian.Day),mean,na.rm=TRUE),1,min,na.rm=TRUE))
TS.60.max<-mean(apply(tapply(SDDEM$TS.60,INDEX=list(SDDEM$Year,SDDEM$Julian.Day),mean,na.rm=TRUE),1,max,na.rm=TRUE))
TS.60.amp<-TS.60.max-TS.60.min
TS.60.mean;TS.60.min;TS.60.max;TS.60.amp

# Import ZA-Kru/
ZAKRU<-read.table("F:/Observations/Euroflux/Loose/EFDC_L2_Flx_ZAKru_2001_v06_30m.txt",sep=",",header=TRUE)
dim(ZAKRU);names(ZAKRU)
ZAKRU$DOY<-floor(ZAKRU$DTime)
ZAKRU[ZAKRU== -9999]<-NA

TA.mean<-mean(tapply(ZAKRU$Ta_1,ZAKRU$DOY,mean,na.rm=TRUE),na.rm=TRUE)
TA.min<-min(tapply(ZAKRU$Ta_1,ZAKRU$DOY,mean,na.rm=TRUE),na.rm=TRUE)
TA.max<-max(tapply(ZAKRU$Ta_1,ZAKRU$DOY,mean,na.rm=TRUE),na.rm=TRUE)
TA.amp<-TA.max-TA.min
TA.mean;TA.min;TA.max;TA.amp

Ts_1.mean<-mean(tapply(ZAKRU$Ts_1,ZAKRU$DOY,mean,na.rm=TRUE),na.rm=TRUE)
Ts_1.min<-min(tapply(ZAKRU$Ts_1,ZAKRU$DOY,mean,na.rm=TRUE),na.rm=TRUE)
Ts_1.max<-max(tapply(ZAKRU$Ts_1,ZAKRU$DOY,mean,na.rm=TRUE),na.rm=TRUE)
Ts_1.amp<-Ts_1.max-Ts_1.min
Ts_1.mean;Ts_1.min;Ts_1.max;Ts_1.amp

#US-IVO
USIVO<-read.csv("F:/Observations/AmeriFlux/US-Ivo.csv")
names(USIVO);dim(USIVO)
USIVO[USIVO== -9999]<-NA

TA.mean<-mean(apply(tapply(USIVO$TA,INDEX=list(USIVO$Year,USIVO$DOY),mean,na.rm=TRUE),1,mean,na.rm=TRUE))
TA.min<-mean(apply(tapply(USIVO$TA,INDEX=list(USIVO$Year,USIVO$DOY),mean,na.rm=TRUE),1,min,na.rm=TRUE))
TA.max<-mean(apply(tapply(USIVO$TA,INDEX=list(USIVO$Year,USIVO$DOY),mean,na.rm=TRUE),1,max,na.rm=TRUE))
TA.amp<-TA.max-TA.min
TA.mean;TA.min;TA.max;TA.amp

TS.1.mean<-mean(apply(tapply(USIVO$TS.1,INDEX=list(USIVO$Year,USIVO$DOY),mean,na.rm=TRUE),1,mean,na.rm=TRUE))
TS.1.min<-mean(apply(tapply(USIVO$TS.1,INDEX=list(USIVO$Year,USIVO$DOY),mean,na.rm=TRUE),1,min,na.rm=TRUE))
TS.1.max<-mean(apply(tapply(USIVO$TS.1,INDEX=list(USIVO$Year,USIVO$DOY),mean,na.rm=TRUE),1,max,na.rm=TRUE))
TS.1.amp<-TS.1.max-TS.1.min
TS.1.mean;TS.1.min;TS.1.max;TS.1.amp
## Import Charlie's files for Polar Russian weather station data ##

library(RNetCDF)
library(ncdf)
library(fields)

dir = "F:/Observations/Romanovsky/IPY_TSP_data_netcdf_withfigures/IPY_TSP_data_netcdf"
Files = read.csv("F:/Observations/Romanovsky/IPY_TSP_Filenames.csv")
dim(Files);names(Files)
Filename<-as.character(Files$Filename)

for(i in 1:length(Filename)){
  if(file.exists(paste(dir,Filename[i],sep="/"))){
    temp.nc<-open.nc(paste(dir,Filename[i],sep="/"))
    #print.nc(temp.nc)
    Files$SiteName[i]<-att.get.nc(temp.nc,"NC_GLOBAL","site_name")
    Files$Latitude[i]<-att.get.nc(temp.nc,"NC_GLOBAL","latitude")
    Files$Longitude[i]<-att.get.nc(temp.nc,"NC_GLOBAL","longitude")
    time.att<-att.get.nc(temp.nc,"time","units")
    Files$Year[i]<-substr(time.att,start=19,stop=22)
    
    time<-var.get.nc(temp.nc,"time")
    depths<-var.get.nc(temp.nc,"depth")
    Close5<-which(depths < 0.11 & depths >= 0)
    Close100<-which(depths >= 0.7 & depths < 2.1)
  
    Ts.df<-as.data.frame(matrix(data=var.get.nc(temp.nc,"soil_temp"),nrow=length(time),ncol=length(depths),dimnames=list(time,depths)))
    Ts.df$DoY<-var.get.nc(temp.nc,"DoY")
    Ts.df$month<-var.get.nc(temp.nc,"month")
    Ts.df$year<-var.get.nc(temp.nc,"year")
    
    Ta.inq<-tryCatch(var.inq.nc(temp.nc,"air_temp"),error=function(e) e)
    if(!inherits(Ta.inq, "error")){
      Ta.df<-data.frame(Ta=var.get.nc(temp.nc,"air_temp"),DoY=var.get.nc(temp.nc,"DoY"),month=var.get.nc(temp.nc,"month"),year=var.get.nc(temp.nc,"year"))
      Ta.monmean<-tapply(Ta.df$Ta,list(Ta.df$year,Ta.df$month),mean,na.rm=TRUE)
      Ta.Ymonmean<-apply(Ta.monmean,2,mean,na.rm=TRUE)
      Files[i,"mean_Air"]<-mean(Ta.Ymonmean)
      Files[i,"amp_Air"]<-max(Ta.Ymonmean)-min(Ta.Ymonmean)
    }
    
    Ts.soil<-data.frame(matrix(data=NA,ncol=2, nrow=length(depths),dimnames=list(depths,c("Mean","Amp"))))
  
    for(d in 1:length(depths)){
      d.monmean<-tapply(Ts.df[,d],list(Ts.df$year,Ts.df$month),mean,na.rm=TRUE)
      d.percobs<-tapply(Ts.df[,d],list(Ts.df$year,Ts.df$month),function(x) length(which(!is.na(x)))/length(x))
      d.monmean[d.percobs<0.85]<-NA
      d.Ymonmean<-apply(d.monmean,2,mean,na.rm=TRUE)
      Ts.soil[d,"Mean"]<-mean(d.Ymonmean)
      Ts.soil[d,"Amp"]<-max(d.Ymonmean)-min(d.Ymonmean)
    }
    Ts.soil$logAmp<-log(Ts.soil$Amp)
    
    #If there is at least one measurement depth between 1 and 10 cm, use for 5 cm. If there are 2 observations, average. If there are 3 or more, interpolate.
    
    if(length(Close5)>0 & length(Close5)<3){
      Files[i,"mean_5cm"]<-mean(unlist(Ts.soil[,"Mean"])[Close5],na.rm=TRUE)
      Files[i,"amp_5cm"]<-mean(unlist(Ts.soil[,"Amp"])[Close5],na.rm=TRUE)
    }
    if(length(Close5)>=3){
      Means.close5<-unlist(Ts.soil[,"Mean"])[Close5]
      if(length(which(!is.na(Means.close5)))>0){
        Coef.mean.close5<-coef(lm(Means.close5~depths[Close5]))
        Files[i,"mean_5cm"]<-Coef.mean.close5[1] + 0.05 * Coef.mean.close5[2]} else {
          Files[i,"mean_5cm"]<-NA
        }
      Amps.close5<-unlist(Ts.soil[,"logAmp"])[Close5]
      if(length(which(!is.na(Amps.close5)))>0) {
        Coef.amp.close5<-coef(lm(Amps.close5~depths[Close5]))
        Files[i,"amp_5cm"]<-exp(Coef.amp.close5[1] + 0.05 * Coef.amp.close5[2])} else {
          Files[i,"mean_5cm"]<-NA}
    }  
      
    #If observed depths go down to at least 70 cm and there were 3 or more depths between 70 and 200 c, extrapolate to 100 cm
    if(length(Close100)>0 & length(Close100)<3){
      Files[i,"mean_100cm"]<-mean(unlist(Ts.soil[,"Mean"])[Close100],na.rm=TRUE)
      Files[i,"amp_100cm"]<-mean(unlist(Ts.soil[,"Amp"])[Close100],na.rm=TRUE)
    } else 
    if(length(Close100)>=3){
      Means.close100<-unlist(Ts.soil[,"Mean"])[Close100]
      if(length(which(!is.na(Means.close100)))>0){
        Coef.mean.close100<-coef(lm(Means.close100~depths[Close100]))
        Files[i,"mean_100cm"]<-Coef.mean.close100[1] + 1 * Coef.mean.close100[2]} else{
          Files[i,"mean_100cm"]<-NA
        }
      Amps.close100<-unlist(Ts.soil[,"logAmp"])[Close100]
      if(length(which(!is.na(Amps.close100)))>0) {
        Coef.amp.close100<-coef(lm(Amps.close100~depths[Close100]))
        Files[i,"amp_100cm"]<-exp(Coef.amp.close100[1] + 1 * Coef.amp.close100[2])} else{
          Files[i,"amp_100cm"]<-NA
        }
    }   
    
    print(Files[i,])
    close.nc(temp.nc)
    
  } else next()
}


time<-var.get.nc(temp.nc,"time")
plot(time)
time.att<-att.get.nc(temp.nc,"time","units")
yr.start<-substr(time.att,start=19,stop=22)
DoY<-var.get.nc(temp.nc,"DoY")
plot(DoY)

write.csv(Files,"F:/Observations/Romanovsky/IPY_TSP_Summary.csv",row.names=FALSE)
Files<-read.csv("F:/Observations/Romanovsky/IPY_TSP_Summary.csv")

# Get air temp from closest gridcell in CRU timeseries #
library("Imap")

CRU.nc<-open.nc("F:/Observations/CRU tmp/cru_ts3.22.1901.1910.tmp.dat.nc")
#print.nc(CRU.nc)
CRU.tmp = var.get.nc(CRU.nc,"tmp")
#Use CDO get yearmin, yearmax of this
CRU.lat = var.get.nc(CRU.nc,"lat")
CRU.lon = var.get.nc(CRU.nc,"lon")
close.nc(CRU.nc)
CRU.df = data.frame(index = 720*360,lats=rep(CRU.lat,each=720), lons = rep(CRU.lon,360),lat.index=rep(1:360,each=720),lon.index=rep(1:720,360))
CRU.ts.mean.nc<-open.nc("F:/Observations/CRU tmp/cru_ts_mean.nc")
CRU.ts.mean<-var.get.nc(CRU.ts.mean.nc,"tmp")
CRU.ts.amp.nc<-open.nc("F:/Observations/CRU tmp/cru_ts_amplitude.nc")
CRU.ts.amp<-var.get.nc(CRU.ts.amp.nc,"tmp")

#Initialize empty columns to hold CRU results
Files$CRUmean_Air<-rep(NA,nrow(Files))
Files$CRUamp_air<-rep(NA,nrow(Files))
Files$CRUlatindex<-rep(NA,nrow(Files))
Files$CRUlonindex<-rep(NA,nrow(Files))
Files$CRUlat<-rep(NA,nrow(Files))
Files$CRUlon<-rep(NA,nrow(Files))

#Only botherwith sites that have data for 5 or 100cm
BotherWith<-unique(c(which(!is.na(Files$mean_5cm)),which(!is.na(Files$mean_100cm))))
for(sta in BotherWith){
  print(Files[sta,"SiteName"])
  CRU.df$dist<-gdist(Files$Longitude[sta],Files$Latitude[sta],CRU.df$lons,CRU.df$lats)
  closest<-CRU.df[CRU.df$dist==min(CRU.df$dist),]
  #If there are two cells that are equidistant, choose only the 1st one
  if(nrow(closest)>1) closest<-closest[1,]
  #YearRange<-Files[sta,"StartYr"]
  Files[sta,"CRUlatindex"]<-closest$lat.index
  Files[sta,"CRUlonindex"]<-closest$lon.index
  Files[sta,"CRUlat"]<-closest$lats
  Files[sta,"CRUlon"]<-closest$lons
  Files[sta,"CRUmean_air"]<-mean(CRU.ts.mean[closest$lon.index,closest$lat.index])
  Files[sta,"CRUamp_air"]<-mean(CRU.ts.amp[closest$lon.index,closest$lat.index])
}

#Add lat and lon to Files
Files$T100.T5.atten<-Files$amp_100cm / Files$amp_5cm
Files$T100.T5.offset<-Files$mean_100cm - Files$mean_5cm

AirforCalc.mean<-Files$mean_Air
AirforCalc.mean[is.na(AirforCalc.mean)]<-Files$mean_air[is.na(AirforCalc.mean)]
AirforCalc.amp<-Files$amp_Air
AirforCalc.amp[is.na(AirforCalc.amp)]<-Files$amp_air[is.na(AirforCalc.amp)]


Files$T5.Tair.offset<-Files$mean_5cm - AirforCalc.mean
Files$T5.Tair.atten<-Files$amp_5cm / AirforCalc.amp


write.csv(Files,"F:/Observations/Romanovsky/IPY_TSP_Summary.csv",row.names=FALSE)


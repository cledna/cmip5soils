## Translate Charlie's python script to R for reading in Russian weather station data ##

rm(list=ls())
library(sp)
library(rgdal)
library(maptools)
require(rgdal)
library(RNetCDF)
library(ncdf)
library(fields)
library(maps)
library(mapdata)
library(raster)
library(RColorBrewer)
my.palette<-rev(brewer.pal(11,"RdYlBu"))

# returns string w/o leading whitespace
trim.leading <- function (x)  sub("^\\s+", "", x)

# returns string w/o trailing whitespace
trim.trailing <- function (x) sub("\\s+$", "", x)

# returns string w/o leading or trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

datadir = "F:/Observations/HRST/hrst/hrst/historical_russian_soil_temp/"

stations.filename=paste(datadir,"station_list_reformatted.txt",sep="")
stations=read.csv(stations.filename,sep='\t')
dim(stations);names(stations)
head(stations)
#Note that all stations have 13 depths, and all tables are 1915-1990

nstations = nrow(stations)
lats = stations[,"Lat_deg"] + stations[,"Lat_min"]/60
lons = stations[,"Lon_deg"] + stations[,"Lon_min"]/60
elevs = stations[,"Elev_meters"]
IDs = sprintf("%03d",stations$Station_ID)
names = trim(as.character(stations$Station_Name))

tmd = "TMD2"
badno = "-999"
ndepth = 13
nmonth = 12
depth = c(2,5,10,15,20,40,60,80,120,160,200,240,320)

mean.5cm = rep(0,nstations)
amp.5cm = rep(0,nstations)
mean.0cm = rep(0,nstations)
amp.0cm = rep(0,nstations)
mean.100cm = rep(0,nstations)
amp.100cm = rep(0,nstations)
amp.levs = c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0)

# minobs = 5
minobs_regr = 4
markersize = 0.02

data_depthrange1 = rep(NA,nstations)
data_depthrange2 = rep(NA,nstations)
data_depthrange3 = rep(NA,nstations)

# Make an array to hold the summary data for all
HRST.summary<-data.frame(Station=rep(names,each=length(depth)),ID=rep(IDs,each=length(depth)),Depth=rep(depth,length(names)),StartYr=rep(NA,263*13),NYr=rep(NA,263*13),Tmin=rep(NA,263*13),Tmax=rep(NA,263*13),Tmean=rep(NA,263*13),Amp.mean=rep(NA,263*13),Amp.sd=rep(NA,263*13))

counter = 1 #counter marks row in HRST.summary


for(sta in 1:length(names)){
#try to open in "New Data" folder, if fail look in "Revised Data", if fail print "can't find" and go to next loop.
  filename = paste(datadir,tmd,"/New_Data/",tmd,".",IDs[sta],sep="")
  if(file.exists(filename)) data = read.table(filename,header=TRUE) else if(file.exists(paste(datadir,tmd,"/Revised_Data/",tmd,".",IDs[sta],sep=""))) {
    data = read.table(paste(datadir,tmd,"/Revised_Data/",tmd,".",IDs[sta],sep=""),header=TRUE)} else {
    print(paste("can't find ",IDs[sta]))
    data = NULL
    #HRST.summary[HRST.summary$Station==names[sta],4:10]<-NA
    counter = counter + 13
    next()
  }
   
  if(!is.null(data)){
    #Open a pdf for the station that will hold plots for all depths
    pdf(file=paste(datadir,"Plots/",tmd,".",IDs[sta],".pdf",sep=""),onefile=TRUE)
    data[data==badno]<-NA
    data<-data[with(data,order(Station,Year,Month)),] #SORT
    years = unique(data$Year)
    
    for(column in 1:ndepth){
      temp<-data[,(column + 3)]
      
      if(length(which(is.na(temp)))==911){
        print(paste("No data for",names[sta],depth[column],"cm",sep=" "))
        HRST.summary[counter,4:10]<-rep(NA,7)
        counter = counter + 1  
        next()
      }
      
      # Determine the % missing observations, and omit years with > 15% missing data
      temp.nobs<-round(tapply(temp,data$Year,function(x) length(which(!is.na(x)))) / tapply(temp,data$Year,length) ,2)
      temp.keepyears<-years[which(temp.nobs>0.85)]
      temp.NAyears<-years[which(temp.nobs<=0.85)]
      
      if(length(temp.NAyears)==length(years)){
        print(paste("No data for",names[sta],depth[column],"cm",sep=" "))
        HRST.summary[counter,4:10]<-rep(NA,7)
        counter = counter + 1  
        next()
      }
      
      # Calculate monthly means
      monmean<-tapply(temp,INDEX=list(data$Year,data$Month),mean,na.rm=TRUE)
      monmean[monmean=="NaN"]<-NA
      monmean[as.character(temp.NAyears),]<-NA
  
  #Make image plot for each depth
{
    par(mar=c(5,5,5,7))   
      image(monmean,axes=FALSE,col=my.palette,zlim=c(-30,25),main=paste(names[sta],depth[column],"cm",sep=" "))
      box(lwd=2)
      axis(side=1,at=seq(1,75,10)/75, labels=years[seq(1,75,10)])
      axis(side=2,at=seq(0,1,length.out=12), labels=month.abb)
      image.plot(monmean,zlim=c(-30,25),legend.only=TRUE,nlevel=11,col=my.palette)
    }
    
      # Get annual amplitude, averaged across keep years
      amplitude<-apply(monmean,1,max)-apply(monmean,1,min)
      amp.nyears<-length(na.omit(amplitude))
      amp.mean<-mean(amplitude,na.rm=TRUE)
      amp.sd<-sd(amplitude,na.rm=TRUE)
     
      # Get overall annual mean
      ann.mean<-mean(monmean,na.rm=TRUE)
      ann.min<-mean(apply(monmean,1,min),na.rm=TRUE)
      ann.max<-mean(apply(monmean,1,max),na.rm=TRUE)
  
      # Fill in summary table
     # HRST.summary[counter,"Station"]<-names[sta]
    #  HRST.summary[counter,"ID"]<-IDs[sta]
    #  HRST.summary[counter,"Depth"]<-depth[column]
      HRST.summary[counter,"StartYr"]<-min(temp.keepyears)
      HRST.summary[counter,"NYr"]<-length(temp.keepyears)
      HRST.summary[counter,"Tmean"]<-ann.mean
      HRST.summary[counter,"Tmin"]<-ann.min
      HRST.summary[counter,"Tmax"]<-ann.max
      HRST.summary[counter,"Amp.mean"]<-amp.mean
      HRST.summary[counter,"Amp.sd"]<-amp.sd
      counter = counter + 1
  }
  dev.off() #Close pdf file for the station
}

}
write.csv(HRST.summary,file=paste(datadir,"/",tmd,"/HRSTSummary.csv",sep=""),row.names=FALSE)
HRST.summary<-read.csv("F:/Observations/HRST/hrst/hrst/historical_russian_soil_temp/TMD2/HRSTSummary.csv")

## Interpolate to 0, 5, and 100 cm for mean and amp
HRST.plot<-data.frame(Stations=names,ID=IDs,StartYr=rep(NA,length(names)), mean_0cm=rep(NA,length(names)),mean_2cm=rep(NA,length(names)),mean_5cm=rep(NA,length(names)), mean_100cm=rep(NA,length(names)),amp_0cm=rep(NA,length(names)),amp_2cm=rep(NA,length(names)),amp_5cm=rep(NA,length(names)), amp_100cm=rep(NA,length(names)))

for(sta in 1:length(names)){
  temp<-HRST.summary[(HRST.summary$Station==names[sta])& (!is.na(HRST.summary$Tmean)),]
  HRST.plot[sta,"StartYr"]<-min(temp$StartYr,na.rm=TRUE)
  if(length(temp$Depth[temp$Depth<=120]) >= minobs_regr){
    Coef.Tmean<-coef(lm(Tmean~Depth,data=temp))
    HRST.plot[sta,"mean_0cm"]<-Coef.Tmean[1]
    HRST.plot[sta,"mean_5cm"]<-Coef.Tmean[1] + 5 * Coef.Tmean[2]
    HRST.plot[sta,"mean_100cm"]<-Coef.Tmean[1] + 100 * Coef.Tmean[2]
    
    temp$logAmp<-log(temp$Amp.mean)
    Coef.Tamp<-coef(lm(logAmp~Depth,data=temp))
    HRST.plot[sta,"amp_0cm"]<-exp(Coef.Tamp[1])
    HRST.plot[sta,"amp_5cm"]<-exp(Coef.Tamp[1] + 5 * Coef.Tmean[2])
    HRST.plot[sta,"amp_100cm"]<-exp(Coef.Tamp[1] + 100 * Coef.Tmean[2])
  }
    
if(length(temp$Depth[temp$Depth==2])!=0){
    HRST.plot[sta,"mean_2cm"]<-temp[temp$Depth==2,"Tmean"]
    HRST.plot[sta,"amp_2cm"]<-temp[temp$Depth==2,"Amp.mean"]
}
if(length(temp$Depth[temp$Depth==5])!=0){
    HRST.plot[sta,"mean_5cm"]<-temp[temp$Depth==5,"Tmean"]
    HRST.plot[sta,"amp_5cm"]<-temp[temp$Depth==5,"Amp.mean"]
  }
}

## Which stations have temps for 2, 5, 80 or 120 cm? ##
{
Stations.2cm<-HRST.summary[which(HRST.summary$Depth==2 & !is.na(HRST.summary$Tmean)),]
nrow(Stations.2cm)
#45

Stations.5cm<-HRST.summary[which(HRST.summary$Depth==5 & !is.na(HRST.summary$Tmean)),]
nrow(Stations.5cm)
#40

length(unique(c(Stations.5cm$ID,Stations.2cm$ID)))
#50

Stations.80cm<-HRST.summary[which(HRST.summary$Depth==80 & !is.na(HRST.summary$Tmean)),]
nrow(Stations.80cm)
#241

Stations.120cm<-HRST.summary[which(HRST.summary$Depth==120 & !is.na(HRST.summary$Tmean)),]
nrow(Stations.120cm)
#156
}

# Get air temp from closest gridcell in CRU timeseries #
install.packages("Imap")
library("Imap")

CRU.nc<-open.nc("F:/Observations/CRU tmp/cru_ts3.22.1901.1910.tmp.dat.nc")
#print.nc(CRU.nc)
CRU.tmp = var.get.nc(CRU.nc,"tmp")
#Use CDO get yearmin, yearmax of this
CRU.lat = var.get.nc(CRU.nc,"lat")
CRU.lon = var.get.nc(CRU.nc,"lon")
CRU.df = data.frame(index = 720*360,lats=rep(CRU.lat,each=720), lons = rep(CRU.lon,360),lat.index=rep(1:360,each=720),lon.index=rep(1:720,360))
CRU.ts.mean.nc<-open.nc("F:/Observations/CRU tmp/cru_ts_mean.nc")
CRU.ts.mean<-var.get.nc(CRU.ts.mean.nc,"tmp")
CRU.ts.amp.nc<-open.nc("F:/Observations/CRU tmp/cru_ts_amplitude.nc")
CRU.ts.amp<-var.get.nc(CRU.ts.amp.nc,"tmp")


# Get closest grid cell
# Get amp and mean for the same years as soil data
# Add result to HRST data
# names(HRST.plot)
# [1] "Stations"   "ID"         "mean_0cm"   "mean_2cm"  
# [5] "mean_5cm"   "mean_100cm" "amp_0cm"    "amp_2cm"   
# [9] "amp_5cm"    "amp_100cm" 

HRST.plot$mean_air<-rep(NA,nrow(HRST.plot))
HRST.plot$amp_air<-rep(NA,nrow(HRST.plot))
HRST.plot$CRUlatindex<-rep(NA,nrow(HRST.plot))
HRST.plot$CRUlonindex<-rep(NA,nrow(HRST.plot))

for(sta in 1:length(names)){
  print(sta)
  temp<-HRST.plot[sta,]
  CRU.df$dist<-gdist(lons[sta],lats[sta],CRU.df$lons,CRU.df$lats)
  closest<-CRU.df[CRU.df$dist==min(CRU.df$dist),]
  if(nrow(closest)>1) closest<-closest[1,]
  #YearRange<-HRST.plot[sta,"StartYr"]
  HRST.plot[sta,"CRUlatindex"]<-closest$lat.index
  HRST.plot[sta,"CRUlonindex"]<-closest$lon.index
  HRST.plot[sta,"CRUlat"]<-closest$lats
  HRST.plot[sta,"CRUlon"]<-closest$lons
  HRST.plot[sta,"mean_air"]<-mean(CRU.ts.mean[closest$lon.index,closest$lat.index])
  HRST.plot[sta,"amp_air"]<-mean(CRU.ts.amp[closest$lon.index,closest$lat.index])
}

#Add lat and lon to HRST.plot
HRST.plot$lat<-lats
HRST.plot$long<-lons
HRST.plot$T5.Tair.offset<-HRST.plot$mean_5cm - HRST.plot$mean_air
HRST.plot$T5.Tair.atten<-HRST.plot$amp_5cm / HRST.plot$amp_air
HRST.plot$T100.Tair.atten<-HRST.plot$amp_100cm / HRST.plot$amp_5cm

write.csv(HRST.plot,file=paste(datadir,"/",tmd,"/HRSTPlot_AllSites.csv",sep=""),row.names=FALSE)


#Plot the results
TempObs<-read.csv("F:/Observations/Observations_SoilTempMetrics.csv")
dim(TempObs);names(TempObs)
par(mfrow=c(3,1),mar=c(4,4,1,1))
plot(Toffset.5cm~TA.Mean,data=TempObs,ylim=c(-5,18),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2)
box(lwd=2)
abline(v=0, col="grey")
abline(h=0, col="grey")
axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6)
axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6)

mtext("Soil - Air Offset",side=2,line=2.5,cex=1.2,outer=FALSE)
mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.2, outer=FALSE)

plot(Tatten.5cm~TA.Mean,data=TempObs,ylim=c(0,2),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2)
box(lwd=2)
abline(v=0, col="grey")
abline(h=1, col="grey")
axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6)
axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6)

mtext("Soil/Air atten",side=2,line=2.5,cex=1.2,outer=FALSE)
mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.2, outer=FALSE)

plot(Tatten.100cm~TA.Mean,data=TempObs,ylim=c(0,2),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2)
box(lwd=2)
abline(v=0, col="grey")
abline(h=1, col="grey")
axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6)
axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6)

mtext("Deep/shallow atten",side=2,line=2.5,cex=1.2,outer=FALSE)
mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.2, outer=FALSE)

# Plot stations on a map
# Make a lon x lat grid with NAs where no data, and data
par(mfrow=c(1,1))
image.plot(CRU.ts.mean)
rast<-raster("F:/Observations/CRU tmp/cru_ts_mean.nc",varname="tmp",origin= -100) 
par(mar=rep(4.5,4))
plot(rast,col=colorRampPalette(c("blue","yellow","red"))(255),xaxt="n",yaxt="n")
land <- readShapeSpatial("C:/Users/Claire/Documents/R/win-library/3.0/ne_110m_land/ne_110m_land.shp")
plot(land,add=TRUE)
points(TempObs$Lon,TempObs$Lat,pch=16,cex=0.5)

# download.file("http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/physical/ne_110m_land.zip","land.zip")
# #Unzip it
# unzip("ne_110m_land.zip")
# #Load it
# land <- readShapeSpatial("C:/Users/Claire/Documents/R/win-library/3.0/ne_110m_land/ne_110m_land.shp")
# plot(land,add=TRUE)

rm(list=ls())
library(RNetCDF)
library(ncdf)
library(fields)
library(maps)
library(raster)
library(abind)

### COMPLETE THE FOLLOWING BEFORE RUNNING ###
MODEL.V=c("bcc-csm1-1","BNU-ESM","CanESM2", "CCSM4","CESM1-BGC","MPI-ESM-LR", "GFDL-ESM2G","GISS-E2-R","HadGEM2-ES","inmcm4","IPSL-CM5A-LR","MIROC5","MRI-CGCM3","NorESM1-M") 
#c("bcc-csm1-1","BNU-ESM","CanESM2", "CESM1-BGC","MPI-ESM-LR", "GFDL-ESM2G","HadGEM2-ES","inmcm4","IPSL-CM5A-LR","MIROC5","MRI-CGCM3","NorESM1-M")
XP.V=c("rcp45","rcp85")
REAL="r1i1p1"
#WD="G:/wd/RData" #"C:/Users/Claire/Documents/LBL/CMIP5/RData"

VAR.V=c("tas","tsl","mrlsl")
Objects=c("Annualts.arr","EOCmean.arr","LatZone.arr","LatZone.global.interp","ZoneMonthly.arr","AnomGlobalMap")

SOIL<-c("Rock","ShiftingSand","Gelisol","Histosol","Spodosol","Andisol","Oxisol","Vertisol","Aridisol","Ultisol","Mollisol","Alfisol","Inceptisol","Entisol")
#ZONE=c("GreatPlains","PampasPlain","EurasianSteppe","ChinaMoll")
ZONE=c("GreatPlains","PampasPlain","EurasianSteppe","ChinaMoll","AustraliaAridisol","EuropeAlfisol","CanadaGelisol","AmazonOxisol")

YEARS=2006:2100

# Outfiles
Annualts.ens<-array(data=NA,dim=c((length(SOIL)+length(ZONE)+1),8,length(YEARS),length(MODEL.V)),dimnames=list(c("Global",SOIL,ZONE),c("tas","tsl0.01","tsl1.0","mrlsl0.01","mrlsl0.1","soil.minus.air","SAWR0.01","SAWR1.0"),YEARS,MODEL.V))

EOC.ens<-array(data=NA,dim=c(length(SOIL)+length(ZONE)+1,8,length(MODEL.V)),dimnames=list(c("Global",SOIL,ZONE),c("tas","tsl0.01","tsl1.0","mrlsl0.01","mrlsl0.1","soil.minus.air","SAWR0.01","SAWR1.0"),MODEL.V))


#Hist.ens<-array(data=NA,dim=c(,5,length(MODEL.V)),dimnames=list(c("Global",SOIL,ZONE),c("tas","tsl0.01","tsl1.0","mrlsl0.01","tas.amp","tsl"),MODEL.V))

#Interpolated lat to regular 1 degree intervals for ensemble avg. Put only surificial layer in LatZone
LatZone.global.ens<-array(data=NA,dim=c(180,5,length(MODEL.V)),dimnames=list(seq(-90,90,length.out=180),c("tas","tsl0.01","tsl1.0","mrlsl0.01","mrlsl0.1"),MODEL.V))

# Monthly mean soil temp for historic and recent period
ZoneMonthly.ens<-array(data=NA,dim=c(length(ZONE),5,12,2,length(MODEL.V)),dimnames=list(ZONE,c("tas","tsl0.01","tsl1.0","mrlsl0.01","mrlsl0.1"),month.abb,c("1986-2005","2080-2100"),MODEL.V))

for (m in 1: length(XP.V)){ #Loop through experiments
  for (n in 1: length(MODEL.V)){ #Loop through models
    for (l in 1:length(VAR.V)){ #Loop through variables
      if(MODEL.V[n]=="CCSM4") REAL<-"r2i1p1" else REAL<-"r1i1p1"
      file.temp<-paste(MODEL.V[n],"_",XP.V[m],"_",REAL,"_",VAR.V[l],".RData",sep="")
      file<-paste(WD,"/",MODEL.V[n],"_",XP.V[m],"_",REAL,"_",VAR.V[l],".RData",sep="")
      if(file.temp %in% list.files(paste(WD,"/",sep=""))){load(file)}
    } #End variables loop
    
    if(MODEL.V[n]=="GISS-E2-R" & XP.V[m]=="rcp45") next() #Go to next model if EXP is missing (e.g. for GISS rcp 4.5)
    # FILL IN ENSEMBLE ARRAYS
    #EOC.ens
    {tas.temp<-get(paste(MODEL.V[n],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
    tsl.temp<-get(paste(MODEL.V[n],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
                  EOC.ens[,1,n]<-tas.temp
                  EOC.ens[,2:3,n]<-tsl.temp[,c("0.01m","1m")]
    if (exists(paste(MODEL.V[n],XP.V[m],REAL,"mrlsl","EOCmean.arr",sep="."))) {             
    mrlsl.temp<-get(paste(MODEL.V[n],XP.V[m],REAL,"mrlsl","EOCmean.arr",sep="."))
    EOC.ens[,4:5,n]<-mrlsl.temp[,c("0.01m","0.1m")]} else {
      EOC.ens[,4:5,n]<-rep(NA, 2*(length(SOIL)+length(ZONE)+1))
    }
    EOC.ens[,6,n]<-tsl.temp[,"0.01m"]-tas.temp
    EOC.ens[,7,n]<-tsl.temp[,"0.01m"]/tas.temp
    EOC.ens[,8,n]<-tsl.temp[,"1m"]/tas.temp
    }
    
    #FILL IN Annualts.ens
    {tas.temp<-get(paste(MODEL.V[n],XP.V[m],REAL,"tas","Annualts.arr",sep="."))
    tsl.temp<-get(paste(MODEL.V[n],XP.V[m],REAL,"tsl","Annualts.arr",sep="."))
    Annualts.ens[,1,,n]<-tas.temp
    Annualts.ens[,2:3,,n]<-tsl.temp[,c("0.01m","1m"),]
    if (exists(paste(MODEL.V[n],XP.V[m],REAL,"mrlsl","Annualts.arr",sep="."))) {             
      mrlsl.temp<-get(paste(MODEL.V[n],XP.V[m],REAL,"mrlsl","Annualts.arr",sep="."))
      Annualts.ens[,4:5,,n]<-mrlsl.temp[,c("0.01m","0.1m"),]} else {
        Annualts.ens[,4:5,,n]<-rep(NA, 2*length(YEARS)*(length(SOIL)+length(ZONE)+1))
      }
    Annualts.ens[,6,,n]<-tsl.temp[,"0.01m",]-tas.temp
    Annualts.ens[,7,,n]<-tsl.temp[,"0.01m",]/tas.temp
    Annualts.ens[,8,,n]<-tsl.temp[,"1m",]/tas.temp
    }
    
    #FILL IN LatZone.global.ens
    {
    tas.temp<-get(paste(MODEL.V[n],XP.V[m],REAL,"tas","LatZone.global.interp",sep="."))
    tsl.temp<-get(paste(MODEL.V[n],XP.V[m],REAL,"tsl","LatZone.global.interp",sep="."))
    LatZone.global.ens[,1,n]<-tas.temp
    LatZone.global.ens[,2:3,n]<-tsl.temp[,c("0.01m","1m")]
    if (exists(paste(MODEL.V[n],XP.V[m],REAL,"mrlsl","LatZone.global.interp",sep="."))) {             
      mrlsl.temp<-get(paste(MODEL.V[n],XP.V[m],REAL,"mrlsl","LatZone.global.interp",sep="."))
      LatZone.global.ens[,4:5,n]<-mrlsl.temp[,c("0.01m","0.1m")]} else {
        LatZone.global.ens[,4:5,n]<-rep(NA, length(tsl.temp[,c("0.01m","1m")]))
      }
    }
    
    #FILL IN ZoneMonthly.ens
    {tas.temp<-get(paste(MODEL.V[n],XP.V[m],REAL,"tas","ZoneMonthly.arr",sep="."))
    tsl.temp<-get(paste(MODEL.V[n],XP.V[m],REAL,"tsl","ZoneMonthly.arr",sep="."))
    ZoneMonthly.ens[,1,,,n]<-tas.temp
    ZoneMonthly.ens[,2:3,,,n]<-tsl.temp[,c("0.01m","1m"),,]
    if (exists(paste(MODEL.V[n],XP.V[m],REAL,"mrlsl","ZoneMonthly.arr",sep="."))) {             
     mrlsl.temp<-get(paste(MODEL.V[n],XP.V[m],REAL,"mrlsl","ZoneMonthly.arr",sep="."))
      ZoneMonthly.ens[,4:5,,,n]<-mrlsl.temp[,c("0.01m","0.1m"),,]} else {
        ZoneMonthly.ens[,4:5,,,n]<-rep(NA, length(tsl.temp[,c("0.01m","0.1m"),,]))
      }
    }
  } #End model loop
 
# Write to files
  write.csv(file=paste(WD,"/",XP.V[m],".EOC.tas.csv",sep=""),EOC.ens[,"tas",])
  write.csv(file=paste(WD,"/",XP.V[m],".EOC.tsl0.01.csv",sep=""),EOC.ens[,"tsl0.01",])
  write.csv(file=paste(WD,"/",XP.V[m],".EOC.tsl1.0.csv",sep=""),EOC.ens[,"tsl1.0",])
  write.csv(file=paste(WD,"/",XP.V[m],".EOC.mrlsl0.01.csv",sep=""),EOC.ens[,"mrlsl0.01",])
  write.csv(file=paste(WD,"/",XP.V[m],".EOC.mrlsl0.1.csv",sep=""),EOC.ens[,"mrlsl0.1",])
  write.csv(file=paste(WD,"/",XP.V[m],".EOC.SAWR0.01.csv",sep=""),EOC.ens[,"SAWR0.01",])
  write.csv(file=paste(WD,"/",XP.V[m],".EOC.SAWR1.0.csv",sep=""),EOC.ens[,"SAWR1.0",])
  write.csv(file=paste(WD,"/",XP.V[m],".EOC.SoilMinusAir.csv",sep=""),EOC.ens[,"soil.minus.air",])
  write.csv(file=paste(WD,"/",XP.V[m],".ZoneMonthly.tas.csv",sep=""),ZoneMonthly.ens[,"tas",,,])

  write.csv(file=paste(WD,"/",XP.V[m],".Annualts.tsl.Global.csv",sep=""),Annualts.ens["Global","tsl0.01",,])
  write.csv(file=paste(WD,"/",XP.V[m],".Annualts.tsl.Mollisol.csv",sep=""),Annualts.ens["Mollisol","tsl0.01",,])
  
  for(n in 1: length(MODEL.V)){
    #if(MODEL.V[n]=="CCSM4") REAL<-"r2i1p1" else REAL<-"r1i1p1"
    if(m==1 & n==7) next() #For GISS rcp4.5 skip to next loop
    
    #write.csv(file=paste(WD,"/",XP.V[m],MODEL.V[n],".ZoneMonthly.tsl0.01.csv",sep=""),ZoneMonthly.ens[,"tsl0.01",,,MODEL.V[n]])
} #End models
#} #End experiments
 
  #With all models complete, (1) Calculate ensemble mean and SD, and (2) plot figures for all models, for current experiment
  EOC.ens.stats<-array(data=NA,dim=c(length(SOIL)+length(ZONE)+1,7,3),dimnames=list(c("Global",SOIL,ZONE),c("tas","tsl0.01","tsl1.0","mrlsl0.01","mrlsl0.1","air.minus.soil","ASWR"),c("Ens.mean","Ens.sd","Ens.se")))
  for (c in 1:(length(SOIL)+length(ZONE)+1)){
    EOC.ens.stats[c,,"Ens.mean"]<-apply(EOC.ens[c,,],1,mean, na.rm=TRUE)
    EOC.ens.stats[c,,"Ens.sd"]<-apply(EOC.ens[c,,],1,sd, na.rm=TRUE)
    #EOC.ens.stats[c,d,"Ens.se"]<-apply(EOC.ens[c,,],1,sum(!is.na()))
  }
  # MAKE SNOW MASK
    { File<-paste("F:/wd/",MODEL.V[n],"/tsl_",MODEL.V[n],"_198601-200512_mon_rect.nc",sep="")
    HistAbsoluteMap.nc<-open.nc(File)
    #print.nc(HistAbsoluteMin.nc)
    NLON=dim.inq.nc(HistAbsoluteMap.nc,"lon")$length
    NLAT=dim.inq.nc(HistAbsoluteMap.nc,"lat")$length
    NT=dim.inq.nc(HistAbsoluteMap.nc,"time")$length
    HistAbsoluteMap<-var.get.nc(HistAbsoluteMap.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,1,NT))
    close.nc(HistAbsoluteMap.nc)
    HistAbsoluteMin<-apply(HistAbsoluteMap,c(1,2),min)
    #image.plot(HistAbsoluteMin)
    SnowMask<- HistAbsoluteMin>274
    #image.plot(SnowMask)
    assign(paste(MODEL.V[n],"SnowMask",sep="."),SnowMask)
    } #end snow mask routine
  
  write.csv(file=paste(WD,"/",XP.V[m],".EOC.ensmean.csv",sep=""),EOC.ens.stats[,,1]) 
  write.csv(file=paste(WD,"/",XP.V[m],".EOC.ensSD.csv",sep=""),EOC.ens.stats[,,2])
} #End experiments


#Plot the bars in custom order
LevelsOrder<-c("Global","Rock","ShiftingSand","Entisol","Inceptisol","Aridisol","Andisol","Gelisol","Histosol","Spodosol","Alfisol","Mollisol","Vertisol","Ultisol","Oxisol")
#dev.off()
  par(mar=c(1,4,0.5,4), oma=c(6,0,1,0),mfrow=c(2,1))
{barplot(t(EOC.ens.stats[LevelsOrder,1:3,1]),beside=T,ylim=c(0,12),las=2,axes=FALSE,names.arg=rep(NA,15))
ticks<-seq(1.5, by=1,length.out=(15*4))[-seq(4,by=4,length.out=15)]
#Light tan
polygon(x=c(rep(ticks[1],2)-2.8,rep(ticks[15],2)+1),y=c(0,12,12,0),col=rgb(246,232,195,255,maxColorValue=255),border=NA)
#Tan
polygon(x=c(rep(ticks[16],2)-1,rep(ticks[18],2)+1),y=c(0,12,12,0),col=rgb(216,179,101,255,maxColorValue=255),border=NA)
#Light cyan
polygon(x=c(rep(ticks[19],2)-1,rep(ticks[21],2)+1),y=c(0,12,12,0),col=rgb(199,234,229,255,maxColorValue=255),border=NA)
#Dark cyan
polygon(x=c(rep(ticks[22],2)-1,rep(ticks[30],2)+1),y=c(0,12,12,0),col=rgb(1,102,94,255,maxColorValue=255),border=NA)
#Cyan
polygon(x=c(rep(ticks[31],2)-1,rep(ticks[39],2)+1),y=c(0,12,12,0),col=rgb(90,180,172,255,maxColorValue=255),border=NA)
#Dark Orange
polygon(x=c(rep(ticks[40],2)-1,rep(ticks[45],2)+2.8),y=c(0,12,12,0),col=rgb(140,81,10,255,maxColorValue=255),border=NA)
par(new=TRUE)
barplot(t(EOC.ens.stats[LevelsOrder,1:3,1]),beside=T,ylab=expression(symbol(D)~Temperature~group("(",degree~C,")")),las=2, mgp=c(2,0.5,0), col=c(gray(0.9),gray(0.5),gray(0.1)),names.arg=rep(NA,15),legend.text=c("Surface air temp","Soil temp 0.01 m","Soil temp 1.0 m"), ylim=c(0,12),args.legend=list(x="topright",bg="white"))
box(bty="l")
arrows(ticks,t(EOC.ens.stats[LevelsOrder,1:3,1]),ticks,(t(EOC.ens.stats[LevelsOrder,1:3,1])+t(EOC.ens.stats[LevelsOrder,1:3,2])),angle=90,length=0.05)
  }

  #Plot moisture only at 0.1m depth
par(new=FALSE)
{ 
barplot(t(EOC.ens.stats[LevelsOrder,5,1]),ylim=c(-20,16),axes=FALSE,names.arg=rep(NA,15))
ticks<-barplot(t(EOC.ens.stats[LevelsOrder,5,1]),plot=FALSE)
polygon(x=c(rep(ticks[1],2)-1.5,rep(ticks[5],2)+0.6),y=c(-20,16,16,-20),col=rgb(246,232,195,255,maxColorValue=255),border=NA)
polygon(x=c(rep(ticks[6],2)-0.6,rep(ticks[6],2)+0.6),y=c(-20,16,16,-20),col=rgb(216,179,101,255,maxColorValue=255),border=NA)
polygon(x=c(rep(ticks[7],2)-0.6,rep(ticks[7],2)+0.6),y=c(-20,16,16,-20),col=rgb(199,234,229,255,maxColorValue=255),border=NA)
polygon(x=c(rep(ticks[8],2)-0.6,rep(ticks[10],2)+0.6),y=c(-20,16,16,-20),col=rgb(1,102,94,255,maxColorValue=255),border=NA)
polygon(x=c(rep(ticks[11],2)-0.6,rep(ticks[13],2)+0.6),y=c(-20,16,16,-20),col=rgb(90,180,172,255,maxColorValue=255),border=NA)
polygon(x=c(rep(ticks[14],2)-0.6,rep(ticks[15],2)+1.3),y=c(-20,16,16,-20),col=rgb(140,81,10,255,maxColorValue=255),border=NA)
par(new=TRUE)
barplot(t(EOC.ens.stats[LevelsOrder,5,1]),ylab=expression(symbol(D)~Soil~moisture~group("(",kg~m^{-3},")")),las=2, mgp=c(2,0.5,0), col=c(gray(0.9)),legend.text=c("Moisture 0.1 m"), ylim=c(-20,16),args.legend=list(x="topright",bg="white"))
box(bty="l")
abline(h=0,col="black")
arrows(ticks,t(EOC.ens.stats[LevelsOrder,5,1]),ticks,(t(EOC.ens.stats[LevelsOrder,5,1])+t(EOC.ens.stats[LevelsOrder,5,2])),angle=90,length=0.05)
arrows(ticks,t(EOC.ens.stats[LevelsOrder,5,1]),ticks,(t(EOC.ens.stats[LevelsOrder,5,1])-t(EOC.ens.stats[LevelsOrder,5,2])),angle=90,length=0.05)
}

#Plot shallow and deep moisture change
#   barplot(t(EOC.ens.stats[1:15,4:5,1]),beside=T,ylab=expression(symbol(D)~Soil~moisture~group("(",g~cm^{-3},")")),las=2, mgp=c(2,0.5,0), col=c(gray(0.8),gray(0.5),gray(0.3)),legend.text=c("Moisture 0.1 m","Moisture 1.0 m"), ylim=c(-10,10),args.legend=list(bty="n"))
#   box(bty="l")
#   ticks<-seq(1.5, by=1,length.out=(15*3))[-seq(3,by=3,length.out=15)]
#   arrows(ticks,t(EOC.ens.stats[1:15,4:5,1]),ticks,(t(EOC.ens.stats[1:15,4:5,1])+t(EOC.ens.stats[1:15,4:5,2])),angle=90,length=0.05)
#   arrows(ticks,t(EOC.ens.stats[1:15,4:5,1]),ticks,(t(EOC.ens.stats[1:15,4:5,1])-t(EOC.ens.stats[1:15,4:5,2])),angle=90,length=0.05)
  
  ## Plot ensemble time series to Global and regions of interest
  Annualts.ens.stats<-array(data=NA,dim=c(length(c("Global",SOIL,ZONE)),6,length(YEARS),2),dimnames=list(c("Global",SOIL,ZONE),c("tas","tsl0.01","soil.minus.air","SAWR0.01","SAWR1.0","mrlsl0.1"),YEARS,c("Ens.mean","Ens.sd")))
  for (c in 1:(length(ZONE)+length(SOIL)+1)){
    for(d in 1:length(YEARS)){
    Annualts.ens.stats[c,,d,"Ens.mean"]<-apply(Annualts.ens[c,c(1,2,6,7,8,5),d,],1,mean, na.rm=TRUE)
    Annualts.ens.stats[c,,d,"Ens.sd"]<-apply(Annualts.ens[c,c(1,2,6,7,8,5),d,],1,sd, na.rm=TRUE)
    }
  }

  
  #Plot timeseries for regions of interest ####
  par(mfrow=c(4,5),oma=c(4,4,4,0), mar=c(1,1,1,1), tck=0.02, mgp=c(2,0.5,0))
  YLIM=list(c(-1,8),c(-1,8),c(-1.5,1.5),NULL,NULL,c(-30,30))
  for(i in c(1,2,3,6)){
    plot(YEARS,Annualts.ens.stats["Global",i,,"Ens.mean"],type="l",ylim=YLIM[[i]])
    polygon(x=c(YEARS,rev(YEARS)),y=c(Annualts.ens.stats["Global",i,,"Ens.mean"]+Annualts.ens.stats["Global",i,,"Ens.sd"],rev(Annualts.ens.stats["Global",i,,"Ens.mean"]-Annualts.ens.stats["Global",i,,"Ens.sd"])), col=grey(0.7))
    lines(YEARS,Annualts.ens.stats["Global",i,,"Ens.mean"],type="l",lwd=2)
    if(i==1){mtext("Global",side=3,line=0,outer=FALSE); mtext(expression(symbol(D)~Air~temp),side=2,line=2,outer=FALSE)}
    if(i==2){mtext(expression(symbol(D)~Soil~temp),side=2,line=2,outer=FALSE)}
    if(i==3){mtext("Soil-Air temp",side=2,line=2,outer=FALSE)}
    if(i==6){mtext(expression(symbol(D)~moisture),side=2,line=2,outer=FALSE)}
    
    plot(YEARS,Annualts.ens.stats["GreatPlains",i,,"Ens.mean"],type="l",ylim=YLIM[[i]])
    polygon(x=c(YEARS,rev(YEARS)),y=c(Annualts.ens.stats["GreatPlains",i,,"Ens.mean"]+Annualts.ens.stats["GreatPlains",i,,"Ens.sd"],rev(Annualts.ens.stats["GreatPlains",i,,"Ens.mean"]-Annualts.ens.stats["GreatPlains",i,,"Ens.sd"])), col=grey(0.7))
    lines(YEARS,Annualts.ens.stats["GreatPlains",i,,"Ens.mean"],type="l",lwd=2)
    if(i==1){mtext("Great Plains",side=3,line=0,outer=FALSE)}
    
    plot(YEARS,Annualts.ens.stats["PampasPlain",i,,"Ens.mean"],type="l",ylim=YLIM[[i]])
    polygon(x=c(YEARS,rev(YEARS)),y=c(Annualts.ens.stats["PampasPlain",i,,"Ens.mean"]+Annualts.ens.stats["PampasPlain",i,,"Ens.sd"],rev(Annualts.ens.stats["PampasPlain",i,,"Ens.mean"]-Annualts.ens.stats["PampasPlain",i,,"Ens.sd"])), col=grey(0.7))
    lines(YEARS,Annualts.ens.stats["PampasPlain",i,,"Ens.mean"],type="l",lwd=2)
    if(i==1){mtext("Pampas Plains",side=3,line=0,outer=FALSE)}
    
    plot(YEARS,Annualts.ens.stats["EurasianSteppe",i,,"Ens.mean"],type="l",ylim=YLIM[[i]])
    polygon(x=c(YEARS,rev(YEARS)),y=c(Annualts.ens.stats["EurasianSteppe",i,,"Ens.mean"]+Annualts.ens.stats["EurasianSteppe",i,,"Ens.sd"],rev(Annualts.ens.stats["EurasianSteppe",i,,"Ens.mean"]-Annualts.ens.stats["EurasianSteppe",i,,"Ens.sd"])), col=grey(0.7))
    lines(YEARS,Annualts.ens.stats["EurasianSteppe",i,,"Ens.mean"],type="l",lwd=2)
    if(i==1){mtext("Central Europe",side=3,line=0,outer=FALSE)}
    
    plot(YEARS,Annualts.ens.stats["ChinaMoll",i,,"Ens.mean"],type="l",ylim=YLIM[[i]])
    polygon(x=c(YEARS,rev(YEARS)),y=c(Annualts.ens.stats["ChinaMoll",i,,"Ens.mean"]+Annualts.ens.stats["ChinaMoll",i,,"Ens.sd"],rev(Annualts.ens.stats["ChinaMoll",i,,"Ens.mean"]-Annualts.ens.stats["ChinaMoll",i,,"Ens.sd"])), col=grey(0.7))
    lines(YEARS,Annualts.ens.stats["ChinaMoll",i,,"Ens.mean"],type="l",lwd=2)
    if(i==1){mtext("Asian Steppe ",side=3,line=0,outer=FALSE)}
  }
  
  
  # Plot latitudinal effects #####
{par(oma=c(5,5,5,2), mar=c(0,0,0,0), tck=0.02,mgp=c(2,0.5,0))
layout(rbind(c(1,2,3,7),
             c(4,5,6,7)), widths=c(2,2,2,1))
#layout.show(7)
  for(i in c(1,2,7,3,4,5)){
    tsl.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tsl","LatZone.arr",sep="."))
    plot(as.numeric(dimnames(tsl.temp)[[2]]),tsl.temp[i,,"0.01m"],type="l",ylab="",xlab="",cex.lab=1.4,lwd=1, cex.axis=1.4, cex.main=1.6, ylim=c(0,15), xaxt="n",yaxt="n")
    axis(side=1, labels=FALSE, tck=0.03)
    axis(side=2, labels=FALSE, tck=0.03)
    text(0,14,dimnames(tsl.temp)[[1]][i],cex=1.8)
    #legend("topleft",legend=MODEL.V,text.col=1:length(MODEL.V), bty="n",cex=1.4)
    for(j in 2:length(MODEL.V)){
      tsl.temp<-get(paste(MODEL.V[j],XP.V[m],REAL,"tsl","LatZone.arr",sep="."))
      lines(as.numeric(dimnames(tsl.temp)[[2]]),tsl.temp[i,,"0.01m"],lwd=1,col=j)
    }
    if(i==1 | i==3) axis(side=2, labels=TRUE, tck=0.03, cex.axis=1.4, mgp=c(2,0.5,0))
    if(i==4 | i==6 | i==3) axis(side=1, labels=TRUE, tck=0.03, cex.axis=1.4, mgp=c(2,0.5,0))
  }
  mtext("Latitude",side=1,line=2, outer=TRUE, cex=1.4)
  mtext(expression(symbol(D)~Soil~Temp~0.01~m~group("(",degree~C,")")),side=2,line=2,outer=TRUE,cex=1.4)
  plot.new()
  legend("center",legend=MODEL.V,text.col=1:length(MODEL.V), cex=1.2, bty="n")
} 

# Plot soil/air warming ratio ####
dev.off()
{par(oma=c(5,5,5,2), mar=c(0,0,0,0), tck=0.02,mgp=c(2,0.5,0))
layout(rbind(c(1,2,3,7),
             c(4,5,6,7))) 
#par(mfrow=c(4,5))
#for(i in 1:19){
#for(i in c(1,13,12,8,10,4)){ #Global, alfisol,mollisol, ultisol, oxisol, aridisol, gelisol
#Model colors
library(RColorBrewer)
mypalette<-c(brewer.pal(7,"Dark2"),brewer.pal(7,"Set2"))
for(i in c(4,6,13,12,11,8)){ #Gelisol, spodisol, alfisol,mollisol, ultisol, oxisol
  plot(2006:2100,Annualts.ens.stats[i,"SAWR1.0",,"Ens.mean"],type="l",ylab="",xlab="",cex.lab=1.4,lwd=2, cex.axis=1.4, cex.main=1.6, ylim=c(0,2), xlim=c(2000,2110), xaxt="n",yaxt="n",ylog=TRUE)
  #abline(h=1, col="grey", lty=2, lwd=2)
  text(2100,1.7,dimnames(Annualts.ens.stats)[[1]][i],cex=1.8, adj=c(1,0.5))
  for(j in 1:length(MODEL.V)){
    lines(2006:2100,Annualts.ens[i,"SAWR1.0",,j],lwd=1,col=mypalette[j])
  }
  lines(2006:2100,Annualts.ens.stats[i,"SAWR1.0",,"Ens.mean"],lwd=2) #Put the ens mean line on top again
  box(lwd=2)
  abline(h=1,col=grey, lty=2, lwd=2)
  axis(side=1, labels=FALSE, tck=0.03, lwd=2)
  axis(side=2, labels=FALSE, tck=0.03, lwd=2)
  #if(i==1 | i==6 |i==11 |i ==16) axis(side=2, labels=TRUE, tck=0.03, cex.axis=1.6, mgp=c(2,0.5,0))
  #if(i>15) axis(side=1, labels=TRUE, tck=0.03, cex.axis=1.6, mgp=c(2,0.5,0))
  if(i==4 | i==12) axis(side=2, labels=TRUE, tck=0.03, cex.axis=1.6, mgp=c(2,0.5,0))
  if(i==8 | i==11 | i==12) axis(side=1, labels=TRUE, tck=0.03, cex.axis=1.6, mgp=c(2,0.5,0))
  if(i==11) mtext("Year",side=1,line=2, outer=FALSE, cex=1.4)
}
mtext("Soil / Air Warming Ratio",side=2,line=2, outer=TRUE, cex=1.4)
plot.new()
legend("center",legend=c("Ensemble mean",MODEL.V),text.col=c("black",mypalette[1:length(MODEL.V)]), col=c("black",mypalette[1:length(MODEL.V)]),lty=1, lwd=c(2,rep(1,length(MODEL.V))),cex=1.4, bty="n")
}

# Plot soil moisture changes through time for soil orders of interest
#dev.off()
{par(oma=c(5,5,5,2), mar=c(0,0,0,0), tck=0.02,mgp=c(2,0.5,0))
layout(rbind(c(1,2,3,7),
             c(4,5,6,7)))
#par(mfrow=c(4,5))
#for(i in 1:19){
#for(i in c(1,13,12,8,10,4)){
for(i in c(4,6,13,12,11,8)){ #Gelisol, spodisol, alfisol,mollisol, ultisol, oxisol
  plot(2006:2100,Annualts.ens.stats[i,"mrlsl0.1",,"Ens.mean"],type="l",ylab="",xlab="",cex.lab=1.4,lwd=2, cex.axis=1.4, cex.main=1.6, ylim=c(-47,25), xlim=c(2000,2110), xaxt="n",yaxt="n",ylog=TRUE)
  abline(h=0, col="grey", lty=2, lwd=2)
  text(2100,22,dimnames(Annualts.ens.stats)[[1]][i],cex=1.8, adj=c(1,0.5))
  for(j in 1:length(MODEL.V)){
    if (MODEL.V[j]=="CCSM4") REAL<-"r2i1p1"
    else REAL<-"r1i1p1"
    if(!exists(paste(MODEL.V[j],XP.V[m],REAL,"mrlsl","Annualts.arr",sep="."))) next()
    lines(2006:2100,Annualts.ens[i,"mrlsl0.1",,j],lwd=1,col=mypalette[j])
  }
  lines(2006:2100,Annualts.ens.stats[i,"mrlsl0.1",,"Ens.mean"],lwd=2) #Put the ens mean line on top again
  box(lwd=2)
  axis(side=1, labels=FALSE, tck=0.03, lwd=2)
  axis(side=2, labels=FALSE, tck=0.03, lwd=2)
  #if(i==1 | i==6 |i==11 |i ==16) axis(side=2, labels=TRUE, tck=0.03, cex.axis=1.6, mgp=c(2,0.5,0))
  #if(i>15) axis(side=1, labels=TRUE, tck=0.03, cex.axis=1.6, mgp=c(2,0.5,0))
  if(i==4 | i==12) axis(side=2, labels=TRUE, tck=0.03, cex.axis=1.6, mgp=c(2,0.5,0))
  if(i==8 | i==11 | i==12) axis(side=1, labels=TRUE, tck=0.03, cex.axis=1.6, mgp=c(2,0.5,0))
  if(i==11) mtext("Year",side=1,line=2, outer=FALSE, cex=1.4)
}
mtext(expression(symbol(D)~Soil~Moisture~group("(",kg~m^{-3},")")),side=2,line=2,outer=TRUE,cex=1.4)
plot.new()
keepers<-c(1:4,6:9,11,13)
legend("center",legend=c("Ensemble mean",MODEL.V[keepers]),text.col=c("black",mypalette[keepers]), col=c("black",mypalette[keepers]),lwd=c(2,rep(1,10)), cex=1.2, bty="n")
}

## Apply snow mask to warming ratio and moisture changes


#Plot soil warming profiles for US Mollisol for each model
{ # dev.off()
  par(oma=c(5,5,4,4), mar=c(0,0,0,0), tck=0.02,mgp=c(2,0.5,0),mfrow=c(3,5))
  for(i in 1:length(MODEL.V)){
    tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
    depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
    depths<-c(2,depths[-c(length(depths),(length(depths)-1))]*-1)
    tas.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
    profile<-c(tas.temp[16],tsl.temp[16,1:(ncol(tsl.temp)-2)])
    plot(profile,depths,ylim=c(-11,2), xlim=c(2,7), type="o",lwd=2, xaxt="n",yaxt="n")
    abline(h=0,col="grey",lwd=2)
    text(2.1, -11,MODEL.V[i],cex=1.6,cex.axis=1.6, adj=c(0,0))
    if(i>10) axis(side=1,labels=TRUE,tck=0.03, cex.axis=1.4) else axis(side=1,labels=FALSE,tck=0.03)
    if(i==1| i==6 | i==11) axis(side=2,labels=TRUE,tck=0.03, cex.axis=1.4) else axis(side=2,labels=FALSE,tck=0.03)
  }
  mtext("Soil depth (m)",side=2, line=2, outer=TRUE, cex=1.4)
  mtext(expression(symbol(D)~Temperature~group("(",degree~C,")")),side=1,line=3,outer=TRUE,cex=1.4)
}

#Plot all the models on same graph for warming profiles in three regions:
# Canadian Gelisol, U.S. Molisol, Amazon Oxisol
{  #dev.off()  
  layout(rbind(c(1,2,3,4),c(1,2,3,4)),widths=c(2,2,2,1))
    layout.show(4)
  #Gelisol, Canada
  { par(mar=c(5,5,4,0),oma=c(0,0,0,0),tck=0.02, mgp=c(2,0.5,0),xpd=FALSE)
      REAL<-"r1i1p1"
  tsl.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
  depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
  depths<-c(2,depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
  tas.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
  profile<-c(tas.temp[22],tsl.temp[22,1:(ncol(tsl.temp)-3)])
  plot(profile,depths,ylim=c(-11,2), xlim=c(2,8), type="o",lwd=2, xlab=expression(symbol(D)~Temperature~group("(",degree~C,")")), ylab="Soil depth (m)", cex.lab=1.8, cex.axis=1.4,main="Canada, Gelisol",cex.main=1.6,col=mypalette[1])
  abline(h=0,col="grey",lwd=2)
  for(i in 2:length(MODEL.V)){
    tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
    depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
    depths<-c(2,depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
    tas.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
    profile<-c(tas.temp[22],tsl.temp[22,1:(ncol(tsl.temp)-3)])
    lines(profile,depths,col=mypalette[i], type="o", lwd=2, pch=i)
  }
  box(lwd=2)
  }
  #Mollisol, Great Plains
  { #par(mar=c(5,5,4,1),oma=c(0,0,0,0),tck=0.02, mgp=c(2,0.5,0),xpd=FALSE)
  REAL<-"r1i1p1"
  tsl.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
  depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
  depths<-c(2,depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
  tas.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
  profile<-c(tas.temp[16],tsl.temp[16,1:(ncol(tsl.temp)-3)])
  plot(profile,depths,ylim=c(-11,2), xlim=c(2,8), type="o",lwd=2, xlab=expression(symbol(D)~Temperature~group("(",degree~C,")")), ylab="", cex.lab=1.8, cex.axis=1.4,main="Great Plains, Mollisol",cex.main=1.6,col=mypalette[1])
  abline(h=0,col="grey",lwd=2)
  for(i in 2:length(MODEL.V)){
    tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
    depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
    depths<-c(2,depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
    tas.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
    profile<-c(tas.temp[16],tsl.temp[16,1:(ncol(tsl.temp)-3)])
    lines(profile,depths,col=mypalette[i], type="o", lwd=2, pch=i)
  }
  box(lwd=2)
}
 #Oxisol, Amazon
 { REAL<-"r1i1p1"
  tsl.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
  depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
  depths<-c(2,depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
  tas.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
  profile<-c(tas.temp[23],tsl.temp[23,1:(ncol(tsl.temp)-3)])
  plot(profile,depths,ylim=c(-11,2), xlim=c(2,8), type="o",lwd=2, xlab=expression(symbol(D)~Temperature~group("(",degree~C,")")), ylab="", cex.lab=1.8, cex.axis=1.4,main="Amazon, Oxisol",cex.main=1.6,col=mypalette[1])
  abline(h=0,col="grey",lwd=2)
  for(i in 2:length(MODEL.V)){
    tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
    depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
    depths<-c(2,depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
    tas.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
    profile<-c(tas.temp[23],tsl.temp[23,1:(ncol(tsl.temp)-3)])
    lines(profile,depths,col=mypalette[i], type="o", lwd=2, pch=i)
  }
  box(lwd=2)
}
  plot.new()
  par(mar=c(0,0,0,0),oma=c(0,1,0,1))
  legend("center",legend=MODEL.V,col=1:length(MODEL.V), text.col=1:length(MODEL.V), lty=1, pch=1:length(MODEL.V), lwd=2, bty="n", cex=1.4)
}

#Replot profiles with zoom in on top 50 cm depth
{  dev.off()  
   layout(rbind(c(1,3,5,7),c(1,3,5,7),c(2,4,6,7)),widths=c(2,2,2,2))
   #layout.show(7)
   #Gelisol, Canada
   #0-10m
{ par(mar=c(4,5,4,0),oma=c(0,0,0,0),tck=0.02, mgp=c(2.2,0.5,0),xpd=FALSE)
  REAL<-"r1i1p1"
  tsl.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
  depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
  depths<-c(2,depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
  tas.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
  profile<-c(tas.temp[22],tsl.temp[22,1:(ncol(tsl.temp)-3)])
  plot(profile,depths,ylim=c(-11,2), xlim=c(0,8), type="o",lwd=2, xlab=expression(symbol(D)~Temp~group("(",degree~C,")")), ylab="Depth (m)", cex.lab=1.8, cex.axis=1.4,main="Canada, Gelisol",cex.main=1.6,col=mypalette[1])
  abline(h=0,col="grey",lwd=2)
  for(i in 2:length(MODEL.V)){
    tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
    depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
    depths<-c(2,depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
    tas.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
    profile<-c(tas.temp[22],tsl.temp[22,1:(ncol(tsl.temp)-3)])
    lines(profile,depths,col=mypalette[i], type="o", lwd=2, pch=i)
  }
  box(lwd=2)
   }
  #0-0.3m
{  par(mar=c(4,5,0,0))
  REAL<-"r1i1p1"
  tsl.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
  depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
  depths<-c(depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
  tas.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
  profile<-tsl.temp[22,1:(ncol(tsl.temp)-3)]/tas.temp[22]
  plot(profile,depths,ylim=c(-0.3,0), xlim=c(0.5,1.1), type="o",lwd=2,xlab=expression(symbol(D)~T[soil]/symbol(D)~T[Air]) , ylab="Depth (m)", cex.lab=1.8, cex.axis=1.4,main="",col=mypalette[1])#
  
  for(i in 2:length(MODEL.V)){
    tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
    depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
    depths<-c(depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
    tas.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
    profile<-tsl.temp[22,1:(ncol(tsl.temp)-3)]/tas.temp[22]
    lines(profile,depths,col=mypalette[i], type="o", lwd=2, pch=i)
  }
  box(lwd=2)
}
#Mollisol, Great Plains, 0-10m
{ par(mar=c(4,5,4,0))
  REAL<-"r1i1p1"
  tsl.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
  depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
  depths<-c(2,depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
  tas.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
  profile<-c(tas.temp[16],tsl.temp[16,1:(ncol(tsl.temp)-3)])
  plot(profile,depths,ylim=c(-11,2), xlim=c(2,8), type="o",lwd=2, xlab=expression(symbol(D)~Temp~group("(",degree~C,")")), ylab="", cex.lab=1.8, cex.axis=1.4,main="U.S., Mollisol",cex.main=1.6,col=mypalette[1])
  abline(h=0,col="grey",lwd=2)
  for(i in 2:length(MODEL.V)){
    tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
    depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
    depths<-c(2,depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
    tas.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
    profile<-c(tas.temp[16],tsl.temp[16,1:(ncol(tsl.temp)-3)])
    lines(profile,depths,col=mypalette[i], type="o", lwd=2, pch=i)
  }
  box(lwd=2)
}
#Mollisol, Great Plains, 0-0.3m
{ par(mar=c(4,5,0,0))
  REAL<-"r1i1p1"
  tsl.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
  depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
  depths<-c(depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
  tas.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
  profile<-tsl.temp[16,1:(ncol(tsl.temp)-3)]/tas.temp[16]
  plot(profile,depths,ylim=c(-0.3,0), xlim=c(0.5,1.1), type="o",lwd=2, xlab=expression(symbol(D)~T[soil]/symbol(D)~T[Air]), ylab="", cex.lab=1.8, cex.axis=1.4,main="",col=mypalette[1])
  for(i in 2:length(MODEL.V)){
    tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
    depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
    depths<-c(depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
    tas.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
    profile<-tsl.temp[16,1:(ncol(tsl.temp)-3)]/tas.temp[16]
    lines(profile,depths,col=mypalette[i], type="o", lwd=2, pch=i)
  }
  box(lwd=2)
}
#Oxisol, Amazon, 0-10m
{ par(mar=c(4,5,4,0))
  REAL<-"r1i1p1"
  tsl.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
  depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
  depths<-c(2,depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
  tas.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
  profile<-c(tas.temp[23],tsl.temp[23,1:(ncol(tsl.temp)-3)])
  plot(profile,depths,ylim=c(-11,2), xlim=c(2,8), type="o",lwd=2, xlab=expression(symbol(D)~Temp~group("(",degree~C,")")), ylab="", cex.lab=1.8, cex.axis=1.4,main="Amazon, Oxisol",cex.main=1.6,col=mypalette[1])
  abline(h=0,col="grey",lwd=2)
  for(i in 2:length(MODEL.V)){
    tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
    depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
    depths<-c(2,depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
    tas.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
    profile<-c(tas.temp[23],tsl.temp[23,1:(ncol(tsl.temp)-3)])
    lines(profile,depths,col=mypalette[i], type="o", lwd=2, pch=i)
  }
  box(lwd=2)
}
#Oxisol, Amazon, 0-0.3m
{ par(mar=c(4,5,0,0))
  REAL<-"r1i1p1"
  tsl.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
  depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
  depths<-c(depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
  tas.temp<-get(paste(MODEL.V[1],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
  profile<-tsl.temp[23,1:(ncol(tsl.temp)-3)]/tas.temp[23]
  plot(profile,depths,ylim=c(-0.3,0), xlim=c(0.5,1.1), type="o",lwd=2, xlab=expression(symbol(D)~T[soil]/symbol(D)~T[Air]), ylab="", cex.lab=1.8, cex.axis=1.4,main="",col=mypalette[1])
  for(i in 2:length(MODEL.V)){
    tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
    depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
    depths<-c(depths[-c(length(depths),(length(depths)-1),(length(depths)-2))]*-1)
    tas.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","EOCmean.arr",sep="."))
    profile<-tsl.temp[23,1:(ncol(tsl.temp)-3)]/tas.temp[23]
    lines(profile,depths,col=mypalette[i], type="o", lwd=2, pch=i)
  }
  box(lwd=2)
}
plot.new()
par(mar=c(0,0,0,0),oma=c(0,1,0,2))
legend("center",legend=MODEL.V,col=mypalette[1:length(MODEL.V)], text.col=mypalette[1:length(MODEL.V)], lty=1, pch=1:length(MODEL.V), lwd=2, bty="n", cex=1.4)
}
  
#Plot soil MOISTURE profiles for US Mollisol for each model
{  dev.off()
  par(oma=c(5,5,4,4), mar=c(0,0,0,0), tck=0.02,mgp=c(2,0.5,0),mfrow=c(3,5))
  for(i in 1:length(MODEL.V)){
    File<-paste(MODEL.V[i],XP.V[m],REAL,"mrlsl","EOCmean.arr",sep=".")
    if(!exists(File)){profile<-NULL; depths<-NULL} else {
      mrlsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"mrlsl","EOCmean.arr",sep="."))
      depths<-as.numeric(unlist(strsplit(dimnames(mrlsl.temp)[[2]],"m")))
      depths<-(depths[-c(length(depths),(length(depths)-1))]*-1)
      profile<-mrlsl.temp[16,1:(ncol(mrlsl.temp)-2)]
    }
    plot(profile,depths,ylim=c(-11,0), xlim=c(-30,30), type="o",lwd=2, xaxt="n",yaxt="n")
    text(0, -11,MODEL.V[i],cex=1.6,cex.axis=1.6, adj=c(0,0))
    if(i>10) axis(side=1,labels=TRUE,tck=0.03, cex.axis=1.4) else axis(side=1,labels=FALSE,tck=0.03)
    if(i==1| i==6 | i==11) axis(side=2,labels=TRUE,tck=0.03, cex.axis=1.4) else axis(side=2,labels=FALSE,tck=0.03)
  }
mtext("Soil depth (m)",side=2, line=2, outer=TRUE, cex=1.4)
mtext(expression(symbol(D)~Moisture~group("(",kg~m^{-3},")")),side=1,line=3,outer=TRUE,cex=1.4)
}  
  
  ## Plot annual temp amplitude profiles
  #Get max(tas)-min(tas)
  #Get max and min for each depth
  #Find where amplitude < 0.37 * range(tas) = damping depth
tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCmean.arr",sep="."))
depths<-as.numeric(unlist(strsplit(dimnames(tsl.temp)[[2]],"m")))
depths<-depths[-c(length(depths),(length(depths)-1))]
#Get maps
tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","AnomGlobalmap",sep="."))
tsl.temp<-tsl.temp[,,1:(dim(tsl.temp)[3]-2)] #Cut off the 0.01m and 1.0m interpolated depths
dimnames(tsl.temp)[[3]]<-c(depths) 
  } 
}

# Plot ensemble avgs for monthly means
REAL<-"r1i1p1"
ZoneMonthly.ens.stats<-array(data=NA,dim=c(length(ZONE),2,12,2),dimnames=list(c(ZONE),c("1986-2005","2080-2100"),month.abb,c("Ens.mean","Ens.sd")))
for (c in 1:(length(ZONE))){
  for(d in 1:2){
    ZoneMonthly.ens.stats[c,d,,"Ens.mean"]<-apply(ZoneMonthly.ens[c,2,,d,],1,mean, na.rm=TRUE)
    ZoneMonthly.ens.stats[c,d,,"Ens.sd"]<-apply(ZoneMonthly.ens[c,2,,d,],1,sd, na.rm=TRUE)
  }
}
dev.off()
ZoneNames=c("U.S. Great Plains","Pampas Plains", "Central Europe", "Asian Steppe", "Australia Aridisol", "Europe Alfisol","Canada Gelisol","Amazon Oxisol")
par(oma=c(0,4,1,0), mar=c(4,1,2,1), tck=0.02,mgp=c(2,0.5,0),mfrow=c(2,4))

for(c in 1:length(ZONE)){
  plot(1:12,ZoneMonthly.ens.stats[c,"1986-2005",,"Ens.mean"]-273.15,type="o",lwd=2, xaxt="n", cex.axis=1.4, main=ZoneNames[c], cex.main=1.6,xlab="",ylim=c(-15,40))
  axis(side=1,at=1:12,labels=month.abb, cex.axis=1.4)
  lines(1:12,ZoneMonthly.ens.stats[c,"2080-2100",,"Ens.mean"]-273.15,type="o",lwd=2, col="dark grey")
  arrows(x0=1:12,y0=ZoneMonthly.ens.stats[c,"2080-2100",,"Ens.mean"],y1=ZoneMonthly.ens.stats[c,"2080-2100",,"Ens.mean"]+ZoneMonthly.ens.stats[c,"2080-2100",,"Ens.sd"], col="grey",length=0.08,angle=90)
  arrows(x0=1:12,y0=ZoneMonthly.ens.stats[c,"2080-2100",,"Ens.mean"],y1=ZoneMonthly.ens.stats[c,"2080-2100",,"Ens.mean"]-ZoneMonthly.ens.stats[c,"2080-2100",,"Ens.sd"], col="grey",length=0.08,angle=90)
  
  arrows(x0=jitter(1:12),y0=ZoneMonthly.ens.stats[c,"1986-2005",,"Ens.mean"],y1=ZoneMonthly.ens.stats[c,"1986-2005",,"Ens.mean"]+ZoneMonthly.ens.stats[c,"1986-2005",,"Ens.sd"],length=0.08,angle=90)
  arrows(x0=jitter(1:12),y0=ZoneMonthly.ens.stats[c,"1986-2005",,"Ens.mean"],y1=ZoneMonthly.ens.stats[c,"1986-2005",,"Ens.mean"]-ZoneMonthly.ens.stats[c,"1986-2005",,"Ens.sd"],length=0.08,angle=90 )
 
  abline(h=276.15, lty=2, col="grey")
}
legend("topright",legend=c("1986-2005","2080-2100"),text.col=c("black","grey"),cex=1.6, bty="n")
mtext(expression(Soil~Temp~0.01~m~group("(",degree~C,")")),side=2,line=1,outer=TRUE,cex=1.4)

# # Plot maps of delta tas, tsl0.1, and mrlsl0.1
# # Soil warming minus air warming
# dev.off()
# par(mfrow=c(2,3),mar=c(1,1,3,1), oma=c(1,1,4,1))
# for (i in 1: length(MODEL.V)){
#   tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","AnomGlobalmap",sep="."))[,,"0.01m"]
#   tas.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","AnomGlobalmap",sep="."))
#   tsl.minus.tas.anom<-tsl.temp-tas.temp
#   image.plot(tsl.minus.tas.anom,xaxt="n",zlim=c(-10,10),yaxt="n",main=MODEL.V[i]) 
#   box(lwd=1)
# }  
# mtext("Soil temperature anomaly minus air temperature anomaly, 2080-2100",side=3,line=0,outer=TRUE)
# 
# Plot soil warming
jpeg(paste("C:/Users/Claire/Documents/LBL/Figures/EOCSoilWarming_1cm.jpg",sep=""),width=1000, height=768,res=200,quality=100)
{par(oma=c(1,1,1,1),mar=c(0,0.5,1.5,0))
layout(rbind(c(1,2,3,4,17),
             c(5,6,7,8,17),
             c(9,10,11,12,17),
             c(13,14,15,16,17)))
#layout.show(17)

for (i in 1: length(MODEL.V)){
  File<-paste("F:/wd/",MODEL.V[i],"/",MODEL.V[i],"_ocean-mask.nc",sep="")
  Land.nc<-open.nc(File)
  NLON=dim.inq.nc(Land.nc,"lon")$length
  NLAT=dim.inq.nc(Land.nc,"lat")$length
  Land<-var.get.nc(Land.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,1,1))
  x<-var.get.nc(Land.nc,"lon",start=c(1),count=c(NLON))
  y<-var.get.nc(Land.nc,"lat",start=c(1),count=c(NLAT))
  Land[Land>0]<-1
  Land[is.na(Land)]<-0
  Land<-Land[c(((NLON/2+1):NLON),(1:(NLON/2))),]
  
  tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","AnomGlobalmap",sep="."))[,,"0.01m"]
  tsl.temp<-tsl.temp[c(((NLON/2+1):NLON),(1:(NLON/2))),]
  image(x,y,tsl.temp,xaxt="n",zlim=c(0,15),yaxt="n",col=tim.colors(),main=MODEL.V[i]) 
  box(lwd=1)
  contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")
}  
plot.new()
plot.new()
#mtext("Soil temperature anomaly, 2080-2100",side=3,line=0,outer=TRUE)
par(oma=c(0,0,0,4))# reset margin to be much smaller.
image.plot(legend.only=TRUE, zlim=c(0,15),legend.width=4.6) 
}
dev.off()

#Plot just the most detailed model, CESM1-BGC
dev.off()
{File<-paste("F:/wd/",MODEL.V[5],"/",MODEL.V[5],"_ocean-mask.nc",sep="")
Land.nc<-open.nc(File)
NLON=dim.inq.nc(Land.nc,"lon")$length
NLAT=dim.inq.nc(Land.nc,"lat")$length
Land<-var.get.nc(Land.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,1,1))
Land[Land>0]<-1
Land[is.na(Land)]<-0
Land<-Land[c(((NLON/2+1):NLON),(1:(NLON/2))),]
x<-var.get.nc(Land.nc,"lon",start=c(1),count=c(NLON))
y<-var.get.nc(Land.nc,"lat",start=c(1),count=c(NLAT))
tsl.temp<-get(paste(MODEL.V[5],XP.V[m],REAL,"tsl","AnomGlobalmap",sep="."))[,,"0.01m"]
tsl.temp<-tsl.temp[c(((NLON/2+1):NLON),(1:(NLON/2))),]
# MST asked for all values > 10 to appear red
tsl.temp[tsl.temp>10]<-10
image.plot(x,y,tsl.temp,axes=F,xlab="",ylab="",zlim=c(0,10),col=tim.colors()) 
box(lwd=1)
contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")
}

#Plot map of soil warming minus air warming
jpeg(paste("C:/Users/Claire/Documents/LBL/Figures/EOCAirSoilWarmingDifference.jpg",sep=""),width=1000, height=768,res=200,quality=100)
{par(oma=c(1,1,1,1),mar=c(0,0.5,1.5,0))
 layout(rbind(c(1,2,3,4,17),
              c(5,6,7,8,17),
              c(9,10,11,12,17),
              c(13,14,15,16,17)))
 
 for (i in 1: length(MODEL.V)){
   File<-paste("F:/wd/",MODEL.V[i],"/",MODEL.V[i],"_ocean-mask.nc",sep="")
   Land.nc<-open.nc(File)
   NLON=dim.inq.nc(Land.nc,"lon")$length
   NLAT=dim.inq.nc(Land.nc,"lat")$length
   Land<-var.get.nc(Land.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,1,1))
   x<-var.get.nc(Land.nc,"lon",start=c(1),count=c(NLON))
   y<-var.get.nc(Land.nc,"lat",start=c(1),count=c(NLAT))
   Land[Land>0]<-1
   Land[is.na(Land)]<-0
   Land<-Land[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   
   tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","AnomGlobalmap",sep="."))[,,"0.01m"]
   tsl.temp<-tsl.temp[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   tas.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","AnomGlobalmap",sep="."))
   tas.temp<-tas.temp[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   difference<-tas.temp - tsl.temp
   image(x,y,difference,xaxt="n",zlim=c(-8,8),yaxt="n",col=tim.colors(),main=MODEL.V[i]) 
   box(lwd=1)
   contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")
 }  
 plot.new()
 plot.new()
 par(oma=c(0,0,0,4))# reset margin to be much smaller.
 image.plot(legend.only=TRUE, zlim=c(-8,8),legend.width=4.6) 
}
dev.off()

#Plot map of air warming divided by soil warming
jpeg(paste("C:/Users/Claire/Documents/LBL/Figures/EOCAirSoilWarmingRatio.jpg",sep=""),width=1000, height=768,res=200,quality=100)
{par(oma=c(1,1,1,1),mar=c(0,0.5,1.5,0))
 layout(rbind(c(1,2,3,4,17),
              c(5,6,7,8,17),
              c(9,10,11,12,17),
              c(13,14,15,16,17)))
 
 for (i in 1: length(MODEL.V)){
   File<-paste("F:/wd/",MODEL.V[i],"/",MODEL.V[i],"_ocean-mask.nc",sep="")
   Land.nc<-open.nc(File)
   NLON=dim.inq.nc(Land.nc,"lon")$length
   NLAT=dim.inq.nc(Land.nc,"lat")$length
   Land<-var.get.nc(Land.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,1,1))
   x<-var.get.nc(Land.nc,"lon",start=c(1),count=c(NLON))
   y<-var.get.nc(Land.nc,"lat",start=c(1),count=c(NLAT))
   Land[Land>0]<-1
   Land[is.na(Land)]<-0
   Land<-Land[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   
   tsl.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","AnomGlobalmap",sep="."))[,,"0.01m"]
   tsl.temp<-tsl.temp[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   tas.temp<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","AnomGlobalmap",sep="."))
   tas.temp<-tas.temp[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   SnowMask<-get(paste(MODEL.V[i],"SnowMask",sep="."))
   SnowMask<-SnowMask[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   #image.plot(SnowMask)
   ratio<-tsl.temp / tas.temp
   #ratio[SnowMask==FALSE]<-NA
   ratio[ratio>1.5]<- 1.5
   image(x,y,ratio,xaxt="n",zlim=c(0,1.5),yaxt="n",col=tim.colors(),main=MODEL.V[i]) 
   box(lwd=1)
   contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")
 }  
 plot.new()
 plot.new()
 par(oma=c(0,0,0,4))# reset margin to be much smaller.
 image.plot(legend.only=TRUE, zlim=c(0,1.5),legend.width=4.6) 
}
dev.off()

#Plot map of historic air temp minus soil temp
jpeg(paste("C:/Users/Claire/Documents/LBL/Figures/HistoricAirSoilTempDifference.jpg",sep=""),width=1000, height=768,res=200,quality=100)
{par(oma=c(1,1,1,1),mar=c(0,0.5,1.5,0))
 layout(rbind(c(1,2,3,4,17),
              c(5,6,7,8,17),
              c(9,10,11,12,17),
              c(13,14,15,16,17)))
 
 for (i in 1: length(MODEL.V)){
   File<-paste("F:/wd/",MODEL.V[i],"/",MODEL.V[i],"_ocean-mask.nc",sep="")
   Land.nc<-open.nc(File)
   NLON=dim.inq.nc(Land.nc,"lon")$length
   NLAT=dim.inq.nc(Land.nc,"lat")$length
   Land<-var.get.nc(Land.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,1,1))
   x<-var.get.nc(Land.nc,"lon",start=c(1),count=c(NLON))
   y<-var.get.nc(Land.nc,"lat",start=c(1),count=c(NLAT))
   Land[Land>0]<-1
   Land[is.na(Land)]<-0
   Land<-Land[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   
   tsl.temp<-get(paste(MODEL.V[i],REAL,"tsl","HistAbsolutemap",sep="."))[,,"0.01m"]
   tsl.temp<-tsl.temp[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   tas.temp<-get(paste(MODEL.V[i],REAL,"tas","HistAbsolutemap",sep="."))
   tas.temp<-tas.temp[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   difference<-tas.temp - tsl.temp
   image(x,y,difference,xaxt="n",zlim=c(-15,10),yaxt="n",col=tim.colors(),main=MODEL.V[i]) 
   box(lwd=1)
   contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")
 }  
 plot.new()
 plot.new()
 par(oma=c(0,0,0,4))# reset margin to be much smaller.
 image.plot(legend.only=TRUE, zlim=c(-15,10),legend.width=4.6) 
}
dev.off()

# Soil warming minus air warming vs damping and vs historic air-soil
dev.off()
par(mfrow=c(7,2),mar=c(0,0,0,0), oma=c(5,8,2,8), tck=0.03, mgp=c(2,0.5,0))
SOColors=c("cyan","lightsalmon2","orange","forest green","green")
SONums=c(4,10,8,12,13)
for (i in 1:length(MODEL.V)){
  tslAnom<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","AnomGlobalmap",sep="."))[,,"0.01m"]
  tasAnom<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","AnomGlobalmap",sep="."))
  tsl.minus.tas.anom<-tslAnom-tasAnom
  ASWR<-tslAnom/tasAnom
  SO<-get(paste(MODEL.V[i],REAL,"DampingDepth",sep="."))[,,3]
  tslHist.1m<-get(paste(MODEL.V[i],REAL,"tsl","HistAbsolutemap",sep="."))[,,"1m"]
  tslHist.1cm<-get(paste(MODEL.V[i],REAL,"tsl","HistAbsolutemap",sep="."))[,,"0.01m"]
  tasHist<-get(paste(MODEL.V[i],REAL,"tas","HistAbsolutemap",sep="."))
  tsl.minus.tas.Hist<-tslHist.1cm-tasHist
  tasHist<-tasHist-273.15
  #plot(ASWR~tasHist, pch=16, ylab="Ratio of soil to air warming", xlab="MAAT", ylim=c(0,2.2),xlim=c(-25,33),xaxt="n",yaxt="n", cex.axis=1.2)
  plot(tsl.minus.tas.Hist~tasHist, pch=16, ylab="Ratio of soil to air warming", xlab="MAAT", ylim=c(-5,18),xlim=c(-25,33),xaxt="n",yaxt="n", cex.axis=1.6)
  box(lwd=2)
  abline(v=0, col="grey")
  abline(h=0, col="grey")
  #abline(h=0, col="grey")
  if(i %in% c(13,14)) axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6) else  axis(side=1,labels=FALSE,lwd=2)
  if(i %in% c(seq(2,14,2))){axis(side=2,labels=FALSE,lwd=2)} else {axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6)}
  
  #plot(ASWR~tas.minus.tsl.Hist, pch=1, ylab="", xlab="", col="black", ylim=c(0,5),xlim=c(-20,5), xaxt="n", cex.axis=1.2)
  text(15,11.5,as.character(MODEL.V[i]),cex=1.4, adj=c(0.5,0))
}
TempObs<-read.csv("F:/Observations/Observations_SoilTempMetrics.csv")
dim(TempObs);names(TempObs)
plot(Toffset.1cm~TA.Mean,data=TempObs,ylim=c(-5,18),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", cex.axis=1.2)
box(lwd=2)
abline(v=0, col="grey")
abline(h=0, col="grey")
axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6)
axis(side=2,labels=TRUE,lwd=2)
text(10,11.5,"Observations, 1994-2013",cex=1.4, adj=c(0.5,0))

mtext("Soil - Air Offset, 1986-2005",side=2,line=2.5,cex=1.4,outer=TRUE)
mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.4, outer=TRUE)

plot(Toffset.1cm~TA.Mean,data=TempObs,ylim=c(-5,18),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", cex.axis=1.2)
box(lwd=2)
abline(v=0, col="grey")
abline(h=0, col="grey")
axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6)
axis(side=2,labels=TRUE,lwd=2)
text(10,11.5,"Observations, 1994-2013",cex=1.4, adj=c(0.5,0))

mtext("Soil - Air Offset, 1986-2005",side=2,line=2.5,cex=1.4,outer=TRUE)
mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.4, outer=TRUE)


### Plot change in Toff from historic to end of century ##
par(mfrow=c(7,2),mar=c(0,0,0,0), oma=c(5,8,2,8), tck=0.03, mgp=c(2,0.5,0))
for (i in 1:length(MODEL.V)){
  tslAnom.1cm<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","AnomGlobalmap",sep="."))[,,"0.01m"]
  tslAnom.1m<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","AnomGlobalmap",sep="."))[,,"1m"]
  tasAnom<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","AnomGlobalmap",sep="."))
  tsl.minus.tas.anom<-tslAnom.1cm-tasAnom
  SO<-get(paste(MODEL.V[i],REAL,"DampingDepth",sep="."))[,,3]
  tslHist.1m<-get(paste(MODEL.V[i],REAL,"tsl","HistAbsolutemap",sep="."))[,,"1m"]
  tslHist.1cm<-get(paste(MODEL.V[i],REAL,"tsl","HistAbsolutemap",sep="."))[,,"0.01m"]
  tasHist<-get(paste(MODEL.V[i],REAL,"tas","HistAbsolutemap",sep="."))
  tsl.minus.tas.Hist<-tslHist.1m-tasHist
  tsl.minus.tas.EOC<-(tslHist.1m+tslAnom.1m)-(tasHist+tasAnom)
  tasEOC<-tasAnom+tasHist-273.15
  tasHist<-tasHist-273.15
  
  plot(tsl.minus.tas.Hist~tasHist, pch=16, ylab="", xlab="", ylim=c(-5,18),xlim=c(-25,38),cex.axis=1.6,type="n",xaxt="n",yaxt="n")
  segments(tasHist,tsl.minus.tas.Hist,tasEOC,tsl.minus.tas.EOC)
  #Color gelisols blue, forests green, aridisols orange
  segments(tasHist[which(SO==4)],tsl.minus.tas.Hist[which(SO==4)],tasEOC[which(SO==4)],tsl.minus.tas.EOC[which(SO==4)],col="blue")
  segments(tasHist[which(SO==13)],tsl.minus.tas.Hist[which(SO==13)],tasEOC[which(SO==13)],tsl.minus.tas.EOC[which(SO==13)],col="forest green")
  segments(tasHist[which(SO==12)],tsl.minus.tas.Hist[which(SO==12)],tasEOC[which(SO==12)],tsl.minus.tas.EOC[which(SO==12)],col="orange")
  box(lwd=2)
  abline(v=0, col="grey")
  abline(h=0, col="grey")
  #abline(h=0, col="grey")
  if(i %in% c(13,14)) axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6) else  axis(side=1,labels=FALSE,lwd=2)
  if(i %in% c(seq(2,14,2))){axis(side=2,labels=FALSE,lwd=2)} else {axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6)}
  text(-20,13.5,as.character(MODEL.V[i]),cex=1.4, adj=c(0,0))
  if(i==2){legend(x="topright",legend=c("Gelisol","Mollisol","Alfisol"),col=c("blue","orange","forest green"),pch=NA,lty=1,bty="n")}
}
mtext(expression(T[offset]),side=2,line=2.5,cex=1.4,outer=TRUE)
mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.4, outer=TRUE)

#image.plot(SO)
#dev.off()

### Plot change in Tatten from historic to end of century ##
par(mfrow=c(7,2),mar=c(0,0,0,0), oma=c(5,8,2,8), tck=0.03, mgp=c(2,0.5,0))
for (i in 1:length(MODEL.V)){
  EOCAmp.1cm<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCAmplitudemap",sep="."))[,,"0.01m"]
  EOCAmp.1m<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCAmplitudemap",sep="."))[,,"1m"]
  EOCAmp.tas<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","EOCAmplitudemap",sep="."))
  HistAmp.1cm<-get(paste(MODEL.V[i],REAL,"tsl","HistAmplitudemap",sep="."))[,,"0.01m"]
  HistAmp.1m<-get(paste(MODEL.V[i],REAL,"tsl","HistAmplitudemap",sep="."))[,,"1m"]
  HistAmp.tas<-get(paste(MODEL.V[i],REAL,"tas","HistAmplitudemap",sep="."))
  
  HistAtten.1m<-HistAmp.1m/HistAmp.1cm
  HistAtten.1cm<-HistAmp.1cm/HistAmp.tas
  EOCAtten.1m<-EOCAmp.1m/EOCAmp.1cm
  EOCAtten.1cm<-EOCAmp.1cm/EOCAmp.tas
  
  tasHist<-get(paste(MODEL.V[i],REAL,"tas","HistAbsolutemap",sep="."))
  tasHist<-tasHist-273.15
  
  tasAnom<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","AnomGlobalmap",sep="."))
  tasEOC<-tasHist+tasAnom
  
  SO<-get(paste(MODEL.V[i],REAL,"DampingDepth",sep="."))[,,3]
  
  plot(HistAtten.1cm~tasHist, pch=16, ylab=expression(T[atten]), xlab="MAAT", ylim=c(0,2.5),xlim=c(-25,38),cex.axis=1.6,xaxt="n",yaxt="n",type="l")
  segments(tasHist,HistAtten.1cm,tasEOC,EOCAtten.1cm,col="black")
  #Color gelisols blue, forests green, aridisols orange
  segments(tasHist[which(SO==4)],HistAtten.1cm[which(SO==4)],tasEOC[which(SO==4)],EOCAtten.1cm[which(SO==4)],col="blue")
  segments(tasHist[which(SO==13)],HistAtten.1cm[which(SO==13)],tasEOC[which(SO==13)],EOCAtten.1cm[which(SO==13)],col="forest green")
  segments(tasHist[which(SO==12)],HistAtten.1cm[which(SO==12)],tasEOC[which(SO==12)],EOCAtten.1cm[which(SO==12)],col="orange")
  box(lwd=2)
  
  #if(i==2){legend(x="topright",legend=c("Gelisol","Mollisol","Alfisol"),col=c("blue","orange","forest green"),pch=NA,lty=1,bty="n")}
           
  box(lwd=2)
  abline(v=0, col="grey")
  abline(h=1, col="grey")
  #abline(h=0, col="grey")
  if(i %in% c(13,14)) axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6) else  axis(side=1,labels=FALSE,lwd=2)
  if(i %in% c(seq(2,14,2))){axis(side=2,labels=FALSE,lwd=2)} else {axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6)}
  if(i==9) text(-20,0.5,as.character(MODEL.V[i]),cex=1.4, adj=c(0,0)) else text(-20,1.8,as.character(MODEL.V[i]),cex=1.4, adj=c(0,0))
}
mtext(expression(T[atten]),side=2,line=2.5,cex=1.4,outer=TRUE)
mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.4, outer=TRUE)



  for(j in 1:2){
    points(tas.minus.tsl.Hist[which(SO==SONums[j])],ASWR[which(SO==SONums[j])],pch=16,col=SOColors[j])
  abline(h=1, col="grey")
  if(i<13) axis(side=1, labels=FALSE) else {
    axis(side=1, labels=TRUE, cex.axis=1.2)
    mtext("MAAT - MAST, 1986-2005", side=1, line=2)}
  
  if(exists(paste(MODEL.V[i],XP.V[m],REAL,"mrlsl","AnomGlobalmap",sep="."))){
    mrlslAnom<-get(paste(MODEL.V[i],XP.V[m],REAL,"mrlsl","AnomGlobalmap",sep="."))[,,"0.1m"]
    plot(ASWR~mrlslAnom, pch=1, ylab="", xlab="", col="black", ylim=c(0,5),xlim=c(-70,70), xaxt="n",yaxt="n", cex.axis=1.2)
    axis(side=2, labels=FALSE)
    for(j in 1:2){
      points(mrlslAnom[which(SO==SONums[j])],ASWR[which(SO==SONums[j])],pch=16,col=SOColors[j])
    }
    abline(h=1, col="grey")
    abline(v=0, col="grey")
    if(i==1) legend("topleft",legend=c("Gelisol","Aridisol"),pch=16, col=c("cyan","lightsalmon2"))
    if(i<13) axis(side=1, labels=FALSE) else {
      axis(side=1, labels=TRUE, cex.axis=1.2)
      mtext(expression(symbol(D)~Moisture~group("(",kg~m^{-3},")")), side=1, line=2)}
    plot.new()
  } else {plot.new(); plot.new()}
#   plot(tsl.minus.tas.Hist~damp)
#   text(6,7,MODEL.V[i], cex=1.4)
#   abline(h=0, col="grey")
#   if(i<5) axis(side=1, labels=FALSE) else {
#     axis(side=1, labels=TRUE, cex.axis=1.2)
#     mtext("Damping depth (m)", side=1, line=2)}
}  
mtext("Air/Soil Warming Ratio, RCP8.5",side=2,line=2,outer=TRUE)

# # Soil surf temp minus air temp, historic
# par(mfrow=c(2,3),mar=c(1,1,3,1), oma=c(1,1,4,1))
# for (i in 1: length(MODEL.V)){
#   tsl.temp<-get(paste(MODEL.V[i],REAL,"tsl","HistAbsolutemap",sep="."))[,,"0.01m"]
#   tas.temp<-get(paste(MODEL.V[i],REAL,"tas","HistAbsolutemap",sep="."))
#   tsl.minus.tas.HistAbs<-tsl.temp-tas.temp
#   image.plot(tsl.minus.tas.HistAbs,xaxt="n",zlim=c(-5,17),yaxt="n",main=MODEL.V[i]) 
#   box(lwd=1)
# }  
# # Soil deep temp minus air temp, historic
# par(mfrow=c(2,3),mar=c(1,1,3,1), oma=c(1,1,4,1))
# for (i in 1: length(MODEL.V)){
#   tsl.temp<-get(paste(MODEL.V[i],REAL,"tsl","HistAbsolutemap",sep="."))[,,"1m"]
#   tas.temp<-get(paste(MODEL.V[i],REAL,"tas","HistAbsolutemap",sep="."))
#   tsl.minus.tas.HistAbs<-tsl.temp-tas.temp
#   image.plot(tsl.minus.tas.HistAbs,xaxt="n",zlim=c(-5,17),yaxt="n",main=MODEL.V[i]) 
#   box(lwd=1)
# }
# 
# # Damping depth, historic
# par(mfrow=c(2,3),mar=c(1,1,3,1), oma=c(1,1,4,1))
# for (i in 1: length(MODEL.V)){
#   damp<-get(paste(MODEL.V[i],REAL,"DampingDepth",sep="."))[,,1]
#   image.plot(damp,xaxt="n",yaxt="n",main=MODEL.V[i]) #zlim=c(-5,17),
#   box(lwd=1)
# } 
# 
# # Damping depth by soil order
# par(mfrow=c(2,3),mar=c(5,1,3,1), oma=c(1,1,4,1))
# for (i in 1: length(MODEL.V)){
#   if(MODEL.V[i]=="CanESM2") {YLim<-c(0,47)} else YLim<-c(0,7)
#   damp<-get(paste(MODEL.V[i],REAL,"DampingDepth",sep="."))
#   plot(damp[,,1]~damp[,,3],main=MODEL.V[i], ylim=YLim, xaxt="n", xlab="") 
#   axis(side=1,labels=FALSE)
#   text(seq(2,by=1,length.out=14),par("usr")[3]-0.25,srt=45,adj=1,labels=SOIL, xpd=TRUE)
# } 
# 
# dev.off()
# par(mfrow=c(2,3),mar=c(1,1,3,1), oma=c(1,1,4,1))
# for (i in 1: length(MODEL.V)){
#   damp<-get(paste(MODEL.V[i],REAL,"DampingDepth",sep="."))[,,2]
#   image.plot(damp,xaxt="n",zlim=c(-10,10),yaxt="n",main=MODEL.V[i]) 
#   box(lwd=1)
# } 
# 


# Soil moisture
par(mfrow=c(2,3),mar=c(1,1,3,1), oma=c(1,1,4,1))
for (i in 1: length(MODEL.V)){
  file<-paste(MODEL.V[i],XP.V[m],REAL,"mrlsl","AnomGlobalmap",sep=".")
  if (exists(file)){
  mrlsl.temp<-get(file)
  image.plot(mrlsl.temp[,,"0.01m"],xaxt="n",yaxt="n",main=MODEL.V[i],zlim=c(-1,1))
  box(lwd=1)} else next
}  



} #End XP loop

## Plot ensemble figures ##
# EOC soil warming anomaly
File="F:/wd/Ensemble/tsl_Ensemble_rcp85_Map_2080-2100_1x1_EnsMean.nc"
tslEOC.EnsMean.nc<-open.nc(File)
# Just get 3 layers, don't need all
NZ=1 #dim.inq.nc(tslEOC.EnsMean.nc,"depth")$length
NLON=dim.inq.nc(tslEOC.EnsMean.nc,"lon")$length
NLAT=dim.inq.nc(tslEOC.EnsMean.nc,"lat")$length
tslEOC.EnsMean<-var.get.nc(tslEOC.EnsMean.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,NZ,1))
close.nc(tslEOC.EnsMean.nc)
tslEOC.EnsMean<-tslEOC.EnsMean[c(((NLON/2+1):NLON),(1:(NLON/2))),]
#dev.off()
#image.plot(tslEOC.EnsMean,zlim=c(0,10)) 

File="F:/wd/Ensemble/tas_Ensemble_rcp85_Map_2080-2100_1x1_EnsMean.nc"
tasEOC.EnsMean.nc<-open.nc(File)
NLON=dim.inq.nc(tasEOC.EnsMean.nc,"lon")$length
NLAT=dim.inq.nc(tasEOC.EnsMean.nc,"lat")$length
tasEOC.EnsMean<-var.get.nc(tasEOC.EnsMean.nc,"tas",start=c(1,1,1),count=c(NLON,NLAT,1))
close.nc(tasEOC.EnsMean.nc)
tasEOC.EnsMean<-tasEOC.EnsMean[c(((NLON/2+1):NLON),(1:(NLON/2))),]
image.plot(tasEOC.EnsMean,zlim=c(0,10)) 

File="F:/wd/Ensemble/tsl_Ensemble_rcp85_Map_2080-2100_1x1_EnsStd.nc"
tslEOC.EnsStd.nc<-open.nc(File)
# Just get 3 layers, don't need all
NZ=1 #dim.inq.nc(tslEOC.EnsStd.nc,"depth")$length
NLON=dim.inq.nc(tslEOC.EnsStd.nc,"lon")$length
NLAT=dim.inq.nc(tslEOC.EnsStd.nc,"lat")$length
tslEOC.EnsStd<-var.get.nc(tslEOC.EnsStd.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,NZ,1))
close.nc(tslEOC.EnsStd.nc)
tslEOC.EnsStd<-tslEOC.EnsStd[c(((NLON/2+1):NLON),(1:(NLON/2))),]
dev.off()
image.plot(tslEOC.EnsStd) 

File<-"G:/wd/Ensemble/OceanMask_1x1.nc"
Land.nc<-open.nc(File)
NLON=dim.inq.nc(Land.nc,"lon")$length
NLAT=dim.inq.nc(Land.nc,"lat")$length
Land<-var.get.nc(Land.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,1,1))
x<-var.get.nc(Land.nc,"lon",start=c(1),count=c(NLON))
y<-var.get.nc(Land.nc,"lat",start=c(1),count=c(NLAT))
Land[Land>0]<-1
Land[is.na(Land)]<-0
Land<-Land[c(((NLON/2+1):NLON),(1:(NLON/2))),]


library(RColorBrewer)
WarmingRatio<-tslEOC.EnsMean/tasEOC.EnsMean

image.plot(x,y,tasEOC.EnsMean,xaxt="n",zlim=c(0,10),yaxt="n",col=brewer.pal(16,"YlOrRd"),xlab="",ylab="", main="Air Warming (degrees C)") #tim.colors()
box(lwd=1)
contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")

image.plot(x,y,tslEOC.EnsMean,xaxt="n",zlim=c(0,10),yaxt="n",col=brewer.pal(16,"YlOrRd"),xlab="",ylab="", main="Soil Warming (degrees C)") #tim.colors()
box(lwd=1)
contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")

image.plot(x,y,WarmingRatio,xaxt="n",zlim=c(0.2,1.8),yaxt="n",col=brewer.pal(11,"Spectral"),xlab="",ylab="", main="Soil/Air Warming Ratio") 
box(lwd=1)
contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")

# Plot ensemble temperature advancements
#Difference between soil and air temp advancement
File="G:/wd/SeasonAdvance/diffAdvance_1x1_EnsMean.nc"
diffAdvance.EnsMean.nc<-open.nc(File)
NLON=dim.inq.nc(diffAdvance.EnsMean.nc,"lon")$length
NLAT=dim.inq.nc(diffAdvance.EnsMean.nc,"lat")$length
diffAdvance.EnsMean<-var.get.nc(diffAdvance.EnsMean.nc,"DOY",start=c(1,1),count=c(NLON,NLAT))
close.nc(diffAdvance.EnsMean.nc)
diffAdvance.EnsMean<-diffAdvance.EnsMean* -1
diffAdvance.EnsMean<-diffAdvance.EnsMean[c(((NLON/2+1):NLON),(1:(NLON/2))),]
diffAdvance.EnsMean[diffAdvance.EnsMean< -20]<- -20
diffAdvance.EnsMean[diffAdvance.EnsMean>20]<-20



image.plot(x,y,diffAdvance,zlim=c(-20,20),xaxt="n",yaxt="n",col=brewer.pal(11,"Spectral"),xlab="",ylab="", main="Soil Advancement - Air Advancement Difference") 
box(lwd=1)
contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")

#####
# Get model mean and sd for temp advancement 
DiffAdvance.sum<-data.frame(model=MODEL.V)


for (m in 1:length(MODEL.V)){
  File=paste("G:/wd/SeasonAdvance/",MODEL.V[m],"_diffAdvance.nc",sep="")
  
  diffAdvance.nc<-open.nc(File)
  NLON=dim.inq.nc(diffAdvance.nc,"lon")$length
  NLAT=dim.inq.nc(diffAdvance.nc,"lat")$length
  diffAdvance<-var.get.nc(diffAdvance.nc,"DOY",start=c(1,1),count=c(NLON,NLAT))
  close.nc(diffAdvance.nc)
  diffAdvance<-diffAdvance* -1
  diffAdvance<-diffAdvance[c(((NLON/2+1):NLON),(1:(NLON/2))),]
  diffAdvance[diffAdvance< -20]<- -20
  diffAdvance[diffAdvance>20]<-20
  DiffAdvance.sum[m,"Mean"]<-mean(diffAdvance, na.rm=TRUE)
  DiffAdvance.sum[m,"SD"]<-sd(diffAdvance, na.rm=TRUE)
}

write.csv(DiffAdvance.sum,file="G:/wd/SeasonAdvance/MeanAdvacement.csv" )

#Air temp advancement
dev.off()
File="F:/wd/SeasonAdvance/tasAdvance_1x1_EnsMean.nc"
tasAdvance.EnsMean.nc<-open.nc(File)
NLON=dim.inq.nc(tasAdvance.EnsMean.nc,"lon")$length
NLAT=dim.inq.nc(tasAdvance.EnsMean.nc,"lat")$length
tasAdvance.EnsMean<-var.get.nc(tasAdvance.EnsMean.nc,"DOY",start=c(1,1),count=c(NLON,NLAT))
close.nc(tasAdvance.EnsMean.nc)
tasAdvance.EnsMean<-tasAdvance.EnsMean* -1
tasAdvance.EnsMean<-tasAdvance.EnsMean[c(((NLON/2+1):NLON),(1:(NLON/2))),]
tasAdvance.EnsMean[tasAdvance.EnsMean< -40]<- -40
tasAdvance.EnsMean[tasAdvance.EnsMean>40]<-40
image.plot(x,y,tasAdvance.EnsMean,zlim=c(0,40),xaxt="n",yaxt="n",col=brewer.pal(9,"YlOrRd"),xlab="",ylab="", main="Air") #
box(lwd=1)
contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")

#Soil temp advancement
File="F:/wd/SeasonAdvance/tslAdvance_1x1_EnsMean.nc"
tslAdvance.EnsMean.nc<-open.nc(File)
NLON=dim.inq.nc(tslAdvance.EnsMean.nc,"lon")$length
NLAT=dim.inq.nc(tslAdvance.EnsMean.nc,"lat")$length
tslAdvance.EnsMean<-var.get.nc(tslAdvance.EnsMean.nc,"DOY",start=c(1,1),count=c(NLON,NLAT))
close.nc(tslAdvance.EnsMean.nc)
tslAdvance.EnsMean<-tslAdvance.EnsMean[c(((NLON/2+1):NLON),(1:(NLON/2))),]
tslAdvance.EnsMean<-tslAdvance.EnsMean* -1
tslAdvance.EnsMean[tslAdvance.EnsMean< -40]<- -40
tslAdvance.EnsMean[tslAdvance.EnsMean>40]<-40
image.plot(x,y,tslAdvance.EnsMean,zlim=c(0,40),xaxt="n",yaxt="n",col=brewer.pal(9,"YlOrRd"),xlab="",ylab="", main="Soil") #
box(lwd=1)
contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")

File="F:/wd/SeasonAdvance/diffAdvance_1x1_EnsMean.nc"
diffAdvance.EnsMean.nc<-open.nc(File)
NLON=dim.inq.nc(diffAdvance.EnsMean.nc,"lon")$length
NLAT=dim.inq.nc(diffAdvance.EnsMean.nc,"lat")$length
diffAdvance.EnsMean<-var.get.nc(diffAdvance.EnsMean.nc,"DOY",start=c(1,1),count=c(NLON,NLAT))
close.nc(diffAdvance.EnsMean.nc)
diffAdvance.EnsMean<-diffAdvance.EnsMean[c(((NLON/2+1):NLON),(1:(NLON/2))),]
diffAdvance.EnsMean<-diffAdvance.EnsMean* -1
#tslAdvance.EnsMean[tslAdvance.EnsMean< -40]<- -40
#tslAdvance.EnsMean[tslAdvance.EnsMean>40]<-40
image.plot(x,y,diffAdvance.EnsMean,xaxt="n",yaxt="n",zlim=c(-20,20),col=brewer.pal(11,"Spectral"),xlab="",ylab="", main="Difference Between Soil and Air") #
box(lwd=1)
contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")
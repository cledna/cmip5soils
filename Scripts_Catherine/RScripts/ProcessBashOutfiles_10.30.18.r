
rm(list=ls())
library(RNetCDF)
library(ncdf4)
library(fields)
library(abind)

### Final tables for each variable (tas, tsl, mrlsl if available)
# 1) EOCmean.arr has EOC means for global, soil order, and zones
# 2) Annualts.arr has 21st century timeseries for global, soil order, and zones
# 3) LatZone.arr has lat EOC mean temp change for several soil orders
# 4) LatZone.interp.global has lat EOC mean global change, interpolated to each lat degree
# 5) ZoneMonthly.arr has monthly historic and EOC temperatures for mollisol and other example zones for diverse soil orders
# 6) Map of 2081-2100 average (AnomGlobalMap)
# One set of the following tables for temp only
# 7) Map of actual air and soil temp, 1986-2005 (HistAbsolutemap)
# 8) Map of air and soil temp annual amplitude (HistAmplitudemap)
# 9) Map of damping depth, calculated from air and top soil layer, as well as from soil layers 1 and 2.


### COMPLETE THE FOLLOWING BEFORE RUNNING ###
MODEL=c("bcc-csm1-1","BNU-ESM","CanESM2","CCSM4","CESM1-BGC","GFDL-ESM2G","GISS-E2-R","HadGEM2-ES","inmcm4","IPSL-CM5A-LR","MIROC5","MPI-ESM-LR","MRI-CGCM3","NorESM1-M") 

XP=c("rcp45","rcp85")
REAL="r1i1p1" # Except CCSM4
XPSTART=200601
XPEND=210012
YEARRANGE<-2006:2100

DIR0="/Volumes/cmip5_soils/regridcmip5soildata"
DIR="/Volumes/cmip5_soils/regridcmip5soildata/OUT3"
OUT="/Volumes/cmip5_soils/regridcmip5soildata/Analysis"

SOIL<-c("Rock", "ShiftingSand", "Gelisol","Histosol","Spodosol","Andisol","Oxisol","Vertisol","Aridisol","Ultisol","Mollisol","Alfisol","Inceptisol","Entisol")
LATZONE=c("Alfisol","Andisol","Aridisol","Gelisol","Inceptisol","Mollisol")
ZONE=c("GreatPlains","PampasPlain","EurasianSteppe","ChinaMoll") # removed others

#Import historical era stuff
par(mfrow=c(3,5),mar=c(0,0,0,0),oma=c(5,5,1,4), tck=0.03, mgp=c(2,0.5,0))


for(d in 1:length(MODEL)){
  if (MODEL[d]=="CCSM4") REAL <-"r2i1p1" else REAL <- "r1i1p1"
  
  WD=paste(DIR,MODEL[d],sep="/")
  
  ## TODO Omit Great Plains for now
  # Omitting mesonet data 
  
}
## TAS
for(d in 1:length(MODEL)){
  WD=paste(DIR,MODEL[d],sep="/")
  if(MODEL[d]=="CCSM4") REAL<-"r2i1p1" else REAL<-"r1i1p1"
  for(x in 1:2){ #loop through XP[x]s
    par(mfrow=c(3,5),mar=c(0,0,0,0),oma=c(5,5,1,4), tck=0.03, mgp=c(2,0.5,0))
   # pdf(paste(DIR0,"/Rdata/Figures/",MODEL[d],".",XP[x],"tasFigs.pdf",sep=""))
    print(MODEL[d], x)
    
    ## 2D OUTPUT (TAS) ###
    VAR="tas"
    REALM="Amon" 
    
    ## ANOMALY TIMESERIES, ANNUAL AVGS
    #If a file is missing (i.e. experiment rcp4.5 is missing for GISS) skip to next loop
    allfiles<-list.files(WD)
    if(!paste(VAR,"_",MODEL[d],"_",XP[x],"_",XPSTART,"-",XPEND,"_anom_global_ts.nc",sep="") %in% allfiles) next()
    
    File=paste(WD,"/",VAR,"_",MODEL[d],"_",XP[x],"_",XPSTART,"-",XPEND,"_anom_global_ts.nc",sep="")
    AnomGlobalts.nc<-open.nc(File)
    #print.nc(AnomGlobalts.nc)
    YEARS=dim.inq.nc(AnomGlobalts.nc,"time")$length
    var.get.nc(AnomGlobalts.nc,"time")
    AnomGlobalts<-var.get.nc(AnomGlobalts.nc,VAR,start=c(1,1,1),count=c(1,1,YEARS))
    close.nc(AnomGlobalts.nc)
    
    #Set up arrays to hold results
    Annualts.arr<-array(data=NA,dim=c(length(SOIL)+length(ZONE)+1,YEARS),dimnames=list(c("Global",SOIL,ZONE),YEARRANGE))
    Annualts.arr[1,]<-AnomGlobalts #Put the global timeseries in column 1
    
    ## 2081-2100 GLOBAL MEAN DELTA
    File=paste(WD,"/",VAR,"_",MODEL[d],"_",XP[x],"_GlobalMean_2081-2100_NoIce.nc",sep="")
    AnomGlobalmean.nc<-open.nc(File)
    #print.nc(AnomGlobalmean.nc)
    AnomGlobalmean<-var.get.nc(AnomGlobalmean.nc,VAR,start=c(1,1,1),count=c(1,1,1))
    close.nc(AnomGlobalmean.nc)
    
    EOCmean.arr<-array(data=NA,dim=c(length(SOIL)+length(ZONE)+1),dimnames=list(c("Global",SOIL,ZONE)))
    EOCmean.arr[1]<-AnomGlobalmean
    
    ## 2081-2100 MAP DELTA
    File=paste(WD,"/",VAR,"_",MODEL[d],"_",XP[x],"_Map_2081-2100_NoIce.nc",sep="")
    AnomGlobalmap.nc<-open.nc(File)
    #print.nc(AnomGlobalmap.nc)
    NLON=dim.inq.nc(AnomGlobalmap.nc,"lon")$length
    NLAT=dim.inq.nc(AnomGlobalmap.nc,"lat")$length
    AnomGlobalmap<-var.get.nc(AnomGlobalmap.nc,VAR,start=c(1,1,1),count=c(NLON,NLAT,1))
    image.plot(AnomGlobalmap)
    title("2081-2100 Global Delta Tas")
    close.nc(AnomGlobalmap.nc)
    
    ## 1986-2005 MAP ABSOLUTE
    File=paste(WD,"/",VAR,"_",MODEL[d],"_198601-200512_meanannual.nc",sep="")
    HistAbsolutemap.nc<-open.nc(File)
    #print.nc(HistAbsolutemap.nc)
    NLON=dim.inq.nc(HistAbsolutemap.nc,"lon")$length
    NLAT=dim.inq.nc(HistAbsolutemap.nc,"lat")$length
    HistAbsolutemap<-var.get.nc(HistAbsolutemap.nc,VAR,start=c(1,1,1),count=c(NLON,NLAT,1))
    image.plot(HistAbsolutemap)
    title("1986-2005 Abs Tas")
    close.nc(HistAbsolutemap.nc)
    
    
    ## 1986-2005 MAP TAS AMPLITUDE
    File=paste(WD,"/",VAR,"_",MODEL[d],"_198601-200512_amplitude.nc",sep="")
      HistAmplitudemap.nc<-open.nc(File)
      #print.nc(HistAbsolutemap.nc)
      NLON=dim.inq.nc( HistAmplitudemap.nc,"lon")$length
      NLAT=dim.inq.nc( HistAmplitudemap.nc,"lat")$length
      HistAmplitudemap<-var.get.nc(HistAmplitudemap.nc,VAR,start=c(1,1,1),count=c(NLON,NLAT,1))
      image.plot(HistAmplitudemap)
      title("1986-2005 tas amplitude")
      close.nc(HistAmplitudemap.nc)
    
  #dev.off()
    
    # CL 8/20/18 Not in bash scripts anymore
    # ## 2081-2100 MAP TAS AMPLITUDE
    # File=paste(WD,"/",VAR,"_",MODEL[d],"_",XP[x],"_208101-210012_land_NoIce_amplitude.nc",sep="")
    # EOCAmplitudemap.nc<-open.nc(File)
    # #print.nc(HistAbsolutemap.nc)
    # NLON=dim.inq.nc(EOCAmplitudemap.nc,"lon")$length
    # NLAT=dim.inq.nc(EOCAmplitudemap.nc,"lat")$length
    # EOCAmplitudemap<-var.get.nc(EOCAmplitudemap.nc,VAR,start=c(1,1,1),count=c(NLON,NLAT,1))
    # image.plot(EOCAmplitudemap)
    # close.nc(EOCAmplitudemap.nc)
    
    ## Soil order means ##
    for (s in 1:length(SOIL)){
      print(SOIL[s])
      File=paste(WD,"/",VAR,"_",MODEL[d],"_",XP[x],"_200601-210012_anom_",SOIL[s],"_ts_annual.nc",sep="")
      AnomSoilts.nc<-open.nc(File)
      NT=dim.inq.nc(AnomSoilts.nc,"time")$length
      AnomSoilts<-var.get.nc(AnomSoilts.nc,VAR,start=c(1,1,1),count=c(1,1,NT))
      close.nc(AnomSoilts.nc)
      
      File=paste(WD,"/",VAR,"_",MODEL[d],"_",XP[x],"_GlobalMean_2081-2100_",SOIL[s],".nc",sep="")
      AnomSoilGlobalMean.nc<-open.nc(File)
      AnomSoilGlobalMean<-var.get.nc(AnomSoilGlobalMean.nc,VAR,start=c(1,1,1),count=c(1,1,1))
      close.nc(AnomSoilGlobalMean.nc)
      
      Annualts.arr[(s+1),]<-AnomSoilts
      EOCmean.arr[(s+1)]<-AnomSoilGlobalMean
    }
    
    ### LAT-ZONAL MEANS ##
    LatZone.arr<-array(data=NA,dim=c((length(LATZONE)+1),NLAT),dimnames=list(c("Global",LATZONE),seq(-90,90,length.out=NLAT)))
    #Global zonal mean
    File=paste(WD,"/",VAR,"_",MODEL[d],"_",XP[x],"_latmean_2081-2100_Global.nc",sep="")
    GlobalLatMean.nc<-open.nc(File)
    GlobalLatMean<-var.get.nc(GlobalLatMean.nc,VAR,start=c(1,1,1),count=c(1,NLAT,1))
    LatZone.arr[(1),]<-GlobalLatMean
    close.nc(GlobalLatMean.nc)
    
    #For global, interpolate to same number of lats
    LatZone.global.interp<-array(data=NA,dim=c(180,1),dimnames=list(seq(-90,90,length.out=180),c("0m")))
    LatZone.global.interp<-approx(seq(-90,90,length.out=NLAT),LatZone.arr[1,],seq(-90,90,length.out=180),method="linear",rule=1)$y
    
    print("LATZONE")
    for (k in 1:length(LATZONE)){
      print(LATZONE[k])
      print(k)
      File=paste(WD,"/",VAR,"_",MODEL[d],"_",XP[x],"_latmean_2081-2100_",LATZONE[k],".nc",sep="")
      SoilLatMean.nc<-open.nc(File)
      SoilLatMean<-var.get.nc(SoilLatMean.nc,VAR,start=c(1,1,1),count=c(1,NLAT,1))
      #Replace zeros w NA
      SoilLatMean[SoilLatMean==0]<-NA
      #print(SoilLatMean)
      LatZone.arr[(k+1),]<-SoilLatMean
      close.nc(SoilLatMean.nc)
    }
    
    ### SOIL ORDER ZONES OF INTEREST ###
    ## Historic monthly means
    ZoneMonthly.arr<-array(data=NA,dim=c(length(ZONE),12,2),dimnames=list(ZONE,c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"),c("1986-2005","2081-2100")))
    
    print("ZONE")
    for (j in 1: length(ZONE)){
      print(ZONE[j])
      print(j)
      #Historic monthly temp
      File=paste(WD,"/",VAR,"_",MODEL[d],"_198601-200512_mon_",ZONE[j],".nc",sep="")
      ZoneHistMon.nc<-open.nc(File)
      ZoneHistMon<-var.get.nc(ZoneHistMon.nc,VAR,start=c(1,1,1),count=c(1,1,12))
      ZoneMonthly.arr[j,,1]<-ZoneHistMon
      close.nc(ZoneHistMon.nc)
      
      #EOC monthly temp
      File=paste(WD,"/",VAR,"_",MODEL[d],"_",XP[x],"_2081-2100_mon_",ZONE[j],".nc",sep="")
      ZoneEOCMon.nc<-open.nc(File)
      ZoneEOCMon<-var.get.nc(ZoneEOCMon.nc,VAR,start=c(1,1,1),count=c(1,1,12))
      ZoneMonthly.arr[j,,2]<-ZoneEOCMon
      close.nc(ZoneEOCMon.nc)
      
      #21st C anomaly ts
      File=paste(WD,"/",VAR,"_",MODEL[d],"_",XP[x],"_",XPSTART,"-",XPEND,"_anom_annual_",ZONE[j],".nc",sep="")
      ZoneAnomts.nc<-open.nc(File)
      ZoneAnomts<-var.get.nc(ZoneAnomts.nc,VAR,start=c(1,1,1),count=c(1,1,YEARS))
      Annualts.arr[(j+s+1),]<-ZoneAnomts
      close.nc(ZoneAnomts.nc)
      
      #2081-2100 anomaly mean
      File=paste(WD,"/",VAR,"_",MODEL[d],"_",XP[x],"_2081-2100_anom_region_",ZONE[j],".nc",sep="")
      ZoneAnomTimean.nc<-open.nc(File)
      #print.nc(ZoneAnomTimean.nc)
      ZoneAnomTimean<-var.get.nc(ZoneAnomTimean.nc,VAR,start=c(1,1,1),count=c(1,1,1))
      EOCmean.arr[(j+s+1)]<-ZoneAnomTimean
      close.nc(ZoneAnomTimean.nc)
    }
    
    ## Add the MODEL[d] and VAR name to the arrays and save to WD
    assign(paste(MODEL[d],XP[x],REAL,VAR,"Annualts.arr",sep="."),Annualts.arr)
    assign(paste(MODEL[d],XP[x],REAL,VAR,"EOCmean.arr",sep="."),EOCmean.arr)
    assign(paste(MODEL[d],XP[x],REAL,VAR,"LatZone.arr",sep="."),LatZone.arr)
    assign(paste(MODEL[d],XP[x],REAL,VAR,"LatZone.global.interp",sep="."),LatZone.global.interp)
    assign(paste(MODEL[d],XP[x],REAL,VAR,"ZoneMonthly.arr",sep="."),ZoneMonthly.arr)
    assign(paste(MODEL[d],XP[x],REAL,VAR,"AnomGlobalmap",sep="."),AnomGlobalmap)
    #assign(paste(MODEL[d],XP[x],REAL,VAR,"EOCAmplitudemap",sep="."),EOCAmplitudemap)
    assign(paste(MODEL[d],REAL,VAR,"HistAbsolutemap",sep="."),HistAbsolutemap)
    assign(paste(MODEL[d],REAL,VAR,"HistAmplitudemap",sep="."),HistAmplitudemap)
    
    
    save(list=c(paste(MODEL[d],XP[x],REAL,VAR,c("Annualts.arr","EOCmean.arr","LatZone.arr","LatZone.global.interp","ZoneMonthly.arr","AnomGlobalmap"),sep="."),paste(MODEL[d],REAL,VAR,c("HistAbsolutemap"),sep=".")),file=paste(OUT,"/RData/",MODEL[d],"_",XP[x],"_",REAL,"_",VAR,".RData",sep=""))

  } # End of XP
} # End of models

### For 3D variables (tsl and mrlsl) ###
### Includes linear interpolation of zertical output to 0.01, 0.1 and 1.0 m depth ###

VAR=c("tsl","mrlsl")

for(d in 1:length(MODEL)){
  for(x in 1:2){ #loop through XP[x]s
    for (m in 2:2){ 
      par(mfrow=c(3,5),mar=c(0,0,0,0),oma=c(5,5,1,4), tck=0.03, mgp=c(2,0.5,0))
      #pdf(paste(DIR0,"/Rdata/Figures/",MODEL[d],".",XP[x],".",VAR[m],"Diagnostic.pdf",sep=""))
      print(MODEL[d], x)
      
      if(MODEL[d]=="CCSM4") REAL<-"r2i1p1" else REAL<-"r1i1p1"
      WD=paste(DIR,MODEL[d],sep="/")
      REALM="Lmon"
      
      if(MODEL[d]=="GISS-E2-R" && XP[x]=="rcp45") next()
      
      print(paste("starting",MODEL[d],VAR[m],XP[x]))
      ## ANOMALY TIMESERIES, ANNUAL AVGS
      File=paste(WD,"/",VAR[m],"_",MODEL[d],"_",XP[x],"_",XPSTART,"-",XPEND,"_anom_global_ts.nc",sep="")
      
      #Check to see if the variable exists. If not, print error and break loop.
      Filename<-paste(VAR[m],"_",MODEL[d],"_",XP[x],"_",XPSTART,"-",XPEND,"_anom_global_ts.nc",sep="")
      if(!(Filename %in% list.files(WD))) {message("No mrlsl files"); next()} 
      
      AnomGlobalts.nc<-open.nc(File)
      #print.nc(AnomGlobalts.nc)
      YEARS=dim.inq.nc(AnomGlobalts.nc,"time")$length
      NZ=dim.inq.nc(AnomGlobalts.nc,"depth")$length
      UBND<-var.get.nc(AnomGlobalts.nc,"depth_bnds",start=c(1,1),count=c(1,NZ))
      LBND<-var.get.nc(AnomGlobalts.nc,"depth_bnds",start=c(2,1),count=c(1,NZ))
      THICK<-LBND-UBND
      MDPNT<-apply(X=cbind(UBND,LBND),MARGIN=1,mean)
      DEPTH<-var.get.nc(AnomGlobalts.nc,"depth",start=c(1),count=c(NZ))
      AnomGlobalts<-var.get.nc(AnomGlobalts.nc,VAR[m],start=c(1,1,1,1),count=c(1,1,NZ,YEARS))
      close.nc(AnomGlobalts.nc)
      
      #Convert mrlsl from aereal to volumetric (kg m-3)
      if(m==2){
        THICK.exp<-matrix(data=rep(THICK,each=YEARS),nrow=NZ,ncol=YEARS,byrow=TRUE)
        AnomGlobalts<-AnomGlobalts/THICK.exp
      }  
      
      # Set up arrays to hold 3D results
      Annualts.arr<-array(data=NA,dim=c((length(SOIL)+length(ZONE)+1),NZ+3,YEARS),dimnames=list(c("Global",SOIL,ZONE),paste(c(round(MDPNT,3),0.01,0.1,1.0),"m",sep=""),YEARRANGE))
      Annualts.arr[1,1:NZ,]<-AnomGlobalts
      
      #Interpolate to 0.01, 0.1, and 1.00m
      for (h in 1:YEARS){
        Annualts.arr[1,c(NZ+1,NZ+2,NZ+3),h]<-approx(MDPNT,Annualts.arr[1,1:NZ,h],c(0.01,0.1,1.0),method="linear",rule=2)$y
      }
      
      ## 2081-2100 GLOBAL MEAN
      File=paste(WD,"/",VAR[m],"_",MODEL[d],"_",XP[x],"_GlobalMean_2081-2100_NoIce.nc",sep="")
      AnomGlobalmean.nc<-open.nc(File)
      # print.nc(AnomGlobalmean.nc)
      AnomGlobalmean<-var.get.nc(AnomGlobalmean.nc,VAR[m],start=c(1,1,1,1),count=c(1,1,NZ,1))
      close.nc(AnomGlobalmean.nc)
      
      if(m==2){
        AnomGlobalmean<-AnomGlobalmean/THICK
      } 
      
      EOCmean.arr<-array(data=NA,dim=c(length(SOIL)+length(ZONE)+1,NZ+3),dimnames=list(c("Global",SOIL,ZONE),paste(c(round(MDPNT,3),0.01,0.1,1.00),"m",sep="")))
      
      # Interpolate to 0.01m, 0.1m, and 1m and add to array
      EOCmean.arr[1,]<-c(AnomGlobalmean,approx(MDPNT,AnomGlobalmean,c(0.01,0.1,1.0),method="linear",rule=2)$y) 
      
      ## 2081-2100 MAP DELTA
      File=paste(WD,"/",VAR[m],"_",MODEL[d],"_",XP[x],"_Map_2081-2100_NoIce.nc",sep="")
      AnomGlobalmap.nc<-open.nc(File)
      #print.nc(AnomGlobalmap.nc)
      NLON=dim.inq.nc(AnomGlobalmap.nc,"lon")$length
      NLAT=dim.inq.nc(AnomGlobalmap.nc,"lat")$length
      AnomGlobalmap<-var.get.nc(AnomGlobalmap.nc,VAR[m],start=c(1,1,1,1),count=c(NLON,NLAT,NZ,1))
      image.plot(AnomGlobalmap[,,1]) 
      title("Map 2081-2100")
      close.nc(AnomGlobalmap.nc)
      
      if(m==2){
        THICK.arr<-array(data=rep(THICK,each=NLON*NLAT),dim=c(NLON,NLAT,NZ))
        AnomGlobalmap<-AnomGlobalmap/THICK.arr
      } 
      
      # Add three more depths to z dimension of map array for interpolating to 0.01, 0.1, and 1.0m 
      expand.arr<-array(data=NA, dim=c(NLON,NLAT,3), dimnames=list(seq(0,360,length.out=NLON),seq(-90,90,length.out=NLAT),c("0.01m","0.1m","1m")))
      AnomGlobalmap<-abind(AnomGlobalmap,expand.arr,along=3)
      dimnames(AnomGlobalmap)[[3]]<-c(MDPNT,c("0.01m","0.1m","1m"))
      
      # Interpolate to 0.01m, 0.1m, and 1m and add to array
      for (h in 1:NLON){
        for (i in 1:NLAT){
          if(is.na(AnomGlobalmap[h,i,1])){
            AnomGlobalmap[h,i,(dim(AnomGlobalmap)[3]-2):dim(AnomGlobalmap)[3]]<-c(NA,NA,NA)
          } else{
            temp<-approx(MDPNT,AnomGlobalmap[h,i,1:NZ],c(0.01,0.1, 1.0),method="linear",rule=2)$y
            AnomGlobalmap[h,i,(dim(AnomGlobalmap)[3]-2):dim(AnomGlobalmap)[3]]<-temp
          }
        }
      }
      #image.plot(AnomGlobalmap[,,"0.1m"])
      
      
      ## Historical map, absolute temp/moist
      File=paste(WD,"/",VAR[m],"_",MODEL[d],"_198601-200512_meanannual.nc",sep="")
      HistAbsolutemap.nc<-open.nc(File)
      #print.nc(HistAbsolutemap.nc)
      NLON=dim.inq.nc(HistAbsolutemap.nc,"lon")$length
      NLAT=dim.inq.nc(HistAbsolutemap.nc,"lat")$length
      HistAbsolutemap<-var.get.nc(HistAbsolutemap.nc,VAR[m],start=c(1,1,1,1),count=c(NLON,NLAT,NZ,1))
      close.nc(HistAbsolutemap.nc)
      
      image.plot(HistAbsolutemap[,,1])
      title("198601-200512 mean annual top layer")
      if(m==2){
        THICK.arr<-array(data=rep(THICK,each=NLON*NLAT),dim=c(NLON,NLAT,NZ))
        HistAbsolutemap<-HistAbsolutemap/THICK.arr
      } 
      
      # Add three more depths to z dimension of map array for interpolating to 0.01, 0.1 and 1.0m 
      expand.arr<-array(data=NA, dim=c(NLON,NLAT,3), dimnames=list(seq(0,360,length.out=NLON),seq(-90,90,length.out=NLAT),c("0.01m","0.1m","1m")))
      HistAbsolutemap<-abind(HistAbsolutemap,expand.arr,along=3)
      dimnames(HistAbsolutemap)[[3]]<-c(MDPNT,c("0.01m","0.1m","1m"))
      
      # Interpolate to 0.01m, 0.1, and 1m and add to array
      for (h in 1:NLON){
        for (i in 1:NLAT){
          if(is.na(HistAbsolutemap[h,i,1])){
            HistAbsolutemap[h,i,(dim(HistAbsolutemap)[3]-2):dim(HistAbsolutemap)[3]]<-c(NA,NA,NA)
          } else{
            temp<-approx(MDPNT,HistAbsolutemap[h,i,1:NZ],c(0.01,0.1,1.0),method="linear",rule=2)$y
            HistAbsolutemap[h,i,(dim(HistAbsolutemap)[3]-2):dim(HistAbsolutemap)[3]]<-temp
          }
        }
      }
      image.plot(HistAbsolutemap[,,"0.1m"])
      title("Hist mean annual 0.1m")
     # dev.off()
      ## Global mean for soil orders
      for (s in 1:length(SOIL)){
        File=paste(WD,"/",VAR[m],"_",MODEL[d],"_",XP[x],"_GlobalMean_2081-2100_",SOIL[s],".nc",sep="")
        AnomSoilGlobalMean.nc<-open.nc(File)
        NZ=dim.inq.nc(AnomSoilGlobalMean.nc,"depth")$length
        AnomSoilGlobalMean<-var.get.nc(AnomSoilGlobalMean.nc,VAR[m],start=c(1,1,1,1),count=c(1,1,NZ,1))
        close.nc(AnomSoilGlobalMean.nc)
        
        if(m==2){
          AnomSoilGlobalMean<-AnomSoilGlobalMean/THICK
        } 
        
        ## Time series
        File=paste(WD,"/",VAR[m],"_",MODEL[d],"_",XP[x],"_200601-210012_anom_",SOIL[s],"_ts_annual.nc",sep="")
        AnomSoilts.nc<-open.nc(File)
        NT=dim.inq.nc(AnomSoilts.nc,"time")$length
        AnomSoilts<-var.get.nc(AnomSoilts.nc,VAR[m],start=c(1,1,1,1),count=c(1,1,NZ,NT))
        close.nc(AnomSoilts.nc)
        #plot(1:NT,AnomSoilts[1,],type="o")
        
        if(m==2){
          THICK.exp<-matrix(data=rep(THICK,each=YEARS),nrow=NZ,ncol=YEARS,byrow=TRUE)
          AnomSoilts<-AnomSoilts/THICK.exp
        } 
        
        Annualts.arr[(s+1),1:NZ,]<-AnomSoilts
        # Interp to 0.01,0.1, and 1.0m
        for (h in 1:YEARS){
          Annualts.arr[(s+1),c(NZ+1,NZ+2,NZ+3),h]<-approx(MDPNT,Annualts.arr[(s+1),1:NZ,h],c(0.01,0.1,1.0),method="linear",rule=2)$y
        }
        EOCmean.arr[(s+1),]<-c(AnomSoilGlobalMean,approx(MDPNT,AnomSoilGlobalMean,c(0.01,0.1,1.0),method="linear",rule=2)$y)
      }
      
      ### LAT-ZONAL MEANS ##
      LatZone.arr<-array(data=NA,dim=c((length(LATZONE)+1),NLAT,NZ+3),dimnames=list(c("Global",LATZONE),seq(-90,90,length.out=NLAT),paste(c(round(MDPNT,3),0.01,0.1,1.0),"m",sep="")))
      
      
      #Global zonal mean (interpolate to 0.01,0.1, and 1.0m depth)
      File=paste(WD,"/",VAR[m],"_",MODEL[d],"_",XP[x],"_latmean_2081-2100_Global.nc",sep="")
      GlobalLatMean.nc<-open.nc(File)
      GlobalLatMean<-var.get.nc(GlobalLatMean.nc,VAR[m],start=c(1,1,1,1),count=c(1,NLAT,NZ,1))
      close.nc(GlobalLatMean.nc)
      
      if(m==2){
        THICK.exp2<-matrix(data=rep(THICK,each=NLAT),nrow=NLAT,ncol=NZ,byrow=FALSE)
        GlobalLatMean<-GlobalLatMean/THICK.exp2
      } 
      
      LatZone.arr[1,,1:NZ]<-GlobalLatMean
      for (h in 1:NLAT){
        if(is.na(LatZone.arr[1,h,1])) {LatZone.arr[1,h,c(NZ+1,NZ+2, NZ+3)]<-c(NA,NA,NA)} else {
          LatZone.arr[1,h,c(NZ+1,NZ+2,NZ+3)]<-approx(MDPNT,LatZone.arr[1,h,1:NZ],c(0.01,0.1,1.0),method="linear",rule=2)$y}
      }
      
      #For global, interpolate to same number of lats
      LatZone.global.interp<-array(data=NA,dim=c(180,3),dimnames=list(seq(-90,90,length.out=180),paste(c(0.01,0.1,1.0),"m",sep="")))
      LatZone.global.interp[,1]<-approx(seq(-90,90,length.out=NLAT),LatZone.arr[1,,"0.01m"],seq(-90,90,length.out=180),method="linear",rule=1)$y
      LatZone.global.interp[,2]<-approx(seq(-90,90,length.out=NLAT),LatZone.arr[1,,"0.1m"],seq(-90,90,length.out=180),method="linear",rule=1)$y
      LatZone.global.interp[,3]<-approx(seq(-90,90,length.out=NLAT),LatZone.arr[1,,"1m"],seq(-90,90,length.out=180),method="linear",rule=1)$y
      
      
      for (k in 1:length(LATZONE)){
        File=paste(WD,"/",VAR[m],"_",MODEL[d],"_",XP[x],"_latmean_2081-2100_",LATZONE[k],".nc",sep="")
        SoilLatMean.nc<-open.nc(File)
        SoilLatMean<-var.get.nc(SoilLatMean.nc,VAR[m],start=c(1,1,1,1),count=c(1,NLAT,NZ,1))
        close.nc(SoilLatMean.nc)
        #Replace zeros w NA
        SoilLatMean[SoilLatMean==0]<-NA
        #print(SoilLatMean)
        
        if(m==2){
          THICK.exp2<-matrix(data=rep(THICK,each=NLAT),nrow=NLAT,ncol=NZ,byrow=FALSE)
          SoilLatMean<-SoilLatMean/THICK.exp2
        } 
        LatZone.arr[(k+1),,1:NZ]<-SoilLatMean
        
        for (h in 1:NLAT){
          if(is.na(LatZone.arr[(k+1),h,1])) {LatZone.arr[(k+1),h,c(NZ+1,NZ+2,NZ+3)]<-c(NA,NA,NA)} else {
            if (sum((is.na(LatZone.arr[(k+1),h,2:NZ])))==(NZ-1)) {LatZone.arr[(k+1),h,c(NZ+1,NZ+2,NZ+3)]<-c(NA,NA,NA)} else{
              LatZone.arr[(k+1),h,c(NZ+1,NZ+2,NZ+3)]<-approx(MDPNT,LatZone.arr[(k+1),h,1:NZ],c(0.01,0.1,1.0),method="linear",rule=2)$y}
            } }
      } #End LATZONE
      
      ### Soil order Regions of interest ###
      #Historic monthly means
      ZoneMonthly.arr<-array(data=NA,dim=c(length(ZONE),NZ+3,12,2),dimnames=list(ZONE,paste(c(round(MDPNT,3),0.01,0.1,1.0),"m",sep=""),month.abb,c("1986-2005","2081-2100")))
      
      for (j in 1: length(ZONE)){
        #Historic monthly temp
        File=paste(WD,"/",VAR[m],"_",MODEL[d],"_198601-200512_mon_",ZONE[j],".nc",sep="")
        ZoneHistMon.nc<-open.nc(File)
        ZoneHistMon<-var.get.nc(ZoneHistMon.nc,VAR[m],start=c(1,1,1,1),count=c(1,1,NZ,12))
        close.nc(ZoneHistMon.nc)
        
        if(m==2){
          THICK.exp3<-matrix(data=rep(THICK,each=12),nrow=NZ,ncol=12,byrow=TRUE)
          ZoneHistMon<-ZoneHistMon/THICK.exp3
        } 
        
        ZoneMonthly.arr[j,1:NZ,,1]<-ZoneHistMon
        for (h in 1:12){ZoneMonthly.arr[j,c(NZ+1,NZ+2,NZ+3),h,1]<-approx(MDPNT,ZoneMonthly.arr[j,1:NZ,h,1],c(0.01,0.1,1.0),method="linear",rule=2)$y}
        
        #EOC monthly temp (absolute, not relative!)
        File=paste(WD,"/",VAR[m],"_",MODEL[d],"_",XP[x],"_2081-2100_mon_",ZONE[j],".nc",sep="")
        ZoneEOCMon.nc<-open.nc(File)
        ZoneEOCMon<-var.get.nc(ZoneEOCMon.nc,VAR[m],start=c(1,1,1,1),count=c(1,1,NZ,12))
        close.nc(ZoneEOCMon.nc)
        
        if(m==2){
          THICK.exp3<-matrix(data=rep(THICK,each=12),nrow=NZ,ncol=12,byrow=TRUE)
          ZoneHistMon<-ZoneHistMon/THICK.exp3
        } 
        
        ZoneMonthly.arr[j,1:NZ,,2]<-ZoneEOCMon
        for (h in 1:12){ZoneMonthly.arr[j,c(NZ+1,NZ+2,NZ+3),h,2]<-approx(MDPNT,ZoneMonthly.arr[j,1:NZ,h,2],c(0.01,0.1,1.0),method="linear",rule=2)$y}
        
        #21st C anomaly ts
        File=paste(WD,"/",VAR[m],"_",MODEL[d],"_",XP[x],"_",XPSTART,"-",XPEND,"_anom_annual_",ZONE[j],".nc",sep="")
        ZoneAnomts.nc<-open.nc(File)
        ZoneAnomts<-var.get.nc(ZoneAnomts.nc,VAR[m],start=c(1,1,1,1),count=c(1,1,NZ,YEARS))
        close.nc(ZoneAnomts.nc)
        
        if(m==2){
          THICK.exp<-matrix(data=rep(THICK,each=YEARS),nrow=NZ,ncol=YEARS,byrow=TRUE)
          ZoneAnomts<-ZoneAnomts/THICK.exp
        } 
        
        Annualts.arr[(j+s+1),1:NZ,]<-ZoneAnomts #s is the index from the soil order loop
        #Interpolate to 0.01 and 1.00m
        for (h in 1:YEARS){
          Annualts.arr[(j+s+1),c(NZ+1,NZ+2,NZ+3),h]<-approx(MDPNT,Annualts.arr[(j+s+1),1:NZ,h],c(0.01,0.1,1.0),method="linear",rule=2)$y
        }
        
        #2081-2100 anomaly mean
        File=paste(WD,"/",VAR[m],"_",MODEL[d],"_",XP[x],"_2081-2100_anom_region_",ZONE[j],".nc",sep="")
        ZoneAnomTimean.nc<-open.nc(File)
        #print.nc(ZoneAnomTimean.nc)
        ZoneAnomTimean<-var.get.nc(ZoneAnomTimean.nc,VAR[m],start=c(1,1,1,1),count=c(1,1,NZ,1))
        close.nc(ZoneAnomTimean.nc)
        
        if(m==2){
          ZoneAnomTimean<-ZoneAnomTimean/THICK
        } 
        EOCmean.arr[(s+j+1),]<-c(ZoneAnomTimean,approx(MDPNT,ZoneAnomTimean,c(0.01,0.1,1.0),method="linear",rule=2)$y)
      } #End of zone loop
      
      if(m==1){
        
        ### Historic annual amplitude ###
        File=paste(WD,"/",VAR[m],"_",MODEL[d],"_198601-200512_amplitude.nc",sep="")
        HistAmplitudemap.nc<-open.nc(File)
        #print.nc(HistAmplitudemap.nc)
        HistAmplitudemap<-var.get.nc(HistAmplitudemap.nc,VAR[m],start=c(1,1,1,1),count=c(NLON,NLAT,NZ,1))
        close.nc(HistAmplitudemap.nc)

        # Add three more depths to z dimension of map array for interpolating to 0.01, 0.1 and 1.0m
        expand.arr<-array(data=NA, dim=c(NLON,NLAT,3), dimnames=list(seq(0,360,length.out=NLON),seq(-90,90,length.out=NLAT),c("0.01m","0.1m","1m")))
        HistAmplitudemap<-abind(HistAmplitudemap,expand.arr,along=3)
        dimnames(HistAmplitudemap)[[3]]<-c(MDPNT,c("0.01m","0.1m","1m"))

        # Interpolate to 0.01m, 0.1m, and 1m and add to array
        for (h in 1:NLON){
          for (i in 1:NLAT){
            if(is.na(HistAmplitudemap[h,i,1])){
              HistAmplitudemap[h,i,(dim(HistAmplitudemap)[3]-2):dim(HistAmplitudemap)[3]]<-c(NA,NA,NA)
            } else{
              temp<-approx(MDPNT,HistAmplitudemap[h,i,1:NZ],c(0.01,0.1,1.0),method="linear",rule=2)$y
              HistAmplitudemap[h,i,(dim(HistAmplitudemap)[3]-2):dim(HistAmplitudemap)[3]]<-temp
            }
          }
        } #End interpolate loop
      # 
      #   ### EOC annual amplitude ###
      #   # CL not in new scripts
      #   # File=paste(WD,"/",VAR[m],"_",MODEL[d],"_",XP[x],"_208101-210012_land_NoIce_amplitude.nc",sep="")
      #   # EOCAmplitudemap.nc<-open.nc(File)
      #   # EOCAmplitudemap<-var.get.nc(EOCAmplitudemap.nc,VAR[m],start=c(1,1,1,1),count=c(NLON,NLAT,NZ,1))
      #   # close.nc(EOCAmplitudemap.nc)
      #   # 
      #   # # Add three more depths to z dimension of map array for interpolating to 0.01, 0.1 and 1.0m 
      #   # expand.arr<-array(data=NA, dim=c(NLON,NLAT,3), dimnames=list(seq(0,360,length.out=NLON),seq(-90,90,length.out=NLAT),c("0.01m","0.1m","1m")))
      #   # EOCAmplitudemap<-abind(EOCAmplitudemap,expand.arr,along=3)
      #   # dimnames(EOCAmplitudemap)[[3]]<-c(MDPNT,c("0.01m","0.1m","1m"))
      #   # 
      #   # # Interpolate to 0.01m, 0.1m, and 1m and add to array
      #   # for (h in 1:NLON){
      #   #   for (i in 1:NLAT){
      #   #     if(is.na(EOCAmplitudemap[h,i,1])){
      #   #       EOCAmplitudemap[h,i,(dim(EOCAmplitudemap)[3]-2):dim(EOCAmplitudemap)[3]]<-c(NA,NA,NA)
      #   #     } else{
      #   #       temp<-approx(MDPNT,EOCAmplitudemap[h,i,1:NZ],c(0.01,0.1,1.0),method="linear",rule=2)$y
      #   #       EOCAmplitudemap[h,i,(dim(EOCAmplitudemap)[3]-2):dim(EOCAmplitudemap)[3]]<-temp
      #   #     }
      #   #   }
      #   # } #End interpolate loop
      #   # #image.plot(EOCAmplitudemap[,,"1m"])
        
      #   #v0 = used soil layers 1 and 2 to calculate z; v1 = used air and soil layer 1
      #   #Open damping depth
        File=paste(WD,"/",VAR[m],"_",MODEL[d],"_198601-200512_damp.nc",sep="")
        DampingDepth.nc<-open.nc(File)
      #   #print.nc(DampingDepth.nc)
         DampingDepth.v0<-var.get.nc(DampingDepth.nc,"var1",start=c(1,1,1),count=c(NLON,NLAT,1))
        close.nc(DampingDepth.nc)
        image.plot(DampingDepth.v0)

        File=paste(WD,"/",VAR[m],"_",MODEL[d],"_198601-200512_dampv1.nc",sep="")
        DampingDepth.v1.nc<-open.nc(File)
        DampingDepth.v1<-var.get.nc(DampingDepth.v1.nc,"var1",start=c(1,1,1),count=c(NLON,NLAT,1))

        #DampingDepth.v1<-read.csv(File,header=FALSE)
        #DampingDepth.v1<-t(as.matrix(DampingDepth.v1))
        image.plot(DampingDepth.v1)

        #Open soil orders and bind to damping depth
        File=paste(DIR0,"/soil-wts/","AllOrders.nc",sep="")
        AllOrders.nc<-open.nc(File)
        #print.nc(AllOrders.nc)
        AllOrders <- array(data=NA,dim = c(NLON,NLAT,length(SOIL)),dimnames = list(seq(1,NLON,length.out=NLON),seq(1,NLAT,length.out = NLAT),SOIL))
        for (i in 1:length(SOIL)){
          AllOrders[,,i]<- var.get.nc(AllOrders.nc,SOIL[i],start=c(1,1),count=c(NLON,NLAT))
        }
        #AllOrders<-var.get.nc(AllOrders.nc,"Grid",start=c(1,1),count=c(NLON,NLAT))
        close.nc(AllOrders.nc)
        DampingDepth<-abind(DampingDepth.v0,DampingDepth.v1,AllOrders,along=3)

      } #End if m==1 clause
       
      ## Add the Model and VAR name to the arrays and save to WD
      assign(paste(MODEL[d],XP[x],REAL,VAR[m],"Annualts.arr",sep="."),Annualts.arr)
      assign(paste(MODEL[d],XP[x],REAL,VAR[m],"EOCmean.arr",sep="."),EOCmean.arr)
      assign(paste(MODEL[d],XP[x],REAL,VAR[m],"LatZone.arr",sep="."),LatZone.arr)
      assign(paste(MODEL[d],XP[x],REAL,VAR[m],"LatZone.global.interp",sep="."),LatZone.global.interp)
      assign(paste(MODEL[d],XP[x],REAL,VAR[m],"ZoneMonthly.arr",sep="."),ZoneMonthly.arr)
      assign(paste(MODEL[d],XP[x],REAL,VAR[m],"AnomGlobalmap",sep="."),AnomGlobalmap)
      assign(paste(MODEL[d],REAL,VAR[m],"HistAbsolutemap",sep="."),HistAbsolutemap)
      
      if(m==1){
       # assign(paste(MODEL[d],XP[x],REAL,VAR[m],"EOCAmplitudemap",sep="."),HistAmplitudemap)
        assign(paste(MODEL[d],REAL,VAR[m],"HistAmplitudemap",sep="."),HistAmplitudemap)
        assign(paste(MODEL[d],REAL,"DampingDepth",sep="."),DampingDepth)
        
       # save(list=c(paste(MODEL[d],XP[x],REAL,VAR[m],c("Annualts.arr","EOCmean.arr","LatZone.arr","LatZone.global.interp","ZoneMonthly.arr","AnomGlobalmap","EOCAmplitudemap"),sep="."),paste(MODEL[d],REAL,VAR[m],"HistAbsolutemap",sep="."),paste(MODEL[d],REAL,VAR[m],"HistAmplitudemap",sep="."),paste(MODEL[d],REAL,"DampingDepth",sep=".")),file=paste(WD,"/",MODEL[d],"_",XP[x],"_",REAL,"_",VAR[m],".RData",sep=""))} else
        save(list=c(paste(MODEL[d],XP[x],REAL,VAR[m],c("Annualts.arr","EOCmean.arr","LatZone.arr","LatZone.global.interp","ZoneMonthly.arr","AnomGlobalmap"),sep="."),paste(MODEL[d],REAL,VAR[m],"HistAbsolutemap",sep="."),paste(MODEL[d],REAL,VAR[m],"HistAmplitudemap",sep="."),paste(MODEL[d],REAL,"DampingDepth",sep=".")),file=paste(OUT,"/RData/",MODEL[d],"_",XP[x],"_",REAL,"_",VAR[m],".RData",sep=""))} else
          
        {
          save(list=c(paste(MODEL[d],XP[x],REAL,VAR[m],c("Annualts.arr","EOCmean.arr","LatZone.arr","LatZone.global.interp","ZoneMonthly.arr","AnomGlobalmap"),sep="."),paste(MODEL[d],REAL,VAR[m],"HistAbsolutemap",sep=".")),file=paste(OUT,"/RData/",MODEL[d],"_",XP[x],"_",REAL,"_",VAR[m],".RData",sep=""))}
      

      
    } # end of var
  } # end of xp
} # end of model

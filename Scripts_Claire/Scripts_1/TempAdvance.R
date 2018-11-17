## Calculate DOY shift from daily tsl data ##

rm(list=ls())
library(RNetCDF)
library(ncdf)
library(fields)
library(abind)

GridToCDF<-function(Grid,Dest,Var,nlat,nlon){ #Grid has lat in rows and lon in columns
  temp.nc<-create.nc(Dest)
  dim.def.nc(temp.nc,"lat",nlat)
  dim.def.nc(temp.nc,"lon",nlon)
  var.def.nc(temp.nc,as.character(Var),vartype="NC_DOUBLE",c(1,0))
  var.def.nc(temp.nc,"lat",vartype="NC_DOUBLE",c(0))
  var.def.nc(temp.nc,"lon",vartype="NC_DOUBLE",c(1))
  att.put.nc(temp.nc,as.character(Var),"_FillValue","NC_DOUBLE",-9999)
  att.put.nc(temp.nc,"lat","units","NC_CHAR","degrees")
  att.put.nc(temp.nc,"lon","units","NC_CHAR","degrees")
  att.put.nc(temp.nc,"lat","axis","NC_CHAR","Y")
  att.put.nc(temp.nc,"lon","axis","NC_CHAR","X")
  var.put.nc(temp.nc,as.character(Var),Grid,start=c(1,1),count=c(nlon,nlat),na.mode=1)
  var.put.nc(temp.nc,"lat",seq(-90,90,length=nlat),start=c(1),count=c(nlat),na.mode=0)
  var.put.nc(temp.nc,"lon",seq(-180,180,length=nlon),start=c(1),count=c(nlon),na.mode=0)
  sync.nc(temp.nc)
  close.nc(temp.nc)  
}

### COMPLETE THE FOLLOWING BEFORE RUNNING ###
MODEL=c("bcc-csm1-1","BNU-ESM","CanESM2", "CCSM4", "CESM1-BGC","MPI-ESM-LR", "GFDL-ESM2G","GISS-E2-R","HadGEM2-ES","inmcm4","IPSL-CM5A-LR","MIROC5","MRI-CGCM3","NorESM1-M")
XP=c("rcp85")
REAL="r1i1p1"

# MAKE 10C MASK
for(n in 1:length(MODEL)){ File<-paste("F:/wd/",MODEL[n],"/tsl_",MODEL[n],"_198601-200512_mon_rect.nc",sep="")
  HistAbsoluteMap.nc<-open.nc(File)
  #print.nc(HistAbsoluteMin.nc)
  NLON=dim.inq.nc(HistAbsoluteMap.nc,"lon")$length
  NLAT=dim.inq.nc(HistAbsoluteMap.nc,"lat")$length
  NT=dim.inq.nc(HistAbsoluteMap.nc,"time")$length
  HistAbsoluteMap<-var.get.nc(HistAbsoluteMap.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,1,NT))
  close.nc(HistAbsoluteMap.nc)
  HistAbsoluteMin<-apply(HistAbsoluteMap,c(1,2),min)
  #image.plot(HistAbsoluteMin)
  Min10Mask<- HistAbsoluteMin>275
  #image.plot(SnowMask)
  assign(paste(MODEL[n],"Min10Mask",sep="."),Min10Mask)
  DEST<-paste("F:/wd/SeasonAdvance/",MODEL[n],"_Mask10C.nc",sep="")
  GridToCDF(Grid=Min10Mask,Dest=DEST,Var="Mask",nlat=NLAT,nlon=NLON)
}


# Run one model at a time or will fill memory.
for(d in 4:4){ #length(MODEL)){
  
  # Import tslEOC, tslHist, tasEOC, and tasHist daily files
  {WD=paste("F:/wd",MODEL[d],sep="/")
   
  File=paste(WD,"/tsl_Lmon_",MODEL[d],"_",XP,"_2080-2100_daily.nc",sep="")
  tslEOC.nc<-open.nc(File)
  # Just get 4 layers, don't need all
  NZ=3 #dim.inq.nc(tslEOC.nc,"depth")$length
  NT=dim.inq.nc(tslEOC.nc,"time")$length
  NLON=dim.inq.nc(tslEOC.nc,"lon")$length
  NLAT=dim.inq.nc(tslEOC.nc,"lat")$length
  UBND<-var.get.nc(tslEOC.nc,"depth_bnds",start=c(1,1),count=c(1,NZ))
  LBND<-var.get.nc(tslEOC.nc,"depth_bnds",start=c(2,1),count=c(1,NZ))
  THICK<-LBND-UBND
  MDPNT<-apply(X=cbind(UBND,LBND),MARGIN=1,mean)
  tslEOC<-var.get.nc(tslEOC.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,NZ,NT))
  close.nc(tslEOC.nc)
  dim(tslEOC)
  image.plot(tslEOC[,,1,1], zlim=c(220,320)) 
    
  File=paste(WD,"/tsl_",MODEL[d],"_","198601-200512_daily.nc",sep="")
  tslHist.nc<-open.nc(File)
  dim.inq.nc(tslHist.nc,"time")$length
  NT=dim.inq.nc(tslHist.nc,"time")$length
  tslHist<-var.get.nc(tslHist.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,NZ,NT))
  close.nc(tslHist.nc)
  image.plot(tslHist[,,1,1], zlim=c(220,320))
  
  File=paste(WD,"/tas_Amon_",MODEL[d],"_",XP,"_2080-2100_daily.nc",sep="")
  tasEOC.nc<-open.nc(File)
  dim.inq.nc(tasEOC.nc,"time")$length
  NT=dim.inq.nc(tasEOC.nc,"time")$length
  tasEOC<-var.get.nc(tasEOC.nc,"tas",start=c(1,1,1),count=c(NLON,NLAT,NT))
  close.nc(tasEOC.nc)
  dim(tasEOC)
  image.plot(tasEOC[,,1], zlim=c(220,320)) 
  
  File=paste(WD,"/tas_",MODEL[d],"_","198601-200512_daily.nc",sep="")
  tasHist.nc<-open.nc(File)
  dim.inq.nc(tasHist.nc,"time")$length
  NT=dim.inq.nc(tasHist.nc,"time")$length
  tasHist<-var.get.nc(tasHist.nc,"tas",start=c(1,1,1),count=c(NLON,NLAT,NT))
  close.nc(tasHist.nc)
  dim(tasHist)
  image.plot(tasHist[,,1], zlim=c(220,320))
  }  
  
  Arrays<-c("tslEOC","tslHist","tasEOC","tasHist")
  
  # Cycle through each of these arrays. 
  
  # The timeseries are only 335 days (Hadley is 330) bc CDO won't interpolate the 1st and last 15 days of the year. Manually interpolate those
  # for soils only, modify dims for air
  for (f in 1:2){ 
    print(as.character(Arrays[f]))
    Array<-get(Arrays[f])
    Jan<-array(data=NA,dim=c(NLON,NLAT,NZ,15))
    if(MODEL[d]=="HadGEM2-ES") {Dec<-array(data=NA,dim=c(NLON,NLAT,NZ,50))} else {
    Dec<-array(data=NA,dim=c(NLON,NLAT,NZ,15)) } 
    for (h in 1:NLON){
      for (i in 1:NLAT){
        for (z in 1:NZ){
          #Get the first and last value in the timeseries for each location and depth
          First<-Array[h,i,z,1]
          Last<-Array[h,i,z,NT]
          if(is.na(First)) {
            Jan[h,i,z,]<-rep(NA,15)
            if(MODEL[d]=="HadGEM2-ES") {Dec[h,i,z,]<-rep(NA,50)} else {Dec[h,i,z,]<-rep(NA,15)}
          } else {
            Jan[h,i,z,]<-seq(mean(First,Last),First,length.out=16)[1:15]
            if(MODEL[d]=="HadGEM2-ES") {Dec[h,i,z,]<-seq(Last,mean(First,Last),length.out=51)[2:51]} else {
              Dec[h,i,z,]<-seq(Last,mean(First,Last),length.out=16)[2:16]}
          }
        } #End NZ
      } #End NLAT
      print(h)
    }#End NLON
    assign(Arrays[f],abind(Jan,Array,Dec,along=4))
  } #End Arrays
  dim(tslEOC)
  #plot(1:365,tslEOC[91,45,1,])
  
  # for air only
  for (f in 3:4){ 
    print(as.character(Arrays[f]))
    Array<-get(Arrays[f])
    Jan<-array(data=NA,dim=c(NLON,NLAT,15))
    if(MODEL[d]=="HadGEM2-ES") {Dec<-array(data=NA,dim=c(NLON,NLAT,50))} else {
      Dec<-array(data=NA,dim=c(NLON,NLAT,15)) }  
    for (h in 1:NLON){
      for (i in 1:NLAT){      
          #Get the first and last value in the timeseries for each location and depth
          First<-Array[h,i,1]
          Last<-Array[h,i,NT]
          if(is.na(First)) {
            Jan[h,i,]<-rep(NA,15)
            if(MODEL[d]=="HadGEM2-ES") {Dec[h,i,]<-rep(NA,50)} else {Dec[h,i,]<-rep(NA,15)}
          } else {
            Jan[h,i,]<-seq(mean(First,Last),First,length.out=16)[1:15]
            if(MODEL[d]=="HadGEM2-ES") {Dec[h,i,]<-seq(Last,mean(First,Last),length.out=51)[2:51]} else {
              Dec[h,i,]<-seq(Last,mean(First,Last),length.out=16)[2:16]}
          }     
      } #End NLAT
      print(h)
    }#End NLON
    assign(Arrays[f],abind(Jan,Array,Dec,along=3))
  } #End Arrays
  #dim(tasEOC);dim(tasHist)
  #image.plot(tasEOC[,,1])
  #image.plot(tslEOC[,,1,1])
  
  # Interpolate to 0.01m, 0.1m, and 1m and add to array
  for (f in 1:2){ #Only do this for tsl files, not tas files
    print(as.character(Arrays[f]))
    Array<-get(Arrays[f])
    ExtraDepths<-array(data=NA,dim=c(NLON,NLAT,365))
    for (t in 1:NT){
      print(t)
      for (h in 1:NLON){
        for (i in 1:NLAT){
          if(is.na(Array[h,i,1,t])){
            ExtraDepths[h,i,t]<-NA} else {
            ExtraDepths[h,i,t]<-approx(MDPNT,Array[h,i,1:NZ,t],c(0.01),method="linear",rule=2)$y}
          } #End NLAT
        } #End NLON
      } #End NT
    assign(Arrays[f],ExtraDepths)
  } #End Arrays
  dim(tslEOC); dim(tslHist)
  
  #tslEOCsurf<-tslEOC[,,NZ+1,] #0.01m depth
  #tslHistsurf<-tslHist[,,NZ+1,]
  #Arrays2<-c("tslEOCsurf","tslHistsurf","tasEOC","tasHist")
  
  # Get time advancement
  for (f in 1:4){
    Degree10.North<-array(data=NA,dim=c(NLON,ceiling(NLAT/2)))
    Degree10.South<-array(data=NA,dim=c(NLON,floor(NLAT/2)))
    Array<-get(Arrays[f])
    for (h in 1:NLON){
      #print(h)
      for (i in 1:floor(NLAT/2)){ #For the southern hemisphere
        if(is.na(Array[h,i,1])) Degree10.South[h,i]<-NA else if(length(which(Array[h,i,180:365]>283.15))==0) Degree10.South[h,i]<-0 else Degree10.South[h,i]<-min(which(Array[h,i,180:365]>283.15),na.rm=TRUE)
      } #End southern hemisphere
      
      for (i in (ceiling(NLAT/2)):NLAT){ #For the northern hemisphere
        if(is.na(Array[h,i,1])) Degree10.North[h,(i-(NLAT/2))]<-NA else if(length(which(Array[h,i,1:230]>283.15))==0) Degree10.North[h,(i-(NLAT/2))]<-0 else Degree10.North[h,(i-(NLAT/2))]<-min(which(Array[h,i,1:230]>283.15),na.rm=TRUE)
      } #End northern hemisphere 
      
    } #End NLON
  assign(paste(MODEL[d],Arrays[f],"Degree10.S",sep="."),Degree10.South)
  assign(paste(MODEL[d],Arrays[f],"Degree10.N",sep="."),Degree10.North)
  } #End Arrays

# image.plot(tslHistsurf.Degree10.N, main="DOY reaching 10C, 2080-2100", zlim=c(0,200))
# image.plot(tslEOCsurf.Degree10.N, main="DOY reaching 10C, 2080-2100", zlim=c(0,200))
# image.plot(tslHistsurf.Degree10.S, main="DOY reaching 10C, 2080-2100", zlim=c(0,200))
# image.plot(tslEOCsurf.Degree10.S, main="DOY reaching 10C, 2080-2100", zlim=c(0,200))

tsl.Shift.10.N<-get(paste(MODEL[d],"tslEOC.Degree10.N",sep="."))-get(paste(MODEL[d],"tslHist.Degree10.N",sep="."))
tsl.Shift.10.S<-get(paste(MODEL[d],"tslEOC.Degree10.S",sep="."))-get(paste(MODEL[d],"tslHist.Degree10.S",sep="."))
assign(paste(MODEL[d],".tsl.Shift.10",sep=""),cbind(tsl.Shift.10.S,tsl.Shift.10.N))

tas.Shift.10.N<-get(paste(MODEL[d],"tasEOC.Degree10.N",sep="."))-get(paste(MODEL[d],"tasHist.Degree10.N",sep="."))
tas.Shift.10.S<-get(paste(MODEL[d],"tasEOC.Degree10.S",sep="."))-get(paste(MODEL[d],"tasHist.Degree10.S",sep="."))
  assign(paste(MODEL[d],".tas.Shift.10",sep=""),cbind(tas.Shift.10.S,tas.Shift.10.N))

assign(paste(MODEL[d],".AirShift.minus.soilShift",sep=""),(get(paste(MODEL[d],".tas.Shift.10",sep=""))-get(paste(MODEL[d],".tsl.Shift.10",sep=""))))

save(list=paste(MODEL[d],c(".tsl.Shift.10",".tas.Shift.10",".AirShift.minus.soilShift"),sep=""), file=paste(WD,"/",MODEL[d],"_SeasonAdvance.Rdata",sep=""))

pdf(paste(WD,"/",MODEL[d],".SeasonAdvancePlots.pdf",sep=""))

{  image.plot(get(paste(MODEL[d],".tas.Shift.10",sep="")),main=paste("Change in DOY reaching 10C, ", MODEL[d], ", var=Soil", sep="")) 
  image.plot(get(paste(MODEL[d],".tsl.Shift.10",sep="")),main=paste("Change in DOY reaching 10C, ", MODEL[d], ", var=Air", sep=""))
  image.plot(get(paste(MODEL[d],".AirShift.minus.soilShift",sep="")),main=paste("Air shift minus Soil shift, ", MODEL[d], ", var=Soil", sep=""))
 
  dev.off()}
rm(list=paste(MODEL[d],c("tasEOC.Degree10.N","tasEOC.Degree10.S","tslEOC.Degree10.N","tslEOC.Degree10.S","tasHist.Degree10.N","tasHist.Degree10.S","tslHist.Degree10.N","tslHist.Degree10.S","tsl.Shift.10","tas.Shift.10","AirShift.minus.soilShift"),sep="."))
} #End models
     
#Plot map of soil temp shift
jpeg(paste("C:/Users/Claire/Documents/LBL/Figures/SoilTempAdance.jpg",sep=""),width=1000, height=768,res=200,quality=100)
{par(oma=c(1,1,1,1),mar=c(0,0.5,1.5,0))
 layout(rbind(c(1,2,3,4,17),
              c(5,6,7,8,17),
              c(9,10,11,12,17),
              c(13,14,15,16,17)))
 
 for (i in c(1:14)){
   #if(MODEL.V[i]=="CCSM4") REAL="r2i1p1" else REAL="r1i1p1"
   File<-paste("F:/wd/",MODEL[i],"/",MODEL[i],"_ocean-mask.nc",sep="")
   Land.nc<-open.nc(File)
   NLON=dim.inq.nc(Land.nc,"lon")$length
   NLAT=dim.inq.nc(Land.nc,"lat")$length
   Land<-var.get.nc(Land.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,1,1))
   x<-var.get.nc(Land.nc,"lon",start=c(1),count=c(NLON))
   y<-var.get.nc(Land.nc,"lat",start=c(1),count=c(NLAT))
   Land[Land>0]<-1
   Land[is.na(Land)]<-0
   Land<-Land[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   
   File<-paste("F:/wd/",MODEL[i],"/",MODEL[i],"_SeasonAdvance.Rdata",sep="")
   load(File)
   tsl.temp<-get(paste(MODEL[i],"tsl.Shift.10",sep="."))
   tsl.temp[tsl.temp==0]<-NA
   tsl.temp<-tsl.temp[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   tsl.temp<-tsl.temp* -1
   tsl.temp[tsl.temp>60]<-60
   tsl.temp[tsl.temp< -5]<- -5
   Min10Mask<-get(paste(MODEL[i],"Min10Mask",sep="."))
   Min10Mask<-Min10Mask[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   tsl.temp[Min10Mask==TRUE]<-NA
   image(x,y,tsl.temp,xaxt="n",zlim=c(-5,60),yaxt="n",col=tim.colors(),main=MODEL[i]) 
   box(lwd=1)
   contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")
 }  
 plot.new()
 plot.new()
 par(oma=c(0,0,0,4))# reset margin to be much smaller.
 image.plot(legend.only=TRUE, zlim=c(-5,60),legend.width=4.6) 
}
dev.off()

#Plot map of Air shift minus soil shift
jpeg(paste("C:/Users/Claire/Documents/LBL/Figures/AirShiftMinusShoilShift.jpg",sep=""),width=1000, height=768,res=200,quality=100)
ZLim<-c(-20,20)
{par(oma=c(1,1,1,1),mar=c(0,0.5,1.5,0))
 layout(rbind(c(1,2,3,4,17),
              c(5,6,7,8,17),
              c(9,10,11,12,17),
              c(13,14,15,16,17)))
 
 for (i in c(1:14)){
   #if(MODEL.V[i]=="CCSM4") REAL="r2i1p1" else REAL="r1i1p1"
   File<-paste("F:/wd/",MODEL[i],"/",MODEL[i],"_ocean-mask.nc",sep="")
   Land.nc<-open.nc(File)
   NLON=dim.inq.nc(Land.nc,"lon")$length
   NLAT=dim.inq.nc(Land.nc,"lat")$length
   Land<-var.get.nc(Land.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,1,1))
   x<-var.get.nc(Land.nc,"lon",start=c(1),count=c(NLON))
   y<-var.get.nc(Land.nc,"lat",start=c(1),count=c(NLAT))
   Land[Land>0]<-1
   Land[is.na(Land)]<-0
   Land<-Land[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   
   File<-paste("F:/wd/",MODEL[i],"/",MODEL[i],"_SeasonAdvance.Rdata",sep="")
   load(File)
   tsl.temp<-get(paste(MODEL[i],"AirShift.minus.soilShift",sep="."))
   tsl.temp[tsl.temp==0]<-NA
   tsl.temp<-tsl.temp[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   tsl.temp<-tsl.temp* -1
   tsl.temp[tsl.temp< -20]<- -20
   tsl.temp[tsl.temp> 20]<- 20
   print(range(tsl.temp,na.rm=TRUE))
   Min10Mask<-get(paste(MODEL[i],"Min10Mask",sep="."))
   Min10Mask<-Min10Mask[c(((NLON/2+1):NLON),(1:(NLON/2))),]
   tsl.temp[Min10Mask==TRUE]<-NA
   image(x,y,tsl.temp,xaxt="n",zlim=ZLim,yaxt="n",col=tim.colors(),main=MODEL[i]) 
   box(lwd=1)
   contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")
 }  
 plot.new()
 plot.new()
 par(oma=c(0,0,0,4))# reset margin to be much smaller.
 image.plot(legend.only=TRUE, zlim=ZLim,legend.width=4.6) 
}
dev.off()



## Export DOY shift to netCDF files
for (d in 1:length(MODEL)){
  WD=paste("F:/wd",MODEL[d],sep="/")
  load(file=paste(WD,"/",MODEL[d],"_SeasonAdvance.Rdata",sep=""))
  tsl.temp<-get(paste(MODEL[d],"tsl.Shift.10",sep="."))
  NLON=dim(tsl.temp)[[1]]
  NLAT=dim(tsl.temp)[[2]]
  #tsl.temp<-tsl.temp[c(((NLON/2+1):NLON),(1:(NLON/2))),]
  tas.temp<-get(paste(MODEL[d],"tas.Shift.10",sep="."))
  Min10Mask<-get(paste(MODEL[d],"Min10Mask",sep="."))
  #Min10Mask<-Min10Mask[c(((NLON/2+1):NLON),(1:(NLON/2))),]
  tsl.temp[Min10Mask==TRUE]<-NA
  tas.temp[Min10Mask==TRUE]<-NA
  diff.temp<-tsl.temp-tas.temp
  DEST.tsl<-paste("F:/wd/SeasonAdvance/",MODEL[d],"_tslAdvance.nc",sep="")
  DEST.tas<-paste("F:/wd/SeasonAdvance/",MODEL[d],"_tasAdvance.nc",sep="")
  DEST.diff<-paste("F:/wd/SeasonAdvance/",MODEL[d],"_diffAdvance.nc",sep="")
  GridToCDF(Grid=tsl.temp,Dest=DEST.tsl,Var="DOY",nlat=NLAT,nlon=NLON)
  GridToCDF(Grid=tas.temp,Dest=DEST.tas,Var="DOY",nlat=NLAT,nlon=NLON)
  GridToCDF(Grid=diff.temp,Dest=DEST.diff,Var="DOY",nlat=NLAT,nlon=NLON)
}






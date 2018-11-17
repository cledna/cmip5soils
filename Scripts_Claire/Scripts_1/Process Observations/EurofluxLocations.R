# Identify Euroflux site locations #
library(RNetCDF)
library(ncdf)
library(fields)
library(abind)

File<-"F:/wd/Ensemble/OceanMask_1x1.nc"
Land.nc<-open.nc(File)
NLON=dim.inq.nc(Land.nc,"lon")$length
NLAT=dim.inq.nc(Land.nc,"lat")$length
Land<-var.get.nc(Land.nc,"tsl",start=c(1,1,1,1),count=c(NLON,NLAT,1,1))
x<-var.get.nc(Land.nc,"lon",start=c(1),count=c(NLON))
y<-var.get.nc(Land.nc,"lat",start=c(1),count=c(NLAT))
Land[Land>0]<-1
Land[is.na(Land)]<-0
#Land<-Land[c(((NLON/2+1):NLON),(1:(NLON/2))),]

List<-read.csv("F:/Observations/Euroflux/Euroflux_SiteLatLon.csv")
names(List)
plot(Lat~Lon,data=List,xlim=c(-180,180),ylim=c(-90,90), xlab="",ylab="", pch=as.character(List$Code), cex=0)
text(List$Lon,List$Lat,List$Code)
contour(x-180,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")

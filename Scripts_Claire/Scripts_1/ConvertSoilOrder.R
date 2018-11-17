## Make a matrix of lat, lon bins, and % of soil order in each ##
rm(list=ls())
library(RNetCDF)
library(ncdf)
library(fields)

# Convert the soil suborders to soil orders
system("cdo copy F:/soil_suborders_data/nrcs_suborder_map.nc F:/soil_suborders_data/nrcs_order_map.nc")
SoilOrder<-open.nc("F:/soil_suborders_data/nrcs_order_map.nc",write=TRUE)
print.nc(SoilOrder)
SSO<-var.get.nc(SoilOrder,"suborder",start=c(1,1),count=c(10800,5400))
SoilOrderNames<-("Gelisol","Histosol","Spodosol","Andisol","Oxisol","Vertisol","Aridisol","Ultisol","Mollisol","Alfisol","Inceptisol","Entisol")

#Chunk the data
xmax<-seq(900,10800,by=900)
ymax<-seq(450,5400,by=450)
for(i in 1:12){
  xmax=i*1
}
SO<-SSO
SO[SO==1]<- -1
SO[SO==2]<- -2
SO[SO==3]<- -3
SO[SO==4]<- -4
SO[SO>=5 & SO<=7]<-1
SO[SO>=10 & SO<=13]<-2
SO[SO>=15 & SO<=19]<-3
SO[SO>=20 & SO<=27]<-4
SO[SO>=30 & SO<=34]<-5
SO[SO>=40 & SO<=45]<-6
SO[SO>=50 & SO<=56]<-7
SO[SO>=60 & SO<=64]<-8
SO[SO>=70 & SO<=77]<-9
SO[SO>=80 & SO<=84]<-10
SO[SO>=85 & SO<=94]<-11
SO[SO>=95 & SO<=99]<-12

min(SO,na.rm=TRUE)
max(SO,na.rm=TRUE)
#Write SO to SoilOrder netCDF file
var.rename.nc(SoilOrder,"suborder","order")
att.put.nc(SoilOrder,"order","missing_value","NC_DOUBLE",-9999)
att.inq.nc(SoilOrder,"order","missing_value")
var.put.nc(SoilOrder,"order",SO,start=c(1,1),count=c(10800,5400),na.mode=0)

#Write to netCDF
sync.nc(SoilOrder)
close.nc(SoilOrder)

#Open and fix suborder, is missing attributes
# Suborders is a mess, the dimids are flipped for suborder, so Panopoly won't plot.
SoilSuborder<-open.nc("F:/soil_suborders_data/nrcs_suborder_map.nc",write=TRUE)
SSO<-var.get.nc(SoilSuborder,"suborder",start=c(1,1),count=c(10800,5400))
print.nc(SoilSuborder)
var.inq.nc(SoilSuborder,"suborder")
att.inq.nc(SoilSuborder, "suborder","missing_value")
dim.inq.nc(SoilSuborder,1)
dim.inq.nc(SoilSuborder,0)
att.put.nc(SoilSuborder,"suborder","_FillValue","NC_INT",0)
att.put.nc(SoilSuborder,"suborder","missing_value","NC_INT",-9999)
var.def.nc(SoilSuborder,"suborder2","NC_INT",c(1,0))
att.put.nc(SoilSuborder,"suborder2","_FillValue","NC_INT",0)
att.put.nc(SoilSuborder,"suborder2","missing_value","NC_INT",-9999)
var.put.nc(SoilSuborder,"suborder2",SSO,start=c(1,1),count=c(10800,5400))
sync.nc(SoilSuborder)
close.nc(SoilSuborder)


# Convert to an array with presence/absence for each order
Folder<-c("F:/soil_suborders_data/")
SoilOrder<-open.nc("F:/soil_suborders_data/nrcs_order_map_Copy.nc",write=TRUE)
print.nc(SoilOrder)
SO<-var.get.nc(SoilOrder,"order",start=c(1,1),count=c(10800,5400))
SoilOrderNames<-c("Ice","Rock","ShiftingSand","Ocean","Gelisol","Histosol","Spodosol","Andisol","Oxisol","Vertisol","Aridisol","Ultisol","Mollisol","Alfisol","Inceptisol","Entisol")
for (i in c(-3:-1,1:12)){
  Temp<-SO
  Temp[Temp!=i]<-0
  Temp[Temp==i]<-1
  #assign(SoilOrderNames[(i+4)],Temp)
  nc<-create.nc(paste(Folder,SoilOrderNames[(i+4)],".nc",sep=""))
  dim.def.nc(nc,"lat",5400)
  dim.def.nc(nc,"lon",10800)
  var.def.nc(nc,SoilOrderNames[(i+4)],vartype="NC_INT",c(1,0))
  var.def.nc(nc,"lat",vartype="NC_FLOAT",c(0))
  var.def.nc(nc,"lon",vartype="NC_FLOAT",c(1))
  att.put.nc(nc,SoilOrderNames[(i+4)],"missing_value","NC_INT",-9999)
  att.put.nc(nc,SoilOrderNames[(i+4)],"_FillValue","NC_INT",0)
  att.put.nc(nc,"lat","units","NC_CHAR","degrees")
  att.put.nc(nc,"lon","units","NC_CHAR","degrees")
  att.put.nc(nc,"lat","axis","NC_CHAR","Y")
  att.put.nc(nc,"lon","axis","NC_CHAR","X")
  var.put.nc(nc,SoilOrderNames[(i+4)],Temp,start=c(1,1),count=c(10800,5400),na.mode=2)
  var.put.nc(nc,"lat",seq(-89.983,89.983,length=5400),start=c(1),count=c(5400),na.mode=2)
  var.put.nc(nc,"lon",seq(-179.983,179.983,length=10800),start=c(1),count=c(10800),na.mode=2)
  sync.nc(nc)
  close.nc(nc)
}

# Mollisol
Mollisol<-open.nc("F:/soil_suborders_data/Mollisol.nc",write=TRUE)
att.put.nc(Mollisol,"NC_GLOBAL","grid","NC_CHAR","lonlat")
sync.nc(Mollisol)
close.nc(Mollisol)

#Make ocean layer
  Temp<-SO
  Temp[Temp!=0]<-55
  Temp[Temp==0]<-1
  Temp[Temp==55]<-0
  nc<-create.nc(paste(Folder,"Ocean",".nc",sep=""))
  dim.def.nc(nc,"lat",5400)
  dim.def.nc(nc,"lon",10800)
  var.def.nc(nc,"Ocean",vartype="NC_INT",c(1,0))
  var.def.nc(nc,"lat",vartype="NC_FLOAT",c(0))
  var.def.nc(nc,"lon",vartype="NC_FLOAT",c(1))
  att.put.nc(nc,"Ocean","missing_value","NC_INT",-9999)
  att.put.nc(nc,"Ocean","_FillValue","NC_INT",0)
  att.put.nc(nc,"lat","units","NC_CHAR","degrees")
  att.put.nc(nc,"lon","units","NC_CHAR","degrees")
  att.put.nc(nc,"lat","axis","NC_CHAR","Y")
  att.put.nc(nc,"lon","axis","NC_CHAR","X")
  var.put.nc(nc,"Ocean",Temp,start=c(1,1),count=c(10800,5400),na.mode=2)
  var.put.nc(nc,"lat",seq(-89.983,89.983,length=5400),start=c(1),count=c(5400),na.mode=2)
  var.put.nc(nc,"lon",seq(-179.983,179.983,length=10800),start=c(1),count=c(10800),na.mode=2)
  sync.nc(nc)
  close.nc(nc)

  
  



## March 17, 2014
# Read in each soil order presence/absence grid
# Change the NAs to 0s and the -9999's to NAs
# Average the 0s and 1s for each CESM pixel
# Write the fraction matrix to netCDF files
library(RNetCDF)
library(fields)
rm(list=ls())
# Get the lon and lat dimensions for the GCM by opening any tas output file
GCM<-"MPI-ESM-LR"
tas1.nc<-open.nc("F:/tas/MPI-ESM-LR/tas_Amon_MPI-ESM-LR_historical_r1i1p1_185001-200512.nc")
#tas1.nc<-open.nc("F:/tas/tas_Amon_CESM1-BGC_historical_r1i1p1_185001-200512.nc") #155 years
long<-var.get.nc(tas1.nc,"lon")
lat<-var.get.nc(tas1.nc,"lat")
longbnds<-var.get.nc(tas1.nc,"lon_bnds")
latbnds<-var.get.nc(tas1.nc,"lat_bnds")
close.nc(tas1.nc)

SoilOrderNames<-c("Ice","Rock","ShiftingSand","Gelisol","Histosol","Spodosol","Andisol","Oxisol","Vertisol","Aridisol","Ultisol","Mollisol","Alfisol","Inceptisol","Entisol")


for(k in 2:length(SoilOrderNames)){
  Order.nc<-open.nc(paste("F:/soil_suborders_data/",SoilOrderNames[k],".nc",sep=""))
  Order.arr<-var.get.nc(Order.nc,SoilOrderNames[k])
  NAs<-which(is.na(Order.arr),arr.ind=TRUE)
  Order.arr[NAs]<-0
  Order.arr[Order.arr== -9999]<-NA
  
  #Target grid dimensions
  nlon<-length(long)
  nlat<-length(lat)

  XVals<-var.get.nc(Order.nc,"lon")+180
  YVals<-var.get.nc(Order.nc,"lat")
  OrderGCM<-matrix(data=NA,nrow=nlat,ncol=nlon)
  for(i in 1:nlon){
    for(j in 1:nlat){
      x<-which(XVals<=longbnds[2,i] & XVals>=longbnds[1,i]) #Pull out all the soil order pixels that are within a grid cell (0 and 1s)
      y<-which(YVals<=latbnds[2,j] & YVals>=latbnds[1,j])
      temp<-mean(Order.arr[x,y],na.rm=TRUE) #Average all the 0s and 1s (ignore NAs)
      OrderGCM[j,i]<-temp 
    }
  }
  #Rearrange the lons to start at North America
  OrderGCMv1<-OrderGCM[,c((nlon/2+1):nlon,1:(nlon/2))]
  
  #For Ice, reverse the 0s and non-zeros to make it a mask for Ice areas
  if(k==1){
    temp2<-OrderGCMv1
    temp2[temp2>0]<-999
    temp2[temp2==0]<-0.888
    temp2[temp2==999]<-0
    temp2<-OrderGCMv1
  }
  
  pdf(file=paste("F:/soil_suborders_data/SoilOrderMaps/",GCM,"/",SoilOrderNames[k],GCM,".pdf",sep=""))
      par(mar=c(10,4,10,2))
      image.plot(t(OrderGCM))
  dev.off()
  
  Grid<-OrderGCMv1
  Dest<-paste("F:/soil_suborders_data/",GCM,"/",SoilOrderNames[k],GCM,".nc",sep="")

#GridToCDF<-function(Grid,Dest){ #Grid has lat in rows and lon in columns
  temp.nc<-create.nc(Dest)
  dim.def.nc(temp.nc,"lat",nlat)
  dim.def.nc(temp.nc,"lon",nlon)
  var.def.nc(temp.nc,as.character(bquote(Grid)),vartype="NC_DOUBLE",c(1,0))
  var.def.nc(temp.nc,"lat",vartype="NC_DOUBLE",c(0))
  var.def.nc(temp.nc,"lon",vartype="NC_DOUBLE",c(1))
  att.put.nc(temp.nc,as.character(bquote(Grid)),"_FillValue","NC_DOUBLE",-9999)
  att.put.nc(temp.nc,"lat","units","NC_CHAR","degrees")
  att.put.nc(temp.nc,"lon","units","NC_CHAR","degrees")
  att.put.nc(temp.nc,"lat","axis","NC_CHAR","Y")
  att.put.nc(temp.nc,"lon","axis","NC_CHAR","X")
  var.put.nc(temp.nc,as.character(bquote(Grid)),t(Grid),start=c(1,1),count=c(nlon,nlat),na.mode=1)
  var.put.nc(temp.nc,"lat",seq(-89.0625,89.0625,length=nlat),start=c(1),count=c(nlat),na.mode=0)
  var.put.nc(temp.nc,"lon",seq(0,360,length=nlon),start=c(1),count=c(nlon),na.mode=0)
  sync.nc(temp.nc)
  close.nc(temp.nc) 

}






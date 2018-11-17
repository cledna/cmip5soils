library(RNetCDF)
library(fields)

# Gelisol
Gelisol.nc<-open.nc("F:/soil_suborders_data/CESM1-BGC/GelisolCESM1-BGC.nc")
Gelisol<-var.get.nc(Gelisol.nc,"Grid",start=c(1,1),count=c(nlon,nlat))
Gelisol[Gelisol== -9999]<-NA
Lon<-seq(0,360,length.out=288)
Lat<-seq(-90,90,length.out=192)
image.plot(x=Lon,y=Lat,Gelisol, ylab="lat",xlab="lon")

#Find Mollisol N America lat and lon range
nlon<-288
nlat<-192

Mollisol.nc<-open.nc("F:/soil_suborders_data/CESM1-BGC/MollisolCESM1-BGC.nc")
Mollisol<-var.get.nc(Mollisol.nc,"Grid",start=c(1,1),count=c(nlon,nlat))
Mollisol[Mollisol== -9999]<-NA
Lon<-seq(-180,180,length.out=288)
Lat<-seq(-90,90,length.out=192)
#Restructure longitude to match GCM output
Mollisol<-Mollisol[c((nlon/2+1):nlon,1:(nlon/2)),]
image.plot(x=Lon,y=Lat,Mollisol, ylab="lat",xlab="lon")
rect(Lon[188],Lat[124],Lon[210],Lat[149], border="red",lwd=2)
image.plot(x=Lon[188:210],y=Lat[124:149],Mollisol[188:210,124:149])


Alfisol.nc<-open.nc("F:/soil_suborders_data/CESM1-BGC/AlfisolCESM1-BGC.nc")
Alfisol<-var.get.nc(Alfisol.nc,"Grid",start=c(1,1),count=c(nlon,nlat))
Alfisol[Alfisol== -9999]<-NA
Lon<-seq(0,360,length.out=288)
Lat<-seq(-90,90,length.out=192)
#Restructure longitude to match GCM output
#Alfisol<-Alfisol[c((nlon/2+1):nlon,1:(nlon/2)),]
image.plot(x=Lon,y=Lat,Alfisol, ylab="lat",xlab="lon")
rect(Lon[188],Lat[124],Lon[210],Lat[149], border="red",lwd=2)
image.plot(x=Lon[188:210],y=Lat[124:149],Alfisol[188:210,124:149])

# Save density map of Alfisol CESM
  pdf(file="C:/Users/Claire/Dropbox/CMIP5_Claire_Margaret/CESM/SoilOrderDensityMaps/AlfisolCESM.pdf")
  par(oma=c(5,0,5,0))  
  image.plot(x=Lon,y=Lat,Alfisol, ylab="lat",xlab="lon")
  dev.off()

Spodosol.nc<-open.nc("F:/soil_suborders_data/CESM1-BGC/SpodosolCESM1-BGC.nc")
Spodosol<-var.get.nc(Spodosol.nc,"Grid",start=c(1,1),count=c(nlon,nlat))
Spodosol[Spodosol== -9999]<-NA
Spodosol<-Spodosol[c((nlon/2+1):nlon,1:(nlon/2)),]
Lon<-seq(-180,180,length.out=288)
Lat<-seq(-90,90,length.out=192)
image.plot(x=Lon,y=Lat,Spodosol, ylab="lat",xlab="lon")
rect(Lon[3],Lat[155],Lon[53],Lat[173], border="red",lwd=2)
image.plot(x=Lon[3:53],y=Lat[155:173],Spodosol[3:53,155:173])

#Amazon lon 230:250, lat 80:100
Oxisol.nc<-open.nc("F:/soil_suborders_data/CESM1-BGC/OxisolCESM1-BGC.nc")
Oxisol<-var.get.nc(Oxisol.nc,"Grid",start=c(1,1),count=c(nlon,nlat))
Oxisol<-Oxisol[c((nlon/2+1):nlon,1:(nlon/2)),]
Lon<-seq(-180,180,length.out=288)
Lat<-seq(-90,90,length.out=192)
image.plot(x=Lon,y=Lat,Oxisol, ylab="lat",xlab="lon")
rect(Lon[221],Lat[80],Lon[260],Lat[105], border="red",lwd=2)
image.plot(x=Lon[221:260],y=Lat[80:105],Oxisol[221:260,80:105])

# Mollisol Eurasia lon 10-137.5 degrees (cells 8-110), lat 126.56-147.19 (cells 135-157) 
nlon<-288
nlat<-192

dev.off()
Mollisol.nc<-open.nc("F:/soil_suborders_data/CESM1-BGC/MollisolCESM1-BGC.nc")
Mollisol<-var.get.nc(Mollisol.nc,"Grid",start=c(1,1),count=c(nlon,nlat))
Mollisol[Mollisol== -9999]<-NA
Lon<-seq(-180,180,length.out=288)
Lat<-seq(-90,90,length.out=192)
#Restructure longitude to match GCM output
Mollisol<-Mollisol[c((nlon/2+1):nlon,1:(nlon/2)),]
image.plot(x=Lon,y=Lat,Mollisol, ylab="lat",xlab="lon")
rect(Lon[8],Lat[135],Lon[110],Lat[157], border="red",lwd=2)
image.plot(x=Lon[8:110],y=Lat[135:157],Mollisol[8:110,135:157])

  # Save density map of Mollisol CESM
  pdf(file="C:/Users/Claire/Dropbox/CMIP5_Claire_Margaret/CESM/SoilOrderDensityMaps/MollisolCESM.pdf")
  par(oma=c(5,0,5,0))  
  image.plot(x=Lon,y=Lat,Mollisol, ylab="lat",xlab="lon")
  dev.off()

# Aridisol Middle East long 30-55, lat 112-137
Aridisol.nc<-open.nc("F:/soil_suborders_data/CESM1-BGC/AridisolCESM1-BGC.nc")
Aridisol<-var.get.nc(Aridisol.nc,"Grid",start=c(1,1),count=c(nlon,nlat))
Aridisol[Aridisol== -9999]<-NA
Lon<-seq(-180,180,length.out=288)
Lat<-seq(-90,90,length.out=192)
#Restructure longitude to match GCM output
Aridisol<-Aridisol[c((nlon/2+1):nlon,1:(nlon/2)),]
image.plot(x=Lon,y=Lat,Aridisol, ylab="lat",xlab="lon")
rect(Lon[30],Lat[112],Lon[55],Lat[137], border="red",lwd=2)
image.plot(x=Lon[8:110],y=Lat[135:157],Mollisol[8:110,135:157])

  # Save density map of Aridisol CESM
  pdf(file="C:/Users/Claire/Dropbox/CMIP5_Claire_Margaret/CESM/SoilOrderDensityMaps/AridisolCESM.pdf")
  par(oma=c(5,0,5,0))  
  image.plot(x=Lon,y=Lat,Aridisol, ylab="lat",xlab="lon")
  dev.off()

# Put regions of interest as rectangles on a map of temp change in 2100

CESM.TslAnom.deep<-open.nc("F:/wd/CESM1-BGC/CESM1-BGC_TslAnom.deep.nc") #I didn't send this because is 40 MB
print.nc(CESM.TslAnom.deep)
Tsl.Anom.deep<-var.get.nc(CESM.TslAnom.deep,"TslAnom",start=c(1,1,1020),count=c(288,192,120))
#Mask out ice areas
Ice.weights.nc<-open.nc("F:/soil_suborders_data/CESM1-BGC/IceCESM1-BGC.nc")
print.nc(Ice.weights.nc)
Ice.weights<-var.get.nc(Ice.weights.nc,"Grid")
Ice.weights<-Ice.weights[c((288/2+1):288,1:(288/2)),]
image.plot(Ice.weights)
Tsl.Anom.deep.2100<-apply(Tsl.Anom.deep,c(1,2),mean,na.rm=TRUE)
dim(Tsl.Anom.deep.2100)
#Mask areas with Ice
Tsl.Anom.deep.2100[Ice.weights==1]<-NA
image.plot(x=Lon,y=Lat,Tsl.Anom.deep.2100, ylab="",xlab="", xaxt="n",yaxt="n")
#Western US
rect(Lon[188],Lat[124],Lon[210],Lat[149], border="red",lwd=2)
#Northern Europe
#rect(Lon[3],Lat[155],Lon[53],Lat[173], border="red",lwd=2)
#Amazon basin
#rect(Lon[221],Lat[80],Lon[260],Lat[105], border="red",lwd=2)
#Central Eurasia
rect(Lon[8],Lat[136],Lon[112],Lat[157], border="red",lwd=2)
#Middle East
rect(Lon[30],Lat[110],Lon[55],Lat[135], border="red",lwd=2)

# Limit temp range to 0-10
image.plot(x=Lon,y=Lat,Tsl.Anom.deep.2100, ylab="",xlab="", xaxt="n",yaxt="n", zlim=c(0,10))
#Western US
rect(Lon[188],Lat[124],Lon[210],Lat[149], border="red",lwd=2)
#Northern Europe
#rect(Lon[3],Lat[155],Lon[53],Lat[173], border="red",lwd=2)
#Amazon basin
#rect(Lon[221],Lat[80],Lon[260],Lat[105], border="red",lwd=2)
#Central Eurasia
rect(Lon[8],Lat[136],Lon[112],Lat[157], border="red",lwd=2)
#Middle East
rect(Lon[30],Lat[110],Lon[55],Lat[135], border="red",lwd=2)

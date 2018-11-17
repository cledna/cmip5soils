###############################
## Extract OzFlux ##
## April 2015 ##
rm(list=ls())
library(RNetCDF)
library(ncdf)
library(fields)

dir = "C:/TheStargate/AdelaideRiver_2007_L3_Ts_nc3.nc"
Adelaide.nc<-open.nc(dir)
print.nc(Adelaide.nc)
Adelaide.ts = var.get.nc(Adelaide.nc,"Ts")
Adelaide.time = var.get.nc(Adelaide.nc,"time")
length(Adelaide.ts)
length(Adelaide.time)

test<-"F:/Observations/Romanovsky/IPY_TSP_data_netcdf_withfigures/IPY_TSP_data_netcdf/barrow2_07__barrow2_08.nc"
test.nc=open.nc(test)
print.nc(test.nc)

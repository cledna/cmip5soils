# Mesonet Analysis Part 2 #

library(abind)
### Evaluate drought severity over record period ###

# Standard Data Handling:
# 1) Import csv and replace -999 with NA
# 2) Add DECYEAR Column
# 3) Reorganize into 3D array, compute timeseries for site average and sd

Reorg3D<-function(DF,StartCol){
  Days<-round((0:(nrow(VWC)/136-1)/365.25),4)+1994
  DFArray<-array(unlist(DF[StartCol:ncol(DF)]),dim=c(136,length(Days),(ncol(DF)-StartCol+1)),dimnames=list(unique(DF$STID),Days,names(DF)[StartCol:ncol(DF)]))
  MEAN<-apply(DFArray,c(2,3),mean,na.rm=TRUE)
  SD<-apply(DFArray,c(2,3),sd,na.rm=TRUE)  
  DFArray<-abind(DFArray,MEAN,SD,along=1,make.names=TRUE)
}
# Plot network average and +/- 1 SD as timeseries
# Precip
# Air and Soil temps
Temp<-read.csv("F:/Observations/Mesonet/Mesonet.csv", header=TRUE)
dim(Temp);names(Temp)
Temp[Temp== -999]<-NA
Temp[Temp== -996]<-NA
Temp.arr<-Reorg3D(Temp,StartCol=7)
dimnames(Temp.arr)[[3]]

#Plot timeseries of mean and confidence band (1 SD)
PlotTS<-function(Array,Var,ylim,Ylab){
  plot(Array["MEAN",,Var]~Days, type="l", ylim=ylim, tck=0.03, ylab=Ylab,xlab="Year",cex.lab=1.6, cex.axis=1.4,mgp=c(2, 0.5, 0))
  polygon(c(Days,rev(Days)),c((Array["MEAN",,Var]-Array["SD",,Var]),rev(Array["MEAN",,Var]+Array["SD",,Var])), col="grey", border=NA)
  lines(Array["MEAN",,Var]~Days)
  Trend<-lm(Array["MEAN",,Var]~Days)
  print(summary(Trend))
  abline(Trend,col="blue")  
}
par(mfrow=c(3,1),mar=c(2,4,0,0))
PlotTS(Temp.arr,"TA",c(0,100),"Air Temp (F)")
PlotTS(Temp.arr,"TS.5sod",c(0,100),"5cm soil temp, sod (F)")
PlotTS(Temp.arr,"TS.5bare",c(0,100),"5cm soil temp, bare (F)")


# Soil moisture
VWC<-read.csv("F:/Observations/Mesonet/29615220/SoilMoisture.csv")
dim(VWC);names(VWC)
VWC[VWC== -999]<-NA
VWC.arr<-Reorg3D(VWC,StartCol=5)

#Plot timeseries of mean and confidence band (1 SD)
plot(VWC.arr["MEAN",,1]~Days, type="l", ylim=c(-1000,1000), tck=0.03, ylab="Soil Moisture (v/v)",xlab="Year",cex.lab=1.6, cex.axis=1.4,mgp=c(2, 0.5, 0))
polygon(c(Days,rev(Days)),c((VWC.arr["MEAN",,1]-VWC.arr["SD",,1]),rev(VWC.arr["MEAN",,1]+VWC.arr["SD",,1])), col="grey", border=NA)
lines(VWC.arr["MEAN",,1]~Days)


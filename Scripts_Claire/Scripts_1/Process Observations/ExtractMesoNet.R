# Plot Mesonet soil temperatures from Oklahoma #
# Sept 18, 2014 #
rm(list=ls())
library(stats)

Data<-read.csv("F:/Observations/Mesonet/Mesonet.csv", header=TRUE)
dim(Data);names(Data)

Sites<-unique(Data$STID)

#Convert from F to C
Data[,7:11]<-(Data[,7:11]-32)*5/9
Data[Data<(-70)]<-NA

Years<-1994:2013

LongtermResults<-data.frame(Site=Sites,Mean.Air=rep(0,length(Sites)),Mean.5sod=rep(0,length(Sites)),Mean.10sod=rep(0,length(Sites)),Mean.30sod=rep(0,length(Sites)),Mean.5bare=rep(0,length(Sites)),DT.Air=rep(0,length(Sites)),se.Air=rep(0,length(Sites)),pvalue.Air=rep(0,length(Sites)),DT.5sod=rep(0,length(Sites)),se.5sod=rep(0,length(Sites)),pvalue.5sod=rep(0,length(Sites)),DT.10sod=rep(0,length(Sites)),se.10sod=rep(0,length(Sites)),pvalue.10sod=rep(0,length(Sites)),DT.30sod=rep(0,length(Sites)),se.30sod=rep(0,length(Sites)),pvalue.30sod=rep(0,length(Sites)),DT.5bare=rep(0,length(Sites)),se.5bare=rep(0,length(Sites)),pvalue.5bare=rep(0,length(Sites)),Years.Air=rep(0,length(Sites)),Years.5sod=rep(0,length(Sites)),Years.10sod=rep(0,length(Sites)),Years.30sod=rep(0,length(Sites)),Years.5bare=rep(0,length(Sites)),FirstYear.5sod=rep(0,length(Sites)),FirstYear.5bare=rep(0,length(Sites)))

library(zoo)
library(GeneCycle)
library(timeSeries)
pdf("F:/Observations/Mesonet/MesonetPlots2.pdf",onefile=TRUE)

for(i in 1:length(Sites)){
  temp<-Data[Data$STID==Sites[i],]
  temp$time<-temp$DECDATE-min(temp$DECDATE)+1
  temp.ts<-ts(data=temp[,c("TA","TS.10sod","TS.5sod","TS.5bare","TS.30sod")],start=1,deltat=1/365)
  temp.ts<-ts(data=temp[,c("TS.5sod")],start=1,deltat=1/365)
  temp.na<-na.omit(temp[,c("TA","DECDATE")])
  TA.lw<-loess(TA~DECDATE,data=temp.na, span=1/((max(floor(temp.na$DECDATE))-min(floor(temp.na$DECDATE)))*52)) #span = approximately weekly average
  #plot(TA~DECDATE,data=temp.na, type="l")
  #lines(temp.na$DECDATE,TA.lw$fitted, col="yellow")
  temp.na$YEAR<-floor(temp.na$DECDATE)
  Amplitude<-mean(tapply(TA.lw$fitted,temp.na$YEAR,max)-tapply(TA.lw$fitted,temp.na$YEAR,min))
#   plot(stl(interpNA(temp.ts)))
#   Per.TA<-periodogram(na.exclude(temp.ts))
#   plot(Per.TA[["spec"]]~Per.TA[["freq"]])
#   FFT.TA<-fft(temp$TA)
#   per<-abs(fft(temp$TA-mean(temp$TA)))^2/length(temp$TA)
#   freq=(1:length(temp$TA)-1)/length(temp$TA)
#   plot(freq,per,type="h")
#   plot.frequency.spectrum(FFT.TA)

# Only keep years with >85 of records present.
  TA.N<-round(tapply(temp$TA,temp$YEAR,function(x) length(which(!is.na(x))))/tapply(temp$TA,temp$YEAR,length),2)
  KeepYears.TA<-Years[which(TA.N>0.85)]
  if(length(KeepYears.TA)>0){
    temp.TA<-temp[temp$YEAR %in% KeepYears.TA,]
    plot(TA~DECDATE,data=temp.TA, col="black", ylim=c(-20,40), type="l", xlab="Year", ylab="Degrees C",main=Sites[i],xlim=c(1994,2014))
    TA.lm<-lm(TA~DECDATE,data=temp.TA)
    abline(TA.lm, col="black")
    LongtermResults[i,7]<-as.data.frame(summary(TA.lm)["coefficients"])[2,1]
    LongtermResults[i,8]<-as.data.frame(summary(TA.lm)["coefficients"])[2,2]
    LongtermResults[i,9]<-as.data.frame(summary(TA.lm)["coefficients"])[2,4]
  }
  
  TS.5sod.N<-round(tapply(temp$TS.5sod,temp$YEAR,function(x) length(which(!is.na(x))))/tapply(temp$TS.5sod,temp$YEAR,length),2)
  KeepYears.TS.5sod<-Years[which(TS.5sod.N>0.85)]
  if(length(KeepYears.TS.5sod)>0){
    temp.TS.5sod<-temp[temp$YEAR %in% KeepYears.TS.5sod,]
    lines(TS.5sod~DECDATE,data=temp.TS.5sod, col="blue")
    TS5.lm<-lm(TS.5sod~DECDATE,data=temp.TS.5sod)
    abline(TS5.lm, col="blue")
    LongtermResults[i,10]<-as.data.frame(summary(TS5.lm)["coefficients"])[2,1]
    LongtermResults[i,11]<-as.data.frame(summary(TS5.lm)["coefficients"])[2,2]
    LongtermResults[i,12]<-as.data.frame(summary(TS5.lm)["coefficients"])[2,4]
  }
  
  TS.10sod.N<-round(tapply(temp$TS.10sod,temp$YEAR,function(x) length(which(!is.na(x))))/tapply(temp$TS.10sod,temp$YEAR,length),2)
  KeepYears.TS.10sod<-Years[which(TS.10sod.N>0.85)]
  if(length(KeepYears.TS.10sod)>0){
    temp.TS.10sod<-temp[temp$YEAR %in% KeepYears.TS.10sod,]
    lines(TS.10sod~DECDATE,data=temp.TS.10sod, col="forest green")
    TS10.lm<-lm(TS.10sod~DECDATE,data=temp.TS.10sod)
    abline(TS10.lm, col="forest green")
    LongtermResults[i,13]<-as.data.frame(summary(TS10.lm)["coefficients"])[2,1]
    LongtermResults[i,14]<-as.data.frame(summary(TS10.lm)["coefficients"])[2,2]
    LongtermResults[i,15]<-as.data.frame(summary(TS10.lm)["coefficients"])[2,4]
  }
  
  TS.30sod.N<-round(tapply(temp$TS.30sod,temp$YEAR,function(x) length(which(!is.na(x))))/tapply(temp$TS.30sod,temp$YEAR,length),2)
  KeepYears.TS.30sod<-Years[which(TS.30sod.N>0.85)]
  if(length(KeepYears.TS.30sod)>0){
    temp.TS.30sod<-temp[temp$YEAR %in% KeepYears.TS.30sod,]
    lines(TS.30sod~DECDATE,data=temp.TS.30sod, col="green")
    TS30.lm<-lm(TS.30sod~DECDATE,data=temp.TS.30sod)
    abline(TS30.lm, col="green")
    LongtermResults[i,16]<-as.data.frame(summary(TS30.lm)["coefficients"])[2,1]
    LongtermResults[i,17]<-as.data.frame(summary(TS30.lm)["coefficients"])[2,2]
    LongtermResults[i,18]<-as.data.frame(summary(TS30.lm)["coefficients"])[2,4]
  }
  
  TS.5bare.N<-round(tapply(temp$TS.5bare,temp$YEAR,function(x) length(which(!is.na(x))))/tapply(temp$TS.5bare,temp$YEAR,length),2)
  KeepYears.TS.5bare<-Years[which(TS.5bare.N>0.85)]
  if(length(KeepYears.TS.5bare)>0){
    temp.TS.5bare<-temp[temp$YEAR %in% KeepYears.TS.5bare,]
    lines(TS.5bare~DECDATE,data=temp.TS.5bare, col="orange")
    TS5bare.lm<-lm(TS.5bare~DECDATE,data=temp.TS.5bare)
    abline(TS5.lm, col="orange")
    LongtermResults[i,19]<-as.data.frame(summary(TS5bare.lm)["coefficients"])[2,1]
    LongtermResults[i,20]<-as.data.frame(summary(TS5bare.lm)["coefficients"])[2,2]
    LongtermResults[i,21]<-as.data.frame(summary(TS5bare.lm)["coefficients"])[2,4]
  }
 
  if(exists("temp.TA")){LongtermResults[i,2]<-mean(temp.TA[,"TA"],na.rm=TRUE)}
  if(exists("temp.TS.5sod")){LongtermResults[i,3]<-mean(temp.TS.5sod[,"TS.5sod"],na.rm=TRUE)}
  if(exists("temp.TS.10sod")){LongtermResults[i,4]<-mean(temp.TS.10sod[,"TS.10sod"],na.rm=TRUE)}
  if(exists("temp.TS.30sod")){LongtermResults[i,5]<-mean(temp.TS.30sod[,"TS.30sod"],na.rm=TRUE)}
  if(exists("temp.TS.5bare")){LongtermResults[i,6]<-mean(temp.TS.5bare[,"TS.5bare"],na.rm=TRUE)}
  
  LongtermResults[i,22]<-length(KeepYears.TA)
  LongtermResults[i,23]<-length(KeepYears.TS.5sod)
  LongtermResults[i,24]<-length(KeepYears.TS.10sod)
  LongtermResults[i,25]<-length(KeepYears.TS.30sod)
  LongtermResults[i,26]<-length(KeepYears.TS.5bare)
  
  if(length(KeepYears.TS.5sod)>0){
    Yr<-min(KeepYears.TS.5sod[which(KeepYears.TS.5sod%in%KeepYears.TA)])
    LongtermResults[i,27]<-mean(temp.TS.5sod[temp.TS.5sod$YEAR==Yr,"TS.5sod"],na.rm=TRUE)-mean(temp.TA[temp.TA$YEAR==Yr,"TA"],na.rm=TRUE)
  }
  if(length(KeepYears.TS.5bare)>0){
    Yr<-min(KeepYears.TS.5bare[which(KeepYears.TS.5bare%in%KeepYears.TA)])
    LongtermResults[i,28]<-mean(temp.TS.5bare[temp.TS.5bare$YEAR==Yr,"TS.5bare"],na.rm=TRUE)-mean(temp.TA[temp.TA$YEAR==Yr,"TA"],na.rm=TRUE)
  
}
}
dev.off()

write.table(LongtermResults,file="F:/Observations/Mesonet/MesonetTrends.csv",sep=",",row.names=FALSE)

# Look at the output and decide which sites are wacky. Record in "Mesonet Trends QC.csv"
QCFlag<-read.csv("F:/Observations/Mesonet/MesonetTrendsQC.csv")
LongtermResults<-cbind(LongtermResults,QCFlag=QCFlag[,2])

## Calculate average profiles from monthly data in order to compare to CMIP5
## Caculate monthly averages
Depths<-c(200,-5,-10,-30)
Cols<-c("StartYr","StopYr","Mean","Min","Max")
MonResults<-as.data.frame(matrix(data=NA,nrow=nrow(QCFlag[QCFlag$QCFlag==FALSE,]),ncol=21,dimnames=list(NULL,c("Site",paste("TA",Cols,sep="."),paste("TS.5sod",Cols,sep="."),paste("TS.10sod",Cols,sep="."),paste("TS.30sod",Cols,sep=".")))))

Data<-read.csv("F:/Observations/Mesonet/Mesonet.csv", header=TRUE)
dim(Data);names(Data)
Sites<-unique(Data$STID)

#Convert from F to C
Data[,7:11]<-(Data[,7:11]-32)*5/9
Data[Data<(-70)]<-NA

pdf("F:/Observations/Mesonet/MesonetProfilesMonthly.pdf",onefile=TRUE)
par(mfrow=c(3,5),mar=c(0,0,2,0),oma=c(5,5,1,4), tck=0.03, mgp=c(2,0.5,0))

  for(i in 1:length(Sites)){
    #Check to see if the site was blacklisted for too few data
    Flag<-QCFlag[QCFlag$Site==Sites[i],"QCFlag"]
    if(!QCFlag[QCFlag$Site==Sites[i],"QCFlag"]) temp<-Data[Data$STID==Sites[i],] else next()
    
    MonResults[i,"Site"]<-as.character(Sites[i])
    
    #Calcualte monthly means for TA
    TA.N<-round(tapply(temp$TA,temp$YEAR,function(x) length(which(!is.na(x))))/tapply(temp$TA,temp$YEAR,length),2)
    KeepYears.TA<-Years[which(TA.N>0.85)]
    if(length(KeepYears.TA)>0){
      temp.TA<-temp[temp$YEAR %in% KeepYears.TA,]
      TA.month<-tapply(temp.TA$TA,temp.TA$MONTH,mean, na.rm=TRUE)
      MonResults[i,"TA.StartYr"]<-min(KeepYears.TA,na.rm=TRUE)
      MonResults[i,"TA.StopYr"]<-max(KeepYears.TA,na.rm=TRUE)
      MonResults[i,"TA.Min"]<-min(TA.month)
      MonResults[i,"TA.Mean"]<-mean(TA.month)
      MonResults[i,"TA.Max"]<-max(TA.month)
    }
    
    TS.5sod.N<-round(tapply(temp$TS.5sod,temp$YEAR,function(x) length(which(!is.na(x))))/tapply(temp$TS.5sod,temp$YEAR,length),2)
    KeepYears.TS.5sod<-Years[which(TS.5sod.N>0.85)]
    if(length(KeepYears.TS.5sod)>0){
      temp.TS.5sod<-temp[temp$YEAR %in% KeepYears.TS.5sod,]
      TS.5sod.month<-tapply(temp.TS.5sod$TS.5sod,temp.TS.5sod$MONTH,mean, na.rm=TRUE)
      MonResults[i,"TS.5sod.StartYr"]<-min(KeepYears.TS.5sod,na.rm=TRUE)
      MonResults[i,"TS.5sod.StopYr"]<-max(KeepYears.TS.5sod,na.rm=TRUE)
      MonResults[i,"TS.5sod.Min"]<-min(TS.5sod.month)
      MonResults[i,"TS.5sod.Mean"]<-mean(TS.5sod.month)
      MonResults[i,"TS.5sod.Max"]<-max(TS.5sod.month)
    }
    
    TS.10sod.N<-round(tapply(temp$TS.10sod,temp$YEAR,function(x) length(which(!is.na(x))))/tapply(temp$TS.10sod,temp$YEAR,length),2)
    KeepYears.TS.10sod<-Years[which(TS.10sod.N>0.85)]
    if(length(KeepYears.TS.10sod)>0){
      temp.TS.10sod<-temp[temp$YEAR %in% KeepYears.TS.10sod,]
      TS.10sod.month<-tapply(temp.TS.10sod$TS.10sod,temp.TS.10sod$MONTH,mean, na.rm=TRUE)
      MonResults[i,"TS.10sod.StartYr"]<-min(KeepYears.TS.10sod,na.rm=TRUE)
      MonResults[i,"TS.10sod.StopYr"]<-max(KeepYears.TS.10sod,na.rm=TRUE)
      MonResults[i,"TS.10sod.Min"]<-min(TS.10sod.month)
      MonResults[i,"TS.10sod.Mean"]<-mean(TS.10sod.month)
      MonResults[i,"TS.10sod.Max"]<-max(TS.10sod.month)
    }
    
    TS.30sod.N<-round(tapply(temp$TS.30sod,temp$YEAR,function(x) length(which(!is.na(x))))/tapply(temp$TS.30sod,temp$YEAR,length),2)
    KeepYears.TS.30sod<-Years[which(TS.30sod.N>0.85)]
    if(length(KeepYears.TS.30sod)>0){
      temp.TS.30sod<-temp[temp$YEAR %in% KeepYears.TS.30sod,]
      TS.30sod.month<-tapply(temp.TS.30sod$TS.30sod,temp.TS.30sod$MONTH,mean, na.rm=TRUE)
      MonResults[i,"TS.30sod.StartYr"]<-min(KeepYears.TS.30sod,na.rm=TRUE)
      MonResults[i,"TS.30sod.StopYr"]<-max(KeepYears.TS.30sod,na.rm=TRUE)
      MonResults[i,"TS.30sod.Min"]<-min(TS.30sod.month)
      MonResults[i,"TS.30sod.Mean"]<-mean(TS.30sod.month)
      MonResults[i,"TS.30sod.Max"]<-max(TS.30sod.month)
    }
    
    plot(Depths~unlist(MonResults[i,c("TA.Mean","TS.5sod.Mean","TS.10sod.Mean","TS.30sod.Mean")]),type="o",xlim=c(-20,35),ylim=c(-500,300),pch=16)
    lines(MonResults[i,c("TA.Min","TS.5sod.Min","TS.10sod.Min","TS.30sod.Min")],Depths,type="o",col="blue",pch=16)
    lines(MonResults[i,c("TA.Max","TS.5sod.Max","TS.10sod.Max","TS.30sod.Max")],Depths,type="o",col="red",pch=16)
    abline(h=0,col="grey")
    text(7,255,as.character(Sites[i]),adj=c(0.5,0.5),cex=1.3)
  }
dev.off()
Mean<-apply(MonResults[1:136,2:21],2,mean,na.rm=TRUE)
MonResults[137,"Site"]<-"MEAN"
MonResults[137,2:21]<-Mean
SD<-apply(MonResults[1:136,2:21],2,sd,na.rm=TRUE)
MonResults[138,"Site"]<-"SD"
MonResults[138,2:21]<-SD

# Plot montly mean/max/min by depth
plot(Depths~unlist(MonResults[137,c("TA.Mean","TS.5sod.Mean","TS.10sod.Mean","TS.30sod.Mean")]),type="o",xlim=c(-20,35),ylim=c(-500,300),pch=16)
  arrows(unlist(MonResults[137,c("TA.Mean","TS.5sod.Mean","TS.10sod.Mean","TS.30sod.Mean")]),Depths,unlist(MonResults[137,c("TA.Mean","TS.5sod.Mean","TS.10sod.Mean","TS.30sod.Mean")])+unlist(MonResults[138,c("TA.Mean","TS.5sod.Mean","TS.10sod.Mean","TS.30sod.Mean")]),Depths,length=0,angle=90)
  arrows(unlist(MonResults[137,c("TA.Mean","TS.5sod.Mean","TS.10sod.Mean","TS.30sod.Mean")]),Depths,unlist(MonResults[137,c("TA.Mean","TS.5sod.Mean","TS.10sod.Mean","TS.30sod.Mean")])-unlist(MonResults[138,c("TA.Mean","TS.5sod.Mean","TS.10sod.Mean","TS.30sod.Mean")]),Depths,length=0,angle=90)
lines(MonResults[137,c("TA.Min","TS.5sod.Min","TS.10sod.Min","TS.30sod.Min")],Depths,type="o",col="blue",pch=16)
  arrows(unlist(MonResults[137,c("TA.Min","TS.5sod.Min","TS.10sod.Min","TS.30sod.Min")]),Depths,unlist(MonResults[137,c("TA.Min","TS.5sod.Min","TS.10sod.Min","TS.30sod.Min")])+unlist(MonResults[138,c("TA.Min","TS.5sod.Min","TS.10sod.Min","TS.30sod.Min")]),Depths,length=0,angle=90, col="blue")
  arrows(unlist(MonResults[137,c("TA.Min","TS.5sod.Min","TS.10sod.Min","TS.30sod.Min")]),Depths,unlist(MonResults[137,c("TA.Min","TS.5sod.Min","TS.10sod.Min","TS.30sod.Min")])-unlist(MonResults[138,c("TA.Min","TS.5sod.Min","TS.10sod.Min","TS.30sod.Min")]),Depths,length=0,angle=90, col="blue")
lines(MonResults[137,c("TA.Max","TS.5sod.Max","TS.10sod.Max","TS.30sod.Max")],Depths,type="o",col="red",pch=16)
  arrows(unlist(MonResults[137,c("TA.Max","TS.5sod.Max","TS.10sod.Max","TS.30sod.Max")]),Depths,unlist(MonResults[137,c("TA.Max","TS.5sod.Max","TS.10sod.Max","TS.30sod.Max")])+unlist(MonResults[138,c("TA.Max","TS.5sod.Max","TS.10sod.Max","TS.30sod.Max")]),Depths,length=0,angle=90, col="red")
  arrows(unlist(MonResults[137,c("TA.Max","TS.5sod.Max","TS.10sod.Max","TS.30sod.Max")]),Depths,unlist(MonResults[137,c("TA.Max","TS.5sod.Max","TS.10sod.Max","TS.30sod.Max")])-unlist(MonResults[138,c("TA.Max","TS.5sod.Max","TS.10sod.Max","TS.30sod.Max")]),Depths,length=0,angle=90, col="red")
abline(h=0,col="grey")
text(7,255,"Oklahoma Mean",adj=c(0.5,0.5),cex=1.3)
write.table(MonResults,"F:/Observations/Mesonet/MesonetProfilesMonthly.csv",sep=",",row.names=FALSE)

#Flag sites where there are fewer air years than soil years
# and where there are 10 years or less usable data
# LongtermResults$QCFlag<-rep(FALSE,nrow(LongtermResults))
# OmitRows<-which(LongtermResults$Years.Air<11)
# OmitRows2<-0
# for(i in 1:nrow(LongtermResults)){
#   if(LongtermResults$Years.Air[i]<LongtermResults$Years.5sod[i]) OmitRows2<-c(OmitRows2,i)
# }
# OmitRows2<-OmitRows2[-1]
#LongtermResults[OmitRows,"QCFlag"]<-TRUE

LongtermPlot<-LongtermResults[LongtermResults$QCFlag==FALSE,]
names(LongtermPlot) #nrows=106
par(tck=0.03, mgp=c(2,0.5,0))
boxplot(LongtermPlot[,2:6],names=c("Air","5 cm sod","10 cm sod","30 cm sod","5 cm bare"), ylab=expression(Mean~Temperature~group("(",symbol(degree)~C,")")),cex.lab=1.4,cex.axis=1.2)

par(tck=0.03, mgp=c(2,0.5,0))
boxplot(LongtermPlot[,c(7,10,13,16,19)],ylim=c(-0.25,0.25),names=c("Air","5 cm sod","10 cm sod","30 cm sod","5 cm bare"), ylab=expression(Temperature~change~group("(",symbol(degree)~C~yr^{-1},")")),cex.lab=1.4,cex.axis=1.2)

dT.N<-data.frame(N.Air=length(LongtermPlot$DT.Air>0),N.5sod=length(LongtermPlot$DT.5sod>0),N.10sod=length(LongtermPlot$DT.10sod>0),N.30sod=length(LongtermPlot$DT.30sod>0),N.5bare=length(LongtermPlot$DT.5bare>0))
# 106 sites for each

TempDiffs<-data.frame(TS.5sod=LongtermPlot$Mean.5sod-LongtermPlot$Mean.Air,TS.10sod=LongtermPlot$Mean.10sod-LongtermPlot$Mean.Air,TS.30sod=LongtermPlot$Mean.30sod-LongtermPlot$Mean.Air,TS.5bare=LongtermPlot$Mean.5bare-LongtermPlot$Mean.Air)

DTDiffs<-data.frame(TS.5sod=LongtermPlot$DT.5sod-LongtermPlot$DT.Air,TS.10sod=LongtermPlot$DT.10sod-LongtermPlot$DT.Air,TS.30sod=LongtermPlot$DT.30sod-LongtermPlot$DT.Air,TS.5bare=LongtermPlot$DT.5bare-LongtermPlot$DT.Air)

plot(DTDiffs$TS.5sod~LongtermPlot$FirstYear.5sod,ylab=expression(DT[soil]-DT[air]~group("(",symbol(degree)~C~yr^{-1},")")),xlab=(MAST-MAAT~group("(",symbol(degree)~C,")")),pch=16)
points(DTDiffs$TS.5bare~LongtermPlot$FirstYear.5bare,col="blue",pch=17)
abline(lm(DTDiffs$TS.5sod~TempDiffs$TS.5sod),col="black")
abline(lm(DTDiffs$TS.5bare~TempDiffs$TS.5bare),col="blue")
legend(x="topleft",legend=c("5 cm under sod","5 cm bare soil"),pch=16:17, col=c("black","blue"))

#Stats
ttest.5sod<-t.test(LongtermPlot$Mean.5sod,LongtermPlot$Mean.Air,paired=TRUE)
print(ttest.5sod)
# Paired t-test
# 
# data:  LongtermPlot$Mean.5sod and LongtermPlot$Mean.Air
# t = 12.1626, df = 105, p-value < 2.2e-16
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   0.5994866 0.8330213
# sample estimates:
#   mean of the differences 
# 0.716254 

ttest.10sod<-t.test(LongtermPlot$Mean.10sod,LongtermPlot$Mean.Air,paired=TRUE)
print(ttest.10sod)
# Paired t-test
# 
# data:  LongtermPlot$Mean.10sod and LongtermPlot$Mean.Air
# t = 16.9876, df = 105, p-value < 2.2e-16
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   0.6199941 0.7838527
# sample estimates:
#   mean of the differences 
# 0.7019234 

ttest.30sod<-t.test(LongtermPlot$Mean.30sod,LongtermPlot$Mean.Air,paired=TRUE)
print(ttest.30sod)
# Paired t-test
# 
# data:  LongtermPlot$Mean.30sod and LongtermPlot$Mean.Air
# t = 13.6748, df = 105, p-value < 2.2e-16
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   0.6718162 0.8996799
# sample estimates:
#   mean of the differences 
# 0.785748 

ttest.5bare<-t.test(LongtermPlot$Mean.5bare,LongtermPlot$Mean.Air,paired=TRUE)
print(ttest.5bare)
# Paired t-test
# 
# data:  LongtermPlot$Mean.5bare and LongtermPlot$Mean.Air
# t = 26.6775, df = 105, p-value < 2.2e-16
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   1.303950 1.513347
# sample estimates:
#   mean of the differences 
# 1.408648 

#aov
Depth<-c(rep("5sod",nrow(LongtermPlot),rep("10sod",nrow(LongtermPlot),rep("30sod",nrow(LongtermPlot),rep("5bare",nrow(LongtermPlot))
DiffFromAir<-c(TempDiffs[,1],TempDiffs[,2],TempDiffs[,3],TempDiffs[,4])                                                                       
TempDiffs.aov<-aov(DiffFromAir~Depth)

#Temperature change
ttest.DT5sod<-t.test(LongtermPlot$DT.5sod,LongtermPlot$DT.Air,paired=TRUE)
print(ttest.DT5sod)

ttest.DT10sod<-t.test(LongtermPlot$DT.10sod,LongtermPlot$DT.Air,paired=TRUE)
print(ttest.DT10sod)

ttest.DT30sod<-t.test(LongtermPlot$DT.30sod,LongtermPlot$DT.Air,paired=TRUE)
print(ttest.DT30sod)

ttest.DT5bare<-t.test(LongtermPlot$DT.5bare,LongtermPlot$DT.Air,paired=TRUE)
print(ttest.DT5bare)

# Paired t-test
# 
# data:  LongtermPlot$DT.5sod and LongtermPlot$DT.Air
# t = 7.0452, df = 105, p-value = 2.008e-10
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   0.02649711 0.04725372
# sample estimates:
#   mean of the differences 
# 0.03687541 
# 
# Paired t-test
# 
# data:  LongtermPlot$DT.10sod and LongtermPlot$DT.Air
# t = 8.2465, df = 105, p-value = 5.029e-13
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   0.02793910 0.04562783
# sample estimates:
#   mean of the differences 
# 0.03678346 
# 
# 
# Paired t-test
# 
# data:  LongtermPlot$DT.30sod and LongtermPlot$DT.Air
# t = 8.839, df = 105, p-value = 2.442e-14
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   0.03637015 0.05740670
# sample estimates:
#   mean of the differences 
# 0.04688843 
# 
# 
# Paired t-test
# 
# data:  LongtermPlot$DT.5bare and LongtermPlot$DT.Air
# t = 8.4383, df = 105, p-value = 1.896e-13
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   0.03031973 0.04894530
# sample estimates:
#   mean of the differences 
# 0.03963251

Depth<-c(5,10,30)
Temp.mean<-c(16.41,16.40,16.45)
Temp.min<-c(4.96,5.24,6.27)
Temp.max<-c(27.77,27.39,26.63)
plot(Temp.mean~Depth,ylim=c(4,28))
points(Temp.min~Depth, col="blue")
points(Temp.max~Depth, col="red")
lm.mean<-lm(Temp.mean~Depth)
lm.min<-lm(Temp.min~Depth)
lm.max<-lm(Temp.max~Depth)
abline(lm.mean);abline(lm.min,col="blue");abline(lm.max,col="red")
predict(lm.mean,newdata=data.frame(Depth=c(1,100)))
predict(lm.min,newdata=data.frame(Depth=c(1,100)))
predict(lm.max,newdata=data.frame(Depth=c(1,100)))


Amplitude<-c(22.8,22.15,20.36)
ln.Amp<-log(Amplitude)
plot(Amplitude~Depth)
plot(ln.Amp~Depth)
Amp.lm<-lm(ln.Amp~Depth)
summary(Amp.lm)
abline(Amp.lm,col="blue")


# Call:
#   lm(formula = ln.Amp ~ Depth)
# 
# Residuals:
#   1          2          3 
# 0.0029930 -0.0037413  0.0007483 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)  3.1459562  0.0047912  656.61  0.00097 ***
#   Depth       -0.0044377  0.0002592  -17.12  0.03714 *  
#   ---
#   Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
# 
# Residual standard error: 0.004849 on 1 degrees of freedom
# Multiple R-squared:  0.9966,  Adjusted R-squared:  0.9932 

Amp<-exp(predict(Amp.lm,newdata=data.frame(Depth=c(1,100))))
plot(c(Depth,1,100),c(Amplitude,Amp))
Amp/24.33 #Air temp amplitude
#Mean attenuation for Air v 1cm, and 1cm v 1m depth
#1cm         100cm 
#0.9510471 0.644436

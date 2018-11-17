## Combine years of SCAN records and plot air vs soil temperature ##

rm(list=ls())
Folder<-"F:/Observations/PuertoRico/Combate/"
SiteFiles<-list.files(Folder)

Site<-read.csv(paste(Folder,SiteFiles[1],sep=""),skip=2)
dim(Site);names(Site)
Days<-c(nrow(Site),rep(NA,length(SiteFiles)-1))
Ncol<-rep(ncol(Site),length(SiteFiles))

for(i in 2:length(SiteFiles)){
  temp<-read.csv(paste(Folder,SiteFiles[i],sep=""),skip=2)
  Days[i]<-nrow(temp)
  #print(colnames(temp))
  Ncol[i]<-ncol(temp)
  Site<-rbind(Site,temp) 
}
Ncol;Days
dim(Site);names(Site)
#dim(temp);names(temp)
#Site$Year<-rep(2002:2013,times=Days)
#Site$Year<-rep(2005:2013,times=Days)
Time2<-as.POSIXlt(strptime(as.character(Site$Date),format='%m/%d/%Y'))
Site$Year<-Time2$year+1900

SiteTemp<-Site[,c(2,4,7,8,15,16,24)]
colnames(SiteTemp)<-c("Date","Precip","Tas","Tas2","Tsl.2cm","Tsl.4cm","Tsl.40cm")
SiteTemp$Precip<-SiteTemp$Precip*2.54 #Convert rainfall from in to cm
SiteTemp$Date<-as.POSIXlt(strptime(as.character(SiteTemp$Date),format='%m/%d/%Y'))
SiteTemp$DecYear<-SiteTemp$Date$yday/365+SiteTemp$Date$year+1900
SiteTemp$Year<-SiteTemp$Date$year+1900

SiteTemp[SiteTemp== -99.9]<-NA
SiteTemp$Tsl.2cm[SiteTemp$Tsl.2cm<0]<-NA
SiteTemp$Tas.avg<-apply(SiteTemp[,c(3,4)],1,mean,na.rm=TRUE)
SiteTemp$Tas.avg[SiteTemp$Tas.avg>35]<-NA
SiteTemp$Tas.avg[SiteTemp$Tas.avg<15]<-NA
SiteTemp$Tsl.2cm[SiteTemp$Tsl.2cm<20]<-NA
SiteTemp$Tsl.2cm[SiteTemp$Tsl.2cm>35]<-NA

plot(Tas.avg~DecYear,data=SiteTemp,type="l", ylim=c(17,37))
#lines(Tas2~DecYear,data=SiteTemp,col="grey")
lines(Tsl.2cm~DecYear,data=SiteTemp,col="blue")
#lines(Tsl.4cm~DecYear,data=SiteTemp,col="red")
lines(Tsl.40cm~DecYear,data=SiteTemp,col="brown")

Tas.lm<-lm(Tas~Days,data=SiteTemp)
summary(Tas.lm)
abline(Tas.lm,lwd=2)
Tsl.2cm.lm<-lm(Tsl.2cm~Days,data=SiteTemp)
summary(Tsl.2cm.lm)
abline(Tsl.2cm.lm,lwd=2,col="blue")

SiteTemp$TempDiff.2<-SiteTemp$Tsl.2cm-SiteTemp$Tas.avg
plot(TempDiff.2~Days,data=SiteTemp,type="l")
abline(h=0,lwd=2,col="grey",lty=2)

#Use only years 2002, 2005-2008, 2013 
TempDiff.annual<-tapply(SiteTemp$TempDiff.2,SiteTemp$Year,mean,na.rm=TRUE)
Tas.annual<-tapply(SiteTemp$Tas.avg,SiteTemp$Year,mean,na.rm=TRUE)
Tsl.2cm.annual<-tapply(SiteTemp$Tsl.2cm,SiteTemp$Year,mean,na.rm=TRUE)
Tsl.4cm.annual<-tapply(SiteTemp$Tsl.4cm,SiteTemp$Year,mean,na.rm=TRUE)
Tsl.40cm.annual<-tapply(SiteTemp$Tsl.40cm,SiteTemp$Year,mean,na.rm=TRUE)

Tas.annual[c(2,3,8,9)]<-NA
Tsl.2cm.annual[c(2,3,8,9)]<-NA
Tsl.4cm.annual[c(2,3,8,9)]<-NA
Tsl.40cm.annual[c(2,3,8,9)]<-NA

Tas.annual
Tsl.2cm.annual
Tsl.4cm.annual
Tsl.40cm.annual

YEAR<-c(2002:2009,2012:2013)
plot(YEAR,TempDiff.annual,type="o")
diff.lm<-lm(TempDiff.annual~YEAR)
abline(diff.lm)
summary(diff.lm)

Tas.mean<-mean(Tas.annual,na.rm=TRUE)
Tsl.2cm.mean<-mean(Tsl.2cm.annual,na.rm=TRUE)
Tsl.4cm.mean<-mean(Tsl.4cm.annual,,na.rm=TRUE)
Tsl.40cm.mean<-mean(Tsl.40cm.annual,,na.rm=TRUE)
TempDiff.mean<-mean(TempDiff.annual,na.rm=TRUE)

Tas.mean
Tsl.2cm.means
Tsl.4cm.mean
Tsl.40cm.mean
TempDiff.mean

plot(Tas.annual~YEAR,type="o",ylim=c(17,37),pch=16, cex=1.4, ylab="Temperature (C)",xlab="Year",cex.lab=1.6, tck=0.03, mgp=c(2,0.5,0),cex.axis=1.2, main="Combate, Puerto Rico", cex.main=1.6)
lines(Tsl.2cm.annual~YEAR,type="o", col="blue",pch=16, cex=1.4)
lines(Tsl.40cm.annual~YEAR,type="o",col="brown",pch=16, cex=1.4)
legend(x="topright",legend=c("Air","Soil 2 cm","Soil 40 cm"),bty="n",pch=16,col=c("black","blue","brown"),cex=1.4)


write.csv(SiteTemp,"F:/Observations/Hawaii/Kainaliu/KainaliuTemp.csv",row.names=FALSE)

#Plot Maricao
Maricao<-read.csv("F:/Observations/PuertoRico/Maricao/MaricaoTemp.csv")
dim(Maricao);names(Maricao)

Tas.annual<-tapply(Maricao$Tas,Maricao$Year,mean,na.rm=TRUE)
Tsl.2cm.annual<-tapply(Maricao$Tsl.2cm,Maricao$Year,mean,na.rm=TRUE)
Tsl.4cm.annual<-tapply(Maricao$Tsl.4cm,Maricao$Year,mean,na.rm=TRUE)
Tsl.40cm.annual<-tapply(Maricao$Tsl.40cm,Maricao$Year,mean,na.rm=TRUE)

YEAR<-2001:2013

plot(Tas.annual~YEAR,type="o",ylim=c(17,27),pch=16, cex=1.4, ylab="Temperature (C)",xlab="Year",cex.lab=1.6, tck=0.03, mgp=c(2,0.5,0),cex.axis=1.2, main="Maricao Forest, Puerto Rico", cex.main=1.6)
lines(Tsl.2cm.annual~YEAR,type="o", col="blue",pch=16, cex=1.4)
lines(Tsl.4cm.annual~YEAR,type="o",col="green",pch=16, cex=1.4)
lines(Tsl.40cm.annual~YEAR,type="o",col="brown",pch=16, cex=1.4)
legend(x="topright",legend=c("Air","Soil 2 cm","Soil 4cm","Soil 30 cm"),bty="n",pch=16,col=c("black","blue","green","brown"),cex=1.4)
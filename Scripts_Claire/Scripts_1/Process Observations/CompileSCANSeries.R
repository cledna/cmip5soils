## Combine years of SCAN records and plot air vs soil temperature ##

rm(list=ls())
CombateFiles<-list.files("F:/Observations/PuertoRico/Combate")

Combate<-read.csv(paste("F:/Observations/PuertoRico/Combate/",CombateFiles[1],sep=""),skip=2)
dim(Combate);names(Combate)
Days<-c(nrow(Combate),rep(NA,length(CombateFiles)-1))

for(i in 2:length(CombateFiles)){
  temp<-read.csv(paste("F:/Observations/PuertoRico/Combate/",CombateFiles[i],sep=""),skip=2)
  Days[i]<-nrow(temp)
  #if(ncol(temp)>27) {print i; names(temp)}
  if(i==12) temp<-temp[,-c(5,27)]
  Combate<-rbind(Combate,temp) 
}

dim(Combate);names(Combate)
dim(temp);names(temp)
Combate$Year<-rep(2002:2013,times=Days)

#MaricaoTemp<-Maricao[,c(2,4,8,14,15,18)]
CombateTemp<-Combate[,c(2,4,7,8,15,16,19)]
colnames(CombateTemp)<-c("Date","Precip","Tas","Tas2","Tsl.2cm","Tsl.4cm","Tsl.40cm")
CombateTemp$Precip<-CombateTemp$Precip*2.54 #Convert rainfall from in to cm

CombateTemp$Days<-1:nrow(CombateTemp)
CombateTemp$DecYear<-CombateTemp$Days/365+2001
CombateTemp$Year<-floor(CombateTemp$DecYear)
CombateTemp[CombateTemp== -99.9]<-NA
CombateTemp$Tsl.2cm[CombateTemp$Tsl.2cm<0]<-NA

plot(Tas~DecYear,data=CombateTemp,type="l")
lines(Tas2~DecYear,data=CombateTemp,col="grey")
lines(Tsl.2cm~DecYear,data=CombateTemp,col="blue")
lines(Tsl.4cm~DecYear,data=CombateTemp,col="red")
lines(Tsl.40cm~DecYear,data=CombateTemp,col="brown")

Tas.lm<-lm(Tas~Days,data=CombateTemp)
summary(Tas.lm)
abline(Tas.lm,lwd=2)
Tsl.2cm.lm<-lm(Tsl.2cm~Days,data=CombateTemp)
summary(Tsl.2cm.lm)
abline(Tsl.2cm.lm,lwd=2,col="blue")

CombateTemp$TempDiff<-CombateTemp$Tsl.2cm-CombateTemp$Tas
plot(TempDiff~Years,data=CombateTemp,type="l")
abline(h=0,lwd=2,col="grey",lty=2)

AnnualTempDiff<-tapply(CombateTemp$TempDiff,CombateTemp$Year,mean,na.rm=TRUE)
plot(2001:2013,AnnualTempDiff,type="o")
YEAR<-2001:2013
diff.lm<-lm(AnnualTempDiff~YEAR)

Tas.mean<-mean(CombateTemp[CombateTemp$DecYear>=2004 & CombateTemp$DecYear<2014,"Tas"],na.rm=TRUE)
Tsl.2cm.mean<-mean(CombateTemp[CombateTemp$DecYear>=2004 & CombateTemp$DecYear<2014,"Tsl.2cm"],na.rm=TRUE)
Tsl.4cm.mean<-mean(CombateTemp[CombateTemp$DecYear>=2004 & CombateTemp$DecYear<2014,"Tsl.4cm"],na.rm=TRUE)
Tsl.40cm.mean<-mean(CombateTemp[CombateTemp$DecYear>=2004 & CombateTemp$DecYear<2014,"Tsl.40cm"],na.rm=TRUE)
TempDiff.mean<-mean(CombateTemp[CombateTemp$DecYear>=2004 & CombateTemp$DecYear<2014,"TempDiff"],na.rm=TRUE)

write.csv(MaricaoTemp,"F:/Observations/PuertoRico/Maricao/MaricaoTemp.csv",row.names=FALSE)
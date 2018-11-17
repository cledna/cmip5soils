# Calculate mean annual air temp and soil temp for 93 AmeriFlux sites downloaded Aug 26, 2014
rm(list=ls())

Directory<-"F:/Observations/AmeriFlux/FullRecords"
Files<-list.files(Directory)
length(Files) #76
# # [1] "BR-Sa3.csv" "CA-NS1.csv" "CA-NS2.csv" "CA-NS3.csv" "CA-NS4.csv" "CA-NS5.csv" "CA-NS6.csv" "CA-NS7.csv" "MX-Lpa.csv" "US-ARb.[1] "BR-Sa3.csv" "CA-NS1.csv" "CA-NS2.csv" "CA-NS3.csv" "CA-NS4.csv" "CA-NS5.csv" "CA-NS6.csv" "CA-NS7.csv" "MX-Lpa.csv" "US-An3.csv" "US-AR1.csv" "US-AR2.csv"
# [13] "US-ARM.csv" "US-Aud.csv" "US-Bar.csv" "US-Blk.csv" "US-Blo.csv" "US-Bn1.csv" "US-Bn2.csv" "US-Bn3.csv" "US-Bo1.csv" "US-Br1.csv" "US-Br3.csv" "US-CaV.csv"
# [25] "US-Cop.csv" "US-Dk1.csv" "US-Dk2.csv" "US-Dk3.csv" "US-Elm.csv" "US-Esm.csv" "US-FPe.csv" "US-FR2.csv" "US-FR3.csv" "US-GLE.csv" "US-GMF.csv" "US-Goo.csv"
# [37] "US-Ha1.csv" "US-Ha2.csv" "US-Ho1.csv" "US-Ho2.csv" "US-Ho3.csv" "US-HVa.csv" "US-IB2.csv" "US-Ivo.csv" "US-KS1.csv" "US-KS2.csv" "US-KUT.csv" "US-LWW.csv"
# [49] "US-Me2.csv" "US-MMS.csv" "US-MOz.csv" "US-MRf.csv" "US-Ne1.csv" "US-Ne2.csv" "US-Ne3.csv" "US-NR1.csv" "US-Oho.csv" "US-Ro1.csv" "US-Ro3.csv" "US-SdH.csv"
# [61] "US-Skr.csv" "US-Slt.csv" "US-SP1.csv" "US-SP2.csv" "US-SP3.csv" "US-SRM.csv" "US-Syv.csv" "US-Ton.csv" "US-UMB.csv" "US-Var.csv" "US-WCr.csv" "US-Whs.csv"
# [73] "US-Wjs.csv" "US-Wkg.csv" "US-Wlr.csv" "US-Wrc.csv"


# Open each
# Replace -9999 with NA
# Determine complete years
# Determine depths
# Calculate mean annual temp and mean overall temp

Headers<-data.frame(matrix(data=NA,nrow=length(Files),ncol=26,dimnames=list(NULL,c("Site",paste("Col",1:25,sep="")))))

for (i in 34:length(Files)){
  Data<-read.csv(paste(Directory,Files[i],sep="/"),nrows=40,header=FALSE)
  SkipRows<-grep("Time",Data[,1])
  if (any(SkipRows)) SkipRows<-SkipRows+1 else SkipRows<-grep("Time",Data[,2]) #This can catch some format errors where Time appears in col 2
  Data<-read.csv(paste(Directory,Files[i],sep="/"),skip=SkipRows)
  test <- tryCatch(floor(Data$Time..decimal.year.), error = function(e) e) #If the SkipRows numbers was different than expected, try one less
  if(any(class(test) == "error")){
    Data<-read.csv(paste(Directory,Files[i],sep="/"),skip=SkipRows-1)
  }
  Headers[i,1]<-as.character(Data[1,1])
  Colnames<-colnames(Data)[-c(1,2)]
  if(length(Colnames)>25) Colnames<-Colnames[1:25]
  Headers[i,2:(1+length(Colnames))]<-Colnames
  print(i)
}
write.table(Headers,paste(Directory,"/Processed/Headers.csv",sep=""),row.names=FALSE)
  Data$Year<-floor(Data$Time..decimal.year.)
  Data[Data== -9999]<-NA
  Years<-unique(Data$Year)
  AirCol<-grep("TA",colnames(Data))
  SoilCol<-grep("TS",colnames(Data))
  ColNames<-colnames(Data)[c(AirCol,SoilCol)]
  ColNames<-sub("..deg.C.","",ColNames)
  
  #Get soil depths and air heights
  Depths<-colnames(Data)[SoilCol]
  Depths<-sub("TS_","",Depths)
  Depths<-sub("..deg.C.","",Depths)
  Depths<-sub(".1","",Depths) #Remove .1, which denotes a replicate
  Depths<-sub("_",".",Depths) #Replace underscore, which denotes a decimal
  Depths<-as.numeric(Depths)
  ChooseSoilZ<-min(Depths,na.rm=TRUE)
  ChooseSoilCol<-SoilCol[which(Depths==ChooseSoilZ)]
  
  Heights<-colnames(Data)[AirCol]
  Heights<-sub("TA_","",Heights)
  Heights<-sub("..deg.C.","",Heights)
  Heights<-sub(".1","",Heights) #Remove .1, which denotes a replicate
  Heights<-sub("_",".",Heights) #Replace underscore, which denotes a decimal
  Heights<-as.numeric(Heights)
  if(is.numeric(Heights)){
    Heights<-round(Heights,0)
    if(2 %in% Heights){ChooseAirCol<-AirCol[which(Heights==2)]} else ChooseAirCol<-AirCol[which(Heights==min(Heights,na.rm=TRUE))]
  }
  ChooseAirCol<-min(AirCol)
  
  Results<-matrix(data=NA,nrow=length(Years),ncol=(1+3*(ncol(Data)-3)+length(Depths)),dimnames=list(NULL,c("Year",paste("mean",ColNames,sep="."),paste("amp",ColNames,sep="."),paste("N",ColNames,sep="."),paste("DampZ",Depths,sep="."))))
  Results<-data.frame(Results)
  Results$Year<-Years
  AllDepths<-c(AirCol,SoilCol)
  for(j in 1:length(AllDepths)){
    Results[,(j+1)]<-tapply(Data[,AllDepths[j]],Data$Year,mean,na.rm=TRUE)
    Results[,(j+1+length(AllDepths))]<-tapply(Data[,AllDepths[j]],Data$Year,max,na.rm=TRUE)-tapply(Data[,AllDepths[j]],Data$Year,min,na.rm=TRUE)
    Results[,(j+1+length(AllDepths)*2)]<-round(tapply(Data[,AllDepths[j]],Data$Year,function(x) length(which(!is.na(x))))/tapply(Data[,AllDepths[j]],Data$Year,length),2)
  }
  Results
  TA.amp<-Results[,length(AllDepths)+2]
  for(j in 1:length(Depths)){
    if(is.na(Depths[j])) Z<- -5 else Z<- -Depths[j]
    Results[,(j+1+3*length(AllDepths))]<-(-Z)/(log(TA.amp)-log(Results[,(1+length(AllDepths)+length(AirCol)+j)]))
  }
  WholeYears<-Years[which(Results[,(2+length(AllDepths)*2)]>0.9)]
  Overall<-apply(Results[which(Results[,(2+length(AllDepths)*2)]>0.9),],2,mean,na.rm=TRUE)
  Overall[Overall=="NaN"]<-NA
  Overall[Overall=="-Inf"]<-NA
  Overall[Overall=="Inf"]<-NA
  Results<-rbind(Results,Overall)
  Overall.short<-na.omit(Overall)
  DampCol<-grep("DampZ",names(Overall.short))
  Damp1<-Overall.short[min(DampCol)]
  Damp1.depth<-sub("DampZ.","",names(Overall.short)[min(DampCol)])
  if(Damp1.depth=="NA") Damp1.depth<-"Assume 5"
  DampMin<-min(Overall.short[DampCol],na.rm=TRUE)
  DampMin.depth<-sub("DampZ.","",names(Overall.short)[which(Overall.short==min(Overall.short[DampCol],na.rm=TRUE))])
  if(DampMin.depth=="NA") DampMin.depth<-"Assume 5"
  DampMax<-max(Overall.short[DampCol],na.rm=TRUE)
  DampMax.depth<-sub("DampZ.","",names(Overall.short)[which(Overall.short==max(Overall.short[DampCol],na.rm=TRUE))])
  if(DampMax.depth=="NA") DampMax.depth<-"Assume 5"
  
  TAfirst<-min(grep("TA",colnames(Data)),na.rm=TRUE)
  TSfirst<-min(grep("TS",colnames(Data)),na.rm=TRUE)
  Results.short<-data.frame(Site=Data[1,1],StartYear=floor(min(WholeYears)),EndYear=floor(max(WholeYears)),TA=Overall[TAfirst+1], TS=Overall[TSfirst+1], TA.amp=Overall[TAfirst+length(Depths)+1],TS.amp=Overall[TSfirst+length(Depths)+1],dev=(Overall[TSfirst+1]-Overall[TAfirst+1]),Damp1=Damp1,Damp1.z=Damp1.depth,DampMin=DampMin,DampMin.z=DampMin.depth,DampMax=DampMax,DampMax.z=DampMax.depth)
    
  write.csv(Results,paste(Directory,"/Processed/Annual2.",Data[1,1],".csv",sep=""),row.names=FALSE)
  write.table(Results.short,paste(Directory,"/Processed/AmeriFluxAll2.csv",sep=""),row.names=FALSE,append=TRUE,sep=",",col.names=FALSE)
}

## Get site information from header
SiteInfo<-matrix(data=NA,nrow=length(Files),ncol=6,dimnames=list(NULL,c("SiteName","FluxnetID","Lat","Lon","Elevation","Vegetation")))
SiteInfo<-data.frame(SiteInfo)
for (i in 1:length(Files)){
  Data<-read.csv(paste(Directory,Files[i],sep="/"),header=FALSE,skip=2, nrows=8)
  SiteInfo[i,1]<-substring(Data[1,],12,)
  SiteInfo[i,2]<-substring(Data[2,],12,)
  SiteInfo[i,3]<-substring(Data[3,],11,)
  SiteInfo[i,4]<-substring(Data[4,],12,)
  SiteInfo[i,5]<-substring(Data[5,],12,)
  SiteInfo[i,6]<-substring(Data[6,],20,)  
}
write.csv(SiteInfo,paste(Directory,"/AmeriFluxSiteInfo.csv",sep=""),row.names=FALSE)

# Read in and plot merged file
Temps<-read.csv("F:/Observations/AmeriFlux/Processed/AmerifluxAll2.csv",header=TRUE)
dim(Temps); names(Temps)
# [1] 74 19
# [1] "Site"       "SiteName"   "Lat"        "Lon"        "Elevation"  "Vegetation" "StartYear"  "EndYear"    "TA"         "TS"        
# [11] "TA.amp"     "TS.amp"     "dev"        "Damp1"      "Damp1.z"    "DampMin"    "DampMin.z"  "DampMax"    "DampMax.z" 
N<-tapply(Temps$dev,Temps$Vegetation,length)
par(mar=c(12,4,1,4), tck=0.03, mgp=c(2,0.5,0))
boxplot(dev~Vegetation,data=Temps, las=2, ylab=expression(Soil-Air~Temp~group("(",degree~C,")")),ylim=c(-3,10))
abline(h=0, col="grey")
text(x=seq(1,by=1,length.out=length(N)),y={-2.5},labels=paste("N=",as.character(N),sep=""))

Temps.v1<-Temps[Temps$TS<40,]
boxplot(dev~Vegetation,data=Temps.v1)

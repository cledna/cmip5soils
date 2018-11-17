## Combine years of SCAN records and plot air vs soil temperature ##

rm(list=ls())
Folder<-"F:/Observations/Virgin Islands/Cinnamon Bay/"
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
}

  Site<-rbind(Site,temp) 
}
Ncol;Days

# There are only two complete years: 2005 and 2013. Better to do by hand!!



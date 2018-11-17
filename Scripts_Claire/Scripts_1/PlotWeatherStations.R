## Publication figure of weather station trends ##

TempObs<-read.csv("C:/Users/claire.phillips/Dropbox/CMIP5_Claire_Margaret/Observations/Observations_SoilTempMetrics.csv")
dim(TempObs);names(TempObs)

TempObs$TA.Amp<-TempObs$TA.Amp/2
TempObs$T5.Amp<-TempObs$T5.Amp/2
TempObs$T100.Amp<-TempObs$T100.Amp/2

TempObs$Anorm.5<-(TempObs$T5.Amp-TempObs$TA.Amp)/TempObs$TA.Amp
TempObs$Anorm.100<-(TempObs$T100.Amp-TempObs$T5.Amp)/TempObs$T5.Amp


# Make a B/W version
pdf("F:/Observations/Observations_SoilTempMetrics_BW.pdf", height=8.5)
{
par(mfrow=c(4,1),mar=c(0,5,1,1),oma=c(5,1,4,1))
plot(Toffset.5cm~TA.Mean,data=TempObs,ylim=c(-5,18),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2)
box(lwd=2)
abline(v=0, col="grey")
abline(h=0, col="grey")
axis(side=1,labels=FALSE,lwd=2,cex.axis=1.6, tck=0.03)
axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6, tck=0.03,mgp=c(2,0.5,0))

#mtext("5cm temp offset from air (C)",side=2,line=2.5,cex=1.2,outer=FALSE)
mtext(expression(paste(Delta,italic(bar(T))["5-air"]," ",group("(",paste(degree,C,sep=""),")"),sep="")),side=2,line=2.5,cex=1.4,outer=FALSE)
#mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.2, outer=FALSE)

plot(Toffset.100cm~TA.Mean,data=TempObs,ylim=c(-5,10),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2)
box(lwd=2)
abline(v=0, col="grey")
abline(h=0, col="grey")
axis(side=1,labels=FALSE,lwd=2,cex.axis=1.6, tck=0.03)
axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6, tck=0.03,mgp=c(2,0.5,0))
mtext(expression(paste(Delta,italic(bar(T))["100-5"]," ",group("(",paste(degree,C,sep=""),")"),sep="")),side=2,line=2.5,cex=1.4,outer=FALSE)

plot(Anorm.5~TA.Mean,data=TempObs,ylim=c(-1,2),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2)
#plot(Tatten.5cm~TA.Mean,data=TempObs,ylim=c(0,2.5),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2)
box(lwd=2)
abline(v=0, col="grey")
abline(h=1, col="grey")
axis(side=1,labels=FALSE,lwd=2,cex.axis=1.6, tck=0.03)
axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6, tck=0.03,mgp=c(2,0.5,0))
#mtext(expression(italic(alpha)["5/air"]),side=2,line=2.5,cex=1.6,outer=FALSE)
mtext(expression(italic(A)["surf"]),side=2,line=2.5,cex=1.4,outer=FALSE)

plot(Anorm.100~TA.Mean,data=TempObs,ylim=c(-1,2),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2)
#plot(Tatten.100cm~TA.Mean,data=TempObs,ylim=c(0,2.5),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2)
box(lwd=2)
abline(v=0, col="grey")
abline(h=1, col="grey")
axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6, tck=0.03,mgp=c(1.5,0.5,0))
axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6, tck=0.03,mgp=c(2,0.5,0))
#mtext(expression(italic(alpha)["100/5"]),side=2,line=2.5,cex=1.6,outer=FALSE)
#mtext(expression(paste(italic(alpha)["100/5"]," ",group("(",paste(degree,C,"/",degree,C,sep=""),")"),sep="")),side=2,line=2.5,cex=1.4,outer=FALSE)
mtext(expression(italic(A)["deep"]),side=2,line=2.5,cex=1.4,outer=FALSE)

mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.6, outer=FALSE)
}
dev.off()

########################################
## Color code by soil order ##
library(RNetCDF)
library(ncdf)
library(fields)
# SoilOrder<-open.nc("F:/soil_suborders_data/nrcs_order_map_Copy.nc",write=TRUE)
# print.nc(SoilOrder)
# close.nc(SoilOrder)

#Find the closest lat/lon in the SoilOrders grid, and get the soil order for that cell.

## COLOR VERSION OF FIGURE ####
# Assign colors to veg types
levels(TempObs$Code)<-c("Other","Forest","Grassland","Permafrost")
TempObs[which(is.na(TempObs$Code)),"Code"]<-"Other"
TempObs$Color<-rep("grey",nrow(TempObs))
TempObs$Color[TempObs$Code=="Forest"]<-"forest green"
TempObs$Color[TempObs$Code=="Grassland"]<-"orange"
TempObs$Color[TempObs$Code=="Permafrost"]<-"blue"

library(segmented)

pdf("C:/Users/claire.phillips/Dropbox/CMIP5_Claire_Margaret/General/Manuscript/Figures/Observations_SoilTempMetrics_Color_Mar2017.pdf", height=8.5)
#pdf("F:/Observations/Observations_SoilTempMetrics_Color_wDiff.pdf", height=8.5)
{
  par(mfrow=c(4,1),mar=c(0,5,1,1),oma=c(5,1,4,1))
  plot(Toffset.5cm~TA.Mean,data=TempObs,ylim=c(-5,18),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2,col=Color,cex=1.2)
  box(lwd=2)
  lm1<-lm(Toffset.5cm~TA.Mean,data=TempObs)
  sm1<-segmented(lm1, seg.Z = ~TA.Mean, psi=5)
  plot(sm1,add=TRUE, rug=FALSE)
  rect(6.5-0.67,-6,6.5+0.67,20,col=grey(0.5,alpha=0.6), border=NA)
  abline(h=0, col="grey")
  text(8, 15, expression(paste(Breakpoint==6.5 %+-% 0.67,degree,"C")),cex=1.2, adj=c(0,0.5))
  axis(side=1,labels=FALSE,lwd=2,cex.axis=1.6, tck=0.03)
  axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6, tck=0.03,mgp=c(2,0.5,0))
  legend(x= -20,y=25,legend=c("Grassland","Forest","Permafrost","Other"),pch=16,cex=1.6,col=c("orange","forest green","blue","grey"),bty="n",horiz=TRUE,xpd=NA)
  
  #mtext("5cm temp offset from air (C)",side=2,line=2.5,cex=1.2,outer=FALSE)
  mtext(expression(paste(Delta,italic(bar(T))["surf"]," ",group("(",paste(degree,C,sep=""),")"),sep="")),side=2,line=2.5,cex=1.4,outer=FALSE)
  #mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.2, outer=FALSE)
  
  plot(Toffset.100cm~TA.Mean,data=TempObs,ylim=c(-5,10),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2,col=Color,cex=1.2)
  box(lwd=2)
  #abline(v=0, col="grey")
  abline(h=0, col="grey")
  axis(side=1,labels=FALSE,lwd=2,cex.axis=1.6, tck=0.03)
  axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6, tck=0.03,mgp=c(2,0.5,0))
  mtext(expression(paste(Delta,italic(bar(T))["deep"]," ",group("(",paste(degree,C,sep=""),")"),sep="")),side=2,line=2.5,cex=1.4,outer=FALSE)
  
  #plot(Tatten.5cm~TA.Mean,data=TempObs,ylim=c(0,2.5),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2,col=Color,cex=1.2)
  plot(Anorm.5~TA.Mean,data=TempObs,ylim=c(-1,2),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2,col=Color,cex=1.2)
  #plot(App.Diff.surf~TA.Mean,data=TempObs,ylim=c(1e-12,1e-2),xlim=c(-25,33),pch=16,log="y",xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2,col=Color,cex=1.2)
  box(lwd=2)
  #abline(v=0, col="grey")
  abline(h=0, col="grey")
  axis(side=1,labels=FALSE,lwd=2,cex.axis=1.6, tck=0.03)
  axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6, tck=0.03,mgp=c(2,0.5,0))
  #mtext(expression(italic(alpha)["5/air"]),side=2,line=2.5,cex=1.6,outer=FALSE)
  #mtext(expression(paste(italic(alpha)["5/air"]," ",group("(",paste(degree,C,"/",degree,C,sep=""),")"),sep="")),side=2,line=2.5,cex=1.4,outer=FALSE)
  #mtext(expression(paste(log~alpha["surf"]," ",group("(",m^2~s^{-1},")"),sep="")),side=2,line=2.5,cex=1.2,outer=FALSE)
  mtext(expression(italic(A)["surf"]),side=2,line=2.5,cex=1.4,outer=FALSE)
  
  
  #plot(Tatten.100cm~TA.Mean,data=TempObs,ylim=c(0,2.5),xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2,col=Color,cex=1.2)
  #plot(App.Diff.deep~TA.Mean,data=TempObs,ylim=c(1e-9,1e-3), xlim=c(-25,33),pch=16,log="y",xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2,col=Color,cex=1.2) 
  plot(Anorm.100~TA.Mean,data=TempObs,ylim=c(-1,2), xlim=c(-25,33),pch=16,xaxt="n",yaxt="n", ylab="",xlab="",cex.axis=1.2,col=Color,cex=1.2) 
  box(lwd=2)
  #abline(v=0, col="grey")
  abline(h=0, col="grey")
  axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6, tck=0.03,mgp=c(1.5,0.5,0))
  #axis(side=2,at=c(1e-9, 5e-7, 1e-5),labels=c(-9,-7,-5),lwd=2,cex.axis=1.6, tck=0.03,mgp=c(2,0.5,0))
  axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6, tck=0.03,mgp=c(2,0.5,0))
  #mtext(expression(italic(alpha)["100/5"]),side=2,line=2.5,cex=1.6,outer=FALSE)
  #mtext(expression(paste(italic(alpha)["100/5"]," ",group("(",paste(degree,C,"/",degree,C,sep=""),")"),sep="")),side=2,line=2.5,cex=1.4,outer=FALSE)
  #mtext(expression(paste(log~kappa["deep"]," ",group("(",m^2~s^{-1},")"),sep="")),side=2,line=2.5,cex=1.2,outer=FALSE)
  mtext(expression(italic(A)["deep"]),side=2,line=2.5,cex=1.4,outer=FALSE)
  
  mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.6, outer=FALSE)
}
dev.off()

## REGRESSION ANALYSIS TO EVALUATE SLOPES AND BREAK POINTS ####
library(segmented)

# Break point analysis for Tsurf ####
lm1<-lm(Toffset.5cm~TA.Mean,data=TempObs)
sm1<-segmented(lm1, seg.Z = ~TA.Mean, psi=5)
par(mfrow=c(2,1), mar=c(5,5,2,2), oma=c(0,0,0,0))
plot(Toffset.5cm~TA.Mean,data=TempObs,ylim=c(-5,18),xlim=c(-25,33),pch=16, cex.axis=1.2,col=Color,cex=1.2)
rect(4.35-0.122,-6,4.35+0.122,20, col=grey(0.5, alpha = 0.6), border=NA)

abline(v=4.35-0.122, lty=2)
#plot(sm1, add=T)
legend(x= "topright",legend=c("Grassland","Forest","Permafrost","Other"),pch=16,cex=1,col=c("orange","forest green","blue","grey"))

# Add a plot for fraction of year with snow cover, derived from Rutgers data
plot(SnowYearFrac~TA.Mean,data=sTempObs,ylim=c(0,1),xlim=c(-25,33),pch=16, cex.axis=1.2,col=Color,cex=1.2, ylab="Fraction of year with snow")
abline(v=10,col="grey")
segments(4.3,-0.1,4.3,0.38)
segments(-30,0.38,4.3,0.38)

# summary(sm1)
# ***Regression Model with Segmented Relationship(s)***
#   
#   Call: 
#   segmented.lm(obj = lm1, seg.Z = ~TA.Mean, psi = 5)
# 
# Estimated Break-Point(s):
#   Est. St.Err 
# 6.500  0.667 
# 
# Meaningful coefficients of the linear terms:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)  4.34994    0.12184   35.70   <2e-16 ***
#   TA.Mean     -0.41062    0.02318  -17.71   <2e-16 ***
#   U1.TA.Mean   0.44666    0.03390   13.18       NA    
# ---
#   Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
# 
# Residual standard error: 1.837 on 443 degrees of freedom
# Multiple R-Squared: 0.5558,  Adjusted R-squared: 0.5528 
# 
# Convergence attained in 2 iterations with relative change 1.40804e-05 
# Break Point = 4.350 +/- 0.122, Slope 1 = -0.411 +/- 0.023, Slope 2 = 0.036 +/- 0.034

lm2<-lm(Toffset.5cm~TA.Mean,data=TempObs[TempObs$Code != "Forest",])
sm2<-segmented(lm2, seg.Z = ~TA.Mean, psi=5)
par(mfrow=c(1,1), mar=c(5,5,2,2), oma=c(0,0,0,0))
plot(Toffset.5cm~TA.Mean,data=TempObs[TempObs$Code != "Forest",],ylim=c(-5,18),xlim=c(-25,33),pch=16, cex.axis=1.2,col=Color,cex=1.2)
plot(sm2, add=T)
summary(sm2)

lm3<-lm(Toffset.5cm~TA.Mean,data=TempObs[TempObs$Code == "Forest"|TempObs$Code == "Permafrost",])
sm3<-segmented(lm3, seg.Z = ~TA.Mean, psi=5)
par(mfrow=c(1,1), mar=c(5,5,2,2), oma=c(0,0,0,0))
plot(Toffset.5cm~TA.Mean,data=TempObs[TempObs$Code == "Forest"|TempObs$Code == "Permafrost",],ylim=c(-5,18),xlim=c(-25,33),pch=16, cex.axis=1.2,col=Color,cex=1.2)
plot(sm3, add=T)
summary(sm3)


# Difference in Tsurf mean for grassland vs forest ####
BP<-6.5
DS<-TempObs[TempObs$Code == "Forest"|TempObs$Code == "Grassland",]
DS<-DS[DS$TA.Mean >= BP,]
dim(DS);dim(TempObs)
# [1] 188  52
# [1] 524  52

lm4<-lm(Toffset.5cm~TA.Mean*Code,data=DS)
summary(lm4)          
coef(lm4)

lm5<-lm(Toffset.5cm~Code+0,data=DS)
summary(lm5)

anova(lm5,lm4)
AIC(lm5);AIC(lm4)

par(mfrow=c(1,1), mar=c(5,5,2,2), oma=c(0,0,0,0))
plot(Toffset.5cm~TA.Mean,data=DS,ylim=c(-5,18),xlim=c(0,33),pch=16, cex.axis=1.2,col=Color,cex=1.2)
abline(coef(lm4)[1],coef(lm4)[2],col="forest green",lwd=2)
abline(coef(lm4)[1]+coef(lm4)[3],coef(lm4)[2]+coef(lm4)[4],col="orange",lwd=2)

par(mfrow=c(1,1), mar=c(5,5,2,2), oma=c(0,0,0,0))
plot(Toffset.5cm~TA.Mean,data=DS,ylim=c(-5,18),xlim=c(0,33),pch=16, cex.axis=1.2,col=Color,cex=1.2)
abline(coef(lm5)[1],0,col="forest green",lwd=2)
abline(coef(lm5)[1]+coef(lm5)[2],0,col="orange",lwd=2)

lm6<-lm(Toffset.5cm~TA.Mean+MAP+TA.Mean*Code,data=DS)
summary(lm6)          
coef(lm4)
plot(Toffset.5cm~MAP,data=DS, ylim=c(-5,15))
lm6a<-lm(Toffset.5cm~TA.Mean,data=DS)
lm6b<-lm(Toffset.5cm~MAP,data=DS)
abline(lm6b)
plot(Toffset.5cm~TA.Mean,data=DS, ylim=c(-5,15))
abline(lm6a)

# Need to go through a model selection process to see if there is an interaction between veg type and 
# climate factors. Can we omit precip as a factor? Or temp?

lm5<-lm(Toffset.5cm~Code+0,data=DS)
summary(lm5)


# Difference in Asurf mean for grassland vs forest ####
lm6<-lm(Anorm.5~TA.Mean+Code,data=DS)
summary(lm6)          

lm7<-lm(Anorm.5~TA.Mean*Code,data=DS)
summary(lm7)

anova(lm6,lm7)
AIC(lm6);AIC(lm7)

par(mfrow=c(1,1), mar=c(5,5,2,2), oma=c(0,0,0,0))
plot(Anorm.5~TA.Mean,data=DS,ylim=c(-1,2),xlim=c(0,33),pch=16, cex.axis=1.2,col=Color,cex=1.2)
abline(coef(lm6)[1],coef(lm6)[2],col="forest green",lwd=2)
abline(coef(lm6)[1]+coef(lm6)[3],coef(lm6)[2],col="orange",lwd=2)

lm8<-lm(Anorm.5~TA.Mean,data=TempObs)
summary(lm8)          

par(mfrow=c(1,1), mar=c(5,5,2,2), oma=c(0,0,0,0))
plot(Anorm.5~TA.Mean,data=TempObs,ylim=c(-1,2),xlim=c(-25,33),pch=16, cex.axis=1.2,col=Color,cex=1.2)
abline(lm8, lwd=2)



# Plot stations on a map ####
#install.packages("Imap")
library("Imap")
library(maps)
library(mapdata)
library(raster)
library(sp)
library(rgdal)
library(maptools)

pdf("F:/Observations/Observations_Locations_Cols.5")
par(mfrow=c(1,1))
#image.plot(CRU.ts.mean)
rast<-raster("F:/Observations/CRU tmp/cru_ts_mean.nc",varname="tmp",origin= -100) 
par(mar=c(1,1,1,1))
plot(rast,col=colorRampPalette(c("blue","yellow","red"))(255),xaxt="n",yaxt="n",bty="n")
land <- readShapeSpatial("C:/Users/Claire/Documents/R/win-library/3.0/ne_110m_land/ne_110m_land.shp")
plot(land)
points(TempObs$Lon,TempObs$Lat,pch=16,cex=0.5, col=TempObs$Color) #as.numeric(TempObs$Network)
dev.off()


Test<-nc_open("C:/TheStargate/ASM_2011_L4_MetFilled.nc")


####################################
### Make similar plots for CMIP5 ##

MODEL.V=c("bcc-csm1-1","BNU-ESM","CanESM2", "CCSM4","CESM1-BGC","MPI-ESM-LR", "GFDL-ESM2G","GISS-E2-R","HadGEM2-ES","inmcm4","IPSL-CM5A-LR","MIROC5","MRI-CGCM3","NorESM1-M") 
REAL="r1i1p1"
library(RNetCDF)
library(ncdf)
library(fields)

### Plot Toffset, shallow during historic ##
pdf("C:/Users/Claire/Documents/LBL/CMIP5/Manuscript/Figures/Toffset_shallow_color.pdf", height=8.5)
par(mfrow=c(7,2),mar=c(0,0,0,0), oma=c(5,8,6,4), tck=0.03, mgp=c(2,0.5,0))
for (i in 1:length(MODEL.V)){
  SO<-get(paste(MODEL.V[i],REAL,"DampingDepth",sep="."))[,,3]
  tslHist.1cm<-get(paste(MODEL.V[i],REAL,"tsl","HistAbsolutemap",sep="."))[,,"0.01m"]-273.15
  tasHist<-get(paste(MODEL.V[i],REAL,"tas","HistAbsolutemap",sep="."))-273.15
  ShallowOffset.Hist<-tslHist.1cm-tasHist
  
  plot(ShallowOffset.Hist~tasHist, pch=16, ylab="", xlab="", ylim=c(-5,18),xlim=c(-25,38),cex.axis=1.6,type="n",xaxt="n",yaxt="n")
  points(tasHist,ShallowOffset.Hist,col="grey")
  #Color gelisols blue, forests green, aridisols orange
  points(tasHist[which(SO==4)],ShallowOffset.Hist[which(SO==4)],col="blue")
  points(tasHist[which(SO==13)],ShallowOffset.Hist[which(SO==13)],col="forest green")
  points(tasHist[which(SO==12)],ShallowOffset.Hist[which(SO==12)],col="orange")
  box(lwd=2)
  abline(v=0, col="grey")
  abline(h=0, col="grey")
  #abline(h=0, col="grey")
  if(i %in% c(13,14)) axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6) else  axis(side=1,labels=FALSE,lwd=2)
  if(i %in% c(seq(2,14,2))){axis(side=2,labels=FALSE,lwd=2)} else {axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6)}
  text(10,13.5,as.character(MODEL.V[i]),cex=1.4, adj=c(0,0))
  if(i==1){#legend(x="topright",legend=c("Gelisol","Mollisol","Alfisol"),col=c("blue","orange","forest green"),pch=NA,lty=1,bty="n")
 legend(x= -25,y=30,legend=c("Grassland","Forest","Permafrost","Other"),pch=16,cex=1.6,col=c("orange","forest green","blue","grey"),bty="n",horiz=TRUE,xpd=NA)
  }
}
#mtext(expression(T[offset]),side=2,line=2.5,cex=1.4,outer=TRUE)
mtext(expression(paste(Delta,italic(bar(T))["1cm-air"]," ",group("(",paste(degree,C,sep=""),")"),sep="")),side=2,line=2.5,cex=1.4,outer=TRUE)
mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.4, outer=TRUE)
dev.off()

### Plot Toffset, deep during historic ##
pdf("C:/Users/Claire/Documents/LBL/CMIP5/Manuscript/Figures/Toffset_deep_color.pdf", height=8.5)
par(mfrow=c(7,2),mar=c(0,0,0,0), oma=c(5,8,6,4), tck=0.03, mgp=c(2,0.5,0))
for (i in 1:length(MODEL.V)){
  SO<-get(paste(MODEL.V[i],REAL,"DampingDepth",sep="."))[,,3]
  tslHist.1m<-get(paste(MODEL.V[i],REAL,"tsl","HistAbsolutemap",sep="."))[,,"1m"]-273.15
  tslHist.1cm<-get(paste(MODEL.V[i],REAL,"tsl","HistAbsolutemap",sep="."))[,,"0.01m"]-273.15
  tasHist<-get(paste(MODEL.V[i],REAL,"tas","HistAbsolutemap",sep="."))-273.15
  DeepOffset.Hist<-tslHist.1m-tslHist.1cm
  #ShallowOffset.Hist<-tslHist.1m-tasHist
  
  plot(DeepOffset.Hist~tasHist, pch=16, ylab="", xlab="", ylim=c(-6,11),xlim=c(-25,38),cex.axis=1.6,type="n",xaxt="n",yaxt="n")
  points(tasHist,DeepOffset.Hist,col="blue", pch=16)
  #Color gelisols blue, forests green, aridisols orange
  points(tasHist[which(SO==4)],DeepOffset.Hist[which(SO==4)],col="blue", pch=16)
  points(tasHist[which(SO==13)],DeepOffset.Hist[which(SO==13)],col="forest green", pch=16)
  points(tasHist[which(SO==12)],DeepOffset.Hist[which(SO==12)],col="orange", pch=16)
  box(lwd=2)
  abline(v=0, col="grey")
  abline(h=0, col="grey")
  #abline(h=0, col="grey")
  if(i %in% c(13,14)) axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6) else  axis(side=1,labels=FALSE,lwd=2)
  if(i %in% c(seq(2,14,2))){axis(side=2,labels=FALSE,lwd=2)} else {axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6)}
  text(10,8,as.character(MODEL.V[i]),cex=1.4, adj=c(0,0))
  if(i==1){#legend(x="topright",legend=c("Gelisol","Mollisol","Alfisol"),col=c("blue","orange","forest green"),pch=NA,lty=1,bty="n")
    legend(x= -25,y=19,legend=c("Grassland","Forest","Permafrost","Other"),pch=16,cex=1.6,col=c("orange","forest green","blue","grey"),bty="n",horiz=TRUE,xpd=NA)
  }
}
#mtext(expression(T[offset]),side=2,line=2.5,cex=1.4,outer=TRUE)
mtext(expression(paste(Delta,italic(bar(T))["100-1cm"]," ",group("(",paste(degree,C,sep=""),")"),sep="")),side=2,line=2.5,cex=1.4,outer=TRUE)
mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.4, outer=TRUE)
dev.off()

### Plot Apparent diffusivity, shallow during historic ##
pdf("C:/Users/Claire/Documents/LBL/CMIP5/Manuscript/Figures/Diffusivity_shallow_color.pdf", height=8.5)
par(mfrow=c(7,2),mar=c(0,0,0,0), oma=c(5,8,6,4), tck=0.03, mgp=c(2,0.5,0))
for (i in 1:length(MODEL.V)){
  SO<-get(paste(MODEL.V[i],REAL,"DampingDepth",sep="."))[,,3]
  tslHistAmp.1cm<-get(paste(MODEL.V[i],REAL,"tsl","HistAmplitudemap",sep="."))[,,"0.01m"]
  tasHistAmp<-get(paste(MODEL.V[i],REAL,"tas","HistAmplitudemap",sep="."))
  tasHist<-get(paste(MODEL.V[i],REAL,"tas","HistAbsolutemap",sep="."))-273.15
  ShallowWaveVector<-(log(tasHistAmp)-log(tslHistAmp.1cm))/0.01
  ShallowDiff<-pi/((ShallowWaveVector^2)*(60*60*24*365))
  
  plot(ShallowDiff~tasHist, pch=16, ylab="", xlab="",ylim=c(1e-12,1e-2),xlim=c(-25,38),cex.axis=1.6,type="n",xaxt="n",yaxt="n",log="y")
  points(tasHist,ShallowDiff,col="grey")
  #Color gelisols blue, forests green, aridisols orange
  points(tasHist[which(SO==4)],ShallowDiff[which(SO==4)],col="blue")
  points(tasHist[which(SO==13)],ShallowDiff[which(SO==13)],col="forest green")
  points(tasHist[which(SO==12)],ShallowDiff[which(SO==12)],col="orange")
  box(lwd=2)
  abline(v=0, col="grey")
  abline(h=0, col="grey")
  #abline(h=0, col="grey")
  if(i %in% c(13,14)) axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6) else  axis(side=1,labels=FALSE,lwd=2)
  if(i %in% c(seq(2,14,2))){axis(side=2,at=c(1e-10,1e-8,1e-6,1e-4),labels=FALSE,lwd=2,cex.axis=1.6, tck=0.03,mgp=c(2,0.5,0))} else {axis(side=2,at=c(1e-10,1e-8,1e-6,1e-4),labels=c(-10,-8,-6,-4),lwd=2,cex.axis=1.6, tck=0.03,mgp=c(2,0.5,0))}
  #if(i %in% c(seq(2,14,2))){axis(side=2,labels=FALSE,lwd=2)} else {axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6)}
  text(10,1e-3,as.character(MODEL.V[i]),cex=1.4, adj=c(0,0))
  if(i==1){#legend(x="topright",legend=c("Gelisol","Mollisol","Alfisol"),col=c("blue","orange","forest green"),pch=NA,lty=1,bty="n")
    legend(x= -25,y=100,legend=c("Grassland","Forest","Permafrost","Other"),pch=16,cex=1.6,col=c("orange","forest green","blue","grey"),bty="n",horiz=TRUE,xpd=NA)
  }
}
#mtext(expression(T[offset]),side=2,line=2.5,cex=1.4,outer=TRUE)
mtext(expression(paste(log~kappa["air-1cm"]," ",group("(",m^2~s^{-1},")"),sep="")),side=2,line=2.5,cex=1.3,outer=TRUE)
mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.4, outer=TRUE)
dev.off()

### Plot Apparent diffusivity, deep during historic ##
pdf("C:/Users/Claire/Documents/LBL/CMIP5/Manuscript/Figures/Diffusivity_deep_color.pdf", height=8.5)
par(mfrow=c(7,2),mar=c(0,0,0,0), oma=c(5,8,6,4), tck=0.03, mgp=c(2,0.5,0))
for (i in 1:length(MODEL.V)){
  SO<-get(paste(MODEL.V[i],REAL,"DampingDepth",sep="."))[,,3]
  tslHistAmp.1m<-get(paste(MODEL.V[i],REAL,"tsl","HistAmplitudemap",sep="."))[,,"1m"]
  tasHistAmp<-get(paste(MODEL.V[i],REAL,"tas","HistAmplitudemap",sep="."))
  tasHist<-get(paste(MODEL.V[i],REAL,"tas","HistAbsolutemap",sep="."))-273.15
  DeepWaveVector<-(log(tasHistAmp)-log(tslHistAmp.1m))/0.99
  DeepDiff<-pi/((DeepWaveVector^2)*(60*60*24*365))
  
  plot(DeepDiff~tasHist, pch=16, ylab="", xlab="",ylim=c(1e-9,1e-3),xlim=c(-25,38),cex.axis=1.6,type="n",xaxt="n",yaxt="n",log="y")
  points(tasHist,DeepDiff,col="grey")
  #Color gelisols blue, forests green, aridisols orange
  points(tasHist[which(SO==4)],DeepDiff[which(SO==4)],col="blue")
  points(tasHist[which(SO==13)],DeepDiff[which(SO==13)],col="forest green")
  points(tasHist[which(SO==12)],DeepDiff[which(SO==12)],col="orange")
  box(lwd=2)
  abline(v=0, col="grey")
  abline(h=0, col="grey")
  #abline(h=0, col="grey")
  if(i %in% c(13,14)) axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6) else  axis(side=1,labels=FALSE,lwd=2)
  if(i %in% c(seq(2,14,2))){axis(side=2,at=c(1e-9,1e-7,1e-5),labels=FALSE,lwd=2,cex.axis=1.6, tck=0.03,mgp=c(2,0.5,0))} else {axis(side=2,at=c(1e-9,1e-7,1e-5),labels=c(-9,-7,-5),lwd=2,cex.axis=1.6, tck=0.03,mgp=c(2,0.5,0))}
  #if(i %in% c(seq(2,14,2))){axis(side=2,labels=FALSE,lwd=2)} else {axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6)}
  text(-20,1e-4,as.character(MODEL.V[i]),cex=1.4, adj=c(0,0))
  if(i==1){#legend(x="topright",legend=c("Gelisol","Mollisol","Alfisol"),col=c("blue","orange","forest green"),pch=NA,lty=1,bty="n")
    legend(x= -25,y=50,legend=c("Grassland","Forest","Permafrost","Other"),pch=16,cex=1.6,col=c("orange","forest green","blue","grey"),bty="n",horiz=TRUE,xpd=NA)
  }
}
#mtext(expression(T[offset]),side=2,line=2.5,cex=1.4,outer=TRUE)
mtext(expression(paste(log~kappa["1-100cm"]," ",group("(",m^2~s^{-1},")"),sep="")),side=2,line=2.5,cex=1.3,outer=TRUE)
mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.4, outer=TRUE)
dev.off()

### Plot change in Tatten from historic to end of century ##
par(mfrow=c(7,2),mar=c(0,0,0,0), oma=c(5,8,2,8), tck=0.03, mgp=c(2,0.5,0))
for (i in 1:length(MODEL.V)){
  EOCAmp.1cm<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCAmplitudemap",sep="."))[,,"0.01m"]
  EOCAmp.1m<-get(paste(MODEL.V[i],XP.V[m],REAL,"tsl","EOCAmplitudemap",sep="."))[,,"1m"]
  EOCAmp.tas<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","EOCAmplitudemap",sep="."))
  HistAmp.1cm<-get(paste(MODEL.V[i],REAL,"tsl","HistAmplitudemap",sep="."))[,,"0.01m"]
  HistAmp.1m<-get(paste(MODEL.V[i],REAL,"tsl","HistAmplitudemap",sep="."))[,,"1m"]
  HistAmp.tas<-get(paste(MODEL.V[i],REAL,"tas","HistAmplitudemap",sep="."))
  
  HistAtten.1m<-HistAmp.1m/HistAmp.1cm
  HistAtten.1cm<-HistAmp.1cm/HistAmp.tas
  EOCAtten.1m<-EOCAmp.1m/EOCAmp.1cm
  EOCAtten.1cm<-EOCAmp.1cm/EOCAmp.tas
  
  tasHist<-get(paste(MODEL.V[i],REAL,"tas","HistAbsolutemap",sep="."))
  tasHist<-tasHist-273.15
  
  tasAnom<-get(paste(MODEL.V[i],XP.V[m],REAL,"tas","AnomGlobalmap",sep="."))
  tasEOC<-tasHist+tasAnom
  
  SO<-get(paste(MODEL.V[i],REAL,"DampingDepth",sep="."))[,,3]
  
  plot(HistAtten.1cm~tasHist, pch=16, ylab=expression(T[atten]), xlab="MAAT", ylim=c(0,2.5),xlim=c(-25,38),cex.axis=1.6,xaxt="n",yaxt="n",type="l")
  segments(tasHist,HistAtten.1cm,tasEOC,EOCAtten.1cm,col="black")
  #Color gelisols blue, forests green, aridisols orange
  segments(tasHist[which(SO==4)],HistAtten.1cm[which(SO==4)],tasEOC[which(SO==4)],EOCAtten.1cm[which(SO==4)],col="blue")
  segments(tasHist[which(SO==13)],HistAtten.1cm[which(SO==13)],tasEOC[which(SO==13)],EOCAtten.1cm[which(SO==13)],col="forest green")
  segments(tasHist[which(SO==12)],HistAtten.1cm[which(SO==12)],tasEOC[which(SO==12)],EOCAtten.1cm[which(SO==12)],col="orange")
  box(lwd=2)
  
  #if(i==2){legend(x="topright",legend=c("Gelisol","Mollisol","Alfisol"),col=c("blue","orange","forest green"),pch=NA,lty=1,bty="n")}
  
  box(lwd=2)
  abline(v=0, col="grey")
  abline(h=1, col="grey")
  #abline(h=0, col="grey")
  if(i %in% c(13,14)) axis(side=1,labels=TRUE,lwd=2,cex.axis=1.6) else  axis(side=1,labels=FALSE,lwd=2)
  if(i %in% c(seq(2,14,2))){axis(side=2,labels=FALSE,lwd=2)} else {axis(side=2,labels=TRUE,lwd=2,cex.axis=1.6)}
  if(i==9) text(-20,0.5,as.character(MODEL.V[i]),cex=1.4, adj=c(0,0)) else text(-20,1.8,as.character(MODEL.V[i]),cex=1.4, adj=c(0,0))
}
mtext(expression(T[atten]),side=2,line=2.5,cex=1.4,outer=TRUE)
mtext("Mean annual air temperature (C)",side=1,line=2.5,cex=1.4, outer=TRUE)

###################################
## What is the mean shallow and deep apparent thermal diffusivity outside snowy regions, i.e. above 10degrees?

names(TempObs)
WarmSoils<-TempObs[TempObs$TA.Mean>=10,]
dim(WarmSoils)
min(WarmSoils$App.Diff.surf,na.rm=TRUE)
max(WarmSoils$App.Diff.surf,na.rm=TRUE)
mean(WarmSoils$App.Diff.surf,na.rm=TRUE)
sd(WarmSoils$App.Diff.surf,na.rm=TRUE)
median(WarmSoils$App.Diff.surf,na.rm=TRUE)
# > min(WarmSoils$App.Diff.surf,na.rm=TRUE)
# [1] 3.46e-10
# > max(WarmSoils$App.Diff.surf,na.rm=TRUE)
# [1] 0.000725861
# > mean(WarmSoils$App.Diff.surf,na.rm=TRUE)
# [1] 5.968235e-06
# > sd(WarmSoils$App.Diff.surf,na.rm=TRUE)
# [1] 6.339907e-05
# > median(WarmSoils$App.Diff.surf,na.rm=TRUE)
# [1] 2.02e-08


min(WarmSoils$App.Diff.deep,na.rm=TRUE)
max(WarmSoils$App.Diff.deep,na.rm=TRUE)
mean(WarmSoils$App.Diff.deep,na.rm=TRUE)
sd(WarmSoils$App.Diff.deep,na.rm=TRUE)
median(WarmSoils$App.Diff.deep,na.rm=TRUE)
# > min(WarmSoils$App.Diff.deep,na.rm=TRUE)
# [1] 1.08e-07
# > max(WarmSoils$App.Diff.deep,na.rm=TRUE)
# [1] 4.51e-06
# > mean(WarmSoils$App.Diff.deep,na.rm=TRUE)
# [1] 9.251529e-07
# > sd(WarmSoils$App.Diff.deep,na.rm=TRUE)
# [1] 6.704807e-07
# > median(WarmSoils$App.Diff.deep,na.rm=TRUE)
# [1] 7.62e-07

#### Snow cover extent data #####
# Use CDO get multi-year daily mean for presence/absence in each grid cell, 1966-2016. 
# Then covert to fraction of year with snow cover.
library(ncdf4)
library(ncdf)
library(fields)
library(ggplot2)

Snow.nc<-nc_open("F:/Observations/SnowSWE/nhsce_v01r01_19661004_20170306_ydaymean.nc")
SnowOrig.nc<-nc_open("F:/Observations/SnowSWE/nhsce_v01r01_19661004_20170306.nc")
# print(SnowOrig.nc)

# Use ncdf4 library to open nc file and extract lat and lon coords, and snow extent.
# Data are in a polar stereographic projection
v1<-Snow.nc$var[[1]]
v2<-Snow.nc$var[[2]]
v3<-SnowOrig.nc$var[[5]]
v5<-Snow.nc$var[[5]]
data1<-ncvar_get(Snow.nc,v1)
data2<-ncvar_get(Snow.nc,v2)
data3<-ncvar_get(SnowOrig.nc,v3)
data5<-ncvar_get(Snow.nc,v5)
gridlon<-as.array(data1)
gridlat<-as.array(data2)
gridland<-as.array(data3)
gridval<-as.array(data5)
dim(gridval)
SnowYearFrac<-apply(X=gridval,MARGIN=c(1,2), FUN=mean)
dim(SnowYearFrac)
image.plot(SnowYearFrac)
image.plot(data3)

# For each soil temp observation, get snow cover for closest grid cell. #
library("Imap")

Snow.df<-data.frame(index=1:(88*88),lon=c(gridlon),lat=c(gridlat),LandMask=c(gridland), YearFrac=c(SnowYearFrac))
#CRU.df = data.frame(index = 720*360,lats=rep(CRU.lat,each=720), lons = rep(CRU.lon,360),lat.index=rep(1:360,each=720),lon.index=rep(1:720,360))


# Get closest grid cell for each station with lat > 0
TempObs$SnowYearFrac<-rep(NA,nrow(TempObs))
TempObs$SnowLat<-rep(NA,nrow(TempObs))
TempObs$SnowLon<-rep(NA,nrow(TempObs))
TempObs$SnowDist<-rep(NA,nrow(TempObs))

NHStations<-which(TempObs$Lat >=0)

for(sta in NHStations){
  print(TempObs$Site[sta])
  temp<-TempObs[sta,]
  #Get the distance (in nautical miles) from each cell in Snow.df to the station
  Snow.df$dist<-gdist(temp$Lon,temp$Lat,Snow.df$lon,Snow.df$lat) 
  Snow.sort<-Snow.df[order(Snow.df$dist),] # Rank by distance 
  Snow.sort<-Snow.sort[Snow.sort$LandMask==1,] # and omit all that are in the ocean
  closest<-Snow.sort[1,]
  #YearRange<-TempObs[sta,"StartYr"]
  TempObs[sta,"SnowLat"]<-closest$lat
  TempObs[sta,"SnowLon"]<-closest$lon
  TempObs[sta,"SnowYearFrac"]<-closest$YearFrac
  TempObs[sta,"SnowDist"]<-closest$dist
}

write.csv(TempObs,file="C:/Users/claire.phillips/Dropbox/CMIP5_Claire_Margaret/Observations/Observations_SoilTempMetricsv2.csv",row.names=FALSE)

# Try to plot polar sterographic projection of world map on top of data (FAIL!) ####

# Polygons data
dum = map(xlim = c(-180,180), ylim = c(0,90), plot = FALSE)
ant_ggplot = data.frame(dum[c("x","y")])
ant_ggplot$value = mean(gridval[,,1])

dat_grid = data.frame(x=c(gridlon),y=c(gridlat),value=c(gridval[,,1]))
dat_grid_sort<-dat_grid[order(-dat_grid$y,dat_grid$x),]
head(dat_grid_sort)
# class(dat_grid)
# head(dat_grid)
#head(data4[,1,1])
image(dat_grid_sort)

# Make the square spatial map
ggplot(aes(x = x, y = y, fill = value), data = dat_grid_sort) + geom_tile() + geom_path(data = ant_ggplot)

# Make the polar stereographic projection
ggplot(aes(x = x, y = y, fill = value), data = dat_grid) + geom_tile() + 
  geom_path(data = ant_ggplot) + coord_polar(theta="x", start= -(pi/2),direction=1)+ 
  ylim (90,0) 
+
  scale_y_continuous("") + scale_x_continuous("") + 
  xlim(180,-180) + ylim(90,0) +
  opts(axis.ticks = theme_blank(), axis.text.y = theme_blank(), 
       axis.title.x = theme_blank(), axis.title.y = theme_blank(),
       panel.border = theme_blank())

library(rgdal)
world<-readOGR("Coastlines\\World_continental_WGS84_Proj.shp", "World_continental_WGS84_Proj")
p  <- p + geom_polygon( data=world, aes(x=long, y=lat, group = group),colour="grey", fill="gainsboro" ) + 
  theme( panel.grid.major.x = element_blank()) + 
  coord_polar(theta="x", start=pi/2,direction=1) + # project the map in polar coordinates
  ylim (-90, -20)                                  # to keep only south hemisphere


Snow<-ncvar_get(Snow.nc, varid="snow_cover_extent", start=c(1,1,1), count=c(87,87,1), verbose=TRUE,
          signedbyte=TRUE, collapse_degen=TRUE)

#Polar projection???

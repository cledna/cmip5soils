### Plot regions of interest ###

## GFDL ##
W.America.Alf<-read.csv("F:/wd/GFDL/Alfisol.WAmerica.time.csv")
names(W.America.Alf)

par(tck=0.03, mgp=c(3,0.5,0), mar=c(5,5,2,5))
plot(Tas~Time,data=W.America.Alf,xlab="Year",ylab=expression(Temperature~change~group("(",degree~C,")")),type="l",lwd=2,main="", col="black", cex.lab=1.6, cex.axis=1.6, ylim=c(-2,8))
lines(Tsl.surf~Time,data=W.America.Alf,lwd=2,col="blue")
lines(Tsl.deep~Time,data=W.America.Alf,lwd=2,col="red")
legend(x="topleft",legend=c("Air","Soil 0 - 2 cm","Soil 80 - 100 cm"),col=c("black","blue","red"), lwd=2, bty="n",cex=1.4)

plot(mrlsl.surf~Time,data=W.America.Alf,xlab="Year",ylab=expression(Soil~moisture~change~group("(",kg~m^{-3},")")),type="l",lwd=2,main="", col="red", cex.lab=1.6, cex.axis=1.6, ylim=c(-40,30))
lines(mrlsl.deep~Time,data=W.America.Alf,lwd=2,col="blue")
legend(x="topleft",legend=c("0 - 2 cm","80 - 100 cm"),col=c("blue","red"), lwd=2, bty="n",cex=1.4)

W.America.Moll<-read.csv("F:/wd/GFDL/Mollisol.WAmerica.time.csv")

par(tck=0.03, mgp=c(3,0.5,0), mar=c(5,5,2,5))
plot(Tas~Time,data=W.America.Moll,xlab="Year",ylab=expression(Temperature~change~group("(",degree~C,")")),type="l",lwd=2,main="", col="black", cex.lab=1.6, cex.axis=1.6, ylim=c(-2,8))
lines(Tsl.surf~Time,data=W.America.Moll,lwd=2,col="blue")
lines(Tsl.deep~Time,data=W.America.Moll,lwd=2,col="red")
legend(x="topleft",legend=c("Air","Soil 0 - 2 cm","Soil 80 - 100 cm"),col=c("black","blue","red"), lwd=2, bty="n",cex=1.4)

plot(mrlsl.surf~Time,data=W.America.Moll,xlab="Year",ylab=expression(Soil~moisture~change~group("(",kg~m^{-3},")")),type="l",lwd=2,main="", col="red", cex.lab=1.6, cex.axis=1.6, ylim=c(-40,30))
lines(mrlsl.deep~Time,data=W.America.Moll,lwd=2,col="blue")
legend(x="topleft",legend=c("0 - 2 cm","80 - 100 cm"),col=c("blue","red"), lwd=2, bty="n",cex=1.4)

N.Europe.Spod<-read.csv("F:/wd/GFDL/Spodosol.NEurope.time.csv")

par(tck=0.03, mgp=c(3,0.5,0), mar=c(5,5,2,5))
plot(Tas~Time,data=N.Europe.Spod,xlab="Year",ylab=expression(Temperature~change~group("(",degree~C,")")),type="l",lwd=2,main="", col="black", cex.lab=1.6, cex.axis=1.6, ylim=c(-2,8))
lines(Tsl.surf~Time,data=N.Europe.Spod,lwd=2,col="blue")
lines(Tsl.deep~Time,data=N.Europe.Spod,lwd=2,col="red")
legend(x="topleft",legend=c("Air","Soil 0 - 2 cm","Soil 80 - 100 cm"),col=c("black","blue","red"), lwd=2, bty="n",cex=1.4)

plot(mrlsl.surf~Time,data=N.Europe.Spod,xlab="Year",ylab=expression(Soil~moisture~change~group("(",kg~m^{-3},")")),type="l",lwd=2,main="", col="red", cex.lab=1.6, cex.axis=1.6, ylim=c(-40,30))
lines(mrlsl.deep~Time,data=N.Europe.Spod,lwd=2,col="blue")
legend(x="topleft",legend=c("0 - 2 cm","80 - 100 cm"),col=c("blue","red"), lwd=2, bty="n",cex=1.4)

Amazon.Ox<-read.csv("F:/wd/GFDL/Oxisol.Amazon.time.csv")

par(tck=0.03, mgp=c(3,0.5,0), mar=c(5,5,2,5))
plot(Tas~Time,data=Amazon.Ox,xlab="Year",ylab=expression(Temperature~change~group("(",degree~C,")")),type="l",lwd=2,main="", col="black", cex.lab=1.6, cex.axis=1.6, ylim=c(-2,8))
lines(Tsl.surf~Time,data=Amazon.Ox,lwd=2,col="blue")
lines(Tsl.deep~Time,data=Amazon.Ox,lwd=2,col="red")
legend(x="topleft",legend=c("Air","Soil 0 - 2 cm","Soil 80 - 100 cm"),col=c("black","blue","red"), lwd=2, bty="n",cex=1.4)

plot(mrlsl.surf~Time,data=Amazon.Ox,xlab="Year",ylab=expression(Soil~moisture~change~group("(",kg~m^{-3},")")),type="l",lwd=2,main="", col="red", cex.lab=1.6, cex.axis=1.6, ylim=c(-40,30))
lines(mrlsl.deep~Time,data=Amazon.Ox,lwd=2,col="blue")
legend(x="topleft",legend=c("0 - 2 cm","80 - 100 cm"),col=c("blue","red"), lwd=2, bty="n",cex=1.4)
# Some key functions used in TempAdvance Scripts (TempAdvance_Soils_cl.Rmd, TempAdvance.Rmd, and TempAdvance_Ensemble.Rmd)

GridToCDF<-function(Grid,Dest,Var,nlat,nlon){ #Grid has lat in rows and lon in columns
  temp.nc<-create.nc(Dest)
  dim.def.nc(temp.nc,"lat",nlat)
  dim.def.nc(temp.nc,"lon",nlon)
  var.def.nc(temp.nc,as.character(Var),vartype="NC_DOUBLE",c(1,0))
  var.def.nc(temp.nc,"lat",vartype="NC_DOUBLE",c(0))
  var.def.nc(temp.nc,"lon",vartype="NC_DOUBLE",c(1))
  att.put.nc(temp.nc,as.character(Var),"_FillValue","NC_DOUBLE",-9999)
  att.put.nc(temp.nc,"lat","units","NC_CHAR","degrees")
  att.put.nc(temp.nc,"lon","units","NC_CHAR","degrees")
  att.put.nc(temp.nc,"lat","axis","NC_CHAR","Y")
  att.put.nc(temp.nc,"lon","axis","NC_CHAR","X")
  var.put.nc(temp.nc,as.character(Var),Grid,start=c(1,1),count=c(nlon,nlat),na.mode=1)
  var.put.nc(temp.nc,"lat",seq(-90,90,length=nlat),start=c(1),count=c(nlat),na.mode=0)
  var.put.nc(temp.nc,"lon",seq(-180,180,length=nlon),start=c(1),count=c(nlon),na.mode=0)
  sync.nc(temp.nc)
  close.nc(temp.nc)  
}

computeShift <- function(model,var,degree,nlon,nlat){
  histN <- get(paste(model,".",var,"Hist.Degree",degree,".N",sep=""))
  eocN <- get(paste(model,".",var,"EOC.Degree",degree,".N",sep=""))
  histS <- get(paste(model,".",var,"Hist.Degree",degree,".S",sep=""))
  eocS <- get(paste(model,".",var,"EOC.Degree",degree,".S",sep=""))
  
  ShiftS <- array(data=NA,dim=c(NLON,floor(NLAT/2)))
  ShiftN <- array(data=NA,dim=c(NLON,ceiling(NLAT/2)))
  
  # Loop through each individual grid cell 
  for (h in 1:nlon){ 
    print(h)
    for (i in 1:floor(nlat/2)){ #For the southern hemisphere
      if (is.na(histS[h,i]) || is.na(eocS[h,i])){ # Case 0: Ocean / NA value
        ShiftS[h,i]<-NA
      } else if (histS[h,i]==0 && eocS[h,i]>0){ # Case 1: Does not exceed threshold in hist period, does in EOC
        ShiftS[h,i] <- 6999
      } else if (histS[h,i]>0 & eocS[h,i]>0){ # Normal shift 
        ShiftS[h,i] <- histS[h,i] - eocS[h,i]
      } else if (histS[h,i]>0 & eocS[h,i]==0){ # Case 2: Exceeds threshold in historical period but not EOC
        ShiftS[h,i] <- -6999
      }
    } # End southern hemisphere 
    
    # Northern Hemisphere
    if (ceiling(nlat/2)==floor(nlat/2)){
      start = ceiling(nlat/2)+1
    } else {start=ceiling(nlat/2)}
    
    for (i in start:nlat){
      if (is.na(histN[h,(i-(nlat/2))]) || is.na(eocN[h,(i-(nlat/2))])){ # Case 0: Ocean / Ice NA value
        ShiftN[h,(i-(nlat/2))]<-NA
      } else if (histN[h,(i-(nlat/2))]==0 && eocN[h,(i-(nlat/2))]>0){# Case 1: Does not exceed threshold in hist period, does in EOC
        ShiftN[h,(i-(nlat/2))] <- 6999
      } else if (histN[h,(i-(nlat/2))]>0 & eocN[h,(i-(nlat/2))]>0){# Normal shift 
        ShiftN[h,(i-(nlat/2))] <- histN[h,(i-(nlat/2))] - eocN[h,(i-(nlat/2))]
      } else if (histN[h,(i-(nlat/2))]>0 & eocN[h,(i-(nlat/2))]==0){# Case 2: Exceeds threshold in historical period but not EOC
        ShiftN[h,(i-(nlat/2))] <- -6999
      } # Omitted case: neither exceed threshold; defaults to NA
    } # End Northern Hemisphere
  } # End longitude loop 
  
  # Bind together results
  mod <- cbind(ShiftS,ShiftN)
  mod <- mod[c(((nlon/2+1):nlon),(1:(nlon/2))),]
  
  # Split out masks for abnormal values (1 = abnormal value, 0 = is not)
  maskCase1 <- mod==6999
  maskCase2 <- mod==-6999
  
  #Filter out abnormal values for now
  mod_filtered <- mod
  mod_filtered[mod_filtered==6999]<- NA
  mod_filtered[mod_filtered==-6999]<- NA
  
  assign(paste(model,".",var,".Shift.",degree,sep=""),mod_filtered,envir = .GlobalEnv)
  assign(paste(model,".",var,".Shift.",degree,".Case1",sep=""),maskCase1,envir = .GlobalEnv)
  assign(paste(model,".",var,".Shift.",degree,".Case2",sep=""),maskCase2,envir = .GlobalEnv)
  
}

plotAdvance <- function(model,var,degree,nlon,nlat,xp){
  # Used to make diagnostic plots for each model
  # Load land file (hard-coded )
  File<-paste("/Volumes/cmip5_soils/regridcmip5soildata/ocean-mask/ocean-mask.Rdata",sep="")
  load(File)
  
  x<-1:NLON
  y<-1:NLAT
  
  # Get filtered model, case1 and case2 masks 
  mod_filtered<-get(paste(model,".",var,".Shift.",degree,sep=""))
  case1 <- get(paste(model,".",var,".Shift.",degree,".Case1",sep=""))
  case1[case1!=1]<- NA
  case2 <- get(paste(model,".",var,".Shift.",degree,".Case2",sep=""))
  case2[case2!=1]<- NA
  
  # Load minimum threshold mask 
  File <- paste(WD2,model,"_Mask",degree,"C.nc",sep="")
  minMask.nc <- open.nc(File)
  minMask <- var.get.nc(minMask.nc,"Mask")
  minMask<-minMask[c(((nlon/2+1):nlon),(1:(nlon/2))),]
  close.nc(minMask.nc)
  
  # Filter the model
  # Part 1: values with shift=0 are NA
  mod_filtered[mod_filtered==0]<- NA # Can change this / delete this line if needed 
  # Part 2: Values with minimum temp above threshold are NA
  mod_filtered[minMask==T]<-NA
  
  return({image.plot(x,y,mod_filtered,xaxt="n",yaxt="n",col=tim.colors(),main=paste(model,var,degree,xp)) 
    contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")
    image(x,y,case1,add=TRUE,col="purple")
    image(x,y,case2,add=TRUE,col="pink")})
  
}

plotAdvanceRelative <-function(model,var,degree,nlon,nlat,xp){
  # Load land file (hard-coded )
  File<-paste("/Volumes/cmip5_soils/regridcmip5soildata/ocean-mask/ocean-mask.Rdata",sep="")
  load(File)
  
  x<-1:NLON
  y<-1:NLAT
  
  mod_filtered<-get(paste(model,".",var,".Shift.",degree,sep=""))
  File <- paste(WD2,model,"_Mask",degree,"C.nc",sep="")
  minMask.nc <- open.nc(File)
  minMask <- var.get.nc(minMask.nc,"Mask")
  minMask<-minMask[c(((nlon/2+1):nlon),(1:(nlon/2))),]
  close.nc(minMask.nc)
  
  # Filter the model
  # Part 1: values with shift=0 are NA
  mod_filtered[mod_filtered==0]<- NA
  # Part 2: Values with minimum temp above threshold are NA
  mod_filtered[minMask==T]<-NA
  
  return({image.plot(x,y,mod_filtered,xaxt="n",yaxt="n",col=tim.colors(),main=paste(model,var,degree)) 
    contour(x,y,Land,add=TRUE,levels=0.99,lwd=1,drawlabels=FALSE,col="grey30")})
  
} 

interpolateToDaily <- function(model,ncfile,var){
  
  data.nc<-open.nc(ncfile)
  
  if (var=="tsl"){ # This deals with NetCDF data (multidimensional [NLON,NLAT,NTIME,NDEPTH])
    # Just get 4 layers, don't need all
    NZ=3 #dim.inq.nc(data,"depth")$length
    NT=dim.inq.nc(data.nc,"time")$length
    NLON=dim.inq.nc(data.nc,"lon")$length
    NLAT=dim.inq.nc(data.nc,"lat")$length
    UBND<-var.get.nc(data.nc,"depth_bnds",start=c(1,1),count=c(1,NZ))
    LBND<-var.get.nc(data.nc,"depth_bnds",start=c(2,1),count=c(1,NZ))
    THICK<-LBND-UBND
    MDPNT<-apply(X=cbind(UBND,LBND),MARGIN=1,mean)
    
    out_data<-var.get.nc(data.nc,var,start=c(1,1,1,1),count=c(NLON,NLAT,NZ,NT))
    close.nc(data.nc)
    
    Jan<-array(data=NA,dim=c(NLON,NLAT,NZ,15))
    if(model=="HadGEM2-ES") {Dec<-array(data=NA,dim=c(NLON,NLAT,NZ,50))} else {
      Dec<-array(data=NA,dim=c(NLON,NLAT,NZ,15)) } 
    for (h in 1:NLON){
      for (i in 1:NLAT){
        for (z in 1:NZ){
          #Get the first and last value in the timeseries for each location and depth
          First<-out_data[h,i,z,1]
          Last<-out_data[h,i,z,NT]
          if(is.na(First)) {
            Jan[h,i,z,]<-rep(NA,15)
            if(model=="HadGEM2-ES") {Dec[h,i,z,]<-rep(NA,50)} else {Dec[h,i,z,]<-rep(NA,15)}
          } else {
            Jan[h,i,z,]<-seq(mean(First,Last),First,length.out=16)[1:15]
            if(model=="HadGEM2-ES") {Dec[h,i,z,]<-seq(Last,mean(First,Last),length.out=51)[2:51]} else {
              Dec[h,i,z,]<-seq(Last,mean(First,Last),length.out=16)[2:16]}
          }
        } #End NZ
      } #End NLAT
      print(h)
    }#End NLON
    out_data <- abind(Jan,out_data,Dec,along=4)
    
    # Interpolate depths 
    ExtraDepths<-array(data=NA,dim=c(NLON,NLAT,365))
    for (t in 1:365){
      for (h in 1:NLON){
        for (i in 1:NLAT){
          if(is.na(out_data[h,i,1,t])){
            ExtraDepths[h,i,t]<-NA} else {
              ExtraDepths[h,i,t]<-approx(MDPNT,out_data[h,i,1:NZ,t],c(0.01),method="linear",rule=2)$y}
        } #End NLAT
      } #End NLON
    } #End NT
    out_data <- ExtraDepths
    
  } else if (var=="tas"){ # 3 Dimensions (air)
    
    NT=dim.inq.nc(data.nc,"time")$length
    NLON=dim.inq.nc(data.nc,"lon")$length
    NLAT=dim.inq.nc(data.nc,"lat")$length
    out_data<-var.get.nc(data.nc,var,start=c(1,1,1),count=c(NLON,NLAT,NT))
    close.nc(data.nc)
    
    Jan<-array(data=NA,dim=c(NLON,NLAT,15))
    if(model=="HadGEM2-ES") {Dec<-array(data=NA,dim=c(NLON,NLAT,50))} else {
      Dec<-array(data=NA,dim=c(NLON,NLAT,15)) }  
    for (h in 1:NLON){
      for (i in 1:NLAT){      
        #Get the first and last value in the timeseries for each location and depth
        First<-out_data[h,i,1]
        Last<-out_data[h,i,NT]
        if(is.na(First)) {
          Jan[h,i,]<-rep(NA,15)
          if(model=="HadGEM2-ES") {Dec[h,i,]<-rep(NA,50)} else {Dec[h,i,]<-rep(NA,15)}
        } else {
          Jan[h,i,]<-seq(mean(First,Last),First,length.out=16)[1:15]
          if(model=="HadGEM2-ES") {Dec[h,i,]<-seq(Last,mean(First,Last),length.out=51)[2:51]} else {
            Dec[h,i,]<-seq(Last,mean(First,Last),length.out=16)[2:16]}
        }     
      } #End NLAT
      print(h)
    }#End NLON
    out_data <- abind(Jan,out_data,Dec,along=3)
  } else if (var=="soil"){ # This case deals with data in the form used in TempAdvance_soils_cl.Rmd (i.e [NDEPTH,NTIME] (2D) dimensionality)
    
    # Soil orders are already globally averaged, so just need to interpolate by time and depth  
    NT=dim.inq.nc(data.nc,"time")$length
    NZ=dim.inq.nc(data.nc,"depth")$length
    UBND<-var.get.nc(data.nc,"depth_bnds",start=c(1,1),count=c(1,NZ))
    LBND<-var.get.nc(data.nc,"depth_bnds",start=c(2,1),count=c(1,NZ))
    THICK<-LBND-UBND
    MDPNT<-apply(X=cbind(UBND,LBND),MARGIN=1,mean)
    out_data<-var.get.nc(data.nc,"tsl")
    close.nc(data.nc)
    
    Jan<-array(data=NA,dim=c(NZ,15))
    if(model=="HadGEM2-ES") {Dec<-array(data=NA,dim=c(NZ,50))} else {
      Dec<-array(data=NA,dim=c(NZ,15)) } 
    for (z in 1:NZ){
      #Get the first and last value in the timeseries for each location and depth
      First<-out_data[z,1]
      Last<-out_data[z,NT]
      if(is.na(First)) {
        Jan[z,]<-rep(NA,15)
        if(model=="HadGEM2-ES") {Dec[z,]<-rep(NA,50)} else {Dec[z,]<-rep(NA,15)}
      } else {
        Jan[z,]<-seq(mean(First,Last),First,length.out=16)[1:15]
        if(model=="HadGEM2-ES") {Dec[z,]<-seq(Last,mean(First,Last),length.out=51)[2:51]} else {
          Dec[z,]<-seq(Last,mean(First,Last),length.out=16)[2:16]}
      }
    } #End NZ
    out_data <- abind(Jan,out_data,Dec,along=2)
    
    # Interpolate depths
    ExtraDepths<-array(data=NA,dim=c(1,365))
    for (t in 1:365){
      if(is.na(out_data[1,t])){
        ExtraDepths[1,t]<-NA} else {
        ExtraDepths[1,t]<-approx(MDPNT,out_data[1:NZ,t],c(0.01),method="linear",rule=2)$y} # Change c(0.01) if you want to change depth (e.g. add c(0.01,1.0))
    } #End NT
    out_data <- ExtraDepths
    
  } else if (var=="tasSoil"){ # 1 dimension Air 
    NT=dim.inq.nc(data.nc,"time")$length
    out_data<-var.get.nc(data.nc,"tas")
    close.nc(data.nc)
    
    #Get the first and last value in the timeseries for each location and depth
    First<-out_data[1]
    Last<-out_data[NT]
    if(is.na(First)) {
        Jan<-rep(NA,15)
        if(model=="HadGEM2-ES") {Dec<-rep(NA,50)} else {Dec<-rep(NA,15)}
    } else {
        Jan<-seq(mean(First,Last),First,length.out=16)[1:15]
        if(model=="HadGEM2-ES") {Dec<-seq(Last,mean(First,Last),length.out=51)[2:51]} else {
          Dec<-seq(Last,mean(First,Last),length.out=16)[2:16]}
    }

    out_data <- abind(Jan,out_data,Dec,along=1)
    
  }
  
  
  return(out_data)
}

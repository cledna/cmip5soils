rm(list=ls())
library(RNetCDF)
library(ncdf4)
library(fields)
library(abind)
library(reshape2)
library(ggplot2)

SOIL=c( "Rock", "ShiftingSand", "Alfisol", "Gelisol", "Histosol", "Spodosol", "Andisol", "Oxisol", "Vertisol", "Aridisol", "Ultisol", "Mollisol", "Inceptisol", "Entisol")

display_image <- function(ncfile,var){
  ncf <- open.nc(ncfile)
  varget <- var.get.nc(ncf, var)
  image(varget)
  return(varget)
}

getvar <- function(ncfile,var){
  ncf <- open.nc(ncfile)
  varget <- var.get.nc(ncf, var)
  close.nc(ncf)
  return(varget)
}
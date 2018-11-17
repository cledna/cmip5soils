MODEL="MPI-ESM-LR"
VAR="tas"
XP="rcp85"
WD="TheStargate"
HISTSTART=185001
XPSTART=200601
XPEND=210012
NLON=192
NLAT=96

if[$VAR ="tas"]
REALM="Amon"
else
REALM="Lmon"
fi

echo $REALM
## Select the historic date range
#Select the historical data range, 1986-2005
# cdo seldate, 1985-01-0100:00,2005-12-0100:00 ${WD}/${VAR}_Amon_${MODEL}_historical_r1i1p1_${HISTSTART}-200512.nc ${WD}/${VAR}_${MODEL}_198601-200512.nc

# #Calculate monthly averages for the 20 year period
# cdo ymonmean ${WD}/${VAR}_${MODEL}_198601-200512.nc ${WD}/${VAR}_${MODEL}_198601-200512_mon.nc

# #Subtract the historic period from 21st century
# cdo ymonsub ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}.nc ${WD}/${VAR}_${MODEL}_198601-200512_mon.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom.nc

# #Make and apply ocean mask
# if[VAR == "tas"]
# then
	# cdo seltimestep,1 ${WD}/tsl_Lmon_${MODEL}_${XP}_r1i1p1_${XPSTART}-${XPEND}.nc ${WD}/${MODEL}_ocean-mask-temp.nc
	# cdo sellevel,0.03 -selvar,’tsl’ ${WD}/${MODEL}_ocean-mask-temp.nc ${WD}/${MODEL}_ocean-mask.nc
	# cdo ifthen ${WD}/${MODEL}_ocean-mask.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_land.nc
	# rm ${WD}/${MODEL}_ocean-mask-temp.nc
# fi

## Make sure soil order grids for the current model are in the WD
## Setgrid for Ice Mask from generic to rectangular
# INFILE="${WD}/Ice${MODEL}.nc"
# OUTFILE="${WD}/Ice${MODEL}_rect.nc"
# cdo setgrid,r${NLON}x$NLAT $INFILE $OUTFILE

# ## Convert air temp to rectangular to apply ice filter
# INFILE="${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_land.nc"
# OUTFILE="${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_land_rect.nc"
# REMAPWEIGHTS="${WD}/${VAR}_${MODEL}_remapweights.nc"
# cdo genbil,r192x96 $INFILE $REMAPWEIGHTS
# cdo remap,r192x96,$REMAPWEIGHTS $INFILE $OUTFILE
	# #cdo sinfo $INFILE
	# #cdo sinfo $OUTFILE

# # Apply ice mask to air temps
# cdo ifthen ${WD}/Ice${MODEL}_rect.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_land_rect.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_land_NoIce.nc

#exit
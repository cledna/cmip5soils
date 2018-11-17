MODEL="MPI-ESM-LR"
VAR="tas"
XP="rcp85"
WD="TheStargate"
HISTSTART=185001
XPSTART=200601
XPEND=210012
NLON=192
NLAT=96

if [ $VAR = "tas" ]
then REALM="Amon"
else REALM="Lmon"
fi

SOIL=( "Rock" "ShiftingSand" "Gelisol" "Histosol" "Spodosol" "Andisol" "Oxisol" "Vertisol" "Aridisol" "Ultisol" "Mollisol" "Alfisol" "Inceptisol" "Entisol" )
LATZONE=( "Alfisol" "Andisol" "Aridisol" "Gelisol" "Inceptisol" "Mollisol")
ZONE=( "GreatPlains" "PampasPlain" "EurasianSteppe" "ChinaMoll" )

# ## Select the historic date range
# #Select the historical data range, 1986-2005
# cdo seldate,1985-01-0100:00,2005-12-0100:00 ${WD}/${VAR}_${REALM}_${MODEL}_historical_r1i1p1_${HISTSTART}-200512.nc ${WD}/${VAR}_${MODEL}_198601-200512.nc

# # # #Calculate monthly averages for the 20 year period
 # cdo ymonmean ${WD}/${VAR}_${MODEL}_198601-200512.nc ${WD}/${VAR}_${MODEL}_198601-200512_mon.nc

# # # #Subtract the historic period from 21st century
 # cdo ymonsub ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_r1i1p1_${XPSTART}-${XPEND}.nc ${WD}/${VAR}_${MODEL}_198601-200512_mon.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom.nc

# # #Make and apply ocean mask
#if [ $VAR = "tas" ]
#then
	# cdo seltimestep,1 ${WD}/tsl_Lmon_${MODEL}_${XP}_r1i1p1_${XPSTART}-${XPEND}.nc ${WD}/${MODEL}_ocean-mask-temp.nc
	# cdo sellevel,0.03 -selvar,"tsl" ${WD}/${MODEL}_ocean-mask-temp.nc ${WD}/${MODEL}_ocean-mask.nc
	# cdo ifthen ${WD}/${MODEL}_ocean-mask.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_land.nc
	# rm ${WD}/${MODEL}_ocean-mask-temp.nc
# #fi

# ## Make sure soil order grids for the current model are in the WD
# ## Setgrid for Ice Mask from generic to rectangular
# cdo setgrid,r${NLON}x$NLAT ${WD}/Ice${MODEL}.nc ${WD}/Ice${MODEL}_rect.nc

# # ## Convert CMIP5 output to rectangular to apply ice filter
# INFILE="${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_land.nc"
# OUTFILE="${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_land_rect.nc"
# REMAPWEIGHTS="${WD}/${VAR}_${MODEL}_remapweights.nc"
# cdo genbil,r${NLON}x${NLAT} $INFILE $REMAPWEIGHTS
# cdo remap,r${NLON}x${NLAT},$REMAPWEIGHTS $INFILE $OUTFILE
	# cdo sinfo $INFILE
	# cdo sinfo $OUTFILE

# # # Apply ice mask to var
# cdo ifthen ${WD}/Ice${MODEL}_rect.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_land_rect.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_land_NoIce.nc

# ### GLOBAL MEAN OUTFILES
# ## ANOMALY TIMESERIES, ANNUAL AVGS
# cdo yearmean -fldmean ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_land_NoIce.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_global_ts.nc

# ## 2080-2100 MAP
# cdo timmean -seldate,2080-01-0100:00,2100-12-0100:00 ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_land_NoIce.nc ${WD}/${VAR}_${MODEL}_${XP}_Map_2080-2100.nc

# ## 2080-2100 GLOBAL MEAN
# cdo timmean -fldmean -seldate,2080-01-0100:00,2100-12-0100:00 ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_land_NoIce.nc ${WD}/${VAR}_${MODEL}_${XP}_GlobalMean_2080-2100.nc

# ### SOIL ORDER RESULTS ###

for SO in ${SOIL[@]}; do ## loop over soils
	# Setgrid for soil order from generic to rectangular
	cdo setgrid,r${NLON}x$NLAT ${WD}/${SO}${MODEL}.nc ${WD}/${SO}${MODEL}_rect.nc
	# Calculate the soil order weights
	cdo enlarge,${WD}/${SO}${MODEL}_rect.nc -fldsum ${WD}/${SO}${MODEL}_rect.nc ${WD}/${SO}${MODEL}_temp.nc
	cdo div ${WD}/${SO}${MODEL}_rect.nc ${WD}/${SO}${MODEL}_temp.nc ${WD}/${SO}${MODEL}_norm.nc
	rm ${WD}/${SO}${MODEL}_temp.nc
	# Enlarge the grid to include depth (and time) and multiply by ts
	cdo enlarge,${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom.nc ${WD}/${SO}${MODEL}_norm.nc ${WD}/${SO}${MODEL}_norm_enlarged.nc
	# Multiple enlarged weights grid by timeseries and store weird values as a temp file
	cdo mul ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom.nc ${WD}/${SO}${MODEL}_norm_enlarged.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_${SO}_ts_temp.nc
	# Sum all the gridcells to get global soil order temp at each time step
	cdo fldsum ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_${SO}_ts_temp.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_${SO}_ts.nc
	cdo yearmean ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_${SO}_ts.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_${SO}_ts_annual.nc
	rm ${WD}/${SO}${MODEL}_norm_enlarged.nc
	rm ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_${SO}_ts_temp.nc
	# Get soil order global mean for 2080-2100
	cdo timmean -seldate,2080-01-0100:00,2100-12-0100:00 ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_${SO}_ts.nc ${WD}/${VAR}_${MODEL}_${XP}_GlobalMean_2080-2100_${SO}.nc
done

# Zonal means for some soil orders
# Global zonal mean
cdo zonmean ${WD}/${VAR}_${MODEL}_${XP}_Map_2080-2100.nc ${WD}/${VAR}_${MODEL}_${XP}_latmean_2080-2100_Global.nc
for LZ in ${LATZONE[@]}; do # loop over soils of interest
	# Get soil order weights for latitudes (zones)
	cdo enlarge,${WD}/${LZ}${MODEL}_rect.nc -zonsum ${WD}/${LZ}${MODEL}_rect.nc ${WD}/${LZ}${MODEL}_zonsum_enlarged.nc
	cdo div ${WD}/${LZ}${MODEL}_rect.nc ${WD}/${LZ}${MODEL}_zonsum_enlarged.nc ${WD}/${LZ}${MODEL}_latnorm.nc
	cdo mul ${WD}/${VAR}_${MODEL}_${XP}_Map_2080-2100.nc -enlarge,${WD}/${VAR}_${MODEL}_${XP}_Map_2080-2100.nc ${WD}/${LZ}${MODEL}_latnorm.nc ${WD}/${VAR}_${MODEL}_${XP}_latmean_2080-2100_${LZ}_temp.nc
	cdo zonsum ${WD}/${VAR}_${MODEL}_${XP}_latmean_2080-2100_${LZ}_temp.nc ${WD}/${VAR}_${MODEL}_${XP}_latmean_2080-2100_${LZ}.nc
	rm ${WD}/${VAR}_${MODEL}_${XP}_latmean_2080-2100_${LZ}_temp.nc
	rm ${WD}/${LZ}${MODEL}_zonsum_enlarged.nc
done

# # For zones of interest get timeseries, EOC means, and monthly means for historic and EOC
for ZO in ${ZONE[@]}; do 
	if [ $ZO = "GreatPlains" ]
	then
		ZOLON1=-115
		ZOLON2=-90
		ZOLAT1=35
		ZOLAT2=55
	elif [ $ZO = "PampasPlain" ]
	then
		ZOLON1=-75
		ZOLON2=-60
		ZOLAT1=-20
		ZOLAT2=-45
	elif [ $ZO = "EurasianSteppe" ]
	then
		ZOLON1=30
		ZOLON2=60
		ZOLAT1=55
		ZOLAT2=40
	elif [ $ZO = "ChinaMoll" ]
	then
		ZOLON1=105
		ZOLON2=140
		ZOLAT1=50
		ZOLAT2=35
	else echo "Don't recognize zone."
	fi
	echo $ZO
	echo $ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2
# Get the Mollisol weights for the region
cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/Mollisol${MODEL}_rect.nc ${WD}/${ZO}${MODEL}-boxtemp.nc
cdo enlarge,${WD}/${ZO}${MODEL}-boxtemp.nc -fldsum ${WD}/${ZO}${MODEL}-boxtemp.nc ${WD}/${ZO}${MODEL}-boxtemp2.nc
cdo div ${WD}/${ZO}${MODEL}-boxtemp.nc ${WD}/${ZO}${MODEL}-boxtemp2.nc ${WD}/${ZO}${MODEL}_weights.nc
rm ${WD}/${ZO}${MODEL}-boxtemp.nc
rm ${WD}/${ZO}${MODEL}-boxtemp2.nc
# Historic monthly means
	# Need to regrid temps to rectangular to ensure match-up with 21st century
	cdo genbil,r${NLON}x${NLAT} ${WD}/${VAR}_${MODEL}_198601-200512_mon.nc ${WD}/${VAR}_${MODEL}_198601-200512_mon_remapweights.nc
	cdo remap,r${NLON}x${NLAT},${WD}/${VAR}_${MODEL}_198601-200512_mon_remapweights.nc ${WD}/${VAR}_${MODEL}_198601-200512_mon.nc ${WD}/${VAR}_${MODEL}_198601-200512_mon_rect.nc
	cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/${VAR}_${MODEL}_198601-200512_mon_rect.nc ${WD}/${VAR}_${MODEL}_198601-200512_mon_${ZO}-temp.nc
	cdo enlarge,${WD}/${VAR}_${MODEL}_198601-200512_mon_${ZO}-temp.nc ${WD}/${ZO}${MODEL}_weights.nc ${WD}/${ZO}${MODEL}_weights_enlarged.nc
	cdo mul ${WD}/${VAR}_${MODEL}_198601-200512_mon_${ZO}-temp.nc ${WD}/${ZO}${MODEL}_weights_enlarged.nc ${WD}/${VAR}_${MODEL}_198601-200512_mon_${ZO}-temp2.nc
	cdo fldsum ${WD}/${VAR}_${MODEL}_198601-200512_mon_${ZO}-temp2.nc ${WD}/${VAR}_${MODEL}_198601-200512_mon_${ZO}.nc
	rm ${WD}/${VAR}_${MODEL}_198601-200512_mon_${ZO}-temp.nc
	rm ${WD}/${VAR}_${MODEL}_198601-200512_mon_${ZO}-temp2.nc
	rm ${WD}/${ZO}${MODEL}_weights_enlarged.nc
# End of century monthly means
	cdo monmean -seldate,2080-01-0100:00,2100-12-3100:00 ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_r1i1p1_${XPSTART}-${XPEND}.nc ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon.nc
	# Need to regrid temps to rectangular
	cdo genbil,r${NLON}x${NLAT} ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon.nc ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon_remapweights.nc
	cdo remap,r${NLON}x${NLAT},${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon_remapweights.nc ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon.nc ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon_rect.nc
	cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon_rect.nc ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon_rect_${ZO}-temp.nc
	cdo enlarge,${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon_rect_${ZO}-temp.nc ${WD}/${ZO}${MODEL}_weights.nc ${WD}/${ZO}${MODEL}_weights_enlarged.nc
	cdo mul ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon_rect_${ZO}-temp.nc ${WD}/${ZO}${MODEL}_weights_enlarged.nc ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon_rect_${ZO}-temp2.nc
	cdo fldsum ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon_rect_${ZO}-temp2.nc ${WD}/${VAR}_${MODEL}_${XP}_2080-2100_mon_${ZO}.nc
	rm ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon_remapweights.nc
	rm ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon_rect.nc
	rm ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon_rect_${ZO}-temp.nc
	rm ${WD}/${VAR}_${REALM}_${MODEL}_${XP}_2080-2100_mon_rect_${ZO}-temp2.nc

# Timeseries anomaly
	cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_land_NoIce.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_${ZO}-temp.nc
	cdo fldsum -mul ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_${ZO}-temp.nc ${WD}/${ZO}${MODEL}_weights_enlarged.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_ts_${ZO}.nc
	rm ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_${ZO}-temp.nc
	rm ${WD}/${ZO}${MODEL}_weights_enlarged.nc
	# Annual timeseries
	cdo yearmean ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_ts_${ZO}.nc ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_annual_${ZO}.nc
	# # End of century region anomaly mean
	cdo timmean -seldate,2080-01-0100:00,2100-12-3100:00 ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_ts_${ZO}.nc ${WD}/${VAR}_${MODEL}_${XP}_2080-2100_anom_region_${ZO}.nc
# # Remove monthly timeseries
	rm ${WD}/${VAR}_${MODEL}_${XP}_${XPSTART}-${XPEND}_anom_ts_${ZO}.nc
done

#exit

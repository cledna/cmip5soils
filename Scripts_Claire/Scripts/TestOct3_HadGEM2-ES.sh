# Completed are 0,1,2,3,11
MODEL=("bcc-csm1-1" "BNU-ESM" "CanESM2" "CESM1-BGC" "CNRM-CM5" "GFDL-ESM2G" "GISS-E2-R" "HadGEM2-ES" "inmcm4" "IPSL-CM5A-LR" "MIROC5" "MPI-ESM-LR" "MRI-CGCM3" "NorESM1-M")
TOPZ=(0.007100635 0.007100600 0.05 0.007100635 193 000.01 000.05 000.05 0000.01 0.01785280 00.025 000.03 000.01 0.007100635 )
Z1=(0.00710064 0.0071006 000.05 0.00710064 193 000.01 000.05 000.05 0000.01 0.0178528 00.025 000.03 000.01 0.00710064)
Z2=(1.03803 1.03803 02.225 1.03803 194 0000.9 0.8271 000002 001.05 0.932152 0001.5 000.78 001.25 1.03803)
ZDIFF=(-1.03092936 -1.0309294 -2.175 -1.03092936 -1 -0.89 -0.7771 -1.95 -1.04 -0.9142992 -1.475 -0.75 -1.24 -1.03092936)
ZDIFF1=(-0.00710064 -0.0071006 -000.05 -0.00710064 -193 -0.01 -0.05 -0.05 -0.01 -0.0178528 -0.025 -000.03 -0.01 -0.00710064)
ZDIFF2=(-1.03803 -1.03803 -02.225 -1.03803 -194 -0.9 -0.8271 -2 -1.05 -0.932152 -1.5 -000.78 -1.25 -1.03803)

NLAT=(64 64 64 192 128 90 90 145 120 96 128 96 160 96)
NLON=(128 128 128 288 256 144 144 192 180 96 256 192 320 144)
VARIABLES=("tas")
XP=("historical" "rcp45" "rcp85")
WD="/home/jsoong/cmip5soils"
ENS="r1i1p1"
index=(7)

SOIL=( "Rock" "ShiftingSand" "Gelisol" "Histosol" "Spodosol" "Andisol" "Oxisol" "Vertisol" "Aridisol" "Ultisol" "Mollisol" "Alfisol" "Inceptisol" "Entisol" )
LATZONE=( "Alfisol" "Andisol" "Aridisol" "Gelisol" "Inceptisol" "Mollisol")
ZONE=("GreatPlains" "PampasPlain" "EurasianSteppe" "ChinaMoll")

for VAR in ${VARIABLES[@]}; do
set +e
if [ $VAR = "tas" ]
	then REALM="Amon"
	else REALM="Lmon"
fi

for i in ${index[@]}; do ## loop over models
	for EXP in ${XP[@]}; do ## loop over experiments 
	fl_nbr=$( ls ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}*.nc | wc -w ) ## number of files in this ensemble member
	yyyymm_str=$( ls ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}*.nc | sed -n '1p' | cut -d '_' -f 6 | cut -d '-' -f 1 )
	yyyymm_end=$( ls ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}*.nc | sed -n "${fl_nbr}p" | cut -d '_' -f 6 | cut -d '-' -f 2 | cut -d '.' -f 1 )
	#cdo sinfo ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}_${yyyymm_str}-${yyyymm_end}.nc

	if [ $EXP = "historical" ]
		then 
		HISTEND=$yyyymm_end
		HISTSTART=$yyyymm_str
		echo "The date range is" $HISTSTART " to " $HISTEND
	else
		XPSTART=$yyyymm_str
		XPEND=$yyyymm_end
		echo "The date range is" $XPSTART " to " $XPEND
	fi

	if [ ${fl_nbr} -le 1 ] ## if there is only 1 file, continue to next loop
		then
		echo "There is only 1 file in ensemble" ${VAR}_${MODEL[$i]}_${EXP}_${ENS}.
		continue
	fi
	echo "There are" ${fl_nbr} "files in ensemble " ${VAR}_${MODEL[$i]}_${EXP}_${ENS}
	echo XPSTART $XPSTART, XPEND $XPEND, HISTEND $HISTEND, HISTART $HISTSTART
# Concatenate the files of one ensemble member into one along the record dimension (time)
 cdo cat ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}*.nc ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}_${yyyymm_str}-${yyyymm_end}.nc

## For GFDL there are two variables in each file rather than one. Split out "average_DT"
 # cdo splitvar ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}_${yyyymm_str}-${yyyymm_end}.nc ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}_${yyyymm_str}-${yyyymm_end}-
 # rm ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}_${yyyymm_str}-${yyyymm_end}-average_DT.nc
 # rm ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}_${yyyymm_str}-${yyyymm_end}.nc
 # mv ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}_${yyyymm_str}-${yyyymm_end}-${VAR}.nc ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}_${yyyymm_str}-${yyyymm_end}.nc
# # Select the date range native for most of the, 200601-210012
	if [ $XPEND -ne 210012 ]
	then
	cdo seldate,2006-01-0100:00,2100-12-3100:00 ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}_${XPSTART}-${XPEND}.nc ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}_200601-210012.nc
  fi
  done #Finish EXP loop

 
XP2=("rcp45") #Loop through the two 21st century experiments. Need to subtract historical from them.
 for EXP2 in ${XP2[@]}; do ## loop over experiments
 set -e
# Select the historic date range
#Select the historical data range, 1986-2005
 cdo seldate,1985-01-0100:00,2005-12-3100:00 ${WD}/${VAR}-historical/${VAR}_${REALM}_${MODEL[i]}_historical_r1i1p1_${HISTSTART}-${HISTEND}_regrid.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512.nc

# # #Calculate monthly averages for the 20 year period
  cdo ymonmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon.nc

# # #Subtract the historic period from 21st century
 cdo ymonsub ${WD}/${VAR}-${EXP2}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_${ENS}_200601-210012.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom.nc

# # #Select the EOC period
 cdo seldate,2080-01-0100:00,2100-12-3100:00 ${WD}/${VAR}-${EXP2}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_${ENS}_200601-210012.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012.nc
 
 #Make and apply ocean mask
if [ $VAR = "tas" ]
then
	cdo copy ${WD}/tsl-historical/tsl_Lmon_${MODEL[i]}_historical_${ENS}_${HISTSTART}-${HISTEND}_regrid.nc ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ocean-mask-temp.nc
	cdo sellevel,${TOPZ[i]} -selvar,"tsl" ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ocean-mask-temp.nc ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ocean-mask.nc
	cdo ifthen ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ocean-mask.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land.nc
	cdo ifthen ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ocean-mask.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012_land.nc
	cdo ifthen ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ocean-mask.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land.nc
	rm ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ocean-mask-temp.nc
else 
	cdo copy ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land.nc
	cdo copy ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012_land.nc
	cdo copy  ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512.nc  ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land.nc
fi
rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012.nc


## Make sure soil order grids for the current model are in the WD
## Setgrid for Ice Mask from generic to rectangular
cdo setgrid,r${NLON[i]}x${NLAT[i]} ${WD}/SoilGrids/Ice${MODEL[i]}.nc ${WD}/OUT/${MODEL[i]}/Ice${MODEL[i]}_rect.nc

# # ## Convert CMIP5 output to rectangular to apply ice filter
cdo genbil,r${NLON[i]}x${NLAT[i]} ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_remapweights.nc
cdo remap,r${NLON[i]}x${NLAT[i]},${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_remapweights.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land_rect.nc
cdo genbil,r${NLON[i]}x${NLAT[i]} ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_remapweights2.nc
cdo remap,r${NLON[i]}x${NLAT[i]},${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_remapweights2.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_rect.nc 
cdo genbil,r${NLON[i]}x${NLAT[i]} ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012_land.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_remapweights3.nc
cdo remap,r${NLON[i]}x${NLAT[i]},${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_remapweights3.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012_land.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012_land_rect.nc

# # # Apply ice mask to var
 cdo ifthen ${WD}/OUT/${MODEL[i]}/Ice${MODEL[i]}_rect.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land_rect.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land_NoIce.nc
 cdo ifthen ${WD}/OUT/${MODEL[i]}/Ice${MODEL[i]}_rect.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_rect.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce.nc
 cdo ifthen ${WD}/OUT/${MODEL[i]}/Ice${MODEL[i]}_rect.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012_land_rect.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012_land_NoIce.nc

rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land.nc
rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012_land.nc
rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land.nc
rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land_rect.nc
rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012_land_rect.nc
rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_rect.nc 

### GLOBAL MEAN OUTFILES
## ANOMALY TIMESERIES, ANNUAL AVGS
cdo yearmean -fldmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land_NoIce.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_global_ts.nc

## 2080-2100 DELTA MAP
cdo timmean -seldate,2080-01-0100:00,2100-12-3100:00 ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land_NoIce.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_Map_2080-2100.nc

## 2080-2100 GLOBAL MEAN DELTA
cdo timmean -fldmean -seldate,2080-01-0100:00,2100-12-3100:00 ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land_NoIce.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_GlobalMean_2080-2100.nc

## 1986-2005 HISTORIC SOIL PHYSICS DIAGNOSTICS
## N.B. land_NoIce is already rectangular
if [ $VAR = "tsl" ]
then
set +e
## Get soil amplitudes
	cdo yearmin  ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce.nc  ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc
	cdo yearmax ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce.nc  ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc
	cdo sub ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude_temp.nc
	cdo timmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude_temp.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude_temp.nc
## Get air temp amplitude
	cdo yearmin  ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce.nc  ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc
	cdo yearmax ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce.nc  ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc
	cdo sub ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_amplitude_temp.nc
	cdo timmean ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_amplitude_temp.nc ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_amplitude.nc
	rm ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_amplitude_temp.nc
## Calculate damping depth from annual air amplitudes and Z1 amplitude
	#set +e
	cdo splitlevel ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-
	cdo sub -ln ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-${Z1[i]}.nc -ln ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_amplitude.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc
	cdo const,${ZDIFF1[i]},r${NLON[i]}x${NLAT[i]} ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF_temp.nc
	cdo settaxis,1986-01-01,00:00,1mon ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF_temp.nc ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF.nc
	cdo div ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF.nc  ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_dampv1.nc
	#rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-*
	rm ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF*
## Calculate damping depth from annual air amplitudes and Z2 amplitude
	#cdo splitlevel ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-
	cdo sub -ln ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-${Z2[i]}.nc -ln ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_amplitude.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc
	cdo const,${ZDIFF2[i]},r${NLON[i]}x${NLAT[i]} ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF_temp.nc
	cdo settaxis,1986-01-01,00:00,1mon ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF_temp.nc ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF.nc
	cdo div ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF.nc  ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_dampv2.nc
	#rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-*
	rm ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF*
## Calculate damping depth from Z1 and Z2 amplitude
	#cdo splitlevel ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-
	cdo sub -ln ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-${Z1[i]}.nc -ln ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-${Z1[i]}.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc
	cdo const,${ZDIFF[i]},r${NLON[i]}x${NLAT[i]} ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF_temp.nc
	cdo settaxis,1986-01-01,00:00,1mon ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF_temp.nc ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF.nc
	cdo div ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF.nc  ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_damp.nc
	#rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-*
	rm ${WD}/OUT/${MODEL[i]}/${MODEL[i]}_ZDIFF*
	set -e
fi
	## Output maps of absolute (not delta) mean annual temp/mrlsl, which will be regressors for damping depth. NOTE, THESE ARE RECTANGULAR!!
	cdo timmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_meanannual.nc
	cdo timmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012_land_NoIce.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012_meanannual.nc
	cdo setgrid,r${NLON[i]}x${NLAT[i]} ${WD}/SoilGrids/AllOrders${MODEL[i]}.nc ${WD}/OUT/${MODEL[i]}/AllOrders${MODEL[i]}_rect.nc

### SOIL ORDER RESULTS ###

for SO in ${SOIL[@]}; do ## loop over soils
	# Setgrid for soil order from generic to rectangular
	cdo setgrid,r${NLON[i]}x${NLAT[i]} ${WD}/SoilGrids/${SO}${MODEL[i]}.nc ${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_rect.nc
	# Calculate the soil order weights
	cdo enlarge,${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_rect.nc -fldsum ${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_rect.nc ${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_temp.nc
	cdo div ${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_rect.nc ${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_temp.nc ${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_norm.nc
	rm ${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_temp.nc
	# Enlarge the grid to include depth (and time) and multiply by ts
	cdo enlarge,${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land_NoIce.nc ${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_norm.nc ${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_norm_enlarged.nc
	#Multiple enlarged weights grid by timeseries and store weird values as a temp file
	cdo mul ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land_NoIce.nc ${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_norm_enlarged.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${SO}_ts_temp.nc
	# Sum all the gridcells to get global soil order temp at each time step
	cdo fldsum ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${SO}_ts_temp.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${SO}_ts.nc
	cdo yearmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${SO}_ts.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${SO}_ts_annual.nc
	rm ${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_norm_enlarged.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${SO}_ts_temp.nc
	# Get soil order global mean for 2080-2100
	cdo timmean -seldate,2080-01-0100:00,2100-12-0100:00 ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${SO}_ts.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_GlobalMean_2080-2100_${SO}.nc
done #End soil order timeseries and means

# Zonal means for some soil orders
# Global zonal mean
cdo zonmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_Map_2080-2100.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_latmean_2080-2100_Global.nc
for LZ in ${LATZONE[@]}; do # loop over soils of interest
	# Get soil order weights for latitudes (zones)
	cdo enlarge,${WD}/OUT/${MODEL[i]}/${LZ}${MODEL[i]}_rect.nc -zonsum ${WD}/OUT/${MODEL[i]}/${LZ}${MODEL[i]}_rect.nc ${WD}/OUT/${MODEL[i]}/${LZ}${MODEL[i]}_zonsum_enlarged.nc
	cdo div ${WD}/OUT/${MODEL[i]}/${LZ}${MODEL[i]}_rect.nc ${WD}/OUT/${MODEL[i]}/${LZ}${MODEL[i]}_zonsum_enlarged.nc ${WD}/OUT/${MODEL[i]}/${LZ}${MODEL[i]}_latnorm.nc
	cdo mul ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_Map_2080-2100.nc -enlarge,${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_Map_2080-2100.nc ${WD}/OUT/${MODEL[i]}/${LZ}${MODEL[i]}_latnorm.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_latmean_2080-2100_${LZ}_temp.nc
	cdo zonsum ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_latmean_2080-2100_${LZ}_temp.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_latmean_2080-2100_${LZ}.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_latmean_2080-2100_${LZ}_temp.nc
	rm ${WD}/OUT/${MODEL[i]}/${LZ}${MODEL[i]}_zonsum_enlarged.nc
done #End zonal means

# For zones of interest get timeseries, EOC means, and monthly means for historic and EOC
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
cdo setgrid,r${NLON[i]}x${NLAT[i]} ${WD}/OUT/${MODEL[i]}/Mollisol${MODEL[i]}_rect.nc ${WD}/OUT/${MODEL[i]}/Mollisol${MODEL[i]}_rect-temp.nc 
cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/OUT/${MODEL[i]}/Mollisol${MODEL[i]}_rect-temp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp.nc
cdo enlarge,${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp.nc -fldsum ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp2.nc
cdo div ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp2.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights.nc
rm ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp.nc
rm ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp2.nc
# Historic monthly means
	#Need to regrid temps to rectangular to ensure match-up with 21st century
	cdo genbil,r${NLON[i]}x${NLAT[i]} ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_remapweights.nc
	cdo remap,r${NLON[i]}x${NLAT[i]},${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_remapweights.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_rect.nc
	cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_rect.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp.nc
	cdo enlarge,${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc
	cdo mul ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp2.nc
	cdo fldsum ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp2.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp2.nc
	rm ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc
	#rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_remapweights.nc
# End of century monthly means
	cdo ymonmean -seldate,2080-01-0100:00,2100-12-3100:00 ${WD}/${VAR}-${EXP2}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_${ENS}_200601-210012.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon.nc
	# Need to regrid temps to rectangular
	cdo genbil,r${NLON[i]}x${NLAT[i]} ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_remapweights.nc
	cdo remap,r${NLON[i]}x${NLAT[i]},${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_remapweights.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_rect.nc
	cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_rect.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_rect_${ZO}-temp.nc
	cdo enlarge,${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_rect_${ZO}-temp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc
	cdo mul ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_rect_${ZO}-temp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_rect_${ZO}-temp2.nc
	cdo fldsum ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_rect_${ZO}-temp2.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_2080-2100_mon_${ZO}.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_remapweights.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_rect.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_rect_${ZO}-temp.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_rect_${ZO}-temp2.nc
# Timeseries anomaly
	cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land_NoIce.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${ZO}-temp.nc
	cdo fldsum -mul ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${ZO}-temp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_ts_${ZO}.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${ZO}-temp.nc
	rm ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc
	# Annual timeseries
	cdo yearmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_ts_${ZO}.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_annual_${ZO}.nc
	# # End of century region anomaly mean
	cdo timmean -seldate,2080-01-0100:00,2100-12-3100:00 ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_ts_${ZO}.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_2080-2100_anom_region_${ZO}.nc
# # Remove monthly timeseries
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_ts_${ZO}.nc
# Yearmin, yearmax, yearmean profiles
if [ $ZO = "GreatPlains" -a $VAR = "tsl" ]
	then
	cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmin_${ZO}_temp.nc
	cdo timmean -fldmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmin_${ZO}_temp.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmin_${ZO}.nc
	cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmax_${ZO}_temp.nc
	cdo timmean -fldmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmax_${ZO}_temp.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmax_${ZO}.nc
	cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}_temp.nc
	cdo timmean -fldmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}_temp.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmean_${ZO}.nc
	cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmin_${ZO}_temp.nc
	cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmax_${ZO}_temp.nc
	cdo timmean -fldmean ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmin_${ZO}_temp.nc ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmin_${ZO}.nc
	cdo timmean -fldmean ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmax_${ZO}_temp.nc ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmax_${ZO}.nc
	cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_mon.nc ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_mon_${ZO}_temp.nc
	cdo timmean -fldmean ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_mon_${ZO}_temp.nc ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmean_${ZO}.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc
	rm ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc
	rm ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmin_${ZO}_temp.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmax_${ZO}_temp.nc
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}_temp.nc
	rm ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmin_${ZO}_temp.nc
	rm ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmax_${ZO}_temp.nc
	rm ${WD}/OUT/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_mon_${ZO}_temp.nc
	fi
 done #End zones of interest
 done #End experiment loop
 done #End model loop; one variable
 done # End variable loop

MODEL=("bcc-csm1-1" "BNU-ESM" "CanESM2" "CCSM4" "CESM1-BGC" "GFDL-ESM2G" "GISS-E2-R" "HadGEM2-ES" "inmcm4" "IPSL-CM5A-LR" "MIROC5" "MPI-ESM-LR" "MRI-CGCM3" "NorESM1-M")
NLAT=(64 64 64 192 90 90 145 120 96 128 96 160 96 192)
NLON=(128 128 128 288 144 144 192 180 96 256 192 320 144 288)
#VAR="tsl"
VARIABLES=("tas") 
XP2=("rcp45") 
WD="data"
ENS="r2i1p1" #N.B. Need to change this for CCSM4
index=2 #(0 1 2 4 5 6 7 8 9 10 11 12 13) #0 1 2 4 5 6 7 8 9 
ZONE=("EuropeAlfisol" "CanadaGelisol" "AustraliaAridisol" "AmazonOxisol")
set -e
for VAR in ${VARIABLES[@]}; do
	if [ $VAR = "tas" ]
	then REALM="Amon"
	else REALM="Lmon"
	fi
for i in ${index[@]}; do ## loop over models
	echo ${MODEL[i]}
for EXP2 in ${XP2[@]}; do ## loop over experiments
for ZO in ${ZONE[@]}; do 
	#Set box lat and long
	if [ $ZO = "AmazonOxisol" ]
	then
		ZOLON1=280
		ZOLON2=320
		ZOLAT1=5
		ZOLAT2=-18
		SO="Oxisol"
	elif [ $ZO = "AustraliaAridisol" ]
	then
		ZOLON1=113
		ZOLON2=153
		ZOLAT1=-23
		ZOLAT2=-32
		SO="Aridisol"
	elif [ $ZO = "EuropeAlfisol" ]
	then
		ZOLON1=25
		ZOLON2=70
		ZOLAT1=60
		ZOLAT2=50
		SO="Alfisol"
	elif [ $ZO = "CanadaGelisol" ]
	then
		ZOLON1=220
		ZOLON2=300
		ZOLAT1=90
		ZOLAT2=52
		SO="Gelisol"
	else echo "Don't recognize zone."
	fi
	echo $ZO
	echo $ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2

	# Get the Soil order weights for the region
	cdo setgrid,r${NLON[i]}x${NLAT[i]} ${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_rect.nc ${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_rect-temp.nc 
	cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/OUT/${MODEL[i]}/${SO}${MODEL[i]}_rect-temp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp.nc
	cdo enlarge,${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp.nc -fldsum ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp2.nc
	cdo div ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp2.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights.nc
	
	rm ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp.nc
	rm ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}-boxtemp2.nc

	# Historic monthly means for each var
		# Calculate multiyear monthly means for no ice grids 
		cdo ymonmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon.nc
		
		#Need to regrid temps to rectangular to ensure match-up with 21st century
		cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp.nc
		cdo enlarge,${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc
		cdo mul ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp2.nc
		cdo fldsum ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp2.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}.nc
		rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp.nc
		rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp2.nc
		rm ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc

	# End of century monthly means for each var
		cdo ymonmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208001-210012_land_NoIce.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon.nc
		
		# Need to regrid temps to rectangular
		cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_${ZO}-temp.nc
		cdo enlarge,${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_${ZO}-temp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc
		cdo mul ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_${ZO}-temp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_${ZO}-temp2.nc
		cdo fldsum ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_${ZO}-temp2.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_2080-2100_mon_${ZO}.nc
		rm ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_${ZO}-temp.nc
		rm ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2080-2100_mon_${ZO}-temp2.nc

	# Timeseries anomaly for each var
		cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land_NoIce.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${ZO}-temp.nc
		cdo fldsum -mul ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${ZO}-temp.nc ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_ts_${ZO}.nc
		rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${ZO}-temp.nc
		rm ${WD}/OUT/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc

	# Annual timeseries
		cdo yearmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_ts_${ZO}.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_annual_${ZO}.nc
	# End of century region anomaly mean
		cdo timmean -seldate,2080-01-0100:00,2100-12-3100:00 ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_ts_${ZO}.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_2080-2100_anom_region_${ZO}.nc
	# Remove monthly timeseries
	rm ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_ts_${ZO}.nc
done #Zone
done #EXP2
done #Model
done #VARIABLES
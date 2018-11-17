## To get a full year, need to interpolate a dataset that goes 13 months. Inttime doesn't interpolate at the edges
# Completed are 0,1,2,3,11
MODEL="CCSM4" #("bcc-csm1-1" "BNU-ESM" "CanESM2" "CESM1-BGC" "CNRM-CM5" "GFDL-ESM2G" "GISS-E2-R" "HadGEM2-ES" "inmcm4" "IPSL-CM5A-LR" "MIROC5" "MPI-ESM-LR" "MRI-CGCM3" "NorESM1-M")
#VAR="tsl"
VARIABLES=("tas" "tsl") #("mrlsl")
WD="data"
ENS="r2i1p1"
index=(0) #(0 1 2 3 4 5 6 7 8 9 10 11 13 )

set e-
for VAR in ${VARIABLES[@]}; do
	if [ $VAR = "tas" ]
		then REALM="Amon"
		else REALM="Lmon"
	fi

	for i in ${index[@]}; do ## loop over models
		echo ${MODEL[i]}
		cdo ymonmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_ymon.nc
		cdo ymonmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_rcp85_208001-210012_land_NoIce.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_rcp85_2080-2100_ymon.nc
		cdo ymonmean ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_rcp45_208001-210012_land_NoIce.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_rcp45_2080-2100_ymon.nc
	
		cdo inttime,2005-01-16,12:00,1day ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_ymon.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_daily.nc
		cdo inttime,2100-01-16,12:00,1day ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_rcp85_2080-2100_ymon.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_rcp85_2080-2100_daily.nc
		cdo inttime,2100-01-16,12:00,1day ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_rcp45_2080-2100_ymon.nc ${WD}/OUT/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_rcp45_2080-2100_daily.nc
	done
done

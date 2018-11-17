# Catherine Ledna
# 10/31/18

## Initialization
MODEL=("bcc-csm1-1" "BNU-ESM" "CanESM2" "CESM1-BGC" "CNRM-CM5" "GFDL-ESM2G" "GISS-E2-R" "HadGEM2-ES" "inmcm4" "IPSL-CM5A-LR" "MIROC5" "MPI-ESM-LR" "MRI-CGCM3" "NorESM1-M" "CCSM4")
TOPZ=(0.007100635 0.007100600 0.05 0.007100635 193 000.01 000.05 000.05 0000.01 0.01785280 00.025 000.03 000.01 0.007100635 0.00710064)
Z1=(0.00710064 0.0071006 000.05 0.00710064 193 000.01 000.05 000.05 0000.01 0.0178528 00.025 000.03 000.01 0.00710064 0.00710064)
Z2=(1.03803 1.03803 02.225 1.03803 194 0000.9 0.8271 000002 001.05 0.932152 0001.5 000.78 001.25 1.03803 1.03803)
ZDIFF=(-1.03092936 -1.0309294 -2.175 -1.03092936 -1 -0.89 -0.7771 -1.95 -1.04 -0.9142992 -1.475 -0.75 -1.24 -1.03092936 -1.03092936)
ZDIFF1=(-0.00710064 -0.0071006 -000.05 -0.00710064 -193 -0.01 -0.05 -0.05 -0.01 -0.0178528 -0.025 -000.03 -0.01 -0.00710064 -0.00710064)
ZDIFF2=(-1.03803 -1.03803 -02.225 -1.03803 -194 -0.9 -0.8271 -2 -1.05 -0.932152 -1.5 -000.78 -1.25 -1.03803 -1.03803)
NLON=288
NLAT=192

# File names for land area files 
AREACELLA="areacella_fx_CCSM4_historical_r0i0p0"
LANDAREA="areacella_fx_CCSM4_historical_r0i0p0_land"
LANDNOICEAREA="areacella_fx_CCSM4_historical_r0i0p0_landNoIce"
GRID="ccsm4grid"

VARIABLES=("tas" "tsl")
XP=("historical" "rcp45" "rcp85")
WD="/Volumes/cmip5_soils/regridcmip5soildata"
OUT="OUT3"
index=(14)

SOIL=( "Rock" "ShiftingSand" )
#SOIL=( "Alfisol" "Gelisol" "Histosol" "Spodosol" "Andisol" "Oxisol" "Vertisol" "Aridisol" "Ultisol" "Mollisol" "Inceptisol" "Entisol")
LATZONE=( "Alfisol" "Andisol" "Aridisol" "Gelisol" "Inceptisol" "Mollisol")
ZONE=("GreatPlains" "PampasPlain" "EurasianSteppe" "ChinaMoll")

for VAR in ${VARIABLES[@]}; do
set +e
if [ $VAR = "tas" ]
	then REALM="Amon"
	else REALM="Lmon"
fi

for i in ${index[@]}; do ## loop over models

    if [ ${MODEL[$i]} = "CCSM4" ]
        then ENS="r2i1p1"
        else ENS="r1i1p1"
    fi

	for EXP in ${XP[@]}; do ## loop over experiments 
        fl_nbr=$( ls ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}*.nc | wc -w ) ## number of files in this ensemble member
        yyyymm_str=$( ls ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}*.nc | sed -n '1p' | cut -d '_' -f 7 | cut -d '-' -f 1 )
        yyyymm_end=$( ls ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}*.nc | sed -n "${fl_nbr}p" | cut -d '_' -f 7 | cut -d '-' -f 2 | cut -d '.' -f 1 )
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

        # Select the date range native for most of the, 200601-210012
        if [ $XPEND -ne 210012 ]
        then
        cdo seldate,2006-01-0100:00,2100-12-3100:00 ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}_${XPSTART}-${XPEND}.nc ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}_200601-210012.nc
        fi
    done #End EXP loop

    XP2=("rcp45" "rcp85") #Loop through the two 21st century experiments. Need to subtract historical from them.
    for EXP2 in ${XP2[@]}; do ## loop over experiments
        echo $VAR ${MODEL[$i]} $EXP2
        set -e
        
        ## SOIL ORDER RESULTS
        echo SOIL ORDER RESULTS
        for SO in ${SOIL[@]}; do ## loop over soils
            # Calculate soil area-weighted annual mean
            # Automatically excludes ocean, ice bc there is no soil area in ocean or land-ice covered regions
            cdo fldsum -mul ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom.nc ${WD}/soil-wts/${SO}_area.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${SO}_ts_temp.nc
            cdo div ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${SO}_ts_temp.nc -fldsum ${WD}/soil-wts/${SO}_area.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${SO}_ts.nc
            cdo yearmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${SO}_ts.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${SO}_ts_annual.nc
            # Get soil order global mean for 2081-2100
            cdo timmean -seldate,2081-01-0100:00,2100-12-0100:00 ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${SO}_ts.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_GlobalMean_2081-2100_${SO}.nc
        done #End soil order timeseries and means

echo FINISHING $VAR ${MODEL[$i]} $EXP2
done #End experiment loop
echo FINISHING $VAR ${MODEL[$i]}
done #End model loop
echo FINISHING $VAR
done # End variable loop
echo FINISHED
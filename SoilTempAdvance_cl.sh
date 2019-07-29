#  Catherine Ledna
# 1/24/19 latest update
# THIS SCRIPT ASSUMES YOU'VE ALREADY RUN CMIP5Analysis_clean_101318.sh for all models


## Initialization
MODEL=("bcc-csm1-1" "BNU-ESM" "CanESM2" "CESM1-BGC" "GFDL-ESM2G" "GISS-E2-R" "HadGEM2-ES" "inmcm4" "IPSL-CM5A-LR" "MIROC5" "MPI-ESM-LR" "MRI-CGCM3" "NorESM1-M" "CCSM4")
TOPZ=(0.007100635 0.007100600 0.05 0.007100635 000.01 000.05 000.05 0000.01 0.01785280 00.025 000.03 000.01 0.007100635 0.00710064)
Z1=(0.00710064 0.0071006 000.05 0.00710064 000.01 000.05 000.05 0000.01 0.0178528 00.025 000.03 000.01 0.00710064 0.00710064)
Z2=(1.03803 1.03803 02.225 1.03803 0000.9 0.8271 000002 001.05 0.932152 0001.5 000.78 001.25 1.03803 1.03803)
ZDIFF=(-1.03092936 -1.0309294 -2.175 -1.03092936 -0.89 -0.7771 -1.95 -1.04 -0.9142992 -1.475 -0.75 -1.24 -1.03092936 -1.03092936)
ZDIFF1=(-0.00710064 -0.0071006 -000.05 -0.00710064 -0.01 -0.05 -0.05 -0.01 -0.0178528 -0.025 -000.03 -0.01 -0.00710064 -0.00710064)
ZDIFF2=(-1.03803 -1.03803 -02.225 -1.03803 -0.9 -0.8271 -2 -1.05 -0.932152 -1.5 -000.78 -1.25 -1.03803 -1.03803)
NLON=288
NLAT=192

# File names for land area files 
AREACELLA="areacella_fx_CCSM4_historical_r0i0p0"
LANDAREA="areacella_fx_CCSM4_historical_r0i0p0_land"
LANDNOICEAREA="areacella_fx_CCSM4_historical_r0i0p0_landNoIce"
GRID="ccsm4grid"


VARIABLES=("tsl" "tas")
XP=("rcp85")
WD="/Volumes/cmip5_soils/regridcmip5soildata"
OUT="OUT3"
index=(13) # completed 0,1,2,3,4,5,6,7,8,9,10,11,12

SOIL=( "Rock" "ShiftingSand" "Gelisol" "Histosol" "Spodosol" "Andisol" "Oxisol" "Vertisol" "Aridisol" "Ultisol" "Mollisol" "Alfisol" "Inceptisol" "Entisol" )
LATZONE=( "Alfisol" "Andisol" "Aridisol" "Gelisol" "Inceptisol" "Mollisol")
ZONE=("GreatPlains" "PampasPlain" "EurasianSteppe" "ChinaMoll")

for VAR in ${VARIABLES[@]}; do
    if [ $VAR = "tas" ]
	    then REALM="Amon"
	    else REALM="Lmon"
    fi

    for i in ${index[@]}; do ## loop over models
        if [ ${MODEL[$i]} = "CCSM4" ]
            then ENS="r2i1p1"
            else ENS="r1i1p1"
        fi

        # Calculate Global 
        # Historical: 
        cdo fldsum -mul ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512.nc ${WD}/area-wts/${LANDNOICEAREA}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_temp.nc
        cdo div ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_temp.nc -fldsum ${WD}/area-wts/${LANDNOICEAREA}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_ts_mon.nc
        rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_temp.nc
        cdo ymonmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_ts_mon.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_ts_ymon.nc
        cdo inttime,2005-01-16,12:00,1day ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_ts_ymon.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_ts_daily.nc
        rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_ts_mon.nc
        rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_ts_ymon.nc


        for XP1 in ${XP[@]}; do
            # EOC: 
            cdo fldsum -mul ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_208101-210012.nc ${WD}/area-wts/${LANDNOICEAREA}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_2081-2100_temp.nc
            cdo div ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_2081-2100_temp.nc -fldsum ${WD}/area-wts/${LANDNOICEAREA}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_2081-2100_ts_mon.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_2081-2100_temp.nc
            cdo ymonmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_2081-2100_ts_mon.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_2081-2100_ts_ymon.nc
            cdo inttime,2100-01-16,12:00,1day ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_2081-2100_ts_ymon.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_2081-2100_ts_daily.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_2081-2100_ts_mon.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_2081-2100_ts_ymon.nc

        done

           
        for SO in ${SOIL[@]}; do ## loop over soils
            ## Step 1: Get historical monthly temperature data (global mean) for each soil order 
            # Automatically excludes ocean, ice bc there is no soil area in ocean or land-ice covered regions
            cdo fldsum -mul ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512.nc ${WD}/soil-wts/${SO}_area.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_${SO}_ts_temp.nc
            cdo div ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_${SO}_ts_temp.nc -fldsum ${WD}/soil-wts/${SO}_area.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_${SO}_ts.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_${SO}_ts_temp.nc
            
            ## Step 2: Interpolate monthly values to daily for historical period 
            cdo ymonmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_${SO}_ts.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_${SO}_ts_ymon.nc
            cdo inttime,2005-01-16,12:00,1day ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_${SO}_ts_ymon.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_${SO}_ts_daily.nc
            #cdo inttime,1986-02-15,12:00,1day ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_${SO}_ts.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_${SO}_ts_all_daily.nc
            
            ## Step 3: Get RCP monthly temperature data (global mean) for each soil order (absolute, not anom), and interpolate
            for XP1 in ${XP[@]}; do
                
                # 3a. global monthly mean by soil order
                cdo fldsum -mul ${WD}/${VAR}-${XP1}/${VAR}_${REALM}_${MODEL[i]}_${XP1}_${ENS}_200601-210012_regrid.nc ${WD}/soil-wts/${SO}_area.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_200601-210012_${SO}_ts_temp.nc
                cdo div ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_200601-210012_${SO}_ts_temp.nc -fldsum ${WD}/soil-wts/${SO}_area.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_200601-210012_${SO}_ts_mon.nc
                rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_200601-210012_${SO}_ts_temp.nc

                #3b. interpolated to daily 
                cdo seldate,2081-01-0100:00,2100-12-3100:00 ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_200601-210012_${SO}_ts_mon.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_208101-210012_${SO}_ts_mon.nc
                cdo ymonmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_208101-210012_${SO}_ts_mon.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_208101-210012_${SO}_ts_ymon.nc
                cdo inttime,2100-01-16,12:00,1day ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_208101-210012_${SO}_ts_ymon.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_208101-210012_${SO}_ts_daily.nc
                # skip 2006 bc of missing days randomly 
                #cdo inttime,2007-01-16,12:00,1day ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_200601-210012_${SO}_ts_mon.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${XP1}_200601-210012_${SO}_ts_all_daily.nc

            done # End XP loop


        done #End soil order timeseries and means

    done # End models loop

done # End variable loop
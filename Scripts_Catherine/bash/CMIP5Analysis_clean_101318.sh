# Catherine Ledna
# 10/31/18 latest update
 
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

VARIABLES=("mrlsl")
XP=("historical" "rcp45" "rcp85")
WD="/Volumes/cmip5_soils/regridcmip5soildata"
OUT="OUT3"
index=(5 6)

# TODO add rock, shiftingsand from NRCS
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
        if [ $XPEND -gt 210012 ]
        then
        cdo seldate,2006-01-0100:00,2100-12-3100:00 ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}_${XPSTART}-${XPEND}.nc ${WD}/${VAR}-${EXP}/${VAR}_${REALM}_${MODEL[$i]}_${EXP}_${ENS}_200601-210012.nc
        fi
    done #End EXP loop

    XP2=("rcp45" "rcp85") #Loop through the two 21st century experiments. Need to subtract historical from them.
    for EXP2 in ${XP2[@]}; do ## loop over experiments
        echo $VAR ${MODEL[$i]} $EXP2
        set -e
        #Select the historical data range, 1986-2005
        cdo seldate,1986-01-0100:00,2005-12-3100:00 ${WD}/${VAR}-historical/${VAR}_${REALM}_${MODEL[i]}_historical_${ENS}_${HISTSTART}-${HISTEND}_regrid.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512.nc

        # #Calculate monthly averages for the 20 year period
        cdo ymonmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon.nc

        # # #Subtract the historic period from 21st century
        if [ ${MODEL[$i]} = "GISS-E2-R" -a $EXP2 = "rcp45" ]
        then
            cdo ymonsub ${WD}/${VAR}-${EXP2}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_${ENS}_202001-208912_regrid.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom.nc
        else
            cdo ymonsub ${WD}/${VAR}-${EXP2}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_${ENS}_200601-210012_regrid.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom.nc
        fi
                
        # # #Select the EOC period
        if [ ${MODEL[$i]} = "GISS-E2-R" -a $EXP2 = "rcp45" ]
        then
            cdo seldate,2081-01-0100:00,2100-12-3100:00 ${WD}/${VAR}-${EXP2}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_${ENS}_202001-208912_regrid.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208101-210012.nc
        else
            cdo seldate,2081-01-0100:00,2100-12-3100:00 ${WD}/${VAR}-${EXP2}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_${ENS}_200601-210012_regrid.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208101-210012.nc
        fi
                        
        #Apply ocean mask
        # Update 10-31-18 CL: Applying to all variables to normalize results of regridding process, instead of tas only
        # Ocean mask: masks out all ocean areas from calculation. For use with visual maps, but not area-weighted averages, as ice is included and coastal area not treated properly  
        cdo ifthen ${WD}/area-wts/${LANDAREA}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land.nc
        cdo ifthen ${WD}/area-wts/${LANDAREA}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208101-210012.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208101-210012_land.nc
        cdo ifthen ${WD}/area-wts/${LANDAREA}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land.nc

        # Land, no ice mask: masks out all ocean and land-ice (i.e. glaciers, Antarctica, Greenland).  
        cdo ifthen ${WD}/area-wts/${LANDNOICEAREA}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land_NoIce.nc
        cdo ifthen ${WD}/area-wts/${LANDNOICEAREA}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208101-210012.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208101-210012_land_NoIce.nc
        cdo ifthen ${WD}/area-wts/${LANDNOICEAREA}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce.nc

        ### GLOBAL MEAN OUTFILES
        ## ANOMALY TIMESERIES, ANNUAL AVGS 
        ## Land, no Ice
        cdo fldsum -mul ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom.nc ${WD}/area-wts/${LANDNOICEAREA}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_global_ts_temp.nc
        cdo div ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_global_ts_temp.nc -fldsum ${WD}/area-wts/${LANDNOICEAREA}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_global_ts_temp2.nc 
        cdo yearmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_global_ts_temp2.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_global_ts.nc
        rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_global_ts_temp2.nc 
        rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_global_ts_temp.nc 

        ## 2081-2100 DELTA MAP
        # Note: includes ice regions for display purposes
        cdo timmean -seldate,2081-01-0100:00,2100-12-3100:00 ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_Map_2081-2100.nc
        # No-ice version: 
        cdo timmean -seldate,2081-01-0100:00,2100-12-3100:00 ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land_NoIce.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_Map_2081-2100_NoIce.nc

        ## 2081-2100 GLOBAL MEAN DELTA
        # Land, No Ice
        cdo fldsum -mul -seldate,2081-01-0100:00,2100-12-3100:00 ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom.nc ${WD}/area-wts/${LANDNOICEAREA}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_GlobalMean_2081-2100_temp.nc
        cdo div ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_GlobalMean_2081-2100_temp.nc -fldsum ${WD}/area-wts/${LANDNOICEAREA}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_GlobalMean_2081-2100_temp2.nc
        cdo timmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_GlobalMean_2081-2100_temp2.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_GlobalMean_2081-2100_NoIce.nc
        rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_GlobalMean_2081-2100_temp.nc
        rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_GlobalMean_2081-2100_temp2.nc

        ## 1986-2005 HISTORIC SOIL PHYSICS DIAGNOSTICS
        if [ $VAR = "tsl" ]
        then
            set +e
            ## Get soil amplitudes
	        cdo yearmin  ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce.nc  ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc
	        cdo yearmax ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce.nc  ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc
            cdo sub ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude_temp.nc
	        cdo timmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude_temp.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude.nc
	        rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude_temp.nc
            
            ## Get air temp amplitude
            cdo yearmin  ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce.nc  ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc
            cdo yearmax ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce.nc  ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc
            cdo sub ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_amplitude_temp.nc
            cdo timmean ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_amplitude_temp.nc ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_amplitude.nc
            rm ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_amplitude_temp.nc

            ## Calculate damping depth from annual air amplitudes and Z1 amplitude
            cdo splitlevel ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-
            cdo -b f64 sub -ln ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-${Z1[i]}.nc -ln ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_amplitude.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc
            cdo const,${ZDIFF1[i]},${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF_temp.nc
            cdo settaxis,1986-01-01,00:00,1mon ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF_temp.nc ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF.nc
            cdo -b f64 -f nc4 div ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF.nc  ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_dampv1.nc
            #rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-*
            rm ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF*
            
            ## Calculate damping depth from annual air amplitudes and Z2 amplitude
            #cdo splitlevel ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-
            cdo -b f64 sub -ln ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-${Z2[i]}.nc -ln ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_amplitude.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc
            cdo const,${ZDIFF2[i]},${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF_temp.nc
            cdo settaxis,1986-01-01,00:00,1mon ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF_temp.nc ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF.nc
            cdo -b f64 -f nc4 div ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF.nc  ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_dampv2.nc
            #rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-*
            rm ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF*
            
            ## Calculate damping depth from Z1 and Z2 amplitude
            #cdo splitlevel ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-
            cdo -b f64 sub -ln ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-${Z2[i]}.nc -ln ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-${Z1[i]}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc
            cdo const,${ZDIFF[i]},${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF_temp.nc
            cdo settaxis,1986-01-01,00:00,1mon ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF_temp.nc ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF.nc
            cdo -b f64 -f nc4 div ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF.nc  ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-temp2.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_damp.nc
            #rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_amplitude-*
            rm ${WD}/${OUT}/${MODEL[i]}/${MODEL[i]}_ZDIFF*
            set -e
        fi
        ## Output maps of absolute (not delta) mean annual temp/mrlsl, which will be regressors for damping depth. NOTE, THESE ARE RECTANGULAR!!
    	cdo timmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_meanannual.nc
	    cdo timmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208101-210012_land_NoIce.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_208101-210012_meanannual.nc

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
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${SO}_ts_temp.nc
        done #End soil order timeseries and means

        # Zonal means for some soil orders
        # Global zonal mean
        echo ZONAL MEANS
        cdo zonmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_Map_2081-2100_NoIce.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_latmean_2081-2100_Global.nc
        for LZ in ${LATZONE[@]}; do # loop over soils of interest
            # Get soil order weights for latitudes (zones)
            ## TODO this hasn't been vetted against the old version; since it's not being used in major analysis, will leave as-is for now bc it looks reasonable
            #   (but should check later)
            cdo enlarge,${WD}/soil-wts/${LZ}_area.nc -zonsum ${WD}/soil-wts/${LZ}_area.nc ${WD}/${OUT}/${MODEL[i]}/${LZ}${MODEL[i]}_zonsum_enlarged.nc
            cdo div ${WD}/soil-wts/${LZ}_area.nc ${WD}/${OUT}/${MODEL[i]}/${LZ}${MODEL[i]}_zonsum_enlarged.nc ${WD}/${OUT}/${MODEL[i]}/${LZ}${MODEL[i]}_latnorm.nc
            cdo mul ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_Map_2081-2100_NoIce.nc -enlarge,${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_Map_2081-2100_NoIce.nc ${WD}/${OUT}/${MODEL[i]}/${LZ}${MODEL[i]}_latnorm.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_latmean_2081-2100_${LZ}_temp.nc
            cdo zonsum ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_latmean_2081-2100_${LZ}_temp.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_latmean_2081-2100_${LZ}.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_latmean_2081-2100_${LZ}_temp.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${LZ}${MODEL[i]}_zonsum_enlarged.nc
        done #End zonal means

        # For zones of interest get timeseries, EOC means, and monthly means for historic and EOC
        echo ZONES OF INTEREST
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
            # Get the Mollisol weights for the region from the soil-wts folder (pre-calculated for all models)
            # Historic monthly means
            cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp.nc
            cdo enlarge,${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp.nc ${WD}/soil-wts/${ZO}Mollisol_weights.nc ${WD}/${OUT}/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc
            cdo mul ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp.nc ${WD}/${OUT}/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp2.nc
            cdo fldsum ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp2.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}-temp2.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc
            #rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon.nc
            
            # End of century monthly means
            if [ ${MODEL[$i]} = "GISS-E2-R" -a $EXP2 = "rcp45" ]
            then
                cdo ymonmean -seldate,2081-01-0100:00,2100-12-3100:00 ${WD}/${VAR}-${EXP2}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_${ENS}_202001-208912_regrid.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2081-2100_mon.nc
            else
                cdo ymonmean -seldate,2081-01-0100:00,2100-12-3100:00 ${WD}/${VAR}-${EXP2}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_${ENS}_200601-210012_regrid.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2081-2100_mon.nc
            fi

           
            cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/${OUT}/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2081-2100_mon.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2081-2100_mon_${ZO}-temp.nc
            cdo enlarge,${WD}/${OUT}/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2081-2100_mon_${ZO}-temp.nc ${WD}/soil-wts/${ZO}Mollisol_weights.nc ${WD}/${OUT}/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc
            cdo mul ${WD}/${OUT}/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2081-2100_mon_${ZO}-temp.nc ${WD}/${OUT}/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2081-2100_mon_${ZO}-temp2.nc
            cdo fldsum ${WD}/${OUT}/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2081-2100_mon_${ZO}-temp2.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_2081-2100_mon_${ZO}.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2081-2100_mon_${ZO}-temp.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${REALM}_${MODEL[i]}_${EXP2}_2081-2100_mon_${ZO}-temp2.nc

            # Timeseries anomaly
            # TODO harmonize land_NoIce issue
            cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_land_NoIce.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${ZO}-temp.nc
            cdo fldsum -mul ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${ZO}-temp.nc ${WD}/${OUT}/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_ts_${ZO}.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_${ZO}-temp.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${ZO}${MODEL[i]}_weights_enlarged.nc

            # Annual timeseries
            cdo yearmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_ts_${ZO}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_annual_${ZO}.nc
            # # End of century region anomaly mean
            cdo timmean -seldate,2081-01-0100:00,2100-12-3100:00 ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_ts_${ZO}.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_2081-2100_anom_region_${ZO}.nc
            # Remove monthly timeseries
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_${EXP2}_200601-210012_anom_ts_${ZO}.nc

            # # Yearmin, yearmax, yearmean profiles
            #   Q CL: there is no soil weighting here; this assumes that all area is mollisol? Or does it want un-mollisol means?
            if [ $ZO = "GreatPlains" -a $VAR = "tsl" ]
            then
            cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmin_${ZO}_temp.nc            
            cdo timmean -fldmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmin_${ZO}_temp.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmin_${ZO}.nc
            cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmax_${ZO}_temp.nc
            cdo timmean -fldmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmax_${ZO}_temp.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmax_${ZO}.nc
            cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}_temp.nc
            cdo timmean -fldmean ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}_temp.nc ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmean_${ZO}.nc
            cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmin_${ZO}_temp.nc
            cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmax_${ZO}_temp.nc
            cdo timmean -fldmean ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmin_${ZO}_temp.nc ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmin_${ZO}.nc
            cdo timmean -fldmean ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmax_${ZO}_temp.nc ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmax_${ZO}.nc
            cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_mon.nc ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_mon_${ZO}_temp.nc
            cdo timmean -fldmean ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_mon_${ZO}_temp.nc ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmean_${ZO}.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc
            rm ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmin.nc
            rm ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_land_NoIce_yearmax.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmin_${ZO}_temp.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_yearmax_${ZO}_temp.nc
            rm ${WD}/${OUT}/${MODEL[i]}/${VAR}_${MODEL[i]}_198601-200512_mon_${ZO}_temp.nc
            rm ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmin_${ZO}_temp.nc
            rm ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_yearmax_${ZO}_temp.nc
            rm ${WD}/${OUT}/${MODEL[i]}/tas_${MODEL[i]}_198601-200512_mon_${ZO}_temp.nc
            fi

done # End zones of interest
echo FINISHING $VAR ${MODEL[$i]} $EXP2
done #End experiment loop
echo FINISHING $VAR ${MODEL[$i]}
done #End model loop
echo FINISHING $VAR
done # End variable loop
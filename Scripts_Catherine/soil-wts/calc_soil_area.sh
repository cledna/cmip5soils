## Calculate Soil Area from Soil Weights
# Catherine Ledna
# 10/13/18

SOIL=( "Gelisol" "Histosol" "Spodosol" "Andisol" "Oxisol" "Vertisol" "Aridisol" "Ultisol" "Mollisol" "Alfisol" "Inceptisol" "Entisol" )
AREACELLA="areacella_fx_CCSM4_historical_r0i0p0"
WD="/Volumes/cmip5_soils/regridcmip5soildata"

for SO in ${SOIL[@]}; do 
    cdo mul ${WD}/area-wts/${AREACELLA}.nc ${WD}/soil-wts/${SO}_regrid.nc ${WD}/soil-wts/${SO}_area.nc
done

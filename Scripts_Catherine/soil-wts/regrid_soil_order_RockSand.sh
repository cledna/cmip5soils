# Catherine Ledna
# August 13, 2018
# Script to regrid soil order masks generated by soil-wts/make_soil_order_maps_oceamask.py (file name [SoilOrder]_derezed10_cl.nc)
#   to CCSM4 grid

SOIL=( "Rock" "ShiftingSand" )
WD="/Volumes/cmip5_soils/regridcmip5soildata/soil-wts"

for SO in ${SOIL[@]}; do 
    ncremap -i ${WD}/${SO}_derezed10_cl.nc -r 0.1 -g ${WD}/ccsm4grid.nc -o ${WD}/${SO}_regrid.nc
done
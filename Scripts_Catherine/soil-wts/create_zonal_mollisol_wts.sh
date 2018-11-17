## Create Zonal Mollisol Weights
# Catherine Ledna
# 10/13/18

WD="/Volumes/cmip5_soils/Scripts_Catherine/BashScripts/LandNoIceArea/test"
ZONE=("GreatPlains" "PampasPlain" "EurasianSteppe" "ChinaMoll")

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

    cdo sellonlatbox,$ZOLON1,$ZOLON2,$ZOLAT1,$ZOLAT2 ${WD}/soil-wts/Mollisol_area.nc ${WD}/soil-wts/${ZO}-boxtemp.nc
    cdo enlarge,${WD}/soil-wts/${ZO}-boxtemp.nc -fldsum ${WD}/soil-wts/${ZO}-boxtemp.nc ${WD}/soil-wts/${ZO}-boxtemp2.nc
    cdo div ${WD}/soil-wts/${ZO}-boxtemp.nc ${WD}/soil-wts/${ZO}-boxtemp2.nc ${WD}/soil-wts/${ZO}Mollisol_weights.nc

    rm ${WD}/soil-wts/${ZO}-boxtemp.nc
    rm ${WD}/soil-wts/${ZO}-boxtemp2.nc

done
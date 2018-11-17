import numpy as np
import netCDF4 as nc4
#import map_funcs

fname_in = "nrcs_order_map.nc"

fin = nc4.Dataset(fname_in)

soil_order_dict = {1:'Gelisol',
                       2:'Histosol',
                       3:'Spodosol',
                       4:'Andisol',
                       5:'Oxisol',
                       6:'Vertisol',
                       7:'Aridisol',
                       8:'Ultisol',
                       9:'Mollisol',
                       10:'Alfisol',
                       11:'Inceptisol',
                       12:'Entisol'
                       }

lats = fin.variables['lat'][:]
lons = fin.variables['lon'][:]

dlat = lats[1] - lats[0]
dlon = lons[1] - lons[0]

JM_i = len(lats)
IM_i = len(lons)

regrid_factor = 10
IM_o = IM_i // regrid_factor
JM_o = JM_i // regrid_factor

lats_o = np.zeros(JM_o)
lons_o = np.zeros(IM_o)

for i in range(IM_o):
    lons_o[i] = lons[i*regrid_factor:(i+1)*regrid_factor].mean()

for j in range(JM_o):
    lats_o[j] = lats[j*regrid_factor:(j+1)*regrid_factor].mean()

order_map_regrid = np.ma.masked_all([JM_o,IM_o])
np.ma.set_fill_value(order_map_regrid,0) # CL: fix default fill value

for i in range(1,13):
    order_map = (fin.variables['order'][:] == i) * 1.
    # Unmask order map-- we don't need it for our purposes
    order_map.mask = np.ma.nomask
    for ii in range(IM_o):
        if ii%100 == 0:
            print(i, ii, IM_o)
        for jj in range(JM_o):
            order_map_regrid[jj,ii] = order_map[jj*regrid_factor:(jj+1)*regrid_factor,ii*regrid_factor:(ii+1)*regrid_factor].mean()
    fname_out = soil_order_dict[i]+'_derezed10_cl.nc'
    fout = nc4.Dataset(fname_out, 'w')
    fout.createDimension('lat', JM_o)
    fout.createDimension('lon', IM_o)    
    outVar = fout.createVariable(soil_order_dict[i], 'f4', fin.variables['order'].dimensions)
    latVar = fout.createVariable('lat', 'f4', 'lat')
    lonVar = fout.createVariable('lon', 'f4', 'lon')
    lonVar.units = 'degrees_east'
    latVar.units = 'degrees_north'
    lonVar.standard_name = "longitude"
    lonVar.long_name = "longitude"
    lonVar.axis = "X"
    latVar.standard_name = "latitude"
    latVar.long_name = "latitude"
    latVar.axis = "Y"
    latVar[:] = lats_o
    lonVar[:] = lons_o
    outVar[:] = order_map_regrid
    fout.close()

        

#map_funcs.fill(gelisol, lats, lons)


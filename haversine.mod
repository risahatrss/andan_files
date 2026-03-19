/* 
 An approximate formula to compute shortest path distance from coordinates

 min_distance  - a parameter used to prevent zero distance when points are in the same city 
 
 param distance {d in DC, s in STORES} := 
 			max(rdf * sqrt((71.5 * (store_lon[s] - dc_lon[d]))^2 
 							+ (111 * (store_lat[s] - dc_lat[d]))^2), min_distance);

For Russia, this formula produces an overstated distance, by ~10% */


/* 
 Haversine formula implementation in AMPL
 http://gis-lab.info/qa/great-circles.html
 */

# Convert lat/lon to radians
param pi := 3.14159265358979;
param dc_lat_r {d in DC} := dc_lat[d] * pi / 180;
param dc_lon_r {d in DC} := dc_lon[d] * pi / 180;
param store_lat_r {s in STORES} := store_lat[s] * pi / 180;
param store_lon_r {s in STORES} := store_lon[s] * pi / 180;

# longitude delta:
param delta_lon_r {d in DC, s in STORES} := store_lon_r[s] - dc_lon_r[d];

# the distance between points in radians:
param delta {d in DC, s in STORES} :=
	atan( sqrt( (cos(store_lat_r[s])*sin(delta_lon_r[d,s]))^2 
					+ (cos(dc_lat_r[d])*sin(store_lat_r[s]) 
					- sin(dc_lat_r[d])*cos(store_lat_r[s])*cos(delta_lon_r[d,s]))^2 )
		/ ( sin(dc_lat_r[d])*sin(store_lat_r[s]) 
			+ cos(dc_lat_r[d])*cos(store_lat_r[s])*cos(delta_lon_r[d,s]) )
		);
				
param km_radian := 6372.795; 
# Earth radius to convert from radians to km

param distance {d in DC, s in STORES} := 
		max(delta[d, s] * km_radian * rdf, min_distance); # distance in km

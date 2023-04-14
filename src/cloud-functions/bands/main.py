import json
import ee
from datetime import datetime
import calendar
import geojson
import shapely
from google.auth import compute_engine
from shapely import wkt

scopes = ["https://www.googleapis.com/auth/earthengine"]
credentials = compute_engine.Credentials(scopes=scopes)
ee.Initialize(credentials)


def get_landsat_month(request):

      request_json = request.get_json(silent=True)
      replies = []
      calls = request_json['calls']
      for call in calls:

        farm_json_str = call[0]
        #farm_name = call[1]
        farm_year = call[1]
        farm_mon = call[2]
        farm_json = shapely.wkt.loads(farm_json_str)
        farm_poly = geojson.Feature(geometry=farm_json, properties={})
        farm_aoi = ee.Geometry(farm_poly.geometry)

        #print("Farm ",farm_name)

        ee_bands = get_landsat_data(farm_aoi,farm_year,farm_mon)
        #ndvi = ee_ndvi.getInfo()

        replies.append(ee_bands)
      return json.dumps({'replies': [str(x) for x in ee.List(replies).getInfo()]})

 


def get_landsat_data(farm_aoi, year, month):
    
    point =  farm_aoi #ee.Geometry.Point(lon, lat)
 
    if (len(str(month))==1):
        month = '0'+str(month)
    else:
        month = str(month)

    # Landsat 5
    if year >= 1984 and year <= 1999:
        ls5 = ee.ImageCollection('LANDSAT/LT05/C01/T1_SR')\
            .filterBounds(point)\
            .filterDate(str(year)+'-'+ str(month)+ '-01', str(year)+'-'+ str(month)+ '31')\
            .sort('CLOUD_COVER')\
            .first()
        band_names = ls5.bandNames().getInfo()
        bands = ls5.select(band_names).reduceRegion(
            reducer=ee.Reducer.mean(),
            geometry=point,
            scale=30
        ).getInfo()
        
    # Landsat 7
    elif year > 1999 and year <= 2013:
        ls7 = ee.ImageCollection('LANDSAT/LE07/C01/T1_SR')\
            .filterBounds(point)\
            .filterDate(str(year)+'-01-01', str(year)+'-12-31')\
            .sort('CLOUD_COVER')\
            .first()
        band_names = ls7.bandNames().getInfo()
        bands = ls7.select(band_names).reduceRegion(
            reducer=ee.Reducer.mean(),
            geometry=point,
            scale=30
        ).getInfo()
        
    # Landsat 8
    elif year > 2013 and year <= 2021:
        ls8 = ee.ImageCollection('LANDSAT/LC08/C01/T1_SR')\
            .filterBounds(point)\
            .filterDate(str(year)+'-01-01', str(year)+'-12-31')\
            .sort('CLOUD_COVER')\
            .first()
        band_names = ls8.bandNames().getInfo()
        bands = ls8.select(band_names).reduceRegion(
            reducer=ee.Reducer.mean(),
            geometry=point,
            scale=30
        ).getInfo()
    
    # Landsat 9
    else:
        ls9 = ee.ImageCollection('LANDSAT/LC09/C01/T1_SR')\
            .filterBounds(point)\
            .filterDate(str(year)+'-01-01', str(year)+'-12-31')\
            .sort('CLOUD_COVER')\
            .first()
        band_names = ls9.bandNames().getInfo()
        bands = ls9.select(band_names).reduceRegion(
            reducer=ee.Reducer.mean(),
            geometry=point,
            scale=30
        ).getInfo()

    return bands
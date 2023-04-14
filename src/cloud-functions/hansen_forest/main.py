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

def get_forest_lost_year(request):
    request_json = request.get_json(silent=True)
    print('Req Json',type(request_json))
    replies = []
    calls = request_json['calls']
    for call in calls:
        farm_json_str = call[0]
        # farm_year = call[1]
        farm_json = shapely.wkt.loads(farm_json_str)
        farm_poly = geojson.Feature(geometry=farm_json, properties={})
        farm_aoi = ee.Geometry(farm_poly.geometry)
        # ee_forest_lost = get_forest_loss(farm_aoi,farm_year)
        ee_forest_lost = get_forest_loss(farm_aoi)


        replies.append(ee_forest_lost)

    return json.dumps({'replies': [str(x) for x in replies]})
 

# def get_forest_loss(farm_aoi , year ):
    # Get a feature collection with just the feature of interest.
    # in the case the year is 
    # if type(year)==int or type(year)==float:
    #     year = str(year)
def get_forest_loss(farm_aoi  ):
        
    # Get the loss image for the year of interest.
    gfc_yearly = ee.Image('UMD/hansen/global_forest_change_2020_v1_8')
     
    loss_image = gfc_yearly.select(['loss'])
    loss_area_image = loss_image.multiply(ee.Image.pixelArea())
    loss_year = gfc_yearly.select(['lossyear'])
    loss_by_year = loss_area_image.addBands(loss_year).reduceRegion(
        reducer=ee.Reducer.sum().group(1),
        geometry=farm_aoi,
        scale=30,
        maxPixels=1e9
    )

    stats_formatted = ee.List(loss_by_year.get('groups')).map(
        lambda el: [ee.Number(ee.Dictionary(el).get('group')).format("20%02d"), ee.Dictionary(el).get('sum')]
    )
    stats_dictionary = ee.Dictionary(stats_formatted.flatten())
    loss_stats = stats_dictionary.getInfo()
    #loss_stats = loss_stats[year]
    return loss_stats
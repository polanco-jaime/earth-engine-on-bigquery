#!/bin/bash

#####################################################################################################
# Script Name: deploy_cf.sh
# Date of Creation: 8/11/2022
# Author: Ankur Wahi
# Updated: 9/26/2022
#####################################################################################################

source ./config.sh

project_id=${PROJECT_ID}
cf_hansen="hansen-gen2"
cf_bands="polybands-gen2"
cf_ndvi="polyndvicf-gen2"
cf_temp="polytempcf-gen2"
cf_dynamic="dynamic-gen2"
cf_crop="polycrop-gen2"
cf_fire="polyfire-gen2"


echo "Deploying forest lost hansen"
cd ~/earth-engine-on-bigquery/src/cloud-functions/hansen_forest

gcloud functions deploy ${cf_hansen} --entry-point get_forest_lost_year --runtime python39 --trigger-http --allow-unauthenticated --set-env-vars SERVICE_ACCOUNT=${ee_sa} --project ${project_id} --service-account ${ee_sa} --gen2 --region ${REGION} --run-service-account ${ee_sa}  --memory 32GB --timeout 300s 


echo "Deploying BANDS CF"

cd ~/earth-engine-on-bigquery/src/cloud-functions/bands

gcloud functions deploy ${cf_bands} --entry-point get_landsat_month --runtime python39 --trigger-http --allow-unauthenticated --set-env-vars SERVICE_ACCOUNT=${ee_sa} --project ${project_id} --service-account ${ee_sa} --gen2 --region ${REGION} --run-service-account ${ee_sa}  --memory 16GB --timeout 300s 


echo "Deploying NDVI CF"

cd ~/earth-engine-on-bigquery/src/cloud-functions/ndvi

gcloud functions deploy ${cf_ndvi} --entry-point get_ndvi_month --runtime python39 --trigger-http --allow-unauthenticated --set-env-vars SERVICE_ACCOUNT=${ee_sa} --project ${project_id} --service-account ${ee_sa} --gen2 --region ${REGION} --run-service-account ${ee_sa}  --memory 16GB --timeout 300s 

echo "Deploying Temperature CF"

cd ~/earth-engine-on-bigquery/src/cloud-functions/temperature

gcloud functions deploy ${cf_temp} --entry-point get_temp_month --runtime python39 --trigger-http --allow-unauthenticated --set-env-vars SERVICE_ACCOUNT=${ee_sa} --project ${project_id} --service-account ${ee_sa} --gen2 --region ${REGION} --run-service-account ${ee_sa}  --memory 16GB --timeout 300s 

echo "Deploying Dynamic World CF"

cd ~/earth-engine-on-bigquery/src/cloud-functions/dynamic_world

gcloud functions deploy ${cf_dynamic} --entry-point get_area --runtime python39 --trigger-http --allow-unauthenticated --set-env-vars SERVICE_ACCOUNT=${ee_sa} --project ${project_id} --service-account ${ee_sa} --gen2 --region ${REGION} --run-service-account ${ee_sa}  --memory 16GB --timeout 300s 

echo "Deploying Crop CF"

cd ~/earth-engine-on-bigquery/src/cloud-functions/crop

gcloud functions deploy ${cf_crop} --entry-point get_crop --runtime python39 --trigger-http --allow-unauthenticated --set-env-vars SERVICE_ACCOUNT=${ee_sa} --project ${project_id} --service-account ${ee_sa} --gen2 --region ${REGION} --run-service-account ${ee_sa}  --memory 16GB --timeout 300s 

echo "Deploying Fire CF"

cd ~/earth-engine-on-bigquery/src/cloud-functions/fire_state

gcloud functions deploy ${cf_fire} --entry-point get_fire_polygon --runtime python39 --trigger-http --allow-unauthenticated --set-env-vars SERVICE_ACCOUNT=${ee_sa} --project ${project_id} --service-account ${ee_sa} --gen2 --region ${REGION} --run-service-account ${ee_sa}  --memory 16GB --timeout 300s 

#Add Cloud Invoker function role

endpoint_hansen=$(gcloud functions describe ${cf_hansen} --region=${REGION} --gen2 --format=json | jq -r '.serviceConfig.uri')
endpoint_bands=$(gcloud functions describe ${cf_bands} --region=${REGION} --gen2 --format=json | jq -r '.serviceConfig.uri')
endpoint_ndvi=$(gcloud functions describe ${cf_ndvi} --region=${REGION} --gen2 --format=json | jq -r '.serviceConfig.uri')
endpoint_temp=$(gcloud functions describe ${cf_temp} --region=${REGION} --gen2 --format=json | jq -r '.serviceConfig.uri')
endpoint_dynamic=$(gcloud functions describe ${cf_dynamic} --region=${REGION} --gen2 --format=json | jq -r '.serviceConfig.uri')
endpoint_crop=$(gcloud functions describe ${cf_crop} --region=${REGION} --gen2 --format=json | jq -r '.serviceConfig.uri')
endpoint_fire=$(gcloud functions describe ${cf_fire} --region=${REGION} --gen2 --format=json | jq -r '.serviceConfig.uri')


bq mk -d udfs_gee

#forest lost hansen
# build_sql="CREATE OR REPLACE FUNCTION udfs_gee.get_forest_lost_year(aoi STRING, year int64) RETURNS STRING REMOTE WITH CONNECTION \`${project_id}.us.gcf-ee-conn\` OPTIONS ( endpoint = '${endpoint_hansen}')"

build_sql="CREATE OR REPLACE FUNCTION udfs_gee.get_forest_lost_year(aoi ANY )  RETURNS STRING REMOTE WITH CONNECTION \`${project_id}.us.gcf-ee-conn\` OPTIONS ( endpoint = '${endpoint_hansen}')"

bq query --use_legacy_sql=false ${build_sql}    

# bands
build_sql="CREATE OR REPLACE FUNCTION udfs_gee.get_poly_bands_month(aoi STRING, year int64, month int64) RETURNS STRING REMOTE WITH CONNECTION \`${project_id}.us.gcf-ee-conn\` OPTIONS ( endpoint = '${endpoint_bands}')"

bq query --use_legacy_sql=false ${build_sql}

# build_sql="CREATE OR REPLACE FUNCTION gee.get_ndvi_month(lon float64,lat float64, farm_name STRING, year int64, month int64) RETURNS STRING REMOTE WITH CONNECTION \`${project_id}.us.gcf-ee-conn\` OPTIONS ( endpoint = '${endpoint}')"
# ndvi
build_sql="CREATE OR REPLACE FUNCTION udfs_gee.get_poly_ndvi_month(aoi STRING, year int64, month int64) RETURNS STRING REMOTE WITH CONNECTION \`${project_id}.us.gcf-ee-conn\` OPTIONS ( endpoint = '${endpoint_ndvi}')"  

bq query --use_legacy_sql=false ${build_sql}

# ndvi
build_sql="CREATE OR REPLACE FUNCTION udfs_gee.get_poly_temp_month(aoi STRING, year int64, month int64) RETURNS STRING REMOTE WITH CONNECTION \`${project_id}.us.gcf-ee-conn\` OPTIONS ( endpoint = '${endpoint_temp}')"

bq query --use_legacy_sql=false ${build_sql}

#
build_sql="CREATE OR REPLACE FUNCTION udfs_gee.get_dw_area(poly_aoi STRING, start_dt STRING, end_dt STRING, area_typr int64) RETURNS STRING REMOTE WITH CONNECTION \`${project_id}.us.gcf-ee-conn\` OPTIONS ( endpoint = '${endpoint_dynamic}')"
   
bq query --use_legacy_sql=false ${build_sql}

#
build_sql="CREATE OR REPLACE FUNCTION udfs_gee.get_fire_polygon_state(start_dt STRING, end_dt STRING, state STRING) RETURNS STRING REMOTE WITH CONNECTION \`${project_id}.us.gcf-ee-conn\` OPTIONS ( endpoint = '${endpoint_fire}')"
   
bq query --use_legacy_sql=false ${build_sql}

#
build_sql="CREATE OR REPLACE FUNCTION udfs_gee.get_poly_crop(farm_aoi STRING, year int64) RETURNS STRING REMOTE WITH CONNECTION\`${project_id}.us.gcf-ee-conn\` OPTIONS ( endpoint = '${endpoint_crop}')"
    
bq query --use_legacy_sql=false ${build_sql}



#bq load --source_format=CSV --replace=true --skip_leading_rows=1  --schema=lon:FLOAT,lat:FLOAT,name:STRING ${project_id}:gee.land_coords  ./land_point.csv 

#bq query --use_legacy_sql=false 'SELECT gee.get_ndvi_month(lon,lat,name,2020,7) as ndvi_jul FROM `gee.land_coords` LIMIT 10'

cd ~/earth-engine-on-bigquery/src/data

bq load --source_format=CSV --replace=true --skip_leading_rows=1  --schema=aoi:STRING,name:STRING ${project_id}:udfs_gee.land_coords  ./land_dim.csv 

sleep 60

#bq query --use_legacy_sql=false 'SELECT gee.get_poly_ndvi_month(farm_aoi,2020,7) as ndvi_jul FROM `gee.land_coords` LIMIT 10'
bq query --use_legacy_sql=false 'SELECT * from `udfs_gee.land_coords` LIMIT 10'

##################################################
##
## Set these Variables
##
##################################################
# existing GCP user that will:
# create the project
# attach a billing id (needs to have permission)
# and provision resources

export USER_EMAIL=eng.pepj@gmail.com 

# project id for your NEW GCP project
export PROJECT_ID=para-practicar-gcp

export REGION=us-west1
# desired App Engine region name
# may be slightly different from GCP region above
# run "gcloud app regions list" from an existing project to confirm
# export APP_ENGINE_REGION=<insert desired app engine region name>
# export APP_ENGINE_REGION=us-central
##################################################
#Example
##################################################
# export USER_EMAIL=myuser@mydomain.com
# export PROJECT_ID=gee-on-gcp
# export BILLING_ACCOUNT_ID=123456-123456-123456
# export REGION=us-central1
# export APP_ENGINE_REGION=us-central
##################################################

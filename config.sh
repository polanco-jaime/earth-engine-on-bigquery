##################################################
##
## Set these Variables
##
##################################################
# existing GCP user that will:
# create the project
# attach a billing id (needs to have permission)
# and provision resources
export USER_EMAIL=jaime.polanco@servinformacion.com

# project id for your NEW GCP project
export PROJECT_ID=servi-ia-dev

# the new project will need to be tied to a billing account, uncomment the line below for Argolis users and update value
# export BILLING_ACCOUNT_ID=<insert billing account>

# desired GCP region for networking and compute resources, EDIT region below based on your need
export REGION=us-central1

# desired App Engine region name
# may be slightly different from GCP region above
# run "gcloud app regions list" from an existing project to confirm
# export APP_ENGINE_REGION=<insert desired app engine region name>
export APP_ENGINE_REGION=us-central
##################################################
#Example
##################################################
# export USER_EMAIL=myuser@mydomain.com
# export PROJECT_ID=gee-on-gcp
# export BILLING_ACCOUNT_ID=123456-123456-123456
# export REGION=us-central1
# export APP_ENGINE_REGION=us-central
##################################################

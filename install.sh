#!/bin/bash

echo 'Enabling necessary APIs'

project=$(grep -o '\"project_id\": \"[^\"]*' terraform.tfvars.json | grep -o '[^\"]*$')

gcloud services enable "compute.googleapis.com" --project=$project

export APIS="googleapis.com www.googleapis.com bigquery.googleapis.com bigquerystorage.googleapis.com iam.googleapis.com iamcredentials.googleapis.com pubsub.googleapis.com dataflow.googleapis.com storage.googleapis.com compute.googleapis.com run.googleapis.com apigateway.googleapis.com servicemanagement.googleapis.com servicecontrol.googleapis.com iap.googleapis.com sql-component.googleapis.com cloudapis.googleapis.com sqladmin.googleapis.com secretmanager.googleapis.com cloudresourcemanager.googleapis.com"
for i in $APIS
do
  echo "199.36.153.10 $i" >> /etc/hosts
done

gcloud beta services identity create --service=iap.googleapis.com --project=$project
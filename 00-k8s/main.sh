#!/bin/bash
# Creates a kubernetes cluster in Google Cloud, GKE (cloud.google.com).

echo "☁️  creating a gke cluster ..."

PROJECT_ID=$(gcloud config get-value project)

gcloud beta container \
--project "$PROJECT_ID" clusters create "fsk8s" \
--zone "us-central1-c" \
--no-enable-basic-auth \
--cluster-version "1.14.10-gke.36" \
--machine-type "n1-standard-4" \
--image-type "COS" \
--disk-type "pd-ssd" \
--disk-size "100" \
--metadata disable-legacy-endpoints=true \
--scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
--num-nodes "3" \
--enable-stackdriver-kubernetes \
--enable-ip-alias \
--network "projects/$PROJECT_ID/global/networks/default" \
--subnetwork "projects/$PROJECT_ID/regions/us-central1/subnetworks/default" \
--default-max-pods-per-node "110" \
--enable-autoscaling \
--min-nodes "0" \
--max-nodes "5" \
--no-enable-master-authorized-networks \
--addons HorizontalPodAutoscaling,HttpLoadBalancing \
--enable-autoupgrade \
--enable-autorepair \
--max-surge-upgrade 1 \
--max-unavailable-upgrade 0 \
--enable-vertical-pod-autoscaling \
--verbosity error

gcloud container clusters get-credentials fsk8s --zone="us-central1-c" --verbosity error

echo "done!"
echo

#!/bin/bash
# Creates a React SPA in the GKE cluster.
# This is an edited example of react-admin's tutorial example
# https://github.com/marmelab/react-admin/tree/master/examples/tutorial

echo "☁️  creating a frontend ui with react ..."

yarn build

PROJECT_ID=$(gcloud config get-value project)
CONTAINER_NAME="us.gcr.io/$PROJECT_ID/fsk8s-ui"

docker build -t $CONTAINER_NAME .
docker push $CONTAINER_NAME

CONTAINER_NAME_ESC=$(echo "$CONTAINER_NAME" | sed 's/\//\\\//g')

cat 00-deployment.yaml | sed "s/{{IMAGE}}/$CONTAINER_NAME_ESC/g" | kubectl create -f -
kubectl apply -f 01-service.yaml

echo "done!"
echo

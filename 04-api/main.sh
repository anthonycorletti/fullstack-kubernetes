#!/bin/bash
# Creates a FastAPI service in the GKE cluster.
#
# Connects to Cockroach DB for data servicing, Vault for secrets, and Pulsar
# for pubsub

echo "☁️  creating an api with fastapi ..."

echo " ... getting the pulsar proxy lb ip"

PULSAR_PROXY_IP=$(kubectl get svc -n pulsar -l component=proxy -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")

if [[ -z $PULSAR_PROXY_IP ]]; then
  PULSAR_PROXY_IP="pulsar-fsk8s-proxy"
fi

echo " ... placing proxy IP in vault"

kubectl exec -it vault-0 -- vault kv put secret/pulsar_proxy_ip "pulsar_proxy_ip=${PULSAR_PROXY_IP}"

echo " ... building container"

PROJECT_ID=$(gcloud config get-value project)
CONTAINER_NAME="us.gcr.io/$PROJECT_ID/fsk8s-api"
docker build -t $CONTAINER_NAME .
docker push $CONTAINER_NAME

CONTAINER_NAME_ESC=$(echo "$CONTAINER_NAME" | sed 's/\//\\\//g')

cat 00-deployment.yaml | sed "s/{{IMAGE}}/$CONTAINER_NAME_ESC/g" | kubectl create -f -

kubectl apply -f 01-service.yaml

echo "done!"
echo

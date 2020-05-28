#!/bin/bash
# Creating an ingress to tie it all together.

echo "☁️  applying an ingress to the ui and api ..."

helm install nginx stable/nginx-ingress --set controller.hostNetwork=true,controller.kind=DaemonSet
kubectl apply -f 00-ingress.yaml

echo "done!"
echo

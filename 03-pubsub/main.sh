#!/bin/bash
# Creates a publish, subscribe service with Apache Pulsar in GKE.
# https://pulsar.apache.org/docs/en/kubernetes-helm

echo "☁️  creating an apache pulsar service ..."


# The username pulsar and password pulsar are used for logging into Grafana
# dashboard and Pulsar Manager.
./scripts/pulsar/prepare_helm_release.sh \
-n pulsar \
-k pulsar-fsk8s \
--control-center-admin pulsar \
--control-center-password pulsar \
-c

helm install \
--values ./values-pulsar.yaml \
pulsar-fsk8s pulsar

echo "⏰ ... waiting for pulsar to come online ..."
while true; do
  if [[ $(kubectl get po -n pulsar | grep Running | grep "1/1" | grep pulsar-fsk8s-proxy | wc -l) -gt 0 ]]; then
    break
  else
    sleep 30
  fi
done
echo "🚀 ... all set! adding components ..."

# create a tenant
kubectl exec -n pulsar pulsar-fsk8s-toolset-0 -- bin/pulsar-admin tenants create default

# create a namespace
kubectl exec -n pulsar pulsar-fsk8s-toolset-0 -- bin/pulsar-admin namespaces create default/pulsar

# create a partitioned topic
kubectl exec -n pulsar pulsar-fsk8s-toolset-0 -- bin/pulsar-admin topics create-partitioned-topic default/pulsar/messages -p 4


echo "done!"
echo

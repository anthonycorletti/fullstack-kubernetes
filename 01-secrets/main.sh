#!/bin/bash
# Creates a Hashicorp Vault service in the GKE cluster.

echo "☁️  creating a vault service ..."

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault --set='server.dev.enabled=true'

echo "⏰ ... waiting for vault to come online ..."
while true; do
  if [[ $(kubectl get po | grep Running | grep vault | wc -l) -gt 0 ]]; then
    break
  else
    sleep 30
  fi
done
echo "🚀 ... all set! adding components ..."

# clearly, for dev purposes only
kubectl exec -it vault-0 -- vault kv put secret/crdb_url "crdb_url=postgresql://fsk8s:thesecret@crdb-cockroachdb-public:26257/fsk8s?sslmode=disable"

echo "done!"
echo

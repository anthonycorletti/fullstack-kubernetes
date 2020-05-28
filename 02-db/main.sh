#!/bin/bash
# Creates a CockroachDB cluster in the GKE cluster.

echo "☁️  creating a cockroachdb service ..."

ACCOUNT_EMAIL=$(gcloud config get-value account)

kubectl create clusterrolebinding crdb-cluster-admin-binding \
--clusterrole=cluster-admin \
--user=$ACCOUNT_EMAIL

helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update
helm install crdb --values db-values.yaml stable/cockroachdb

echo "⏰ ... waiting for crdb to come online ..."
while true; do
  if [[ $(kubectl get po | grep Running | grep crdb-cockroachdb- | wc -l) -gt 2 ]] && [[ $(kubectl get svc | grep crdb-cockroachdb-public | wc -l) -gt 0 ]]; then
    break
  else
    sleep 30
  fi
done
echo "🚀 ... all set! adding components ..."

# clearly, for dev purposes only
kubectl run cockroachdb -it \
--image=cockroachdb/cockroach:v20.1.0 \
--rm \
--restart=Never \
-- sql --insecure -e 'create user if not exists fsk8s' \
--host=crdb-cockroachdb-public

kubectl run cockroachdb -it \
--image=cockroachdb/cockroach:v20.1.0 \
--rm \
--restart=Never \
-- sql --insecure -e 'create database if not exists fsk8s' \
--host=crdb-cockroachdb-public

kubectl run cockroachdb -it \
--image=cockroachdb/cockroach:v20.1.0 \
--rm \
--restart=Never \
-- sql --insecure -e 'grant all on database fsk8s to fsk8s' \
--host=crdb-cockroachdb-public

kubectl run cockroachdb -it \
--image=cockroachdb/cockroach:v20.1.0 \
--rm \
--restart=Never \
-- sql -u fsk8s -d fsk8s --insecure -e 'create table if not exists items (
      id uuid not null default gen_random_uuid(),
      name string not null,
      description string null,
      created_at timestamp not null,
      updated_at timestamp not null,
      constraint "primary" primary key (name asc, id asc)
)' \
--host=crdb-cockroachdb-public

echo "done!"
echo

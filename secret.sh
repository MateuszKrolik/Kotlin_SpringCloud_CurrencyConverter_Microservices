#! /bin/zsh

set -a
source .env
set +a

kubectl create secret generic db-secret \
  --from-literal=DB_HOSTNAME=$DB_HOSTNAME \
  --from-literal=DB_PORT=$DB_PORT \
  --from-literal=DB_NAME=$DB_NAME \
  --from-literal=DB_USERNAME=$DB_USERNAME \
  --from-literal=DB_PASSWORD=$DB_PASSWORD \
  --namespace=services
#!/bin/bash

# Load environment variables from .env file
set -a
source .env
set +a

# Delete existing deployment and service if they exist
kubectl delete deployment currency-exchange --ignore-not-found=true
kubectl delete service currency-exchange --ignore-not-found=true

# Create deployment without environment variables
kubectl create deployment currency-exchange \
  --image=mateuszkrolik/microservices-currency-exchange-service:0.0.1-SNAPSHOT

# Set environment variables
kubectl set env deployment/currency-exchange \
  DB_HOSTNAME=$DB_HOSTNAME \
  DB_PORT=$DB_PORT \
  DB_NAME=$DB_NAME \
  DB_USERNAME=$DB_USERNAME \
  DB_PASSWORD=$DB_PASSWORD

kubectl expose deployment currency-exchange --type=LoadBalancer --port=8000

kubectl get svc

# minikube tunnel # load balancer

# curl http://34.38.248.160:8000/currency-exchange/from/USD/to/PLN

# k get deployment currency-exchange -o yaml >> deployment.yaml
# k get service currency-exchange -o yaml >> service.yaml

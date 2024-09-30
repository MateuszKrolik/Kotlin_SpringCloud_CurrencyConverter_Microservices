#!/bin/bash

# Delete existing deployment and service if they exist
kubectl delete deployment currency-conversion --ignore-not-found=true
kubectl delete service currency-conversion --ignore-not-found=true

kubectl create deployment currency-conversion --image=mateuszkrolik/microservices-currency-conversion-service:0.0.1-SNAPSHOT

# Set environment variables
# kubectl set env deployment/currency-conversion \
#  CURRENCY_EXCHANGE_SERVICE_HOST=currency-exchange

kubectl expose deployment currency-conversion --type=LoadBalancer --port=8100

kubectl get svc

# minikube tunnel # local load balancer

# curl  http://34.38.248.160:8100/currency-conversion-feign/from/USD/to/PLN/quantity/10

# k get deployment currency-conversion -o yaml >> deployment.yaml
# k get service currency-conversion -o yaml >> service.yaml

#!/bin/bash

# Delete existing deployment and service if they exist
kubectl delete deployment api-gateway --ignore-not-found=true
kubectl delete service api-gateway --ignore-not-found=true

kubectl create deployment api-gateway --image=mateuszkrolik/microservices-api-gateway:0.0.1-SNAPSHOT

kubectl expose deployment api-gateway --type=LoadBalancer --port=8765

kubectl get svc

# minikube tunnel # local load balancer

# curl  http://34.38.248.160:8765/currency-conversion-feign/from/USD/to/PLN/quantity/10

kubectl get deployment api-gateway -o yaml >> deployment.yaml
kubectl get service api-gateway -o yaml >> service.yaml

#!/bin/zsh

minikube start

addons=(
    "default-storageclass"
    "storage-provisioner"
    "ingress"
    "ingress-dns"
    "dashboard"
    "metrics-server"
)

for addon in "${addons[@]}"; do
    echo "Enabling addon: $addon"
    minikube addons enable "$addon"
done

echo "All specified addons have been enabled."
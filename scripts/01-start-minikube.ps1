$ErrorActionPreference = "Stop"

Write-Host "Starting Minikube using Docker driver..." -ForegroundColor Cyan

# Ensure we use a supported Kubernetes version
minikube config set kubernetes-version v1.30.0 | Out-Null

minikube start --driver=docker

Write-Host "Enabling ingress addon..." -ForegroundColor Cyan
minikube addons enable ingress

Write-Host "Minikube status:" -ForegroundColor Cyan
minikube status
kubectl cluster-info

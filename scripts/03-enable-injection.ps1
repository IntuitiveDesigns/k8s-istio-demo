$ErrorActionPreference = "Stop"

Write-Host "Labeling namespace 'demo' for Istio sidecar injection..." -ForegroundColor Cyan
kubectl label namespace demo istio-injection=enabled --overwrite

Write-Host "Restarting deployments to trigger sidecar injection..." -ForegroundColor Cyan
kubectl rollout restart deploy/frontend -n demo
kubectl rollout restart deploy/backend-v1 -n demo

Write-Host "Waiting for pods..." -ForegroundColor Cyan
kubectl get pods -n demo -w

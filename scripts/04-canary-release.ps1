$ErrorActionPreference = "Stop"

Write-Host "Deploying backend v2..." -ForegroundColor Cyan
kubectl apply -f k8s/backend-v2.yaml

Write-Host "Current backend pods:" -ForegroundColor Cyan
kubectl get pods -n demo -l app=backend

$ErrorActionPreference = "Stop"

Write-Host "Applying Gateway + DestinationRule..." -ForegroundColor Cyan
kubectl apply -f istio/gateway.yaml
kubectl apply -f istio/destination-rule.yaml

Write-Host "Applying 90/10 traffic split (v1/v2)..." -ForegroundColor Cyan
kubectl apply -f istio/virtual-service-90-10.yaml

Write-Host "Done. Now refresh the frontend and observe v1/v2 responses." -ForegroundColor Green

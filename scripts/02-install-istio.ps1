$ErrorActionPreference = "Stop"

# Install Istio into the cluster using the demo profile.
# Assumes istioctl is installed and available in PATH.

Write-Host "Installing Istio (demo profile)..." -ForegroundColor Cyan
istioctl install --set profile=demo -y

Write-Host "Verifying Istio system pods..." -ForegroundColor Cyan
kubectl get pods -n istio-system

Write-Host "Istio install complete." -ForegroundColor Green

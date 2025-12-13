$ErrorActionPreference = "Stop"

function Assert-CommandExists($name) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        throw "Required command not found in PATH: $name"
    }
}

Write-Host "=== Phase 3 Bootstrap: mTLS + AuthorizationPolicy ===" -ForegroundColor Cyan

Assert-CommandExists "minikube"
Assert-CommandExists "kubectl"
Assert-CommandExists "istioctl"
Assert-CommandExists "docker"

# Phase 3 builds on Phase 2 operationally, but remains independently runnable
Write-Host "Bootstrapping Phase 2 first (baseline + Istio + canary)..." -ForegroundColor Cyan
& "$PSScriptRoot\phase2-bootstrap.ps1"

Write-Host "Applying PeerAuthentication (mTLS) and AuthorizationPolicy..." -ForegroundColor Cyan
kubectl apply -f "istio/peer-auth.yaml"
kubectl apply -f "istio/auth-policy.yaml"

Write-Host "Phase 3 applied." -ForegroundColor Green
Write-Host "Validation:" -ForegroundColor Green
Write-Host "  kubectl get peerauthentication,authorizationpolicy -n demo" -ForegroundColor Green
Write-Host "Open via ingress (if not already):" -ForegroundColor Green
Write-Host "  minikube service istio-ingressgateway -n istio-system" -ForegroundColor Green

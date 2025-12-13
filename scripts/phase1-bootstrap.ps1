$ErrorActionPreference = "Stop"

function Assert-CommandExists($name) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        throw "Required command not found in PATH: $name"
    }
}

function Ensure-MinikubeContext {
    # Make sure kubectl is pointed at minikube (common failure after resets)
    try { minikube update-context | Out-Null } catch {}
    try { kubectl config use-context minikube | Out-Null } catch {}
}

Write-Host "=== Phase 1 Bootstrap: Kubernetes baseline (no Istio) ===" -ForegroundColor Cyan

Assert-CommandExists "minikube"
Assert-CommandExists "kubectl"

# Start minikube using your existing script (keeps repo behavior consistent)
Write-Host "Starting Minikube..." -ForegroundColor Cyan
& "$PSScriptRoot\01-start-minikube.ps1"

Ensure-MinikubeContext

Write-Host "Deploying Kubernetes baseline resources..." -ForegroundColor Cyan
kubectl apply -f "k8s/namespace.yaml"
kubectl apply -f "k8s/backend-v1.yaml"
kubectl apply -f "k8s/frontend.yaml"
kubectl apply -f "k8s/service.yaml"

Write-Host "Waiting for demo pods to become Ready..." -ForegroundColor Cyan
kubectl wait --for=condition=Ready pods --all -n demo --timeout=240s

Write-Host "Phase 1 is ready." -ForegroundColor Green
Write-Host "Open the app with:" -ForegroundColor Green
Write-Host "  minikube service frontend -n demo" -ForegroundColor Green

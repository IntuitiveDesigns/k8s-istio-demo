$ErrorActionPreference = "Stop"

function Assert-CommandExists($name) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        throw "Required command not found in PATH: $name"
    }
}

function Ensure-MinikubeContext {
    try { minikube update-context | Out-Null } catch {}
    try { kubectl config use-context minikube | Out-Null } catch {}
}

function Get-IstioTag {
    # Allow override: $env:ISTIO_TAG="1.28.0"
    if ($env:ISTIO_TAG) { return $env:ISTIO_TAG }

    # Best-effort parse from istioctl version output; fallback to 1.28.0
    try {
        $out = & istioctl version --remote=false 2>$null
        $m = [regex]::Match($out, 'client version:\s*([0-9]+\.[0-9]+\.[0-9]+)')
        if ($m.Success) { return $m.Groups[1].Value }
    } catch {}
    return "1.28.0"
}

function Fix-IstioImagePullIfNeeded($tag) {
    # If istiod is in ErrImagePull/ImagePullBackOff due to DNS, pre-pull and load images into minikube
    try {
        $reason = kubectl get pod -n istio-system -l app=istiod -o jsonpath="{.items[0].status.containerStatuses[0].state.waiting.reason}" 2>$null
        if ($reason -eq "ErrImagePull" -or $reason -eq "ImagePullBackOff") {
            Write-Host "Istiod image pull failed ($reason). Pulling Istio images on host and loading into Minikube..." -ForegroundColor Yellow

            docker pull "istio/pilot:$tag"
            docker pull "istio/proxyv2:$tag"

            minikube image load "istio/pilot:$tag"
            minikube image load "istio/proxyv2:$tag"

            kubectl delete pod -n istio-system -l app=istiod | Out-Null
        }
    } catch {
        # Ignore if istiod not yet created
    }
}

Write-Host "=== Phase 2 Bootstrap: Istio + Canary (v1/v2) ===" -ForegroundColor Cyan

Assert-CommandExists "minikube"
Assert-CommandExists "kubectl"
Assert-CommandExists "istioctl"
Assert-CommandExists "docker"

# Start cluster
Write-Host "Starting Minikube..." -ForegroundColor Cyan
& "$PSScriptRoot\01-start-minikube.ps1"
Ensure-MinikubeContext

# Baseline Kubernetes workloads (Phase 1 baseline)
Write-Host "Deploying Kubernetes baseline resources..." -ForegroundColor Cyan
kubectl apply -f "k8s/namespace.yaml"
kubectl apply -f "k8s/backend-v1.yaml"
kubectl apply -f "k8s/frontend.yaml"
kubectl apply -f "k8s/service.yaml"

# Install Istio
$tag = Get-IstioTag
Write-Host "Installing Istio (demo profile), tag $tag..." -ForegroundColor Cyan
istioctl install --set profile=demo -y

Start-Sleep -Seconds 5
Fix-IstioImagePullIfNeeded $tag

Write-Host "Waiting for Istio control plane..." -ForegroundColor Cyan
kubectl wait --for=condition=Ready pods --all -n istio-system --timeout=300s

# Enable injection and restart workloads
Write-Host "Enabling sidecar injection for namespace 'demo'..." -ForegroundColor Cyan
kubectl label namespace demo istio-injection=enabled --overwrite

Write-Host "Restarting workloads to inject sidecars..." -ForegroundColor Cyan
kubectl rollout restart deploy/backend-v1 -n demo
kubectl rollout restart deploy/frontend -n demo

Write-Host "Waiting for demo pods (with sidecars)..." -ForegroundColor Cyan
kubectl wait --for=condition=Ready pods --all -n demo --timeout=300s

# Deploy v2
Write-Host "Deploying backend v2..." -ForegroundColor Cyan
kubectl apply -f "k8s/backend-v2.yaml"
kubectl wait --for=condition=Ready pods -l app=backend -n demo --timeout=300s

# Apply Istio routing (Gateway + ingress + canary)
Write-Host "Applying Istio routing (Gateway, ingress, subsets, 90/10 canary)..." -ForegroundColor Cyan
kubectl apply -f "istio/gateway.yaml"
kubectl apply -f "istio/frontend-ingress-vs.yaml"
kubectl apply -f "istio/destination-rule.yaml"
kubectl apply -f "istio/virtual-service-90-10.yaml"

Write-Host "Phase 2 is ready." -ForegroundColor Green
Write-Host "Open the app through Istio IngressGateway with:" -ForegroundColor Green
Write-Host "  minikube service istio-ingressgateway -n istio-system" -ForegroundColor Green
Write-Host "Then refresh repeatedly to observe v1/v2 responses." -ForegroundColor Green

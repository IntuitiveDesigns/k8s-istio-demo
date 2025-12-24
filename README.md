# Demystifying Kubernetes & Istio — Phase 1 Demo
[![Architected by Steven Lopez](https://img.shields.io/badge/Architected%20by-Steven%20Lopez-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/steve-lopez-b9941/)

---

This repository contains a **hands-on Kubernetes demo** designed to reinforce an accelerated learning presentation on Kubernetes and Istio.

The goal is not to teach YAML in isolation, but to help engineers and architects **build a correct mental model** of how Kubernetes behaves before introducing service mesh complexity.

This demo was originally inspired by real-world enablement work with enterprise customers, where understanding *why* Kubernetes behaves the way it does is more valuable than memorizing resources.

---

## Phase 1 Scope (Kubernetes Only)

Phase 1 intentionally excludes Istio.

The objective is to demonstrate what **Kubernetes alone** provides:

- Declarative application deployment
- Pod scheduling and lifecycle management
- Service discovery via DNS
- Load balancing across replicas
- Namespace isolation
- Desired-state reconciliation

Once these fundamentals are internalized, Istio becomes additive rather than confusing.

---

## Architecture Overview

```
Browser
  |
  v
Frontend Service (NodePort)
  |
  v
Backend Service (ClusterIP)
  |
  v
Backend Pods (v1 replicas)
```

---

## Repository Structure

```
k8s-istio-demo/
├── README.md
├── prerequisites.md
├── scripts/
│   └── 01-start-minikube.ps1
├── k8s/
│   ├── namespace.yaml
│   ├── backend-v1.yaml
│   ├── frontend.yaml
│   └── service.yaml
├── app/
│   ├── backend/
│   └── frontend/
├── diagrams/
├── terraform/
└── ansible/
```

---

## Running Phase 1

### Start Minikube

```powershell
.\scripts\01-start-minikube.ps1
```

### Deploy Kubernetes resources

```powershell
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/backend-v1.yaml
kubectl apply -f k8s/frontend.yaml
kubectl apply -f k8s/service.yaml
```

### Access the application

```powershell
minikube service frontend -n demo
```

Expected output:

```
Frontend received -> Backend v1 responding from backend-v1-xxxxx
```

---

## What’s Next

Phase 2 introduces Istio:

- Sidecar injection
- Canary routing
- Traffic shaping
- Security and policy enforcement

---

# Kubernetes + Istio Canary Demo (Phase 2)

This repository demonstrates **how Istio adds traffic management and progressive delivery on top of Kubernetes** using a simple frontend/backend application.

Phase 2 focuses on:

- Istio installation
- Sidecar injection
- Gateway-based ingress
- Canary traffic splitting between backend v1 and v2

> Phase 2 is **fully independent**. You do **not** need to run Phase 1 first.

---

## Prerequisites

Ensure the following are installed and available in your PATH:

- Docker Desktop (running, Linux containers)
- Minikube
- kubectl
- istioctl

Verify:

```powershell
docker version
minikube version
kubectl version --client
istioctl version
```

---

## Phase 2 Execution Model

You will use **two PowerShell windows**:

### PowerShell Window #1 – Cluster + App Lifecycle

Used to:

- Start Minikube
- Install Istio
- Deploy workloads
- Apply traffic policies

### PowerShell Window #2 – Traffic Testing

Used to:

- Generate HTTP requests
- Observe traffic distribution changes in real time

This separation avoids interrupting Minikube tunnels and keeps testing clean.

---

## Step 1 – Run Phase 2 Bootstrap (Window #1)

From the repository root:

```powershell
.\scripts\phase2-bootstrap.ps1
```

This script automatically:

1. Starts Minikube
2. Deploys the baseline app (frontend + backend v1)
3. Installs Istio (demo profile)
4. Enables sidecar injection
5. Redeploys workloads with Envoy
6. Deploys backend v2
7. Applies Istio Gateway and VirtualServices
8. Configures a 90/10 canary split (v1/v2)

Wait until the script completes successfully.

---

## Step 2 – Open Istio Ingress (Window #1)

Still in **Window #1**, run:

```powershell
minikube service istio-ingressgateway -n istio-system
```

Important notes:

- Keep this window **open** (required for Minikube tunnel on Windows)
- Multiple localhost URLs may appear – any `http://127.0.0.1:<port>` is valid
- This is the **only correct entry point** for Phase 2

---

## Step 3 – Get the Ingress URL (Window #2)

Open **a new PowerShell window**.

Run:

```powershell
$url = (minikube service istio-ingressgateway -n istio-system --url | Select-Object -First 1)
$url
```

This stores the Istio ingress URL for testing.

---

## Step 4 – Test Initial Canary (90/10)

In **Window #2**:

```powershell
1..20 | % {
  (Invoke-WebRequest -UseBasicParsing $url).Content.Trim()
}
```

Expected:

- Mostly `Backend v1 responding`
- Occasional `Backend v2 responding`

This confirms Istio is actively managing traffic.

---

## Step 5 – Change Traffic Distribution (Live)

### Switch to 50/50

**Window #1**:

```powershell
kubectl apply -f istio/virtual-service-50-50.yaml
```

**Window #2**:

```powershell
1..20 | % {
  (Invoke-WebRequest -UseBasicParsing $url).Content.Trim()
}
```

Expected:

- Roughly equal v1 and v2 responses

---

### Switch to 100% v2

**Window #1**:

```powershell
kubectl apply -f istio/virtual-service-100-0.yaml
```

**Window #2**:

```powershell
1..10 | % {
  (Invoke-WebRequest -UseBasicParsing $url).Content.Trim()
}
```

Expected:

- Only `Backend v2 responding`
- No redeploys
- No restarts

---

## Validation Commands (Optional)

```powershell
kubectl get pods -n demo
kubectl get gateway,virtualservice,destinationrule -n demo
```

Expected:

- Pods show `READY 2/2` (app + Envoy)
- Istio resources present and configured

---

## What This Demonstrates

- Kubernetes handles deployment and service discovery
- Istio adds declarative traffic control
- Canary releases are:
  - Immediate
  - Reversible
  - Code-free
- Traffic behavior changes without touching workloads

This mirrors how enterprises safely roll out changes in production.

---

## Cleanup

```powershell
minikube delete --all --purge
```

---

## Next Steps

- Phase 3: mTLS and AuthorizationPolicy
- Observability with Kiali and Prometheus
- Failure injection and retries
- Terraform and Ansible automation

---

**Author note:**  
This demo was designed as an accelerated learning lab for engineers and architects to quickly internalize how Kubernetes and Istio work together in real-world environments.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Author:** Steven Lopez

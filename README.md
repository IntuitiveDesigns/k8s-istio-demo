# Demystifying Kubernetes & Istio — Phase 1 Demo

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

## License

MIT

# Prerequisites

This demo is designed to run locally on **Windows** using **Minikube + Docker Desktop**.

The instructions and scripts assume a local Kubernetes cluster running inside Docker.

---

## Required Software

### Docker Desktop (REQUIRED)

<https://www.docker.com/products/docker-desktop/>

Requirements:

- Docker Desktop **must be running**
- Use **Linux containers** (not Windows containers)
- WSL 2 backend recommended

Verify:

```powershell
docker version
```

If this fails, the demo will not work.

---

### kubectl (REQUIRED)

Verify:

```powershell
kubectl version --client
```

Install:
<https://kubernetes.io/docs/tasks/tools/>

---

### Minikube (REQUIRED)

Verify:

```powershell
minikube version
```

Install:
<https://minikube.sigs.k8s.io/docs/start/>

This demo uses:

- Docker driver
- Kubernetes v1.30.0 (configured automatically by scripts)

---

### istioctl (REQUIRED for Phase 2+)

Verify:

```powershell
istioctl version
```

Install:
<https://istio.io/latest/docs/setup/getting-started/#download>

The Istio version should be compatible with Kubernetes v1.30+.

---

### PowerShell (REQUIRED)

PowerShell is required to run the provided `.ps1` scripts.

---

## Minikube Configuration Notes

- Driver: Docker
- Kubernetes version: v1.30.0 (set automatically by scripts)

To fully reset the environment:

```powershell
minikube delete --all --purge
```

---

## kubectl Context Notes (Windows)

On Windows, `kubectl` may lose its context after resets or restarts.

If you see errors like:

```
Unable to connect to the server: dial tcp 127.0.0.1:8080
```

Fix with:

```powershell
minikube update-context
kubectl config use-context minikube
```

(The bootstrap scripts do this automatically.)

---

## Known Windows Caveats

- Keep the terminal open when running:

  ```powershell
  minikube service <service-name>
  ```

  This is required for Minikube tunnels on Windows.

- VPNs may interfere with Docker networking and image pulls.
  Disable VPNs if you encounter networking issues.

---

## Optional / Future Tools (Later Phases)

These tools are **not required** for Phase 1 or Phase 2:

- Terraform (infrastructure automation)
- Ansible (configuration automation)
- Helm (optional packaging)

They will be introduced incrementally in later phases.

---

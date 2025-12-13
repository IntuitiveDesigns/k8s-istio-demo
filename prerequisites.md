# Prerequisites

This demo is designed to run locally on **Windows** using Minikube and Docker.

---

## Required Software

### Docker Desktop
<https://www.docker.com/products/docker-desktop/>

### kubectl

Verify:

```powershell
kubectl version --client
```

Install:
<https://kubernetes.io/docs/tasks/tools/>

### Minikube

Verify:

```powershell
minikube version
```

Install:
<https://minikube.sigs.k8s.io/docs/start/>

### PowerShell

Required for scripts.

---

## Minikube Configuration Notes

- Docker driver
- Kubernetes v1.30.0

Reset if needed:

```powershell
minikube delete --all --purge
```

---

## Known Windows Caveats

- Keep terminal open when using `minikube service`
- VPNs may interfere with networking

---

## Optional Tools (Future Phases)

- Istio
- Terraform
- Ansible
- Helm

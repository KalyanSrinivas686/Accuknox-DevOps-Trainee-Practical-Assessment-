# Wisecow - Kubernetes Deployment & CI/CD

## Goal
Containerize and deploy the Wisecow application to Kubernetes with TLS, automated CI/CD via GitHub Actions, and security hardening (KubeArmor).

## Quick steps (local dev - Minikube/Kind)
1. Build image locally:
   - `docker build -t ghcr.io/<org>/wisecow:local .`
2. Push to registry (or use kind load docker-image)
3. Create namespace:
   - `kubectl apply -f k8s/namespace.yaml`
4. Create TLS secret (self-signed for local):
   - generate certs and `kubectl create secret tls wisecow-tls --key=wisecow.key --cert=wisecow.crt -n wisecow`
5. Apply manifests:
   - `kubectl apply -f k8s/service.yaml -n wisecow`
   - `kubectl apply -f k8s/deployment.yaml -n wisecow`
   - `kubectl apply -f k8s/ingress.yaml -n wisecow`

## CI/CD
- Workflow: `.github/workflows/ci-cd.yml`
- Required secrets:
  - `CR_PAT` (GHCR token or DockerHub token)
  - `IMAGE_REGISTRY` (e.g., ghcr.io)
  - `IMAGE_NAME` (e.g., ghcr.io/<org>/wisecow)
  - `KUBECONFIG_DATA` (base64 of kubeconfig)

## Monitoring & Tools
- `scripts/system_health_monitor.sh`
- `scripts/app_health_check.sh`

## KubeArmor
- `kubearmor/zerotrust-policy.yaml`

# ⚙️ Terraform + Helmfile Example Deployment

This repository provides an example setup for deploying infrastructure using **Terraform** and managing Kubernetes services using **Helmfile**. It includes modular infra, example app charts, and secret management via External Secrets.

---

## 📁 Project Structure

```
.
├── terraform/              # Terraform modules and environments
│   ├── 00-modules/         # Custom + official Terraform modules
│   ├── 01-scripts/
│   └── 02-services/
├── charts/                 # Helm charts for app/consumer/etc.
│   ├── app/
│   └── consumer/
├── environments/           # Helmfile environment values
│   ├── dev.yaml
│   └── prod.yaml
├── helmfile.yaml           # Main Helmfile config
└── scripts/
    └── deploy.sh           # Helmfile apply script with env support
```

---

## 🚀 Getting Started

### 🔧 Requirements

- Terraform ≥ 1.0
- Helm ≥ 3.12
- Helmfile ≥ 0.155
- kubectl, awscli
- Vault + External Secrets Operator (optional for secrets)

---

## ☁️ Terraform Usage

This project uses a mix of official modules (like VPC, EKS) and custom ones.

### Initialize and Apply:

```bash
cd terraform/
./scripts/example-terraform-apply.sh dev module.vpc 02-service/kubernetes/development
```

### Apply Specific Module:

```bash
terraform apply -target=module.eks
```

---

## 🎯 Helmfile Usage

Helmfile is used to declaratively manage all Kubernetes services.

### Deploy All Releases:

```bash
cd helm-charts
./scripts/helm-apply.shh dev
```

### Deploy a Specific Release:

```bash
cd helm-charts
./scripts/helm-apply.sh dev app
./scripts/helm-apply.sh prod redis
```

### Show Diff Before Apply:

```bash
helmfile -e dev diff
```

---

## 🧩 Charts Overview

| Chart      | Description                                |
|------------|--------------------------------------------|
| `app`      | Web app with ingress, autoscaling, secrets |
| `consumer` | Background worker with config + secrets    |
| `redis`    | Redis via Bitnami Helm chart               |

Charts support shared `global:` values per environment.

---

## 🔐 Secret Management

Secrets are managed via [External Secrets Operator](https://external-secrets.io/).

Example ExternalSecret:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: redis-secret
spec:
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
  target:
    name: redis-credentials
  data:
    - secretKey: REDIS_PASSWORD
      remoteRef:
        key: kv/data/shared/redis
        property: redis_password
```

---

## 🛠 Script: `helmfile-apply.sh`

A helper script to deploy via Helmfile:

```bash
cd helm-charts
./scripts/helmfile-apply.sh <env> [release-name]

# Examples:
./scripts/helmfile-apply.sh dev
./scripts/helmfile-apply.sh dev app
./scripts/helmfile-apply.sh prod redis

# Show help:
./scripts/helmfile-apply.sh --help
```

For better automation, consider implementing a CI/CD pipeline (e.g., GitHub Actions, GitLab CI) or using a dedicated Terraform automation tool like Atlantis. These tools help enforce Terraform workflows (plan, review, apply) automatically on pull requests, improve collaboration, and reduce manual errors in infrastructure deployments.

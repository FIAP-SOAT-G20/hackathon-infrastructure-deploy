# Hackathon Infrastructure Deploy

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.24+-blue.svg)](https://kubernetes.io/)
[![AWS EKS](https://img.shields.io/badge/AWS-EKS-orange.svg)](https://aws.amazon.com/eks/)

> Kubernetes infrastructure deployment for FIAP PostTech 10SOAT 2024 Hackathon project.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This repository contains the Kubernetes infrastructure manifests for deploying the Hackathon Video Service application on AWS EKS. The infrastructure is designed with scalability, reliability, and observability in mind.

### Features

- 🚀 **Scalable**: Horizontal Pod Autoscaling (HPA) configured
- 🔒 **Secure**: Secret management and secure configuration
- 📊 **Observable**: Metrics collection and monitoring
- 🌐 **Load Balanced**: Ingress controller with SSL termination
- 🔄 **High Availability**: Multi-replica deployments

## 🏗️ Architecture

The application follows a microservices architecture deployed on Kubernetes:

```
┌─────────────────┐    ┌─────────────────┐
│   Ingress       │    │   Video Service │
│   Controller    │───▶│   API           │
└─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Video Service │
                       │   Worker        │
                       └─────────────────┘
```

### Components

- **Video Service API**: REST API for video processing operations
- **Video Service Worker**: Background worker for async video processing
- **Ingress**: Load balancer and SSL termination
- **ConfigMaps**: Application configuration management
- **Secrets**: Secure credential storage
- **HPA**: Automatic scaling based on resource utilization

## ✅ Prerequisites

Before deploying, ensure you have:

- [kubectl](https://kubernetes.io/docs/tasks/tools/) (v1.24+)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate permissions
- Access to AWS EKS cluster: `fiap-10soat-g22-k8s-cluster`
- [Make](https://www.gnu.org/software/make/) for using the Makefile commands

### Required AWS Permissions

Your AWS profile needs the following permissions:
- `eks:DescribeCluster`
- `eks:UpdateKubeconfig`

## 🚀 Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/FIAP-SOAT-G20/hackathon-infrastructure-deploy.git
   cd hackathon-infrastructure-deploy
   ```

2. **Authenticate with AWS EKS**
   ```bash
   make aws-eks-auth
   ```

3. **Deploy the infrastructure**
   ```bash
   make k8s-apply
   ```

4. **Verify deployment**
   ```bash
   make k8s-status
   ```

5. **View application logs**
   ```bash
   make k8s-logs
   ```

## 📁 Project Structure

```
.
├── README.md                           # This file
├── LICENSE                            # Project license
├── Makefile                           # Automation commands
├── namespace.yaml                     # Kubernetes namespace
├── configs/                           # Configuration files
│   ├── video-service-config.yaml     # Application configuration
│   ├── secrets.yaml                  # Encrypted secrets
│   └── metrics.yaml                  # Monitoring configuration
├── services/                          # Service deployments
│   └── video-service/
│       ├── api/                       # API service manifests
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   └── hpa.yaml
│       └── worker/                    # Worker service manifests
│           ├── deployment.yaml
│           └── hpa.yaml
├── ingress/                           # Ingress configuration
│   └── ingress.yaml
└── docs/                              # Documentation assets
    ├── k8s.jpg                        # Architecture diagram
    ├── k8s.drawio                     # Editable diagram
    └── gopher.png                     # Project mascot
```

## ⚙️ Configuration

### Environment Variables

The application uses ConfigMaps and Secrets for configuration:

- **ConfigMap**: `hackathon-video-service-config` - Non-sensitive configuration
- **Secret**: `hackathon-secrets` - Sensitive data like API keys, database credentials

### Resource Limits

| Component | CPU Request | Memory Request | CPU Limit | Memory Limit |
|-----------|-------------|----------------|-----------|--------------|
| Video API | 100m        | 128Mi          | 500m      | 512Mi        |
| Worker    | 100m        | 128Mi          | 500m      | 512Mi        |

### Horizontal Pod Autoscaler

- **Metrics**: CPU utilization
- **Target**: 70% CPU utilization
- **Min Replicas**: 1
- **Max Replicas**: 5

## 🚀 Deployment

### Available Make Commands

| Command | Description |
|---------|-------------|
| `make help` | Show all available commands |
| `make aws-eks-auth` | Authenticate with AWS EKS cluster |
| `make k8s-apply` | Deploy all Kubernetes resources |
| `make k8s-delete` | Remove all Kubernetes resources |
| `make k8s-status` | Show status of all resources |
| `make k8s-logs` | View application logs |
| `make k8s-set-namespace` | Set kubectl context to hackathon namespace |

### Manual Deployment

If you prefer to deploy manually:

```bash
# Apply in order
kubectl apply -f namespace.yaml
kubectl apply -f configs/
kubectl apply -f services/video-service/api/
kubectl apply -f services/video-service/worker/
kubectl apply -f ingress/
```

### Rollback

To rollback a deployment:

```bash
kubectl rollout undo deployment/hackathon-video-service -n hackathon
kubectl rollout undo deployment/hackathon-video-worker -n hackathon
```

## 📊 Monitoring

### Health Checks

The application includes:
- **Liveness Probes**: Restart containers if unhealthy
- **Readiness Probes**: Route traffic only to ready pods

### Metrics Collection

Metrics are collected and available for monitoring:
- Application metrics via `/metrics` endpoint
- Kubernetes metrics via metrics-server
- Custom metrics for autoscaling

### Viewing Logs

```bash
# API logs
kubectl logs -f deployment/hackathon-video-service -n hackathon

# Worker logs  
kubectl logs -f deployment/hackathon-video-worker -n hackathon

# All pods logs
make k8s-logs
```

## 🔧 Troubleshooting

### Common Issues

**Pods stuck in Pending state**
```bash
kubectl describe pod <pod-name> -n hackathon
```

**ImagePullBackOff errors**
- Verify image name and tag in deployment.yaml
- Check image repository permissions

**ConfigMap/Secret not found**
```bash
kubectl get configmaps -n hackathon
kubectl get secrets -n hackathon
```

**HPA not scaling**
```bash
kubectl describe hpa -n hackathon
kubectl top pods -n hackathon
```

### Debug Commands

```bash
# Check cluster connectivity
kubectl cluster-info

# View all resources
kubectl get all -n hackathon

# Check events
kubectl get events -n hackathon --sort-by='.lastTimestamp'

# Port forward for local testing
kubectl port-forward svc/hackathon-video-service 8080:80 -n hackathon
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Guidelines

- Follow Kubernetes best practices
- Update documentation for any changes
- Test deployments before submitting PR
- Use conventional commit messages

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**FIAP PostTech 10SOAT 2025 - Group 21**

.DEFAULT_GOAL := help

# Variables
NAMESPACE=hackathon

# Looks at comments using ## on targets and uses them to produce a help output.
.PHONY: help
help: ALIGN=22
help: ## Print this message
	@echo "Usage: make <command>"
	@awk -F '::? .*## ' -- "/^[^':]+::? .*## /"' { printf "  make '$$(tput bold)'%-$(ALIGN)s'$$(tput sgr0)' - %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: aws-eks-auth
aws-eks-auth: ## Authenticate with AWS EKS with the 10soat aws profile
	@echo  "🟢 Authenticating with AWS EKS..."
	aws eks update-kubeconfig --name hackathon-eks-cluster --profile 10soat

.PHONY: k8s-apply
k8s-apply: ## Apply Kubernetes manifests
	@echo  "🟢 Applying Kubernetes manifests..."
	kubectl apply -f namespace.yaml
	kubectl apply -f configs/video-service-config.yaml
	kubectl apply -f configs/secrets.yaml
	kubectl apply -f configs/metrics.yaml
	kubectl apply -f services/video-service/api/
	kubectl apply -f services/video-service/worker/
	kubectl apply -f ingress/ingress.yaml

.PHONY: k8s-delete
k8s-delete: ## Delete Kubernetes resources
	@echo  "🔴 Deleting Kubernetes resources..."
	kubectl delete -f ingress/ingress.yaml
	kubectl delete -f services/video-service/worker/
	kubectl delete -f services/video-service/api/
	kubectl delete -f configs/metrics.yaml
	kubectl delete -f configs/secrets.yaml
	kubectl delete -f configs/video-service-config.yaml
	kubectl delete -f namespace.yaml

.PHONY: k8s-logs
k8s-logs: ## Show application logs
	@echo  "🟢 Showing application logs..."
	@echo  "🟢 Showing application logs for hackathon-video-service..."
	kubectl logs -f -l app=hackathon-video-service -n $(NAMESPACE)
	@echo  "🟢 Showing application logs for hackathon-video-consumer-worker..."
	kubectl logs -f -l app=hackathon-video-consumer-worker -n $(NAMESPACE)

.PHONY: k8s-status
k8s-status: ## Show Kubernetes resources status
	@echo  "🟢 Showing Kubernetes resources status..."
	@echo "=== Pods ==="
	kubectl get pods -n $(NAMESPACE)
	@echo "\n=== Services ==="
	kubectl get svc -n $(NAMESPACE)
	@echo "\n=== Deployments ==="
	kubectl get deploy -n $(NAMESPACE)
	@echo "\n=== HPA ==="
	kubectl get hpa -n $(NAMESPACE)
	@echo "\n=== Ingress ==="
	kubectl get ingress -n $(NAMESPACE)
	@echo "\n=== ConfigMaps ==="
	kubectl get configmaps -n $(NAMESPACE)
	@echo "\n=== Secrets ==="
	kubectl get secrets -n $(NAMESPACE)

k8s-set-namespace: ## Set Kubernetes namespace
	@echo  "🟢 Setting Kubernetes namespace..."
	kubectl config set-context --current --namespace=$(NAMESPACE)


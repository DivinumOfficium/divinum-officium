#!/bin/bash

# Divinum Officium - Quick Deployment Script
# This script helps you quickly deploy the application using ArgoCD

set -e

echo "🚀 Divinum Officium Kubernetes Deployment"
echo "=========================================="
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    echo "Please ensure kubectl is configured correctly"
    exit 1
fi

echo "✅ Connected to Kubernetes cluster"
echo ""

# Check if ArgoCD is installed
if ! kubectl get namespace argocd &> /dev/null; then
    echo "❌ ArgoCD namespace not found"
    echo "Please install ArgoCD first: https://argo-cd.readthedocs.io/en/stable/getting_started/"
    exit 1
fi

echo "✅ ArgoCD is installed"
echo ""

# Ask about manifests in GitHub
echo "📋 Before deploying, ensure you have:"
echo "   1. Created a 'k8s' directory in your GitHub repository"
echo "   2. Added these manifests to the k8s directory:"
echo "      - deployment.yaml"
echo "      - service.yaml"
echo "      - ingress.yaml"
echo "      - kustomization.yaml"
echo "   3. Committed and pushed to the master branch"
echo ""

read -p "Have you completed these steps? (yes/no): " answer
if [[ "$answer" != "yes" ]]; then
    echo ""
    echo "Please complete the setup steps first:"
    echo "1. cd /path/to/divinum-officium"
    echo "2. mkdir -p k8s"
    echo "3. cp deployment.yaml service.yaml ingress.yaml kustomization.yaml k8s/"
    echo "4. git add k8s/"
    echo "5. git commit -m 'Add Kubernetes manifests'"
    echo "6. git push origin master"
    echo ""
    exit 0
fi

# Deploy ArgoCD Application
echo ""
echo "📦 Deploying ArgoCD Application..."
kubectl apply -f argocd-application.yaml

echo ""
echo "⏳ Waiting for ArgoCD to sync..."
sleep 5

# Check application status
echo ""
echo "📊 Application Status:"
kubectl get application divinum-officium -n argocd

echo ""
echo "🎉 Deployment initiated!"
echo ""
echo "Next steps:"
echo "1. Check ArgoCD UI to monitor deployment:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   Then visit: https://localhost:8080"
echo ""
echo "2. Get ArgoCD admin password:"
echo "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
echo ""
echo "3. Check pod status:"
echo "   kubectl get pods -l app=divinum-officium"
echo ""
echo "4. Access your application:"
echo "   kubectl port-forward svc/divinum-officium 8080:80"
echo "   Then visit: http://localhost:8080"
echo ""

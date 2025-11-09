# Deploying Divinum Officium to Kubernetes with ArgoCD

## Overview
This guide will help you deploy the Divinum Officium application to your Kubernetes cluster using ArgoCD for GitOps-based continuous deployment.

## Prerequisites
- Kubernetes cluster is running
- ArgoCD is installed and accessible
- kubectl is configured to access your cluster
- You have access to your GitHub repository

## Setup Steps

### Step 1: Add Kubernetes Manifests to Your Repository

You need to add the Kubernetes manifests to your GitHub repository:

1. Create a `k8s` directory in your repository root:
   ```bash
   mkdir k8s
   ```

2. Copy these files to the `k8s` directory:
   - `deployment.yaml` - The application deployment
   - `service.yaml` - The Kubernetes service
   - `ingress.yaml` - The ingress for external access

3. Commit and push to GitHub:
   ```bash
   git add k8s/
   git commit -m "Add Kubernetes manifests"
   git push origin master
   ```

### Step 2: Configure the Ingress (Optional but Recommended)

Edit `k8s/ingress.yaml` in your repository:
- Replace `divinum-officium.example.com` with your actual domain
- Adjust `ingressClassName` if you're not using nginx
- Uncomment TLS section if you want HTTPS

### Step 3: Deploy the ArgoCD Application

Apply the ArgoCD application manifest:

```bash
kubectl apply -f argocd-application.yaml
```

This tells ArgoCD to:
- Monitor your GitHub repository
- Automatically sync the Kubernetes manifests
- Deploy them to your cluster

### Step 4: Verify the Deployment

1. Check ArgoCD UI:
   ```bash
   # Get ArgoCD admin password
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   
   # Port forward to access ArgoCD UI
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```
   
   Then visit https://localhost:8080 and login with:
   - Username: `admin`
   - Password: (from the command above)

2. Check the application status:
   ```bash
   kubectl get pods -l app=divinum-officium
   kubectl get svc divinum-officium
   kubectl get ingress divinum-officium
   ```

### Step 5: Access Your Application

Once deployed, you can access the application:

**With Ingress:**
- Visit your configured domain (e.g., https://divinum-officium.example.com)

**Without Ingress (for testing):**
```bash
# Port forward to the service
kubectl port-forward svc/divinum-officium 8080:80

# Visit http://localhost:8080
```

## How ArgoCD Works

With this setup:
1. **GitOps**: Your GitHub repository is the source of truth
2. **Automated Sync**: Any changes you push to the `k8s/` directory will automatically deploy
3. **Self-Healing**: If someone manually changes the cluster, ArgoCD will revert it to match Git
4. **Automatic Pruning**: Deleted resources in Git will be deleted from the cluster

## Making Changes

To update your application:
1. Edit the manifests in your repository's `k8s/` directory
2. Commit and push to GitHub
3. ArgoCD will automatically detect and apply the changes

## Scaling the Application

To change the number of replicas:
```yaml
# In k8s/deployment.yaml
spec:
  replicas: 3  # Change this number
```

Commit, push, and ArgoCD will handle the rest!

## Troubleshooting

### Check ArgoCD Application Status
```bash
kubectl get application -n argocd
kubectl describe application divinum-officium -n argocd
```

### Force Sync
If automatic sync isn't working:
```bash
# Via CLI
argocd app sync divinum-officium

# Or via UI
# Click the "Sync" button in the ArgoCD UI
```

### View Logs
```bash
kubectl logs -l app=divinum-officium
```

### Check ArgoCD Logs
```bash
kubectl logs -n argocd deployment/argocd-application-controller
```

## Additional Configuration

### Using a Private Repository
If your repository is private, you need to add credentials to ArgoCD:

```bash
argocd repo add https://github.com/hcblassingame/divinum-officium.git \
  --username <your-username> \
  --password <your-token>
```

### Changing the Target Revision
To deploy from a different branch or tag, edit the ArgoCD application:
```yaml
spec:
  source:
    targetRevision: develop  # or a specific tag/commit
```

## Architecture

```
GitHub Repository
    ↓
ArgoCD (monitors repo)
    ↓
Kubernetes Cluster
    ├── Deployment (2 replicas)
    ├── Service (ClusterIP)
    └── Ingress (external access)
```

## Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Divinum Officium Project](https://github.com/hcblassingame/divinum-officium)

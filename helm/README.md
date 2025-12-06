# Watchlog Helm Repository Setup Guide

This guide will help you set up a Helm repository for the Watchlog Agent.

## Method 1: Using GitHub Pages (Recommended)

### Step 1: Package the Chart

```bash
cd agent-kubernetes/helm
helm package watchlog-agent
```

This command creates a file `watchlog-agent-1.0.0.tgz`.

### Step 2: Create Helm Repository

```bash
# Create directory for repository
mkdir -p charts-repo

# Copy chart package
cp watchlog-agent-*.tgz charts-repo/

# Create index.yaml
helm repo index charts-repo --url https://charts.watchlog.io
```

### Step 3: Push to GitHub

1. Create a new repository on GitHub (e.g., `watchlog-helm-charts`)
2. Push the `charts-repo/` files:

```bash
cd charts-repo
git init
git add .
git commit -m "Add Watchlog Helm chart"
git remote add origin https://github.com/your-org/watchlog-helm-charts.git
git push -u origin main
```

### Step 4: Enable GitHub Pages

1. Go to Settings > Pages in your GitHub repository
2. Set Source to `main` branch and `/ (root)`
3. Set Custom domain to `charts.watchlog.io` (optional)

### Step 5: Configure DNS (if using custom domain)

Add a CNAME record in your DNS provider:
- Name: `charts`
- Value: `your-username.github.io`

## Method 2: Using Other Static Hosting Services

You can use any static hosting service:
- Netlify
- Vercel
- AWS S3 + CloudFront
- Azure Blob Storage

Just upload the `charts-repo/` files to them.

## Method 3: Using ChartMuseum (for production)

ChartMuseum is a Helm repository server that you can deploy.

```bash
# Install ChartMuseum
helm repo add chartmuseum https://chartmuseum.github.io/charts
helm install chartmuseum chartmuseum/chartmuseum

# Upload chart
curl -X POST --data-binary "@watchlog-agent-1.0.0.tgz" \
  http://chartmuseum:8080/api/charts
```

## Updating the Chart

Every time you modify the chart:

```bash
# 1. Increment version in Chart.yaml
# 2. Package it
helm package watchlog-agent

# 3. Add to repository
cp watchlog-agent-*.tgz charts-repo/

# 4. Update index
helm repo index charts-repo --url https://charts.watchlog.io --merge charts-repo/index.yaml

# 5. Push
cd charts-repo
git add .
git commit -m "Update chart to version X.X.X"
git push
```

## Testing the Repository

```bash
# Add repository
helm repo add watchlog https://charts.watchlog.io

# Update
helm repo update

# Search
helm search repo watchlog

# Install (dry-run)
helm install watchlog-agent watchlog/watchlog-agent --dry-run --debug
```

## Quick Setup Script

Use the provided script to automate the setup:

```bash
./setup-repo.sh
```

This script will:
1. Package the Helm chart
2. Create the repository directory
3. Generate the index.yaml file

Then follow the steps above to push to GitHub and enable Pages.

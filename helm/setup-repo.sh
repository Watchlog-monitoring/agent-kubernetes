#!/bin/bash
# Script for setting up Watchlog Helm Repository
# This script packages the chart and prepares it for hosting

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📦 Setting up Watchlog Helm Repository...${NC}"
echo ""

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Error: Helm is not installed"
    echo "Please install Helm: https://helm.sh/docs/intro/install/"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHART_DIR="$SCRIPT_DIR/watchlog-agent"
REPO_DIR="$SCRIPT_DIR/charts-repo"

# Create repository directory
mkdir -p "$REPO_DIR"

echo -e "${YELLOW}📦 Packaging Helm chart...${NC}"
cd "$CHART_DIR"
helm package . --destination "$REPO_DIR"

echo -e "${YELLOW}📝 Generating repository index...${NC}"
cd "$REPO_DIR"

# Check if index.yaml exists (for updates)
if [ -f "index.yaml" ]; then
    echo "Merging with existing index.yaml..."
    helm repo index . --url https://charts.watchlog.io --merge index.yaml
else
    echo "Creating new index.yaml..."
    helm repo index . --url https://charts.watchlog.io
fi

echo ""
echo -e "${GREEN}✅ Repository setup complete!${NC}"
echo ""
echo "Files created in: $REPO_DIR"
echo ""
echo "Next steps:"
echo "1. Review the files in $REPO_DIR"
echo "2. Push to GitHub or your hosting service:"
echo "   cd $REPO_DIR"
echo "   git init"
echo "   git add ."
echo "   git commit -m 'Add Watchlog Helm chart'"
echo "   git remote add origin <your-repo-url>"
echo "   git push -u origin main"
echo ""
echo "3. Enable GitHub Pages (if using GitHub):"
echo "   Settings > Pages > Source: main branch, / (root)"
echo ""
echo "4. Test the repository:"
echo "   helm repo add watchlog https://charts.watchlog.io"
echo "   helm repo update"
echo "   helm search repo watchlog"


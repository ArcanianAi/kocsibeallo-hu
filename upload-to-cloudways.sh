#!/bin/bash
# Upload deployment files to Cloudways
# Run this from your LOCAL machine
#
# Usage: ./upload-to-cloudways.sh

set -e

echo "=============================================="
echo "Uploading Deployment Files to Cloudways"
echo "=============================================="
echo ""

# Cloudways credentials
SSH_HOST="165.22.200.254"
SSH_PORT="22"
SSH_USER="kocsid10ssh"

echo "Uploading files to $SSH_USER@$SSH_HOST..."
echo "You will be prompted for the password: KCSIssH3497!"
echo ""

# Upload database export
echo "1. Uploading database export (36MB)..."
scp -P "$SSH_PORT" /Volumes/T9/Sites/kocsibeallo-hu/cloudways-db-export.sql "$SSH_USER@$SSH_HOST:/home/$SSH_USER/"
echo "✓ Database uploaded"
echo ""

# Upload deployment script
echo "2. Uploading deployment script..."
scp -P "$SSH_PORT" /Volumes/T9/Sites/kocsibeallo-hu/scripts/cloudways/production-deploy-full.sh "$SSH_USER@$SSH_HOST:/home/$SSH_USER/"
echo "✓ Deployment script uploaded"
echo ""

# Upload production settings template
echo "3. Uploading production settings template..."
scp -P "$SSH_PORT" /Volumes/T9/Sites/kocsibeallo-hu/drupal10/settings.production.php "$SSH_USER@$SSH_HOST:/home/$SSH_USER/"
echo "✓ Settings template uploaded"
echo ""

echo "=============================================="
echo "✓ All files uploaded successfully!"
echo "=============================================="
echo ""
echo "Next steps:"
echo ""
echo "1. SSH into Cloudways:"
echo "   ssh $SSH_USER@$SSH_HOST -p $SSH_PORT"
echo ""
echo "2. Navigate to your application:"
echo "   cd applications/[app-name]/public_html"
echo ""
echo "3. Run the deployment script:"
echo "   cp ~/production-deploy-full.sh ."
echo "   chmod +x production-deploy-full.sh"
echo "   ./production-deploy-full.sh"
echo ""
echo "=============================================="

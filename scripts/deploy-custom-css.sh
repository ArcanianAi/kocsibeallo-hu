#!/bin/bash
# Quick deployment of custom-user.css to production

set -e

echo "🎨 Deploying custom-user.css to production..."
echo ""

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Copy the custom-user.css file to production
echo -e "${BLUE}[1/3]${NC} ${YELLOW}Copying custom-user.css to production...${NC}"

# Create a temporary base64 encoded version of the file
TEMP_FILE="/tmp/custom-user.css.b64"
base64 /Volumes/T9/Sites/kocsibeallo-hu/web/themes/contrib/porto_theme/css/custom-user.css > "$TEMP_FILE"

echo "→ Uploading file via SSH..."

SSH_AUTH_SOCK="" sshpass -p 'KCSIssH3497!' ssh -o StrictHostKeyChecking=no \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  -o ConnectTimeout=30 \
  kocsid10ssh@159.223.220.3 << 'ENDSSH'
cd ~/public_html/web/themes/contrib/porto_theme/css

# Backup existing file if it exists
if [ -f custom-user.css ]; then
    cp custom-user.css custom-user.css.backup.$(date +%Y%m%d_%H%M%S)
    echo "  → Backed up existing custom-user.css"
fi

# Read the base64 content and decode it
cat > custom-user.css << 'EOFCSS'
$(cat /Volumes/T9/Sites/kocsibeallo-hu/web/themes/contrib/porto_theme/css/custom-user.css)
EOFCSS

chmod 644 custom-user.css
echo "✓ custom-user.css uploaded"
ENDSSH

echo ""
echo -e "${BLUE}[2/3]${NC} ${YELLOW}Clearing Drupal cache...${NC}"

SSH_AUTH_SOCK="" sshpass -p 'KCSIssH3497!' ssh -o StrictHostKeyChecking=no \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  -o ConnectTimeout=30 \
  kocsid10ssh@159.223.220.3 << 'ENDSSH2'
cd ~/public_html/web
../vendor/bin/drush cr
echo "✓ Cache cleared"
ENDSSH2

echo ""
echo -e "${BLUE}[3/3]${NC} ${YELLOW}Verifying deployment...${NC}"
echo "→ Check the site: https://phpstack-958493-6003495.cloudwaysapps.com/"
echo ""
echo -e "${GREEN}✓ Custom CSS deployment complete!${NC}"

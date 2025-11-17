#!/bin/bash
# Check slideshow template differences between local and production

PROD_USER="kocsid10ssh"
PROD_PASS="KCSIssH3497!"
PROD_HOST="159.223.220.3"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPORTS_DIR="$(cd "$(dirname "$0")/.." && pwd)/reports"
mkdir -p "$REPORTS_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="${REPORTS_DIR}/slideshow-template-check-${TIMESTAMP}.txt"

echo -e "${BLUE}========================================${NC}" | tee "$REPORT_FILE"
echo -e "${BLUE}🔍 SLIDESHOW TEMPLATE COMPARISON${NC}" | tee -a "$REPORT_FILE"
echo -e "${BLUE}========================================${NC}" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

echo "=== LOCAL VERSION ===" | tee -a "$REPORT_FILE"
echo "File: web/themes/contrib/porto_theme/templates/page--front.html.twig" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"
echo "→ slide_show region rendering:" | tee -a "$REPORT_FILE"
grep -A8 "slide_show" /Volumes/T9/Sites/kocsibeallo-hu/web/themes/contrib/porto_theme/templates/page--front.html.twig | head -10 | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

echo "=== PRODUCTION VERSION ===" | tee -a "$REPORT_FILE"
SSH_AUTH_SOCK="" sshpass -p "${PROD_PASS}" ssh \
  -o StrictHostKeyChecking=no \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  -o ConnectTimeout=30 \
  ${PROD_USER}@${PROD_HOST} bash << 'EOFCHECK' | tee -a "$REPORT_FILE"

cd ~/public_html/web/themes/contrib/porto_theme/templates

echo "→ slide_show region rendering:"
grep -A8 "slide_show" page--front.html.twig | head -10

echo ""
echo "→ Git status of template:"
cd ~/public_html
git status --short web/themes/contrib/porto_theme/templates/page--front.html.twig

echo ""
echo "→ Git diff of template:"
git diff web/themes/contrib/porto_theme/templates/page--front.html.twig | head -30

EOFCHECK

echo "" | tee -a "$REPORT_FILE"
echo -e "${GREEN}Report saved to: $REPORT_FILE${NC}"

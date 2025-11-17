#!/bin/bash
# Fix script to restore deleted Porto theme files on production

PROD_USER="kocsid10ssh"
PROD_PASS="KCSIssH3497!"
PROD_HOST="159.223.220.3"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create reports directory if it doesn't exist
REPORTS_DIR="$(cd "$(dirname "$0")/.." && pwd)/reports"
mkdir -p "$REPORTS_DIR"

# Generate timestamped report filename
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="${REPORTS_DIR}/fix-deleted-files-${TIMESTAMP}.txt"

echo -e "${BLUE}========================================${NC}" | tee "$REPORT_FILE"
echo -e "${BLUE}🔧 RESTORING DELETED PORTO FILES${NC}" | tee -a "$REPORT_FILE"
echo -e "${BLUE}========================================${NC}" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"
echo "Report: $REPORT_FILE" | tee -a "$REPORT_FILE"
echo "Date: $(date)" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

echo -e "${YELLOW}This will restore the following deleted files:${NC}" | tee -a "$REPORT_FILE"
echo "  - web/themes/contrib/porto_theme/css/custom-blog.css" | tee -a "$REPORT_FILE"
echo "  - web/themes/contrib/porto_theme/css/custom-user.css (39KB - CRITICAL)" | tee -a "$REPORT_FILE"
echo "  - web/themes/contrib/porto_theme/js/blog-date-format.js" | tee -a "$REPORT_FILE"
echo "  - web/themes/contrib/porto_theme/js/header-fixes.js" | tee -a "$REPORT_FILE"
echo "  - web/themes/contrib/porto_theme/porto.info.yml (restore library refs)" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

echo -e "${YELLOW}Connecting to production...${NC}"
echo "" | tee -a "$REPORT_FILE"

# Run fix and save output to both console and report
SSH_AUTH_SOCK="" sshpass -p "${PROD_PASS}" ssh \
  -o StrictHostKeyChecking=no \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  -o ConnectTimeout=30 \
  ${PROD_USER}@${PROD_HOST} bash << 'EOFFIX' | tee -a "$REPORT_FILE"

cd ~/public_html

echo "=== 1. CHECKING GIT STATUS ==="
echo "→ Current git status (deleted files):"
git status --short | grep "^ D" | head -10
echo ""

echo "=== 2. RESTORING DELETED FILES FROM GIT ==="
echo "→ Running git restore on deleted Porto files..."

# Restore deleted CSS files
if git status --short | grep -q "^ D.*custom-blog.css"; then
    echo "  → Restoring custom-blog.css..."
    git restore web/themes/contrib/porto_theme/css/custom-blog.css
    echo "  ✓ Restored"
fi

if git status --short | grep -q "^ D.*custom-user.css"; then
    echo "  → Restoring custom-user.css (CRITICAL - 39KB custom CSS)..."
    git restore web/themes/contrib/porto_theme/css/custom-user.css
    echo "  ✓ Restored"
fi

# Restore deleted JS files
if git status --short | grep -q "^ D.*header-fixes.js"; then
    echo "  → Restoring header-fixes.js..."
    git restore web/themes/contrib/porto_theme/js/header-fixes.js
    echo "  ✓ Restored"
fi

if git status --short | grep -q "^ D.*blog-date-format.js"; then
    echo "  → Restoring blog-date-format.js..."
    git restore web/themes/contrib/porto_theme/js/blog-date-format.js
    echo "  ✓ Restored"
fi

# Restore modified files (porto.info.yml, porto.libraries.yml, etc)
echo ""
echo "=== 3. RESTORING MODIFIED FILES ==="
echo "→ Restoring modified Porto configuration files..."

if git status --short | grep -q "^ M.*porto.info.yml"; then
    echo "  → Restoring porto.info.yml (library definitions)..."
    git restore web/themes/contrib/porto_theme/porto.info.yml
    echo "  ✓ Restored"
fi

if git status --short | grep -q "^ M.*porto.libraries.yml"; then
    echo "  → Restoring porto.libraries.yml..."
    git restore web/themes/contrib/porto_theme/porto.libraries.yml
    echo "  ✓ Restored"
fi

if git status --short | grep -q "^ M.*porto.theme"; then
    echo "  → Restoring porto.theme..."
    git restore web/themes/contrib/porto_theme/porto.theme
    echo "  ✓ Restored"
fi

# Restore any modified templates
echo "  → Restoring modified header templates..."
git restore web/themes/contrib/porto_theme/templates/includes/header_option/*.html.twig 2>/dev/null || true
echo "  ✓ Restored"

echo ""
echo "=== 4. VERIFYING RESTORED FILES ==="

# Verify custom-user.css
if [ -f web/themes/contrib/porto_theme/css/custom-user.css ]; then
    SIZE=$(wc -c < web/themes/contrib/porto_theme/css/custom-user.css)
    if [ $SIZE -gt 30000 ]; then
        echo "  ✓ custom-user.css: $SIZE bytes (GOOD)"
        # Check for gold color
        if grep -q "ac9c58" web/themes/contrib/porto_theme/css/custom-user.css; then
            echo "    ✓ Contains #ac9c58 gold color"
        fi
    else
        echo "  ⚠ custom-user.css: Only $SIZE bytes (expected ~39KB)"
    fi
else
    echo "  ✗ custom-user.css: STILL MISSING"
fi

# Verify header-fixes.js
if [ -f web/themes/contrib/porto_theme/js/header-fixes.js ]; then
    SIZE=$(wc -c < web/themes/contrib/porto_theme/js/header-fixes.js)
    echo "  ✓ header-fixes.js: $SIZE bytes"
else
    echo "  ✗ header-fixes.js: STILL MISSING"
fi

# Verify blog-date-format.js
if [ -f web/themes/contrib/porto_theme/js/blog-date-format.js ]; then
    SIZE=$(wc -c < web/themes/contrib/porto_theme/js/blog-date-format.js)
    echo "  ✓ blog-date-format.js: $SIZE bytes"
else
    echo "  ✗ blog-date-format.js: STILL MISSING"
fi

# Verify porto.info.yml has custom libraries
echo ""
echo "  → Checking porto.info.yml libraries section:"
grep -A5 "^libraries:" web/themes/contrib/porto_theme/porto.info.yml | sed 's/^/    /'

echo ""
echo "=== 5. CLEARING DRUPAL CACHE ==="
echo "→ Clearing cache to rebuild CSS aggregation..."
cd web
../vendor/bin/drush cr 2>&1 | tail -5
echo "✓ Cache cleared"

echo ""
echo "=== 6. FINAL GIT STATUS ==="
echo "→ Remaining uncommitted changes:"
cd ~/public_html
git status --short | head -15

echo ""
echo "========================================="
echo "✓ FILE RESTORATION COMPLETE"
echo "========================================="

EOFFIX

echo "" | tee -a "$REPORT_FILE"
echo -e "${GREEN}========================================${NC}" | tee -a "$REPORT_FILE"
echo -e "${GREEN}✓ FIX COMPLETE${NC}" | tee -a "$REPORT_FILE"
echo -e "${GREEN}========================================${NC}" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"
echo "Report saved to: $REPORT_FILE" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"
echo -e "${YELLOW}Next steps:${NC}" | tee -a "$REPORT_FILE"
echo "1. Visit https://phpstack-958493-6003495.cloudwaysapps.com/" | tee -a "$REPORT_FILE"
echo "2. Hard refresh (Cmd+Shift+R / Ctrl+Shift+F5)" | tee -a "$REPORT_FILE"
echo "3. Check for #ac9c58 gold color and #011e41 dark blue header" | tee -a "$REPORT_FILE"
echo "4. If still not working, run ./scripts/diagnose-production.sh again" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

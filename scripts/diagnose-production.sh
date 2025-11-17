#!/bin/bash
# Diagnostic script to check production server state

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
REPORT_FILE="${REPORTS_DIR}/production-diagnostic-${TIMESTAMP}.txt"

echo -e "${BLUE}========================================${NC}" | tee "$REPORT_FILE"
echo -e "${BLUE}🔍 PRODUCTION SERVER DIAGNOSTIC${NC}" | tee -a "$REPORT_FILE"
echo -e "${BLUE}========================================${NC}" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"
echo "Report: $REPORT_FILE" | tee -a "$REPORT_FILE"
echo "Date: $(date)" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

echo -e "${YELLOW}Connecting to production...${NC}"
echo "" | tee -a "$REPORT_FILE"

# Run diagnostic and save output to both console and report
SSH_AUTH_SOCK="" sshpass -p "${PROD_PASS}" ssh \
  -o StrictHostKeyChecking=no \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  -o ConnectTimeout=30 \
  ${PROD_USER}@${PROD_HOST} bash << 'EOFDIAG' | tee -a "$REPORT_FILE"

echo "=== 1. DIRECTORY STRUCTURE ==="
cd ~/public_html
echo "→ Current directory: $(pwd)"
echo "→ Directory listing:"
ls -lah | head -15
echo ""

echo "=== 2. GIT REPOSITORY STATUS ==="
if [ -d .git ]; then
    echo "✓ .git directory EXISTS"
    echo ""
    echo "→ Git remote:"
    git remote -v
    echo ""
    echo "→ Current branch:"
    git branch --show-current
    echo ""
    echo "→ Last 5 commits:"
    git log --oneline -5
    echo ""
    echo "→ Git status:"
    git status | head -20
    echo ""
    echo "→ Uncommitted/untracked files:"
    git status --short | head -10
else
    echo "✗ .git directory DOES NOT EXIST"
    echo "  → This means the repository was NOT cloned properly"
    echo "  → All files were copied manually, not via git"
fi
echo ""

echo "=== 3. PORTO THEME FILES ==="
cd ~/public_html/web/themes/contrib/porto_theme

echo "→ porto.info.yml:"
if [ -f porto.info.yml ]; then
    echo "  Size: $(wc -c < porto.info.yml) bytes"
    echo "  Libraries section:"
    grep -A5 "^libraries:" porto.info.yml || echo "  (libraries section not found)"
else
    echo "  ✗ FILE MISSING"
fi
echo ""

echo "→ Custom CSS files:"
for file in css/custom-user.css css/custom.css css/h.css; do
    if [ -f "$file" ]; then
        SIZE=$(wc -c < "$file")
        if [ $SIZE -eq 0 ]; then
            echo "  ⚠ $file: EMPTY (0 bytes)"
        else
            echo "  ✓ $file: $SIZE bytes"
        fi
    else
        echo "  ✗ $file: NOT FOUND"
    fi
done
echo ""

echo "→ Custom JS files:"
for file in js/custom.js js/header-fixes.js js/blog-date-format.js; do
    if [ -f "$file" ]; then
        SIZE=$(wc -c < "$file")
        if [ $SIZE -eq 0 ]; then
            echo "  ⚠ $file: EMPTY (0 bytes)"
        else
            echo "  ✓ $file: $SIZE bytes"
        fi
    else
        echo "  ✗ $file: NOT FOUND"
    fi
done
echo ""

echo "=== 4. FILE CONTENT SAMPLES ==="
echo "→ First 5 lines of porto.info.yml:"
head -5 porto.info.yml 2>/dev/null || echo "  (file not readable)"
echo ""

echo "→ First 3 lines of css/custom-user.css:"
head -3 css/custom-user.css 2>/dev/null || echo "  (file missing or empty)"
echo ""

echo "→ Checking for #ac9c58 gold color in CSS files:"
if grep -q "ac9c58" css/custom-user.css 2>/dev/null; then
    COUNT=$(grep -c "ac9c58" css/custom-user.css)
    echo "  ✓ Found in custom-user.css ($COUNT occurrences)"
else
    echo "  ✗ NOT found in custom-user.css"
fi

if grep -q "ac9c58" css/custom.css 2>/dev/null; then
    COUNT=$(grep -c "ac9c58" css/custom.css)
    echo "  ✓ Found in custom.css ($COUNT occurrences)"
else
    echo "  ✗ NOT found in custom.css"
fi
echo ""

echo "=== 5. CONFIG FILES ==="
cd ~/public_html/config/sync

echo "→ Config directory:"
if [ -d . ]; then
    FILE_COUNT=$(find . -name "*.yml" | wc -l)
    echo "  ✓ Directory exists: $FILE_COUNT YAML files"
else
    echo "  ✗ Directory missing"
fi
echo ""

echo "→ porto.settings.yml:"
if [ -f porto.settings.yml ]; then
    SIZE=$(wc -c < porto.settings.yml)
    echo "  ✓ Size: $SIZE bytes"
    echo "  First 5 lines:"
    head -5 porto.settings.yml
    echo "  ..."
    echo "  Checking for user_css field:"
    if grep -q "user_css:" porto.settings.yml; then
        echo "  ✓ user_css field found"
    else
        echo "  ✗ user_css field NOT found"
    fi
else
    echo "  ✗ FILE MISSING"
fi
echo ""

echo "=== 6. FILE PERMISSIONS ==="
cd ~/public_html
echo "→ Directory permissions:"
ls -ld web/themes/contrib/porto_theme
ls -ld web/themes/contrib/porto_theme/css
ls -ld web/themes/contrib/porto_theme/js
echo ""

echo "→ Custom file permissions:"
ls -l web/themes/contrib/porto_theme/porto.info.yml 2>/dev/null || echo "  porto.info.yml: NOT FOUND"
ls -l web/themes/contrib/porto_theme/css/custom-user.css 2>/dev/null || echo "  custom-user.css: NOT FOUND"
ls -l web/themes/contrib/porto_theme/js/header-fixes.js 2>/dev/null || echo "  header-fixes.js: NOT FOUND"
echo ""

echo "=== 7. COMPOSER STATUS ==="
cd ~/public_html
echo "→ Vendor directory:"
if [ -d vendor ]; then
    echo "  ✓ vendor directory exists"
    if [ -f vendor/autoload.php ]; then
        echo "  ✓ vendor/autoload.php exists"
    else
        echo "  ✗ vendor/autoload.php MISSING"
    fi
else
    echo "  ✗ vendor directory MISSING"
fi
echo ""

echo "→ Composer lock hash:"
if [ -f composer.lock ]; then
    HASH=$(md5sum composer.lock | awk '{print $1}')
    echo "  Hash: ${HASH:0:16}..."
    if [ -f /tmp/composer.lock.hash ]; then
        SAVED_HASH=$(cat /tmp/composer.lock.hash)
        echo "  Saved: ${SAVED_HASH:0:16}..."
        if [ "$HASH" = "$SAVED_HASH" ]; then
            echo "  ✓ Matches saved hash"
        else
            echo "  ⚠ Different from saved hash"
        fi
    else
        echo "  (no saved hash found)"
    fi
else
    echo "  ✗ composer.lock MISSING"
fi
echo ""

echo "=== 8. DEPLOYMENT STATE ==="
if [ -f /tmp/kocsibeallo-deployment-state.txt ]; then
    echo "→ Deployment state file found:"
    cat /tmp/kocsibeallo-deployment-state.txt
else
    echo "→ No deployment state file found"
fi
echo ""

echo "=== 9. DISK USAGE ==="
cd ~/public_html
echo "→ Total size:"
du -sh . 2>/dev/null || echo "  (cannot calculate)"
echo "→ Top directories:"
du -sh web vendor config 2>/dev/null || echo "  (cannot calculate)"
echo ""

echo "========================================="
echo "✓ DIAGNOSTIC COMPLETE"
echo "========================================="

EOFDIAG

echo "" | tee -a "$REPORT_FILE"
echo -e "${GREEN}========================================${NC}" | tee -a "$REPORT_FILE"
echo -e "${GREEN}✓ DIAGNOSTIC COMPLETE${NC}" | tee -a "$REPORT_FILE"
echo -e "${GREEN}========================================${NC}" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"
echo "Report saved to: $REPORT_FILE" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"
echo -e "${YELLOW}Next steps based on findings:${NC}" | tee -a "$REPORT_FILE"
echo "1. If .git missing → Need fresh git clone" | tee -a "$REPORT_FILE"
echo "2. If files DELETED by git → Run ./scripts/fix-deleted-files.sh" | tee -a "$REPORT_FILE"
echo "3. If files empty → Need to re-pull from GitHub" | tee -a "$REPORT_FILE"
echo "4. If porto.info.yml wrong → Need to update from git" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

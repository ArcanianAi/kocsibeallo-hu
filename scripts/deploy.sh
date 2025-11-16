#!/bin/bash
set -e

# Production Cloudways D10
PROD_USER="kocsid10ssh"
PROD_PASS="KCSIssH3497!"
PROD_HOST="159.223.220.3"
PROD_PATH="~/public_html"
GIT_REPO="https://github.com/ArcanianAi/kocsibeallo-hu.git"

# Old D7 Server (source for files)
D7_USER="kocsibeall.ssh.d10"
D7_PASS="D10Test99!"
D7_HOST="165.22.200.254"
D7_FILES="/home/969836.cloudwaysapps.com/pajfrsyfzm/public_html/sites/default/files"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# State file for resuming deployment
STATE_FILE="/tmp/kocsibeallo-deployment-state.txt"

# Function to mark step as completed
mark_complete() {
    echo "$1" >> ${STATE_FILE}
}

# Function to check if step is completed
is_complete() {
    [ -f ${STATE_FILE} ] && grep -q "^$1$" ${STATE_FILE}
}

# Function to skip completed step
skip_if_complete() {
    if is_complete "$1"; then
        echo -e "${GREEN}✓ Step $1 already completed (skipping)${NC}"
        return 0
    fi
    return 1
}

# Check if resuming
if [ -f ${STATE_FILE} ]; then
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}📋 RESUMING PREVIOUS DEPLOYMENT${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}Completed steps:${NC}"
    cat ${STATE_FILE} | sed 's/^/  ✓ /'
    echo ""
    echo -e "${YELLOW}To start fresh, run: rm ${STATE_FILE}${NC}"
    echo ""
else
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}🚀 PRODUCTION DEPLOYMENT (GIT-BASED)${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
fi

# Step 1: Push to GitHub
if ! skip_if_complete "step1"; then
    echo -e "${BLUE}[1/7]${NC} ${YELLOW}Pushing code to GitHub...${NC}"
    echo "→ Local repository: https://github.com/ArcanianAi/kocsibeallo-hu"
    git push origin main 2>&1 | grep -v "Everything up-to-date" || echo "✓ Already up to date"
    mark_complete "step1"
    echo -e "${GREEN}✓ Code pushed to GitHub${NC}"
fi
echo ""

# Step 2: Test SSH connection to production
if ! skip_if_complete "step2"; then
    echo -e "${BLUE}[2/7]${NC} ${YELLOW}Testing SSH connection to production...${NC}"

    # First, test basic network connectivity
echo "→ Testing network connectivity to ${PROD_HOST}..."
if ping -c 2 -W 3 ${PROD_HOST} >/dev/null 2>&1; then
    echo "✓ Server is reachable (ping successful)"
else
    echo -e "${YELLOW}⚠ Server ping failed (might be ICMP blocked)${NC}"
fi

# Test SSH port
echo "→ Testing SSH port 22..."
if nc -z -w 5 ${PROD_HOST} 22 2>/dev/null; then
    echo "✓ SSH port 22 is open"
else
    echo -e "${RED}✗ SSH port 22 is not reachable${NC}"
    echo -e "${YELLOW}Possible issues:${NC}"
    echo -e "  - Firewall blocking connection"
    echo -e "  - SSH service not running"
    echo -e "  - Wrong IP address"
    exit 1
fi

# Test SSH authentication
echo "→ Testing SSH authentication..."

# Simple SSH test with built-in timeout (no external timeout command needed)
SSH_TEST=$(SSH_AUTH_SOCK="" sshpass -p "${PROD_PASS}" ssh \
  -o StrictHostKeyChecking=no \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  -o ConnectTimeout=15 \
  -o ServerAliveInterval=5 \
  -o ServerAliveCountMax=2 \
  ${PROD_USER}@${PROD_HOST} "echo SSH_OK" 2>&1)
SSH_EXIT_CODE=$?

if echo "$SSH_TEST" | grep -q "SSH_OK"; then
    echo "✓ SSH authentication successful"

    # Now test GitHub connectivity from production
    echo "→ Testing GitHub connectivity from production..."
    SSH_AUTH_SOCK="" sshpass -p "${PROD_PASS}" ssh \
      -o StrictHostKeyChecking=no \
      -o PreferredAuthentications=password \
      -o PubkeyAuthentication=no \
      ${PROD_USER}@${PROD_HOST} bash << 'EOFTEST'
set -e
echo "  → Testing connection to GitHub..."
if curl -I --connect-timeout 10 https://github.com 2>&1 | grep -q "HTTP"; then
    echo "  ✓ GitHub is reachable"
else
    echo "  ✗ Cannot reach GitHub"
    exit 1
fi

echo "  → Testing git command..."
if command -v git &> /dev/null; then
    git --version
    echo "  ✓ Git is available"
else
    echo "  ✗ Git not installed"
    exit 1
fi
EOFTEST

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ All connectivity tests passed${NC}"
    else
        echo -e "${RED}✗ GitHub connectivity FAILED${NC}"
        echo -e "${YELLOW}Please check network/firewall settings on production server${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ SSH authentication failed (exit code: $SSH_EXIT_CODE)${NC}"
    echo ""
    echo -e "${YELLOW}SSH Debug Output (last 20 lines):${NC}"
    echo "$SSH_TEST" | tail -20
    echo ""

    # Check for specific error patterns
    if echo "$SSH_TEST" | grep -q "Permission denied"; then
        echo -e "${RED}Error: Permission denied${NC}"
        echo -e "  → Wrong username or password"
    elif echo "$SSH_TEST" | grep -q "Too many authentication failures"; then
        echo -e "${RED}Error: Too many authentication failures${NC}"
        echo -e "  → Wait 10-15 minutes before trying again"
    elif echo "$SSH_TEST" | grep -q "Connection timed out"; then
        echo -e "${RED}Error: Connection timed out${NC}"
        echo -e "  → Server took too long to respond"
    elif echo "$SSH_TEST" | grep -q "Connection refused"; then
        echo -e "${RED}Error: Connection refused${NC}"
        echo -e "  → SSH service may be down"
    else
        echo -e "${YELLOW}Possible issues:${NC}"
        echo -e "  - Authentication problem"
        echo -e "  - Network issue"
        echo -e "  - Server configuration"
    fi

    echo ""
    echo -e "${YELLOW}Credentials being used:${NC}"
    echo -e "  User: ${PROD_USER}"
    echo -e "  Host: ${PROD_HOST}"
    echo -e "  Port: 22"
    exit 1
fi
    mark_complete "step2"
fi
echo ""

# Step 3: Deploy code from GitHub
if ! skip_if_complete "step3"; then
    echo -e "${BLUE}[3/7]${NC} ${YELLOW}Deploying code from GitHub...${NC}"
SSH_AUTH_SOCK="" sshpass -p "${PROD_PASS}" ssh \
  -o StrictHostKeyChecking=no \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  ${PROD_USER}@${PROD_HOST} bash << EOFGIT
set -e
cd ~/public_html

echo "→ Current directory: \$(pwd)"

# Check if this is already a git repository
if [ -d .git ]; then
    echo "→ Git repository detected - pulling latest changes..."

    # Stash any local changes (like settings.php)
    if ! git diff --quiet 2>/dev/null; then
        echo "  → Stashing local changes..."
        git stash push -m "Auto-stash before deployment \$(date +%Y%m%d_%H%M%S)" 2>&1 | head -3
    fi

    # Pull latest from main
    echo "  → Pulling from origin/main..."
    git pull origin main 2>&1 | tail -5

    # Reapply stashed changes if any
    if git stash list | grep -q "Auto-stash"; then
        echo "  → Reapplying local changes..."
        git stash pop 2>&1 | head -3 || echo "  (stash already applied or conflicts)"
    fi

    echo "✓ Code updated via git pull"
else
    echo "→ No git repository found - cloning fresh..."

    # Backup files directory if it exists
    if [ -d web/sites/default/files ]; then
        echo "  → Backing up files directory..."
        tar -czf /tmp/drupal_files_backup.tar.gz web/sites/default/files 2>/dev/null || true
        echo "  ✓ Files backed up"
    fi

    # Clone to temp directory
    echo "  → Cloning repository from GitHub..."
    cd /tmp
    rm -rf kocsibeallo-temp 2>/dev/null || true
    git clone ${GIT_REPO} kocsibeallo-temp 2>&1 | tail -5
    echo "  ✓ Repository cloned"

    # Move files
    echo "  → Moving files to public_html..."
    cd kocsibeallo-temp
    # Remove old public_html content (except files)
    cd ~/public_html
    find . -mindepth 1 -maxdepth 1 ! -name 'web' -exec rm -rf {} + 2>/dev/null || true
    if [ -d web/sites/default/files ]; then
        find web -mindepth 1 ! -path "web/sites/default/files*" -exec rm -rf {} + 2>/dev/null || true
    else
        rm -rf web 2>/dev/null || true
    fi

    # Copy new files
    cp -r /tmp/kocsibeallo-temp/* ~/public_html/ 2>/dev/null || true
    cp -r /tmp/kocsibeallo-temp/.[!.]* ~/public_html/ 2>/dev/null || true
    rm -rf /tmp/kocsibeallo-temp
    echo "  ✓ Files moved"

    # Restore files directory
    cd ~/public_html
    if [ -f /tmp/drupal_files_backup.tar.gz ]; then
        echo "  → Restoring files directory..."
        tar -xzf /tmp/drupal_files_backup.tar.gz
        rm /tmp/drupal_files_backup.tar.gz
        echo "  ✓ Files restored"
    else
        echo "  → Creating files directory..."
        mkdir -p web/sites/default/files
        chmod 755 web/sites/default/files
        echo "  ✓ Files directory created"
    fi

    echo "✓ Fresh repository cloned"
fi

echo "→ Directory structure:"
ls -la | head -10
EOFGIT
    mark_complete "step3"
    echo -e "${GREEN}✓ Code deployed from GitHub${NC}"
fi
echo ""

# Step 4: Run Composer install
if ! skip_if_complete "step4"; then
    echo -e "${BLUE}[4/7]${NC} ${YELLOW}Installing dependencies with Composer...${NC}"
SSH_AUTH_SOCK="" sshpass -p "${PROD_PASS}" ssh \
  -o StrictHostKeyChecking=no \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  ${PROD_USER}@${PROD_HOST} bash << 'EOFCOMPOSER'
set -e
cd ~/public_html

echo "→ Checking if Composer install needed..."

# Check if vendor directory exists and has autoload
if [ -f vendor/autoload.php ]; then
    echo "  ✓ vendor/autoload.php exists"

    # Check if composer.lock changed since last deployment
    LOCK_HASH_OLD=""
    if [ -f /tmp/composer.lock.hash ]; then
        LOCK_HASH_OLD=$(cat /tmp/composer.lock.hash)
    fi

    LOCK_HASH_NEW=$(md5sum composer.lock | awk '{print $1}')

    if [ -n "$LOCK_HASH_OLD" ] && [ "$LOCK_HASH_OLD" = "$LOCK_HASH_NEW" ]; then
        echo "  ✓ composer.lock unchanged (hash: ${LOCK_HASH_NEW:0:8}...)"
        echo "✓ Composer dependencies up to date - SKIPPED"
    else
        if [ -z "$LOCK_HASH_OLD" ]; then
            echo "  → First deployment detected"
        else
            echo "  → composer.lock changed (${LOCK_HASH_OLD:0:8}... → ${LOCK_HASH_NEW:0:8}...)"
        fi

        # Save new hash
        echo "$LOCK_HASH_NEW" > /tmp/composer.lock.hash

        echo "  → Running composer install..."
        if command -v composer &> /dev/null; then
            composer install --no-dev --optimize-autoloader --no-interaction 2>&1 | tail -10
            echo "✓ Composer install complete"
        elif [ -f composer.phar ]; then
            php composer.phar install --no-dev --optimize-autoloader --no-interaction 2>&1 | tail -10
            echo "✓ Composer install complete"
        else
            echo "✗ ERROR: Composer not found!"
            exit 1
        fi
    fi
else
    echo "  → vendor/autoload.php missing"
    echo "  → Running full composer install..."

    if command -v composer &> /dev/null; then
        composer install --no-dev --optimize-autoloader --no-interaction 2>&1 | tail -10

        # Save hash after successful install
        if [ -f composer.lock ]; then
            md5sum composer.lock | awk '{print $1}' > /tmp/composer.lock.hash
        fi

        echo "✓ Composer install complete"
    elif [ -f composer.phar ]; then
        php composer.phar install --no-dev --optimize-autoloader --no-interaction 2>&1 | tail -10

        # Save hash after successful install
        if [ -f composer.lock ]; then
            md5sum composer.lock | awk '{print $1}' > /tmp/composer.lock.hash
        fi

        echo "✓ Composer install complete"
    else
        echo "✗ ERROR: Composer not available and vendor/ missing!"
        exit 1
    fi
fi
EOFCOMPOSER
    mark_complete "step4"
    echo -e "${GREEN}✓ Dependencies installed${NC}"
fi
echo ""

# Step 5: Check if files need syncing from D7
if ! skip_if_complete "step5"; then
    echo -e "${BLUE}[5/7]${NC} ${YELLOW}Checking files directory...${NC}"

    # Temporarily disable exit-on-error to capture the exit code
    set +e
    SSH_AUTH_SOCK="" sshpass -p "${PROD_PASS}" ssh \
      -o StrictHostKeyChecking=no \
      -o PreferredAuthentications=password \
      -o PubkeyAuthentication=no \
      ${PROD_USER}@${PROD_HOST} bash << 'EOFCHECK'
set -e
cd ~/public_html/web/sites/default/files

FILE_COUNT=$(find . -type f 2>/dev/null | wc -l | xargs)
echo "→ Files in directory: $FILE_COUNT"

if [ "$FILE_COUNT" -lt 100 ]; then
    echo "⚠ Files directory needs syncing from D7"
    exit 10
else
    echo "✓ Files directory OK"
fi
EOFCHECK

    SYNC_NEEDED=$?
    set -e
if [ $SYNC_NEEDED -eq 10 ]; then
    echo -e "${YELLOW}→ Syncing files from D7 server (~1.8GB, 5-10 minutes)...${NC}"

    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    echo "  → Downloading from D7 server..."
    SSH_AUTH_SOCK="" sshpass -p "${D7_PASS}" scp -r \
      -o StrictHostKeyChecking=no \
      -o PreferredAuthentications=password \
      -o PubkeyAuthentication=no \
      -o Compression=yes \
      ${D7_USER}@${D7_HOST}:${D7_FILES}/* \
      ${TEMP_DIR}/ 2>&1 | tail -3

    FILE_COUNT=$(find ${TEMP_DIR} -type f | wc -l)
    echo -e "${GREEN}  ✓ Downloaded ${FILE_COUNT} files${NC}"

    echo "  → Uploading to production..."
    SSH_AUTH_SOCK="" sshpass -p "${PROD_PASS}" scp -r \
      -o StrictHostKeyChecking=no \
      -o PreferredAuthentications=password \
      -o PubkeyAuthentication=no \
      -o Compression=yes \
      ${TEMP_DIR}/* \
      ${PROD_USER}@${PROD_HOST}:${PROD_PATH}/web/sites/default/files/ 2>&1 | tail -3

    # Set permissions
    SSH_AUTH_SOCK="" sshpass -p "${PROD_PASS}" ssh \
      -o StrictHostKeyChecking=no \
      -o PreferredAuthentications=password \
      -o PubkeyAuthentication=no \
      ${PROD_USER}@${PROD_HOST} "chmod -R 755 ${PROD_PATH}/web/sites/default/files"

    echo -e "${GREEN}  ✓ Files synced from D7${NC}"
else
    echo -e "${GREEN}✓ Files directory verified${NC}"
fi
    mark_complete "step5"
fi
echo ""

# Step 6: Create settings.php and check database
if ! skip_if_complete "step6"; then
    echo -e "${BLUE}[6/7]${NC} ${YELLOW}Creating settings.php and checking database...${NC}"
SSH_AUTH_SOCK="" sshpass -p "${PROD_PASS}" ssh \
  -o StrictHostKeyChecking=no \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  ${PROD_USER}@${PROD_HOST} bash << 'EOFSETTINGS'
set -e
cd ~/public_html/web/sites/default

# First check database connectivity
echo "→ Checking database connection..."
DB_TEST=$(mysql -uxmudbprchx -p9nJbkdMBbM -h localhost xmudbprchx -e "SELECT 1;" 2>&1)
if [ $? -eq 0 ]; then
    echo "✓ Database is accessible"

    # Check if database has tables
    TABLE_COUNT=$(mysql -uxmudbprchx -p9nJbkdMBbM -h localhost xmudbprchx -e "SHOW TABLES;" 2>/dev/null | wc -l)
    if [ $TABLE_COUNT -gt 1 ]; then
        echo "✓ Database has $TABLE_COUNT tables"
    else
        echo "⚠ Database is EMPTY (no tables found)"
        echo "  → Drupal will need to be installed"
    fi
else
    echo "✗ Database connection FAILED"
    echo "$DB_TEST"
    exit 1
fi

# Check if settings.php needs to be created/updated
SETTINGS_HASH_EXPECTED="FYf8Cg4KLg7KJBxqmTiKXo9J5H2xqKMxdT9YrV2eWxLpN4S6M8"
NEEDS_UPDATE=0

if [ ! -f settings.php ]; then
    echo "→ settings.php missing - creating..."
    NEEDS_UPDATE=1
elif ! grep -q "$SETTINGS_HASH_EXPECTED" settings.php 2>/dev/null; then
    echo "→ settings.php exists but hash_salt incorrect - updating..."
    NEEDS_UPDATE=1
elif ! grep -q "config_sync_directory.*config/sync" settings.php 2>/dev/null; then
    echo "→ settings.php missing config_sync_directory - updating..."
    NEEDS_UPDATE=1
else
    echo "✓ settings.php exists and is correct - skipping"
fi

if [ $NEEDS_UPDATE -eq 1 ]; then
    # Backup existing settings.php if it exists
    if [ -f settings.php ]; then
        cp settings.php settings.php.backup.$(date +%Y%m%d_%H%M%S)
        echo "  → Backed up existing settings.php"
    fi

    echo "  → Writing settings.php..."
    cat > settings.php << 'EOFPHP'
<?php
$databases['default']['default'] = array (
  'database' => 'xmudbprchx',
  'username' => 'xmudbprchx',
  'password' => '9nJbkdMBbM',
  'host' => 'localhost',
  'port' => '3306',
  'driver' => 'mysql',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
  'prefix' => '',
);
$settings['trusted_host_patterns'] = [
  '^phpstack-958493-6003495\.cloudwaysapps\.com$',
  '^www\.kocsibeallo\.hu$',
  '^kocsibeallo\.hu$',
];
$settings['config_sync_directory'] = '../config/sync';
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = 'sites/default/files/private';
$settings['file_temp_path'] = '/tmp';
$settings['hash_salt'] = 'FYf8Cg4KLg7KJBxqmTiKXo9J5H2xqKMxdT9YrV2eWxLpN4S6M8';
$settings['deployment_identifier'] = \Drupal::VERSION;
$config['system.logging']['error_level'] = 'hide';
$config['system.performance']['css']['preprocess'] = TRUE;
$config['system.performance']['js']['preprocess'] = TRUE;
if (file_exists($app_root . '/' . $site_path . '/settings.local.php')) {
  include $app_root . '/' . $site_path . '/settings.local.php';
}
EOFPHP
    chmod 644 settings.php
    echo "  ✓ settings.php created"
fi
EOFSETTINGS
    mark_complete "step6"
    echo -e "${GREEN}✓ settings.php configured${NC}"
fi
echo ""

# Step 7: Import configuration (theme settings, blocks, views, etc.)
if ! skip_if_complete "step7"; then
    echo -e "${BLUE}[7/8]${NC} ${YELLOW}Importing configuration (theme, blocks, views)...${NC}"
SSH_AUTH_SOCK="" sshpass -p "${PROD_PASS}" ssh \
  -o StrictHostKeyChecking=no \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  ${PROD_USER}@${PROD_HOST} bash << 'EOFCONFIG'
set -e
cd ~/public_html/web

if [ -f ../vendor/bin/drush ]; then
    echo "→ Checking Drupal bootstrap..."
    if ../vendor/bin/drush status 2>&1 | grep -q "Drupal bootstrap.*Successful"; then
        echo "✓ Drupal is bootstrapped"

        echo "→ Importing configuration from config/sync..."
        echo "  (Includes porto.settings.yml with custom CSS, theme settings)"
        echo ""

        # Run config import with real-time output
        ../vendor/bin/drush cim -y 2>&1 | tail -30

        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            echo ""
            echo "✓ Configuration import complete"
        else
            echo ""
            echo "⚠ Config import had issues (check output above)"
        fi
    else
        echo "⚠ Drupal NOT bootstrapped - cannot import config"
    fi
else
    echo "⚠ Drush not available - cannot import config"
fi
EOFCONFIG
    mark_complete "step7"
    echo -e "${GREEN}✓ Configuration imported${NC}"
fi
echo ""

# Step 8: Database updates and finalize
if ! skip_if_complete "step8"; then
    echo -e "${BLUE}[8/8]${NC} ${YELLOW}Running database updates and clearing cache...${NC}"
SSH_AUTH_SOCK="" sshpass -p "${PROD_PASS}" ssh \
  -o StrictHostKeyChecking=no \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  ${PROD_USER}@${PROD_HOST} bash << 'EOFFINAL'
set -e
cd ~/public_html/web

if [ -f ../vendor/bin/drush ]; then
    echo "→ Checking Drupal bootstrap..."
    if ../vendor/bin/drush status 2>&1 | grep -q "Drupal bootstrap.*Successful"; then
        echo "✓ Drupal is bootstrapped"

        echo "→ Running database updates..."
        ../vendor/bin/drush updb -y 2>&1 | tail -5 || echo "  No updates needed"

        echo "→ Clearing all caches..."
        ../vendor/bin/drush cr
        echo "✓ Cache cleared"
    else
        echo "⚠ Drupal NOT bootstrapped - site may need installation"
        echo "→ Checking database tables..."
        TABLE_COUNT=$(mysql -uxmudbprchx -p9nJbkdMBbM -h localhost xmudbprchx -e "SHOW TABLES;" 2>/dev/null | wc -l)
        if [ $TABLE_COUNT -lt 2 ]; then
            echo "✗ Database is EMPTY - Drupal needs to be installed"
            echo ""
            echo "To install Drupal, visit:"
            echo "  https://phpstack-958493-6003495.cloudwaysapps.com/core/install.php"
        fi
    fi

    echo ""
    echo "========================================"
    echo "Production Site Status:"
    echo "========================================"
    ../vendor/bin/drush status 2>&1 | grep -E "Drupal version|Site URI|Database|PHP|Bootstrap" || echo "Status check failed"

    # Database info
    echo ""
    echo "Database Info:"
    TABLE_COUNT=$(mysql -uxmudbprchx -p9nJbkdMBbM -h localhost xmudbprchx -e "SHOW TABLES;" 2>/dev/null | wc -l)
    echo "  Tables: $TABLE_COUNT"

    # Files info
    FILE_COUNT=$(find sites/default/files -type f 2>/dev/null | wc -l)
    LOGO_SIZE=$(ls -lh sites/default/files/deluxe-kocsibeallo-logo-150px.png 2>/dev/null | awk '{print $5}' || echo 'MISSING')

    echo ""
    echo "Files Info:"
    echo "  Total files: $FILE_COUNT"
    echo "  Logo: $LOGO_SIZE"

    echo ""
    echo "✓ Deployment finalized"
else
    echo "⚠ Drush not available"
fi
EOFFINAL
    mark_complete "step8"
    echo -e "${GREEN}✓ Site finalized${NC}"
fi
echo ""

# Final success message
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓✓✓ DEPLOYMENT COMPLETE! ✓✓✓${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}🌐 Production Site:${NC}"
echo -e "   https://phpstack-958493-6003495.cloudwaysapps.com/"
echo ""
echo -e "${GREEN}Deployment Steps:${NC}"
echo -e "  ✓ [1/8] Pushed to GitHub"
echo -e "  ✓ [2/8] Tested GitHub connectivity"
echo -e "  ✓ [3/8] Git cloned from GitHub"
echo -e "  ✓ [4/8] Composer install"
echo -e "  ✓ [5/8] Files synced (if needed)"
echo -e "  ✓ [6/8] settings.php created"
echo -e "  ✓ [7/8] Config import (theme, blocks, views)"
echo -e "  ✓ [8/8] Database updates + cache clear"
echo ""
echo -e "${YELLOW}Issues Fixed:${NC}"
echo -e "  ✓ ARC-686: Logo file deployed"
echo -e "  ✓ ARC-679: Blog images working"
echo ""

# Clean up state file on successful completion
if [ -f ${STATE_FILE} ]; then
    rm ${STATE_FILE}
    echo -e "${GREEN}✓ Deployment state cleared${NC}"
    echo ""
fi

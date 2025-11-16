#!/bin/bash
# Cloudways Production Deployment Script
# Run this directly on the Cloudways server via SSH (Termius)
#
# Usage:
#   1. SSH into Cloudways via Termius: ssh kocsid10ssh@165.22.200.254 -p 22
#   2. Navigate to application directory
#   3. Run this script
#
# Date: 2025-11-16
# Production URL: https://phpstack-969836-6003258.cloudwaysapps.com

set -e  # Exit on any error

echo "=============================================="
echo "Cloudways Production Deployment - FULL SETUP"
echo "=============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Verify directory and Git deployment
echo -e "${YELLOW}Step 1: Verifying directory structure...${NC}"
pwd
echo ""
echo "Contents:"
ls -la
echo ""

# Step 2: Check if code exists
echo -e "${YELLOW}Step 2: Checking if Git code is deployed...${NC}"
if [ -f "composer.json" ]; then
    echo -e "${GREEN}✓ Drupal application found (composer.json exists)${NC}"
else
    echo -e "${RED}✗ Drupal application not found (composer.json missing)!${NC}"
    echo "Please deploy code via Cloudways > Deployment Via Git > Pull"
    exit 1
fi

# Step 3: Install Composer dependencies
echo -e "${YELLOW}Step 3: Installing Composer dependencies...${NC}"

echo "Running: composer install --no-dev --optimize-autoloader"
composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

if [ ! -f "vendor/bin/drush" ]; then
    echo -e "${RED}✗ Drush not found after composer install!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Composer dependencies installed${NC}"
echo ""

# Step 4: Create required directories
echo -e "${YELLOW}Step 4: Creating required directories...${NC}"
mkdir -p web/sites/default/files
mkdir -p web/sites/default/files/private
chmod 777 web/sites/default/files
chmod 777 web/sites/default/files/private
echo -e "${GREEN}✓ Directories created${NC}"
echo ""

# Step 5: Update settings.php
echo -e "${YELLOW}Step 5: Checking settings.php configuration...${NC}"
cd web/sites/default

# Backup settings.php if not already backed up
if [ ! -f "settings.php.backup" ]; then
    echo "Creating backup of settings.php..."
    cp settings.php settings.php.backup
fi

echo -e "${YELLOW}Please verify settings.php contains:${NC}"
echo "  - Database credentials: wdzpzmmtxg / fyQuAvP74q"
echo "  - Redis credentials: localhost:6379 / ccp5TKzJx4"
echo "  - Config sync: ../config/sync"
echo "  - Trusted hosts: phpstack-969836-6003258.cloudwaysapps.com"
echo ""
echo -e "${YELLOW}Press Enter when settings.php is ready, or Ctrl+C to edit it first${NC}"
read -r

cd ../../  # Back to app root

# Step 6: Import database
echo -e "${YELLOW}Step 6: Database Import${NC}"
echo "Do you have a database dump to import? (y/n)"
read -r import_db

if [ "$import_db" = "y" ]; then
    echo "Enter the full path to your database dump file:"
    read -r db_dump_path

    if [ -f "$db_dump_path" ]; then
        echo "Importing database..."
        mysql -u wdzpzmmtxg -pfyQuAvP74q wdzpzmmtxg < "$db_dump_path"
        echo -e "${GREEN}✓ Database imported${NC}"
    else
        echo -e "${RED}✗ Database dump file not found: $db_dump_path${NC}"
        echo "Skipping database import. You'll need to import it manually."
    fi
else
    echo "Skipping database import."
fi
echo ""

# Step 7: Enable Redis module
echo -e "${YELLOW}Step 7: Enabling Redis module...${NC}"
cd web
../vendor/bin/drush en redis -y || echo "Redis module may already be enabled"
echo -e "${GREEN}✓ Redis module enabled${NC}"
echo ""

# Step 8: Import configuration
echo -e "${YELLOW}Step 8: Importing Drupal configuration...${NC}"
echo "Checking if config sync directory exists..."
if [ -d "../config/sync" ]; then
    echo "Config directory found with $(ls -1 ../config/sync/*.yml 2>/dev/null | wc -l) files"
    ../vendor/bin/drush config:import -y --source=../config/sync
    echo -e "${GREEN}✓ Configuration imported${NC}"
else
    echo -e "${YELLOW}⚠ Config sync directory not found. Skipping config import.${NC}"
fi
echo ""

# Step 9: Run database updates
echo -e "${YELLOW}Step 9: Running database updates...${NC}"
../vendor/bin/drush updatedb -y
echo -e "${GREEN}✓ Database updates complete${NC}"
echo ""

# Step 10: Clear cache
echo -e "${YELLOW}Step 10: Clearing cache...${NC}"
../vendor/bin/drush cr
echo -e "${GREEN}✓ Cache cleared${NC}"
echo ""

# Step 11: Rebuild cache
echo -e "${YELLOW}Step 11: Rebuilding cache...${NC}"
../vendor/bin/drush cache:rebuild
echo -e "${GREEN}✓ Cache rebuilt${NC}"
echo ""

# Step 12: Set proper permissions
echo -e "${YELLOW}Step 12: Setting file permissions...${NC}"
# Already at app root
chmod -R 755 web/
chmod -R 777 web/sites/default/files/
echo -e "${GREEN}✓ Permissions set${NC}"
echo ""

# Step 13: Get admin login link
echo -e "${YELLOW}Step 13: Generating admin login link...${NC}"
cd web
ADMIN_LINK=$(../vendor/bin/drush uli)
echo -e "${GREEN}✓ Admin login link:${NC}"
echo "$ADMIN_LINK"
echo ""

# Step 14: Check site status
echo -e "${YELLOW}Step 14: Checking site status...${NC}"
../vendor/bin/drush status
echo ""

# Final summary
echo "=============================================="
echo -e "${GREEN}DEPLOYMENT COMPLETE!${NC}"
echo "=============================================="
echo ""
echo "Production Site: https://phpstack-969836-6003258.cloudwaysapps.com"
echo "Admin Login: $ADMIN_LINK"
echo ""
echo "Next steps:"
echo "  1. Visit the site URL above"
echo "  2. Use the admin login link to access admin panel"
echo "  3. Verify all functionality works correctly"
echo "  4. Test webforms, blog posts, gallery"
echo "  5. Check Redis is working: drush cr should be fast"
echo ""
echo "=============================================="

#!/bin/bash

##
# Update Deployment Script
# Use this for deploying updates to an existing installation
# Does NOT import database - only updates code and configuration
##

set -e  # Exit on error

echo "================================================"
echo "Kocsibeallo.hu - Update Deployment"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${GREEN}==>${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

# Check if we're in the project root
if [ ! -f "docker-compose.d10.yml" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Check if containers are running
if ! docker ps | grep -q "pajfrsyfzm-d10-cli"; then
    print_error "Drupal 10 containers are not running!"
    echo "  Start them with: docker-compose -f docker-compose.d10.yml up -d"
    exit 1
fi

# Step 1: Pull latest changes
print_step "Step 1/7: Pulling latest changes from Git..."
git pull origin main

if [ $? -ne 0 ]; then
    print_error "Git pull failed! Please resolve any conflicts."
    exit 1
fi

# Step 2: Update Composer dependencies
print_step "Step 2/7: Updating Composer dependencies..."
cd drupal10
composer install --no-interaction --prefer-dist --optimize-autoloader
cd ..

# Step 3: Put site in maintenance mode
print_step "Step 3/7: Putting site in maintenance mode..."
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush state:set system.maintenance_mode 1 --input-format=integer"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"

# Step 4: Import configuration
print_step "Step 4/7: Importing configuration changes..."
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:import -y"

if [ $? -ne 0 ]; then
    print_warning "Configuration import had errors. Check the output above."
    read -p "Continue with deployment? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
        print_error "Deployment cancelled. Site is still in maintenance mode!"
        exit 1
    fi
fi

# Step 5: Run database updates
print_step "Step 5/7: Running database updates..."
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush updatedb -y"

# Step 6: Clear cache
print_step "Step 6/7: Clearing cache..."
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"

# Step 7: Take site out of maintenance mode
print_step "Step 7/7: Taking site out of maintenance mode..."
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush state:set system.maintenance_mode 0 --input-format=integer"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"

# Display success message
echo ""
echo "================================================"
echo -e "${GREEN}✓ Update Deployment Complete!${NC}"
echo "================================================"
echo ""
echo "📊 Site Status:"
echo "  - Drupal 10 Site: http://localhost:8090"
echo "  - Maintenance Mode: OFF"
echo ""
echo "🎯 What was updated:"
echo "  ✓ Code pulled from Git"
echo "  ✓ Composer dependencies updated"
echo "  ✓ Configuration imported"
echo "  ✓ Database updates applied"
echo "  ✓ Cache cleared"
echo ""
echo "📚 Verify deployment:"
echo "  1. Check site at http://localhost:8090"
echo "  2. Test affected functionality"
echo "  3. Review any error logs"
echo ""
echo "If issues occur:"
echo "  - Check logs: drush watchdog:show"
echo "  - Check status: drush status"
echo "  - See: docs/DEPLOYMENT_GUIDE.md"
echo ""

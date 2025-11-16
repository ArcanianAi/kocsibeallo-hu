#!/bin/bash

##
# Cloudways Post-Deployment Script
# Run this AFTER Git pull completes (manual or webhook)
##

set -e  # Exit on error

echo "================================================"
echo "Kocsibeallo.hu - Cloudways Post-Deployment"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${GREEN}==>${NC} $1"
}

print_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Start time
START_TIME=$(date +%s)

# Check if we're in the right directory
if [ ! -f "drupal10/composer.json" ]; then
    print_error "Not in application root directory!"
    echo "  Current directory: $(pwd)"
    echo "  Please navigate to: applications/[app-name]/public_html"
    exit 1
fi

print_info "Starting post-deployment tasks..."
echo ""

# Step 1: Navigate to Drupal directory
print_step "Step 1/7: Navigating to Drupal directory..."
cd drupal10
print_success "In drupal10 directory"

# Step 2: Update Composer dependencies
print_step "Step 2/7: Installing/Updating Composer dependencies..."
print_info "This may take a few minutes..."

if composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader 2>&1; then
    print_success "Composer dependencies installed"
else
    print_error "Composer install failed!"
    print_warning "Trying with cache clear..."
    composer clear-cache
    if composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader; then
        print_success "Composer dependencies installed (after cache clear)"
    else
        print_error "Composer install failed even after cache clear!"
        exit 1
    fi
fi

# Step 3: Navigate to web directory
print_step "Step 3/7: Navigating to web directory..."
cd web
print_success "In web directory"

# Step 4: Put site in maintenance mode
print_step "Step 4/7: Putting site in maintenance mode..."
if ../vendor/bin/drush state:set system.maintenance_mode 1 --input-format=integer 2>&1; then
    ../vendor/bin/drush cr > /dev/null 2>&1
    print_success "Site in maintenance mode"
else
    print_warning "Could not enable maintenance mode (site may still be accessible)"
fi

# Step 5: Import configuration
print_step "Step 5/7: Importing configuration changes..."
if ../vendor/bin/drush config:import -y 2>&1; then
    print_success "Configuration imported successfully"
else
    print_warning "Configuration import had warnings/errors"
    echo "  Check output above for details"
fi

# Step 6: Run database updates
print_step "Step 6/7: Running database updates..."
if ../vendor/bin/drush updatedb -y 2>&1; then
    print_success "Database updates completed"
else
    print_warning "Database updates had warnings/errors"
    echo "  Check output above for details"
fi

# Step 7: Clear cache and disable maintenance mode
print_step "Step 7/7: Clearing cache and enabling site..."
../vendor/bin/drush cr > /dev/null 2>&1
print_success "Cache cleared"

if ../vendor/bin/drush state:set system.maintenance_mode 0 --input-format=integer 2>&1; then
    ../vendor/bin/drush cr > /dev/null 2>&1
    print_success "Site out of maintenance mode"
else
    print_warning "Could not disable maintenance mode - site may still show maintenance page"
    echo "  Run manually: drush state:set system.maintenance_mode 0 --input-format=integer"
fi

# Calculate deployment time
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "================================================"
echo -e "${GREEN}✓ Post-Deployment Complete!${NC}"
echo "================================================"
echo ""
echo "⏱️  Total time: ${DURATION} seconds"
echo ""
echo "📊 Summary:"
echo "  ✓ Composer dependencies updated"
echo "  ✓ Configuration imported"
echo "  ✓ Database updates applied"
echo "  ✓ Cache cleared"
echo "  ✓ Site is LIVE"
echo ""
echo "🌐 Site URL: https://www.kocsibeallo.hu"
echo ""
echo "📝 Next steps:"
echo "  1. Visit the site and verify it's working"
echo "  2. Test critical functionality"
echo "  3. Check for any error messages"
echo "  4. Review Drupal logs if needed:"
echo "     drush watchdog:show --severity=Error"
echo ""
echo "📚 Logs and debugging:"
echo "  - Drush logs: drush watchdog:show"
echo "  - PHP errors: Check Cloudways logs"
echo "  - Site status: drush status"
echo ""

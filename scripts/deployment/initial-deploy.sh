#!/bin/bash

##
# Initial Deployment Script
# Use this ONLY for first-time deployment when setting up from scratch
# This includes database import
##

set -e  # Exit on error

echo "================================================"
echo "Kocsibeallo.hu - Initial Deployment"
echo "================================================"
echo ""
echo "⚠️  This script is for FIRST-TIME deployment only!"
echo "    If updating an existing installation, use update-deploy.sh"
echo ""
read -p "Continue with initial deployment? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

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

# Step 1: Install Composer dependencies
print_step "Step 1/8: Installing Composer dependencies..."
cd drupal10
if [ ! -f "composer.json" ]; then
    print_error "composer.json not found in drupal10/ directory"
    exit 1
fi

composer install --no-interaction --prefer-dist --optimize-autoloader
cd ..

# Step 2: Create necessary directories
print_step "Step 2/8: Creating necessary directories..."
mkdir -p drupal10/web/sites/default/files
mkdir -p drupal10/web/sites/default/files/private
chmod 777 drupal10/web/sites/default/files
chmod 777 drupal10/web/sites/default/files/private

# Step 3: Check for database dump
print_step "Step 3/8: Checking for database dump..."
DB_DUMP=""

if [ -f "database/drupal10.sql" ]; then
    DB_DUMP="database/drupal10.sql"
elif [ -f "database/latest.sql" ]; then
    DB_DUMP="database/latest.sql"
else
    print_warning "No database dump found in database/ directory"
    echo ""
    echo "  Please provide the path to your database dump file:"
    read -p "  Database dump path: " DB_DUMP

    if [ ! -f "$DB_DUMP" ]; then
        print_error "Database dump file not found: $DB_DUMP"
        exit 1
    fi
fi

print_step "Using database dump: $DB_DUMP"

# Step 4: Start Docker containers
print_step "Step 4/8: Starting Docker containers..."
docker-compose -f docker-compose.d10.yml up -d

# Wait for containers to be ready
print_step "Waiting for containers to start..."
sleep 15

# Wait for database to be healthy
print_step "Waiting for database to be ready..."
for i in {1..30}; do
    if docker exec pajfrsyfzm-d10-mariadb mysqladmin ping -h localhost -u drupal -pdrupal &> /dev/null; then
        echo "Database is ready!"
        break
    fi
    echo "Waiting for database... ($i/30)"
    sleep 2
done

# Step 5: Import database
print_step "Step 5/8: Importing database (this may take several minutes)..."

# Check if file is gzipped
if [[ "$DB_DUMP" == *.gz ]]; then
    print_step "Database dump is gzipped, decompressing during import..."
    gunzip < "$DB_DUMP" | docker exec -i pajfrsyfzm-d10-mariadb mysql -udrupal -pdrupal drupal10
else
    docker exec -i pajfrsyfzm-d10-mariadb mysql -udrupal -pdrupal drupal10 < "$DB_DUMP"
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Database imported successfully!"
else
    print_error "Database import failed!"
    exit 1
fi

# Step 6: Import configuration
print_step "Step 6/8: Importing Drupal configuration..."
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:import -y" || {
    print_warning "Configuration import had warnings (this is normal for initial deployment)"
}

# Step 7: Run database updates
print_step "Step 7/8: Running database updates..."
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush updatedb -y"

# Step 8: Clear cache
print_step "Step 8/8: Clearing cache..."
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"

# Optional: Copy files directory if it exists
echo ""
if [ -d "files-backup" ]; then
    print_step "Found files-backup directory. Copying files..."
    cp -R files-backup/* drupal10/web/sites/default/files/
    chmod -R 777 drupal10/web/sites/default/files/
    echo -e "${GREEN}✓${NC} Files copied successfully!"
else
    print_warning "No files-backup directory found"
    echo "  If you have uploaded files, copy them to:"
    echo "  drupal10/web/sites/default/files/"
fi

# Display success message
echo ""
echo "================================================"
echo -e "${GREEN}✓ Initial Deployment Complete!${NC}"
echo "================================================"
echo ""
echo "📊 Environment URLs:"
echo "  - Drupal 10 Site: http://localhost:8090"
echo "  - Admin Login:    http://localhost:8090/user/login"
echo "  - phpMyAdmin:     http://localhost:8082"
echo ""
echo "🔑 Default Admin Credentials:"
echo "  - Username: admin"
echo "  - Password: admin123"
echo "  ⚠️  CHANGE THIS PASSWORD IMMEDIATELY!"
echo ""
echo "📚 Documentation:"
echo "  - Deployment Guide: docs/DEPLOYMENT_GUIDE.md"
echo "  - Environment URLs: docs/ENVIRONMENT_URLS.md"
echo ""
echo "🎯 Next Steps:"
echo "  1. Access the site at http://localhost:8090"
echo "  2. Log in and change the admin password"
echo "  3. Verify all content is displaying correctly"
echo "  4. Test webforms and functionality"
echo ""
echo "For updates, use: ./scripts/deployment/update-deploy.sh"
echo ""

#!/bin/bash

##
# Initial Setup Script
# Runs after cloning the repository to set up the Drupal 10 environment
##

set -e  # Exit on error

echo "================================================"
echo "Kocsibeallo.hu - Drupal 10 Setup Script"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
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
print_step "Installing Composer dependencies..."
cd drupal10
if [ ! -f "composer.json" ]; then
    print_error "composer.json not found in drupal10/ directory"
    exit 1
fi

composer install --no-interaction --prefer-dist --optimize-autoloader
cd ..

# Step 2: Create necessary directories
print_step "Creating necessary directories..."
mkdir -p drupal10/web/sites/default/files
chmod 777 drupal10/web/sites/default/files

# Step 3: Copy settings file if needed
if [ ! -f "drupal10/web/sites/default/settings.php" ]; then
    print_warning "settings.php not found, you'll need to configure it manually"
fi

# Step 4: Start Docker containers
print_step "Starting Docker containers..."
docker-compose -f docker-compose.d10.yml up -d

# Wait for containers to be ready
print_step "Waiting for containers to start..."
sleep 10

# Step 5: Check if database exists
print_step "Checking database..."
DB_EXISTS=$(docker exec pajfrsyfzm-d10-db mysql -udrupal -pdrupal -e "SHOW DATABASES LIKE 'drupal10';" | grep -c "drupal10" || true)

if [ "$DB_EXISTS" -eq 0 ]; then
    print_warning "Database 'drupal10' does not exist"
    print_warning "You need to import a database dump"
    echo ""
    echo "  docker exec -i pajfrsyfzm-d10-db mysql -udrupal -pdrupal drupal10 < /path/to/dump.sql"
    echo ""
fi

# Step 6: Import configuration (if database exists)
if [ "$DB_EXISTS" -gt 0 ]; then
    print_step "Importing configuration..."
    docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:import -y" || true

    print_step "Running database updates..."
    docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush updatedb -y" || true

    print_step "Clearing cache..."
    docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"
fi

# Step 7: Display environment info
echo ""
echo "================================================"
echo -e "${GREEN}Setup Complete!${NC}"
echo "================================================"
echo ""
echo "📊 Environment URLs:"
echo "  - Drupal 10 Site: http://localhost:8090"
echo "  - phpMyAdmin:     http://localhost:8082"
echo "  - Database:       localhost:8306"
echo ""
echo "🔑 Database Credentials:"
echo "  - Database: drupal10"
echo "  - User:     drupal"
echo "  - Password: drupal"
echo ""

if [ "$DB_EXISTS" -eq 0 ]; then
    echo "⚠️  NEXT STEPS:"
    echo "  1. Import database dump"
    echo "  2. Import configuration: drush config:import"
    echo "  3. Clear cache: drush cr"
    echo ""
fi

echo "📚 Documentation: docs/ENVIRONMENT_URLS.md"
echo ""

#!/bin/bash

# Fix Sitemap - Enable all content types and regenerate
# Run this script ON THE PRODUCTION SERVER

set -e

echo "🔧 Fixing sitemap configuration..."
echo ""

cd ~/public_html/web

# Import sitemap bundle settings from config
echo "📥 Importing sitemap configuration for all content types..."
../vendor/bin/drush config:import --partial --source=../config/sync -y

echo ""
echo "✅ Sitemap configuration imported:"
echo "   - article (blog posts) - priority 0.7"
echo "   - foto_a_galeriahoz (gallery pages) - priority 0.8"
echo "   - page (basic pages) - priority 0.6"
echo "   - webform (forms) - priority 0.5"

echo ""
echo "🔄 Regenerating sitemap (this may take a minute)..."
../vendor/bin/drush simple-sitemap:generate

echo ""
echo "✅ Sitemap fix complete!"
echo ""
echo "Verify: https://phpstack-958493-6003495.cloudwaysapps.com/sitemap.xml"
echo "Expected: 200+ URLs (was 1)"
echo ""
echo "Check URL count:"
echo '  curl -s https://phpstack-958493-6003495.cloudwaysapps.com/sitemap.xml | grep -c "<loc>"'

#!/bin/bash

# Fix Sitemap - Enable all content types and regenerate
# Run this script ON THE PRODUCTION SERVER

set -e

echo "🔧 Fixing sitemap configuration..."
echo ""

cd ~/public_html/web

# Enable sitemap for all content types
echo "✅ Enabling sitemap for 'article' (blog posts)..."
../vendor/bin/drush simple-sitemap:settings entity:node:article --status=1 --priority=0.7 --changefreq=monthly

echo "✅ Enabling sitemap for 'foto_a_galeriahoz' (gallery pages)..."
../vendor/bin/drush simple-sitemap:settings entity:node:foto_a_galeriahoz --status=1 --priority=0.8 --changefreq=monthly

echo "✅ Enabling sitemap for 'page' (basic pages)..."
../vendor/bin/drush simple-sitemap:settings entity:node:page --status=1 --priority=0.6 --changefreq=yearly

echo "✅ Enabling sitemap for 'webform' (forms)..."
../vendor/bin/drush simple-sitemap:settings entity:node:webform --status=1 --priority=0.5 --changefreq=yearly

echo ""
echo "🔄 Regenerating sitemap (this may take a minute)..."
../vendor/bin/drush simple-sitemap:generate

echo ""
echo "📊 Checking sitemap status..."
../vendor/bin/drush simple-sitemap:status

echo ""
echo "✅ Sitemap fix complete!"
echo ""
echo "Verify: https://phpstack-958493-6003495.cloudwaysapps.com/sitemap.xml"
echo "Expected: 200+ URLs (was 1)"

#!/bin/bash
#
# Transfer files from old D7 server to new D10 production server
# Run this script ON THE NEW PRODUCTION SERVER (159.223.220.3)
#

set -e

echo "=== Drupal 7 to Drupal 10 File Transfer ==="
echo ""
echo "This will download all files from the old D7 server to the new production server"
echo ""

# Navigate to the files directory
cd public_html/web/sites/default/

# Create backup if files exist
if [ -d "files" ] && [ "$(ls -A files)" ]; then
    echo "Creating backup of existing files..."
    tar -czf files_backup_$(date +%Y%m%d_%H%M%S).tar.gz files/
fi

echo ""
echo "Starting SCP transfer from D7 server..."
echo "Source: kocsid10ssh@165.22.200.254:sites/default/files/"
echo "Target: $(pwd)/files/"
echo ""
echo "You will be prompted for the D7 server password: KCSIssH3497!"
echo ""

# SCP transfer
scp -r kocsid10ssh@165.22.200.254:sites/default/files/* files/

echo ""
echo "Setting correct permissions..."
chmod -R 755 files/
chown -R xmudbprchx:xmudbprchx files/

echo ""
echo "✅ File transfer complete!"
echo ""
echo "Files transferred to: $(pwd)/files/"
echo "Total size: $(du -sh files/ | cut -f1)"
echo ""
echo "Next steps:"
echo "1. Clear Drupal cache: cd web && ../vendor/bin/drush cr"
echo "2. Verify site at: https://phpstack-958493-6003495.cloudwaysapps.com/"

#!/bin/bash

# Migrate Private Files to Public (Content Images Only)
# Created: 2025-11-17
# Purpose: Move ONLY content article images from private:// to public://
#
# IMPORTANT: Webform attachments and other private files are NOT touched!
#
# Issue: D7 migration left some content images with private:// URIs but they are
#        referenced in HTML as public URLs, causing 404 errors
#
# This script:
# 1. Copies ONLY files that are embedded in node bodies (content articles)
# 2. Updates their database URIs from private:// to public://
# 3. Leaves webform attachments and other private files untouched
# 4. Sets correct permissions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Migrate Content Article Images to Public${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if running on D10 server
if [ ! -f ~/public_html/web/index.php ]; then
    echo -e "${RED}Error: This script must be run on the D10 production server${NC}"
    echo -e "${YELLOW}Expected path: ~/public_html/web/index.php${NC}"
    exit 1
fi

cd ~/public_html/web/sites/default/files

echo -e "${YELLOW}[1/6] Checking directories...${NC}"
if [ ! -d "private" ]; then
    echo -e "${RED}Error: private/ directory not found${NC}"
    exit 1
fi

PRIVATE_COUNT=$(ls -1 private/*.jpg private/*.jpeg private/*.png private/*.webp 2>/dev/null | wc -l || echo "0")
echo -e "${GREEN}✓ Found ${PRIVATE_COUNT} image files in private/ directory${NC}"
echo ""

echo -e "${YELLOW}[2/6] Creating backup of database...${NC}"
cd ~/public_html/web
BACKUP_TABLE="file_managed_backup_$(date +%Y%m%d_%H%M%S)"
../vendor/bin/drush sql-query "CREATE TABLE ${BACKUP_TABLE} AS SELECT * FROM file_managed WHERE uri LIKE 'private://%'"
BACKUP_COUNT=$(../vendor/bin/drush sql-query "SELECT COUNT(*) FROM ${BACKUP_TABLE}")
echo -e "${GREEN}✓ Backup created: ${BACKUP_TABLE} (${BACKUP_COUNT} rows)${NC}"
echo ""

echo -e "${YELLOW}[3/6] Finding content article images in node bodies...${NC}"
# Export list of filenames that are embedded in node bodies
../vendor/bin/drush sql-query "
SELECT DISTINCT SUBSTRING_INDEX(f.uri, '/', -1) as filename
FROM file_managed f
WHERE f.uri LIKE 'private://%'
AND f.uri NOT LIKE 'private://%/%'
AND EXISTS (
    SELECT 1 FROM node__body nb
    WHERE nb.body_value LIKE CONCAT('%', SUBSTRING_INDEX(f.uri, '/', -1), '%')
)
" > /tmp/content_images_to_migrate.txt

FOUND_COUNT=$(wc -l < /tmp/content_images_to_migrate.txt || echo "0")
echo -e "${GREEN}✓ Found ${FOUND_COUNT} content images to migrate${NC}"

if [ "$FOUND_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠ No content images found to migrate${NC}"
    echo -e "${YELLOW}⚠ This might mean:${NC}"
    echo "  - All images are already public://"
    echo "  - Or the query didn't find matches"
    exit 0
fi

echo ""
echo -e "${BLUE}Sample files to migrate:${NC}"
head -10 /tmp/content_images_to_migrate.txt
if [ "$FOUND_COUNT" -gt 10 ]; then
    echo "... and $((FOUND_COUNT - 10)) more"
fi
echo ""

echo -e "${YELLOW}[4/6] Copying content images from private/ to public/...${NC}"
cd ~/public_html/web/sites/default/files

COPIED=0
SKIPPED=0
while IFS= read -r filename; do
    # Skip empty lines and "filename" header
    if [ -z "$filename" ] || [ "$filename" = "filename" ]; then
        continue
    fi

    if [ -f "private/$filename" ]; then
        if [ ! -f "$filename" ]; then
            cp "private/$filename" "./$filename"
            COPIED=$((COPIED + 1))
        else
            SKIPPED=$((SKIPPED + 1))
        fi
    fi
done < /tmp/content_images_to_migrate.txt

echo -e "${GREEN}✓ Copied: ${COPIED} files${NC}"
if [ "$SKIPPED" -gt 0 ]; then
    echo -e "${YELLOW}⚠ Skipped: ${SKIPPED} files (already exist in public)${NC}"
fi
echo ""

echo -e "${YELLOW}[5/6] Updating database URIs for migrated files...${NC}"
cd ~/public_html/web

../vendor/bin/drush sql-query "
UPDATE file_managed f
SET uri = CONCAT('public://', SUBSTRING_INDEX(uri, '/', -1))
WHERE uri LIKE 'private://%'
AND uri NOT LIKE 'private://%/%'
AND EXISTS (
    SELECT 1 FROM node__body nb
    WHERE nb.body_value LIKE CONCAT('%', SUBSTRING_INDEX(f.uri, '/', -1), '%')
)
"

UPDATED=$(../vendor/bin/drush sql-query "
SELECT COUNT(*) FROM file_managed f
WHERE f.uri LIKE 'public://%'
AND f.uri NOT LIKE 'public://%/%'
AND EXISTS (
    SELECT 1 FROM node__body nb
    WHERE nb.body_value LIKE CONCAT('%', SUBSTRING_INDEX(f.uri, '/', -1), '%')
)
")
echo -e "${GREEN}✓ Updated ${UPDATED} database records to public://${NC}"
echo ""

echo -e "${YELLOW}[6/6] Setting file permissions...${NC}"
cd ~/public_html/web/sites/default/files
while IFS= read -r filename; do
    if [ -z "$filename" ] || [ "$filename" = "filename" ]; then
        continue
    fi
    if [ -f "$filename" ]; then
        chmod 644 "$filename"
    fi
done < /tmp/content_images_to_migrate.txt
echo -e "${GREEN}✓ Permissions set to 644${NC}"
echo ""

# Clean up temp file
rm -f /tmp/content_images_to_migrate.txt

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Migration Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "  - Files copied: ${COPIED}"
echo "  - Database records updated: ${UPDATED}"
echo "  - Backup table: ${BACKUP_TABLE}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Clear Drupal cache: cd ~/public_html/web && ../vendor/bin/drush cache:rebuild"
echo "2. Test affected pages to verify images load correctly"
echo "3. Check browser console for remaining 404 errors"
echo ""
echo -e "${GREEN}✓ Webform attachments remain private (not touched)${NC}"
echo -e "${YELLOW}Private files remain for safety. Remove after verification if needed.${NC}"
echo ""

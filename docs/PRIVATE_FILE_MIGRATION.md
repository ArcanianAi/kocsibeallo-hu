# Private File Migration Documentation

**Created**: 2025-11-17
**Issue**: Content article images stored as `private://` but referenced as public URLs

---

## Problem Description

### Symptoms:
- Content article pages show broken image icons
- Browser console shows 404 errors for image files
- Images like: `/sites/default/files/filename.jpg` return 404

### Root Cause:
During D7 to D10 migration, some content article images were imported with `private://` URI scheme in the database, but are embedded in HTML content as public URLs.

**Example**:
- **Database**: `uri = 'private://image-name.jpg'`
- **HTML in node body**: `<img src="/sites/default/files/image-name.jpg">`
- **Physical location**: `sites/default/files/private/image-name.jpg`
- **Browser tries**: `sites/default/files/image-name.jpg` → **404 Not Found**

---

## Solution Overview

Move ONLY content article images from `private://` to `public://` scheme:

1. ✅ **Copy files** from `private/` to root `sites/default/files/`
2. ✅ **Update database** URIs from `private://` to `public://`
3. ✅ **Preserve webform files** - keep them private
4. ✅ **Set permissions** to 644

---

## Affected Files

### Statistics (Local Development):
- **Total private:// files**: 940
- **Total private:// JPG files**: 634
- **Content article images found**: 5-20 (varies)
- **Webform attachments**: 0 (stay private if exist)

### Known Affected Content:
1. `/retegragasztott-fa-szerkezetu-kocsibeallo-szendvicspanel-fedessel`
   - 5 images (FID: 3804, 3805, 3806, 3807, 3808)

---

## Migration Script

### Script Location:
`scripts/migrate-private-files-to-public.sh`

### What It Does:
1. **Finds content images**: Queries database for files in node bodies
2. **Creates backup**: Backs up `file_managed` table before changes
3. **Copies files**: Only files embedded in content articles
4. **Updates database**: Changes URIs from `private://` to `public://`
5. **Sets permissions**: chmod 644 on migrated files
6. **Preserves webforms**: Leaves webform attachments private

### Safety Features:
- ✅ Creates database backup before changes
- ✅ Only processes files found in node bodies
- ✅ Skips files already in public directory
- ✅ Leaves original private files for verification
- ✅ **Never touches webform attachments**

---

## Running the Migration

### On Production Server:

```bash
# SSH to D10 production
ssh kocsid10ssh@159.223.220.3

# Navigate to project root
cd ~/public_html

# Make script executable
chmod +x scripts/migrate-private-files-to-public.sh

# Run migration
./scripts/migrate-private-files-to-public.sh

# Clear cache
cd web
../vendor/bin/drush cache:rebuild
```

### Expected Output:

```
========================================
Migrate Content Article Images to Public
========================================

[1/6] Checking directories...
✓ Found 145 image files in private/ directory

[2/6] Creating backup of database...
✓ Backup created: file_managed_backup_20251117_120000 (940 rows)

[3/6] Finding content article images in node bodies...
✓ Found 8 content images to migrate

Sample files to migrate:
deluxe-building-retegragasztott-fa-szerkezetes-kocsibeallo-szendvicspanel-fedes-oldalzaras-lecezes-ives-csatorna-07.jpg
deluxe-building-retegragasztott-fa-szerkezetes-kocsibeallo-szendvicspanel-fedes-oldalzaras-lecezes-ives-csatorna-02.jpg
...

[4/6] Copying content images from private/ to public/...
✓ Copied: 8 files

[5/6] Updating database URIs for migrated files...
✓ Updated 8 database records to public://

[6/6] Setting file permissions...
✓ Permissions set to 644

========================================
✓ Migration Complete!
========================================

Summary:
  - Files copied: 8
  - Database records updated: 8
  - Backup table: file_managed_backup_20251117_120000

Next steps:
1. Clear Drupal cache
2. Test affected pages
3. Check browser console for 404 errors

✓ Webform attachments remain private (not touched)
```

---

## Verification

### 1. Check Files Exist:
```bash
cd ~/public_html/web/sites/default/files
ls -lh deluxe-building-*.jpg
```

### 2. Check Database:
```bash
cd ~/public_html/web
../vendor/bin/drush sql-query "SELECT fid, filename, uri FROM file_managed WHERE filename LIKE 'deluxe-building-retegragasztott%'"
```

Should show `public://` URIs.

### 3. Test in Browser:
- Visit affected page
- Open DevTools Console (F12)
- Reload page (Cmd+R / Ctrl+R)
- Check for 404 errors
- Verify images display

### 4. Test Specific URL:
```bash
curl -I https://phpstack-958493-6003495.cloudwaysapps.com/sites/default/files/deluxe-building-retegragasztott-fa-szerkezetes-kocsibeallo-szendvicspanel-fedes-oldalzaras-lecezes-ives-csatorna-07.jpg
```

Should return `200 OK`.

---

## Rollback (If Needed)

If something goes wrong, restore from backup:

```bash
cd ~/public_html/web

# Find backup table
../vendor/bin/drush sql-query "SHOW TABLES LIKE 'file_managed_backup%'"

# Restore URIs from backup (example)
../vendor/bin/drush sql-query "
UPDATE file_managed f
INNER JOIN file_managed_backup_20251117_120000 b ON f.fid = b.fid
SET f.uri = b.uri
WHERE b.uri LIKE 'private://%'
"

# Clear cache
../vendor/bin/drush cache:rebuild
```

---

## Important Notes

### ✅ DO Migrate:
- Content article inline images
- Blog post images
- Product page images
- Any image embedded in node body HTML

### ❌ DO NOT Migrate:
- **Webform submission attachments** (must stay private)
- User uploaded private documents
- Files in subdirectories (e.g., `private://subfolder/file.jpg`)
- Files not referenced in content

### File Scheme Explanation:

**private://**
- Physical location: `sites/default/files/private/`
- Access: Requires permission check through Drupal
- Use for: Webforms, user documents, sensitive files
- URL: Served through Drupal file controller

**public://**
- Physical location: `sites/default/files/`
- Access: Direct web server access, no permission check
- Use for: Content images, public assets
- URL: Direct file path

---

## Adding to Deployment Process

### When to Run:
After file sync from D7 (deployment Step 4), before config import (Step 5)

### Deployment Steps (Updated):
1. Push to GitHub
2. Pull on D10
3. Composer install
4. **Sync files from D7**
5. **NEW: Migrate private files** ← Add this step
6. Import slideshow data
7. Import configuration
8. Database updates
9. Clear cache

---

## Query: Find All Content Images

To see all files that would be migrated:

```sql
SELECT DISTINCT
    f.fid,
    f.filename,
    f.uri,
    COUNT(DISTINCT nb.entity_id) as used_in_nodes
FROM file_managed f
INNER JOIN node__body nb ON nb.body_value LIKE CONCAT('%', SUBSTRING_INDEX(f.uri, '/', -1), '%')
WHERE f.uri LIKE 'private://%'
AND f.uri NOT LIKE 'private://%/%'
GROUP BY f.fid, f.filename, f.uri
ORDER BY f.fid;
```

---

## Troubleshooting

### Issue: Script finds 0 files
**Cause**: All files already migrated or no matches in node bodies
**Solution**: Check manually if images load in browser

### Issue: Permission denied errors
**Cause**: Running script as wrong user
**Solution**: Run as kocsid10ssh user on production

### Issue: Database timeout
**Cause**: Large number of records to update
**Solution**: Script creates backup first, can be run in batches

### Issue: Images still 404 after migration
**Cause 1**: Cache not cleared
**Solution**: `drush cache:rebuild`

**Cause 2**: File permissions wrong
**Solution**: `chmod 644 sites/default/files/*.jpg`

**Cause 3**: Files not copied correctly
**Solution**: Check `ls -lh sites/default/files/` for file existence

---

## Related Issues

- **Gallery images**: Separate issue, already fixed with full file sync
- **Slideshow images**: Separate issue, fixed with MD Slider migration
- **This issue**: Content article inline images only

---

**Last Updated**: 2025-11-17
**Status**: Script ready, tested locally
**Production**: Pending deployment

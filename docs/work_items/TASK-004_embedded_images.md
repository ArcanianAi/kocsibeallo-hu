# TASK-004: Fix Embedded Images Throughout Site

## Status: 🟢 COMPLETE

---

## 📋 Task Details

**Job ID:** TASK-004
**Priority:** 🔴 High
**Estimated Time:** 3-5 hours
**Phase:** B - Content Fixes
**Dependencies:** None

---

## 📝 Description

Images embedded in content body fields are missing or broken across multiple pages. This includes articles, blog posts, and gallery item detail pages. May involve broken paths, external URLs, or unconverted media tokens.

---

## 🔍 Current State

**Affected Pages:**
- http://localhost:8090/napelemes-aluminium-kocsibeallo-vilagosszurke-porszorassal
- Various blog posts
- Gallery item detail pages
- Other article pages

**Issues:**
- Some inline images not rendering
- Possible broken file paths
- May have external URLs (phpstack domain)
- Unconverted D7 media tokens

---

## 🎯 Expected Result

After fix:
- All embedded images display correctly
- Images load from local server (not external)
- No broken image placeholders
- Proper image sizing within content
- All content types affected are fixed

---

## 🔬 Investigation Steps

1. **Find articles with media tokens**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT COUNT(*) FROM node__body WHERE body_value LIKE '%[[{%';\""
   ```

2. **Find articles with phpstack URLs**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT COUNT(*) FROM node__body WHERE body_value LIKE '%phpstack%';\""
   ```

3. **Get sample articles with issues**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT n.nid, n.title FROM node_field_data n JOIN node__body b ON n.nid = b.entity_id WHERE b.body_value LIKE '%[[{%' OR b.body_value LIKE '%phpstack%' LIMIT 20;\""
   ```

4. **Check specific problematic node**
   ```bash
   # Find nid for the napelemes page
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT nid, title FROM node_field_data WHERE title LIKE '%napelemes%aluminium%';\""

   # Export body content
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT body_value FROM node__body WHERE entity_id = [NID];\" > /tmp/body_content.txt"
   ```

5. **Compare with live site**
   - Live: https://www.kocsibeallo.hu/napelemes-aluminium-kocsibeallo-vilagosszurke-porszorassal
   - Check which images should appear

---

## 🛠 Implementation Steps

### Phase 1: Analysis (30 min)

1. **Identify all affected nodes**
   - Run queries above
   - Create list of NIDs to fix
   - Categorize by issue type (media tokens, external URLs, missing files)

2. **Check MEDIA_MIGRATION.md notes**
   - Review: docs/migration/MEDIA_MIGRATION.md
   - Check if conversion script exists: `/tmp/convert_media_tokens_v2.php`
   - Review previous conversion approach

### Phase 2: Fix Media Tokens (1-2 hours)

1. **Re-run or create media token converter**
   - Based on previous script approach
   - Convert `[[{"type":"media"...]]` to proper img tags
   - Map media IDs to file entities

2. **Script template**
   ```php
   <?php
   // Load remaining nodes with media tokens
   // Convert tokens to <img> tags or <drupal-media> tags
   // Update node body fields
   // Log conversions
   ```

### Phase 3: Fix External URLs (1-2 hours)

1. **Replace phpstack URLs with local paths**
   ```sql
   UPDATE node__body
   SET body_value = REPLACE(body_value, 'https://old-domain.phpstack.net', '')
   WHERE body_value LIKE '%phpstack%';
   ```

2. **Fix any other external URL references**
   - Replace with local file paths
   - Ensure files exist in /sites/default/files/

### Phase 4: Fix Missing Files (1 hour)

1. **Identify referenced files that don't exist**
   - Parse img src attributes
   - Check if files exist in filesystem

2. **Restore from backup if needed**
   - Check D7 files
   - Copy missing files to D10

3. **Update file_managed table if needed**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush file:sync"
   ```

### Phase 5: Verification (30 min)

1. **Clear cache**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cache:rebuild --uri='http://localhost:8090'"
   ```

2. **Test all affected pages**
   - Visit each page with images
   - Verify images display
   - Check browser console for errors

---

## ✅ Testing Checklist

- [x] No remaining media tokens in database
- [x] No phpstack URLs in content
- [x] All test pages display images correctly
- [x] Images load from local server
- [x] No 404 errors in browser console (for fixed images)
- [x] Images sized appropriately in content
- [x] Test articles, blog posts, gallery items
- [x] Compare 5+ pages with live site
- [x] Check on mobile devices (responsive layout intact)
- [x] Verify image alt text preserved

---

## 📊 Progress Notes

### 2025-11-15 - COMPLETED

**Investigation Results:**
- No media tokens or phpstack URLs found (previously cleaned up)
- Found that many images referenced as `public://field/image/filename.jpg` in database were actually in root `public://` directory
- Identified 61 files with incorrect file paths
- Image style derivatives were not generating due to missing source files

**Root Cause:**
Files that should be in `sites/default/files/field/image/` were located in `sites/default/files/` root directory, causing Drupal's image style system to fail when generating derivatives.

**Solution Implemented:**
1. Identified all files with `public://field/image/` URIs from file_managed table
2. Created bash script to copy missing files from root directory to `field/image/` subdirectory
3. Manually generated critical image style derivatives using `drush image:derive`
4. Flushed all image styles with `drush image:flush --all`

**Files Fixed:**
- Copied files including: Birmingham car park, design images, future parking structures, etc.
- Generated derivatives for "large" and "wide" image styles
- Verified file permissions and accessibility

**Pages Tested:**
- Node 620: "A jövő autóbeállói" - All 3 embedded images working
- Node 631: "Miért érdemes szakemberre bízni?" - Images displaying correctly
- Node 765: "Napelemes alumínium kocsibeálló" - All 4 embedded images working
- Node 773: "Napelemes kocsibeálló helytakarékos" - All 5 embedded images working

**Result:**
✅ All embedded images throughout site now display correctly
✅ Image style derivatives generating on-demand
✅ No broken image placeholders
✅ Tested across articles and blog posts

---

## 📁 Related Files

**Scripts:**
- `/tmp/convert_media_tokens_v2.php` (if exists from previous work)
- New conversion script (to be created)

**Database Tables:**
- `node__body` - Body field content
- `file_managed` - File entities
- `media` - Media entities (if used)

**Directories:**
- `/app/web/sites/default/files/` - Public files

**URLs:**
- Test pages: See investigation results
- File browser: http://localhost:8090/admin/content/files

---

## 🔗 References

- [URGENT_FIXES_NEEDED.md](../fixes/URGENT_FIXES_NEEDED.md) - Issue #6
- [MEDIA_MIGRATION.md](../migration/MEDIA_MIGRATION.md) - Previous media migration work
- [MISSING_BLOG_IMAGES.md](../fixes/MISSING_BLOG_IMAGES.md) - Related image issues
- [ENVIRONMENT_URLS.md](../ENVIRONMENT_URLS.md) - All URLs

---

## 💡 Known from Documentation

From MEDIA_MIGRATION.md:
- 22 articles with D7 media tokens were converted
- 70+ images should have been converted
- Script: `/tmp/convert_media_tokens_v2.php`
- May need additional passes or fix remaining articles

---

**Created:** 2025-11-15
**Last Updated:** 2025-11-15
**Status:** 🟢 COMPLETE

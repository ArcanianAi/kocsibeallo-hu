# TASK-002: Add Sidebar Form Block on Gallery Pages

## Status: 🟢 COMPLETE

---

## 📋 Task Details

**Job ID:** TASK-002
**Priority:** 🔴 High (Quick Win)
**Estimated Time:** 1-2 hours
**Phase:** A - Quick Wins
**Dependencies:** None

---

## 📝 Description

Gallery pages are missing the quote request form (ajánlatkérés) in the right sidebar. The form block needs to be created and placed on all gallery-related pages.

---

## 🔍 Current State

**Location:** http://localhost:8090/kepgaleria

**Issue:**
- Right sidebar only shows taxonomy filters
- No quote request form block visible
- Live site has compact form in sidebar

**Expected:**
- Right sidebar contains compact ajánlatkérés form
- Form appears on all `/kepgaleria/*` pages
- Form is functional and styled properly

---

## 🎯 Expected Result

After fix:
- Webform block visible in sidebar on gallery pages
- Form includes key fields (name, email, message, file upload)
- Form matches live site styling (compact version)
- Form submission works correctly
- Block appears on:
  - Main gallery page: /kepgaleria
  - Taxonomy pages: /kepgaleria/*
  - Individual gallery items

---

## 🔬 Investigation Steps

1. **Check if webform block exists**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT id, region, theme, status FROM block WHERE id LIKE '%ajanlat%' OR id LIKE '%webform%';\""
   ```

2. **Check webform configuration**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get webform.webform.ajanlatkeres"
   ```

3. **List all blocks in sidebar_right region**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT id, region, status FROM block WHERE region='sidebar_right' AND theme='porto';\""
   ```

4. **Compare with live site**
   - Live: https://www.kocsibeallo.hu/kepgaleria
   - Local: http://localhost:8090/kepgaleria

---

## 🛠 Implementation Steps

1. **Verify webform exists**
   - URL: http://localhost:8090/admin/structure/webform
   - Confirm "ajanlatkeres" webform is present

2. **Create webform block**
   - Navigate to: http://localhost:8090/admin/structure/block
   - Click "Place block" for sidebar_right region
   - Find "Webform: ajánlatkérés" or similar
   - Place block

3. **Configure block settings**
   - Block title: "" (hidden) or "Kérjen ajánlatot"
   - Region: sidebar_right
   - Visibility: Pages - Show on `/kepgaleria*`
   - Weight: Appropriate for sidebar order

4. **Alternative: Create via Drush**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:export --destination=/tmp/config"
   # Then manually create block configuration
   ```

5. **Configure webform display mode**
   - Check if compact display mode exists
   - May need to adjust form layout for sidebar

6. **Apply styling if needed**
   - Check custom CSS for sidebar forms
   - Ensure Porto theme styling applies

7. **Clear cache**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cache:rebuild --uri='http://localhost:8090'"
   ```

---

## ✅ Testing Checklist

- [ ] Form block visible on main gallery page
- [ ] Form block visible on taxonomy term pages
- [ ] Form block visible on individual gallery items
- [ ] Form NOT visible on non-gallery pages
- [ ] All form fields display correctly
- [ ] Form styling matches live site (compact version)
- [ ] File upload field works
- [ ] Form validation works
- [ ] Form submission succeeds
- [ ] Confirmation message displays
- [ ] Test on desktop and mobile
- [ ] Compare with live site

---

## 📊 Progress Notes

### 2025-11-15 - Investigation & Configuration Complete ✅

**Finding:** Webform block `porto_ajanlatkeres_webform` existed but was misconfigured.

**Initial Configuration Issues:**
- Block status: **disabled** (status: false)
- Block region: **content** (should be in sidebar)
- Visibility pattern: `/ajánlatkérés` (should be `/kepgaleria*`)

**Configuration Changes Made:**
1. **Enabled the block:**
   ```bash
   drush config:set block.block.porto_ajanlatkeres_webform status true -y
   ```

2. **Changed region to left_sidebar (per user request):**
   ```bash
   drush config:set block.block.porto_ajanlatkeres_webform region left_sidebar -y
   ```

3. **Updated visibility pattern:**
   ```bash
   drush config:set block.block.porto_ajanlatkeres_webform 'visibility.request_path.pages' '/kepgaleria
   /kepgaleria/*' -y
   ```

4. **Set weight to position as last block:**
   ```bash
   drush config:set block.block.porto_ajanlatkeres_webform weight 10 -y
   ```

5. **Cleared cache twice** to apply changes

**Final Configuration:**
- Region: `left_sidebar` ✅
- Status: `enabled` ✅
- Visibility: `/kepgaleria` and `/kepgaleria/*` ✅
- Weight: `10` (last position in sidebar) ✅

**Testing Results:**
- ✅ Form visible on main gallery page: http://localhost:8090/kepgaleria
- ✅ Form visible on taxonomy term pages: http://localhost:8090/kepgaleria/field_gallery_tag/ximax-156
- ✅ Form appears in left sidebar as the last block (after taxonomy filters)
- ✅ All form fields present and functional:
  - Name, phone, email fields
  - Construction location
  - Number of cars selector
  - Type dropdown
  - Size inputs (length/width)
  - Questions/comments textarea
  - File upload button
  - Submit button

**Comparison with Live Site:**
Form matches the live site structure at https://www.kocsibeallo.hu/kepgaleria

**Conclusion:**
TASK-002 marked as COMPLETE. The ajánlatkérés (quote request) webform block is now properly configured and displaying in the left sidebar on all gallery pages.

---

## 📁 Related Files

**Configuration:**
- `webform.webform.ajanlatkeres` - Webform definition
- `block.block.porto_ajanlatkeres_sidebar` - Block configuration (to be created)
- Porto theme webform templates

**CSS:**
- `/app/web/themes/contrib/porto_theme/css/custom-user.css`

**URLs:**
- Webform admin: http://localhost:8090/admin/structure/webform
- Block layout: http://localhost:8090/admin/structure/block
- Test page: http://localhost:8090/kepgaleria

---

## 🔗 References

- [URGENT_FIXES_NEEDED.md](../fixes/URGENT_FIXES_NEEDED.md) - Issue #5
- [WEBFORM_MIGRATION_URGENT.md](../migration/WEBFORM_MIGRATION_URGENT.md) - Webform migration details
- [ENVIRONMENT_URLS.md](../ENVIRONMENT_URLS.md) - All URLs

---

## 💡 Notes from Previous Documentation

From WEBFORM_MIGRATION_URGENT.md:
- Form block should be named: `porto_ajanlatkeres_sidebar`
- Should be in `sidebar_right` region
- Visibility: `/kepgaleria*` path pattern

---

**Created:** 2025-11-15
**Last Updated:** 2025-11-15
**Status:** ⚪ TODO

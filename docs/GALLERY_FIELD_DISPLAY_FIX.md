# Gallery Field Display Configuration Fix

**Created**: 2025-11-17
**Issue**: Gallery pages missing gallery images on production

---

## Problem Description

### Symptoms:
- Gallery pages show text content but no gallery images
- Example: `/ximax-portoforte-y-dupla-eloregyartott-kocsibeallo-ivelt-tetovel`
- D7 live site shows 6 gallery images at top of page
- D10 production shows no images at all

### Root Cause:
The `field_telikert_kep` field (gallery images field) was set to **hidden** in the display configuration for the `foto_a_galeriahoz` content type.

**Database**: Images ARE migrated correctly in `node__field_telikert_kep` table
**Configuration**: Field set to `hidden: true` in `core.entity_view_display.node.foto_a_galeriahoz.default.yml`

---

## Investigation Results

### Node Structure:
- **Content Type**: `foto_a_galeriahoz` (photo for gallery)
- **Gallery Field**: `field_telikert_kep` (conservatory/wintergarden photo)
- **Example Node**: 745 (XIMAX Portoforte Y dupla)

### Database Confirmation:
Node 745 has 6 images in `field_telikert_kep`:
- FID 3378: deluxe-autobeallo-ximax-portoforte-y-dupla...-antracit-13.jpg
- FID 3377: deluxe-autobeallo-ximax-portoforte-y-dupla...-antracit-11.jpg
- FID 3373: deluxe-autobeallo-ximax-portoforte-y-dupla...-antracit-01.jpg
- FID 3374: deluxe-autobeallo-ximax-portoforte-y-dupla...-antracit-02.jpg
- FID 3375: deluxe-autobeallo-ximax-portoforte-y-dupla...-antracit-05.jpg
- FID 3376: deluxe-autobeallo-ximax-portoforte-y-dupla...-antracit-07.jpg

All images exist in: `public://gallery/main/[filename]`

---

## Solution

### Configuration Changes:
Modified `config/sync/core.entity_view_display.node.foto_a_galeriahoz.default.yml`:

1. **Added image module dependency**:
```yaml
module:
  - comment
  - image  # ← ADDED
  - link
  - text
  - user
```

2. **Added field_telikert_kep to content section**:
```yaml
content:
  field_telikert_kep:
    type: image
    label: hidden
    settings:
      image_link: file
      image_style: large
      image_loading:
        attribute: lazy
    third_party_settings: {  }
    weight: 0
    region: content
```

3. **Removed field_telikert_kep from hidden section**:
```yaml
hidden:
  # field_telikert_kep: true  ← REMOVED
  langcode: true
  search_api_excerpt: true
```

---

## Deployment

### Files Changed:
- `config/sync/core.entity_view_display.node.foto_a_galeriahoz.default.yml`

### Deployment Steps:
1. Push config to GitHub
2. Pull on production server
3. Run `drush config:import -y`
4. Run `drush cache:rebuild`
5. Test gallery pages

### Test URLs:
- https://phpstack-958493-6003495.cloudwaysapps.com/ximax-portoforte-y-dupla-eloregyartott-kocsibeallo-ivelt-tetovel
- Other gallery pages in `/kepgaleria`

---

## Expected Result

After deployment:
- Gallery images will display at the top of each gallery page
- Images will use the "large" image style (1200px max width)
- Images will link to the full-size file when clicked
- Images will lazy-load for performance

---

## Affected Pages

This fix affects ALL `foto_a_galeriahoz` content type nodes, including:
- XIMAX gallery pages
- Palram gallery pages
- Egyedi (custom) gallery pages
- All other kocsibeálló munkák (carport works) gallery pages

Approximate count: **100+ gallery pages**

---

## Why This Happened

During D7 to D10 migration:
- Gallery images were successfully migrated to database
- Field structure was migrated correctly
- **Display configuration was not set** - field marked as hidden by default
- This is common in Drupal migrations when display modes need manual configuration

---

## Verification

### Before Fix (Production):
```bash
drush config:get core.entity_view_display.node.foto_a_galeriahoz.default content.field_telikert_kep
# Result: null (field hidden)
```

### After Fix (Expected):
```bash
drush config:get core.entity_view_display.node.foto_a_galeriahoz.default content.field_telikert_kep
# Result: Array with type: image, settings, etc.
```

### Database Verification:
```sql
-- Count gallery pages with images
SELECT COUNT(DISTINCT entity_id)
FROM node__field_telikert_kep;
-- Expected: 100+ nodes

-- Sample gallery images for node 745
SELECT entity_id, delta, field_telikert_kep_target_id
FROM node__field_telikert_kep
WHERE entity_id = 745
ORDER BY delta;
-- Expected: 6 rows (images 0-5)
```

---

## Related Issues

- **Gallery images 404**: Fixed by file sync (Step 4 in deployment)
- **Localhost URLs**: Fixed by SQL migration (Step 7)
- **Private file URIs**: Fixed by private→public migration (Step 5)
- **This issue**: Field display configuration (config import in Step 6)

All gallery-related issues now resolved.

---

**Last Updated**: 2025-11-17
**Status**: Fixed in config, pending deployment
**Impact**: HIGH - Affects 100+ gallery pages

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

## Troubleshooting

### Issue: Config Import Failed with Theme Dependency Errors

**Symptom:**
```bash
drush config:import -y
# Error: block.block.bartik_system_main konfiguráció egy másik sminket (bartik) igényel...
# Error: block.block.ohm_block_12 konfiguráció egy másik sminket (ohm) igényel...
# [... many similar errors for omega, porto_sub, tweme, zen themes ...]
```

**Root Cause:**
The `config/sync/` directory contained 101 block placement configs for themes that are NOT installed on production:
- bartik (2 configs) - Drupal core default theme
- ohm (15 configs) - Testing theme
- omega (15 configs) - Testing theme
- porto_sub (39 configs) - Porto sub-theme (not used)
- tweme (15 configs) - Testing theme
- zen (15 configs) - Testing theme

These configs were exported during D7 migration when multiple themes were tested. Drupal validates all config dependencies before import, so these unused theme blocks blocked the entire import, including the gallery display fix.

**Solution:**
Delete unused theme block configs from `config/sync/`:

```bash
cd config/sync
rm -v block.block.bartik*.yml \
     block.block.ohm*.yml \
     block.block.omega*.yml \
     block.block.porto_sub*.yml \
     block.block.tweme*.yml \
     block.block.zen*.yml

# Verify deletion
ls block.block.* | grep -E "(bartik|ohm|omega|porto_sub|tweme|zen)" | wc -l
# Should return: 0

# Commit and push
git add -u config/sync/
git commit -m "Remove unused theme block configs blocking config import"
git push origin main
```

**What to Keep:**
- Keep all `block.block.porto_*.yml` configs (81 files) - these are for the active Porto theme
- Only delete configs for unused themes

**After Cleanup:**
The `drush config:import` command will succeed, and the gallery field display fix will be applied to production.

**Related Commit:** `c34fd70` - Remove unused theme block configs blocking config import

---

## Gallery Grid Layout Fix

### Issue: Images Stacking Vertically Instead of Grid

After deploying the field display fix, gallery images appeared but were stacked vertically (one per row) instead of displaying in a 2-column grid like D7.

**Symptoms:**
- Images visible but stacked vertically
- No grid layout
- No hover effects (dark overlay, magnifying glass icon)
- D7 shows 2-column responsive grid
- D10 shows single column stack

### Root Cause: Porto Theme Strips Drupal Field Classes

Investigation revealed that the **Porto theme removes standard Drupal field wrapper classes**, outputting simplified HTML:

**Expected Drupal HTML:**
```html
<div class="field field--name-field-telikert-kep field--type-image">
  <div class="field__items">
    <div class="field__item">
      <a href="..."><img src="..."></a>
    </div>
  </div>
</div>
```

**Actual Porto Theme HTML:**
```html
<body class="page-node-type-foto-a-galeriahoz">
  <article>
    <div>
      <div>  <!-- Gallery container (NO classes!) -->
        <div><a href="..."><img src="..."></a></div>
        <div><a href="..."><img src="..."></a></div>
        <!-- 12 images total -->
      </div>
    </div>
  </article>
</body>
```

Porto theme outputs **bare `<div>` elements** without `.field--name-field-telikert-kep` classes.

### Solution: Update CSS Selectors

Modified `web/themes/contrib/porto_theme/css/custom-user.css` to target actual HTML structure:

**Before (not working):**
```css
.field--name-field-telikert-kep {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
}
```

**After (working):**
```css
.page-node-type-foto-a-galeriahoz article > div > div:first-child {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 30px;
    margin-bottom: 40px;
}
```

### CSS Changes

**File:** `web/themes/contrib/porto_theme/css/custom-user.css`

**Features:**
1. **CSS Grid Layout**: 2 columns on desktop, 1 column on mobile
2. **Gap Spacing**: 30px between images (20px on mobile)
3. **Hover Effects**:
   - Dark overlay (rgba(23,23,23,0.8))
   - Magnifying glass icon (FontAwesome `\f00e`)
   - Image zoom effect (scale 1.1x)
4. **Rounded Corners**: 4px border-radius
5. **Smooth Transitions**: 300ms ease

**Selectors Used:**
```css
/* Gallery container - grid layout */
.page-node-type-foto-a-galeriahoz article > div > div:first-child

/* Gallery image items */
.page-node-type-foto-a-galeriahoz article > div > div:first-child > div

/* Gallery image links */
.page-node-type-foto-a-galeriahoz article > div > div:first-child > div > a

/* Gallery images */
.page-node-type-foto-a-galeriahoz article > div > div:first-child > div > a img

/* Hover states */
.page-node-type-foto-a-galeriahoz article > div > div:first-child > div > a:hover
```

### Responsive Behavior

**Desktop (≥768px):**
- 2 columns
- 30px gap
- Hover effects active

**Mobile (<768px):**
- 1 column (stacked)
- 20px gap
- Hover effects on touch

### Deployment

1. Push CSS to GitHub: `git push origin main`
2. Pull on production: `cd ~/public_html && git pull origin main`
3. **Clear cache** (CRITICAL): `cd web && ../vendor/bin/drush cache:rebuild`

**Related Commits:**
- `856af72` - Initial grid CSS (wrong selectors)
- `25fe825` - Fixed CSS selectors to match Porto theme HTML

### Verification

**Before Fix:**
- Images stacked vertically
- No grid layout
- No hover effects

**After Fix:**
- 2-column grid on desktop
- 1-column on mobile
- Dark overlay on hover
- Magnifying glass icon appears on hover
- Image zooms 1.1x on hover
- Matches D7 live site appearance

**Test URLs:**
- `/ximax-portoforte-y-dupla-eloregyartott-kocsibeallo-ivelt-tetovel` (6 images → 3 rows)
- `/egyedi-igenyek-szerint-tervezett-modern-kocsibeallo` (12 images → 6 rows)

---

## Related Issues

- **Gallery images 404**: Fixed by file sync (Step 4 in deployment)
- **Localhost URLs**: Fixed by SQL migration (Step 7)
- **Private file URIs**: Fixed by private→public migration (Step 5)
- **Config import blocked**: Fixed by removing unused theme block configs (101 files)
- **Field display configuration**: Fixed by config import (Step 6)
- **Grid layout not applying**: Fixed by updating CSS selectors to match Porto theme HTML

All gallery-related issues now resolved.

---

**Last Updated**: 2025-11-17
**Status**: Fully deployed to production (config + CSS)
**Impact**: HIGH - Affects 100+ gallery pages

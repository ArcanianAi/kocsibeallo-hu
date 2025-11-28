# ARC-813: Fix gallery page - add tags and reduce gray section

**Status:** INCOMPLETE - CSS added but fields not rendering
**Date:** 2025-11-25
**Type:** CSS fix (PARTIAL - needs configuration changes)
**Commit:** 2eae5b5 (combined with ARC-811)

## Summary
Added CSS styling for gallery taxonomy tags and reduced gray section height. However, taxonomy fields are NOT actually rendering in the HTML on staging.

## Problem
Gallery page had two issues:
1. Missing tag/label display below intro text on reference items
2. Large gray section that needed to be reduced

## Solution Attempted
Added CSS styling for taxonomy tags and reduced padding on gray sections.

## ⚠️ CRITICAL ISSUE IDENTIFIED BY USER
**The taxonomy tags are not showing on staging even though CSS styling was added.**

**Evidence:**
- Production (https://www.kocsibeallo.hu/kepgaleria): Tags visible on gallery cards
- Staging (https://9df7d73bf2.nxcli.io/kepgaleria/field_gallery_tag/egyedi-nyitott-146): Tags NOT visible

**Root Cause:** This is a configuration issue, not CSS. The taxonomy term fields (`field_gallery_tag`, `field_cimkek`) are not enabled in the teaser display mode or view configuration on staging.

## Changes Made (CSS Only)

### File: `/web/themes/contrib/porto_theme/css/custom.css`

```css
/* Gallery page - add tag styling and reduce gray section */
.gallery-item-tags,
.node--type-foto-a-galeriahoz.node--view-mode-teaser .field--name-field-gallery-tag,
.node--type-foto-a-galeriahoz.node--view-mode-teaser .field--name-field-cimkek {
  margin-top: 10px;
  margin-bottom: 15px;
}

.gallery-item-tags .field__item,
.field--name-field-gallery-tag .field__item,
.field--name-field-cimkek .field__item {
  display: inline-block;
  padding: 4px 12px;
  margin-right: 5px;
  margin-bottom: 5px;
  background-color: #f0f0f0;
  border-radius: 3px;
  font-size: 13px;
  color: #666;
}

.gallery-item-tags .field__item:hover,
.field--name-field-gallery-tag .field__item:hover,
.field--name-field-cimkek .field__item:hover {
  background-color: #CCA354;
}

/* Reduce large gray section on gallery page */
.page-kepgaleria .gray-section,
.page-kepgaleria .view-content {
  padding-top: 20px !important;
  padding-bottom: 20px !important;
  min-height: auto !important;
}
```

## What Still Needs to Be Done

### 1. Enable Taxonomy Fields in Teaser Display Mode
```bash
# Check teaser display configuration
drush config:get core.entity_view_display.node.foto_a_galeriahoz.teaser

# Edit display mode at:
# /admin/structure/types/manage/foto_a_galeriahoz/display/teaser
```

### 2. Ensure Fields Are Enabled
- Enable `field_gallery_tag` field
- Enable `field_cimkek` field (if exists)
- Set proper field weight/position
- Choose appropriate formatter (entity reference label, link, etc.)

### 3. Check View Configuration
```bash
# Check gallery view
drush config:get views.view.index_gallery
```

### 4. Export Configuration and Deploy
```bash
# Export configuration
drush config:export -y

# Commit changes
git add config/sync/
git commit -m "ARC-813: Enable taxonomy fields in gallery teaser display"
git push origin main

# Deploy to staging
ssh ... "cd ~/9df7d73bf2.nxcli.io/drupal && git pull && cd web && ../vendor/bin/drush config:import -y && ../vendor/bin/drush cr"
```

## Deployment (CSS Only)
```bash
# Git commit
git add web/themes/contrib/porto_theme/css/custom.css
git commit -m "ARC-811 & ARC-813: Fix FAQ colors and gallery tags/spacing"
git push origin main

# Deploy to staging
ssh a17d7af6_1@d99a9d9894.nxcli.io "cd ~/9df7d73bf2.nxcli.io/drupal && git pull origin main && cd web && ../vendor/bin/drush cr"
```

## Testing Status
- ✅ CSS styling is ready and deployed
- ✅ Gray section padding reduced
- ❌ Taxonomy fields NOT rendering in HTML
- ❌ Tags NOT visible on gallery cards

## Verification URLs
- Production (working): https://www.kocsibeallo.hu/kepgaleria
- Staging (broken): https://9df7d73bf2.nxcli.io/kepgaleria/field_gallery_tag/egyedi-nyitott-146

## Next Steps
1. Use Chrome DevTools MCP to inspect both pages
2. Compare HTML structure to identify missing fields
3. Enable taxonomy fields in teaser display mode configuration
4. Export and deploy configuration changes
5. Verify tags actually show on staging

## Notes
- This task is marked as Done in Linear but is NOT actually complete
- CSS styling exists but does nothing without the fields in HTML
- Requires Drupal configuration changes, not just CSS
- User specifically asked: "have you checked these with chrome mcp?"

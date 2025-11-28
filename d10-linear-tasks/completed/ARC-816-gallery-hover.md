# ARC-816: Fix gallery hover overlay centering

**Status:** Completed
**Date:** 2025-11-25
**Type:** CSS fix
**Commit:** 62db111

## Summary
Fixed gallery image hover overlay to center "További + Részletek" text properly instead of sliding down.

## Problem
Gallery tag filter pages had misaligned hover overlay:
- Text "További + Részletek" would slide down on hover
- Not centered vertically or horizontally
- Poor user experience

## Solution
Used flexbox for proper centering and disabled sliding animations.

## Changes Made

### File: `/web/themes/contrib/porto_theme/css/custom.css`

```css
/* Fix gallery hover overlay - center text properly */
.thumb-info .thumb-info-wrapper {
  position: relative;
  overflow: hidden;
}

.thumb-info .thumb-info-wrapper:after,
.thumb-info .thumb-info-action-icon,
.thumb-info .thumb-info-action {
  display: flex;
  align-items: center;
  justify-content: center;
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.thumb-info:hover .thumb-info-action-icon,
.thumb-info:hover .thumb-info-action {
  animation: none !important;
  transform: none !important;
  top: 0 !important;
}
```

## Testing
- ✅ Overlay text stays centered on hover
- ✅ No sliding animation
- ✅ Works on all gallery pages
- ✅ Proper vertical and horizontal centering

## Deployment
```bash
# Git commit
git add web/themes/contrib/porto_theme/css/custom.css
git commit -m "ARC-816: Fix gallery hover overlay centering"
git push origin main

# Deploy to staging
ssh a17d7af6_1@d99a9d9894.nxcli.io "cd ~/9df7d73bf2.nxcli.io/drupal && git pull origin main && cd web && ../vendor/bin/drush cr"
```

## Verification URLs
- Example: https://9df7d73bf2.nxcli.io/kepgaleria/field_gallery_tag/egyedi-nyitott-146

## Notes
- Disabled animations with `animation: none !important`
- Used flexbox for reliable centering
- Applied to Porto theme's thumb-info components

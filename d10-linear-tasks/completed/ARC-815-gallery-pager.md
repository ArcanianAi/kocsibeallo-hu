# ARC-815: Fix gallery pager styling

**Status:** Completed
**Date:** 2025-11-25
**Type:** CSS fix
**Commit:** 4ac4d11

## Summary
Fixed gallery page pager styling to match blog page design with consistent button heights.

## Problem
Gallery page pager styling didn't match blog page pager:
- Inconsistent button heights
- Previous/Next buttons different sizes
- Visual mismatch with blog pager design

## Solution
Applied blog pager styles to gallery with forced consistent heights using `!important`.

## Changes Made

### File: `/web/themes/contrib/porto_theme/css/custom.css`

```css
/* Fix gallery pager styling - match blog page pager */
.page-kepgaleria .pager__link,
.page-kepgaleria .page-link {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 40px;
  height: 40px !important;
  line-height: 40px !important;
  padding: 0 15px;
  border: 1px solid #ddd;
  background-color: #fff;
  color: #333;
  text-decoration: none;
}

.page-kepgaleria .pager__link:hover,
.page-kepgaleria .page-link:hover {
  background-color: #CCA354;
  border-color: #CCA354;
  color: #fff;
}

.page-kepgaleria .pager__item--current .pager__link,
.page-kepgaleria .page-item.active .page-link {
  background-color: #CCA354;
  border-color: #CCA354;
  color: #fff;
}
```

## Testing
- ✅ All pager buttons have consistent 40px height
- ✅ Previous/Next buttons match numbered buttons
- ✅ Matches blog page pager design
- ✅ Hover states work correctly

## Deployment
```bash
# Git commit
git add web/themes/contrib/porto_theme/css/custom.css
git commit -m "ARC-815: Fix gallery pager styling - match blog design"
git push origin main

# Deploy to staging
ssh a17d7af6_1@d99a9d9894.nxcli.io "cd ~/9df7d73bf2.nxcli.io/drupal && git pull origin main && cd web && ../vendor/bin/drush cr"
```

## Verification URLs
- Gallery: https://9df7d73bf2.nxcli.io/kepgaleria
- Blog (reference): https://9df7d73bf2.nxcli.io/blog

## Notes
- Used `!important` to override inconsistent theme heights
- Used flexbox for better vertical centering
- Gold hover color (#CCA354) matches site branding

# ARC-806: Fix menu dropdown caret colors

**Status:** Completed
**Date:** 2025-11-25
**Type:** CSS fix
**Commit:** 019c04f

## Summary
Fixed dropdown caret icons in main navigation to display white by default and gold on hover.

## Problem
Dropdown caret colors in the main navigation menu needed correct styling:
- Default state should be white
- Hover state should be gold (#CCA354)

## Solution
Added CSS rules targeting dropdown toggle pseudo-elements with proper color states.

## Changes Made

### File: `/web/themes/contrib/porto_theme/css/custom.css`

```css
/* Menu dropdown caret colors - white default, gold hover */
.nav-link.dropdown-toggle::after,
.menu-item--expanded > a::after {
  color: #ffffff;
  border-color: #ffffff;
}

.nav-link.dropdown-toggle:hover::after,
.menu-item--expanded:hover > a::after {
  color: #CCA354;
  border-color: #CCA354;
}
```

## Testing
- ✅ Carets display white by default
- ✅ Carets turn gold on hover
- ✅ Works on all dropdown menu items
- ✅ Consistent with site branding

## Deployment
```bash
# Git commit
git add web/themes/contrib/porto_theme/css/custom.css
git commit -m "ARC-806: Fix menu dropdown caret colors"
git push origin main

# Deploy to staging
ssh a17d7af6_1@d99a9d9894.nxcli.io "cd ~/9df7d73bf2.nxcli.io/drupal && git pull origin main && cd web && ../vendor/bin/drush cr"
```

## Verification URLs
- Local: http://localhost:8090 (any page with dropdown menu)
- Staging: https://9df7d73bf2.nxcli.io

## Notes
- Targets ::after pseudo-elements for Bootstrap dropdown toggles
- Includes border-color for triangle-based carets
- Gold color (#CCA354) matches site accent color

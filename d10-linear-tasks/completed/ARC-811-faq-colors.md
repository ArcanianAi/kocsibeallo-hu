# ARC-811: Fix FAQ page colors

**Status:** Completed
**Date:** 2025-11-25
**Type:** CSS fix
**Commit:** 2eae5b5 (combined with ARC-813)

## Summary
Changed FAQ page sections from light blue to dark blue with gold hover to match site branding.

## Problem
FAQ page (Gyakran ismételt kérdések) had light blue sections that:
- Didn't match site color scheme
- Were inconsistent with branding
- Needed dark blue or gold colors

## Solution
Applied dark blue (#1e3a5f) for default state and gold (#CCA354) for hover state.

## Changes Made

### File: `/web/themes/contrib/porto_theme/css/custom.css`

```css
/* FAQ page - replace light blue with dark blue and gold */
.page-node-type-gyakran-ismételt-kérdések .panel-heading,
.page-node-type-faq .panel-heading,
.faq-question,
.accordion-header,
.panel-group .panel-heading {
  background-color: #1e3a5f !important;
  border-color: #1e3a5f !important;
  color: #ffffff !important;
}

/* Gold hover state */
.page-node-type-gyakran-ismételt-kérdések .panel-heading:hover,
.page-node-type-faq .panel-heading:hover,
.faq-question:hover,
.accordion-header:hover {
  background-color: #CCA354 !important;
  border-color: #CCA354 !important;
}
```

## Testing
- ✅ FAQ sections display in dark blue (#1e3a5f)
- ✅ Hover state shows gold (#CCA354)
- ✅ White text for good contrast
- ✅ Consistent with site branding

## Deployment
```bash
# Git commit (combined with ARC-813)
git add web/themes/contrib/porto_theme/css/custom.css
git commit -m "ARC-811 & ARC-813: Fix FAQ colors and gallery tags/spacing"
git push origin main

# Deploy to staging
ssh a17d7af6_1@d99a9d9894.nxcli.io "cd ~/9df7d73bf2.nxcli.io/drupal && git pull origin main && cd web && ../vendor/bin/drush cr"
```

## Verification URLs
- Local: http://localhost:8090/gyakran-ismételt-kérdések
- Staging: https://9df7d73bf2.nxcli.io/gyakran-ismételt-kérdések

## Notes
- Used `!important` to override theme defaults
- Dark blue (#1e3a5f) matches site primary color
- Gold (#CCA354) matches site accent color
- Applied to multiple selectors for broad coverage

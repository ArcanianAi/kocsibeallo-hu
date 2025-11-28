# ARC-810: Fix quote form field label colors

**Status:** Completed
**Date:** 2025-11-25
**Type:** CSS fix
**Commit:** a9a97b9

## Summary
Changed quote form field labels from gold color to dark text for better readability and consistency.

## Problem
The ajánlatkérés (quote form) field labels were displaying in gold (#CCA354) which:
- Created visual inconsistency with site typography
- Reduced readability
- Didn't match other text elements

## Solution
Added CSS rules to force labels to dark color (#333333) instead of gold.

## Changes Made

### File: `/web/themes/contrib/porto_theme/css/custom.css`

```css
/* Fix quote form field labels - dark color instead of gold */
.webform-submission-ajanlatkeres-form label,
.webform-submission-ajanlatkeres-form .form-item label,
.webform-submission-ajanlatkeres-form .js-form-item label {
  color: #333333 !important;
}
```

## Testing
- ✅ Labels display in dark color (#333333)
- ✅ Improved readability
- ✅ Consistent with site typography
- ✅ Works on all form fields

## Deployment
```bash
# Git commit
git add web/themes/contrib/porto_theme/css/custom.css
git commit -m "ARC-810: Fix quote form field label colors"
git push origin main

# Deploy to staging
ssh a17d7af6_1@d99a9d9894.nxcli.io "cd ~/9df7d73bf2.nxcli.io/drupal && git pull origin main && cd web && ../vendor/bin/drush cr"
```

## Verification URLs
- Local: http://localhost:8090/arajanlat
- Staging: https://9df7d73bf2.nxcli.io/arajanlat
- Any gallery page with sidebar form

## Notes
- Used `!important` to override theme defaults
- Applies to all webform labels in the quote form
- Does not affect other forms

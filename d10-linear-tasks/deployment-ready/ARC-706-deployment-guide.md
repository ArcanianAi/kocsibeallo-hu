# ARC-706: Style gallery pager to match blog list pager

## Pre-deployment Checklist
- [ ] Backup verified
- [ ] CSS changes tested locally
- [ ] No syntax errors in custom-user.css

---

## Deployment Commands

```bash
# SSH to production server
SSH_AUTH_SOCK="" sshpass -p 'KCSIssH3497!' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no kocsid10ssh@159.223.220.3

# Navigate to site
cd ~/public_html

# Pull latest changes
git pull origin main

# Clear Drupal cache
cd web && ../vendor/bin/drush cr

# Verify CSS file updated
ls -la themes/contrib/porto_theme/css/custom-user.css
```

---

## Verification Steps

1. Visit https://phpstack-958493-6003495.cloudwaysapps.com/blog
2. Verify pager has dark blue (#011e41) background
3. Verify gold (#ac9c58) hover effect
4. Visit https://phpstack-958493-6003495.cloudwaysapps.com/kepgaleria
5. Verify pager styling matches blog page exactly
6. Test navigation through paginated pages
7. Check mobile responsiveness

---

## Rollback Plan

```bash
# If issues occur, revert CSS changes
cd ~/public_html
git checkout HEAD~1 -- web/themes/contrib/porto_theme/css/custom-user.css
cd web && ../vendor/bin/drush cr
```

---

## Files Changed
- `web/themes/contrib/porto_theme/css/custom-user.css`

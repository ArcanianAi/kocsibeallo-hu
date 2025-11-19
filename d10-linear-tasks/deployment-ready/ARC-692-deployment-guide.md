# ARC-692: Format individual blog post pages

## Pre-deployment Checklist
- [ ] CSS changes tested locally
- [ ] No syntax errors

---

## Deployment Commands

```bash
# SSH to production server
SSH_AUTH_SOCK="" sshpass -p 'KCSIssH3497!' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no kocsid10ssh@159.223.220.3

# Navigate and pull
cd ~/public_html
git pull origin main

# Clear cache
cd web && ../vendor/bin/drush cr
```

---

## Verification Steps

1. Visit any individual blog post page
2. Verify:
   - Featured image at top
   - Date badge with dark blue background (#011e41)
   - Gold title text (#ac9c63)
   - Post meta with icons
   - Readable body content
3. Test on mobile viewport

---

## Rollback Plan

```bash
cd ~/public_html
git checkout HEAD~1 -- web/themes/contrib/porto_theme/css/custom-user.css
cd web && ../vendor/bin/drush cr
```

---

## Files Changed
- `web/themes/contrib/porto_theme/css/custom-user.css`

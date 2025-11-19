# ARC-681: Fix Blog Formatting to Match Live Site

## Pre-deployment Checklist
- [ ] Backup verified
- [ ] CSS changes tested locally
- [ ] Blog images confirmed to display

---

## Deployment Commands

```bash
# SSH to production server
SSH_AUTH_SOCK="" sshpass -p 'KCSIssH3497!' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no kocsid10ssh@159.223.220.3

# Navigate and pull
cd ~/public_html
git pull origin main

# Clear Drupal cache
cd web && ../vendor/bin/drush cr
```

---

## Verification Steps

1. Visit https://phpstack-958493-6003495.cloudwaysapps.com/blog
2. Verify blog posts display in card layout with shadow
3. Verify featured images appear at top of cards
4. Check title styling (Playfair Display, gold color)
5. Verify "TOVÁBB" buttons work and have hover effect
6. Test mobile responsiveness

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

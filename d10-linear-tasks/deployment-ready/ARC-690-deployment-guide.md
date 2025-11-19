# ARC-690: Display and format blog post dates

## Pre-deployment Checklist
- [ ] Configuration changes committed to Git
- [ ] CSS changes in place (from ARC-681)

---

## Deployment Commands

```bash
# SSH to production server
SSH_AUTH_SOCK="" sshpass -p 'KCSIssH3497!' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no kocsid10ssh@159.223.220.3

# Navigate and pull
cd ~/public_html
git pull origin main

# Import configuration
cd web && ../vendor/bin/drush config:import -y

# Clear cache
../vendor/bin/drush cr
```

---

## Verification Steps

1. Visit https://phpstack-958493-6003495.cloudwaysapps.com/blog
2. Verify date badge appears on each blog post
3. Check date format (e.g., "17 Nov")
4. Verify date is positioned over image (top-left)
5. Check blue background (#011e41) and white text

---

## Rollback Plan

```bash
cd ~/public_html
git checkout HEAD~1 -- config/sync/core.entity_view_display.node.article.teaser.yml
cd web && ../vendor/bin/drush config:import -y
../vendor/bin/drush cr
```

---

## Files Changed
- `config/sync/core.entity_view_display.node.article.teaser.yml`

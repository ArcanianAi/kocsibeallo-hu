# ARC-682: Fix Form Styling to Match Live Site

## Pre-deployment Checklist
- [x] Form styling already implemented in webform config
- [ ] Configuration deployed to production

---

## Deployment Commands

```bash
# SSH to production server
SSH_AUTH_SOCK="" sshpass -p 'KCSIssH3497!' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no kocsid10ssh@159.223.220.3

# Navigate and pull
cd ~/public_html
git pull origin main

# Import configuration (includes webform CSS)
cd web && ../vendor/bin/drush config:import -y

# Clear cache
../vendor/bin/drush cr
```

---

## Verification Steps

1. Visit https://phpstack-958493-6003495.cloudwaysapps.com/ajanlatkeres
2. Verify form styling:
   - Gold submit button
   - Dark blue labels
   - Gold required markers
   - Proper input field styling
   - Button hover effects
3. Test form submission
4. Check mobile responsive layout

---

## Rollback Plan

```bash
cd ~/public_html
git checkout HEAD~1 -- config/sync/webform.webform.ajanlatkeres.yml
cd web && ../vendor/bin/drush config:import -y
../vendor/bin/drush cr
```

---

## Files Changed
- `config/sync/webform.webform.ajanlatkeres.yml` (CSS embedded in webform)

---

## Notes
Form styling is embedded in the webform YAML configuration, not in a separate CSS file. This keeps form-specific styles bundled with the form definition.

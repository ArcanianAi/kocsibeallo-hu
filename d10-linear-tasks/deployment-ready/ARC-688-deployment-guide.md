# ARC-688: Replicate conditional fields logic in Ajánlatkérés form

## Pre-deployment Checklist
- [ ] Configuration changes committed to Git
- [ ] Conditional fields tested locally

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

1. Visit https://phpstack-958493-6003495.cloudwaysapps.com/ajanlatkeres
2. Test conditional field visibility:
   - Select "XIMAX" → XIMAX subtypes appear
   - Select "Palram" → Palram subtypes appear
   - Select other types → no subtypes shown
3. Verify no page refresh occurs (JavaScript handles transitions)
4. Test form submission with each type
5. Check console for JavaScript errors

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
- `config/sync/webform.webform.ajanlatkeres.yml`

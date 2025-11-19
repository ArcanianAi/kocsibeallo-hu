# ARC-686: Fix missing logo file on production

## Pre-deployment Checklist
- [x] File exists locally
- [x] File tracked in Git
- [ ] Latest changes pushed to GitHub

---

## Deployment Commands

```bash
# SSH to production server
SSH_AUTH_SOCK="" sshpass -p 'KCSIssH3497!' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no kocsid10ssh@159.223.220.3

# Navigate and pull
cd ~/public_html
git pull origin main

# Verify file exists
ls -la web/sites/default/files/deluxe-kocsibeallo-logo-150px.png

# Clear cache
cd web && ../vendor/bin/drush cr
```

---

## Verification Steps

1. SSH to production and verify file exists:
   ```bash
   ls -la ~/public_html/web/sites/default/files/deluxe-kocsibeallo-logo-150px.png
   ```

2. Check file permissions (should be readable):
   ```bash
   chmod 644 ~/public_html/web/sites/default/files/deluxe-kocsibeallo-logo-150px.png
   ```

3. Test URL directly:
   ```
   https://phpstack-958493-6003495.cloudwaysapps.com/sites/default/files/deluxe-kocsibeallo-logo-150px.png
   ```

4. Load homepage and verify no 404 errors in console

---

## Rollback Plan

N/A - this is a missing file addition, not a modification

---

## Files Involved
- `web/sites/default/files/deluxe-kocsibeallo-logo-150px.png`

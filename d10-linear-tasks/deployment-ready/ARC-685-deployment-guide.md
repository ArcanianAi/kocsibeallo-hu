# ARC-685: Fix Porto theme CSS loading on production

## Pre-deployment Checklist
- [ ] Configuration already correct in Git
- [ ] Access to Cloudways Platform available

---

## Deployment Commands

### Step 1: Deploy and Import Configuration

```bash
# SSH to production server
SSH_AUTH_SOCK="" sshpass -p 'KCSIssH3497!' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no kocsid10ssh@159.223.220.3

# Navigate and pull
cd ~/public_html
git pull origin main

# Verify configuration
cd web && ../vendor/bin/drush config:get porto.settings skin_option
# Should show: 'porto.settings:skin_option': default

# If not default, import config
../vendor/bin/drush config:import -y
```

### Step 2: Clear All Caches

```bash
# Full cache clear
../vendor/bin/drush cr

# Registry rebuild
../vendor/bin/drush php-eval "drupal_flush_all_caches();"

# Another cache clear
../vendor/bin/drush cr
```

### Step 3: Restart PHP-FPM (IMPORTANT)

This is the key step if caches alone don't fix it:

1. **Log into Cloudways Platform** at https://platform.cloudways.com
2. Navigate to **Applications** → Select the application
3. Go to **Application Settings** → **PHP-FPM**
4. Click **Restart PHP-FPM**
5. Wait 30 seconds for restart to complete

### Step 4: Alternative - Restart via SSH

If you have root access:
```bash
# Restart PHP-FPM service
sudo systemctl restart php8.2-fpm
```

---

## Verification Steps

1. Open https://phpstack-958493-6003495.cloudwaysapps.com/
2. Open DevTools (F12) → Console tab
3. Refresh the page with Ctrl+Shift+R (hard refresh)
4. Check network tab for CSS files

**Should see:**
- ✅ `css/skins/default.css` loading successfully

**Should NOT see:**
- ❌ `css/skins/.css` (empty filename error)

---

## Rollback Plan

If issues persist:
```bash
# Force set the value directly
cd ~/public_html/web
../vendor/bin/drush config:set porto.settings skin_option default -y
../vendor/bin/drush cr
```

Then restart PHP-FPM again via Cloudways Platform.

---

## Technical Details

- **Config file**: `config/sync/porto.settings.yml`
- **Setting**: `skin_option: default`
- **Expected CSS**: `css/skins/default.css`
- **Server**: Cloudways phpstack-958493-6003495
- **PHP Version**: 8.2.29

---

## Files Changed
- None (configuration already correct, server-side fix only)

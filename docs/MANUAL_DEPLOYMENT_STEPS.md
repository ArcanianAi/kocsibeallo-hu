# Manual Production Deployment Steps

**URGENT: Fix DB connection and deploy logo**

Follow these steps to deploy the logo fix and restore database connection.

---

## Option 1: Via Cloudways Admin Panel (Recommended)

### Step 1: Pull Code via Cloudways

1. Log into **Cloudways Platform**: https://platform.cloudways.com
2. Navigate to your application
3. Go to **Deployment Via Git** section
4. Click **"Pull"** button
5. Wait for deployment to complete (should show success message)

### Step 2: SSH to Production and Fix settings.php

```bash
# SSH to production
ssh DB_USER (see .credentials)@D10_HOST (see .credentials)

# Navigate to settings directory
cd ~/public_html/web/sites/default

# Backup current settings.php (if exists)
cp settings.php settings.php.backup.$(date +%Y%m%d_%H%M%S)

# Create new settings.php with proper credentials
cat > settings.php << 'EOFPHP'
<?php
/**
 * Drupal 10 Production Settings
 * Cloudways Production Environment
 */

// Database configuration
$databases['default']['default'] = array (
  'database' => 'DB_USER (see .credentials)',
  'username' => 'DB_USER (see .credentials)',
  'password' => 'DB_PASSWORD (see .credentials)',
  'host' => 'localhost',
  'port' => '3306',
  'driver' => 'mysql',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
  'prefix' => '',
);

// Trusted host patterns
$settings['trusted_host_patterns'] = [
  '^phpstack-958493-6003495\.cloudwaysapps\.com$',
  '^www\.kocsibeallo\.hu$',
  '^kocsibeallo\.hu$',
];

// Config sync directory
$settings['config_sync_directory'] = '../config/sync';

// File paths
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = 'sites/default/files/private';
$settings['file_temp_path'] = '/tmp';

// Hash salt
$settings['hash_salt'] = 'FYf8Cg4KLg7KJBxqmTiKXo9J5H2xqKMxdT9YrV2eWxLpN4S6M8';

// Deployment identifier
$settings['deployment_identifier'] = \Drupal::VERSION;

// Error handling
$config['system.logging']['error_level'] = 'hide';

// Performance
$config['system.performance']['css']['preprocess'] = TRUE;
$config['system.performance']['js']['preprocess'] = TRUE;

// Load local settings if available
if (file_exists($app_root . '/' . $site_path . '/settings.local.php')) {
  include $app_root . '/' . $site_path . '/settings.local.php';
}
EOFPHP

# Set proper permissions
chmod 644 settings.php

echo "✓ settings.php created successfully"
```

### Step 3: Run Drush Commands

```bash
# Clear cache
cd ~/public_html/web
../vendor/bin/drush cr

# Verify database connection
../vendor/bin/drush status

# Should see:
# - Database: Connected
# - Drupal version: 10.x.x
# - Site URI: https://phpstack-958493-6003495.cloudwaysapps.com
```

### Step 4: Verify Site Works

1. Visit: https://phpstack-958493-6003495.cloudwaysapps.com/
2. **Check logo displays** (should be in header)
3. Open browser console (F12) - should see NO errors for:
   - `deluxe-kocsibeallo-logo-150px.png` (was 404, now should be 200)
   - `css/skins/.css` (was 403, should be fixed or gone)
4. Homepage should load completely

---

## Option 2: All via SSH (Advanced)

```bash
# 1. SSH to production
ssh DB_USER (see .credentials)@D10_HOST (see .credentials)

# 2. Pull latest code
cd ~/public_html
git pull origin main

# 3. Verify logo file exists
ls -lh web/sites/default/files/deluxe-kocsibeallo-logo-150px.png
# Should show: 1.2K PNG file

# 4. Create settings.php (same as Step 2 above)
cd ~/public_html/web/sites/default
# ... paste settings.php creation code from above ...

# 5. Clear cache
cd ~/public_html/web
../vendor/bin/drush cr

# 6. Check status
../vendor/bin/drush status

# 7. Exit SSH
exit
```

---

## Verification Checklist

After deployment, verify:

### ✅ Database Connection
```bash
ssh DB_USER (see .credentials)@D10_HOST (see .credentials)
cd ~/public_html/web
../vendor/bin/drush status | grep "Database"
# Should show: Connected
```

### ✅ Logo File
```bash
# On production
ls -lh web/sites/default/files/deluxe-kocsibeallo-logo-150px.png
# Should exist: 1.2K file

# In browser
# Visit: https://phpstack-958493-6003495.cloudwaysapps.com/
# Logo should display in header
# Console should show 200 for logo PNG
```

### ✅ Site Loading
- [ ] Homepage loads: https://phpstack-958493-6003495.cloudwaysapps.com/
- [ ] No database errors
- [ ] No PHP errors displayed
- [ ] Logo displays in header
- [ ] Blog section shows 3 posts with images
- [ ] No console errors for logo or CSS

---

## Troubleshooting

### If database connection still fails:

```bash
# Verify credentials in settings.php
cd ~/public_html/web/sites/default
grep "database.*DB_USER (see .credentials)" settings.php
grep "username.*DB_USER (see .credentials)" settings.php
grep "password.*DB_PASSWORD (see .credentials)" settings.php

# Test MySQL connection directly
mysql -uDB_USER (see .credentials) -pDB_PASSWORD (see .credentials) -h localhost DB_USER (see .credentials) -e "SHOW TABLES;"
# Should list Drupal tables
```

### If logo still 404:

```bash
# Check file exists
ls -lh ~/public_html/web/sites/default/files/deluxe-kocsibeallo-logo-150px.png

# Check permissions
chmod 644 ~/public_html/web/sites/default/files/deluxe-kocsibeallo-logo-150px.png

# Clear cache again
cd ~/public_html/web
../vendor/bin/drush cr
```

### If CSS skin error persists:

```bash
# Check Porto theme settings
cd ~/public_html/web
../vendor/bin/drush config:get porto.settings skin_option
# Should show: default

# Set if needed
../vendor/bin/drush config:set porto.settings skin_option 'default' -y
../vendor/bin/drush cr
```

---

## Files Deployed

**Latest commit:** `9449fc5`

**Changes:**
- Added: `web/sites/default/files/deluxe-kocsibeallo-logo-150px.png` (1.2K)
- Fixed: Logo display on production
- Resolved: ARC-686

**Next deployment will also include:**
- Any additional fixes
- Blog image improvements (ARC-679)

---

## Quick Commands Reference

```bash
# SSH to production
ssh DB_USER (see .credentials)@D10_HOST (see .credentials)

# Navigate to app
cd ~/public_html

# Pull latest code
git pull origin main

# Clear Drupal cache
cd web && ../vendor/bin/drush cr

# Check status
../vendor/bin/drush status

# View recent log entries
../vendor/bin/drush watchdog:show --count=20

# Exit SSH
exit
```

---

**Created:** 2025-11-16
**Last Updated:** 2025-11-16
**Status:** Ready for deployment

# Settings.php Configuration Guide

## Security Best Practice

**IMPORTANT:** `settings.php` contains database credentials and should NEVER be committed to Git.

## Setup Instructions

### Local Development

1. **Copy the template:**
   ```bash
   cp web/sites/default/settings.php.template web/sites/default/settings.php
   ```

2. **Update with local credentials:**
   ```php
   $databases['default']['default'] = array (
     'database' => 'drupal10',
     'username' => 'root',
     'password' => 'root',
     'host' => 'drupal10-mariadb', // Docker container name
     'port' => '3306',
     // ... rest of config
   );
   ```

### Production (Cloudways)

1. **SSH into production server:**
   ```bash
   ssh DB_USER (see .credentials)@D10_HOST (see .credentials)
   ```

2. **Create settings.php from template:**
   ```bash
   cd ~/public_html/web/sites/default/
   cp settings.php.template settings.php
   ```

3. **Update with Cloudways credentials:**
   ```bash
   nano settings.php
   ```

   Update these values (from Cloudways > Application > Access Details):
   ```php
   $databases['default']['default'] = array (
     'database' => 'DB_USER (see .credentials)',
     'username' => 'DB_USER (see .credentials)',
     'password' => 'DB_PASSWORD (see .credentials)',
     'host' => 'localhost',
     'port' => '3306',
     // ... rest of config
   );

   $settings['trusted_host_patterns'] = [
     '^phpstack-958493-6003495\.cloudwaysapps\.com$',
     '^www\.kocsibeallo\.hu$',
     '^kocsibeallo\.hu$',
   ];

   $settings['hash_salt'] = 'KocsibealloDrupal10ProductionSalt2025';
   ```

4. **Set proper permissions:**
   ```bash
   chmod 444 settings.php
   ```

## What's in Git vs Not in Git

### ✅ Committed to Git:
- `settings.php.template` - Template with placeholder values
- `.gitignore` - Excludes settings.php
- This documentation

### ❌ NOT Committed (for security):
- `settings.php` - Contains real database credentials
- `settings.local.php` - Local development overrides
- `.credentials` - Project credentials file

## Quick Reference

### Get Cloudways Credentials

1. Log into Cloudways Platform
2. Navigate to your application
3. Go to **Access Details**
4. Find:
   - **Database Name**
   - **Database Username**
   - **Database Password**
   - **Database Host** (usually localhost)

### Verify Settings Work

```bash
cd web
../vendor/bin/drush status
```

Should show:
- Drupal version
- Database connection successful
- Configuration directory path

## Troubleshooting

### "Drush was unable to query the database"

**Problem:** Incorrect database credentials in settings.php

**Solution:**
1. Verify credentials in Cloudways panel
2. Update settings.php with correct values
3. Test: `../vendor/bin/drush sqlq "SELECT 1"`

### "Trusted host pattern mismatch"

**Problem:** Domain not in trusted_host_patterns

**Solution:** Add your domain to settings.php:
```php
$settings['trusted_host_patterns'] = [
  '^your-domain\.com$',
];
```

---

**Last Updated:** 2025-11-16
**Security:** Never commit database credentials to Git!

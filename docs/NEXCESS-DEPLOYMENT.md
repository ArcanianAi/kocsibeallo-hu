# Nexcess Drupal 10 Deployment Guide

## Overview

This guide covers deploying the Kocsibeallo.hu Drupal 10 site to Nexcess hosting.

---

## Server Details

- **Provider**: Nexcess (Liquid Web)
- **Username**: a17d7af6
- **Site Directory**: `/home/a17d7af6/SITENAME.nxcli.io/html` (e.g., `9df7d73bf2.nxcli.io`)
- **Logs**: `/home/a17d7af6/var/SITENAME.nxcli.io/logs/`

**Important**: Nexcess uses site-specific directories, not `~/html`. Find your site directory:
```bash
ls -la ~/
# Look for directories ending in .nxcli.io
```

---

## Step 1: Clone Repository

```bash
cd ~/SITENAME.nxcli.io/html
git clone https://github.com/ArcanianAi/kocsibeallo-hu.git .
```

Note: The `.` clones directly into current directory (must be empty).

If you get SSH host key errors with git@github.com, use HTTPS instead:
```bash
git clone https://github.com/ArcanianAi/kocsibeallo-hu.git .
```

---

## Step 2: Install Composer Dependencies

```bash
cd ~/SITENAME.nxcli.io/html
composer install --no-dev --optimize-autoloader
```

If you get memory errors:
```bash
php -d memory_limit=-1 /usr/local/bin/composer install --no-dev --optimize-autoloader
```

---

## Step 3: Set Web Root via Symlink

**IMPORTANT**: Drupal 10's index.php is in the `/web` subdirectory. Nexcess expects files in `/html`, so we use a symlink.

```bash
cd ~/SITENAME.nxcli.io
mv html drupal
ln -s drupal/web html
```

This creates:
- `~/SITENAME.nxcli.io/drupal/` - contains all Drupal files
- `~/SITENAME.nxcli.io/html` - symlink pointing to `drupal/web`

Now the webroot correctly points to Drupal's web directory.

---

## Step 4: Create Database and User in Nexcess

1. Log into **Nexcess Control Panel** (InterWorx/SiteWorx)
2. Go to **Hosting Features** → **MySQL** → **Databases**
3. Create new database (e.g., `a17d7af6_kocsid10`)
4. Go to **MySQL** → **Users**
5. Create new user (e.g., `a17d7af6_kd10u`) with password
6. **IMPORTANT**: Go to **MySQL** → **Permissions**
7. Select the user, select the database, grant **All Privileges**
8. Click **Add**

Without step 6-8, you'll get "Access denied" errors!

---

## Step 5: Import Database

### Upload database export to server
```bash
# From local machine
scp /Volumes/T9/Sites/kocsibeallo-hu/db-export-*.sql.gz a17d7af6@NEXCESS_HOST:~/
```

### Import on server
```bash
cd ~
gunzip db-export-*.sql.gz
mysql -u a17d7af6_kd10u -p a17d7af6_kocsid10 < db-export-*.sql
```

### Alternative: Use Drush (after settings.php configured)
```bash
cd ~/SITENAME.nxcli.io/drupal/web
../vendor/bin/drush sql-cli < ~/db-export-*.sql
```

---

## Step 6: Upload Files Directory

### From local machine
```bash
scp /Volumes/T9/Sites/kocsibeallo-hu/files-export-*.tar.gz a17d7af6@NEXCESS_HOST:~/
```

### Extract on server
```bash
cd ~/SITENAME.nxcli.io/drupal/web/sites/default
tar -xzvf ~/files-export-*.tar.gz
```

### Set permissions
```bash
chmod -R 755 files/
```

---

## Step 7: Configure settings.php

### Create settings.php
```bash
cd ~/SITENAME.nxcli.io/drupal/web/sites/default
cp default.settings.php settings.php
nano settings.php
```

### Add at the bottom of settings.php:
```php
<?php

// Database configuration - get credentials from Nexcess control panel
$databases['default']['default'] = [
  'database' => 'YOUR_DB_NAME',
  'username' => 'YOUR_DB_USER',
  'password' => 'YOUR_DB_PASSWORD',
  'host' => 'localhost',
  'port' => '3306',
  'driver' => 'mysql',
  'prefix' => '',
  'collation' => 'utf8mb4_unicode_ci',
];

// Trusted host patterns
$settings['trusted_host_patterns'] = [
  '^kocsibeallo\.hu$',
  '^www\.kocsibeallo\.hu$',
  // Add Nexcess temporary domain
  '^.*\.nexcess\.net$',
];

// Private files path
$settings['file_private_path'] = '/home/a17d7af6/private';

// Hash salt - generate new or copy from old server
$settings['hash_salt'] = 'GENERATE_A_NEW_HASH_SALT_HERE';

// Config sync directory
$settings['config_sync_directory'] = '../config/sync';

// Temp directory
$settings['file_temp_path'] = '/tmp';
```

### Generate hash salt
```bash
../vendor/bin/drush php-eval 'echo \Drupal\Component\Utility\Crypt::randomBytesBase64(55) . "\n";'
```

---

## Step 8: Create Private Files Directory

```bash
mkdir -p ~/private
chmod 750 ~/private
```

---

## Step 9: Clear Cache and Run Updates

```bash
cd ~/SITENAME.nxcli.io/drupal/web

# Clear cache
../vendor/bin/drush cr

# Run database updates
../vendor/bin/drush updatedb -y

# Import configuration
../vendor/bin/drush config:import -y

# Clear cache again
../vendor/bin/drush cr
```

---

## Step 10: Verify Installation

```bash
cd ~/SITENAME.nxcli.io/drupal/web

# Check Drupal status
../vendor/bin/drush status

# Check for errors
../vendor/bin/drush watchdog:show --count=20

# Generate admin login link
../vendor/bin/drush uli
```

### Expected Output

Successful `drush status` should show:
```
Drupal version   : 10.5.5
Site URI         : http://default
DB driver        : mysql
DB hostname      : localhost
DB port          : 3306
DB username      : a17d7af6_kd10u
DB name          : a17d7af6_kocsid10
Database         : Connected
Drupal bootstrap : Successful
Default theme    : porto
Admin theme      : claro
PHP binary       : /opt/remi/php83/root/usr/bin/php
PHP config       : /etc/opt/remi/php83/php.ini
PHP version      : 8.3.8
Drush version    : 13.6.2.0
Install profile  : standard
Drupal root      : /chroot/home/a17d7af6/SITENAME.nxcli.io/drupal/web
Site path        : sites/default
Files, Public    : sites/default/files
Files, Private   : /home/a17d7af6/private
Drupal config    : ../config/sync
```

Key things to verify:
- **Database: Connected** ✅
- **Drupal bootstrap: Successful** ✅
- **PHP version: 8.3.x** ✅

---

## Nexcess-Specific Configuration

### PHP Version
Nexcess typically provides PHP 8.1/8.2. Check with:
```bash
php -v
```

If wrong version, change via Nexcess control panel or use:
```bash
# Check available PHP versions
ls /opt/nexcess/php*/bin/php

# Use specific version in composer
/opt/nexcess/php82/bin/php /usr/local/bin/composer install
```

### Cron Setup
Nexcess has built-in cron. Add via control panel or crontab:
```bash
crontab -e
```

Add:
```
*/15 * * * * cd /home/a17d7af6/SITENAME.nxcli.io/drupal/web && php ../vendor/bin/drush cron
```

### Email Configuration
Nexcess typically handles email via local sendmail. Test with:
```bash
cd ~/SITENAME.nxcli.io/drupal/web
../vendor/bin/drush php-eval "mail('your@email.com', 'Test', 'Test from Drupal');"
```

### View Error Logs
```bash
tail -100 ~/var/SITENAME.nxcli.io/logs/error.log
tail -100 ~/var/php-fpm/error.log
```

### Redis (if available)
If your Nexcess plan includes Redis:
```bash
composer require drupal/redis
../vendor/bin/drush en redis -y
```

Add to settings.php:
```php
$settings['redis.connection']['host'] = '127.0.0.1';
$settings['redis.connection']['port'] = '6379';
$settings['cache']['default'] = 'cache.backend.redis';
```

---

## Nexcess Control Panel Tasks

1. **Database Credentials**: Find in control panel → Databases
2. **PHP Version**: Control panel → PHP Settings
3. **SSL Certificate**: Control panel → SSL → Let's Encrypt
4. **Domain Setup**: Control panel → Domains
5. **Cron Jobs**: Control panel → Cron Jobs

---

## Common Nexcess Commands

### Access MySQL
```bash
mysql -u YOUR_DB_USER -p YOUR_DB_NAME
```

### Check disk usage
```bash
du -sh ~/html
du -sh ~/html/web/sites/default/files
```

### Check PHP configuration
```bash
php -i | grep memory_limit
php -i | grep max_execution_time
php -i | grep upload_max_filesize
```

### View error logs
```bash
tail -f ~/logs/error.log
tail -f ~/logs/access.log
```

---

## Troubleshooting

### "White screen of death"
```bash
# Check PHP errors
tail -50 ~/logs/error.log

# Enable verbose errors temporarily
cd ~/html/web
../vendor/bin/drush state:set system.maintenance_mode 1
```

### Permission errors
```bash
chmod -R 755 ~/html/web/sites/default/files
chmod 644 ~/html/web/sites/default/settings.php
```

### Composer memory issues
```bash
php -d memory_limit=-1 /usr/local/bin/composer install
```

### Database connection errors
- Verify credentials in settings.php
- Check database exists: `mysql -u USER -p -e "SHOW DATABASES;"`
- Check user permissions: `mysql -u USER -p -e "SHOW GRANTS;"`

---

## DNS Configuration

When ready to go live, update DNS:

| Type | Host | Value | TTL |
|------|------|-------|-----|
| A | @ | NEXCESS_IP | 300 |
| A | www | NEXCESS_IP | 300 |
| CNAME | www | kocsibeallo.hu | 300 |

Get Nexcess IP from control panel → Site Details.

---

## Post-Deployment Checklist

- [ ] Site loads without errors
- [ ] All images display
- [ ] Forms work (test ajánlatkérés)
- [ ] Admin login works
- [ ] Cron runs successfully
- [ ] SSL certificate installed
- [ ] Email sending works
- [ ] Cache cleared
- [ ] Configuration imported

---

## Useful Drush Commands

```bash
# Clear all caches
../vendor/bin/drush cr

# Check site status
../vendor/bin/drush status

# One-time admin login
../vendor/bin/drush uli

# Export configuration
../vendor/bin/drush config:export -y

# Import configuration
../vendor/bin/drush config:import -y

# Check recent logs
../vendor/bin/drush watchdog:show

# Run cron manually
../vendor/bin/drush cron
```

---

## Support

- **Nexcess Support**: https://www.nexcess.net/support/
- **Nexcess Documentation**: https://help.nexcess.net/

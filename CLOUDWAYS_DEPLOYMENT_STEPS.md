# Cloudways Production Deployment - Step by Step

**Production URL:** https://phpstack-969836-6003258.cloudwaysapps.com
**Date:** 2025-11-16

**CLOUDWAYS PATHS (After Restructure):**
- Application Root: `/home/969836.cloudwaysapps.com/wdzpzmmtxg`
- Public HTML: `/home/969836.cloudwaysapps.com/wdzpzmmtxg/public_html`
- Web Root: `/home/969836.cloudwaysapps.com/wdzpzmmtxg/public_html/web`
- Composer: `/home/969836.cloudwaysapps.com/wdzpzmmtxg/public_html/composer.json`
- Config: `/home/969836.cloudwaysapps.com/wdzpzmmtxg/public_html/config`

**NOTE:** Repository was restructured on 2025-11-16. Old `drupal10/` subdirectory removed.

---

## 📋 Deployment Checklist

### ✅ Step 1: SSH into Cloudways

**Method A: Manual SSH (Termius or Terminal)**
```bash
ssh kocsid10ssh@165.22.200.254 -p 22
# Password: KCSIssH3497!
```

**Method B: SSH from Claude Code (Using Expect Scripts)**

Claude Code can automate SSH connections using expect scripts. Here's the working method:

```bash
# Create expect script for SSH command
cat > /tmp/ssh_cmd.sh << 'EOF'
#!/usr/bin/expect -f
set timeout 30
spawn ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no kocsid10ssh@165.22.200.254 "YOUR_COMMAND_HERE"
expect "password:"
send "KCSIssH3497!\r"
expect eof
EOF

# Make executable and run
chmod +x /tmp/ssh_cmd.sh
/tmp/ssh_cmd.sh
```

**Example: Check current directory**
```bash
cat > /tmp/ssh_cmd.sh << 'EOF'
#!/usr/bin/expect -f
set timeout 30
spawn ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no kocsid10ssh@165.22.200.254 "pwd && ls -la"
expect "password:"
send "KCSIssH3497!\r"
expect eof
EOF
chmod +x /tmp/ssh_cmd.sh
/tmp/ssh_cmd.sh
```

**Important SSH Notes:**
- Direct `ssh` or `sshpass` commands fail with "Too many authentication failures"
- Expect scripts with proper options work reliably
- Must use: `-o PreferredAuthentications=password -o PubkeyAuthentication=no`
- Server may rate-limit after many rapid connections

### ✅ Step 2: Verify Directory Structure

**VERIFIED ACTUAL STRUCTURE:**
```bash
# You start in:
/home/969836.cloudwaysapps.com/wdzpzmmtxg

# Directory listing shows:
drwxrwxr-x   2 wdzpzmmtxg www-data   4096 private_html
drwxrwxr-x   5 wdzpzmmtxg www-data   4096 public_html  ← Your application
drwxr-xr-x   6 root       root       4096 git_repo
drwxr-xr-x   2 root       root       4096 logs
drwxr-xr-x   2 root       root       4096 ssl
drwxrwxr-x   2 wdzpzmmtxg www-data   4096 tmp

# Navigate to application:
cd public_html
pwd
# Output: /home/969836.cloudwaysapps.com/wdzpzmmtxg/public_html
```

### ✅ Step 3: Check Git Deployment Status

**VERIFIED: Git code IS deployed!**

```bash
# From public_html directory:
ls -la

# ACTUAL OUTPUT (Verified 2025-11-16):
total 104
drwxrwxr-x   5 wdzpzmmtxg www-data    4096 Nov 16 09:58 .
drwxr-xr-x+ 10 root       wdzpzmmtxg  4096 Nov 16 10:24 ..
-rw-rw-r--   1 wdzpzmmtxg www-data    6023 PORTO_THEME_STATUS.txt
-rw-rw-r--   1 wdzpzmmtxg www-data     154 README.md
-rwxrwxr-x   1 wdzpzmmtxg www-data    6892 discover_d7_filesystem.sh
-rw-rw-r--   1 wdzpzmmtxg www-data    2078 docker-compose.d10.yml
-rw-rw-r--   1 wdzpzmmtxg www-data    2122 docker-compose.d7.yml
drwxrwxr-x   9 wdzpzmmtxg www-data    4096 docs/                 ✓
-rwxrwxr-x   1 wdzpzmmtxg www-data    7248 download_missing_files.sh
-rwxrwxr-x   1 wdzpzmmtxg www-data    4682 download_priority_files.sh
drwxrwxr-x   4 wdzpzmmtxg www-data    4096 drupal10/             ✓
-rw-rw-r--   1 wdzpzmmtxg www-data   36019 index.php
-rw-rw-r--   1 wdzpzmmtxg www-data    3242 nginx.conf
drwxrwxr-x   4 wdzpzmmtxg www-data    4096 scripts/              ✓
```

**Git Deployment: ✅ COMPLETE**

If code is NOT deployed:
1. Go to Cloudways Platform web interface
2. Navigate to: Application > Deployment Via Git
3. Click "Pull" button to deploy code
4. Wait for deployment to complete
5. Return and verify with `ls -la`

### ✅ Step 4: Check Composer Dependencies Status

**VERIFIED: Composer dependencies NOT YET installed**

```bash
cd drupal10
ls -la

# ACTUAL OUTPUT (Verified 2025-11-16):
total 292
drwxrwxr-x 4 wdzpzmmtxg www-data   4096 drupal10/
drwxrwxr-x 5 wdzpzmmtxg www-data   4096 ..
-rw-rw-r-- 1 wdzpzmmtxg www-data    357 .editorconfig
-rw-rw-r-- 1 wdzpzmmtxg www-data   3909 composer.json         ✓
-rw-rw-r-- 1 wdzpzmmtxg www-data 273481 composer.lock         ✓
drwxrwxr-x 3 wdzpzmmtxg www-data   4096 config/               ✓
drwxrwxr-x 5 wdzpzmmtxg www-data   4096 web/                  ✓
# NO vendor/ directory!                                        ✗

# Verify vendor is missing:
ls -la vendor/ 2>&1
# Output: ls: cannot access 'vendor/': No such file or directory
```

**Composer Status: ❌ NOT INSTALLED - This is expected and REQUIRED next step**

### ✅ Step 5: Install Composer Dependencies
```bash
cd drupal10

# Install all dependencies (this will take a few minutes)
composer install --no-dev --optimize-autoloader

# Verify vendor directory exists
ls -la vendor/
ls -la vendor/bin/drush
```

### ✅ Step 5: Update settings.php with Production Credentials
```bash
cd web/sites/default

# Backup original settings.php
cp settings.php settings.php.backup

# Edit settings.php
nano settings.php
```

**Add/Update these sections in settings.php:**

```php
<?php

/**
 * Production Database Configuration
 */
$databases['default']['default'] = array (
  'database' => 'wdzpzmmtxg',
  'username' => 'wdzpzmmtxg',
  'password' => 'fyQuAvP74q',
  'prefix' => '',
  'host' => 'localhost',
  'port' => '3306',
  'isolation_level' => 'READ COMMITTED',
  'driver' => 'mysql',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
);

/**
 * Configuration sync directory
 */
$settings['config_sync_directory'] = '../config/sync';

/**
 * Trusted host patterns
 */
$settings['trusted_host_patterns'] = [
  '^phpstack-969836-6003258\.cloudwaysapps\.com$',
  '^www\.kocsibeallo\.hu$',
  '^kocsibeallo\.hu$',
];

/**
 * File paths
 */
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = 'sites/default/files/private';

/**
 * Redis Cache Configuration (Cloudways includes Redis)
 */
if (extension_loaded('redis')) {
  $settings['redis.connection']['interface'] = 'PhpRedis';
  $settings['redis.connection']['host'] = 'localhost';
  $settings['redis.connection']['port'] = '6379';
  $settings['redis.connection']['base'] = 'wdzpzmmtxg';
  $settings['redis.connection']['password'] = 'ccp5TKzJx4';

  $settings['cache']['default'] = 'cache.backend.redis';
  $settings['cache']['bins']['bootstrap'] = 'cache.backend.chainedfast';
  $settings['cache']['bins']['discovery'] = 'cache.backend.chainedfast';
  $settings['cache']['bins']['config'] = 'cache.backend.chainedfast';

  $settings['container_yamls'][] = 'modules/contrib/redis/example.services.yml';
  $settings['container_yamls'][] = 'modules/contrib/redis/redis.services.yml';
}

/**
 * Hash salt (generate a new one or use existing)
 */
$settings['hash_salt'] = 'GENERATE_A_NEW_HASH_SALT_HERE';
```

**Save and exit** (Ctrl+X, Y, Enter)

### ✅ Step 6: Create Required Directories
```bash
# Navigate back to web directory
cd /path/to/application/public_html/drupal10/web

# Create files directories
mkdir -p sites/default/files
mkdir -p sites/default/files/private
chmod 777 sites/default/files
chmod 777 sites/default/files/private
```

### ✅ Step 7: Import Database

**Option A: If you have a database dump locally**
```bash
# From your LOCAL machine, upload database dump
scp -P 22 /path/to/database-dump.sql kocsid10ssh@165.22.200.254:/home/kocsid10ssh/

# Then on Cloudways server:
mysql -u wdzpzmmtxg -pfyQuAvP74q wdzpzmmtxg < /home/kocsid10ssh/database-dump.sql
```

**Option B: From Cloudways, connect to D10 local database**
```bash
# If you want to export from local and import to production
# First, export from local:
# (Run this on your LOCAL machine)
docker exec pajfrsyfzm-d10-mariadb mysqldump -udrupal -pdrupal drupal10 > /tmp/prod-export.sql

# Then upload to Cloudways:
scp -P 22 /tmp/prod-export.sql kocsid10ssh@165.22.200.254:/home/kocsid10ssh/

# Import on Cloudways:
mysql -u wdzpzmmtxg -pfyQuAvP74q wdzpzmmtxg < /home/kocsid10ssh/prod-export.sql
```

### ✅ Step 8: Enable Redis Module
```bash
cd /path/to/application/public_html/drupal10/web

# Enable Redis module
../vendor/bin/drush en redis -y

# Verify it's enabled
../vendor/bin/drush pml | grep redis
```

### ✅ Step 9: Import Configuration
```bash
cd /path/to/application/public_html/drupal10/web

# Import all configuration
../vendor/bin/drush config:import -y

# If errors occur, try force import
../vendor/bin/drush config:import -y --source=../config/sync
```

### ✅ Step 10: Run Database Updates
```bash
# Run all pending database updates
../vendor/bin/drush updatedb -y
```

### ✅ Step 11: Clear Cache
```bash
# Clear all caches
../vendor/bin/drush cr

# Rebuild cache
../vendor/bin/drush rebuild
```

### ✅ Step 12: Set Proper File Permissions
```bash
cd /path/to/application/public_html/drupal10

# Set directory permissions
chmod -R 755 web/
chmod -R 777 web/sites/default/files/
```

### ✅ Step 13: Create Admin User Login Link
```bash
cd /path/to/application/public_html/drupal10/web

# Generate one-time login link
../vendor/bin/drush uli

# This will give you a URL like:
# https://phpstack-969836-6003258.cloudwaysapps.com/user/reset/...
```

### ✅ Step 14: Verify Site is Working
```bash
# Check site status
../vendor/bin/drush status

# Should show:
# - Drupal version: 10.x
# - Database: Connected
# - Bootstrap: Successful
```

**Visit in browser:**
- https://phpstack-969836-6003258.cloudwaysapps.com
- Use the one-time login link from Step 13

---

## 🔍 Troubleshooting

### Database Connection Errors
```bash
# Test database connection
mysql -u wdzpzmmtxg -pfyQuAvP74q wdzpzmmtxg -e "SHOW TABLES;"

# If fails, check settings.php credentials
```

### Composer Issues
```bash
# Clear composer cache
cd drupal10
composer clear-cache
composer install --no-dev
```

### Permission Issues
```bash
# Fix all permissions
cd drupal10
chmod -R 755 .
chmod -R 777 web/sites/default/files
```

### Configuration Import Fails
```bash
# Check config directory exists and has files
ls -la drupal10/config/sync/ | wc -l
# Should show 1000+ files

# Force import
cd drupal10/web
../vendor/bin/drush config:import -y --source=../config/sync
```

---

## 📝 Post-Deployment Tasks

- [ ] Change admin password
- [ ] Test all functionality
- [ ] Verify webforms work
- [ ] Check blog posts display correctly
- [ ] Test gallery
- [ ] Verify Redis cache is working: `drush cr` should be fast
- [ ] Set up SSL certificate (Cloudways auto SSL)
- [ ] Point domain www.kocsibeallo.hu to Cloudways (when ready)

---

**Deployment Date:** 2025-11-16
**Production URL:** https://phpstack-969836-6003258.cloudwaysapps.com

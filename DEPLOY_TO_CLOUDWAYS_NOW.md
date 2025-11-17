# Deploy to Cloudways Production - Quick Start Guide

**Date:** 2025-11-16
**Production URL:** https://phpstack-969836-6003258.cloudwaysapps.com

---

## 🚀 What's Ready

I've prepared everything you need for deployment:

✅ **Database export ready:** `cloudways-db-export.sql` (36MB, 16,083 lines)
✅ **Full deployment script ready:** `scripts/cloudways/production-deploy-full.sh`
✅ **Post-deployment script ready:** `scripts/cloudways/post-deploy.sh`
✅ **Production credentials documented:** `.credentials` file

---

## 📋 Deployment Methods

### Option A: Automated Script (Recommended - Run in Termius)

Since SSH password authentication works from your Termius client, here's the complete deployment process:

#### Step 1: Upload Database to Cloudways

**On your local machine:**
```bash
# Upload the database export to Cloudways
scp -P 22 /Volumes/T9/Sites/kocsibeallo-hu/cloudways-db-export.sql SSH_USER (see .credentials)@D7_HOST (see .credentials):/home/SSH_USER (see .credentials)/
```

When prompted, enter password: `SSH_PASSWORD (see .credentials)`

#### Step 2: Upload Deployment Script

```bash
# Upload the deployment script
scp -P 22 /Volumes/T9/Sites/kocsibeallo-hu/scripts/cloudways/production-deploy-full.sh SSH_USER (see .credentials)@D7_HOST (see .credentials):/home/SSH_USER (see .credentials)/
```

#### Step 3: SSH into Cloudways (via Termius or Terminal)

**In Termius or Terminal:**
```bash
ssh SSH_USER (see .credentials)@D7_HOST (see .credentials) -p 22
# Password: SSH_PASSWORD (see .credentials)
```

#### Step 4: Locate Your Application Directory

```bash
# Check current location
pwd

# List applications
ls -la

# Navigate to applications directory
cd applications/
ls -la

# Find your application (look for kocsibeallo or similar)
# Then navigate to it
cd [your-application-name]/public_html
pwd
```

**Expected path:** `/home/SSH_USER (see .credentials)/applications/[app-name]/public_html`

#### Step 5: Check Git Deployment Status

```bash
# List contents
ls -la

# You should see:
# - drupal10/
# - docs/
# - scripts/
# - README.md
```

**If you DON'T see these files:**
1. Go to Cloudways admin panel
2. Navigate to: Application > Deployment Via Git
3. Click **"Pull"** button to deploy code from GitHub
4. Wait for deployment to complete
5. Return to SSH and check again: `ls -la`

#### Step 6: Run the Deployment Script

```bash
# Copy the deployment script to current directory
cp ~/production-deploy-full.sh .
chmod +x production-deploy-full.sh

# Run the deployment
./production-deploy-full.sh
```

The script will:
1. ✓ Verify directory structure
2. ✓ Check if Git code is deployed
3. ✓ Install Composer dependencies
4. ✓ Create required directories
5. ✓ Prompt you to verify settings.php
6. ✓ Ask if you want to import database
7. ✓ Enable Redis module
8. ✓ Import Drupal configuration
9. ✓ Run database updates
10. ✓ Clear cache
11. ✓ Set permissions
12. ✓ Generate admin login link
13. ✓ Show site status

#### Step 7: Import Database (when prompted)

When the script asks: "Do you have a database dump to import? (y/n)"

Enter: `y`

When it asks for the path, enter:
```
/home/SSH_USER (see .credentials)/cloudways-db-export.sql
```

#### Step 8: Verify Settings.php (when prompted)

The script will pause and ask you to verify `settings.php`. You need to ensure it contains the production credentials.

**Option 1: Edit settings.php now**

In another terminal window, SSH in again and edit:
```bash
cd /home/SSH_USER (see .credentials)/applications/[app-name]/public_html/drupal10/web/sites/default
nano settings.php
```

Add or update these sections:

```php
/**
 * Production Database Configuration
 */
$databases['default']['default'] = array (
  'database' => 'DB_USER (see .credentials)',
  'username' => 'DB_USER (see .credentials)',
  'password' => 'DB_PASSWORD (see .credentials)',
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
  '^phpstack-969836-6003258\\.cloudwaysapps\\.com$',
  '^www\\.kocsibeallo\\.hu$',
  '^kocsibeallo\\.hu$',
];

/**
 * File paths
 */
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = 'sites/default/files/private';

/**
 * Redis Cache Configuration
 */
if (extension_loaded('redis')) {
  $settings['redis.connection']['interface'] = 'PhpRedis';
  $settings['redis.connection']['host'] = 'localhost';
  $settings['redis.connection']['port'] = '6379';
  $settings['redis.connection']['base'] = 'DB_USER (see .credentials)';
  $settings['redis.connection']['password'] = 'ccp5TKzJx4';

  $settings['cache']['default'] = 'cache.backend.redis';
  $settings['cache']['bins']['bootstrap'] = 'cache.backend.chainedfast';
  $settings['cache']['bins']['discovery'] = 'cache.backend.chainedfast';
  $settings['cache']['bins']['config'] = 'cache.backend.chainedfast';

  $settings['container_yamls'][] = 'modules/contrib/redis/example.services.yml';
  $settings['container_yamls'][] = 'modules/contrib/redis/redis.services.yml';
}

/**
 * Hash salt
 */
$settings['hash_salt'] = 'YOUR_EXISTING_HASH_SALT_OR_GENERATE_NEW_ONE';
```

**Save:** Ctrl+X, Y, Enter

Then press Enter in the deployment script window to continue.

**Option 2: Skip and do it later**

Just press Enter to continue, but you'll need to update settings.php manually before the site works.

---

### Option B: Manual Step-by-Step (If Script Doesn't Work)

If the automated script has issues, follow these manual steps:

#### 1. SSH into Cloudways
```bash
ssh SSH_USER (see .credentials)@D7_HOST (see .credentials) -p 22
# Password: SSH_PASSWORD (see .credentials)
```

#### 2. Navigate to Application
```bash
cd applications/[app-name]/public_html
```

#### 3. Verify Git Deployment
```bash
ls -la
# Should see: drupal10/, docs/, scripts/, README.md
```

If not, pull from Cloudways admin panel first.

#### 4. Install Composer Dependencies
```bash
cd drupal10
composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader
```

#### 5. Create Directories
```bash
mkdir -p web/sites/default/files
mkdir -p web/sites/default/files/private
chmod 777 web/sites/default/files
chmod 777 web/sites/default/files/private
```

#### 6. Update settings.php
```bash
cd web/sites/default
nano settings.php
```

Add the production configuration (see Option A, Step 8 above).

#### 7. Import Database
```bash
mysql -u DB_USER (see .credentials) -pDB_PASSWORD (see .credentials) DB_USER (see .credentials) < /home/SSH_USER (see .credentials)/cloudways-db-export.sql
```

#### 8. Enable Redis
```bash
cd /home/SSH_USER (see .credentials)/applications/[app-name]/public_html/drupal10/web
../vendor/bin/drush en redis -y
```

#### 9. Import Configuration
```bash
../vendor/bin/drush config:import -y
```

#### 10. Run Updates
```bash
../vendor/bin/drush updatedb -y
```

#### 11. Clear Cache
```bash
../vendor/bin/drush cr
```

#### 12. Get Admin Link
```bash
../vendor/bin/drush uli
```

Copy the URL and open it in your browser.

---

## ✅ Verification Steps

After deployment completes:

1. **Visit Production URL:**
   https://phpstack-969836-6003258.cloudwaysapps.com

2. **Use Admin Login Link** (from script output)

3. **Check Site Status:**
   ```bash
   cd drupal10/web
   ../vendor/bin/drush status
   ```

4. **Verify Redis:**
   ```bash
   ../vendor/bin/drush cr
   # Should complete quickly if Redis is working
   ```

5. **Test Functionality:**
   - [ ] Homepage loads
   - [ ] Blog posts visible
   - [ ] Gallery works
   - [ ] Webforms load
   - [ ] Admin panel accessible

---

## 🔧 Troubleshooting

### Database Connection Errors
```bash
# Test database connection
mysql -u DB_USER (see .credentials) -pDB_PASSWORD (see .credentials) DB_USER (see .credentials) -e "SHOW TABLES;"
```

If this fails, verify database credentials in settings.php.

### Configuration Import Fails
```bash
# Check if config files exist
ls -la drupal10/config/sync/ | wc -l
# Should show 1000+ files

# Force import
cd drupal10/web
../vendor/bin/drush config:import -y --source=../config/sync
```

### Permission Issues
```bash
cd drupal10
chmod -R 755 .
chmod -R 777 web/sites/default/files
```

### Composer Issues
```bash
cd drupal10
composer clear-cache
composer install --no-dev
```

---

## 📞 Next Steps After Successful Deployment

1. **Change Admin Password** (via admin login link)
2. **Test All Features** thoroughly
3. **Set Up Cloudways Auto SSL** (in Cloudways admin panel)
4. **Configure Automatic Backups** (Cloudways > Backup)
5. **Point Domain** www.kocsibeallo.hu to Cloudways (when ready)

---

## 📚 Reference Files

- **Full credentials:** `.credentials`
- **Deployment scripts:** `scripts/cloudways/`
- **Documentation:** `docs/CLOUDWAYS_DEPLOYMENT.md`
- **Step-by-step guide:** `CLOUDWAYS_DEPLOYMENT_STEPS.md`

---

**Questions or issues?** Check the troubleshooting section or refer to the detailed documentation.

**Production URL:** https://phpstack-969836-6003258.cloudwaysapps.com

---

**Last Updated:** 2025-11-16

# Cloudways Production Deployment Guide

Complete guide for deploying the Drupal 10 site to Cloudways production environment.

## 🌐 Overview

**Production Environment:** Cloudways Managed Hosting
**Live Site:** https://www.kocsibeallo.hu
**Repository:** https://github.com/ArcanianAi/kocsibeallo-d7-d10-migration

---

## 🔄 How Cloudways Git Deployment Works

Cloudways provides Git integration with two deployment modes:

### 1. Manual Deployment (Default)
- Log into Cloudways admin panel
- Navigate to **Application > Deployment Via Git**
- Click **Pull** button to pull latest changes

### 2. Automatic Deployment (Recommended - With Webhooks)
- Configure webhook in GitHub repository
- Every push to `main` branch automatically triggers deployment
- Cloudways pulls latest code automatically

**⚠️ IMPORTANT:** Neither mode automatically runs Composer or Drush commands!

---

## ⚙️ Initial Cloudways Setup (One-Time)

### Step 1: Generate SSH Key in Cloudways

1. Log into Cloudways Platform
2. Navigate to your application
3. Go to **Deployment Via Git** section
4. Click **Generate SSH Key**
5. Copy the generated SSH public key

### Step 2: Add SSH Key to GitHub

1. Go to https://github.com/ArcanianAi/kocsibeallo-d7-d10-migration
2. Navigate to **Settings > Deploy keys**
3. Click **Add deploy key**
4. Paste the SSH key from Cloudways
5. Give it a title: "Cloudways Production"
6. **DO NOT** check "Allow write access"
7. Click **Add key**

### Step 3: Connect Repository in Cloudways

1. In Cloudways **Deployment Via Git** section
2. Enter Git Remote Address:
   ```
   git@github.com:ArcanianAi/kocsibeallo-d7-d10-migration.git
   ```
3. Enter Branch Name: `main`
4. Enter Deployment Path (important!):
   ```
   /
   ```
   Or if codebase is in subdirectory:
   ```
   /drupal10
   ```
5. Click **Save**

### Step 4: Initial Code Pull

1. Click **Pull** button in Cloudways
2. Wait for deployment to complete
3. Verify files are in place via SFTP or SSH

### Step 5: SSH Access and Post-Deployment

1. Get SSH credentials from Cloudways (Application > Access Details)
2. SSH into server:
   ```bash
   ssh master@server-ip -p port
   ```
3. Navigate to application:
   ```bash
   cd applications/[app-name]/public_html
   ```

---

## 🚀 Cloudways Deployment Workflow

### Automatic Deployment (With Webhooks)

If webhooks are configured, deployment happens automatically:

```
1. Developer pushes to GitHub main branch
   ↓
2. GitHub webhook triggers Cloudways
   ↓
3. Cloudways pulls latest code automatically
   ↓
4. Developer must SSH in and run post-deployment script
```

### Post-Deployment Steps (REQUIRED - Must Run Manually)

After Git pull completes (automatic or manual):

```bash
# 1. SSH into Cloudways server
ssh master@server-ip -p port

# 2. Navigate to application
cd applications/[app-name]/public_html

# 3. Run post-deployment script
./scripts/cloudways/post-deploy.sh
```

**Or run commands manually:**

```bash
# Navigate to Drupal directory
cd drupal10

# Install/Update Composer dependencies
composer install --no-dev --optimize-autoloader

# Run Drush commands
cd web
../vendor/bin/drush state:set system.maintenance_mode 1 --input-format=integer
../vendor/bin/drush config:import -y
../vendor/bin/drush updatedb -y
../vendor/bin/drush cr
../vendor/bin/drush state:set system.maintenance_mode 0 --input-format=integer
```

---

## 📝 Post-Deployment Script

We've created an automated post-deployment script for you:

**Location:** `scripts/cloudways/post-deploy.sh`

**Usage:**
```bash
cd /path/to/application
./scripts/cloudways/post-deploy.sh
```

**What it does:**
1. Installs Composer dependencies
2. Puts site in maintenance mode
3. Imports configuration changes
4. Runs database updates
5. Clears cache
6. Takes site out of maintenance mode
7. Reports success or errors

---

## 🔧 Setting Up Automatic Webhooks

### Option 1: Using Cloudways API (Recommended)

1. **Get Cloudways API Key:**
   - Log into Cloudways
   - Go to **Account > API**
   - Generate API key if you don't have one

2. **Create webhook endpoint script** (already created in repo)
   Location: `scripts/cloudways/webhook-endpoint.php`

3. **Configure GitHub Webhook:**
   - Go to GitHub repository settings
   - Navigate to **Webhooks**
   - Click **Add webhook**
   - Payload URL: `https://www.kocsibeallo.hu/webhook-deploy.php`
   - Content type: `application/json`
   - Secret: (optional, for security)
   - Select: "Just the push event"
   - Click **Add webhook**

### Option 2: Using GitHub Actions

Alternatively, use GitHub Actions to trigger deployment:

**File:** `.github/workflows/deploy-production.yml` (already created)

This automatically deploys when you push to `main` branch.

---

## 📁 Cloudways Directory Structure

**Important:** Understand where files go on Cloudways:

```
/home/master/applications/[app-name]/
├── public_html/              # Your application root (Git pulls here)
│   ├── drupal10/             # Drupal 10 installation
│   │   ├── composer.json
│   │   ├── config/
│   │   ├── vendor/           # Generated by composer install
│   │   └── web/
│   │       ├── core/         # Generated by composer install
│   │       ├── modules/
│   │       ├── themes/
│   │       └── sites/
│   │           └── default/
│   │               ├── settings.php
│   │               └── files/
│   ├── docs/
│   ├── scripts/
│   └── README.md
└── logs/
```

---

## 🔐 Production Settings.php

**Important:** Production `settings.php` needs different database credentials!

### Update Database Settings

SSH into Cloudways and edit:
```bash
nano drupal10/web/sites/default/settings.php
```

**Production database settings:**
```php
$databases['default']['default'] = array (
  'database' => 'cloudways_db_name',
  'username' => 'cloudways_db_user',
  'password' => 'cloudways_db_password',
  'host' => 'localhost',
  'port' => '3306',
  'driver' => 'mysql',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
);
```

**Get credentials from:**
Cloudways > Application > Access Details > Database Access

### Trusted Host Patterns

```php
$settings['trusted_host_patterns'] = [
  '^www\.kocsibeallo\.hu$',
  '^kocsibeallo\.hu$',
];
```

### File Paths

```php
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = 'sites/default/files/private';
```

### Redis Cache Configuration

**Cloudways includes Redis by default!** Configure it in settings.php:

```php
/**
 * Redis configuration (Cloudways includes Redis)
 * Get Redis password from: Cloudways > Application > Access Details
 */
if (extension_loaded('redis')) {
  $settings['redis.connection']['interface'] = 'PhpRedis';
  $settings['redis.connection']['host'] = 'localhost';
  $settings['redis.connection']['port'] = '6379';
  // $settings['redis.connection']['password'] = 'your-redis-password';

  $settings['cache']['default'] = 'cache.backend.redis';
  $settings['cache']['bins']['bootstrap'] = 'cache.backend.chainedfast';
  $settings['cache']['bins']['discovery'] = 'cache.backend.chainedfast';
  $settings['cache']['bins']['config'] = 'cache.backend.chainedfast';
}
```

**Enable Redis module:**
```bash
cd drupal10/web
../vendor/bin/drush en redis -y
```

### Config Sync Directory

```php
$settings['config_sync_directory'] = '../config/sync';
```

---

## 🚨 Deployment Checklist

### Before Deployment

- [ ] All changes committed to Git
- [ ] Pushed to `main` branch on GitHub
- [ ] Tested locally in Docker environment
- [ ] Configuration exported (`drush config:export`)
- [ ] Database backup created (if needed)

### After Automatic Pull (Every Deployment)

- [ ] SSH into Cloudways server
- [ ] Navigate to application directory
- [ ] Run post-deployment script:
  ```bash
  ./scripts/cloudways/post-deploy.sh
  ```
- [ ] Verify site is working
- [ ] Check for errors in logs
- [ ] Test critical functionality

### If Issues Occur

- [ ] Check Cloudways deployment logs
- [ ] Check Drupal logs: `drush watchdog:show`
- [ ] Verify file permissions
- [ ] Check `settings.php` database credentials
- [ ] Review recent commits in GitHub

---

## ⚡ Quick Deployment Commands

### Manual Pull (If webhook not working)

```bash
# In Cloudways admin panel:
# Application > Deployment Via Git > Click "Pull" button
```

### After Any Pull - Run This

```bash
# SSH into server
ssh master@server-ip -p port

# Navigate to app
cd applications/[app-name]/public_html

# Run post-deploy
./scripts/cloudways/post-deploy.sh
```

---

## 🔍 Troubleshooting

### "Permission denied" during deployment

**Fix file permissions:**
```bash
# SSH into Cloudways
cd applications/[app-name]/public_html
chmod -R 755 drupal10/
chmod -R 777 drupal10/web/sites/default/files/
```

### Composer install fails

**Clear Composer cache:**
```bash
cd drupal10
composer clear-cache
composer install --no-dev --optimize-autoloader
```

### Configuration import fails

**Check config directory:**
```bash
ls -la drupal10/config/sync/
# Should show 1000+ .yml files
```

**Force import:**
```bash
cd drupal10/web
../vendor/bin/drush config:import -y --source=../config/sync
```

### Database connection errors

**Verify credentials:**
```bash
# Check Cloudways database credentials
# Update settings.php with correct values
nano drupal10/web/sites/default/settings.php
```

### Site stuck in maintenance mode

**Turn off maintenance mode:**
```bash
cd drupal10/web
../vendor/bin/drush state:set system.maintenance_mode 0 --input-format=integer
../vendor/bin/drush cr
```

---

## 📊 Cloudways vs Local Differences

| Feature | Local (Docker) | Cloudways (Production) |
|---------|----------------|------------------------|
| **Deployment** | Git commit/push | Webhook auto-pull + SSH commands |
| **Composer** | Automatic (in container) | Manual SSH execution required |
| **Drush** | `docker exec` commands | SSH then run drush |
| **Database** | Docker MariaDB | Cloudways MySQL |
| **Files** | Local volume mount | Cloudways filesystem |
| **Cache** | Redis (optional) | Cloudways Redis (if enabled) |

---

## 🎯 Best Practices for Cloudways

### 1. Always Use Post-Deployment Script

Never rely on Git pull alone - always run post-deployment commands.

### 2. Backup Before Major Updates

```bash
# In Cloudways admin panel:
# Application > Backup and Restore > Take Backup Now
```

### 3. Test in Staging First

- Set up a staging application on Cloudways
- Deploy to staging first
- Test thoroughly
- Then deploy to production

### 4. Monitor Deployments

- Check Cloudways deployment logs
- Monitor Drupal watchdog: `drush watchdog:show`
- Set up New Relic or application monitoring

### 5. Keep settings.php Secure

- Never commit production database credentials
- Use environment variables if possible
- Keep different settings for local vs production

---

## 📱 Cloudways Platform Access

**Access your application:**
- **Platform:** https://platform.cloudways.com
- **SFTP/SSH:** Application > Access Details
- **Database:** Application > Access Details > Database Access
- **Deployment Logs:** Application > Deployment Via Git

---

## 🔄 Complete Deployment Workflow Summary

### Every Time You Deploy

```bash
# 1. LOCAL: Make changes and commit
git add .
git commit -m "Your changes"
git push origin main

# 2. CLOUDWAYS: Automatic pull (if webhook configured)
# OR manually click "Pull" in Cloudways admin

# 3. SSH INTO CLOUDWAYS: Run post-deployment
ssh master@server-ip -p port
cd applications/[app-name]/public_html
./scripts/cloudways/post-deploy.sh

# 4. VERIFY: Check site is working
# Visit https://www.kocsibeallo.hu
```

---

## 📚 Related Documentation

- **Local Deployment:** `docs/DEPLOYMENT_GUIDE.md`
- **Restructure Plan:** `docs/RESTRUCTURE_PLAN.md`
- **Environment URLs:** `docs/ENVIRONMENT_URLS.md`
- **Cloudways Docs:** https://support.cloudways.com

---

## 🆘 Support Resources

- **Cloudways Support:** https://support.cloudways.com
- **Drupal Community:** https://drupal.org/support
- **Repository Issues:** https://github.com/ArcanianAi/kocsibeallo-d7-d10-migration/issues

---

**Last Updated:** 2025-11-16
**Production Site:** https://www.kocsibeallo.hu
**Repository:** https://github.com/ArcanianAi/kocsibeallo-d7-d10-migration

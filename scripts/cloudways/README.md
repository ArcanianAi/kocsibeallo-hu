# Cloudways Deployment Scripts

Scripts specifically for Cloudways production environment deployment.

## 📋 Overview

Cloudways Git integration pulls code automatically (via webhook) or manually, but **does not** run Composer or Drush commands. These scripts handle post-deployment tasks.

---

## 🚀 Post-Deployment Script

### `post-deploy.sh`

**Purpose:** Run this AFTER every Git pull to complete the deployment

**When to use:**
- After automatic webhook deployment
- After manual "Pull" in Cloudways admin
- After any code update to production

**What it does:**
1. Installs/updates Composer dependencies
2. Puts site in maintenance mode
3. Imports Drupal configuration changes
4. Runs database updates
5. Clears cache
6. Takes site out of maintenance mode

### Usage

```bash
# SSH into Cloudways server
ssh master@server-ip -p port

# Navigate to application root
cd applications/[app-name]/public_html

# Run post-deployment script
./scripts/cloudways/post-deploy.sh
```

**Output:**
```
================================================
Kocsibeallo.hu - Cloudways Post-Deployment
================================================

==> Step 1/7: Navigating to Drupal directory...
✓ In drupal10 directory

==> Step 2/7: Installing/Updating Composer dependencies...
INFO: This may take a few minutes...
✓ Composer dependencies installed

==> Step 3/7: Navigating to web directory...
✓ In web directory

==> Step 4/7: Putting site in maintenance mode...
✓ Site in maintenance mode

==> Step 5/7: Importing configuration changes...
✓ Configuration imported successfully

==> Step 6/7: Running database updates...
✓ Database updates completed

==> Step 7/7: Clearing cache and enabling site...
✓ Cache cleared
✓ Site out of maintenance mode

================================================
✓ Post-Deployment Complete!
================================================

⏱️  Total time: 45 seconds
```

---

## 🔧 Manual Commands (Alternative)

If you prefer to run commands manually instead of using the script:

```bash
# SSH into Cloudways
ssh master@server-ip -p port

# Navigate to application
cd applications/[app-name]/public_html/drupal10

# Install Composer dependencies
composer install --no-dev --optimize-autoloader

# Navigate to web directory
cd web

# Put site in maintenance mode
../vendor/bin/drush state:set system.maintenance_mode 1 --input-format=integer
../vendor/bin/drush cr

# Import configuration
../vendor/bin/drush config:import -y

# Run database updates
../vendor/bin/drush updatedb -y

# Clear cache and enable site
../vendor/bin/drush cr
../vendor/bin/drush state:set system.maintenance_mode 0 --input-format=integer
```

---

## 🔄 Complete Cloudways Deployment Workflow

### Step-by-Step Process

**1. Make changes locally:**
```bash
# Work on your local environment
# Make code changes
# Test in Docker

# Commit and push
git add .
git commit -m "Your changes"
git push origin main
```

**2. Automatic deployment (if webhook configured):**
- GitHub webhook triggers Cloudways
- Cloudways pulls latest code from `main` branch
- Code is deployed to production server
- **BUT**: Composer and Drush commands are NOT run automatically!

**3. SSH in and run post-deployment:**
```bash
ssh master@server-ip -p port
cd applications/[app-name]/public_html
./scripts/cloudways/post-deploy.sh
```

**4. Verify deployment:**
- Visit https://www.kocsibeallo.hu
- Check functionality
- Review logs if needed

---

## 🔍 Troubleshooting

### Script fails with "Permission denied"

**Fix permissions:**
```bash
chmod +x scripts/cloudways/post-deploy.sh
```

### Composer install fails

**Clear cache and retry:**
```bash
cd drupal10
composer clear-cache
composer install --no-dev --optimize-autoloader
```

### Configuration import fails

**Check config sync directory:**
```bash
ls -la drupal10/config/sync/ | wc -l
# Should show 1000+ files
```

**Force import:**
```bash
cd drupal10/web
../vendor/bin/drush config:import -y --source=../config/sync
```

### Site stuck in maintenance mode

**Manually disable:**
```bash
cd drupal10/web
../vendor/bin/drush state:set system.maintenance_mode 0 --input-format=integer
../vendor/bin/drush cr
```

### Drush not found

**Verify Composer installed it:**
```bash
cd drupal10
ls -la vendor/bin/drush
# Should exist

# If not, install dependencies:
composer install
```

---

## 📚 Additional Resources

- **Cloudways Deployment Guide:** `docs/CLOUDWAYS_DEPLOYMENT.md`
- **General Deployment:** `docs/DEPLOYMENT_GUIDE.md`
- **Cloudways Support:** https://support.cloudways.com
- **GitHub Repository:** https://github.com/ArcanianAi/kocsibeallo-d7-d10-migration

---

## 🎯 Best Practices

1. **Always run post-deploy after Git pull** - Never assume deployment is complete without it
2. **Monitor the output** - Watch for errors or warnings
3. **Test immediately** - Visit the site right after deployment
4. **Keep backups** - Take Cloudways backup before major deployments
5. **Check logs** - Use `drush watchdog:show` to check for errors

---

**Last Updated:** 2025-11-16
**Production Site:** https://www.kocsibeallo.hu

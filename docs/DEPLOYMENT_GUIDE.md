# Deployment Guide - Kocsibeallo.hu Drupal 10

Complete guide for deploying the Drupal 10 site from Git repository.

## Prerequisites

- Docker and Docker Compose installed
- Git installed
- At least 10GB disk space
- Database dump file (not included in repo)
- Files backup (optional, for sites/default/files/)

---

## Initial Setup (First Time)

### Step 1: Clone the Repository

```bash
git clone https://github.com/ArcanianAi/kocsibeallo-d7-d10-migration.git
cd kocsibeallo-d7-d10-migration
```

### Step 2: Run Setup Script

The automated setup script will:
- Install Composer dependencies
- Create necessary directories
- Start Docker containers
- Configure the environment

```bash
./scripts/deployment/setup.sh
```

**OR** follow manual steps below.

---

## Manual Setup Steps

### 1. Install Composer Dependencies

```bash
cd drupal10
composer install --no-interaction --prefer-dist --optimize-autoloader
cd ..
```

This will install:
- Drupal core
- All contrib modules (Porto theme, Webform, Search API, etc.)
- Drush and other dependencies

### 2. Create Necessary Directories

```bash
mkdir -p drupal10/web/sites/default/files
chmod 777 drupal10/web/sites/default/files
```

### 3. Configure Settings

Update `drupal10/web/sites/default/settings.php` with your database credentials:

```php
$databases['default']['default'] = array (
  'database' => 'drupal10',
  'username' => 'drupal',
  'password' => 'drupal',
  'host' => 'drupal10-db',
  'port' => '3306',
  'driver' => 'mysql',
);
```

**For D7 migration connection:**
```php
$databases['migrate']['default'] = array (
  'database' => 'pajfrsyfzm',
  'username' => 'root',
  'password' => 'root',
  'host' => 'drupal7-db',
  'port' => '3306',
  'driver' => 'mysql',
);
```

### 4. Start Docker Containers

```bash
docker-compose -f docker-compose.d10.yml up -d
```

Wait for containers to start:
```bash
docker ps
```

### 5. Import Database

Option A: Import from SQL dump
```bash
docker exec -i pajfrsyfzm-d10-db mysql -udrupal -pdrupal drupal10 < /path/to/database-dump.sql
```

Option B: Use the database from the migration process
```bash
# Database should already be in place if continuing migration
```

### 6. Import Configuration

```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:import -y"
```

### 7. Run Database Updates

```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush updatedb -y"
```

### 8. Clear Cache

```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"
```

### 9. (Optional) Copy Files Directory

If you have a backup of uploaded files:

```bash
# From local backup
cp -R /path/to/files/backup/* drupal10/web/sites/default/files/

# OR from production server
rsync -avz user@production:/path/to/files/ drupal10/web/sites/default/files/

# Set permissions
chmod -R 777 drupal10/web/sites/default/files/
```

---

## Accessing the Site

After deployment:

- **Website:** http://localhost:8090
- **Admin:** http://localhost:8090/user/login
  - Username: `admin`
  - Password: `admin123` (change in production!)

- **phpMyAdmin:** http://localhost:8082
  - Server: `drupal10-db`
  - Username: `drupal`
  - Password: `drupal`

- **Database Connection:**
  - Host: `localhost`
  - Port: `8306`
  - Database: `drupal10`
  - Username: `drupal`
  - Password: `drupal`

---

## Quick Reference - Local Docker Commands

The Docker CLI container name is `pajfrsyfzm-d10-cli`. Use these simplified commands for common operations:

### Clear Cache (Most Common)
```bash
docker exec pajfrsyfzm-d10-cli drush cr
```

### Import Configuration
```bash
docker exec pajfrsyfzm-d10-cli drush config:import -y
```

### Run Database Updates
```bash
docker exec pajfrsyfzm-d10-cli drush updatedb -y
```

### Check Drupal Status
```bash
docker exec pajfrsyfzm-d10-cli drush status
```

### List Running Containers
```bash
docker ps | grep pajfrsyfzm
```

### View Logs
```bash
docker logs pajfrsyfzm-d10-cli
```

### Interactive Shell Access
```bash
docker exec -it pajfrsyfzm-d10-cli bash
```

**Note:** The `drush` command is available directly in the container's PATH, so you don't need to specify the full path (`../vendor/bin/drush`).

---

## Updating the Site (Pull Latest Changes)

### Step 1: Pull Latest Code

```bash
cd kocsibeallo-d7-d10-migration
git pull origin main
```

### Step 2: Update Dependencies

```bash
cd drupal10
composer install
cd ..
```

### Step 3: Import Configuration

```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:import -y"
```

### Step 4: Run Database Updates

```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush updatedb -y"
```

### Step 5: Clear Cache

```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"
```

---

## Production Deployment

### Prerequisites

1. Production server with:
   - PHP 8.1+
   - MySQL 8.0+
   - Composer
   - Web server (Nginx/Apache)

2. Database backup from migration
3. Files directory backup
4. Environment-specific settings

### Deployment Steps

1. **Clone repository on production server:**
   ```bash
   git clone https://github.com/ArcanianAi/kocsibeallo-d7-d10-migration.git /var/www/kocsibeallo
   cd /var/www/kocsibeallo
   ```

2. **Install dependencies:**
   ```bash
   cd drupal10
   composer install --no-dev --optimize-autoloader
   ```

3. **Configure settings:**
   - Copy `web/sites/default/settings.php` template
   - Update database credentials
   - Set proper config sync directory
   - Configure trusted host patterns

4. **Import database:**
   ```bash
   mysql -u[user] -p[pass] drupal10 < database-dump.sql
   ```

5. **Import configuration:**
   ```bash
   cd web
   ../vendor/bin/drush config:import -y
   ```

6. **Set file permissions:**
   ```bash
   chown -R www-data:www-data /var/www/kocsibeallo/drupal10/web/sites/default/files
   chmod -R 755 /var/www/kocsibeallo/drupal10/web/sites/default/files
   ```

7. **Configure web server:**
   - Point document root to `/var/www/kocsibeallo/drupal10/web`
   - Configure SSL certificate
   - Set up URL rewrites

8. **Clear cache:**
   ```bash
   ../vendor/bin/drush cr
   ```

---

## Email Configuration (Postmark)

The site uses **Postmark** for reliable transactional email delivery. This ensures form submissions, notifications, and other system emails are delivered properly.

### Prerequisites

1. **Postmark Account:** Sign up at https://postmarkapp.com
2. **Server API Token:** Get from Postmark dashboard → Servers → [Your Server] → API Tokens
3. **Verified Sender Signature:** Add and verify `info@kocsibeallo.hu` in Postmark → Sender Signatures

### Configuration Steps

1. **Configure Postmark settings:**
   - Go to `/admin/config/system/postmark` in Drupal admin
   - Enter your **Server API Token**
   - Set sender email to verified address (e.g., `info@kocsibeallo.hu`)

2. **Configure Mail System:**
   - Go to `/admin/config/system/mailsystem`
   - Set **Default Mail System** to `Postmark`
   - Optionally set specific modules (like Webform) to use Postmark

3. **Test email delivery:**
   - Use the test form at `/admin/config/system/postmark/test`
   - Verify emails are received

### Environment Variables (Optional)

For security, you can set the API key via environment variable instead of storing in database:

```php
// In settings.php
$config['postmark.settings']['postmark_api_key'] = getenv('POSTMARK_API_KEY');
```

Then set `POSTMARK_API_KEY` in your environment or `.env` file.

### Webform Email Handlers

The ajánlatkérés (RFQ) form is configured with two email handlers:

1. **Admin Notification**
   - To: `info@kocsibeallo.hu`, `hello@deluxebuilding.hu`
   - Subject: "Új ajánlatkérés érkezett"
   - Contains all submission data

2. **Customer Confirmation**
   - To: Submitter's email address
   - From: `info@kocsibeallo.hu`
   - Subject: "Köszönjük ajánlatkérését!"
   - Well-formatted HTML with submission summary

---

## Troubleshooting

### Containers won't start

```bash
# Check container logs
docker-compose -f docker-compose.d10.yml logs

# Restart containers
docker-compose -f docker-compose.d10.yml restart
```

### Database connection errors

```bash
# Check database container
docker exec -it pajfrsyfzm-d10-db mysql -udrupal -pdrupal

# Verify settings.php database credentials
```

### Permission errors

```bash
# Fix file permissions
chmod -R 777 drupal10/web/sites/default/files
chown -R www-data:www-data drupal10/web/sites/default/files
```

### Composer errors

```bash
# Clear Composer cache
composer clear-cache

# Re-install dependencies
rm -rf vendor/
composer install
```

### Configuration import fails

```bash
# Check config directory exists
ls -la drupal10/config/sync/

# Verify config sync directory in settings.php
grep config_sync_directory drupal10/web/sites/default/settings.php

# Export current config (if needed)
drush config:export -y
```

---

## Environment URLs Quick Reference

### Development (Docker)
- **D10 Web:** http://localhost:8090
- **D10 phpMyAdmin:** http://localhost:8082
- **D10 Database:** localhost:8306

### Production
- **Live Site:** https://www.kocsibeallo.hu
- **Admin:** https://www.kocsibeallo.hu/user/login

---

## Useful Drush Commands

```bash
# Enter container
docker exec -it pajfrsyfzm-d10-cli bash

# Once inside container, navigate to web directory
cd /app/web

# Clear cache
../vendor/bin/drush cr

# Import configuration
../vendor/bin/drush config:import -y

# Export configuration
../vendor/bin/drush config:export -y

# Run database updates
../vendor/bin/drush updatedb -y

# Check status
../vendor/bin/drush status

# Rebuild cache
../vendor/bin/drush rebuild

# User login link
../vendor/bin/drush uli
```

---

## Backup & Restore

### Backup

```bash
# Backup database
docker exec pajfrsyfzm-d10-db mysqldump -udrupal -pdrupal drupal10 > backup-$(date +%Y%m%d).sql

# Backup files
tar -czf files-backup-$(date +%Y%m%d).tar.gz drupal10/web/sites/default/files/

# Backup configuration
cp -R drupal10/config/sync/ config-backup-$(date +%Y%m%d)/
```

### Restore

```bash
# Restore database
docker exec -i pajfrsyfzm-d10-db mysql -udrupal -pdrupal drupal10 < backup-20251116.sql

# Restore files
tar -xzf files-backup-20251116.tar.gz -C drupal10/web/sites/default/

# Import configuration
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:import -y"
```

---

## Performance Optimization

### Production Settings

In `settings.php`:

```php
// Disable render cache for development, enable for production
$config['system.performance']['css']['preprocess'] = TRUE;
$config['system.performance']['js']['preprocess'] = TRUE;

// Disable Twig debugging in production
$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/production.services.yml';
```

### Cache Configuration

```bash
# Enable Redis (if available)
drush en redis -y

# Configure Memcache (if available)
drush en memcache -y
```

---

## Security Checklist

Before production deployment:

- [ ] Change admin password
- [ ] Remove development modules
- [ ] Disable debug/devel modules
- [ ] Configure trusted host patterns
- [ ] Set up SSL certificate
- [ ] Configure file permissions properly
- [ ] Enable security updates
- [ ] Set up regular backups
- [ ] Configure firewall rules
- [ ] Review security permissions

---

## Support & Documentation

- **Full Documentation:** `docs/` directory
- **Environment Details:** `docs/ENVIRONMENT_URLS.md`
- **Migration Guide:** `docs/MIGRATION_STATUS_SUMMARY.md`
- **Scripts:** `scripts/` directory

---

**Last Updated:** 2025-11-16
**Repository:** https://github.com/ArcanianAi/kocsibeallo-d7-d10-migration

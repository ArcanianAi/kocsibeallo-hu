# Drupal Development & Deployment Workflow

## Overview

This document explains the complete development, testing, and deployment workflow for the kocsibeallo.hu Drupal 10 site.

---

## Architecture Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEVELOPMENT WORKFLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   LOCAL (Mac)              GITHUB              PRODUCTION       │
│   ┌──────────┐            ┌──────┐            ┌──────────┐     │
│   │  Docker  │  git push  │      │  git pull  │ Nexcess  │     │
│   │  D10     │ ─────────► │ main │ ─────────► │ Server   │     │
│   │  Dev     │            │      │            │          │     │
│   └──────────┘            └──────┘            └──────────┘     │
│        │                                           │           │
│        │ drush cex                    drush cim    │           │
│        ▼                                           ▼           │
│   ┌──────────┐                              ┌──────────┐       │
│   │ config/  │                              │ config/  │       │
│   │ sync/    │  ◄─── Version Control ───►   │ sync/    │       │
│   └──────────┘                              └──────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Environments

### 1. Local Development (Docker)

**Purpose:** Development, testing, debugging

| Component | Details |
|-----------|---------|
| URL | http://localhost:8090 |
| Container CLI | `pajfrsyfzm-d10-cli` |
| Database | MySQL in Docker (`drupal10-db`) |
| Files | Local filesystem |

**Start Development Environment:**
```bash
cd /Volumes/T9/Sites/kocsibeallo-hu
docker-compose -f docker-compose.d10.yml up -d
```

### 2. Production (Nexcess)

**Purpose:** Live site serving customers

| Component | Details |
|-----------|---------|
| URL | https://kocsibeallo.hu |
| SSH Host | d99a9d9894.nxcli.io |
| SSH User | a17d7af6_1 |
| Site Dir | `/home/a17d7af6/9df7d73bf2.nxcli.io/drupal` |
| Webroot | `drupal/web` (symlinked to `html`) |

---

## Project Structure

```
kocsibeallo-hu/
├── composer.json          # PHP dependencies
├── composer.lock          # Locked versions
├── config/
│   └── sync/              # Drupal config YAML files (989 files)
├── web/                   # Drupal webroot
│   ├── core/              # Drupal core
│   ├── modules/
│   │   ├── contrib/       # Contributed modules
│   │   └── custom/        # Custom modules
│   ├── themes/
│   │   └── contrib/
│   │       └── porto_theme/  # Porto theme + customizations
│   └── sites/
│       └── default/
│           ├── files/     # Uploaded files (not in git)
│           └── settings.php
├── vendor/                # Composer packages (not in git)
├── docs/                  # Documentation
└── scripts/               # Deployment scripts
```

---

## Configuration Management (Config Sync)

Drupal configuration is managed through YAML files in `config/sync/`. This is the **source of truth** for all site configuration.

### What's in Config?

- Content types and fields
- Views
- Blocks and block placement
- Menus and menu links
- Webforms
- Theme settings
- User roles and permissions
- Module settings

### Export Configuration (Local → Git)

After making changes in the admin UI:

```bash
# Local Docker
docker exec pajfrsyfzm-d10-cli drush cex -y

# Or on Nexcess server
cd ~/9df7d73bf2.nxcli.io/drupal/web
../vendor/bin/drush cex -y
```

This updates YAML files in `config/sync/`.

### Import Configuration (Git → Database)

After pulling code changes:

```bash
# Local Docker
docker exec pajfrsyfzm-d10-cli drush cim -y

# Or on Nexcess server
cd ~/9df7d73bf2.nxcli.io/drupal/web
../vendor/bin/drush cim -y
```

This applies YAML config to the database.

---

## Development Workflow

### Making Changes

#### 1. Code Changes (Themes, Modules)

```bash
# 1. Make changes locally
# Edit files in web/themes/contrib/porto_theme/ or web/modules/custom/

# 2. Test locally
docker exec pajfrsyfzm-d10-cli drush cr

# 3. Commit and push
git add -A
git commit -m "Description of change"
git push origin main

# 4. Deploy to production (see Deployment section)
```

#### 2. Configuration Changes (Admin UI)

```bash
# 1. Make changes in Drupal admin (localhost:8090/admin)
# E.g., edit a view, add a block, change webform

# 2. Export configuration
docker exec pajfrsyfzm-d10-cli drush cex -y

# 3. Review exported changes
git diff config/sync/

# 4. Commit and push
git add config/sync/
git commit -m "Config: description of change"
git push origin main

# 5. Deploy to production (see Deployment section)
```

#### 3. Content Changes

Content (nodes, media) is **NOT** in Git. Changes made directly in admin UI on each environment. For production content changes, edit directly on https://kocsibeallo.hu/admin.

---

## Deployment to Production

### Quick Deploy (Most Common)

```bash
# SSH to Nexcess
sshpass -p 'LongRagHaltsLied' ssh a17d7af6_1@d99a9d9894.nxcli.io

# On server:
cd ~/9df7d73bf2.nxcli.io/drupal

# Pull latest code
git pull origin main

# Import configuration
cd web && ../vendor/bin/drush cim -y

# Clear cache
../vendor/bin/drush cr
```

### Full Deploy (New Modules/Dependencies)

```bash
# SSH to Nexcess
cd ~/9df7d73bf2.nxcli.io/drupal

# Pull latest code
git pull origin main

# Update Composer dependencies
composer install --no-dev --optimize-autoloader

# Run database updates
cd web && ../vendor/bin/drush updb -y

# Import configuration
../vendor/bin/drush cim -y

# Clear cache
../vendor/bin/drush cr
```

### One-Liner Deploy from Local

```bash
sshpass -p 'LongRagHaltsLied' ssh -o StrictHostKeyChecking=no a17d7af6_1@d99a9d9894.nxcli.io "cd /home/a17d7af6/9df7d73bf2.nxcli.io/drupal && git pull origin main && cd web && ../vendor/bin/drush cim -y && ../vendor/bin/drush cr"
```

---

## Custom Modules

Located in `web/modules/custom/`:

| Module | Purpose |
|--------|---------|
| `webform_custom` | Form ID normalization, CSS class handling for HubSpot/Make integration |
| `admin_field_fix` | Fixes for admin display |

### Creating a New Custom Module

```bash
# Create directory structure
mkdir -p web/modules/custom/my_module

# Create info.yml
cat > web/modules/custom/my_module/my_module.info.yml << 'EOF'
name: 'My Module'
type: module
description: 'Description here'
core_version_requirement: ^10 || ^11
package: Custom
EOF

# Create .module file if needed
touch web/modules/custom/my_module/my_module.module

# Enable module
docker exec pajfrsyfzm-d10-cli drush en my_module -y

# Export config to capture the enabled state
docker exec pajfrsyfzm-d10-cli drush cex -y
```

---

## Theme Customizations

Porto theme customizations are in `web/themes/contrib/porto_theme/`:

| File | Purpose |
|------|---------|
| `css/custom.css` | Main custom styles |
| `css/custom-blog.css` | Blog-specific styles |
| `css/custom-user.css` | User-specific styles |
| `js/header-fixes.js` | Header JavaScript |
| `porto.libraries.yml` | Asset definitions |
| `templates/` | Twig template overrides |

### Adding CSS

1. Add CSS to appropriate file in `css/`
2. If new file, register in `porto.libraries.yml`
3. Clear cache: `drush cr`
4. Commit and deploy

---

## Database Operations

### Export Database (Backup)

```bash
# Local
docker exec pajfrsyfzm-d10-db mysqldump -udrupal -pdrupal drupal10 > backup.sql

# Production (via SSH)
cd ~/9df7d73bf2.nxcli.io/drupal/web
../vendor/bin/drush sql-dump --result-file=~/backup-$(date +%Y%m%d).sql
```

### Import Database

```bash
# Local
docker exec -i pajfrsyfzm-d10-db mysql -udrupal -pdrupal drupal10 < backup.sql
docker exec pajfrsyfzm-d10-cli drush cr

# Production
cd ~/9df7d73bf2.nxcli.io/drupal/web
../vendor/bin/drush sql-cli < ~/backup.sql
../vendor/bin/drush cr
```

---

## Common Drush Commands

```bash
# Clear cache
drush cr

# Export config
drush cex -y

# Import config
drush cim -y

# Database updates
drush updb -y

# Generate admin login link
drush uli

# Check status
drush status

# View recent logs
drush watchdog:show

# Enable module
drush en module_name -y

# Disable module
drush pm:uninstall module_name -y

# Run cron
drush cron
```

---

## Troubleshooting

### Config Import Fails

```bash
# Check for config differences
drush config:status

# Force import (careful!)
drush cim -y --source=../config/sync
```

### White Screen of Death

```bash
# Check PHP errors
tail -100 ~/var/9df7d73bf2.nxcli.io/logs/error.log

# Enable verbose errors
drush state:set system.maintenance_mode 1
```

### Permission Issues

```bash
# Fix files directory permissions
chmod -R 755 web/sites/default/files
```

### Cache Won't Clear

```bash
# Rebuild everything
drush cr
drush cim -y
drush updb -y
drush cr
```

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `composer.json` | PHP dependencies |
| `config/sync/*.yml` | Drupal configuration |
| `web/sites/default/settings.php` | Database credentials, env-specific settings |
| `web/themes/contrib/porto_theme/porto.info.yml` | Theme definition |
| `web/themes/contrib/porto_theme/porto.libraries.yml` | CSS/JS assets |

---

## Git Workflow

### Branches

- `main` - Production-ready code, deploys to live site

### Commit Messages

```bash
# For code changes
git commit -m "Fix: description of bug fix"
git commit -m "Feature: description of new feature"

# For config changes
git commit -m "Config: updated webform settings"
git commit -m "Config: added new block placement"
```

### Before Pushing

1. Test changes locally
2. Export config if admin changes made
3. Review `git diff`
4. Commit with clear message
5. Push to main

---

## Security Notes

- Never commit `settings.php` with real credentials
- SSH password is in `.credentials` (gitignored)
- Production DB credentials in Nexcess settings.php only
- Use environment variables for sensitive data when possible

---

## Related Documentation

- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Detailed deployment steps
- [NEXCESS-DEPLOYMENT.md](NEXCESS-DEPLOYMENT.md) - Nexcess-specific setup
- [ENVIRONMENT_URLS.md](ENVIRONMENT_URLS.md) - All URLs and access points
- [WEBFORM_CONDITIONAL_FIELDS.md](WEBFORM_CONDITIONAL_FIELDS.md) - Webform customizations

---

**Last Updated:** 2026-01-08

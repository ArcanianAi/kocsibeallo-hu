# Project Restructure Plan

## Current Problem

The codebase (Drupal 7 and Drupal 10) is **NOT** in Git because:
1. Both directories are 1.7GB each (too large for Git)
2. Contains vendor dependencies (should be managed by Composer)
3. Contains contrib modules/themes (should be installed via Composer)
4. Contains uploaded files (should not be in version control)
5. Config sync is inside `files/` directory (wrong location)

## Best Practice Structure for Drupal 10

### What SHOULD be in Git:
✅ **Core Project Files:**
- `composer.json` - Defines all Drupal dependencies
- `composer.lock` - Locks dependency versions
- `docker-compose.d10.yml` - Docker configuration
- `nginx.conf` - Web server config

✅ **Custom Code:**
- `web/modules/custom/` - Custom modules (e.g., gallery_custom)
- `web/themes/custom/` - Custom themes (if any)
- `web/sites/default/settings.php` - Settings (with secrets removed)

✅ **Configuration:**
- `config/sync/` - Exported Drupal configuration (NEW location)

✅ **Documentation & Scripts:**
- `docs/` - All documentation
- `scripts/` - Deployment and setup scripts
- `README.md` - Project documentation

### What should NOT be in Git:
❌ `vendor/` - Composer dependencies (run `composer install`)
❌ `web/core/` - Drupal core (installed by Composer)
❌ `web/modules/contrib/` - Contrib modules (installed by Composer)
❌ `web/themes/contrib/` - Contrib themes (installed by Composer)
❌ `web/sites/default/files/` - Uploaded files (except .htaccess)
❌ `drupal7-codebase/` - D7 reference (keep locally only)
❌ `database/` - Database dumps (too large)

## Restructure Steps

### Phase 1: Setup Config Management (Inside D10 container)
```bash
# 1. Create config directory outside web root
mkdir -p /app/config/sync

# 2. Update settings.php
# Change: $settings['config_sync_directory'] = '../config/sync';

# 3. Export current configuration
drush config:export -y

# 4. Verify config was exported
ls -la /app/config/sync/
```

### Phase 2: Create Proper .gitignore
```gitignore
# Drupal 10 - Exclude managed dependencies
/drupal10/vendor/
/drupal10/web/core/
/drupal10/web/modules/contrib/
/drupal10/web/themes/contrib/
/drupal10/web/sites/default/files/*
!/drupal10/web/sites/default/files/.htaccess

# Drupal 7 - Reference only (not in git)
/drupal7-codebase/

# Database and backups
/database/
/backups/
/d7_backups/
*.sql
*.sql.gz
*.tar.gz

# Docker volumes
.docker/

# Environment files with secrets
.env
.env.local

# OS and IDE
.DS_Store
.idea/
*.swp
```

### Phase 3: Commit Structure to Git
```bash
# Add Drupal 10 Composer files
git add drupal10/composer.json drupal10/composer.lock

# Add custom code
git add drupal10/web/modules/custom/
git add drupal10/web/themes/custom/

# Add configuration
git add drupal10/config/

# Add settings (will need to create template)
git add drupal10/web/sites/default/settings.php

# Add Docker and scripts
git add docker-compose.d10.yml nginx.conf

# Commit
git commit -m "Add Drupal 10 codebase structure"
```

### Phase 4: Create Deployment Process

**After cloning the repository:**
```bash
# 1. Clone repository
git clone https://github.com/ArcanianAi/kocsibeallo-d7-d10-migration.git
cd kocsibeallo-d7-d10-migration

# 2. Install Composer dependencies
cd drupal10
composer install

# 3. Start Docker containers
cd ..
docker-compose -f docker-compose.d10.yml up -d

# 4. Import database (from backup)
# Import database dump to D10 database

# 5. Import configuration
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:import -y"

# 6. Clear cache
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"

# 7. Copy files directory (from backup or production)
# rsync or copy files to drupal10/web/sites/default/files/
```

## File Organization After Restructure

```
kocsibeallo-d7-d10-migration/
├── README.md
├── .gitignore
├── docker-compose.d7.yml (optional - for reference)
├── docker-compose.d10.yml
├── nginx.conf
│
├── drupal10/ (Drupal 10 Composer project)
│   ├── composer.json ✅ IN GIT
│   ├── composer.lock ✅ IN GIT
│   ├── vendor/ ❌ NOT IN GIT (generated)
│   ├── config/ ✅ IN GIT
│   │   └── sync/ (exported configuration)
│   └── web/
│       ├── core/ ❌ NOT IN GIT (generated)
│       ├── modules/
│       │   ├── contrib/ ❌ NOT IN GIT (installed by Composer)
│       │   └── custom/ ✅ IN GIT
│       │       └── gallery_custom/
│       ├── themes/
│       │   ├── contrib/ ❌ NOT IN GIT
│       │   └── custom/ ✅ IN GIT (if we customize Porto)
│       └── sites/default/
│           ├── settings.php ✅ IN GIT (template)
│           └── files/ ❌ NOT IN GIT (except .htaccess)
│
├── scripts/ ✅ IN GIT
│   ├── deployment/
│   │   ├── deploy.sh (production deployment)
│   │   ├── setup.sh (initial setup after clone)
│   │   └── import-db.sh (database import helper)
│   ├── migration/
│   │   ├── discover_d7_filesystem.sh (D7 discovery)
│   │   ├── download_missing_files.sh (file recovery)
│   │   └── download_priority_files.sh (priority files)
│   └── utilities/
│       └── (other helper scripts)
│
├── docs/ ✅ IN GIT
│   └── (all documentation)
│
└── drupal7-codebase/ ❌ NOT IN GIT (local reference only)
```

## Benefits of This Structure

1. **Small Git Repository:** ~10MB instead of 3.4GB
2. **Reproducible:** Anyone can clone and run `composer install`
3. **Version Control:** Only track what you actually change
4. **Deployment:** Clear process to deploy to production
5. **Collaboration:** Team members can work on the same codebase
6. **Configuration Management:** Export/import config between environments

## Drupal 7 Strategy

For Drupal 7 (reference environment):
- **Option A:** Keep locally only, document how to get it
- **Option B:** Create a separate database dump in docs/
- **Option C:** Not needed - D7 is just for migration reference

**Recommendation:** Option A - Keep D7 locally for reference during development, not needed in git.

## Database Strategy

- **Keep locally:** Large SQL dumps in `database/` directory
- **Document:** How to get/import the database
- **Git:** Add small schema-only dump for reference (optional)
- **Production:** Use proper backup/restore procedures

## Files Strategy

For `web/sites/default/files/`:
- **Keep locally:** All uploaded files
- **Git:** Only `.htaccess` file
- **Deployment:** Use rsync or file storage service
- **Document:** How to sync files from production

## Next Steps

1. ✅ Create config directory and export configuration
2. ✅ Update .gitignore for Drupal 10 best practices
3. ✅ Commit Composer files and custom code
4. ✅ Create deployment scripts
5. ✅ Update documentation
6. ✅ Push to GitHub
7. ✅ Test clone and deployment process

---

**Status:** Planning Complete - Ready for Implementation
**Estimated Time:** 1-2 hours
**Risk Level:** Low (can keep backup of current state)

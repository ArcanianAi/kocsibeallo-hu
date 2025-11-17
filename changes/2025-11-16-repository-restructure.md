# MAJOR CHANGE: Repository Restructure

**Date:** 2025-11-16
**Type:** Repository Structure Change
**Impact:** HIGH - Affects all deployment paths
**Status:** COMPLETED Locally, PENDING Git Push & Cloudways Re-deployment

---

## 📋 Summary

Restructured the Git repository to move all Drupal files from `drupal10/` subdirectory up one level to the repository root. This fixes deployment issues where Cloudways expects a standard Composer-based Drupal structure.

---

## ❌ Problem Identified

### Issue:
The repository had an extra `drupal10/` directory level that broke standard Drupal deployment expectations.

### Old Structure (WRONG):
```
repo/
  drupal10/              ← Extra unnecessary folder
    composer.json
    web/
    config/
    vendor/
```

When deployed to Cloudways:
```
public_html/
  drupal10/              ← WRONG PATH
    web/
      index.php          ← Web server can't find Drupal here!
```

### Why This Was Wrong:
1. **Cloudways expects:** `public_html/web/index.php`
2. **We had:** `public_html/drupal10/web/index.php`
3. **Problem:** Web server document root misconfigured
4. **Impact:** Site doesn't work, deployment scripts fail, paths confusing

---

## ✅ Solution Implemented

### New Structure (CORRECT):
```
repo/
  composer.json          ← At root (standard!)
  web/                   ← At root (standard!)
  config/                ← At root (standard!)
  vendor/                ← At root
  docs/                  ← Project docs
  scripts/               ← Deployment scripts
```

When deployed to Cloudways:
```
public_html/
  composer.json          ← CORRECT
  web/
    index.php            ← Web server finds Drupal here! ✓
  config/
  vendor/
```

---

## 🔧 Technical Changes Made

### 1. File System Restructure

**Commands executed:**
```bash
cd /Volumes/T9/Sites/kocsibeallo-hu

# Move all files from drupal10/ to root
mv drupal10/.editorconfig ./
mv drupal10/.gitattributes ./
mv drupal10/composer.json ./
mv drupal10/composer.lock ./
mv drupal10/config ./
mv drupal10/settings.production.php ./
mv drupal10/web ./
mv drupal10/vendor ./

# Remove empty drupal10/ directory
rmdir drupal10/
```

### 2. Updated `.gitignore`

**Changed all paths from:**
```gitignore
drupal10/vendor/
drupal10/web/core/
drupal10/web/modules/contrib/
# ... etc
```

**To:**
```gitignore
vendor/
web/core/
web/modules/contrib/
# ... etc
```

### 3. Updated `docker-compose.d10.yml`

**Changed volume mounts from:**
```yaml
volumes:
  - ./drupal10:/app:delegated
```

**To:**
```yaml
volumes:
  - .:/app:delegated
```

### 4. Updated All Documentation

Updated paths in:
- `CLOUDWAYS_DEPLOYMENT_STEPS.md`
- `DEPLOY_TO_CLOUDWAYS_NOW.md`
- `DEPLOYMENT_STATUS.md`
- `START_HERE.md`
- `docs/CLOUDWAYS_DEPLOYMENT.md`
- `docs/CLAUDE_CODE_SSH_AUTOMATION.md`
- All deployment scripts

### 5. Updated Deployment Scripts

Updated paths in:
- `scripts/cloudways/production-deploy-full.sh`
- `scripts/cloudways/post-deploy.sh`
- All other deployment automation

---

## 📊 Path Changes Reference Table

| Component | Old Path | New Path |
|-----------|----------|----------|
| **Composer file** | `drupal10/composer.json` | `composer.json` |
| **Web root** | `drupal10/web/` | `web/` |
| **Config directory** | `drupal10/config/` | `config/` |
| **Vendor directory** | `drupal10/vendor/` | `vendor/` |
| **Settings.php** | `drupal10/web/sites/default/settings.php` | `web/sites/default/settings.php` |
| **Drush** | `drupal10/vendor/bin/drush` | `vendor/bin/drush` |

### Cloudways Paths

| Component | Old Path | New Path |
|-----------|----------|----------|
| **App root** | `/public_html/drupal10/` | `/public_html/` |
| **Web root** | `/public_html/drupal10/web/` | `/public_html/web/` |
| **Composer** | `/public_html/drupal10/composer.json` | `/public_html/composer.json` |
| **Drush** | `/public_html/drupal10/vendor/bin/drush` | `/public_html/vendor/bin/drush` |
| **Config** | `/public_html/drupal10/config/` | `/public_html/config/` |

---

## 🚀 Impact on Deployment

### Local Development

**Before:**
```bash
cd /Volumes/T9/Sites/kocsibeallo-hu/drupal10
composer install
cd web
../vendor/bin/drush status
```

**After:**
```bash
cd /Volumes/T9/Sites/kocsibeallo-hu
composer install
cd web
../vendor/bin/drush status
```

### Cloudways Production

**Before:**
```bash
cd /home/969836.cloudwaysapps.com/DB_USER (see .credentials)/public_html
cd drupal10        ← Extra level
composer install
cd web
../vendor/bin/drush status
```

**After:**
```bash
cd /home/969836.cloudwaysapps.com/DB_USER (see .credentials)/public_html
composer install   ← Direct access
cd web
../vendor/bin/drush status
```

---

## ⚠️ Breaking Changes

### For Cloudways Deployment:

1. **Git must be re-pulled** - Old structure will be overwritten
2. **Old `/public_html/drupal10/` directory** will become orphaned
3. **Must delete old directory manually:** `rm -rf /public_html/drupal10/` (after verification)
4. **Composer dependencies** must be reinstalled in new location
5. **All deployment scripts** now reference new paths

### For Local Development:

1. **Docker volumes** now mount current directory, not `./drupal10`
2. **All composer commands** run from repository root
3. **Docker containers must be recreated:**
   ```bash
   docker-compose -f docker-compose.d10.yml down
   docker-compose -f docker-compose.d10.yml up -d
   ```

---

## ✅ Verification Steps

### Local Verification:

```bash
# 1. Check files are at root
ls -la composer.json      # Should exist
ls -la web/index.php      # Should exist
ls -la config/sync/       # Should have .yml files

# 2. Test Docker
docker-compose -f docker-compose.d10.yml down
docker-compose -f docker-compose.d10.yml up -d

# 3. Access site
open http://localhost:8090

# 4. Run drush
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush status"
```

### Cloudways Verification (After Re-deployment):

```bash
# 1. SSH into Cloudways
ssh SSH_USER (see .credentials)@D7_HOST (see .credentials) -p 22

# 2. Check new structure
cd /home/969836.cloudwaysapps.com/DB_USER (see .credentials)/public_html
ls -la composer.json      # Should be HERE
ls -la web/index.php      # Should exist
ls -la config/sync/       # Should have files

# 3. Old directory check
ls -la drupal10/          # May still exist (orphaned)
# If exists and verified new structure works: rm -rf drupal10/

# 4. Run composer install
composer install --no-dev --no-interaction

# 5. Test drush
cd web
../vendor/bin/drush status
```

---

## 📝 Migration Steps for Cloudways

### Step 1: Commit and Push Changes

```bash
cd /Volumes/T9/Sites/kocsibeallo-hu
git status
git add .
git commit -m "Restructure: Move drupal10/* to root for standard Drupal deployment

- Moved all Drupal files from drupal10/ up one level
- Updated .gitignore paths
- Updated docker-compose volume mounts
- Updated all documentation and scripts
- Fixes Cloudways deployment path issues

See changes/2025-11-16-repository-restructure.md for details"

git push origin main
```

### Step 2: Re-deploy on Cloudways

1. Log into Cloudways Platform
2. Navigate to: Application > Deployment Via Git
3. Click **"Pull"** button
4. Wait for deployment to complete

### Step 3: SSH and Verify

```bash
ssh SSH_USER (see .credentials)@D7_HOST (see .credentials) -p 22
cd /home/969836.cloudwaysapps.com/DB_USER (see .credentials)/public_html

# Verify new structure
ls -la composer.json web/ config/

# If old drupal10/ exists:
ls -la drupal10/
# After verifying new structure works: rm -rf drupal10/
```

### Step 4: Complete Deployment

Follow steps in `CLOUDWAYS_DEPLOYMENT_STEPS.md` with NEW PATHS:

```bash
cd /home/969836.cloudwaysapps.com/DB_USER (see .credentials)/public_html

# Install Composer dependencies
composer install --no-dev --no-interaction

# Enable Redis
cd web
../vendor/bin/drush en redis -y

# Import config
../vendor/bin/drush config:import -y

# Update database
../vendor/bin/drush updatedb -y

# Clear cache
../vendor/bin/drush cr

# Get admin link
../vendor/bin/drush uli
```

---

## 🎯 Success Criteria

### Checklist:

- [ ] Local: Files at repository root (not in drupal10/)
- [ ] Local: Docker compose works with new structure
- [ ] Local: Site accessible at localhost:8090
- [ ] Git: Changes committed and pushed to GitHub
- [ ] Cloudways: Code re-pulled via Git deployment
- [ ] Cloudways: Files at `/public_html/` (not `/public_html/drupal10/`)
- [ ] Cloudways: Composer install successful
- [ ] Cloudways: Drush commands work
- [ ] Cloudways: Site accessible at production URL
- [ ] Cloudways: Old `drupal10/` directory removed (optional cleanup)

---

## 🐛 Known Issues & Solutions

### Issue: Docker containers fail to start

**Cause:** Volume mount path changed from `./drupal10` to `.`

**Solution:**
```bash
docker-compose -f docker-compose.d10.yml down -v
docker-compose -f docker-compose.d10.yml up -d
```

### Issue: Old drupal10/ directory still on Cloudways

**Cause:** Git pull doesn't delete directories, only adds/updates files

**Solution:**
```bash
# SSH into Cloudways
cd /home/969836.cloudwaysapps.com/DB_USER (see .credentials)/public_html
# Verify new structure works first!
rm -rf drupal10/
```

### Issue: Composer dependencies in wrong location

**Cause:** Dependencies installed in old `/public_html/drupal10/vendor`

**Solution:**
```bash
# Remove old vendor
rm -rf /public_html/drupal10/vendor
# Reinstall in new location
cd /public_html
composer install --no-dev
```

---

## 📚 Related Documentation

| Document | Description |
|----------|-------------|
| `RESTRUCTURE_COMPLETED.md` | Summary of restructure changes |
| `CLOUDWAYS_DEPLOYMENT_STEPS.md` | Updated deployment guide |
| `docs/CLOUDWAYS_DEPLOYMENT.md` | Detailed Cloudways workflow |
| `START_HERE.md` | Quick start guide |
| `DEPLOYMENT_STATUS.md` | Current deployment status |

---

## 👥 Team Communication

### Key Points to Communicate:

1. **Repository structure changed** - `drupal10/` directory removed
2. **All paths updated** - Update any local scripts or bookmarks
3. **Re-clone recommended** - Easier than migrating local changes
   ```bash
   git clone git@github.com:ArcanianAi/kocsibeallo-d7-d10-migration.git
   cd kocsibeallo-d7-d10-migration
   composer install
   ```
4. **Docker must be restarted** - Volume mounts changed
5. **Cloudways will be re-deployed** - Old structure replaced

---

## 📅 Timeline

| Date | Action | Status |
|------|--------|--------|
| 2025-11-16 11:55 | Issue identified | ✅ Complete |
| 2025-11-16 11:56 | Local restructure completed | ✅ Complete |
| 2025-11-16 11:57 | .gitignore updated | ✅ Complete |
| 2025-11-16 11:58 | docker-compose updated | ✅ Complete |
| 2025-11-16 12:00 | Documentation updated | ✅ Complete |
| 2025-11-16 12:XX | Git commit & push | ⏳ Pending |
| 2025-11-16 12:XX | Cloudways re-deployment | ⏳ Pending |
| 2025-11-16 12:XX | Verification complete | ⏳ Pending |

---

## ✅ Sign-off

**Restructure completed by:** Claude Code
**Verified by:** _Pending user verification_
**Approved for deployment:** _Pending_

---

**Change Log Entry:** MAJOR - Repository restructure (drupal10/ → root)
**Risk Level:** Medium (requires re-deployment, but code unchanged)
**Rollback Plan:** Git revert commit, re-pull on Cloudways

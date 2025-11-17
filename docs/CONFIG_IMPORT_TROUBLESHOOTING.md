# Configuration Import Troubleshooting

**Created**: 2025-11-17
**Issue**: Config import failures blocking deployments

---

## Overview

This document covers common config import (`drush config:import`) errors and their solutions for the Drupal 10 kocsibeallo.hu site.

---

## Issue 1: Theme Dependency Errors

### Symptom

```bash
cd ~/public_html/web
../vendor/bin/drush config:import -y

# Output:
+------------+---------------------------------------------------------+-----------+
| Collection | Config                                                  | Operation |
+------------+---------------------------------------------------------+-----------+
|            | porto.settings                                          | Update    |
|            | core.entity_view_display.node.foto_a_galeriahoz.default | Update    |
+------------+---------------------------------------------------------+-----------+

[error] The import failed due to the following reasons:
block.block.bartik_system_main konfiguráció egy másik sminket (bartik) igényel,
ami viszont nem lesz telepítve az importálást követően.

block.block.ohm_block_12 konfiguráció egy másik sminket (ohm) igényel,
ami viszont nem lesz telepítve az importálást követően.

[... many similar errors for omega, porto_sub, tweme, zen themes ...]
```

### Root Cause

The `config/sync/` directory contains block placement configs for themes that are **not installed** on production:
- **bartik** - Drupal core default theme (never used)
- **ohm** - Testing theme from migration
- **omega** - Testing theme from migration
- **porto_sub** - Porto sub-theme (tested but not used)
- **tweme** - Testing theme from migration
- **zen** - Testing theme from migration

These configs were exported during the D7→D10 migration when multiple themes were tested. Drupal validates **all** config dependencies before import, so even ONE missing theme dependency blocks the **entire import**.

### Impact

**CRITICAL** - Blocks ALL configuration imports, including:
- Content type display settings (e.g., gallery field display fix)
- Views configuration updates
- Field configuration updates
- Module settings updates

### Solution

**Step 1: Identify unused theme configs**

```bash
# On local Mac
cd /Volumes/T9/Sites/kocsibeallo-hu

# Count unused theme block configs
ls config/sync/block.block.* | grep -E "(bartik|ohm|omega|porto_sub|tweme|zen)" | wc -l

# Show breakdown by theme
echo "bartik: $(ls config/sync/block.block.bartik* 2>/dev/null | wc -l)"
echo "ohm: $(ls config/sync/block.block.ohm* 2>/dev/null | wc -l)"
echo "omega: $(ls config/sync/block.block.omega* 2>/dev/null | wc -l)"
echo "porto_sub: $(ls config/sync/block.block.porto_sub* 2>/dev/null | wc -l)"
echo "tweme: $(ls config/sync/block.block.tweme* 2>/dev/null | wc -l)"
echo "zen: $(ls config/sync/block.block.zen* 2>/dev/null | wc -l)"
```

**Step 2: Delete unused theme configs**

```bash
cd config/sync

# Delete all unused theme block configs
rm -v block.block.bartik*.yml \
     block.block.ohm*.yml \
     block.block.omega*.yml \
     block.block.porto_sub*.yml \
     block.block.tweme*.yml \
     block.block.zen*.yml
```

**Step 3: Verify deletion**

```bash
# Should return 0
ls block.block.* | grep -E "(bartik|ohm|omega|porto_sub|tweme|zen)" | wc -l

# Should return ~81 (porto theme blocks - these are NEEDED)
ls block.block.porto_*.yml | wc -l
```

**Step 4: Commit and push**

```bash
git add -u config/sync/
git commit -m "Remove unused theme block configs blocking config import"
git push origin main
```

**Step 5: Retry deployment**

```bash
# SSH to D10 production
ssh kocsid10ssh@159.223.220.3

# Pull cleaned configs
cd ~/public_html
git pull origin main

# Retry config import (should succeed now)
cd web
../vendor/bin/drush config:import -y

# Clear cache
../vendor/bin/drush cache:rebuild
```

### What to Keep

**✅ KEEP these configs:**
- All `block.block.porto_*.yml` files (81 files) - Active theme blocks
- All `block.block.porto_theme_*.yml` files - Porto theme variant blocks
- Any `core.*`, `field.*`, `node.*`, `views.*` configs

**❌ DELETE these configs:**
- `block.block.bartik*.yml` - Drupal default theme (not used)
- `block.block.ohm*.yml` - Testing theme
- `block.block.omega*.yml` - Testing theme
- `block.block.porto_sub*.yml` - Porto sub-theme (not used)
- `block.block.tweme*.yml` - Testing theme
- `block.block.zen*.yml` - Testing theme

### Statistics

**Before cleanup:**
- Total block configs: 182
- Unused theme blocks: 101
- Active porto blocks: 81

**After cleanup:**
- Total block configs: 81
- Unused theme blocks: 0
- Active porto blocks: 81

**Related Commit:** `c34fd70` - Remove unused theme block configs blocking config import

---

## Issue 2: Missing Module Dependencies

### Symptom

```bash
drush config:import -y

[error] Unable to install the Example module since it does not exist.
```

### Root Cause

A configuration file references a module that is not installed on production.

### Solution

**Option A: Install the missing module**

```bash
composer require drupal/example_module
drush en example_module -y
drush config:import -y
```

**Option B: Remove the config if module not needed**

```bash
# Locally
rm config/sync/example_module.settings.yml
git add -u config/sync/
git commit -m "Remove config for unused module"
git push origin main

# Then retry deployment
```

---

## Issue 3: Configuration Already Exists

### Symptom

```bash
drush config:import -y

[error] Configuration already exists: example.settings
```

### Root Cause

Trying to create a config that already exists in the database.

### Solution

```bash
# Force import (overwrites existing)
drush config:import -y --delete
```

---

## Issue 4: Configuration Mismatch

### Symptom

```bash
drush config:import -y

[error] Configuration validation error: The configuration is not valid.
```

### Root Cause

The YAML structure in `config/sync/` is malformed or has invalid values.

### Solution

```bash
# Check for YAML syntax errors locally
cd config/sync

# Find invalid YAML files
for file in *.yml; do
  php -r "yaml_parse_file('$file') or exit(1);" 2>/dev/null || echo "Invalid: $file"
done

# Fix the invalid YAML file manually, then redeploy
```

---

## Prevention

### 1. Clean Config Exports

After testing themes or modules locally, clean up before committing:

```bash
# Check what will be exported
drush config:status

# Export only changed configs
drush config:export -y

# Review changes before committing
git diff config/sync/

# Remove any test theme/module configs
git checkout config/sync/block.block.test_theme*.yml
```

### 2. Test Config Import Locally First

Before pushing to production:

```bash
# Export local config
drush config:export -y

# Simulate import
drush config:import -y --preview

# If successful, commit and push
git add config/sync/
git commit -m "Update configuration"
git push origin main
```

### 3. Use Drush Commands for Safety

```bash
# Preview config changes without importing
drush config:import -y --preview

# Show differences between active and sync
drush config:status

# Check specific config
drush config:get core.entity_view_display.node.foto_a_galeriahoz.default
```

---

## Quick Reference

### Check Config Status
```bash
drush config:status
```

### Preview Import
```bash
drush config:import -y --preview
```

### Force Import (Delete Removed Configs)
```bash
drush config:import -y --delete
```

### Import Single Config
```bash
drush config:import --partial --source=../config/sync/ -y
drush cset core.entity_view_display.node.foto_a_galeriahoz.default content.field_telikert_kep ...
```

### Export Current Config
```bash
drush config:export -y
```

### Get Specific Config Value
```bash
drush config:get core.entity_view_display.node.foto_a_galeriahoz.default content.field_telikert_kep
```

---

## Related Documentation

- `docs/GALLERY_FIELD_DISPLAY_FIX.md` - Gallery field display configuration
- `DEPLOYMENT_STEPS_FOR_EXTERNAL_SYSTEM.md` - Full deployment guide
- `docs/PRIVATE_FILE_MIGRATION.md` - Private file URI fixes
- `docs/SLIDESHOW_MIGRATION.md` - Slideshow data import

---

**Last Updated**: 2025-11-17
**Status**: Active troubleshooting guide
**Related Issue**: Config import blocking gallery display fix deployment

# Slideshow Migration Guide

## Overview

The homepage slideshow uses the **MD Slider** module. The slideshow data is stored in database tables, NOT in Drupal configuration files.

## What Gets Migrated

### Via Config Files (✅ Already in Git)
- `config/sync/block.block.porto_frontpage.yml` - Block placement on homepage
- `config/sync/image.style.md_slider_*.yml` - Image styles for slider

### Via Database Migration (⚠️ Must be imported)
- `md_sliders` table - Slider configuration (1 slider: "Front Page")
- `md_slides` table - Individual slides (8 slides with images)

### Via File Sync (⚠️ Must be synced)
- 8 slideshow image files in `sites/default/files/`

## Slideshow Details

**Slider Name**: Front Page
**Machine Name**: front_page
**Dimensions**: 960x350px
**Animation**: Fade
**Autoplay**: Yes (8 second delay)
**Location**: Homepage only (region: slide_show)

## Migration Steps

### Step 1: Sync Files from D7 to D10

The slideshow images must be copied from D7:

```bash
# On D10 server (or via deployment script)
cd ~/public_html/web/sites/default/files

rsync -avz --progress \
  -e "ssh -o StrictHostKeyChecking=no" \
  kocsibeall.ssh.d10@165.22.200.254:/home/969836.cloudwaysapps.com/pajfrsyfzm/public_html/sites/default/files/ \
  ./
```

**Required files (FID → filename)**:
- 2850: `ximax-swingline-kocsibeallo-tandem-elrendezesben-kocsibeallo.webp`
- 2851: `ximax-swingline-kocsibeallo-m-elrendezesben-kocsibeallo.webp`
- 2852: `ximax-swingline-kocsibellao-autobeallo.webp`
- 2853: `autobeallo_ragasztott_fabol_polikarbonát-fedessel.webp`
- 2854: `porfestett_acel_kocsibeallo-trapezlemez.webp`
- 2855: `kocsibeallo_ragasztott_fabol_polikarbonat-fedessel.webp`
- 2856: `vas-szerkezet-napelemes-kocsibeallo-slide_0.webp`
- 2859: `ragasztott-fa-szerkezetu-polikabonat-fedesu-kocsibelllo-slide_1.webp`

### Step 2: Import Configuration

Import Drupal configuration (includes block placement and image styles):

```bash
cd ~/public_html/web
../vendor/bin/drush config:import -y
```

This imports:
- Block placement: `block.block.porto_frontpage`
- Image styles: `image.style.md_slider_*`

### Step 3: Import Slideshow Data

Import the slider and slides into the database:

```bash
cd ~/public_html/web
../vendor/bin/drush sql-query --file=../database/migrations/md_slider_homepage.sql
```

**What this does**:
- Deletes any existing "Front Page" slider data
- Inserts slider configuration (settings, dimensions, animation)
- Inserts 8 slides with their image references

### Step 4: Clear Cache

```bash
cd ~/public_html/web
../vendor/bin/drush cache:rebuild
```

### Step 5: Verify

1. **Check database**:
   ```bash
   drush sql-query "SELECT * FROM md_sliders WHERE machine_name = 'front_page';"
   drush sql-query "SELECT COUNT(*) FROM md_slides WHERE slid = 1;"  # Should be 8
   ```

2. **Check files exist**:
   ```bash
   drush sql-query "SELECT fid, filename FROM file_managed WHERE fid IN (2850, 2851, 2852, 2853, 2854, 2855, 2856, 2859);"
   ```

3. **View homepage**: Visit homepage and verify slideshow appears and images load correctly.

## Troubleshooting

### Slideshow Not Visible
- Check block is enabled: `/admin/structure/block`
- Verify block is in "Slide Show" region for Porto theme
- Clear cache: `drush cache:rebuild`

### Images Not Loading
- Verify files exist in `sites/default/files/`
- Check file permissions: `chmod -R 755 sites/default/files/`
- Verify file_managed entries exist for FIDs 2850-2859

### Wrong Images Displaying
- Check FID values in md_slides table match file_managed table
- Verify file_managed.uri paths are correct (should be `public://filename.webp`)

## Migration File Location

**SQL File**: `database/migrations/md_slider_homepage.sql`

This file is:
- ✅ Tracked in Git
- ✅ Safe to commit (no credentials)
- ✅ Idempotent (can be run multiple times)

## Related Configuration

**Config files** (already in config/sync/):
- `block.block.porto_frontpage.yml` - Block placement
- `image.style.md_slider_*.yml` - Image styles (17 files)

**Module**: MD Slider (contrib module)
**Location**: `web/modules/contrib/md_slider/`

## Notes

- The slideshow data is NOT exportable via `drush config:export`
- MD Slider stores data in custom database tables, not in configuration
- File IDs (FIDs) must match between local and production
- The migration SQL assumes FIDs 2850, 2851, 2852, 2853, 2854, 2855, 2856, 2859 exist

---

**Last Updated**: 2025-11-17

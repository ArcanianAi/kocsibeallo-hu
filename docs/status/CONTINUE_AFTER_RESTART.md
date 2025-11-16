# Quick Start Guide - Continue After Restart

**Date:** 2025-11-12

---

## Current Status

### ✅ Completed
- Media migration (2,457 files from D7)
- Blog page creation and styling
- Footer styling fixes
- Menu configuration (Nyitólap first, Címlap hidden)
- Gallery view field exclusion

### 🔧 In Progress
- **Gallery images** - All 6 images showing per card instead of just first one
- Needs Twig template modification

---

## Quick Commands Reference

### Start Docker Containers
```bash
cd /Volumes/T9/Sites/kocsibeallo-hu

# Check if running
docker ps --format "table {{.Names}}\t{{.Status}}"

# Start D10 if needed
docker-compose -f docker-compose.d10.yml up -d

# Start D7 if needed
docker-compose -f docker-compose.d7.yml up -d
```

### Access Points
- **D10 Site:** http://localhost:8090
- **D10 phpMyAdmin:** http://localhost:8082
- **D10 Database:** localhost:8306
- **D7 Site:** http://localhost:7080
- **D7 phpMyAdmin:** http://localhost:7081
- **D7 Database:** localhost:7306

### Essential Drush Commands
```bash
# Clear cache
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"

# Clear CSS/JS cache
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cc css-js"

# Run PHP script
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush php:script /tmp/script.php"

# SQL query
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'SELECT COUNT(*) FROM node'"

# Config get
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get views.view.index_gallery"

# Config edit
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:edit core.entity_view_display.node.foto_a_galeriahoz.teaser"
```

---

## Priority Task: Fix Gallery Images

**Problem:** Gallery cards showing all 6 images instead of just first one
**Files to Check:** See GALLERY_IMAGE_FIX.md

### Quick Fix Steps

**1. Edit Twig Template:**
```bash
# File location
/Volumes/T9/Sites/kocsibeallo-hu/drupal10/web/themes/contrib/porto_theme/templates/node/gallery/node--foto-a-galeriahoz--teaser.html.twig

# Lines to change: 25-29
# FROM:
{% if content.field_telikert_kep %}
    {{ content.field_telikert_kep }}
# TO:
{% if content.field_telikert_kep %}
    <div class="field--name-field-telikert-kep field--type-image">
        {% set first_image = content.field_telikert_kep[0] %}
        {% if first_image %}
            <div class="field__item">
                {{ first_image }}
            </div>
        {% endif %}
    </div>
```

**2. Clear Cache:**
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"
```

**3. Test:**
```bash
# Check image count (should be ~24, not ~84)
curl -s "http://localhost:8090/kepgaleria/field_gallery_tag/egyedi-nyitott-146" | grep -o '<img[^>]*>' | wc -l

# Check in browser with hard refresh: Cmd+Shift+R (Mac) or Ctrl+Shift+R (Windows)
```

---

## File Locations Quick Reference

### Documentation
- `/Volumes/T9/Sites/kocsibeallo-hu/GALLERY_IMAGE_FIX.md` - Full gallery fix documentation
- `/Volumes/T9/Sites/kocsibeallo-hu/MEDIA_MIGRATION.md` - Media migration complete guide
- `/Volumes/T9/Sites/kocsibeallo-hu/BLOG_FIX.md` - Blog page creation
- `/Volumes/T9/Sites/kocsibeallo-hu/FOOTER_STYLING.md` - Footer fixes
- `/Volumes/T9/Sites/kocsibeallo-hu/MENU_CHANGES.md` - Menu configuration

### Key Files for Gallery Fix
- **Template:** `/drupal10/web/themes/contrib/porto_theme/templates/node/gallery/node--foto-a-galeriahoz--teaser.html.twig`
- **CSS:** `/drupal10/web/themes/contrib/porto_theme/css/custom-user.css` (lines 469-508)
- **View Config:** Edit via `drush config:edit views.view.index_gallery`
- **Display Config:** Edit via `drush config:edit core.entity_view_display.node.foto_a_galeriahoz.teaser`

### Scripts in /tmp
- `/tmp/fix_gallery_view.php` - Already run (excluded field from view)
- `/tmp/fix_gallery_field_display.php` - Alternative approach (not run yet)
- `/tmp/import_d7_files_preserve_fids.php` - File import (already run)
- `/tmp/convert_media_tokens_v2.php` - Token conversion (already run)

---

## Verification Checklist

### Check Containers Running
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Check D10 Site Accessible
```bash
curl -s http://localhost:8090 | grep -o '<title>[^<]*' | head -1
# Should show: <title>Deluxe Building kocsibeállók
```

### Check Database Connection
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'SELECT COUNT(*) FROM node'"
# Should show number of nodes
```

### Check Files Migrated
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'SELECT COUNT(*) FROM file_managed'"
# Should show: 2457
```

### Check Blog Page
```bash
curl -s http://localhost:8090/blog | grep -c "article"
# Should show multiple results
```

### Check Gallery Page
```bash
# Should show gallery items
curl -s "http://localhost:8090/kepgaleria/field_gallery_tag/egyedi-nyitott-146" | grep -c "product-thumb-info"
# Should show: 12 (number of gallery cards)
```

---

## Common Issues After Restart

### Issue: Docker Containers Not Running
```bash
cd /Volumes/T9/Sites/kocsibeallo-hu
docker-compose -f docker-compose.d10.yml up -d
docker-compose -f docker-compose.d7.yml up -d
```

### Issue: Permission Denied
```bash
# Fix file permissions
docker exec pajfrsyfzm-d10-cli bash -c "chmod -R 755 /app/web/sites/default/files"
```

### Issue: Cache Not Clearing
```bash
# Clear all caches manually
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'TRUNCATE cache_bootstrap'"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'TRUNCATE cache_config'"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'TRUNCATE cache_container'"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'TRUNCATE cache_data'"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'TRUNCATE cache_default'"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'TRUNCATE cache_discovery'"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'TRUNCATE cache_dynamic_page_cache'"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'TRUNCATE cache_entity'"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'TRUNCATE cache_menu'"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'TRUNCATE cache_render'"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'TRUNCATE cache_page'"
```

### Issue: CSS Changes Not Applying
```bash
# Clear CSS aggregation
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cc css-js"

# Disable CSS aggregation temporarily
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:set system.performance css.preprocess 0 -y"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:set system.performance js.preprocess 0 -y"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"
```

### Issue: Twig Template Changes Not Showing
```bash
# Enable Twig debug
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:set system.performance twig.config.debug 1 -y"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:set system.performance twig.config.auto_reload 1 -y"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"

# Disable Twig cache
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:set system.performance twig.config.cache 0 -y"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"
```

---

## Testing URLs

### Key Pages to Test
- **Homepage:** http://localhost:8090/
- **Blog:** http://localhost:8090/blog
- **Gallery Main:** http://localhost:8090/kepgaleria
- **Gallery Filter:** http://localhost:8090/kepgaleria/field_gallery_tag/egyedi-nyitott-146
- **Individual Gallery Item:** http://localhost:8090/dupla-kocsibeallo-kulonleges-kivitelezessel-ragasztott-fa-szerkezettel
- **Contact:** http://localhost:8090/kapcsolat

### Compare with Live Site
- **Live Gallery:** https://www.kocsibeallo.hu/kepgaleria/field_gallery_tag/egyedi-nyitott-146
- **Live Blog:** https://www.kocsibeallo.hu/blog

---

## Docker Commands Quick Reference

### Container Management
```bash
# List running containers
docker ps

# List all containers
docker ps -a

# Start containers
docker-compose -f docker-compose.d10.yml up -d
docker-compose -f docker-compose.d7.yml up -d

# Stop containers
docker-compose -f docker-compose.d10.yml down
docker-compose -f docker-compose.d7.yml down

# Restart containers
docker-compose -f docker-compose.d10.yml restart
docker-compose -f docker-compose.d7.yml restart

# View logs
docker logs pajfrsyfzm-d10-cli
docker logs pajfrsyfzm-d10-nginx
docker logs pajfrsyfzm-d10-mariadb
```

### Execute Commands
```bash
# Execute bash in container
docker exec -it pajfrsyfzm-d10-cli bash

# Execute single command
docker exec pajfrsyfzm-d10-cli bash -c "command here"

# Copy files to container
docker cp /local/path pajfrsyfzm-d10-cli:/container/path

# Copy files from container
docker cp pajfrsyfzm-d10-cli:/container/path /local/path
```

---

## Editor Setup

### VS Code
```bash
# Open project
code /Volumes/T9/Sites/kocsibeallo-hu

# Install recommended extensions:
# - PHP Intelephense
# - Twig Language 2
# - Drupal 8 Snippets
```

### Key Files to Have Open
1. `GALLERY_IMAGE_FIX.md` - Current task documentation
2. `node--foto-a-galeriahoz--teaser.html.twig` - Template to edit
3. `custom-user.css` - CSS file

---

## Progress Tracking

### Session Started: 2025-11-12

**Completed Today:**
1. ✅ Media migration from D7 (2,457 files)
2. ✅ Blog page creation and styling
3. ✅ Footer copyright bar alignment
4. ✅ Gallery taxonomy tags inline display
5. ✅ Menu configuration (Nyitólap/Címlap)
6. ✅ Blog date/author footer hidden
7. ✅ D7 media token conversion (22 articles)

**Current Task:**
- 🔧 Gallery images - Show only first image per card

**Next Tasks:**
- Gallery template fix (Twig modification)
- Final testing and comparison with live site
- Performance optimization
- Security review

---

## Claude Code Context

When you restart and ask Claude Code to continue:

**Say:**
> "I restarted my computer. I need to continue with the gallery image fix. Read GALLERY_IMAGE_FIX.md and help me modify the Twig template to show only the first image."

**Claude Code will know:**
- What the problem is
- What's been tried
- What needs to be done
- Where the files are
- How to test

---

## Important Notes

1. **Always clear cache** after making changes
2. **Hard refresh browser** (Cmd+Shift+R / Ctrl+Shift+R)
3. **Check both HTML source and rendered page**
4. **Compare with live site** for reference
5. **Test on multiple gallery filter pages**
6. **Document any new findings** in the .md files

---

**Quick start commands after restart:**
```bash
# 1. Start containers
cd /Volumes/T9/Sites/kocsibeallo-hu
docker-compose -f docker-compose.d10.yml up -d

# 2. Check status
docker ps
curl -s http://localhost:8090 | grep -o '<title>[^<]*'

# 3. Read docs
cat GALLERY_IMAGE_FIX.md

# 4. Edit template
# Open: drupal10/web/themes/contrib/porto_theme/templates/node/gallery/node--foto-a-galeriahoz--teaser.html.twig

# 5. Clear cache
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"

# 6. Test
open http://localhost:8090/kepgaleria/field_gallery_tag/egyedi-nyitott-146
```

---

**Last updated:** 2025-11-12
**Next session:** Edit Twig template to limit images

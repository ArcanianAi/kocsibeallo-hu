# Sitemap Fix

**Created**: 2025-11-17
**Issue**: Sitemap only contains 1 URL (homepage) instead of 200+ URLs

---

## Problem Description

### Symptoms:
- `/sitemap` returns 404 error
- `/sitemap.xml` exists but only contains 1 URL (homepage)
- D7 live site has 265 URLs in sitemap
- D10 production only has 1 URL

### Root Cause:
Simple XML Sitemap module is installed and working, but **content types are not configured** to be included in the sitemap. No bundle settings exist in config.

---

## Investigation

### D7 Live Site:
- Sitemap URL: https://www.kocsibeallo.hu/sitemap.xml
- Total URLs: **265**
- Includes: Gallery pages, blog posts, basic pages, taxonomy terms

### D10 Production (Before Fix):
- Sitemap URL: https://phpstack-958493-6003495.cloudwaysapps.com/sitemap.xml
- Total URLs: **1** (homepage only)
- Missing: All content nodes

### Configuration:
**Module installed**: `drupal/simple_sitemap: ^4.2`

**Config files present**:
- `config/sync/simple_sitemap.settings.yml` ✅
- `config/sync/simple_sitemap.sitemap.default.yml` ✅
- `config/sync/simple_sitemap.bundle_settings.*.yml` ❌ **MISSING**

The missing bundle settings mean content types are not configured to be included.

---

## Solution

Enable sitemap generation for all content types and regenerate sitemap.

### Content Types to Include:

| Content Type | Machine Name | Priority | Change Frequency |
|-------------|--------------|----------|------------------|
| Gallery pages | `foto_a_galeriahoz` | 0.8 (high) | monthly |
| Blog posts | `article` | 0.7 | monthly |
| Basic pages | `page` | 0.6 | yearly |
| Webforms | `webform` | 0.5 | yearly |

---

## Fix Script

**File**: `scripts/fix-sitemap.sh`

**Usage (on production server)**:
```bash
# SSH to production
ssh kocsid10ssh@159.223.220.3

# Run fix script
cd ~/public_html
./scripts/fix-sitemap.sh
```

**What the script does**:
1. Enables sitemap for `article` content type
2. Enables sitemap for `foto_a_galeriahoz` content type
3. Enables sitemap for `page` content type
4. Enables sitemap for `webform` content type
5. Regenerates sitemap with all content
6. Shows sitemap status

**Expected output**:
```
🔧 Fixing sitemap configuration...

✅ Enabling sitemap for 'article' (blog posts)...
✅ Enabling sitemap for 'foto_a_galeriahoz' (gallery pages)...
✅ Enabling sitemap for 'page' (basic pages)...
✅ Enabling sitemap for 'webform' (forms)...

🔄 Regenerating sitemap (this may take a minute)...

📊 Checking sitemap status...

✅ Sitemap fix complete!

Verify: https://phpstack-958493-6003495.cloudwaysapps.com/sitemap.xml
Expected: 200+ URLs (was 1)
```

---

## Drush Commands Used

### Enable content type for sitemap:
```bash
drush simple-sitemap:settings entity:node:{content_type} \
  --status=1 \
  --priority=0.8 \
  --changefreq=monthly
```

### Regenerate sitemap:
```bash
drush simple-sitemap:generate
```

### Check sitemap status:
```bash
drush simple-sitemap:status
```

### List all sitemap settings:
```bash
drush config:get simple_sitemap.settings
```

---

## Verification

### Before Fix:
```bash
curl -s https://phpstack-958493-6003495.cloudwaysapps.com/sitemap.xml | grep -c '<loc>'
# Result: 1
```

### After Fix (Expected):
```bash
curl -s https://phpstack-958493-6003495.cloudwaysapps.com/sitemap.xml | grep -c '<loc>'
# Result: 200+ (should match D7: 265)
```

### Check via browser:
- URL: https://phpstack-958493-6003495.cloudwaysapps.com/sitemap.xml
- Look for: "A hivatkozások száma a webhelytérképen: 200+"
- Verify: Gallery pages, blog posts, and pages are listed

---

## Export Configuration (Optional)

After fixing on production, you can export the sitemap bundle settings to config:

```bash
# On production
cd ~/public_html/web
../vendor/bin/drush config:export -y

# This will create:
# - config/sync/simple_sitemap.bundle_settings.node.article.yml
# - config/sync/simple_sitemap.bundle_settings.node.foto_a_galeriahoz.yml
# - config/sync/simple_sitemap.bundle_settings.node.page.yml
# - config/sync/simple_sitemap.bundle_settings.node.webform.yml
```

Then pull these configs to local and commit to GitHub:

```bash
# On local Mac
cd /Volumes/T9/Sites/kocsibeallo-hu
scp kocsid10ssh@159.223.220.3:~/public_html/config/sync/simple_sitemap.bundle_settings.* config/sync/
git add config/sync/simple_sitemap.bundle_settings.*
git commit -m "Add sitemap bundle settings for all content types"
git push origin main
```

---

## Troubleshooting

### Issue: Sitemap still only has 1 URL

**Check if content types are enabled**:
```bash
drush simple-sitemap:status
```

**Manually regenerate**:
```bash
drush simple-sitemap:generate --force
```

### Issue: Sitemap generation times out

For large sites (200+ nodes), generation may take time. Check cron settings:

```bash
drush config:get simple_sitemap.settings
```

If needed, increase generation duration:
```bash
drush config:set simple_sitemap.settings generate_duration 30000
```

### Issue: Some pages missing from sitemap

**Check node publishing status**:
```sql
-- Only published nodes are included
SELECT COUNT(*) FROM node_field_data WHERE status = 1 AND type = 'foto_a_galeriahoz';
```

**Check if content type is enabled**:
```bash
drush simple-sitemap:settings entity:node:foto_a_galeriahoz
```

---

## SEO Impact

### Before Fix:
- Only homepage indexed in sitemap
- Search engines cannot discover gallery pages
- Poor SEO performance for gallery content

### After Fix:
- 200+ URLs in sitemap (matching D7)
- All gallery pages discoverable
- All blog posts discoverable
- Proper SEO for all content

---

## Related Files

- **Script**: `scripts/fix-sitemap.sh`
- **Config**: `config/sync/simple_sitemap.*.yml`
- **Documentation**: `docs/SITEMAP_FIX.md`

---

**Status**: Ready to deploy
**Priority**: HIGH - Affects SEO and site discoverability
**Impact**: 200+ pages now included in sitemap

---

**Last Updated**: 2025-11-17

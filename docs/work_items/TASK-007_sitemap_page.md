# TASK-007: Create Missing Sitemap Page

## Status: ⚪ TODO

---

## 📋 Task Details

**Job ID:** TASK-007
**Priority:** 🔴 High
**Estimated Time:** 1-2 hours
**Phase:** C - Styling & Polish
**Dependencies:** None

---

## 📝 Description

The sitemap page at `/sitemap` returns 404. Need to install sitemap module or create custom sitemap page to display site structure with all menu items and links.

---

## 🔍 Current State

**Location:** http://localhost:8090/sitemap

**Issue:**
- Page returns 404 error
- No sitemap functionality available

**Expected:**
- Sitemap page displays full site structure
- Shows all menu items organized by section
- Accessible at `/sitemap` URL
- Matches live site structure

---

## 🎯 Expected Result

After fix:
- URL `/sitemap` works and displays sitemap
- Shows "HONLAP TÉRKÉP" heading
- Lists all menu items organized by menu
- Includes form at bottom (if on live site)
- Clean, organized layout
- Hungarian language

---

## 🔬 Investigation Steps

1. **Check live site sitemap**
   - URL: https://www.kocsibeallo.hu/sitemap
   - Document structure
   - Note which menus are included
   - Check if form is present
   - Screenshot for reference

2. **Check D7 sitemap implementation**
   ```bash
   docker exec drupal7-php bash -c "drush pm:list --status=enabled | grep -i sitemap"
   ```

3. **Check available D10 sitemap modules**
   - simple_sitemap (XML sitemap, but can display HTML)
   - site_map (HTML sitemap module)
   - Or custom page approach

4. **Check existing URL alias**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT * FROM path_alias WHERE alias='/sitemap';\""
   ```

---

## 🛠 Implementation Steps

### Option A: Use site_map Module (Recommended)

1. **Install site_map module**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app && composer require drupal/site_map"
   ```

2. **Enable module**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush pm:enable site_map -y"
   ```

3. **Configure site_map**
   - URL: http://localhost:8090/admin/config/search/sitemap
   - Select menus to include
   - Configure display options
   - Set page title to "HONLAP TÉRKÉP"

4. **Verify URL**
   - Check if accessible at `/sitemap` or `/site-map`
   - Create URL alias if needed

5. **Add to menu if needed**
   - Add link to footer or main menu

### Option B: Use simple_sitemap Module

1. **Install simple_sitemap**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app && composer require drupal/simple_sitemap"
   ```

2. **Enable and configure**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush pm:enable simple_sitemap -y"
   ```

3. **Configure for HTML display**
   - May need additional configuration or custom page

### Option C: Create Custom Page

1. **Create basic page**
   - Content type: Basic Page
   - Title: "HONLAP TÉRKÉP" or "Sitemap"
   - URL alias: `/sitemap`

2. **Add menu block via layout builder or manual HTML**
   - List all menus
   - Organize by section
   - Can use Views or custom code

3. **Style appropriately**

---

## ✅ Testing Checklist

- [ ] URL `/sitemap` works (no 404)
- [ ] Page displays site structure
- [ ] All menus included
- [ ] Links are functional
- [ ] Proper heading ("HONLAP TÉRKÉP")
- [ ] Layout is clean and organized
- [ ] Mobile responsive
- [ ] Matches live site structure
- [ ] Hungarian language throughout
- [ ] Form at bottom (if applicable)
- [ ] Added to site navigation (if needed)

---

## 📊 Progress Notes

### [Date] - [Status Update]
- Note progress here as work proceeds
- Document which approach was chosen
- Note any configuration changes

---

## 📁 Related Files

**Module:**
- site_map or simple_sitemap (TBD)

**Configuration:**
- Module-specific config

**URLs:**
- Config: http://localhost:8090/admin/config/search/sitemap (if site_map)
- Test page: http://localhost:8090/sitemap
- Live reference: https://www.kocsibeallo.hu/sitemap

---

## 🔗 References

- [URGENT_FIXES_NEEDED.md](../fixes/URGENT_FIXES_NEEDED.md) - Issue #7
- [MENU_CHANGES.md](../reference/MENU_CHANGES.md) - Menu structure
- [ENVIRONMENT_URLS.md](../ENVIRONMENT_URLS.md) - All URLs

---

## 💡 Live Site Reference

From live site (https://www.kocsibeallo.hu/sitemap):
- To be documented during investigation
- Include screenshot
- Note menu organization
- Document any special features

---

## 📦 Recommended Module

**site_map** (https://www.drupal.org/project/site_map)
- Specifically for HTML sitemaps
- Easy configuration
- Menu-based display
- Well-maintained for D10

Alternative:
**simple_sitemap** (https://www.drupal.org/project/simple_sitemap)
- More for XML sitemaps (SEO)
- Can also display HTML version
- More features but may be overkill

---

**Created:** 2025-11-15
**Last Updated:** 2025-11-15
**Status:** ⚪ TODO

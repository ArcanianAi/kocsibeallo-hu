# Urgent Fixes Needed Before Production

**Date:** 2025-11-14
**Priority:** 🔴 **HIGH - Must fix before production deployment**
**Current Phase:** Phase 4 - Issue Identification Complete

---

## 🚨 Critical Issues Identified

### 1. **Missing Blog Images on Homepage** 🔴
**Location:** http://localhost:8090/
**Issue:** Blog post thumbnails are not displaying on the homepage
**Expected:** Each blog post should have a featured image thumbnail
**Current:** Images missing from blog teaser display

**Investigation Needed:**
- Check image field configuration in blog view
- Verify image style is set correctly for teaser display
- Check if field_image is properly configured in view
- Compare with live site: https://www.kocsibeallo.hu/

**Estimated Time:** 1-2 hours

---

### 2. **Blog Formatting Issues** 🔴
**Location:** http://localhost:8090/ (homepage blog section)
**Issue:** Blog post formatting doesn't match live site styling
**Expected:** Blog posts should have proper card layout with:
- Featured image
- Date display (day + month format)
- Title
- Teaser/excerpt
- "Read More" button

**Current State:** Formatting appears incomplete or different from live site

**Investigation Needed:**
- Check blog view display mode (teaser vs card)
- Review template files for blog teasers
- Compare CSS classes with live site
- Check if Porto theme has specific blog teaser template

**Estimated Time:** 2-3 hours

---

### 3. **Homepage Shows Too Many Blog Posts** 🟡
**Location:** http://localhost:8090/
**Issue:** Homepage is displaying 10 blog posts instead of 3
**Expected:** Only 3 most recent blog posts should display
**Current:** Showing 10 posts with pagination

**Fix Required:**
- Modify blog view block configuration
- Set items to display: 3
- Remove pagination from homepage block
- Keep full pagination on /blog page

**Estimated Time:** 30 minutes

---

### 4. **Ajánlatkérés Form Styling Issues** 🔴
**Location:** http://localhost:8090/ajánlatkérés
**Issue:** Form appearance doesn't match live site
**Expected:** Form should have:
- Proper spacing and layout
- Styled input fields
- Color-coded labels
- Professional appearance matching Porto theme
- Side-by-side field layout where appropriate

**Current:** Form appears basic/unstyled compared to live site

**Investigation Needed:**
- Check webform theme settings
- Review custom CSS for forms
- Check if Porto theme has webform templates
- Compare form structure with live site
- Check for missing webform display mode settings

**Estimated Time:** 2-4 hours

---

### 5. **Missing Sidebar Form Block on Gallery Pages** 🔴
**Location:** http://localhost:8090/kepgaleria
**Issue:** Gallery pages are missing the quote request form in sidebar
**Expected:** Right sidebar should contain a compact version of the ajánlatkérés form
**Current:** Sidebar only shows taxonomy filters, no form block

**According to WEBFORM_MIGRATION_URGENT.md:**
- Form block was supposed to be created: `porto_ajanlatkeres_sidebar`
- Should be placed in `sidebar_right` region
- Should appear on all `/kepgaleria/*` pages

**Fix Required:**
- Verify webform block exists: `porto_ajanlatkeres_sidebar`
- Check block placement configuration
- Ensure block visibility set for `/kepgaleria*` path
- Test form submission from sidebar

**Estimated Time:** 1-2 hours

---

### 6. **Missing Embedded Images Throughout Site** 🔴
**Location:** Multiple pages, including:
- http://localhost:8090/napelemes-aluminium-kocsibeallo-vilagosszurke-porszorassal
- Various blog posts
- Gallery item detail pages

**Issue:** Images embedded in content body are missing
**Expected:** All inline/embedded images should display within content
**Current:** Some images not rendering (possibly broken paths or missing conversions)

**Known from MEDIA_MIGRATION.md:**
- 22 articles with D7 media tokens were converted
- 70+ images should have been converted
- Script used: `/tmp/convert_media_tokens_v2.php`
- May need to re-run or fix additional articles

**Investigation Needed:**
- Check which articles still have broken image references
- Look for remaining media tokens: `[[{"type":"media"...]]`
- Check for external URL references (phpstack domain)
- Verify file paths are correct
- May need to run additional URL replacement script

**Estimated Time:** 3-5 hours

---

### 7. **Missing Sitemap Page** 🔴
**Location:** http://localhost:8090/sitemap
**Issue:** Sitemap page returns 404 error
**Expected:** Should display full site map with all menu items and structure
**Current:** Page doesn't exist

**On Live Site:**
- Shows "HONLAP TÉRKÉP" heading
- Lists all menu items organized by section
- Includes form at bottom of page
- Uses site_map module (D7)

**Fix Required:**
- Install and enable sitemap module for D10 (e.g., `simple_sitemap` or `site_map`)
- Configure sitemap to display menu structure
- Create custom page if module not suitable
- Ensure URL alias `/sitemap` works

**Estimated Time:** 1-2 hours

---

## 📊 Summary of Issues

| # | Issue | Priority | Est. Time | Status |
|---|-------|----------|-----------|--------|
| 1 | Missing blog images on homepage | 🔴 High | 1-2h | Not Started |
| 2 | Blog formatting issues | 🔴 High | 2-3h | Not Started |
| 3 | Too many blog posts on homepage | 🟡 Medium | 30m | Not Started |
| 4 | Form styling doesn't match live | 🔴 High | 2-4h | Not Started |
| 5 | Missing sidebar form on gallery | 🔴 High | 1-2h | Not Started |
| 6 | Embedded images missing | 🔴 High | 3-5h | Not Started |
| 7 | Missing sitemap page | 🔴 High | 1-2h | Not Started |

**Total Estimated Time:** 11-19 hours

---

## 🔍 Investigation Commands

### Check Blog View Configuration
```bash
# List all blog-related views and displays
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush views:list | grep -i blog"

# Export blog view configuration
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get views.view.blog"

# Check block placements for blog
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT id, region, status FROM block WHERE id LIKE '%blog%';\""
```

### Check Webform Block Status
```bash
# Check if sidebar webform block exists
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT id, region, theme, status FROM block WHERE id LIKE '%ajanlat%' OR id LIKE '%webform%';\""

# List all webform blocks
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get block.block.porto_ajanlatkeres_webform"
```

### Check for Broken Image References
```bash
# Find articles with media tokens
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT nid, title FROM node_field_data WHERE type='article' LIMIT 10;\""

# Check for phpstack URLs still in content
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT COUNT(*) FROM node__body WHERE body_value LIKE '%phpstack%';\""

# Check for remaining media tokens
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT COUNT(*) FROM node__body WHERE body_value LIKE '%[[{%';\""
```

---

## 🛠 Recommended Fix Order

### Phase A: Quick Wins (2-3 hours)
1. **Fix homepage blog count** (30 min)
   - Update view configuration to show 3 posts
   - Remove pagination from block

2. **Add sidebar form block** (1-2h)
   - Create or enable webform block
   - Configure placement on gallery pages
   - Test form submission

### Phase B: Content Fixes (4-6 hours)
3. **Fix embedded images** (3-5h)
   - Identify all broken image references
   - Run URL replacement scripts
   - Verify image paths
   - Test image display across all content types

4. **Fix blog images** (1-2h)
   - Configure image field in blog view
   - Set correct image style
   - Test thumbnail display

### Phase C: Styling & Polish (4-7 hours)
5. **Fix blog formatting** (2-3h)
   - Update view display mode
   - Apply Porto theme templates
   - Adjust CSS as needed

6. **Fix form styling** (2-4h)
   - Apply Porto theme styling to webform
   - Customize form layout
   - Match live site appearance

---

## 📋 Testing Checklist (After Fixes)

### Homepage Testing
- [ ] Exactly 3 blog posts display
- [ ] Each blog post has featured image
- [ ] Blog posts have proper formatting (date, title, excerpt, button)
- [ ] Blog section matches live site appearance
- [ ] "Read More" links work correctly

### Gallery Pages Testing
- [ ] Sidebar form displays on `/kepgaleria`
- [ ] Sidebar form displays on gallery taxonomy pages
- [ ] Sidebar form displays on individual gallery items
- [ ] Form submission works from sidebar
- [ ] Form styling matches main form (compact version)

### Form Testing
- [ ] Main ajánlatkérés form matches live site styling
- [ ] All fields are properly styled
- [ ] Form validation works
- [ ] File upload styled correctly
- [ ] Submit button styled correctly
- [ ] Confirmation message displays properly

### Content Testing
- [ ] All blog post images display correctly
- [ ] Gallery item images display (main gallery images)
- [ ] Embedded images in articles display
- [ ] Embedded images in gallery items display
- [ ] No broken image placeholders
- [ ] All images load from local server (not external URLs)

---

## 🔗 Related Documentation

- **MIGRATION_COMPLETE.md** - Overall migration status
- **MEDIA_MIGRATION.md** - Media file migration details
- **BLOG_FIX.md** - Previous blog page fixes
- **WEBFORM_MIGRATION_URGENT.md** - Webform migration details
- **GALLERY_IMAGE_FIX.md** - Gallery image display fix

---

## 💡 Additional Considerations

### Performance Impact
- Fixing images may require clearing image cache
- CSS changes will require cache rebuild
- Test performance after all fixes applied

### Browser Testing
After fixes, test in:
- Chrome (latest)
- Firefox (latest)
- Safari (if on Mac)
- Mobile browsers (responsive design)

### Comparison with Live Site
For each fix, compare with live site:
- **Live:** https://www.kocsibeallo.hu/
- **Local:** http://localhost:8090/

Take screenshots for visual comparison.

---

## 📞 Next Actions

1. **Review this document** with stakeholder
2. **Prioritize fixes** based on business needs
3. **Allocate time** for development (10-17 hours estimated)
4. **Schedule testing** after each phase
5. **Plan deployment** only after all critical issues resolved

---

**Status:** 🔴 **NOT READY FOR PRODUCTION**
**Blocking Issues:** 6 critical issues must be resolved
**Target:** Complete all fixes before Phase 5 deployment

**Last Updated:** 2025-11-14
**Next Review:** After Phase A completion

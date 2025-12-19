# Urgent Fixes Needed Before Production

**Date:** 2025-11-14
**Priority:** 🔴 **HIGH - Must fix before production deployment**
**Current Phase:** Phase 4 - Issue Identification Complete

---

## 🚨 Critical Issues Identified

### 1. ~~**Missing Blog Images on Homepage**~~ ✅ COMPLETED
**Status:** Fixed - Blog images now display correctly on homepage

---

### 2. ~~**Blog Formatting Issues**~~ ✅ COMPLETED
**Status:** Fixed - Blog post formatting now matches live site styling

---

### 3. ~~**Homepage Shows Too Many Blog Posts**~~ ✅ COMPLETED
**Status:** Fixed - Homepage now displays exactly 3 blog posts

---

### 4. ~~**Ajánlatkérés Form Styling Issues**~~ ✅ COMPLETED
**Status:** Fixed - Form styling now matches live site appearance

---

### 5. ~~**Missing Sidebar Form Block on Gallery Pages**~~ ✅ COMPLETED
**Status:** Fixed - Sidebar form now displays on gallery pages

---

### 6. ~~**Missing Embedded Images Throughout Site**~~ ✅ COMPLETED
**Status:** Fixed - Embedded images now display correctly in content

---

### 7. ~~**Missing Sitemap Page**~~ ✅ COMPLETED
**Status:** Fixed - Sitemap page now exists and returns HTTP 200

---

## 📊 Summary of Issues

| # | Issue | Priority | Est. Time | Status |
|---|-------|----------|-----------|--------|
| 1 | Missing blog images on homepage | 🔴 High | 1-2h | ✅ Completed |
| 2 | Blog formatting issues | 🔴 High | 2-3h | ✅ Completed |
| 3 | Too many blog posts on homepage | 🟡 Medium | 30m | ✅ Completed |
| 4 | Form styling doesn't match live | 🔴 High | 2-4h | ✅ Completed |
| 5 | Missing sidebar form on gallery | 🔴 High | 1-2h | ✅ Completed |
| 6 | Embedded images missing | 🔴 High | 3-5h | ✅ Completed |
| 7 | Missing sitemap page | 🔴 High | 1-2h | ✅ Completed |

**All issues resolved! 🎉**

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
- [x] Exactly 3 blog posts display ✅
- [x] Each blog post has featured image ✅
- [x] Blog posts have proper formatting (date, title, excerpt, button) ✅
- [x] Blog section matches live site appearance ✅
- [x] "Read More" links work correctly ✅

### Gallery Pages Testing
- [x] Sidebar form displays on `/kepgaleria` ✅
- [x] Sidebar form displays on gallery taxonomy pages ✅
- [x] Sidebar form displays on individual gallery items ✅
- [x] Form submission works from sidebar ✅
- [x] Form styling matches main form (compact version) ✅

### Form Testing
- [x] Main ajánlatkérés form matches live site styling ✅
- [x] All fields are properly styled ✅
- [x] Form validation works ✅
- [x] File upload styled correctly ✅
- [x] Submit button styled correctly ✅
- [x] Confirmation message displays properly ✅

### Content Testing
- [x] All blog post images display correctly ✅
- [x] Gallery item images display (main gallery images) ✅
- [x] Embedded images in articles display ✅
- [x] Embedded images in gallery items display ✅
- [x] No broken image placeholders ✅
- [x] All images load from local server (not external URLs) ✅

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

**Status:** ✅ **READY FOR PRODUCTION**
**Blocking Issues:** None - All 7 issues resolved!
**Completed:** 7 of 7 issues resolved ✅
**Target:** Proceed with Phase 5 deployment

**Last Updated:** 2025-12-15
**Completion Date:** 2025-12-15

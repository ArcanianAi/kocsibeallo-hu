# TASK-005: Fix Blog Formatting to Match Live Site

## Status: 🟡 IN_PROGRESS

---

## 📋 Task Details

**Job ID:** TASK-005
**Priority:** 🔴 High
**Estimated Time:** 2-3 hours
**Phase:** C - Styling & Polish
**Dependencies:** TASK-001, TASK-003 (blog count and images fixed)

---

## 📝 Description

Blog post formatting on homepage doesn't match the live site styling. Need to update templates, CSS, and view display mode to achieve proper card layout with featured image, date, title, excerpt, and "Read More" button.

---

## 🔍 Current State

**Location:** http://localhost:8090/

**Issue:**
- Blog post formatting incomplete or different from live
- Missing proper card layout structure
- Date format may be incorrect
- Layout doesn't match Porto theme expectations

**Expected:**
- Blog posts in card layout with:
  - Featured image (top)
  - Date display (day + month format)
  - Title
  - Teaser/excerpt
  - "Read More" button/link
- Styling matches live site
- Responsive design works

---

## 🎯 Expected Result

After fix:
- Blog posts have consistent card layout
- Date displayed in Hungarian format (e.g., "10 Nov")
- Proper spacing and typography
- "Read More" button styled correctly
- Hover effects work (if applicable)
- Mobile responsive
- Matches live site appearance

---

## 🔬 Investigation Steps

1. **Compare live vs local**
   - Live: https://www.kocsibeallo.hu/
   - Local: http://localhost:8090/
   - Screenshot comparison
   - Inspect element to see CSS classes

2. **Check current view display mode**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get views.view.blog"
   ```

3. **Check Porto theme blog templates**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "find /app/web/themes/contrib/porto_theme -name '*blog*' -o -name '*article*' | grep -E '\.(twig|css)$'"
   ```

4. **Inspect live site HTML structure**
   - Check wrapper classes
   - Check card structure
   - Note CSS classes used
   - Check date formatting

5. **Check teaser display mode**
   - URL: http://localhost:8090/admin/structure/types/manage/article/display/teaser

---

## 🛠 Implementation Steps

### Phase 1: Analysis (30 min)

1. **Document live site structure**
   - Take screenshots
   - Note HTML structure
   - List CSS classes
   - Document date format

2. **Check current display mode**
   - View settings
   - Field order
   - Field formatters

### Phase 2: Update View Display (1 hour)

1. **Edit blog view**
   - URL: http://localhost:8090/admin/structure/views/view/blog

2. **Configure fields in proper order**
   - Image (if not already done in TASK-003)
   - Date (formatted appropriately)
   - Title
   - Body (trimmed/summary)
   - Read more link

3. **Set display mode**
   - Try "Teaser" display mode first
   - Or use "Rendered entity" with teaser view mode

4. **Configure date field**
   - Format: Custom or predefined
   - Pattern: "d M" for day + month
   - Language: Hungarian

### Phase 3: Template Customization (1 hour)

1. **Check if Porto has blog templates**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "ls -la /app/web/themes/contrib/porto_theme/templates/"
   ```

2. **Create custom template if needed**
   - Copy from Porto or Drupal core
   - Customize for card layout
   - Place in theme templates directory

3. **Common templates to check:**
   - `node--article--teaser.html.twig`
   - `views-view-unformatted--blog.html.twig`
   - `views-view--blog.html.twig`

### Phase 4: CSS Styling (30 min)

1. **Add custom CSS to custom-user.css**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "vim /app/web/themes/contrib/porto_theme/css/custom-user.css"
   ```

2. **Possible CSS additions:**
   ```css
   .blog-card {
     /* Card styling */
   }

   .blog-card .date {
     /* Date styling */
   }

   .blog-card .read-more {
     /* Button styling */
   }
   ```

3. **Match live site colors and spacing**

### Phase 5: Testing (30 min)

1. **Clear cache**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cache:rebuild --uri='http://localhost:8090'"
   ```

2. **Test responsive design**
   - Desktop
   - Tablet
   - Mobile

3. **Compare with live site**

---

## ✅ Testing Checklist

- [ ] Blog cards have proper structure
- [ ] Featured image displays at top
- [ ] Date in correct format (Hungarian)
- [ ] Title styled correctly
- [ ] Excerpt/teaser displays
- [ ] "Read More" button present and styled
- [ ] Proper spacing between elements
- [ ] Card borders/shadows match (if applicable)
- [ ] Hover effects work
- [ ] Mobile responsive
- [ ] Matches live site closely
- [ ] All blog posts have consistent formatting
- [ ] Typography matches site theme

---

## 📊 Progress Notes

### [Date] - [Status Update]
- Note progress here as work proceeds
- Document template changes
- Note CSS additions

---

## 📁 Related Files

**Configuration:**
- `views.view.blog` - View configuration
- `core.entity_view_display.node.article.teaser` - Teaser display mode

**Templates:**
- Porto theme templates (TBD based on investigation)
- Custom templates (if created)

**CSS:**
- `/app/web/themes/contrib/porto_theme/css/custom-user.css`

**URLs:**
- Blog view: http://localhost:8090/admin/structure/views/view/blog
- Display mode: http://localhost:8090/admin/structure/types/manage/article/display/teaser
- Test page: http://localhost:8090/

---

## 🔗 References

- [URGENT_FIXES_NEEDED.md](../fixes/URGENT_FIXES_NEEDED.md) - Issue #2
- [BLOG_FIX.md](../fixes/BLOG_FIX.md) - Previous blog fixes
- [THEME_REFERENCE.md](../reference/THEME_REFERENCE.md) - Porto theme reference
- [CUSTOM_CSS_APPLIED.md](../tasks/CUSTOM_CSS_APPLIED.md) - CSS customizations
- [ENVIRONMENT_URLS.md](../ENVIRONMENT_URLS.md) - All URLs

---

## 💡 Live Site Structure Reference

To be documented during investigation phase:
- HTML structure
- CSS classes
- Date format pattern
- Card layout details

---

**Created:** 2025-11-15
**Last Updated:** 2025-11-15
**Status:** ⚪ TODO

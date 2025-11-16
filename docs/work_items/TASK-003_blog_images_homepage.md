# TASK-003: Fix Missing Blog Images on Homepage

## Status: 🟢 COMPLETE

---

## 📋 Task Details

**Job ID:** TASK-003
**Priority:** 🔴 High
**Estimated Time:** 1-2 hours
**Phase:** B - Content Fixes
**Dependencies:** TASK-001 (blog count fix)

---

## 📝 Description

Blog post thumbnails are not displaying on the homepage. Each blog post should have a featured image thumbnail in the teaser display.

---

## 🔍 Current State

**Location:** http://localhost:8090/

**Issue:**
- Blog posts on homepage missing thumbnail images
- Image field not configured or not displaying
- Posts show title, excerpt, but no image

**Expected:**
- Each blog post has featured image thumbnail
- Images sized appropriately for teaser view
- Images link to full article (if applicable)

---

## 🎯 Expected Result

After fix:
- All blog posts on homepage display featured images
- Images are properly sized (thumbnail/teaser size)
- Images maintain aspect ratio
- No broken image placeholders
- Matches live site appearance

---

## 🔬 Investigation Steps

1. **Check blog view field configuration**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get views.view.blog"
   ```

2. **Check if image field exists on article content type**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush field:list node.article"
   ```

3. **Check blog posts have images**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT n.nid, n.title, GROUP_CONCAT(f.uri) as images FROM node_field_data n LEFT JOIN node__field_image i ON n.nid = i.entity_id LEFT JOIN file_managed f ON i.field_image_target_id = f.fid WHERE n.type='article' GROUP BY n.nid LIMIT 10;\""
   ```

4. **Check image styles**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush image:styles:list"
   ```

5. **Compare with live site**
   - Live: https://www.kocsibeallo.hu/
   - Check image field name
   - Check image style used

---

## 🛠 Implementation Steps

1. **Edit blog view**
   - URL: http://localhost:8090/admin/structure/views/view/blog
   - Select appropriate display (Block or Page)

2. **Add image field if missing**
   - Add field: "Content: Image" or "Content: Field Image"
   - Configure formatter: Image
   - Select image style (thumbnail, medium, teaser, etc.)
   - Set link image to: Content (optional)

3. **Reorder fields**
   - Position image field appropriately
   - Typically: Image, Title, Date, Teaser/Body

4. **Configure image style**
   - Check existing styles: http://localhost:8090/admin/config/media/image-styles
   - Create new style if needed (e.g., "blog_teaser")
   - Recommended size: 400x300 or similar

5. **Update view display settings**
   - Ensure field is not excluded
   - Check field visibility settings
   - Verify wrapper/template settings

6. **Clear cache**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cache:rebuild --uri='http://localhost:8090'"
   ```

7. **Regenerate image styles if needed**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush image:flush --all"
   ```

---

## ✅ Testing Checklist

- [x] All blog posts on homepage show images
- [x] Images are properly sized
- [x] No broken image placeholders
- [x] Images maintain aspect ratio
- [x] Images load correctly
- [x] Click on image goes to article (if configured)
- [x] Images display on mobile
- [x] Compare with live site layout
- [x] Check image alt text is present
- [x] Verify image lazy loading (if enabled)

---

## 📊 Progress Notes

### 2025-11-15 - COMPLETED
**Issue Identified:**
- Blog view (block_1 display) was missing the image field
- Porto theme template didn't render image field
- Multi-value field was showing all images instead of just the first one

**Solution Implemented:**
1. Added field_image to blog view's block_1 display via Views UI
2. Configured image field settings:
   - Formatter: Image
   - Image style: Közepes (220×220)
   - Link to: Content
   - Image loading: Lazy
   - Delta limit: 1 (show only first image)
3. Updated Porto theme template: `views-view-fields--blog--block-1.html.twig`
   - Added image field rendering between date and title
4. Cleared cache twice (after view update and template update)

**Result:**
- All 3 blog posts now display featured images on homepage
- Images are properly sized (220x220)
- Only first image displays for posts with multiple images
- Images link to full article
- Lazy loading enabled for performance

---

## 📁 Related Files

**Configuration:**
- `views.view.blog` - Blog view configuration
- `image.style.*` - Image style configurations
- `field.field.node.article.field_image` - Image field config

**Templates:**
- Blog teaser templates in Porto theme

**URLs:**
- Blog view admin: http://localhost:8090/admin/structure/views/view/blog
- Image styles: http://localhost:8090/admin/config/media/image-styles
- Test page: http://localhost:8090/

---

## 🔗 References

- [URGENT_FIXES_NEEDED.md](../fixes/URGENT_FIXES_NEEDED.md) - Issue #1
- [BLOG_FIX.md](../fixes/BLOG_FIX.md) - Previous blog fixes
- [MEDIA_MIGRATION.md](../migration/MEDIA_MIGRATION.md) - Media migration details
- [ENVIRONMENT_URLS.md](../ENVIRONMENT_URLS.md) - All URLs

---

## 💡 Potential Issues

- Image field might have different machine name (field_featured_image, field_main_image, etc.)
- Images might exist but formatter not configured
- Image style might not be appropriate for layout
- Template might be overriding view display

---

**Created:** 2025-11-15
**Last Updated:** 2025-11-15
**Status:** 🟢 COMPLETE

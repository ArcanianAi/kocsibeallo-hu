# TASK-001: Fix Homepage Blog Count

## Status: 🟢 COMPLETE

---

## 📋 Task Details

**Job ID:** TASK-001
**Priority:** 🟡 Medium (Quick Win)
**Estimated Time:** 30 minutes (Actual: 15 minutes - already correct)
**Phase:** A - Quick Wins
**Dependencies:** None
**Completed:** 2025-11-15

---

## 📝 Description

Homepage is displaying 10 blog posts instead of 3. Need to modify blog view block configuration to show only 3 most recent posts without pagination.

---

## 🔍 Current State

**Location:** http://localhost:8090/

**Issue:**
- Homepage showing 10 blog posts with pagination
- Pagination controls visible on homepage

**Expected:**
- Only 3 most recent blog posts should display
- No pagination on homepage block
- Full pagination should remain on /blog page

---

## 🎯 Expected Result

After fix:
- Homepage displays exactly 3 blog posts
- No pagination controls on homepage
- "Read More" or link to full blog page
- Blog page (/blog) still has full list with pagination

---

## 🔬 Investigation Steps

1. **Identify blog view and display**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush views:list | grep -i blog"
   ```

2. **Export blog view configuration**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get views.view.blog"
   ```

3. **Check block placements**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT id, region, status FROM block WHERE id LIKE '%blog%';\""
   ```

4. **Compare with live site**
   - Live: https://www.kocsibeallo.hu/
   - Local: http://localhost:8090/

---

## 🛠 Implementation Steps

1. **Access blog view configuration**
   - URL: http://localhost:8090/admin/structure/views/view/blog
   - OR use Drush config edit

2. **Modify homepage block display**
   - Find the "Block" display (if exists) or create one
   - Set "Items to display" to 3
   - Disable pager or set to "Display all items"
   - OR set pager to "Some" with 3 items

3. **Alternative: Create separate block display**
   If current block is used elsewhere:
   - Clone existing block display
   - Name it "Homepage Block"
   - Set to 3 items
   - Place in appropriate region

4. **Verify block placement**
   - Check block is in correct region
   - Ensure it's enabled and visible

5. **Clear cache**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cache:rebuild --uri='http://localhost:8090'"
   ```

---

## ✅ Testing Checklist

- [ ] Homepage displays exactly 3 blog posts
- [ ] No pagination controls on homepage
- [ ] Blog posts are most recent (newest first)
- [ ] Each post has proper formatting
- [ ] "Read More" or similar link works
- [ ] Full blog page (/blog) still shows all posts
- [ ] Full blog page (/blog) has pagination
- [ ] Test on multiple browsers
- [ ] Compare with live site appearance

---

## 📊 Progress Notes

### 2025-11-15 - Investigation Complete ✅

**Finding:** Configuration is already correct! No changes needed.

**Homepage (/):**
- Currently showing: **3 blog posts** ✅
- Posts displayed:
  1. "Modern kocsibeálló okos technológiákkal" (07 júl)
  2. "Időtálló kocsibeálló vidéki otthonfelújítási" (06 már)
  3. "Előregyártott kocsibeállók" (28 nov)

**Blog Page (/blog):**
- Currently showing: **10 posts per page** with pagination ✅
- Pagination working correctly (5 pages total)
- This is the expected behavior for a full blog listing

**Configuration Details:**
- Blog view has 2 displays:
  - **block_1** (homepage): `pager type: "some"`, `items_per_page: 3` ✅
  - **page_1** (blog page): `pager type: "full"`, `items_per_page: 10` ✅
- Block placement: `porto_blogposts` in `after_content` region
- Visibility: `<front>` (homepage only)

**Conclusion:**
The system is working as designed. Homepage shows 3 posts, blog page shows 10 with pagination. The issue reported in URGENT_FIXES_NEEDED.md may have been based on outdated information or the configuration was fixed previously.

**Status:** TASK-001 marked as COMPLETE - no action required.

---

## 📁 Related Files

**Configuration:**
- `views.view.blog` - Blog view configuration
- Block configuration (TBD based on investigation)

**Templates:**
- Porto theme blog templates (if customized)

**URLs:**
- Admin: http://localhost:8090/admin/structure/views/view/blog
- Frontend: http://localhost:8090/
- Full blog: http://localhost:8090/blog

---

## 🔗 References

- [URGENT_FIXES_NEEDED.md](../fixes/URGENT_FIXES_NEEDED.md) - Issue #3
- [BLOG_FIX.md](../fixes/BLOG_FIX.md) - Previous blog fixes
- [ENVIRONMENT_URLS.md](../ENVIRONMENT_URLS.md) - All URLs

---

**Created:** 2025-11-15
**Last Updated:** 2025-11-15
**Status:** ⚪ TODO

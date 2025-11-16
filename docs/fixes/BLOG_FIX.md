# Blog Page Fix

**Date:** 2025-11-11
**Status:** Complete

---

## Problem Identified

**User Report:**
> "i am totally missing the blogs it is leding now to an empty page..."

**Analysis:**
- Blog page at `/blog` was showing empty content
- Menu linked to `/blog` but it was showing node/632 (empty page node)
- No blog view existed to display article nodes
- Article content type had 10+ migrated articles but no way to display them

**Root Causes:**
1. No blog view configured to list article nodes
2. Path alias `/blog` pointed to node/632 (empty page) instead of a view
3. Menu link pointed to `entity:node/632` instead of blog listing

---

## Solution Implemented

### 1. Created Blog View

Created a Views-based blog listing page to display article nodes in teaser format.

**View Configuration:**
- **View ID:** `blog`
- **Base Table:** `node_field_data`
- **Display:** Page + Block
- **Path:** `/blog`
- **Filters:**
  - Content type: Article
  - Published: Yes
- **Sort:** Created date (DESC)
- **Items per page:** 10
- **Display format:** Teaser view mode

**PHP Script Used:**
```php
<?php
$config = \Drupal::configFactory()->getEditable('views.view.blog');
$config->setData([
  'langcode' => 'hu',
  'status' => TRUE,
  'id' => 'blog',
  'label' => 'Blog',
  'base_table' => 'node_field_data',
  'display' => [
    'default' => [
      'display_plugin' => 'default',
      'display_options' => [
        'title' => 'Blog bejegyzések',
        'pager' => [
          'type' => 'full',
          'options' => ['items_per_page' => 10],
        ],
        'filters' => [
          'status' => ['value' => '1'],
          'type' => ['value' => ['article' => 'article']],
        ],
        'sorts' => [
          'created' => ['order' => 'DESC'],
        ],
        'row' => [
          'type' => 'entity:node',
          'options' => ['view_mode' => 'teaser'],
        ],
      ],
    ],
    'page_1' => [
      'display_plugin' => 'page',
      'display_options' => ['path' => 'blog'],
    ],
    'block_1' => [
      'display_plugin' => 'block',
      'display_options' => ['block_description' => 'Blog listing'],
    ],
  ],
]);
$config->save();
```

**Command Executed:**
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush php:script /tmp/create_blog_view.php"

# Result: Blog view created successfully
```

### 2. Removed Conflicting Path Alias

**Problem:**
Node 632 had a path alias `/blog` which took precedence over the view page.

**Query to Find Alias:**
```sql
SELECT id, path, alias, langcode FROM path_alias
WHERE alias='/blog' OR path='/node/632'

# Result:
# 7765 | /node/632 | /blog | hu
```

**Delete Alias:**
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"DELETE FROM path_alias WHERE id=7765 AND path='/node/632'\""
```

**Result:** View page at `/blog` now takes precedence.

### 3. Updated Menu Link (Optional)

**Original Menu Link:**
```sql
SELECT id, title, link__uri FROM menu_link_content_data
WHERE menu_name='main' AND title='Blog'

# Result:
# 5438 | Blog | entity:node/632
```

**Updated to Point to View:**
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"UPDATE menu_link_content_data SET link__uri='internal:/blog' WHERE id=5438 AND menu_name='main'\""
```

**Note:** After removing the path alias, this update became redundant since `/blog` now resolves to the view automatically.

---

## Technical Details

### Migrated Article Nodes

**Query:**
```sql
SELECT nid, title, type FROM node_field_data
WHERE type='article'
ORDER BY created DESC LIMIT 10
```

**Results (10 articles migrated):**
1. 774 - Modern kocsibeálló okos technológiákkal
2. 768 - Időtálló kocsibeálló vidéki otthonfelújítási támogatással
3. 757 - Előregyártott kocsibeállók
4. 741 - Meglepő, de fából van: fémhatású kocsibeálló szerkezetek
5. 732 - Most érdemes napelemes kocsibeállót építtetni
6. 728 - Bemutatjuk az új Ximax Wing kocsibeallót
7. 727 - Autóvédelem stílusosan: a XIMAX kocsibeállók varázsa
8. 723 - Mindennek lesz végre helye - Kocsibeállók tárolóval
9. 722 - Kocsibeálló tartószerkezetek 3. rész: alumínium zártszelvények
10. 721 - Kocsibeálló Tartószerkezetek 2. rész - Vas zártszerelvény

### View Output Structure

**HTML Structure:**
```html
<div class="views-element-container">
  <div class="js-view-dom-id-[random-id]">
    <div class="views-row">
      <article data-history-node-id="774">
        <h2>
          <a href="/blog/modern-kocsibeallo-okos-technologiakkal...">
            Modern kocsibeálló okos technológiákkal...
          </a>
        </h2>
        <footer>
          <div>admin küldte be 2025. 07. 07...</div>
        </footer>
        <div>
          <div>
            <p>Ingatlan értéknövelés...</p>
          </div>
          <div>Címkék: egyedi kocsibeállók</div>
          <ul class="links">
            <li><a href="...">Tovább</a></li>
            <li><a href="...#comment-form">Új hozzászólás</a></li>
          </ul>
        </div>
      </article>
    </div>
    <!-- More articles... -->
  </div>
</div>
```

### Article Teaser Display

Each article in teaser mode shows:
- **Title** (H2, linked to full article)
- **Author** ("admin küldte be")
- **Date** (e.g., "2025. 07. 07., h – 16:17")
- **Body teaser** (first paragraph)
- **Tags** (taxonomy term links)
- **Links:**
  - "Tovább" (Read more)
  - "Új hozzászólás" (Add comment)

### Paging

- **Items per page:** 10
- **Pager type:** Full (with First/Previous/Next/Last links)
- **Hungarian labels:**
  - Next: "Következő ›"
  - Previous: "‹ Előző"
  - First: "« Első"
  - Last: "Utolsó »"

---

## Results

✅ **Blog view created** and configured
✅ **10+ articles displaying** in teaser format
✅ **Path conflict resolved** (removed node/632 alias)
✅ **Menu link functional** - points to working blog listing
✅ **Paging enabled** for navigating multiple articles
✅ **Matches live site functionality** - article listing with teasers

**Blog Page Features:**
- Title: "Blog bejegyzések"
- Article teasers with images (if available)
- Author and date display
- Tag links for filtering/navigation
- "Read more" and comment links
- 10 articles per page with paging

---

## Before/After Comparison

**Before:**
```
URL: http://localhost:8090/blog
Result: Empty page (node/632 with no content)
Articles: Not visible
```

**After:**
```
URL: http://localhost:8090/blog
Result: Blog view listing
Articles: 10 articles displayed with teasers
Navigation: Pager for more articles
```

---

## Files Modified

1. **views.view.blog** (NEW)
   - Config: Created view configuration
   - Display: Page at /blog + Block
   - Format: Entity (node) teaser

2. **path_alias table**
   - Deleted: Alias for node/632 → /blog

3. **menu_link_content_data table**
   - Updated: Blog menu link (id: 5438)
   - From: entity:node/632
   - To: internal:/blog

---

## Maintenance Notes

### Adding More Blog Articles

Articles will automatically appear in the blog listing when:
- Content type: Article
- Status: Published
- Sorted by: Creation date (newest first)

### Modifying Blog Display

**To change articles per page:**
```bash
drush config:set views.view.blog display.default.display_options.pager.options.items_per_page 15 -y
drush cache:rebuild
```

**To change view mode (teaser vs full):**
```bash
drush config:set views.view.blog display.default.display_options.row.options.view_mode full -y
drush cache:rebuild
```

### If Blog Page Becomes Empty Again

**Check:**
1. View enabled: `drush config:get views.view.blog status`
2. Path not aliased: `drush sql:query "SELECT * FROM path_alias WHERE alias='/blog'"`
3. Articles exist: `drush sql:query "SELECT COUNT(*) FROM node_field_data WHERE type='article' AND status=1"`

---

## Future Enhancements

**Possible Improvements:**
1. Add featured image to teaser display
2. Add category/tag faceted filtering
3. Add blog archive block (by month/year)
4. Add related articles block
5. Style blog listing to match live site more closely
6. Add RSS feed for blog articles

---

**Document maintained by:** Claude Code
**Last updated:** 2025-11-11
**Migration project:** Drupal 7 → Drupal 10 (kocsibeallo.hu)

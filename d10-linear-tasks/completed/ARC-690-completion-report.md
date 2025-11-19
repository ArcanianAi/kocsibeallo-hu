# ARC-690: Display and format blog post dates on /blog list page

## Linear Task Link
https://linear.app/arcanian/issue/ARC-690/display-and-format-blog-post-dates-on-blog-list-page

---

## Summary
Added the `created` date field to the article teaser display configuration and updated field weights for proper ordering.

---

## Changes Made

### Configuration File Modified
`config/sync/core.entity_view_display.node.article.teaser.yml`

### Changes
1. **Added `created` field**
   - Type: `timestamp`
   - Format: custom `'d M'` (e.g., "17 Nov")
   - Weight: 1 (appears after image)
   - Label: hidden

2. **Updated field weights**
   - field_image: 0 (unchanged)
   - created: 1 (NEW)
   - body: 2 (was 1)
   - field_tags: 3 (was 2)
   - field_thumbnail: 4 (was 3)
   - links: 10 (unchanged)

---

## CSS Already Applied (from ARC-681)

The date badge CSS was already added in the previous task:
```css
/* Date badge - positioned over featured image */
.view-blog article .field--name-created {
  position: absolute;
  top: 20px;
  left: 20px;
  background: #011e41;
  color: #fff;
  padding: 10px 15px;
  text-align: center;
  z-index: 10;
  line-height: 1;
}
```

---

## Date Format

- Custom format: `d M`
- Example output: "17 Nov"
- Position: Overlay on top-left of featured image

---

## Deployment Requirements

After deploying config changes:
```bash
cd web && ../vendor/bin/drush config:import -y
../vendor/bin/drush cr
```

---

## Local Verification Steps

1. Import config: `drush cim -y`
2. Clear cache: `drush cr`
3. Visit http://localhost:8090/blog
4. Verify date badge appears on blog posts
5. Check date format displays correctly
6. Verify date overlays image properly

---

## Time Spent
~10 minutes

---

## Notes
- Date format `d M` shows day and abbreviated month
- Can be changed to `d M Y` for full year
- CSS positions date badge absolutely over image

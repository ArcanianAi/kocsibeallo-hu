# ARC-822: Fix missing galleries - Palram pages

**Status:** Completed
**Date:** 2025-11-25
**Commit:** Database changes only (documented in db-backup-arc822-20251125-101952.sql.gz)

## Summary
Added gallery links to three Palram product pages (Arizona 5000, Arcadia, Atlas 5000) and tagged relevant gallery items with the palram taxonomy term.

## Changes Made

### 1. Tagged Gallery Items with Palram Term (tid 194)
Added `field_gallery_tag` = 194 (palram) to the following gallery items:

- **Node 595**: Polikarbonát kocsibeálló egy oldalon elhelyezett oszlopokkal
- **Node 601**: Alumínium kocsibeálló polikarbonát fedéssel
- **Node 700**: Antracit színű kocsibeálló polikarbonát fedéssel
- **Node 731**: Modern alumínium kocsibeálló polikarbonát fedéssel, LED csíkokkal
- **Node 746**: Palram Arizona előregyártott kocsibeálló (already tagged)

### 2. Added Gallery Links to Product Pages
Added identical gallery link sections to the body content of three Palram product pages:

- **Node 696**: Palram Arizona 5000 kocsibeálló
- **Node 697**: Palram Arcadia kocsibeálló
- **Node 703**: Palram Atlas 5000 kocsibeálló

Gallery link HTML:
```html
<h2>Palram kocsibeállók képgaléria</h2>
<p>Tekintse meg Palram kocsibeálló referenciáinkat!</p>
<p class="rtecenter"><a class="myButton" href="/kepgaleria/field_gallery_tag/palram-194">Palram képgaléria</a></p>
```

## Database Tables Modified
- `node__field_gallery_tag` - Added palram tag to 4 gallery items
- `node_revision__field_gallery_tag` - Added palram tag to revisions
- `node__body` - Added gallery links to 3 product pages
- `node_revision__body` - Added gallery links to revisions

## SQL Commands Used

### Tag gallery items:
```sql
INSERT INTO node__field_gallery_tag (bundle, deleted, entity_id, revision_id, langcode, delta, field_gallery_tag_target_id)
VALUES
  ('foto_a_galeriahoz', 0, 595, (SELECT vid FROM node_field_data WHERE nid=595), 'hu', 1, 194),
  ('foto_a_galeriahoz', 0, 700, (SELECT vid FROM node_field_data WHERE nid=700), 'hu', 1, 194),
  ('foto_a_galeriahoz', 0, 601, (SELECT vid FROM node_field_data WHERE nid=601), 'hu', 1, 194),
  ('foto_a_galeriahoz', 0, 731, (SELECT vid FROM node_field_data WHERE nid=731), 'hu', 1, 194);
```

### Add gallery links (example for node 696):
```sql
UPDATE node__body
SET body_value = CONCAT(body_value, '<h2>Palram kocsibeállók képgaléria</h2>\n<p>Tekintse meg Palram kocsibeálló referenciáinkat!</p>\n<p class="rtecenter"><a class="myButton" href="/kepgaleria/field_gallery_tag/palram-194">Palram képgaléria</a></p>\n\n')
WHERE entity_id = 696 AND bundle = 'page';
```

## Testing
- Cache cleared with `drush cr`
- Gallery URL: `/kepgaleria/field_gallery_tag/palram-194`
- Product pages now have gallery links before the quote request button

## Deployment Notes
**Database backup:** `db-backup-arc822-20251125-101952.sql.gz`

To deploy to Nexcess:
1. SSH into Nexcess server
2. Navigate to drupal directory
3. Run the same SQL commands via drush sql-query
4. Clear cache with `drush cr`

## Result
All three Palram product pages now have functional gallery links showing 5 relevant gallery items tagged with "palram".

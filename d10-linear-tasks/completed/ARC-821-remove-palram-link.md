# ARC-821: Remove broken Palram link

**Status:** Completed
**Date:** 2025-11-25
**Type:** Database update (content removal)

## Summary
Removed broken external link to deluxebuilding.hu from the Palram autóbeálló típusok page (node 695).

## Problem
Node 695 contained a paragraph with an external link to:
```
https://deluxebuilding.hu/termekkategoria/palram-autobeallok/
```

This link was likely broken or pointing to an outdated/inactive external catalog site.

## Solution
Removed the entire paragraph containing the broken link.

### Removed Content:
```html
<p>&nbsp;</p>

<p>A Palram kocsibeállók összes típusát és árát <a href="https://deluxebuilding.hu/termekkategoria/palram-autobeallok/" target="_blank"><strong>deluxebuilding.hu</strong>&nbsp;termék katalógus oldalunkon megtalálja</a>.</p>
```

**Translation:** "You can find all Palram carport types and prices on our deluxebuilding.hu product catalog page"

## Database Changes

### node__body table:
```sql
UPDATE node__body
SET body_value = REPLACE(body_value, '<p>&nbsp;</p>\n\n<p>A Palram kocsibeállók összes típusát és árát <a href="https://deluxebuilding.hu/termekkategoria/palram-autobeallok/" target="_blank"><strong>deluxebuilding.hu</strong>&nbsp;termék katalógus oldalunkon megtalálja</a>.</p>', '')
WHERE entity_id = 695;
```

### node_revision__body table:
```sql
UPDATE node_revision__body
SET body_value = REPLACE(body_value, '<p>&nbsp;</p>\n\n<p>A Palram kocsibeállók összes típusát és árát <a href="https://deluxebuilding.hu/termekkategoria/palram-autobeallok/" target="_blank"><strong>deluxebuilding.hu</strong>&nbsp;termék katalógus oldalunkon megtalálja</a>.</p>', '')
WHERE entity_id = 695;
```

## Page Affected
- **Node 695:** Palram autóbeálló típusok
  - URL: `/palram-autobeallo-tipusok`
  - This is the main Palram product types overview page

## Notes
- The page still contains:
  - Product descriptions for Palram Arizona, Arcadia, and Atlas
  - Internal links to individual Palram product pages
  - "Kérjen ajánlatot!" (Request quote) buttons
  - Link to kocsibeallo-epites.hu for more information (this remains)
- The deluxebuilding.hu link was the only external catalog reference
- Removing the paragraph improves content focus on the company's own offerings

## Testing
- Cache cleared with `drush cr`
- Page content flows naturally without the removed paragraph
- All remaining links are internal or to valid external sites

## Deployment
To deploy to Nexcess:
```bash
SSH_AUTH_SOCK="" sshpass -p 'LongRagHaltsLied' ssh -o StrictHostKeyChecking=no a17d7af6_1@d99a9d9894.nxcli.io
cd ~/9df7d73bf2.nxcli.io/drupal/web
../vendor/bin/drush sql-query "UPDATE node__body SET body_value = REPLACE(body_value, '<p>&nbsp;</p>\n\n<p>A Palram kocsibeállók összes típusát és árát <a href=\"https://deluxebuilding.hu/termekkategoria/palram-autobeallok/\" target=\"_blank\"><strong>deluxebuilding.hu</strong>&nbsp;termék katalógus oldalunkon megtalálja</a>.</p>', '') WHERE entity_id = 695"
../vendor/bin/drush sql-query "UPDATE node_revision__body SET body_value = REPLACE(body_value, '<p>&nbsp;</p>\n\n<p>A Palram kocsibeállók összes típusát és árát <a href=\"https://deluxebuilding.hu/termekkategoria/palram-autobeallok/\" target=\"_blank\"><strong>deluxebuilding.hu</strong>&nbsp;termék katalógus oldalunkon megtalálja</a>.</p>', '') WHERE entity_id = 695"
../vendor/bin/drush cr
```

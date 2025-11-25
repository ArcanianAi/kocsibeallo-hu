# ARC-823: Fix inline trapéz image link

**Status:** Completed
**Date:** 2025-11-25
**Type:** Database update (link fix)

## Summary
Fixed broken inline image link on "Egyedi gyártású nyitott kocsibeállók" page (node 591) that linked to trapézlemez gallery page.

## Problem
The inline trapézlemez image on node 591 had a broken link:
- **Broken link:** `/trapézlemezzel-fedett-kocsibeálló` (with accents)
- **Correct path:** `/galeria/trapezlemezzel-fedett-kocsibeallo` (path alias for node 593)

The link used accented characters which don't match the actual URL path alias.

## Solution
Updated the body content of node 591 to use the correct path alias without accents.

## Database Changes

### node__body table:
```sql
UPDATE node__body
SET body_value = REPLACE(body_value, '/trapézlemezzel-fedett-kocsibeálló', '/galeria/trapezlemezzel-fedett-kocsibeallo')
WHERE entity_id = 591;
```

### node_revision__body table:
```sql
UPDATE node_revision__body
SET body_value = REPLACE(body_value, '/trapézlemezzel-fedett-kocsibeálló', '/galeria/trapezlemezzel-fedett-kocsibeallo')
WHERE entity_id = 591;
```

## Pages Affected
- **Node 591:** Egyedi gyártású nyitott kocsibeállók (custom carports page)
  - URL: `/egyedi-gyártású-nyitott-kocsibeállók`
- **Node 593:** Trapézlemezzel fedett kocsibeálló (trapeze roofing gallery page)
  - URL: `/galeria/trapezlemezzel-fedett-kocsibeallo`

## Image Details
The inline image that now links correctly:
- **Source:** `/sites/default/files/styles/large/public/gallery/main/porfestett_acel_kocsibeallo-trapezlemez-tetovel-2.jpg`
- **Alt text:** "Trapézlemezzel fedett kocsibeálló"
- **Title:** "Porfestett acél szerkezet, trapézlemez tetővel"

## Testing
- Cache cleared with `drush cr`
- Link now properly directs to the trapezlemezzel gallery page
- Image displays correctly with working clickable link

## Deployment
To deploy to Nexcess:
```bash
SSH_AUTH_SOCK="" sshpass -p 'LongRagHaltsLied' ssh -o StrictHostKeyChecking=no a17d7af6_1@d99a9d9894.nxcli.io
cd ~/9df7d73bf2.nxcli.io/drupal/web
../vendor/bin/drush sql-query "UPDATE node__body SET body_value = REPLACE(body_value, '/trapézlemezzel-fedett-kocsibeálló', '/galeria/trapezlemezzel-fedett-kocsibeallo') WHERE entity_id = 591"
../vendor/bin/drush sql-query "UPDATE node_revision__body SET body_value = REPLACE(body_value, '/trapézlemezzel-fedett-kocsibeálló', '/galeria/trapezlemezzel-fedett-kocsibeallo') WHERE entity_id = 591"
../vendor/bin/drush cr
```

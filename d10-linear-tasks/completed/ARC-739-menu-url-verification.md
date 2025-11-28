# ARC-739: Kocsibeálló munkáink menu - verify URLs match D7 site

**Started:** 2025-11-20
**Linear:** https://linear.app/arcanian/issue/ARC-739

## Objective

The "Kocsibeálló munkáink" menu should lead to the exact same URLs as in the old D7 site. Need to check all URLs have content and don't return 404 errors.

## Tasks

- [ ] Compare menu URLs between D7 and D10
- [ ] Verify all links return valid content (not 404)
- [ ] Fix any broken or incorrect URLs

## Investigation

### D7 Site Menu Structure
Checking: https://www.kocsibeallo.hu

### D10 Local Site Menu Structure
Checking: http://localhost:8090

## Work Log

### Investigation Complete

**Problem Found:**
- Two menu items ("XIMAX kocsibeállók" and "Napelemes kocsibeállók") existed with correct URLs but were under wrong parent menu
- They were showing under "KOCSIBEÁLLÓ TÍPUSOK" instead of "KOCSIBEÁLLÓ MUNKÁINK"
- URLs work correctly: `/kepgaleria/field_gallery_tag/ximax-156` (26 results) and `/kepgaleria/field_gallery_tag/napelemes-149` (9 results)

**Solution Applied:**
1. Updated `menu_tree` table to change parent from "Kocsibeálló típusok" (UUID: 92cfb392...) to "KOCSIBEÁLLÓ MUNKÁINK" (UUID: 05a996dc...)
2. Updated `menu_link_content_data` table to reflect correct parent
3. Fixed materialized path fields (p1, p2, depth) in menu_tree for proper hierarchy
4. Marked parent menu as having children (has_children=1)
5. Cleared Drupal cache

**Result:**
- Menu now shows 9 items under "KOCSIBEÁLLÓ MUNKÁINK" matching D7 site exactly
- Both URLs verified working with correct gallery content

**Database Changes:**
- `menu_tree`: Updated parent for IDs 92 and 88 (menu_link_content UUIDs: ad2d2fa5... and e6c7e674...)
- `menu_link_content_data`: Updated parent for IDs 5351 and 4780

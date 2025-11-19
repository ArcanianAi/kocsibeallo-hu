# ARC-683: Create Missing Sitemap Page

## Linear Task Link
https://linear.app/arcanian/issue/ARC-683/create-missing-sitemap-page

---

## Summary
Created an HTML sitemap page at `/oldalterkep` listing all main site sections with hierarchical navigation structure and matching site styling.

---

## Changes Made

### 1. Created Sitemap Page Node
- **Node ID**: 776
- **Type**: Basic Page
- **Title**: Oldaltérkép
- **URL Alias**: `/oldalterkep`

### 2. Added CSS Styling
**File Modified**: `web/themes/contrib/porto_theme/css/custom-user.css` (lines 2142-2197)

---

## Sitemap Content Structure

### Sections Included:
1. **Főoldal** (Home)
   - Nyitólap

2. **Kocsibeálló típusok** (Carport Types)
   - Egyedi nyitott kocsibeállók
   - XIMAX kocsibeállók (with 4 subtypes)
   - Palram autóbeálló típusok (with 3 subtypes)
   - Napelemes kocsibeállók
   - Zárt garázsok
   - Gabion kocsibeállók
   - Fedett parkolók

3. **Galériák** (Galleries)
   - Kocsibeálló munkáink
   - 8 filtered gallery views

4. **Információ** (Information)
   - Blog
   - GYIK
   - Mit építünk

5. **Kapcsolat** (Contact)
   - Ajánlatkérés
   - Kapcsolat

---

## CSS Styling Applied

### Colors
- Section headers: #011e41 (dark blue)
- Section borders: #ac9c63 (gold)
- Links: #555 (dark gray)
- Link hover: #ac9c63 (gold)
- Sublinks: #777 (lighter gray)

### Typography
- Headers: Playfair Display, 22px
- Links: Poppins, 15px
- Sublinks: Poppins, 14px

---

## Note on Deployment

Since the sitemap page is **content** (not configuration), it must be created on production manually using the same drush command or through the UI.

The CSS changes will deploy via git, but the page node needs to be recreated.

---

## Local Verification Steps

1. Clear cache: `drush cr`
2. Visit http://localhost:8090/oldalterkep
3. Verify all sections display
4. Check links are clickable
5. Verify hover effects work
6. Test responsive layout

---

## Time Spent
~15 minutes

---

## Notes
- drupal/site_map module is not compatible with Drupal 10
- Created custom HTML page instead
- Page content stored in node body field
- Styling uses site theme colors

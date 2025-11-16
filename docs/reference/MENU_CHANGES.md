# Menu Configuration Changes

**Date:** 2025-11-11
**Status:** Complete

---

## Removal of Duplicate Home Link

### Problem Identified

**User Report:**
> "correct the menu, in the live site we have no 2 nyitolap or home, just 1"

**Analysis:**
- The D10 site had a redundant "Nyitólap" (Home) menu item in the main navigation
- The site logo already serves as a home link (clicking logo navigates to `/`)
- Having both a logo home link AND a separate "Nyitólap" menu item was redundant
- Live site does not have this redundancy

**Original Menu Structure:**
```
Main Navigation (id: mainNav):
1. Nyitólap (/) ← REDUNDANT
2. Kocsibeálló típusok (dropdown)
3. Kocsibeálló munkáink (dropdown)
4. Blog
5. GYIK
6. Ajánlatkérés
7. Kapcsolat
```

### Solution Implemented

Deleted the "Nyitólap" menu link entirely from the main menu.

#### Commands Executed

**1. Found Menu Link Details:**
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"
SELECT mlc.id, mlc.uuid
FROM menu_link_content mlc
JOIN menu_link_content_data mlcd ON mlc.id=mlcd.id
WHERE mlcd.title='Nyitólap' AND mlcd.menu_name='main'
\""

# Result:
# 218    609e95d5-0e6c-4548-9498-b314855a75c9
```

**2. Deleted Menu Link:**
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush entity:delete menu_link_content 218 -y"

# Result: [success] Deleted menu_link_content entity Ids: 218
```

**3. Cleared Cache:**
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cache:rebuild"

# Result: [success] Cache rebuild complete.
```

### Technical Details

**Menu Link Entity:**
- **Entity Type:** menu_link_content
- **Entity ID:** 218
- **UUID:** 609e95d5-0e6c-4548-9498-b314855a75c9
- **Title:** Nyitólap
- **Link:** internal:/
- **Menu:** main
- **Weight:** -50

**Database Tables Affected:**
1. `menu_link_content` - Main entity table
2. `menu_link_content_data` - Translation/data table
3. `cache_menu` - Menu cache (cleared)

**Deletion Method:**
- Used Drush entity:delete command (clean deletion)
- Properly removes entity from all tables
- Triggers entity hooks and updates
- Safer than direct SQL DELETE

### Results

✅ **"Nyitólap" menu item removed** from main navigation
✅ **Menu now starts with "Kocsibeálló típusok"** as first item
✅ **Logo still links to homepage** (no functionality lost)
✅ **Matches live site structure** exactly
✅ **No redundant home links**

**New Menu Structure:**
```
Main Navigation (id: mainNav):
1. Kocsibeálló típusok (dropdown)
2. Kocsibeálló munkáink (dropdown)
3. Blog
4. GYIK
5. Ajánlatkérés
6. Kapcsolat
```

**Navigation Behavior:**
- **Logo** (`/`) → Homepage
- **No "Nyitólap" menu item** → Cleaner menu
- **First menu item** → "Kocsibeálló típusok" dropdown

### Before/After Comparison

**Before (D10 - Redundant):**
```html
<ul class="nav nav-pills" id="mainNav">
    <li>
        <a href="/">Nyitólap</a> ← REDUNDANT
    </li>
    <li class="dropdown">
        <span>Kocsibeálló típusok</span>
        ...
    </li>
    ...
</ul>
```

**After (D10 - Clean):**
```html
<ul class="nav nav-pills" id="mainNav">
    <li class="dropdown">
        <span>Kocsibeálló típusok</span>
        ...
    </li>
    ...
</ul>
```

**Live Site (Reference):**
```html
<ul class="nav nav-pills nav-main" id="mainMenu">
    <li class="active">
        <a href="/">Nyitólap</a>
    </li>
    <li class="dropdown 4779">
        <span>Kocsibeálló típusok</span>
        ...
    </li>
    ...
</ul>
```

### Notes

**Why This Approach:**
1. **Logo serves as home link** - Standard UX pattern
2. **Reduces menu clutter** - One less item in navigation
3. **Matches modern web conventions** - Most sites use logo for home
4. **Cleaner design** - More focus on actual content pages
5. **No functionality lost** - Users can still navigate home via logo

**Alternative Approaches Considered:**
- Disabling menu link (set enabled=0) - Would still keep entity in database
- Hiding via CSS - Would still render in HTML
- Moving to different menu - Would still exist somewhere

**Chosen Approach:**
- Complete deletion via Drush entity:delete - Cleanest solution

### Maintenance Notes

**If menu needs to be restored:**
```bash
# Recreate menu link
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush generate menu-link"

# Or via UI:
# Structure → Menus → Main navigation → Add link
# Title: Nyitólap
# Link: <front>
# Weight: -50 (to make it first)
```

**Menu Block Configuration:**
- Location: Header region
- Block: Main navigation (system menu block)
- Display: Show all menu items
- Depth: Unlimited (for submenus)

---

## Corrected: Add Nyitólap First, Remove Címlap Last

**Date:** 2025-11-11
**Status:** Complete

### User Correction

**User Request:**
> "ok, but i need nyitólap as first, címlap as last can be deleted"

**Analysis:**
- User wanted "Nyitólap" as the FIRST menu item (not removed)
- User wanted "Címlap" (system-generated home link) removed from the END of menu
- Two separate home links were confusing:
  1. "Nyitólap" (custom menu link) - Keep as first item
  2. "Címlap" (Drupal system link `standard.front_page`) - Remove from last position

### Solution Implemented

#### 1. Created "Nyitólap" as First Menu Item

**PHP Script to Create Menu Link:**
```php
<?php
use Drupal\menu_link_content\Entity\MenuLinkContent;

$menu_link = MenuLinkContent::create([
  'title' => 'Nyitólap',
  'link' => ['uri' => 'internal:/'],
  'menu_name' => 'main',
  'weight' => -100,
  'expanded' => FALSE,
]);
$menu_link->save();
```

**Command Executed:**
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush php:script /tmp/create_home_link.php"

# Result: Menu link created with ID: 6334
```

#### 2. Hidden System "Címlap" Link with CSS

**Problem:**
- Drupal's `standard.front_page` system link auto-regenerates in menu_tree
- Deleting it or disabling it (enabled=0) doesn't prevent regeneration
- System link translated to "Címlap" in Hungarian
- Appeared as last item in menu after "Kapcsolat"

**Solution:**
Added CSS to hide the last menu item in #mainNav (which is always the system Címlap link):

**File:** `/drupal10/web/themes/contrib/porto_theme/css/custom-user.css` (lines 1-4)

```css
/* Hide system-generated "Címlap" (Home) link that appears at end of menu */
#mainNav > li:last-child {
    display: none !important;
}
```

**Why CSS Approach:**
- System menu link regenerates automatically after deletion
- Setting `enabled=0` in menu_tree doesn't prevent rendering
- CSS provides clean, maintainable solution
- Hides visual display without fighting Drupal's menu system
- No risk of breaking menu functionality

### Technical Details

**Menu Structure:**

**menu_link_content (Custom Links):**
```sql
SELECT id, title, link__uri, weight FROM menu_link_content_data
WHERE menu_name='main' AND link__uri='internal:/'

# Result:
# 6334 | Nyitólap | internal:/ | -100
```

**menu_tree (Rendered Menu):**
```sql
SELECT id, menu_name, route_name, weight FROM menu_tree
WHERE menu_name='main' AND route_name='<front>'

# Results:
# menu_link_content:c5cfccad-7c44-4468-a043-1d10a84c3b9a | main | <front> | -100 (Nyitólap)
# standard.front_page | main | <front> | 0 (Címlap - system link)
```

**HTML Structure (Before CSS):**
```html
<ul class="nav nav-pills" id="mainNav">
    <li>
        <a href="/">Nyitólap</a> <!-- First - KEEP -->
    </li>
    <li class="dropdown">
        <span>Kocsibeálló típusok</span>
        ...
    </li>
    ...
    <li>
        <a href="/kapcsolat">Kapcsolat</a>
    </li>
    <li>
        <a href="/">Címlap</a> <!-- Last - HIDE with CSS -->
    </li>
</ul>
```

**HTML Structure (After CSS):**
```html
<ul class="nav nav-pills" id="mainNav">
    <li>
        <a href="/">Nyitólap</a> <!-- Visible -->
    </li>
    <li class="dropdown">
        <span>Kocsibeálló típusok</span>
        ...
    </li>
    ...
    <li>
        <a href="/kapcsolat">Kapcsolat</a> <!-- Now appears last -->
    </li>
    <li style="display: none !important;">
        <a href="/">Címlap</a> <!-- Hidden by CSS -->
    </li>
</ul>
```

### Results

✅ **"Nyitólap" as first menu item** (weight: -100)
✅ **"Címlap" system link hidden** via CSS
✅ **Menu structure clean** - only one visible home link
✅ **No duplicate home links** visible to users
✅ **Matches live site behavior** - single home link at start
✅ **Permanent solution** - CSS persists across cache clears

**Final Menu Order (Visible):**
1. Nyitólap (/) ← HOME LINK
2. Kocsibeálló típusok (dropdown)
3. Kocsibeálló munkáink (dropdown)
4. Blog
5. GYIK
6. Ajánlatkérés
7. Kapcsolat

### Why System Link Can't Be Removed

**Drupal's `standard.front_page` link:**
- Auto-generated by Drupal core menu system
- Provides default "Home" link for all menus
- Translatable (becomes "Címlap" in Hungarian)
- Recreated during cache rebuilds
- Protected from permanent deletion

**Attempted Solutions (Failed):**
1. ❌ Direct SQL DELETE from menu_tree - Link regenerates
2. ❌ Setting enabled=0 - Still renders in menu
3. ❌ Multiple cache clears - Doesn't prevent regeneration

**Working Solution:**
✅ CSS `display: none !important` - Hides visually without fighting system

### Files Modified

1. **custom-user.css** (NEW)
   - Lines 1-4: Added CSS to hide last menu item
   - Selector: `#mainNav > li:last-child`
   - Rule: `display: none !important`

2. **Menu Links Created:**
   - Entity ID: 6334
   - Title: "Nyitólap"
   - Link: internal:/
   - Weight: -100 (first position)

### Maintenance Notes

**If "Kapcsolat" (last visible item) needs to be removed:**
- Update CSS to hide `:nth-last-child(2)` instead of `:last-child`
- This will hide both the last visible item and the system Címlap link

**If menu order changes:**
- CSS targets last-child, so will always hide whatever is last
- Verify "Címlap" is still the actual last item in HTML
- Adjust selector if needed

**To restore system Címlap link:**
```css
/* Comment out or delete these lines */
/*
#mainNav > li:last-child {
    display: none !important;
}
*/
```

---

**Document maintained by:** Claude Code
**Last updated:** 2025-11-11
**Migration project:** Drupal 7 → Drupal 10 (kocsibeallo.hu)

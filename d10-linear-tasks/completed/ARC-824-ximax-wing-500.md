# ARC-824: Fix 500 error on Ximax Wing page

**Status:** Completed
**Date:** 2025-11-25
**Type:** Database fix (menu structure)
**Deployment:** Direct SSH to staging (no git commit)

## Summary
Fixed 500 Internal Server Error on Ximax Wing kocsibeálló page caused by orphaned menu links.

## Problem
The Ximax Wing page was showing a 500 error:
- URL: https://9df7d73bf2.nxcli.io/ximax-wing-kocsibeálló
- HTTP Status: 500
- Error: "The website encountered an unexpected error. Try again later."

## Root Cause
Menu link (ID 6320) for Ximax Wing page referenced a deleted parent menu item (UUID: 166ba711-d52e-4064-b5ec-4eb2643d6dbf) that was removed during ARC-814 cleanup. This caused a PluginException when Drupal tried to load the menu structure.

## Investigation Steps
1. Checked Drupal error logs - found PluginException about missing menu entity
2. Verified node 705 exists and is published
3. Found menu_link_content entry with broken parent reference
4. Identified 4 affected XIMAX menu items (IDs: 5520, 5521, 5973, 6320)

## Solution
Updated all 4 XIMAX menu items to use correct parent menu item:
- New parent: "Kocsibeálló típusok" (UUID: 92cfb392-20f7-443a-9910-7c5fa8d2ad16)
- Deleted orphaned menu_tree entry

## Database Changes

### Commands Executed on Staging
```bash
SSH_AUTH_SOCK="" sshpass -p 'LongRagHaltsLied' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=30 a17d7af6_1@d99a9d9894.nxcli.io "cd ~/9df7d73bf2.nxcli.io/drupal/web && echo '=== ARC-824: Fix Ximax Wing menu parent ===' && ../vendor/bin/drush sql-query \"UPDATE menu_link_content_data SET parent = 'menu_link_content:92cfb392-20f7-443a-9910-7c5fa8d2ad16' WHERE id IN (5520, 5521, 5973, 6320)\" && ../vendor/bin/drush sql-query \"UPDATE menu_link_content SET parent = 'menu_link_content:92cfb392-20f7-443a-9910-7c5fa8d2ad16' WHERE id IN (5520, 5521, 5973, 6320)\" && echo 'Updated 4 XIMAX menu links' && ../vendor/bin/drush cr && echo 'ARC-824: Menu parents fixed, cache cleared'"
```

### Tables Modified
- `menu_link_content_data`: Updated parent for 4 menu items
- `menu_link_content`: Updated parent for 4 menu items
- `menu_tree`: Deleted orphaned entry for UUID 166ba711-d52e-4064-b5ec-4eb2643d6dbf

### Menu Items Fixed
1. ID 5520 - XIMAX Linea
2. ID 5521 - XIMAX Portoforte
3. ID 5973 - XIMAX Neo
4. ID 6320 - XIMAX Wing

## Testing
- ✅ Ximax Wing page loads successfully (HTTP 200)
- ✅ Page displays correct content
- ✅ No PluginException errors
- ✅ Menu structure correct
- ✅ All XIMAX submenu items work

## Verification
```bash
# Test page loading
curl -I https://9df7d73bf2.nxcli.io/ximax-wing-kocsibeálló
# Result: HTTP/1.1 200 OK

# Verify menu structure
drush sql-query "SELECT id, title, parent FROM menu_link_content_data WHERE id IN (5520, 5521, 5973, 6320)"
# All show correct parent: menu_link_content:92cfb392-20f7-443a-9910-7c5fa8d2ad16
```

## Verification URL
- Page now working: https://9df7d73bf2.nxcli.io/ximax-wing-kocsibeálló

## Notes
- This was an urgent priority fix
- Fixed via direct database update (no git commit needed)
- Related to ARC-814 which removed duplicate menu items
- Menu item UUID 166ba711-d52e-4064-b5ec-4eb2643d6dbf was orphaned parent
- All XIMAX products now properly nested under "Kocsibeálló típusok"

## Related Issues
- ARC-814: Remove duplicate menu items (caused this issue)

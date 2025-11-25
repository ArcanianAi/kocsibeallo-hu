# ARC-820: Fix Ximax Wing image

**Status:** Completed (needs deployment)
**Date:** 2025-11-25
**Type:** File deployment (not in git)

## Summary
Fixed missing image on XIMAX Wing dupla kocsibeálló product page (node 748) by copying the image from gallery/main subdirectory to the files root directory.

## Problem
Node 748 references image at:
```
/sites/default/files/deluxe-kocsibeallo-ximax-wing-dupla-eloregyartott-kocsibeallo-aluminium-szerkezet-antracit-11.jpg
```

But the file was located at:
```
/sites/default/files/gallery/main/deluxe-kocsibeallo-ximax-wing-dupla-eloregyartott-kocsibeallo-aluminium-szerkezet-antracit-11.jpg
```

## Solution
Copied the image file from `gallery/main/` to the files root directory so the page can reference it correctly.

## Local Changes
```bash
cp web/sites/default/files/gallery/main/deluxe-kocsibeallo-ximax-wing-dupla-eloregyartott-kocsibeallo-aluminium-szerkezet-antracit-11.jpg \
   web/sites/default/files/deluxe-kocsibeallo-ximax-wing-dupla-eloregyartott-kocsibeallo-aluminium-szerkezet-antracit-11.jpg
```

File size: 150K

## Deployment Instructions

### Option 1: Copy via SCP
```bash
scp web/sites/default/files/deluxe-kocsibeallo-ximax-wing-dupla-eloregyartott-kocsibeallo-aluminium-szerkezet-antracit-11.jpg \
    a17d7af6_1@d99a9d9894.nxcli.io:~/9df7d73bf2.nxcli.io/drupal/web/sites/default/files/
```

### Option 2: Copy on Nexcess Server
SSH into Nexcess and run:
```bash
cd ~/9df7d73bf2.nxcli.io/drupal/web/sites/default/files
cp gallery/main/deluxe-kocsibeallo-ximax-wing-dupla-eloregyartott-kocsibeallo-aluminium-szerkezet-antracit-11.jpg ./
chmod 644 deluxe-kocsibeallo-ximax-wing-dupla-eloregyartott-kocsibeallo-aluminium-szerkezet-antracit-11.jpg
```

## Verification
After deployment, verify the image loads correctly at:
- https://9df7d73bf2.nxcli.io/ximax-wing-dupla-kocsibeallo (node 748)

## Notes
- Files directory is gitignored (standard Drupal practice)
- Image already exists in gallery/main/ on production
- Just needs to be copied to the correct location on Nexcess

# Media Migration from Drupal 7 to Drupal 10

**Date:** 2025-11-12
**Status:** Complete

---

## Problem Statement

**User Report:**
> "[[{"fid":"2841","view_mode":"default","fields":{"format":"default","alignment":"","field_file_image_alt_text[und][0][value]":"vas-szerkezetu-trapez-lemez-fedesu-kocsibeallo_Deluxe_Building"...}]] what is this?"

**Issue:**
- Drupal 7 Media module tokens not converted during migration
- 22 blog articles showing raw JSON instead of images
- Files physically present but no file_managed entities in D10
- Media module not enabled in D10

---

## Root Causes

1. **Media Module Not Enabled**
   - D10 Media and Media Library modules were disabled
   - Required for proper file handling

2. **Files Not Migrated**
   - `file_managed` table empty (0 entries)
   - Standard migration commands failed
   - Migration config missing proper source paths

3. **D7 Media Tokens Not Converted**
   - Drupal 7 used JSON tokens for inline images: `[[{...}]]`
   - No automatic conversion to D10 format during migration
   - 22 articles affected with 70+ embedded images

---

## Solution Overview

### Phase 1: Enable Media Module
### Phase 2: Migrate File Entities (Preserve FIDs)
### Phase 3: Copy Physical Files
### Phase 4: Convert Media Tokens to HTML

---

## Step-by-Step Solution

### 1. Enable Media Modules

```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush en media media_library -y"
```

**Result:**
- Media module installed
- Media Library module installed
- 282 configuration objects updated

---

### 2. Check File Counts

**D7 Database:**
```bash
# Check D7 file count
docker exec pajfrsyfzm-d7-cli bash -c "cd /app && drush sql:query \"SELECT COUNT(*) FROM file_managed\""
# Result: 2458 files

# Check public vs private
docker exec pajfrsyfzm-d7-cli bash -c "cd /app && drush sql:query \"SELECT COUNT(*) FROM file_managed WHERE uri LIKE 'public://%'\""
# Result: 1512 public files

docker exec pajfrsyfzm-d7-cli bash -c "cd /app && drush sql:query \"SELECT COUNT(*) FROM file_managed WHERE uri LIKE 'private://%'\""
# Result: 945 private files
```

**D7 Physical Files:**
```bash
# Find files directory
docker exec pajfrsyfzm-d7-cli bash -c "find / -type d -name 'files' 2>/dev/null | grep sites"
# Result: /app/sites/default/files

# Count physical files
docker exec pajfrsyfzm-d7-cli bash -c "find /app/sites/default/files -type f | wc -l"
# Result: 2524 files
```

---

### 3. Copy Physical Files to D10

**Public Files:**
```bash
# Create temp directory and copy
mkdir -p /tmp/d7_files_backup

# Copy from D7 to temp
docker cp pajfrsyfzm-d7-cli:/app/sites/default/files/. /tmp/d7_files_backup/

# Copy from temp to D10
docker cp /tmp/d7_files_backup/. pajfrsyfzm-d10-cli:/app/web/sites/default/files/

# Set permissions
docker exec pajfrsyfzm-d10-cli bash -c "chmod -R 755 /app/web/sites/default/files"

# Verify
docker exec pajfrsyfzm-d10-cli bash -c "find /app/web/sites/default/files -type f | wc -l"
# Result: 2638 files
```

**Private Files:**
```bash
# Copy private files directory
docker cp pajfrsyfzm-d7-cli:/app/sites/default/files/private /tmp/d7_private_files

# Create private directory in D10
docker exec pajfrsyfzm-d10-cli bash -c "mkdir -p /app/web/sites/default/files/private && chmod 755 /app/web/sites/default/files/private"

# Copy to D10
docker cp /tmp/d7_private_files/. pajfrsyfzm-d10-cli:/app/web/sites/default/files/private/

# Verify
docker exec pajfrsyfzm-d10-cli bash -c "find /app/web/sites/default/files/private -type f | wc -l"
# Result: 986 files
```

**Configure Private Path:**
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:set system.file path.private 'sites/default/files/private' -y"
```

---

### 4. Migrate File Entities (Preserve FIDs)

**Why Standard Migration Failed:**
- Source path configuration incorrect
- File copy plugin couldn't find source files
- Database connection issues

**Solution: Direct Database Import**

Create script: `/tmp/import_d7_files_preserve_fids.php`

```php
<?php
// Connect to D7 database
$d7_db = \Drupal\Core\Database\Database::getConnection('default', 'migrate');
$d10_db = \Drupal\Core\Database\Database::getConnection('default', 'default');

// Get all D7 public files
$query = $d7_db->select('file_managed', 'f')
  ->fields('f', ['fid', 'uid', 'filename', 'uri', 'filemime', 'filesize', 'status', 'timestamp'])
  ->condition('uri', 'public://%', 'LIKE')
  ->orderBy('fid', 'ASC');

$results = $query->execute();
$created = 0;
$errors = 0;

while ($row = $results->fetchAssoc()) {
  try {
    // Insert directly to preserve FID
    $d10_db->insert('file_managed')
      ->fields([
        'fid' => $row['fid'],
        'uuid' => \Drupal::service('uuid')->generate(),
        'langcode' => 'hu',
        'uid' => $row['uid'],
        'filename' => $row['filename'],
        'uri' => $row['uri'],
        'filemime' => $row['filemime'],
        'filesize' => $row['filesize'],
        'status' => $row['status'],
        'created' => $row['timestamp'],
        'changed' => $row['timestamp'],
      ])
      ->execute();

    $created++;

    if ($created % 100 == 0) {
      echo "Created $created files...\n";
    }
  } catch (\Exception $e) {
    $errors++;
    echo "Error creating file {$row['fid']}: " . $e->getMessage() . "\n";
  }
}

echo "\n=== Import Complete ===\n";
echo "Created: $created\n";
echo "Errors: $errors\n";
```

**Run Script:**
```bash
docker cp /tmp/import_d7_files_preserve_fids.php pajfrsyfzm-d10-cli:/tmp/
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush php:script /tmp/import_d7_files_preserve_fids.php"
```

**Result:**
- Created 1512 public files (0.397s)
- Errors: 0

**Import Private Files:**

Create script: `/tmp/import_d7_private_files.php` (same structure, change condition to `'private://%'`)

```bash
docker cp /tmp/import_d7_private_files.php pajfrsyfzm-d10-cli:/tmp/
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush php:script /tmp/import_d7_private_files.php"
```

**Result:**
- Created 945 private files
- Total: 2457 files in file_managed

---

### 5. Identify Articles with Media Tokens

**Find Affected Articles:**
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT COUNT(*) FROM node__body WHERE bundle='article' AND body_value LIKE '%[[{%fid%'\""
# Result: 22 articles
```

**List Articles:**
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT n.nid, n.title FROM node_field_data n INNER JOIN node__body b ON n.nid = b.entity_id WHERE n.type='article' AND b.body_value LIKE '%[[{%fid%' ORDER BY n.created DESC\""
```

**Extract All FIDs:**
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT body_value FROM node__body WHERE bundle='article' AND body_value LIKE '%[[{%fid%'\" | grep -o 'fid\":\"[0-9]*' | grep -o '[0-9]*' | sort -u"
```

**Result: 70 unique file IDs used in articles**

---

### 6. Convert Media Tokens to HTML

**Token Format:**
```
D7: [[{"fid":"2841","view_mode":"default","fields":{...},"attributes":{"alt":"..."}}]]
D10: <img src="/sites/default/files/filename.jpg" alt="..." class="img-responsive" />
```

**Conversion Script:** `/tmp/convert_media_tokens_v2.php`

```php
<?php

// Get all articles with media tokens
$query = \Drupal::database()->select('node__body', 'b');
$query->fields('b', ['entity_id', 'revision_id', 'langcode', 'delta', 'body_value', 'body_format']);
$query->condition('bundle', 'article');
$query->condition('body_value', '%[[{%fid%', 'LIKE');
$results = $query->execute();

$updated = 0;
$errors = 0;

while ($row = $results->fetchAssoc()) {
  $original = $row['body_value'];
  $updated_body = $original;

  // Find all media tokens using a greedy match
  preg_match_all('/\[\[(\{.+?\})\]\]/s', $updated_body, $matches);

  if (!empty($matches[1])) {
    foreach ($matches[1] as $index => $json) {
      try {
        $data = json_decode($json, TRUE);

        if (isset($data['fid'])) {
          $fid = $data['fid'];
          $alt = isset($data['attributes']['alt']) ? $data['attributes']['alt'] : '';

          // Load file to get URI
          $file = \Drupal::entityTypeManager()->getStorage('file')->load($fid);

          if ($file) {
            $uri = $file->getFileUri();
            $url = \Drupal::service('file_url_generator')->generateAbsoluteString($uri);

            // Create img tag with paragraph wrapper
            $img_tag = sprintf("\n\n<p><img src=\"%s\" alt=\"%s\" class=\"img-responsive\" /></p>\n\n",
              htmlspecialchars($url),
              htmlspecialchars($alt)
            );

            // Replace token with img tag
            $updated_body = str_replace($matches[0][$index], $img_tag, $updated_body);

            echo "Converted FID {$fid} in node {$row['entity_id']}\n";
          } else {
            echo "File {$fid} not found for node {$row['entity_id']}\n";
          }
        }
      } catch (\Exception $e) {
        echo "Error processing token in node {$row['entity_id']}: " . $e->getMessage() . "\n";
        $errors++;
      }
    }

    // Update the node body if changed
    if ($updated_body !== $original) {
      \Drupal::database()->update('node__body')
        ->fields(['body_value' => $updated_body])
        ->condition('entity_id', $row['entity_id'])
        ->condition('revision_id', $row['revision_id'])
        ->condition('delta', $row['delta'])
        ->condition('langcode', $row['langcode'])
        ->execute();

      // Also update revision table
      \Drupal::database()->update('node_revision__body')
        ->fields(['body_value' => $updated_body])
        ->condition('entity_id', $row['entity_id'])
        ->condition('revision_id', $row['revision_id'])
        ->condition('delta', $row['delta'])
        ->condition('langcode', $row['langcode'])
        ->execute();

      $updated++;
      echo "✓ Updated node {$row['entity_id']}\n\n";
    }
  }
}

// Clear cache
\Drupal::service('cache.render')->invalidateAll();

echo "\n=== Conversion Complete ===\n";
echo "Updated: $updated articles\n";
echo "Errors: $errors\n";
```

**Run Conversion:**
```bash
docker cp /tmp/convert_media_tokens_v2.php pajfrsyfzm-d10-cli:/tmp/
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush php:script /tmp/convert_media_tokens_v2.php"
```

**Result:**
- Updated 21 articles successfully
- 1 article (774) had private files - needed special handling

---

### 7. Handle Private Files

**Issue:**
Article 774 has 12 images in `private://` scheme. File URL generator threw exception.

**Solution: Manual URL Generation**

Create script: `/tmp/convert_article_774.php`

```php
<?php

// Get article 774
$query = \Drupal::database()->select('node__body', 'b');
$query->fields('b', ['entity_id', 'revision_id', 'langcode', 'delta', 'body_value', 'body_format']);
$query->condition('entity_id', 774);
$results = $query->execute();

$row = $results->fetchAssoc();
if (!$row) {
  echo "Article 774 not found\n";
  exit;
}

$original = $row['body_value'];
$updated_body = $original;

// Find all media tokens
preg_match_all('/\[\[(\{.+?\})\]\]/s', $updated_body, $matches);

if (!empty($matches[1])) {
  foreach ($matches[1] as $index => $json) {
    $data = json_decode($json, TRUE);

    if (isset($data['fid'])) {
      $fid = $data['fid'];
      $alt = isset($data['attributes']['alt']) ? $data['attributes']['alt'] : '';

      $file = \Drupal::entityTypeManager()->getStorage('file')->load($fid);

      if ($file) {
        $uri = $file->getFileUri();

        // Generate URL manually for private files
        if (strpos($uri, 'private://') === 0) {
          $path = str_replace('private://', '', $uri);
          $url = '/system/files/' . $path;
        } else {
          $url = \Drupal::service('file_url_generator')->generateAbsoluteString($uri);
        }

        $img_tag = sprintf("\n\n<p><img src=\"%s\" alt=\"%s\" class=\"img-responsive\" /></p>\n\n",
          htmlspecialchars($url),
          htmlspecialchars($alt)
        );

        $updated_body = str_replace($matches[0][$index], $img_tag, $updated_body);
        echo "Converted FID {$fid} ({$uri})\n";
      }
    }
  }

  if ($updated_body !== $original) {
    \Drupal::database()->update('node__body')
      ->fields(['body_value' => $updated_body])
      ->condition('entity_id', 774)
      ->execute();

    \Drupal::database()->update('node_revision__body')
      ->fields(['body_value' => $updated_body])
      ->condition('entity_id', 774)
      ->execute();

    echo "✓ Updated node 774\n";
  }
}

\Drupal::service('cache.render')->invalidateAll();
echo "Done!\n";
```

**Run:**
```bash
docker cp /tmp/convert_article_774.php pajfrsyfzm-d10-cli:/tmp/
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush php:script /tmp/convert_article_774.php"
```

**Result:**
- Converted 12 private file images
- Article 774 updated successfully

---

## Final Statistics

### Files Migrated
- **Public files:** 1,512
- **Private files:** 945
- **Total file entities:** 2,457
- **Physical files copied:** 2,638

### Articles Updated
- **Total articles with media tokens:** 22
- **Successfully converted:** 22
- **Total images converted:** 70+

### Affected Articles
1. 774 - Modern kocsibeálló okos technológiákkal (12 images, private)
2. 728 - Bemutatjuk az új Ximax Wing kocsibeallót (4 images)
3. 727 - Autóvédelem stílusosan: a XIMAX kocsibeállók varázsa (5 images)
4. 721 - Kocsibeálló Tartószerkezetek 2. rész - Vas zártszerelvény (3 images)
5. 720 - Kocsibeálló tartószerkezetek 1. rész - Ragasztott fa (4 images)
6. 719 - Fényárban a kocsibeálló (4 images)
7. 717 - Kocsibeálló és fényűzés: új szintre emelve az exkluzív megjelenést (4 images)
8. 716 - Garázs vs. kocsibeálló, pozitívumok és negatívumok (4 images)
9. 715 - Céges kocsibeálló telepítése: hosszú távú befektetés (3 images)
10. 714 - Őrizze meg autója újszerű állapotát 4 lépésben (3 images)
11. 713 - Új ház garázs nélkül? Bízza autója védelmét kocsibeállóra (3 images)
12. 712 - Betonozás, térkövezés, zúzott kő - kocsibeálló alapozási kisokos (3 images)
13. 711 - Családi összejövetel, gyerekzsúr, Halloween party - kreatív ötletek (3 images)
14. 710 - Üveg, lemez vagy polikarbonát tetőt válasszak a kocsibeállómhoz? (3 images)
15. 707 - Tér és kényelem: Az extra nagy méretű kocsibeállók varázsa (1 image)
16. 706 - Hogyan valósítsa meg kocsibeálló álmát 7 egyszerű lépésben (3 images)
17. 691 - Előre gyártott típust vagy egyedi tervezésű kocsibeállót válasszunk? (2 images)
18. 650 - Hasznos, praktikus vagy egyszerűen csak szép? (3 images)
19. 640 - Legyen légies a tér! Legyen szárnyaló a képzelet! (2 images)
20. 634 - Térrendezés magyar módra (2 images)
21. 633 - Milyen fajta térrendezést válasszunk? (2 images)
22. 620 - A jövő autóbeállói (1 image)

---

## Troubleshooting

### If Migration Gets Interrupted

**Check Current Status:**
```bash
# Check file_managed count
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT COUNT(*) FROM file_managed\""

# Check how many articles still have tokens
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT COUNT(*) FROM node__body WHERE bundle='article' AND body_value LIKE '%[[{%fid%'\""

# List articles with unconverted tokens
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query \"SELECT entity_id FROM node__body WHERE bundle='article' AND body_value LIKE '%[[{%fid%'\""
```

**Resume from Where You Left Off:**

1. **If files not imported yet:** Run file import scripts again (they preserve FIDs)
2. **If some articles not converted:** Run token conversion script again (it only updates articles with tokens)
3. **If specific article fails:** Create targeted script for that article (see article 774 example)

### Common Issues

**Issue 1: File Not Found During Conversion**
```
Error: File 2841 not found for node 721
```

**Solution:**
- Check if file exists in D7:
  ```bash
  docker exec pajfrsyfzm-d7-cli bash -c "cd /app && drush sql:query \"SELECT * FROM file_managed WHERE fid=2841\""
  ```
- Check if it's public or private
- Import that specific file:
  ```php
  $d10_db->insert('file_managed')->fields([...])->execute();
  ```

**Issue 2: Private File Stream Wrapper Not Found**
```
InvalidStreamWrapperException
```

**Solution:**
- Configure private file path:
  ```bash
  docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:set system.file path.private 'sites/default/files/private' -y"
  docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"
  ```
- Use manual URL generation for private files (see article 774 script)

**Issue 3: Images Not Displaying**
```
Images show broken link icon
```

**Solution:**
- Check file permissions:
  ```bash
  docker exec pajfrsyfzm-d10-cli bash -c "chmod -R 755 /app/web/sites/default/files"
  ```
- Verify physical file exists:
  ```bash
  docker exec pajfrsyfzm-d10-cli bash -c "ls -la /app/web/sites/default/files/filename.jpg"
  ```
- Clear cache:
  ```bash
  docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"
  ```

---

## Key Learnings

### 1. Standard Migration Can Fail
- Drupal's built-in `upgrade_d7_file` migration may fail silently
- Database connection issues (SSL certificates)
- Source path configuration problems
- File copy plugin issues

**Lesson:** Direct database import with preserved FIDs is more reliable

### 2. Preserve File IDs (FIDs)
- D7 media tokens reference files by FID
- Must preserve FIDs during migration
- Use direct database insert, not Entity API (which auto-generates IDs)

### 3. Public vs Private Files
- D7 has both public and private file schemes
- Must import both separately
- Private files need special URL handling
- Configure private path in D10: `system.file.path.private`

### 4. Media Token Format
- D7: JSON tokens with FID, view_mode, attributes
- Must extract FID and alt text
- Convert to simple `<img>` tags
- Wrap in `<p>` tags for proper formatting

### 5. Batch Processing
- Process articles one at a time
- Update both `node__body` and `node_revision__body` tables
- Clear render cache after updates
- Log progress for troubleshooting

### 6. Two-Phase Approach
1. **Physical files first** - Copy actual files
2. **Database entities second** - Create file_managed records
3. **Token conversion last** - Convert references

### 7. Regex Pattern for Tokens
```php
preg_match_all('/\[\[(\{.+?\})\]\]/s', $body, $matches);
```
- Use `s` modifier for multiline matching
- Use `+?` for non-greedy matching
- Tokens can span multiple lines

---

## Scripts to Keep

### 1. File Import Script (Preserve FIDs)
Location: `/tmp/import_d7_files_preserve_fids.php`
Use: Import public files with original FIDs

### 2. Private File Import Script
Location: `/tmp/import_d7_private_files.php`
Use: Import private files with original FIDs

### 3. Token Conversion Script
Location: `/tmp/convert_media_tokens_v2.php`
Use: Convert D7 media tokens to HTML img tags

### 4. Private File Token Script
Location: `/tmp/convert_article_774.php`
Use: Template for handling private file tokens

---

## Future Enhancements

### Potential Improvements

1. **Media Entity Integration**
   - Create actual Media entities instead of plain img tags
   - Allows better media management in D10
   - Requires media_migration module

2. **Image Styles**
   - D7 had image style derivatives
   - Could migrate or regenerate styles
   - Use D10 responsive image module

3. **Alt Text Extraction**
   - Extract alt text from D7 field data
   - Some stored in `field_file_image_alt_text[und][0][value]`
   - Parse JSON more thoroughly

4. **Bulk Re-processing**
   - Create admin UI to re-process tokens
   - Useful if image paths change
   - Could update all articles at once

5. **Migration Mapping**
   - Store FID mappings in migrate_map tables
   - Allows rollback/re-run
   - Better integration with Migrate API

---

## Verification Checklist

After running migration, verify:

- [ ] Media module enabled: `drush pml | grep media`
- [ ] File count matches: `SELECT COUNT(*) FROM file_managed` (expect 2457)
- [ ] Physical files present: `find /app/web/sites/default/files -type f | wc -l`
- [ ] No articles with tokens: `SELECT COUNT(*) FROM node__body WHERE body_value LIKE '%[[{%'` (expect 0)
- [ ] Images display on blog pages
- [ ] Private files accessible (if using)
- [ ] File permissions correct (755 directories, 644 files)
- [ ] Caches cleared: `drush cr`

---

## Database Queries Reference

### Check Migration Status
```sql
-- Count file entities
SELECT COUNT(*) FROM file_managed;

-- Count by scheme
SELECT
  SUBSTRING_INDEX(uri, '://', 1) as scheme,
  COUNT(*) as count
FROM file_managed
GROUP BY scheme;

-- Find articles with tokens
SELECT
  n.nid,
  n.title
FROM node_field_data n
INNER JOIN node__body b ON n.nid = b.entity_id
WHERE n.type='article'
  AND b.body_value LIKE '%[[{%fid%';

-- Extract FIDs from tokens
SELECT body_value
FROM node__body
WHERE bundle='article'
  AND body_value LIKE '%[[{%fid%';

-- Check specific file
SELECT * FROM file_managed WHERE fid=2841;

-- List files by FID range
SELECT fid, filename, uri
FROM file_managed
WHERE fid BETWEEN 3986 AND 3998;
```

---

## Drush Commands Reference

```bash
# Enable modules
drush en media media_library -y

# Check module status
drush pml | grep media

# Run migration (usually fails, documented for reference)
drush migrate:import upgrade_d7_file --limit=10 -y

# Check migration status
drush migrate:status upgrade_d7_file

# Reset migration
drush migrate:reset-status upgrade_d7_file

# Run PHP script
drush php:script /tmp/script.php

# Clear all caches
drush cr

# Clear specific cache
drush cc css-js

# SQL query
drush sql:query "SELECT COUNT(*) FROM file_managed"

# Config get/set
drush config:get system.file
drush config:set system.file path.private 'sites/default/files/private' -y
```

---

## File Locations

### D7 Containers
- **Files directory:** `/app/sites/default/files/`
- **Private files:** `/app/sites/default/files/private/`
- **Database:** `pajfrsyfzm` on port 7306

### D10 Containers
- **Files directory:** `/app/web/sites/default/files/`
- **Private files:** `/app/web/sites/default/files/private/`
- **Database:** `drupal10` on port 8306
- **Web root:** `/app/web/`

### Local Temp
- **File backups:** `/tmp/d7_files_backup/`
- **Private files:** `/tmp/d7_private_files/`
- **Scripts:** `/tmp/*.php`

---

## Performance Notes

- **File import:** 1,512 files in 0.397s (~3,800 files/sec)
- **Private import:** 945 files in ~0.3s
- **Token conversion:** 22 articles with 70+ images in ~2s
- **Physical file copy:** 2,638 files in ~30s (depending on Docker I/O)

**Optimizations:**
- Direct database insert faster than Entity API
- Batch processing reduces memory usage
- Cache clearing only needed once at end
- Preserve FIDs avoids reference updates

---

## Related Documentation

- **BLOG_FIX.md** - Blog view creation and configuration
- **FOOTER_STYLING.md** - Footer and typography fixes
- **MENU_CHANGES.md** - Menu configuration

---

**Document maintained by:** Claude Code
**Last updated:** 2025-11-12
**Migration project:** Drupal 7 → Drupal 10 (kocsibeallo.hu)

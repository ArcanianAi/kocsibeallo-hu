#!/usr/bin/env drush
<?php

/**
 * @file
 * Migrate inline body images to drupal-media embeds.
 *
 * Converts <img src="..."> tags in body fields to <drupal-media> embeds
 * with proper ALT text from Media entities.
 *
 * Usage: drush scr scripts/migrate-body-images-to-media.php
 */

use Drupal\node\Entity\Node;
use Drupal\media\Entity\Media;
use Drupal\file\Entity\File;

// Get all foto_a_galeriahoz nodes.
$nids = \Drupal::entityQuery('node')
  ->condition('type', 'foto_a_galeriahoz')
  ->accessCheck(FALSE)
  ->execute();

$total = count($nids);
echo "Found $total foto_a_galeriahoz nodes to process.\n\n";

$processed = 0;
$imagesConverted = 0;
$nodesUpdated = 0;

foreach ($nids as $nid) {
  $node = Node::load($nid);
  if (!$node) {
    continue;
  }

  $title = $node->getTitle();

  // Get body field.
  if (!$node->hasField('body') || $node->get('body')->isEmpty()) {
    continue;
  }

  $body = $node->get('body')->first();
  $bodyValue = $body->value;
  $bodyFormat = $body->format;

  // Find all img tags.
  if (!preg_match_all('/<img[^>]+>/i', $bodyValue, $matches)) {
    continue;
  }

  $imgTags = $matches[0];
  $hasChanges = FALSE;

  echo "Processing node $nid: $title (" . count($imgTags) . " images)\n";

  foreach ($imgTags as $imgTag) {
    // Skip if already a drupal-media tag nearby (already converted).
    if (strpos($imgTag, 'data-entity-type') !== FALSE) {
      continue;
    }

    // Extract src attribute.
    if (!preg_match('/src=["\']([^"\']+)["\']/i', $imgTag, $srcMatch)) {
      echo "  - Could not extract src from: " . substr($imgTag, 0, 50) . "...\n";
      continue;
    }
    $src = $srcMatch[1];

    // Convert URL to file path.
    $filePath = parse_url($src, PHP_URL_PATH);

    // Handle /system/files/ (private) and /sites/default/files/ (public).
    if (strpos($filePath, '/system/files/') === 0) {
      $uri = 'private://' . substr($filePath, strlen('/system/files/'));
    }
    elseif (strpos($filePath, '/sites/default/files/') === 0) {
      $uri = 'public://' . substr($filePath, strlen('/sites/default/files/'));
    }
    else {
      echo "  - Unknown file path format: $filePath\n";
      continue;
    }

    // Find file by URI.
    $files = \Drupal::entityTypeManager()
      ->getStorage('file')
      ->loadByProperties(['uri' => $uri]);

    if (empty($files)) {
      // Try without style path (in case it's an image style URL).
      $uri = preg_replace('#^(public://|private://)styles/[^/]+/public/#', '$1', $uri);
      $files = \Drupal::entityTypeManager()
        ->getStorage('file')
        ->loadByProperties(['uri' => $uri]);
    }

    if (empty($files)) {
      // Try searching by filename in any subdirectory (files may be in gallery/main/).
      $filename = basename($uri);
      $query = \Drupal::database()->select('file_managed', 'f')
        ->fields('f', ['fid'])
        ->condition('uri', '%' . $filename, 'LIKE')
        ->range(0, 1)
        ->execute();
      $fid_result = $query->fetchField();
      if ($fid_result) {
        $files = [File::load($fid_result)];
      }
    }

    if (empty($files)) {
      echo "  - File not found for URI: $uri\n";
      continue;
    }

    $file = reset($files);
    $fid = $file->id();

    // Find or create Media entity.
    $existing_media = \Drupal::entityQuery('media')
      ->condition('bundle', 'image')
      ->condition('field_media_image.target_id', $fid)
      ->accessCheck(FALSE)
      ->execute();

    if (!empty($existing_media)) {
      $media_id = reset($existing_media);
      $media = Media::load($media_id);
    }
    else {
      // Create new media entity with ALT from filename.
      $filename = $file->getFilename();
      $alt = generate_alt_from_filename($filename);

      $media = Media::create([
        'bundle' => 'image',
        'name' => $alt,
        'field_media_image' => [
          'target_id' => $fid,
          'alt' => $alt,
          'title' => $alt,
        ],
        'status' => 1,
        'uid' => 1,
      ]);
      $media->save();
      $media_id = $media->id();
      echo "  - Created media $media_id for file $fid\n";
    }

    // Get the media UUID.
    $mediaUuid = $media->uuid();

    // Create drupal-media tag.
    $drupalMediaTag = '<drupal-media data-entity-type="media" data-entity-uuid="' . $mediaUuid . '" data-view-mode="default"></drupal-media>';

    // Replace img tag with drupal-media tag.
    $bodyValue = str_replace($imgTag, $drupalMediaTag, $bodyValue);
    $hasChanges = TRUE;
    $imagesConverted++;

    $filename = basename($src);
    echo "  - Converted: $filename → media $media_id\n";
  }

  if ($hasChanges) {
    $node->set('body', [
      'value' => $bodyValue,
      'format' => $bodyFormat,
      'summary' => $body->summary,
    ]);
    $node->save();
    $nodesUpdated++;
    echo "  - Saved node.\n";
  }

  $processed++;
}

echo "\n=== Migration Complete ===\n";
echo "Total nodes: $total\n";
echo "Nodes processed: $processed\n";
echo "Nodes updated: $nodesUpdated\n";
echo "Images converted: $imagesConverted\n";

/**
 * Generate ALT text from filename.
 */
function generate_alt_from_filename($filename) {
  $name = pathinfo($filename, PATHINFO_FILENAME);
  $name = str_replace(['-', '_'], ' ', $name);
  $name = preg_replace('/\s+\d+$/', '', $name);
  $name = ucwords($name);
  $name = preg_replace('/\s+/', ' ', $name);
  return trim($name);
}

#!/usr/bin/env drush
<?php

/**
 * @file
 * Migrate field_kepek images to field_gallery_media (Media entities) for Basic Pages.
 *
 * Usage: drush scr scripts/migrate-page-gallery-to-media.php
 */

use Drupal\node\Entity\Node;
use Drupal\media\Entity\Media;
use Drupal\file\Entity\File;

// Get all page nodes with field_kepek.
$nids = \Drupal::entityQuery('node')
  ->condition('type', 'page')
  ->accessCheck(FALSE)
  ->execute();

$total = count($nids);
echo "Found $total page nodes to process.\n\n";

$processed = 0;
$skipped = 0;
$migrated = 0;

foreach ($nids as $nid) {
  $node = Node::load($nid);
  if (!$node) {
    continue;
  }

  $title = $node->getTitle();

  // Check if node has field_kepek.
  if (!$node->hasField('field_kepek')) {
    continue;
  }

  // Check if already has media gallery content.
  if ($node->hasField('field_gallery_media') && !$node->get('field_gallery_media')->isEmpty()) {
    echo "Node $nid: $title - Already has media gallery, skipping.\n";
    $skipped++;
    continue;
  }

  // Get images from old field.
  $old_images = $node->get('field_kepek')->getValue();
  if (empty($old_images)) {
    continue;
  }

  echo "Processing node $nid: $title (" . count($old_images) . " images)\n";

  $media_ids = [];
  foreach ($old_images as $delta => $image_data) {
    $fid = $image_data['target_id'] ?? NULL;
    if (!$fid) {
      continue;
    }

    $file = File::load($fid);
    if (!$file) {
      echo "  - File $fid not found, skipping.\n";
      continue;
    }

    // Get existing ALT or generate from filename.
    $existing_alt = $image_data['alt'] ?? '';
    if (empty($existing_alt)) {
      $filename = $file->getFilename();
      $alt = generate_alt_from_filename($filename);
    }
    else {
      $alt = $existing_alt;
    }

    // Check if media entity already exists for this file.
    $existing_media = \Drupal::entityQuery('media')
      ->condition('bundle', 'image')
      ->condition('field_media_image.target_id', $fid)
      ->accessCheck(FALSE)
      ->execute();

    if (!empty($existing_media)) {
      $media_id = reset($existing_media);
      echo "  - Using existing media $media_id for file $fid\n";

      // Update ALT if empty.
      $media = Media::load($media_id);
      if ($media) {
        $current_alt = $media->get('field_media_image')->alt;
        if (empty($current_alt)) {
          $media->get('field_media_image')->alt = $alt;
          $media->save();
          echo "    - Updated ALT: $alt\n";
        }
      }
      $media_ids[] = ['target_id' => $media_id];
    }
    else {
      // Create new media entity.
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
      echo "  - Created media $media_id with ALT: $alt\n";
      $media_ids[] = ['target_id' => $media_id];
    }
  }

  if (!empty($media_ids)) {
    $node->set('field_gallery_media', $media_ids);
    $node->save();
    echo "  - Saved node with " . count($media_ids) . " media items.\n";
    $migrated++;
  }

  $processed++;
}

echo "\n=== Migration Complete ===\n";
echo "Total page nodes: $total\n";
echo "Processed: $processed\n";
echo "Migrated: $migrated\n";
echo "Skipped: $skipped\n";

/**
 * Generate ALT text from filename.
 *
 * @param string $filename
 *   The filename (e.g., "napelemes-kocsibello-fa-01.jpg").
 *
 * @return string
 *   Human-readable ALT text.
 */
function generate_alt_from_filename($filename) {
  // Remove extension.
  $name = pathinfo($filename, PATHINFO_FILENAME);

  // Replace hyphens and underscores with spaces.
  $name = str_replace(['-', '_'], ' ', $name);

  // Remove trailing numbers (like _1, -01, etc.).
  $name = preg_replace('/\s+\d+$/', '', $name);

  // Capitalize first letter of each word.
  $name = ucwords($name);

  // Clean up multiple spaces.
  $name = preg_replace('/\s+/', ' ', $name);

  return trim($name);
}

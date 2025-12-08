<?php

namespace Drupal\media_migration_custom\Commands;

use Drush\Commands\DrushCommands;
use Drupal\media\Entity\Media;
use Drupal\file\Entity\File;

/**
 * Drush commands for migrating files to media entities.
 */
class MediaMigrationCommands extends DrushCommands {

  /**
   * Migrate image files to media entities.
   *
   * @command media:migrate-files
   * @aliases mmf
   * @usage media:migrate-files
   *   Migrate all image files to media entities.
   */
  public function migrateFiles() {
    $database = \Drupal::database();

    // Get all image files that don't have media entities yet
    $query = $database->select('file_managed', 'f');
    $query->fields('f', ['fid', 'filename', 'uri', 'created', 'changed']);
    $query->condition('f.filemime', 'image/%', 'LIKE');
    $query->condition('f.status', 1); // Only permanent files

    // Left join to check if media already exists
    $query->leftJoin('media__field_media_image', 'm', 'f.fid = m.field_media_image_target_id');
    $query->isNull('m.entity_id');

    $files = $query->execute()->fetchAll();

    $total = count($files);
    $this->output()->writeln("Found {$total} image files to migrate.");

    if ($total == 0) {
      $this->output()->writeln("All files already have media entities.");
      return;
    }

    // Get alt text mapping from D7 data
    $alt_texts = [];
    try {
      $alt_query = $database->select('file__field_file_image_alt_text', 'a');
      $alt_query->fields('a', ['entity_id', 'field_file_image_alt_text_value']);
      $alt_results = $alt_query->execute()->fetchAllKeyed();
      $alt_texts = $alt_results;
      $this->output()->writeln("Found " . count($alt_texts) . " existing alt texts from D7.");
    }
    catch (\Exception $e) {
      $this->output()->writeln("No D7 alt text table found, will generate from filenames.");
    }

    $created = 0;
    $errors = 0;

    foreach ($files as $file_data) {
      try {
        $file = File::load($file_data->fid);
        if (!$file) {
          $this->output()->writeln("File {$file_data->fid} not found, skipping.");
          continue;
        }

        // Get alt text - from D7 field or generate from filename
        $alt = isset($alt_texts[$file_data->fid]) ? $alt_texts[$file_data->fid] : '';
        if (empty($alt)) {
          // Generate from filename (remove extension, replace dashes/underscores)
          $alt = pathinfo($file_data->filename, PATHINFO_FILENAME);
          $alt = str_replace(['-', '_'], ' ', $alt);
          $alt = ucfirst($alt);
        }

        // Truncate alt to 512 chars max
        $alt = mb_substr($alt, 0, 512);

        // Create media entity with preserved timestamps from original file
        $media = Media::create([
          'bundle' => 'image',
          'name' => $file_data->filename,
          'uid' => 1,
          'status' => 1,
          'created' => $file_data->created,
          'field_media_image' => [
            'target_id' => $file_data->fid,
            'alt' => $alt,
            'title' => $alt,
          ],
        ]);
        // Preserve the original file's changed timestamp
        $media->setChangedTime($file_data->changed);
        $media->save();

        $created++;
        if ($created % 100 == 0) {
          $this->output()->writeln("Created {$created} / {$total} media entities...");
        }
      }
      catch (\Exception $e) {
        $errors++;
        $this->output()->writeln("Error with file {$file_data->fid}: " . $e->getMessage());
      }
    }

    $this->output()->writeln("Migration complete: {$created} created, {$errors} errors.");
  }

  /**
   * Show migration status.
   *
   * @command media:status
   * @aliases mst
   */
  public function status() {
    $database = \Drupal::database();

    // Count files
    $file_count = $database->query("SELECT COUNT(*) FROM {file_managed} WHERE filemime LIKE 'image/%'")->fetchField();

    // Count media
    $media_count = $database->query("SELECT COUNT(*) FROM {media_field_data} WHERE bundle = 'image'")->fetchField();

    // Count files without media
    $query = $database->select('file_managed', 'f');
    $query->condition('f.filemime', 'image/%', 'LIKE');
    $query->leftJoin('media__field_media_image', 'm', 'f.fid = m.field_media_image_target_id');
    $query->isNull('m.entity_id');
    $query->addExpression('COUNT(*)');
    $unmigrated = $query->execute()->fetchField();

    $this->output()->writeln("Image files: {$file_count}");
    $this->output()->writeln("Media entities: {$media_count}");
    $this->output()->writeln("Files without media: {$unmigrated}");
  }

  /**
   * List media entities with their alt text.
   *
   * @command media:list
   * @aliases mls
   * @option limit Number of items to show
   */
  public function listMedia($options = ['limit' => 20]) {
    $database = \Drupal::database();

    $query = $database->select('media_field_data', 'm');
    $query->fields('m', ['mid', 'name']);
    $query->join('media__field_media_image', 'i', 'm.mid = i.entity_id');
    $query->fields('i', ['field_media_image_alt']);
    $query->range(0, $options['limit']);
    $query->orderBy('m.mid', 'DESC');

    $results = $query->execute()->fetchAll();

    foreach ($results as $row) {
      $alt = $row->field_media_image_alt ?: '(no alt)';
      $this->output()->writeln("[{$row->mid}] {$row->name} - Alt: {$alt}");
    }
  }

  /**
   * Fix timestamps on existing media entities to match their source files.
   *
   * @command media:fix-timestamps
   * @aliases mft
   * @usage media:fix-timestamps
   *   Update all media entity timestamps to match their source file timestamps.
   */
  public function fixTimestamps() {
    $database = \Drupal::database();

    // Get all media entities with their associated files
    $query = $database->select('media__field_media_image', 'm');
    $query->fields('m', ['entity_id', 'field_media_image_target_id']);
    $query->join('file_managed', 'f', 'm.field_media_image_target_id = f.fid');
    $query->addField('f', 'created', 'file_created');
    $query->addField('f', 'changed', 'file_changed');
    $query->join('media_field_data', 'md', 'm.entity_id = md.mid');
    $query->addField('md', 'created', 'media_created');
    $query->addField('md', 'changed', 'media_changed');

    $results = $query->execute()->fetchAll();
    $total = count($results);
    $fixed = 0;

    $this->output()->writeln("Found {$total} media entities to check.");

    foreach ($results as $row) {
      // Only update if timestamps differ
      if ($row->media_created != $row->file_created || $row->media_changed != $row->file_changed) {
        $database->update('media_field_data')
          ->fields([
            'created' => $row->file_created,
            'changed' => $row->file_changed,
          ])
          ->condition('mid', $row->entity_id)
          ->execute();

        // Also update revision table
        $database->update('media_field_revision')
          ->fields([
            'changed' => $row->file_changed,
          ])
          ->condition('mid', $row->entity_id)
          ->execute();

        $fixed++;
        if ($fixed % 100 == 0) {
          $this->output()->writeln("Fixed {$fixed} media entities...");
        }
      }
    }

    $this->output()->writeln("Timestamp fix complete: {$fixed} media entities updated.");
  }

  /**
   * Update alt text for a media entity.
   *
   * @command media:set-alt
   * @aliases msa
   * @param int $mid Media ID
   * @param string $alt New alt text
   */
  public function setAlt($mid, $alt) {
    $media = Media::load($mid);
    if (!$media) {
      $this->output()->writeln("Media {$mid} not found.");
      return;
    }

    $media->get('field_media_image')->alt = $alt;
    $media->get('field_media_image')->title = $alt;
    $media->save();

    $this->output()->writeln("Updated media {$mid} alt text to: {$alt}");
  }

  /**
   * Find missing files - files in DB but not on disk.
   *
   * @command media:find-missing
   * @aliases mfm
   * @option type Filter by type: public, private, or all
   * @usage media:find-missing
   *   Find all missing files.
   * @usage media:find-missing --type=public
   *   Find only missing public files.
   */
  public function findMissing($options = ['type' => 'all']) {
    $database = \Drupal::database();
    $file_system = \Drupal::service('file_system');

    $query = $database->select('file_managed', 'f');
    $query->fields('f', ['fid', 'filename', 'uri', 'filemime']);
    $query->condition('f.status', 1);

    if ($options['type'] === 'public') {
      $query->condition('f.uri', 'public://%', 'LIKE');
    }
    elseif ($options['type'] === 'private') {
      $query->condition('f.uri', 'private://%', 'LIKE');
    }

    $files = $query->execute()->fetchAll();
    $total = count($files);
    $missing = [];
    $checked = 0;

    $this->output()->writeln("Checking {$total} files...");

    foreach ($files as $file) {
      $real_path = $file_system->realpath($file->uri);
      if (!$real_path || !file_exists($real_path)) {
        $missing[] = $file;
      }
      $checked++;
      if ($checked % 500 == 0) {
        $this->output()->writeln("Checked {$checked} / {$total}...");
      }
    }

    $missing_count = count($missing);
    $this->output()->writeln("\nFound {$missing_count} missing files:\n");

    // Group by directory
    $by_dir = [];
    foreach ($missing as $file) {
      $dir = dirname($file->uri);
      if (!isset($by_dir[$dir])) {
        $by_dir[$dir] = [];
      }
      $by_dir[$dir][] = $file;
    }

    foreach ($by_dir as $dir => $files) {
      $this->output()->writeln("{$dir}: " . count($files) . " missing");
      // Show first 5 from each dir
      $shown = 0;
      foreach ($files as $file) {
        if ($shown < 5) {
          $this->output()->writeln("  - [{$file->fid}] {$file->filename}");
          $shown++;
        }
      }
      if (count($files) > 5) {
        $this->output()->writeln("  ... and " . (count($files) - 5) . " more");
      }
    }

    return $missing_count;
  }

  /**
   * Fix encoding issues in file URIs (Latin-1 to UTF-8 conversion).
   *
   * @command media:fix-encoding
   * @aliases mfe
   * @option dry-run Show what would be fixed without making changes
   * @usage media:fix-encoding
   *   Fix all file URI encoding issues.
   * @usage media:fix-encoding --dry-run
   *   Preview fixes without applying them.
   */
  public function fixEncoding($options = ['dry-run' => FALSE]) {
    $database = \Drupal::database();
    $file_system = \Drupal::service('file_system');
    $dry_run = $options['dry-run'];

    // Hungarian character mapping: Latin-1 byte to UTF-8 character
    $latin1_to_utf8 = [
      "\xe1" => 'á', // á
      "\xe9" => 'é', // é
      "\xed" => 'í', // í
      "\xf3" => 'ó', // ó
      "\xf6" => 'ö', // ö
      "\xfa" => 'ú', // ú
      "\xfc" => 'ü', // ü
      "\xc1" => 'Á', // Á
      "\xc9" => 'É', // É
      "\xcd" => 'Í', // Í
      "\xd3" => 'Ó', // Ó
      "\xd6" => 'Ö', // Ö
      "\xda" => 'Ú', // Ú
      "\xdc" => 'Ü', // Ü
      "\xf5" => 'ő', // ő (may appear as o with tilde in Latin-1)
      "\xfb" => 'ű', // ű (may appear as u with circumflex in Latin-1)
      "\xd5" => 'Ő', // Ő
      "\xdb" => 'Ű', // Ű
    ];

    // Get all files - we'll check if their paths need fixing
    $query = $database->select('file_managed', 'f');
    $query->fields('f', ['fid', 'filename', 'uri']);
    $query->condition('f.status', 1);
    $files = $query->execute()->fetchAll();

    $total = count($files);
    $fixed = 0;
    $not_found = 0;
    $checked = 0;

    $this->output()->writeln("Checking {$total} files for encoding issues...");
    if ($dry_run) {
      $this->output()->writeln("DRY RUN - no changes will be made.\n");
    }

    foreach ($files as $file) {
      $checked++;
      $uri = $file->uri;
      $filename = $file->filename;

      // Check if file exists with current URI
      $real_path = $file_system->realpath($uri);
      if ($real_path && file_exists($real_path)) {
        continue; // File exists, no fix needed
      }

      // Try to fix the encoding
      $fixed_uri = $uri;
      $fixed_filename = $filename;

      // Apply Latin-1 to UTF-8 conversion
      foreach ($latin1_to_utf8 as $latin1 => $utf8) {
        $fixed_uri = str_replace($latin1, $utf8, $fixed_uri);
        $fixed_filename = str_replace($latin1, $utf8, $fixed_filename);
      }

      // Only proceed if the conversion actually changed something
      if ($fixed_uri === $uri) {
        // No encoding issue, file is just missing
        $not_found++;
        continue;
      }

      // Check if the fixed URI exists
      $fixed_real_path = $file_system->realpath($fixed_uri);
      if ($fixed_real_path && file_exists($fixed_real_path)) {
        if ($dry_run) {
          $this->output()->writeln("[{$file->fid}] Would fix:");
          $this->output()->writeln("  FROM: {$uri}");
          $this->output()->writeln("  TO:   {$fixed_uri}");
        }
        else {
          // Update the database
          $database->update('file_managed')
            ->fields([
              'uri' => $fixed_uri,
              'filename' => $fixed_filename,
            ])
            ->condition('fid', $file->fid)
            ->execute();
          $this->output()->writeln("[{$file->fid}] Fixed: {$filename}");
        }
        $fixed++;
      }
      else {
        // Encoding was fixed but file still not found
        $not_found++;
      }

      if ($checked % 500 == 0) {
        $this->output()->writeln("Checked {$checked} / {$total}...");
      }
    }

    $action = $dry_run ? "Would fix" : "Fixed";
    $this->output()->writeln("\n{$action} {$fixed} files with encoding issues.");
    $this->output()->writeln("Truly missing (not fixable): {$not_found} files.");

    if (!$dry_run && $fixed > 0) {
      $this->output()->writeln("\nClearing caches...");
      drupal_flush_all_caches();
    }
  }

  /**
   * Pre-generate image style derivatives for all images.
   *
   * Nginx doesn't route missing image styles to Drupal for on-demand generation,
   * so we need to pre-generate them.
   *
   * @command media:generate-styles
   * @aliases mgs
   * @option style Image style to generate (default: all)
   * @option path Filter by path pattern (e.g., gallery/main)
   * @usage media:generate-styles
   *   Generate all image styles for all images.
   * @usage media:generate-styles --style=large
   *   Generate only the 'large' image style.
   * @usage media:generate-styles --path=gallery/main
   *   Generate styles only for gallery/main images.
   */
  public function generateStyles($options = ['style' => 'all', 'path' => NULL]) {
    $database = \Drupal::database();
    $file_system = \Drupal::service('file_system');

    // Get all image styles
    $style_storage = \Drupal::entityTypeManager()->getStorage('image_style');
    if ($options['style'] === 'all') {
      $styles = $style_storage->loadMultiple();
    }
    else {
      $style = $style_storage->load($options['style']);
      if (!$style) {
        $this->output()->writeln("Image style '{$options['style']}' not found.");
        return;
      }
      $styles = [$options['style'] => $style];
    }

    $this->output()->writeln("Will generate " . count($styles) . " image style(s): " . implode(', ', array_keys($styles)));

    // Get all image files
    $query = $database->select('file_managed', 'f');
    $query->fields('f', ['fid', 'filename', 'uri']);
    $query->condition('f.filemime', 'image/%', 'LIKE');
    $query->condition('f.status', 1);
    $query->condition('f.uri', 'public://%', 'LIKE');

    if ($options['path']) {
      $query->condition('f.uri', '%' . $database->escapeLike($options['path']) . '%', 'LIKE');
    }

    $files = $query->execute()->fetchAll();
    $total = count($files);
    $generated = 0;
    $skipped = 0;
    $errors = 0;

    $this->output()->writeln("Processing {$total} image files...\n");

    foreach ($files as $file) {
      $source_path = $file_system->realpath($file->uri);
      if (!$source_path || !file_exists($source_path)) {
        $skipped++;
        continue;
      }

      foreach ($styles as $style_name => $style) {
        $derivative_uri = $style->buildUri($file->uri);
        $derivative_path = $file_system->realpath($derivative_uri);

        // Skip if derivative already exists
        if ($derivative_path && file_exists($derivative_path)) {
          continue;
        }

        try {
          $result = $style->createDerivative($file->uri, $derivative_uri);
          if ($result) {
            $generated++;
          }
          else {
            $errors++;
          }
        }
        catch (\Exception $e) {
          $errors++;
          $this->output()->writeln("Error [{$file->fid}] {$style_name}: " . $e->getMessage());
        }
      }

      if (($generated + $skipped + $errors) % 100 == 0) {
        $this->output()->writeln("Progress: {$generated} generated, {$skipped} skipped, {$errors} errors...");
      }
    }

    $this->output()->writeln("\nGeneration complete:");
    $this->output()->writeln("  Generated: {$generated}");
    $this->output()->writeln("  Skipped (source missing): {$skipped}");
    $this->output()->writeln("  Errors: {$errors}");
  }
}

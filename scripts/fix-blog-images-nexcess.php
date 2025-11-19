#!/usr/bin/env php
<?php
/**
 * @file
 * Fix missing blog article images on Nexcess.
 *
 * Run with: cd ~/9df7d73bf2.nxcli.io/drupal/web && php ../scripts/fix-blog-images-nexcess.php
 */

// Find Drupal root and autoloader
$dir = getcwd();
if (basename($dir) === 'web') {
  $autoloader = $dir . '/../vendor/autoload.php';
} else {
  $autoloader = $dir . '/vendor/autoload.php';
}

if (!file_exists($autoloader)) {
  die("Could not find autoloader at: $autoloader\n");
}

use Drupal\file\Entity\File;

// Bootstrap Drupal
$autoloader = require_once $autoloader;
$kernel = \Drupal\Core\DrupalKernel::createFromRequest(
  \Symfony\Component\HttpFoundation\Request::createFromGlobals(),
  $autoloader,
  'prod'
);
$kernel->boot();
$kernel->preHandle(\Symfony\Component\HttpFoundation\Request::createFromGlobals());

$connection = \Drupal::database();

// D7 article image data
$d7_data = <<<'TSV'
774	Modern kocsibeálló okos technológiákkal - Energiatakarékos és automatizált megoldások	egyedi-tervezesu-napelemmel-fedett-dupla-kocsibeallo-ragasztott-fa-szerkezettel-deluxe-kocsibeallo-15.jpg	public://field/image/egyedi-tervezesu-napelemmel-fedett-dupla-kocsibeallo-ragasztott-fa-szerkezettel-deluxe-kocsibeallo-15.jpg	image/jpeg	1986867
768	Időtálló kocsibeálló vidéki otthonfelújítási támogatással	videki-otthonfelujitasi-tamogatas-egyedi-kocsibeallo-deluxe-building.jpg	public://field/image/videki-otthonfelujitasi-tamogatas-egyedi-kocsibeallo-deluxe-building.jpg	image/jpeg	623843
757	Előregyártott kocsibeállók	deluxe-eloregyartott-autobeallo-ximax-eco-aluminium-05.jpg	public://field/image/deluxe-eloregyartott-autobeallo-ximax-eco-aluminium-05.jpg	image/jpeg	436975
741	Meglepő, de fából van: fémhatású kocsibeálló szerkezetek	femhatasu_ragasztott_fa_kocsibeallo_deluxe_building_2.jpg	public://field/image/femhatasu_ragasztott_fa_kocsibeallo_deluxe_building_2.jpg	image/jpeg	347415
732	Most érdemes napelemes kocsibeállót építtetni	napelemes_kocsibeallo_autobeallo_deluxe_building_5.jpg	public://field/image/napelemes_kocsibeallo_autobeallo_deluxe_building_5.jpg	image/jpeg	364245
728	Bemutatjuk az új Ximax Wing kocsibeallót	ximax-wing-80-antracit-szinu-aluminium-kocsibeallo-1.jpg	public://ximax-wing-80-antracit-szinu-aluminium-kocsibeallo-1.jpg	image/jpeg	332734
727	Autóvédelem stílusosan: a XIMAX kocsibeállók varázsa	ximax-neo-rozsdamentes_szinu-szimpla-aluminium-kocsibeallo-Deluxe_Building.jpg	public://field/image/ximax-neo-rozsdamentes_szinu-szimpla-aluminium-kocsibeallo-Deluxe_Building.jpg	image/jpeg	74695
723	Mindennek lesz végre helye - Kocsibeállók tárolóval	egyedi_kocsibeallo_taroloval_Deluxe_Building.jpg	public://field/image/egyedi_kocsibeallo_taroloval_Deluxe_Building.jpg	image/jpeg	1418318
722	Kocsibeálló tartószerkezetek 3. rész: alumínium zártszelvények 	aluminium-kocsibeallo_szendvicspanel-fedessel-Deluxe_Building.jpg	public://field/image/aluminium-kocsibeallo_szendvicspanel-fedessel-Deluxe_Building.jpg	image/jpeg	1671289
721	Kocsibeálló Tartószerkezetek 2. rész - Vas zártszerelvény	vas-szerkezet-polikarbonat-fedes-egyedi-autobeallo-kocsibeallo-autobeallo4.jpg	public://gallery/main/vas-szerkezet-polikarbonat-fedes-egyedi-autobeallo-kocsibeallo-autobeallo4.jpg	image/jpeg	284092
720	Kocsibeálló tartószerkezetek 1. rész - Ragasztott fa	ragasztott-fa-szerkezetu-lamberiazott-zsindely-fedesu-kocsibeallo_Deluxe_Building.jpg	public://field/image/ragasztott-fa-szerkezetu-lamberiazott-zsindely-fedesu-kocsibeallo_Deluxe_Building.jpg	image/jpeg	254858
719	Fényárban a kocsibeálló	szines_LED_csikokkal_felszerelt_egyedi_kocsibeallo_Deluxe_Building.jpg	public://field/image/szines_LED_csikokkal_felszerelt_egyedi_kocsibeallo_Deluxe_Building.jpg	image/jpeg	152764
717	Kocsibeálló és fényűzés: új szintre emelve az exkluzív megjelenést	ximax_myport_7_kocsibeallo_deluxe_building.jpg	public://field/image/ximax_myport_7_kocsibeallo_deluxe_building.jpg	image/jpeg	128134
716	Garázs vs. kocsibeálló, pozitívumok és negatívumok	Ximax_Portoforte_kocsibeallo_deluxe_building.jpg	public://field/image/Ximax_Portoforte_kocsibeallo_deluxe_building.jpg	image/jpeg	1228911
715	Céges kocsibeálló telepítése: hosszú távú befektetés	elore_gyartott_kocsibeallo_Ximax_cegeknek_Deluxe_building.jpg	public://field/image/elore_gyartott_kocsibeallo_Ximax_cegeknek_Deluxe_building.jpg	image/jpeg	258372
714	Őrizze meg autója újszerű állapotát 4 lépésben	üvegfedésű-kocsibeálló-02.jpg	public://field/image/üvegfedésű-kocsibeálló-02.jpg	image/jpeg	3002209
713	Új ház garázs nélkül? Bízza autója védelmét kocsibeállóra	ximax-linea-dupla-aluminium-kocsibeallo_deluxe_building.jpg	public://field/image/ximax-linea-dupla-aluminium-kocsibeallo_deluxe_building.jpg	image/jpeg	127592
712	Betonozás, térkövezés, zúzott kő - kocsibeálló alapozási kisokos	ximax-portoforte-ives-aluminium-dupla-kocsibeallo-beton_aljzat_Deluxe_building.jpg	public://field/image/ximax-portoforte-ives-aluminium-dupla-kocsibeallo-beton_aljzat_Deluxe_building.jpg	image/jpeg	102505
711	Családi összejövetel, gyerekzsúr, Halloween party - kreatív ötletek kocsibeálló tulajdonosoknak	karacsonyi_diszitesu_fa_kocsibeallo_deluxe_building.jpg	public://field/image/karacsonyi_diszitesu_fa_kocsibeallo_deluxe_building.jpg	image/jpeg	1336747
710	Üveg, lemez vagy polikarbonát tetőt válasszak a kocsibeállómhoz?	uveg_fedes_kocsibeallo_deluxe_building.jpg	public://field/image/uveg_fedes_kocsibeallo_deluxe_building.jpg	image/jpeg	5940744
706	Kocsibeálló extrákkal	deluxe-autobeallo-ximax-eco-eloregyartott-aluminium-kocsibeallo-06.jpg	public://field/image/deluxe-autobeallo-ximax-eco-eloregyartott-aluminium-kocsibeallo-06.jpg	image/jpeg	464414
TSV;

echo "=== Fix Missing Blog Images (Nexcess) ===\n\n";

$fixed = 0;
$errors = 0;
$skipped = 0;

$lines = explode("\n", trim($d7_data));
echo "Processing " . count($lines) . " articles...\n\n";

// Get the files directory path
$files_path = \Drupal::service('file_system')->realpath('public://');

foreach ($lines as $line) {
  $parts = explode("\t", $line);
  if (count($parts) < 6) continue;

  $nid = $parts[0];
  $title = $parts[1];
  $filename = $parts[2];
  $uri = $parts[3];
  $filemime = $parts[4];
  $filesize = $parts[5];

  // Check if D10 article has a valid image
  $d10_file = $connection->query("
    SELECT fi.field_image_target_id, fm.uri, fm.fid
    FROM {node__field_image} fi
    LEFT JOIN {file_managed} fm ON fi.field_image_target_id = fm.fid
    WHERE fi.entity_id = :nid AND fi.delta = 0
  ", [':nid' => $nid])->fetch();

  // Skip if D10 already has valid image
  if ($d10_file && $d10_file->uri) {
    $skipped++;
    continue;
  }

  echo "→ nid {$nid}: " . substr($title, 0, 50) . "...\n";

  // Convert URI to filesystem path
  $d10_path = str_replace('public://', $files_path . '/', $uri);

  // Check if file exists
  if (!file_exists($d10_path)) {
    echo "  ⚠ File missing: {$d10_path}\n";
    $errors++;
    continue;
  }

  // Get actual file size
  $actual_filesize = filesize($d10_path);

  // Create file_managed entry
  $file = File::create([
    'uri' => $uri,
    'filename' => $filename,
    'filemime' => $filemime,
    'filesize' => $actual_filesize,
    'status' => 1,
    'uid' => 1,
  ]);
  $file->save();

  $new_fid = $file->id();
  echo "  Created file_managed: fid={$new_fid}\n";

  // Update or insert node__field_image
  $existing = $connection->query("
    SELECT entity_id FROM {node__field_image} WHERE entity_id = :nid AND delta = 0
  ", [':nid' => $nid])->fetch();

  // Get node info
  $node_info = $connection->query("
    SELECT vid, langcode FROM {node_field_data} WHERE nid = :nid
  ", [':nid' => $nid])->fetch();

  if ($existing) {
    $connection->update('node__field_image')
      ->fields(['field_image_target_id' => $new_fid])
      ->condition('entity_id', $nid)
      ->condition('delta', 0)
      ->execute();
  } else if ($node_info) {
    $connection->insert('node__field_image')
      ->fields([
        'bundle' => 'article',
        'deleted' => 0,
        'entity_id' => $nid,
        'revision_id' => $node_info->vid,
        'langcode' => $node_info->langcode,
        'delta' => 0,
        'field_image_target_id' => $new_fid,
        'field_image_alt' => $title,
        'field_image_title' => '',
        'field_image_width' => NULL,
        'field_image_height' => NULL,
      ])
      ->execute();
  }

  // Also update revision table
  if ($node_info) {
    $connection->merge('node_revision__field_image')
      ->keys([
        'entity_id' => $nid,
        'revision_id' => $node_info->vid,
        'delta' => 0,
      ])
      ->fields([
        'bundle' => 'article',
        'deleted' => 0,
        'entity_id' => $nid,
        'revision_id' => $node_info->vid,
        'langcode' => $node_info->langcode,
        'delta' => 0,
        'field_image_target_id' => $new_fid,
        'field_image_alt' => $title,
        'field_image_title' => '',
        'field_image_width' => NULL,
        'field_image_height' => NULL,
      ])
      ->execute();
  }

  $fixed++;
  echo "  ✓ Fixed!\n";
}

echo "\n=== Summary ===\n";
echo "Fixed: {$fixed}\n";
echo "Skipped (already has image): {$skipped}\n";
echo "Errors: {$errors}\n";

<?php

/**
 * Script to create XIMAX autóbeálló típusok menu item and reorganize submenu
 * ARC-781
 */

use Drupal\menu_link_content\Entity\MenuLinkContent;

// Bootstrap Drupal
require_once 'web/core/includes/bootstrap.inc';
require_once 'web/autoload.php';

$kernel = \Drupal\Core\DrupalKernel::createFromRequest(
  \Symfony\Component\HttpFoundation\Request::createFromGlobals(),
  require 'web/autoload.php',
  'prod',
  FALSE
);
$kernel->boot();
$kernel->prepareLegacyRequest(\Symfony\Component\HttpFoundation\Request::createFromGlobals());

// Find the "Kocsibeálló típusok" parent menu item
$parent_uuid = NULL;
$database = \Drupal::database();
$query = $database->query("SELECT mlc.uuid FROM menu_link_content mlc INNER JOIN menu_link_content_data mlcd ON mlc.id = mlcd.id WHERE mlcd.id = 4779");
$result = $query->fetchAssoc();
if ($result) {
  $parent_uuid = $result['uuid'];
  echo "Found parent UUID: $parent_uuid\n";
}

// Create menu link for "XIMAX autóbeálló típusok" (node/651)
$ximax_parent = MenuLinkContent::create([
  'title' => 'XIMAX autóbeálló típusok',
  'link' => ['uri' => 'entity:node/651'],
  'menu_name' => 'main',
  'parent' => $parent_uuid ? 'menu_link_content:' . $parent_uuid : '',
  'weight' => 2, // Position it after "Egyedi nyitott" and "Palram"
  'enabled' => TRUE,
]);
$ximax_parent->save();
$ximax_parent_uuid = $ximax_parent->uuid();

echo "Created XIMAX parent menu item with UUID: $ximax_parent_uuid\n";

// Update the 4 XIMAX product pages to have the new parent
$ximax_children = [
  5521, // XIMAX Linea
  5973, // Ximax NEO
  5520, // XIMAX Portoforte
  6320, // XIMAX Wing
];

foreach ($ximax_children as $child_id) {
  $child_query = $database->query("SELECT mlc.uuid FROM menu_link_content mlc WHERE mlc.id = :id", [':id' => $child_id]);
  $child_result = $child_query->fetchAssoc();

  if ($child_result) {
    $child_uuid = $child_result['uuid'];
    $menu_link = \Drupal::entityTypeManager()
      ->getStorage('menu_link_content')
      ->loadByProperties(['uuid' => $child_uuid]);

    if ($menu_link) {
      $menu_link = reset($menu_link);
      $menu_link->set('parent', 'menu_link_content:' . $ximax_parent_uuid);
      $menu_link->save();
      echo "Updated menu item $child_id to have XIMAX parent\n";
    }
  }
}

// Clear menu cache
\Drupal::service('plugin.manager.menu.link')->rebuild();
\Drupal::service('router.builder')->rebuild();

echo "Done! Menu structure updated.\n";

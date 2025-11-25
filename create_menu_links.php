<?php

use Drupal\Core\DrupalKernel;
use Symfony\Component\HttpFoundation\Request;

$autoloader = require_once '/app/autoload.php';
$kernel = new DrupalKernel('prod', $autoloader);
$request = Request::createFromGlobals();
$kernel->boot();
$kernel->prepareLegacyRequest($request);

$storage = \Drupal::entityTypeManager()->getStorage('menu_link_content');

// Create Ximax menu link
$ximax_link = $storage->create([
  'title' => 'Ximax kocsibeállók',
  'link' => ['uri' => 'internal:/kepgaleria/field_gallery_tag/ximax-156'],
  'menu_name' => 'main',
  'parent' => 'menu_link_content:05a996dc-0a5f-40b7-8257-1b040160d37b',
  'weight' => -49,
  'expanded' => FALSE,
]);
$ximax_link->save();
echo "Created Ximax menu link with ID: " . $ximax_link->id() . "\n";

// Create Napelemes menu link
$napelemes_link = $storage->create([
  'title' => 'Napelemes kocsibeállók',
  'link' => ['uri' => 'internal:/kepgaleria/field_gallery_tag/napelemes-149'],
  'menu_name' => 'main',
  'parent' => 'menu_link_content:05a996dc-0a5f-40b7-8257-1b040160d37b',
  'weight' => -47,
  'expanded' => FALSE,
]);
$napelemes_link->save();
echo "Created Napelemes menu link with ID: " . $napelemes_link->id() . "\n";

echo "Menu links created successfully!\n";

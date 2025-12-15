<?php
/**
 * Fix UTF-8 encoding issues in node titles and body content
 * Uses D7 database as source of truth
 */

use Drupal\node\Entity\Node;

// D7 database connection info
$d7_host = 'mariadb7';
$d7_db = 'drupal';
$d7_user = 'drupal';
$d7_pass = 'drupal';

try {
  $d7_pdo = new PDO("mysql:host=$d7_host;dbname=$d7_db;charset=utf8mb4", $d7_user, $d7_pass);
  $d7_pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
  echo "Connected to D7 database\n";
} catch (PDOException $e) {
  echo "D7 connection failed: " . $e->getMessage() . "\n";
  return;
}

// Get all nodes from D7 with Hungarian characters
$stmt = $d7_pdo->query("
  SELECT n.nid, n.title, b.body_value, b.body_summary
  FROM node n
  LEFT JOIN field_data_body b ON n.nid = b.entity_id
  WHERE n.title LIKE '%ű%' OR n.title LIKE '%ő%'
     OR n.title LIKE '%á%' OR n.title LIKE '%é%'
     OR n.title LIKE '%í%' OR n.title LIKE '%ó%'
     OR n.title LIKE '%ö%' OR n.title LIKE '%ü%'
");

$d7_nodes = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Found " . count($d7_nodes) . " D7 nodes with Hungarian characters\n\n";

$fixed_count = 0;
$skipped_count = 0;

foreach ($d7_nodes as $d7_node) {
  $nid = $d7_node['nid'];
  $d7_title = $d7_node['title'];
  $d7_body = $d7_node['body_value'];
  $d7_summary = $d7_node['body_summary'];

  // Try to load the D10 node
  $node = Node::load($nid);
  if (!$node) {
    continue;
  }

  $d10_title = $node->getTitle();
  $needs_update = false;

  // Check if title needs fixing (compare normalized versions)
  if ($d7_title !== $d10_title) {
    echo "NID $nid: Title mismatch\n";
    echo "  D7:  $d7_title\n";
    echo "  D10: $d10_title\n";
    $node->setTitle($d7_title);
    $needs_update = true;
  }

  // Check body if exists
  if ($node->hasField('body') && !empty($d7_body)) {
    $d10_body = $node->get('body')->value;
    // Simple check - if D10 body contains garbled chars
    if (strpos($d10_body, 'Ã') !== false || strpos($d10_body, 'Å') !== false) {
      echo "NID $nid: Body has encoding issues, fixing...\n";
      $node->get('body')->value = $d7_body;
      if (!empty($d7_summary)) {
        $node->get('body')->summary = $d7_summary;
      }
      $needs_update = true;
    }
  }

  if ($needs_update) {
    $node->save();
    $fixed_count++;
    echo "  -> Fixed!\n";
  } else {
    $skipped_count++;
  }
}

echo "\n=== Summary ===\n";
echo "Fixed: $fixed_count nodes\n";
echo "Skipped (already OK): $skipped_count nodes\n";

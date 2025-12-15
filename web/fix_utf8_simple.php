<?php
/**
 * Fix UTF-8 encoding issues using TSV file from D7
 */

use Drupal\node\Entity\Node;

$tsv_file = '/tmp/d7_node_titles.tsv';
if (!file_exists($tsv_file)) {
  echo "TSV file not found: $tsv_file\n";
  return;
}

$lines = file($tsv_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
echo "Found " . count($lines) . " nodes to check\n\n";

$fixed_count = 0;
$not_found = 0;
$already_ok = 0;

foreach ($lines as $line) {
  $parts = explode("\t", $line, 2);
  if (count($parts) < 2) continue;

  $nid = trim($parts[0]);
  $d7_title = trim($parts[1]);

  $node = Node::load($nid);
  if (!$node) {
    $not_found++;
    continue;
  }

  $d10_title = $node->getTitle();

  // Check if needs fixing
  if ($d7_title !== $d10_title) {
    echo "NID $nid:\n";
    echo "  D7:  $d7_title\n";
    echo "  D10: $d10_title\n";
    $node->setTitle($d7_title);
    $node->save();
    echo "  -> Fixed!\n\n";
    $fixed_count++;
  } else {
    $already_ok++;
  }
}

echo "\n=== Summary ===\n";
echo "Fixed: $fixed_count nodes\n";
echo "Already OK: $already_ok nodes\n";
echo "Not found in D10: $not_found nodes\n";

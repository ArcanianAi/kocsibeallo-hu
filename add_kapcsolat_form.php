<?php

use Drupal\node\Entity\Node;

// Bootstrap Drupal
$autoloader = require_once '/app/vendor/autoload.php';
$kernel = \Drupal\Core\DrupalKernel::createFromRequest(
  \Symfony\Component\HttpFoundation\Request::createFromGlobals(),
  $autoloader,
  'prod'
);
$kernel->boot();
$kernel->prepareLegacyRequest(\Symfony\Component\HttpFoundation\Request::createFromGlobals());

// Load node 145 (Kapcsolat page)
$node = Node::load(145);

if ($node) {
  $body = $node->body->value;

  // Remove the incomplete div tag if exists
  $body = str_replace('<div data-drupal-selector="webform-submission-kapcsolat-form" id="webform-submission-kapcsolat-form">', '', $body);

  // Check if form embed already exists
  if (strpos($body, 'data-entity-uuid="2e1c5d29-dbd7-4ed5-a197-a966b38bbbbd"') === FALSE) {
    // Add the webform embed after the "Kapcsolat" heading
    $form_embed = "\n\n<p>Kérjük, töltse ki az alábbi űrlapot és hamarosan felvesszük Önnel a kapcsolatot!</p>\n\n" .
                  '<drupal-entity data-embed-button="webform" data-entity-embed-display="entity_reference:entity_reference_entity_view" ' .
                  'data-entity-type="webform" data-entity-uuid="2e1c5d29-dbd7-4ed5-a197-a966b38bbbbd"></drupal-entity>' . "\n</div>";

    $body = str_replace(
      '<div class="col-md-12">' . "\n" . '<h2>Kapcsolat</h2>' . "\n" . '</div>',
      '<div class="col-md-12">' . "\n" . '<h2>Kapcsolat</h2>' . $form_embed,
      $body
    );

    $node->body->value = $body;
    $node->save();

    echo "Successfully added contact form to Kapcsolat page!\n";
  } else {
    echo "Contact form already embedded in page.\n";
  }
} else {
  echo "Error: Could not load node 145\n";
}

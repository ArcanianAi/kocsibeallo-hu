<?php

namespace Drupal\photoswipe_rules\Form;

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;
use Drupal\node\Entity\NodeType;

/**
 * Configure PhotoSwipe Rules settings.
 */
class PhotoswipeRulesSettingsForm extends ConfigFormBase {

  /**
   * {@inheritdoc}
   */
  public function getFormId() {
    return 'photoswipe_rules_settings';
  }

  /**
   * {@inheritdoc}
   */
  protected function getEditableConfigNames() {
    return ['photoswipe_rules.settings'];
  }

  /**
   * {@inheritdoc}
   */
  public function buildForm(array $form, FormStateInterface $form_state) {
    $config = $this->config('photoswipe_rules.settings');

    $form['excluded_paths'] = [
      '#type' => 'textarea',
      '#title' => $this->t('Excluded paths'),
      '#description' => $this->t('Enter paths where PhotoSwipe should be DISABLED. One path per line. Use &lt;front&gt; for the homepage. Use * as wildcard (e.g., /admin/*, /node/123).'),
      '#default_value' => $config->get('excluded_paths'),
      '#rows' => 5,
    ];

    $form['enabled_paths'] = [
      '#type' => 'textarea',
      '#title' => $this->t('Enabled paths (override exclusions)'),
      '#description' => $this->t('Enter paths where PhotoSwipe should ALWAYS be enabled, even if they match an exclusion rule. One path per line.'),
      '#default_value' => $config->get('enabled_paths'),
      '#rows' => 3,
    ];

    // Get all content types
    $content_types = [];
    foreach (NodeType::loadMultiple() as $type) {
      $content_types[$type->id()] = $type->label();
    }

    $form['excluded_content_types'] = [
      '#type' => 'checkboxes',
      '#title' => $this->t('Excluded content types'),
      '#description' => $this->t('Select content types where PhotoSwipe should be disabled.'),
      '#options' => $content_types,
      '#default_value' => $config->get('excluded_content_types') ?: [],
    ];

    $form['excluded_selectors'] = [
      '#type' => 'textarea',
      '#title' => $this->t('Excluded CSS selectors'),
      '#description' => $this->t('Enter CSS selectors for elements that should NOT have PhotoSwipe. One selector per line. Example: .frontpage .product-thumb-info'),
      '#default_value' => $config->get('excluded_selectors'),
      '#rows' => 3,
    ];

    return parent::buildForm($form, $form_state);
  }

  /**
   * {@inheritdoc}
   */
  public function submitForm(array &$form, FormStateInterface $form_state) {
    $excluded_types = array_filter($form_state->getValue('excluded_content_types'));

    $this->config('photoswipe_rules.settings')
      ->set('excluded_paths', $form_state->getValue('excluded_paths'))
      ->set('enabled_paths', $form_state->getValue('enabled_paths'))
      ->set('excluded_content_types', array_values($excluded_types))
      ->set('excluded_selectors', $form_state->getValue('excluded_selectors'))
      ->save();

    parent::submitForm($form, $form_state);
  }

}

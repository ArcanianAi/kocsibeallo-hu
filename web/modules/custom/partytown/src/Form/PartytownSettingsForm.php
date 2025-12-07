<?php

namespace Drupal\partytown\Form;

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;

/**
 * Configure Partytown settings.
 */
class PartytownSettingsForm extends ConfigFormBase {

  /**
   * {@inheritdoc}
   */
  protected function getEditableConfigNames() {
    return ['partytown.settings'];
  }

  /**
   * {@inheritdoc}
   */
  public function getFormId() {
    return 'partytown_settings_form';
  }

  /**
   * {@inheritdoc}
   */
  public function buildForm(array $form, FormStateInterface $form_state) {
    $config = $this->config('partytown.settings');

    $form['description'] = [
      '#type' => 'markup',
      '#markup' => '<p>' . $this->t('Partytown offloads third-party scripts to a web worker, freeing up the main thread and improving Core Web Vitals metrics like Total Blocking Time (TBT) and Largest Contentful Paint (LCP).') . '</p>',
    ];

    $form['enabled'] = [
      '#type' => 'checkbox',
      '#title' => $this->t('Enable Partytown'),
      '#default_value' => $config->get('enabled'),
      '#description' => $this->t('When enabled, configured third-party scripts will run in a web worker instead of the main thread.'),
    ];

    $form['debug'] = [
      '#type' => 'checkbox',
      '#title' => $this->t('Debug mode'),
      '#default_value' => $config->get('debug'),
      '#description' => $this->t('Enable verbose console logging for debugging. <strong>Disable in production</strong> as it increases file size.'),
    ];

    $form['lib_path'] = [
      '#type' => 'textfield',
      '#title' => $this->t('Library path'),
      '#default_value' => $config->get('lib_path') ?? '/modules/custom/partytown/lib',
      '#description' => $this->t('Path to Partytown library files relative to web root. Must be on the same origin (required by service worker).'),
      '#required' => TRUE,
    ];

    $form['forward'] = [
      '#type' => 'textarea',
      '#title' => $this->t('Event forwards'),
      '#default_value' => implode("\n", $config->get('forward') ?? ['dataLayer.push']),
      '#description' => $this->t('Global functions to forward from main thread to web worker. One per line.<br><strong>Common values:</strong><br>• <code>dataLayer.push</code> - Google Tag Manager<br>• <code>gtag</code> - Google Analytics 4<br>• <code>fbq</code> - Facebook Pixel<br>• <code>_hsq.push</code> - HubSpot'),
      '#rows' => 6,
    ];

    $form['intercept_patterns'] = [
      '#type' => 'textarea',
      '#title' => $this->t('Script URL patterns to intercept'),
      '#default_value' => implode("\n", $config->get('intercept_patterns') ?? []),
      '#description' => $this->t('URL patterns to match. Scripts with src URLs containing these patterns will be converted to run in Partytown. One per line.<br><strong>Common patterns:</strong><br>• <code>googletagmanager.com</code><br>• <code>google-analytics.com</code><br>• <code>connect.facebook.net</code><br>• <code>consent.cookiebot.com</code>'),
      '#rows' => 6,
    ];

    $form['excluded_paths'] = [
      '#type' => 'textarea',
      '#title' => $this->t('Excluded paths'),
      '#default_value' => implode("\n", $config->get('excluded_paths') ?? []),
      '#description' => $this->t('Drupal paths where Partytown should NOT be active. Use wildcards (*). One per line.<br><strong>Recommended:</strong> <code>/admin/*</code>, <code>/user/*</code> to avoid issues with admin interfaces and GTM preview mode.'),
      '#rows' => 4,
    ];

    $form['resolve_url'] = [
      '#type' => 'checkbox',
      '#title' => $this->t('Enable CORS proxy'),
      '#default_value' => $config->get('resolve_url'),
      '#description' => $this->t('Proxy third-party script requests through your server to handle CORS restrictions. Enable only if scripts fail to load due to CORS errors. This adds server load.'),
    ];

    // Third-party script injection section
    $form['third_party'] = [
      '#type' => 'details',
      '#title' => $this->t('Third-Party Scripts'),
      '#open' => TRUE,
      '#description' => $this->t('Configure third-party scripts to be directly injected with Partytown. These scripts will bypass any Drupal modules that normally load them (like Google Tag module) and run in a web worker instead.<br><br><strong>Important:</strong> When you configure scripts here, you should disable or uninstall the corresponding Drupal modules to avoid duplicate loading.'),
    ];

    $form['third_party']['gtm_container_id'] = [
      '#type' => 'textfield',
      '#title' => $this->t('Google Tag Manager Container ID'),
      '#default_value' => $config->get('gtm_container_id'),
      '#description' => $this->t('GTM Container ID (e.g., GTM-XXXXXX). When set, GTM will be loaded via Partytown instead of the Google Tag module.'),
      '#placeholder' => 'GTM-XXXXXX',
    ];

    $form['third_party']['cookiebot_id'] = [
      '#type' => 'textfield',
      '#title' => $this->t('Cookiebot ID'),
      '#default_value' => $config->get('cookiebot_id'),
      '#description' => $this->t('Cookiebot account ID for consent management.'),
      '#placeholder' => 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
    ];

    $form['third_party']['facebook_pixel_id'] = [
      '#type' => 'textfield',
      '#title' => $this->t('Facebook Pixel ID'),
      '#default_value' => $config->get('facebook_pixel_id'),
      '#description' => $this->t('Facebook Pixel ID for tracking. Note: If you have complex event tracking via GTM, leave this empty and configure Facebook Pixel through GTM instead.'),
      '#placeholder' => 'XXXXXXXXXXXXXXXX',
    ];

    $form['status'] = [
      '#type' => 'details',
      '#title' => $this->t('Module Status'),
      '#open' => TRUE,
    ];

    // Check if library files exist
    $lib_path = DRUPAL_ROOT . ($config->get('lib_path') ?? '/modules/custom/partytown/lib');
    $required_files = ['partytown.js', 'partytown-sw.js'];
    $missing_files = [];

    foreach ($required_files as $file) {
      if (!file_exists($lib_path . '/' . $file)) {
        $missing_files[] = $file;
      }
    }

    if (empty($missing_files)) {
      $form['status']['library_status'] = [
        '#type' => 'markup',
        '#markup' => '<p style="color: green;">✓ ' . $this->t('Partytown library files found at @path', ['@path' => $lib_path]) . '</p>',
      ];
    }
    else {
      $form['status']['library_status'] = [
        '#type' => 'markup',
        '#markup' => '<p style="color: red;">✗ ' . $this->t('Missing library files: @files at @path', [
          '@files' => implode(', ', $missing_files),
          '@path' => $lib_path,
        ]) . '</p>',
      ];
    }

    // Check if google_tag module is enabled
    if (\Drupal::moduleHandler()->moduleExists('google_tag')) {
      $forwards = $config->get('forward') ?? [];
      if (in_array('dataLayer.push', $forwards)) {
        $form['status']['gtm_status'] = [
          '#type' => 'markup',
          '#markup' => '<p style="color: green;">✓ ' . $this->t('Google Tag module detected and dataLayer.push is configured.') . '</p>',
        ];
      }
      else {
        $form['status']['gtm_status'] = [
          '#type' => 'markup',
          '#markup' => '<p style="color: orange;">⚠ ' . $this->t('Google Tag module detected but dataLayer.push is not in forwards. Add it above for GTM to work.') . '</p>',
        ];
      }
    }

    return parent::buildForm($form, $form_state);
  }

  /**
   * {@inheritdoc}
   */
  public function validateForm(array &$form, FormStateInterface $form_state) {
    parent::validateForm($form, $form_state);

    // Validate lib_path starts with /
    $lib_path = $form_state->getValue('lib_path');
    if (!str_starts_with($lib_path, '/')) {
      $form_state->setErrorByName('lib_path', $this->t('Library path must start with /'));
    }
  }

  /**
   * {@inheritdoc}
   */
  public function submitForm(array &$form, FormStateInterface $form_state) {
    $this->config('partytown.settings')
      ->set('enabled', (bool) $form_state->getValue('enabled'))
      ->set('debug', (bool) $form_state->getValue('debug'))
      ->set('lib_path', trim($form_state->getValue('lib_path')))
      ->set('forward', $this->textareaToArray($form_state->getValue('forward')))
      ->set('intercept_patterns', $this->textareaToArray($form_state->getValue('intercept_patterns')))
      ->set('excluded_paths', $this->textareaToArray($form_state->getValue('excluded_paths')))
      ->set('resolve_url', (bool) $form_state->getValue('resolve_url'))
      ->set('gtm_container_id', trim($form_state->getValue('gtm_container_id') ?? ''))
      ->set('cookiebot_id', trim($form_state->getValue('cookiebot_id') ?? ''))
      ->set('facebook_pixel_id', trim($form_state->getValue('facebook_pixel_id') ?? ''))
      ->save();

    parent::submitForm($form, $form_state);

    // Clear render cache to apply changes immediately
    \Drupal::service('cache.render')->invalidateAll();
    \Drupal::service('cache.page')->invalidateAll();

    $this->messenger()->addStatus($this->t('Partytown settings saved. Page and render caches cleared.'));
  }

  /**
   * Convert textarea value to array.
   */
  protected function textareaToArray(string $value): array {
    return array_values(array_filter(array_map('trim', explode("\n", $value))));
  }

}

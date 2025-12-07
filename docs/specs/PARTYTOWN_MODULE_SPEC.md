# Partytown Drupal Module Specification

**Module Name:** `partytown`
**Machine Name:** `partytown`
**Version:** 1.0.0
**Drupal Compatibility:** 10.x, 11.x
**Date:** 2025-12-07
**Author:** Arcanian
**Related Issue:** [ARC-868](https://linear.app/arcanian/issue/ARC-868)

---

## 1. Overview

### 1.1 Purpose

This module integrates [Partytown](https://partytown.qwik.dev/) with Drupal to offload third-party scripts (Google Tag Manager, Facebook Pixel, Google Analytics, Cookiebot, etc.) to a web worker, freeing up the main thread and improving Core Web Vitals metrics.

### 1.2 Problem Statement

Third-party scripts significantly impact PageSpeed performance:

| Script | Transfer Size | Main Thread Impact |
|--------|---------------|-------------------|
| Google Tag Manager | 129 KiB | High |
| Facebook Pixel | 86 KiB | Medium |
| Cookiebot | 34 KiB | Medium |

These scripts block the main thread, increasing Total Blocking Time (TBT) and delaying Largest Contentful Paint (LCP).

### 1.3 Solution

Partytown runs third-party scripts in a web worker, removing them from the main thread. This can reduce TBT by 50-80% and improve overall PageSpeed scores by 10-20 points.

---

## 2. Architecture

### 2.1 High-Level Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         Browser                                  │
├─────────────────────────────────────────────────────────────────┤
│  Main Thread                    │  Web Worker (Partytown)       │
│  ─────────────                  │  ────────────────────         │
│  • Critical CSS                 │  • GTM Script                 │
│  • Critical JS                  │  • Facebook Pixel             │
│  • LCP Content                  │  • Google Analytics           │
│  • User Interactions            │  • Cookiebot                  │
│                                 │  • Other 3rd-party scripts    │
│         ◄─────────────────────► │                               │
│         Event Forwarding        │                               │
│         (dataLayer.push, fbq)   │                               │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Module Components

```
web/modules/custom/partytown/
├── partytown.info.yml           # Module definition
├── partytown.module             # Hook implementations
├── partytown.install            # Install/uninstall hooks
├── partytown.libraries.yml      # Library definitions
├── partytown.routing.yml        # Admin routes
├── partytown.permissions.yml    # Permissions
├── config/
│   ├── install/
│   │   └── partytown.settings.yml    # Default config
│   └── schema/
│       └── partytown.schema.yml      # Config schema
├── src/
│   ├── Form/
│   │   └── PartytownSettingsForm.php # Admin settings form
│   ├── EventSubscriber/
│   │   └── PartytownResponseSubscriber.php # Modifies HTML response
│   └── Service/
│       └── PartytownManager.php      # Core service
├── js/
│   └── partytown-config.js           # Config injector
├── lib/                              # Partytown library files
│   ├── partytown.js
│   ├── partytown-sw.js
│   ├── partytown-atomics.js
│   └── partytown-media.js
└── templates/
    └── partytown-snippet.html.twig   # Inline snippet template
```

---

## 3. Functional Requirements

### 3.1 Core Features

#### FR-1: Library File Hosting
- **Description:** Host Partytown library files from the same origin (required by service worker scope)
- **Location:** `/libraries/partytown/` or `/modules/custom/partytown/lib/`
- **Files Required:**
  - `partytown.js` (main script)
  - `partytown-sw.js` (service worker)
  - `partytown-atomics.js` (atomics support)
  - `partytown-media.js` (media support, optional)

#### FR-2: Script Interception
- **Description:** Intercept scripts from configured modules and add `type="text/partytown"`
- **Supported Modules:**
  - `google_tag` (GTM)
  - `google_analytics` (GA4)
  - `eu_cookie_compliance` / Cookiebot
  - Custom inline scripts
- **Implementation:** Response subscriber that modifies HTML output

#### FR-3: Event Forwarding Configuration
- **Description:** Configure which global functions to forward from main thread to worker
- **Default Forwards:**
  ```javascript
  forward: [
    'dataLayer.push',      // GTM
    'gtag',                // GA4
    'fbq',                 // Facebook Pixel
    '_hsq.push',           // HubSpot
    'Cookiebot'            // Cookiebot
  ]
  ```

#### FR-4: Admin Configuration UI
- **Description:** Provide admin form for configuration
- **Path:** `/admin/config/services/partytown`
- **Settings:**
  - Enable/disable module
  - Debug mode toggle
  - Custom forwards (textarea)
  - Script URL patterns to intercept
  - Excluded pages (path patterns)

#### FR-5: Integration with google_tag Module
- **Description:** Seamless integration with Drupal's google_tag module
- **Behavior:** Automatically modify GTM script tags when both modules enabled
- **No manual configuration required** for basic GTM setup

### 3.2 Configuration Options

```yaml
# partytown.settings.yml
enabled: true
debug: false
lib_path: '/libraries/partytown'
forward:
  - 'dataLayer.push'
  - 'gtag'
  - 'fbq'
intercept_patterns:
  - 'googletagmanager.com'
  - 'google-analytics.com'
  - 'connect.facebook.net'
  - 'consent.cookiebot.com'
excluded_paths:
  - '/admin/*'
  - '/user/*'
resolve_url: true  # Resolve URLs through proxy (for CORS)
```

---

## 4. Technical Implementation

### 4.1 Installation Process

```php
// partytown.install

/**
 * Implements hook_install().
 */
function partytown_install() {
  // Copy Partytown library files to public files directory
  $source = \Drupal::service('extension.list.module')->getPath('partytown') . '/lib';
  $destination = 'public://partytown';

  \Drupal::service('file_system')->prepareDirectory($destination, FileSystemInterface::CREATE_DIRECTORY);

  $files = ['partytown.js', 'partytown-sw.js', 'partytown-atomics.js', 'partytown-media.js'];
  foreach ($files as $file) {
    \Drupal::service('file_system')->copy("$source/$file", "$destination/$file", FileSystemInterface::EXISTS_REPLACE);
  }

  \Drupal::messenger()->addStatus(t('Partytown library files copied to @path', ['@path' => $destination]));
}
```

### 4.2 Response Subscriber (Script Interception)

```php
// src/EventSubscriber/PartytownResponseSubscriber.php

namespace Drupal\partytown\EventSubscriber;

use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\ResponseEvent;
use Symfony\Component\HttpKernel\KernelEvents;

class PartytownResponseSubscriber implements EventSubscriberInterface {

  protected $config;
  protected $partytownManager;

  public function __construct(ConfigFactoryInterface $config_factory, PartytownManager $partytown_manager) {
    $this->config = $config_factory->get('partytown.settings');
    $this->partytownManager = $partytown_manager;
  }

  public static function getSubscribedEvents() {
    // Run after other response subscribers but before final output
    return [KernelEvents::RESPONSE => ['onResponse', -100]];
  }

  public function onResponse(ResponseEvent $event) {
    if (!$this->config->get('enabled')) {
      return;
    }

    $response = $event->getResponse();
    $content = $response->getContent();

    // Skip if not HTML
    if (strpos($response->headers->get('Content-Type'), 'text/html') === false) {
      return;
    }

    // Skip excluded paths
    $current_path = \Drupal::service('path.current')->getPath();
    if ($this->isExcludedPath($current_path)) {
      return;
    }

    // Inject Partytown config and snippet into <head>
    $content = $this->injectPartytownSnippet($content);

    // Convert matching scripts to type="text/partytown"
    $content = $this->convertScripts($content);

    $response->setContent($content);
  }

  protected function injectPartytownSnippet($content) {
    $snippet = $this->partytownManager->getSnippet();
    $config = $this->partytownManager->getConfigScript();

    // Insert after <head> tag
    $content = preg_replace(
      '/<head([^>]*)>/i',
      "<head$1>\n$config\n$snippet",
      $content,
      1
    );

    return $content;
  }

  protected function convertScripts($content) {
    $patterns = $this->config->get('intercept_patterns') ?? [];

    foreach ($patterns as $pattern) {
      // Match script tags containing the pattern
      $regex = '/<script([^>]*src=["\'][^"\']*' . preg_quote($pattern, '/') . '[^"\']*["\'][^>]*)>/i';
      $content = preg_replace($regex, '<script type="text/partytown"$1>', $content);
    }

    return $content;
  }

  protected function isExcludedPath($path) {
    $excluded = $this->config->get('excluded_paths') ?? [];
    $alias = \Drupal::service('path_alias.manager')->getAliasByPath($path);

    foreach ($excluded as $pattern) {
      if (\Drupal::service('path.matcher')->matchPath($path, $pattern) ||
          \Drupal::service('path.matcher')->matchPath($alias, $pattern)) {
        return true;
      }
    }
    return false;
  }
}
```

### 4.3 Partytown Manager Service

```php
// src/Service/PartytownManager.php

namespace Drupal\partytown\Service;

class PartytownManager {

  protected $config;

  public function __construct(ConfigFactoryInterface $config_factory) {
    $this->config = $config_factory->get('partytown.settings');
  }

  /**
   * Get the Partytown configuration script.
   */
  public function getConfigScript(): string {
    $forwards = $this->config->get('forward') ?? ['dataLayer.push'];
    $lib_path = $this->config->get('lib_path') ?? '/libraries/partytown';
    $debug = $this->config->get('debug') ?? false;
    $resolve_url = $this->config->get('resolve_url') ?? false;

    $config = [
      'lib' => $lib_path . '/',
      'debug' => $debug,
      'forward' => $forwards,
    ];

    // Add resolveUrl for CORS proxy if needed
    if ($resolve_url) {
      $config['resolveUrl'] = '__RESOLVE_URL_FUNCTION__';
    }

    $json = json_encode($config, JSON_UNESCAPED_SLASHES);

    // Replace placeholder with actual function
    if ($resolve_url) {
      $proxy_url = \Drupal::request()->getSchemeAndHttpHost() . '/partytown/proxy';
      $resolve_fn = "function(url) { if (url.hostname !== location.hostname) { return '$proxy_url?url=' + encodeURIComponent(url.href); } return url; }";
      $json = str_replace('"__RESOLVE_URL_FUNCTION__"', $resolve_fn, $json);
    }

    return "<script>partytown = $json;</script>";
  }

  /**
   * Get the inlined Partytown snippet.
   */
  public function getSnippet(): string {
    // This is the minified Partytown snippet that bootstraps the library
    // In production, this would be loaded from the partytown.js file
    $lib_path = $this->config->get('lib_path') ?? '/libraries/partytown';

    return <<<HTML
<script>
/* Partytown Bootstrap */
!function(t,e,n,i,o,r,a,s,c,d,l){if(l=t.partytown||{},!e.querySelector('script[type="text/partytown"]'))return;function p(){c||(c=1,a=document.createElement("script"),a.src="{$lib_path}/partytown.js",document.head.appendChild(a))}l.lib=l.lib||"{$lib_path}/","complete"==document.readyState?p():(t.addEventListener("DOMContentLoaded",p),t.addEventListener("load",p))}(window,document);
</script>
HTML;
  }

  /**
   * Get list of library files.
   */
  public function getLibraryFiles(): array {
    return [
      'partytown.js',
      'partytown-sw.js',
      'partytown-atomics.js',
      'partytown-media.js',
    ];
  }
}
```

### 4.4 Admin Settings Form

```php
// src/Form/PartytownSettingsForm.php

namespace Drupal\partytown\Form;

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;

class PartytownSettingsForm extends ConfigFormBase {

  protected function getEditableConfigNames() {
    return ['partytown.settings'];
  }

  public function getFormId() {
    return 'partytown_settings_form';
  }

  public function buildForm(array $form, FormStateInterface $form_state) {
    $config = $this->config('partytown.settings');

    $form['enabled'] = [
      '#type' => 'checkbox',
      '#title' => $this->t('Enable Partytown'),
      '#default_value' => $config->get('enabled'),
      '#description' => $this->t('When enabled, configured third-party scripts will run in a web worker.'),
    ];

    $form['debug'] = [
      '#type' => 'checkbox',
      '#title' => $this->t('Debug mode'),
      '#default_value' => $config->get('debug'),
      '#description' => $this->t('Enable verbose console logging for debugging. Disable in production.'),
    ];

    $form['lib_path'] = [
      '#type' => 'textfield',
      '#title' => $this->t('Library path'),
      '#default_value' => $config->get('lib_path') ?? '/libraries/partytown',
      '#description' => $this->t('Path to Partytown library files. Must be on the same origin.'),
    ];

    $form['forward'] = [
      '#type' => 'textarea',
      '#title' => $this->t('Event forwards'),
      '#default_value' => implode("\n", $config->get('forward') ?? ['dataLayer.push']),
      '#description' => $this->t('Global functions to forward to the web worker. One per line. Common values: dataLayer.push, gtag, fbq, _hsq.push'),
      '#rows' => 6,
    ];

    $form['intercept_patterns'] = [
      '#type' => 'textarea',
      '#title' => $this->t('Script URL patterns to intercept'),
      '#default_value' => implode("\n", $config->get('intercept_patterns') ?? [
        'googletagmanager.com',
        'google-analytics.com',
        'connect.facebook.net',
        'consent.cookiebot.com',
      ]),
      '#description' => $this->t('URL patterns to match. Scripts containing these patterns will be converted to Partytown. One per line.'),
      '#rows' => 6,
    ];

    $form['excluded_paths'] = [
      '#type' => 'textarea',
      '#title' => $this->t('Excluded paths'),
      '#default_value' => implode("\n", $config->get('excluded_paths') ?? ['/admin/*', '/user/*']),
      '#description' => $this->t('Paths where Partytown should NOT be active. Use wildcards (*). One per line.'),
      '#rows' => 4,
    ];

    $form['resolve_url'] = [
      '#type' => 'checkbox',
      '#title' => $this->t('Enable CORS proxy'),
      '#default_value' => $config->get('resolve_url'),
      '#description' => $this->t('Proxy third-party requests through your server to handle CORS. May be required for some scripts.'),
    ];

    return parent::buildForm($form, $form_state);
  }

  public function submitForm(array &$form, FormStateInterface $form_state) {
    $this->config('partytown.settings')
      ->set('enabled', $form_state->getValue('enabled'))
      ->set('debug', $form_state->getValue('debug'))
      ->set('lib_path', $form_state->getValue('lib_path'))
      ->set('forward', array_filter(array_map('trim', explode("\n", $form_state->getValue('forward')))))
      ->set('intercept_patterns', array_filter(array_map('trim', explode("\n", $form_state->getValue('intercept_patterns')))))
      ->set('excluded_paths', array_filter(array_map('trim', explode("\n", $form_state->getValue('excluded_paths')))))
      ->set('resolve_url', $form_state->getValue('resolve_url'))
      ->save();

    parent::submitForm($form, $form_state);

    // Clear caches to apply changes
    drupal_flush_all_caches();
  }
}
```

### 4.5 Module Definition Files

```yaml
# partytown.info.yml
name: 'Partytown'
type: module
description: 'Offloads third-party scripts to a web worker for improved performance.'
package: 'Performance'
core_version_requirement: ^10 || ^11
configure: partytown.settings
dependencies:
  - drupal:system

# partytown.routing.yml
partytown.settings:
  path: '/admin/config/services/partytown'
  defaults:
    _form: '\Drupal\partytown\Form\PartytownSettingsForm'
    _title: 'Partytown Settings'
  requirements:
    _permission: 'administer partytown'

partytown.proxy:
  path: '/partytown/proxy'
  defaults:
    _controller: '\Drupal\partytown\Controller\ProxyController::proxy'
  requirements:
    _permission: 'access content'

# partytown.permissions.yml
administer partytown:
  title: 'Administer Partytown settings'
  description: 'Configure Partytown third-party script offloading.'

# partytown.services.yml
services:
  partytown.manager:
    class: Drupal\partytown\Service\PartytownManager
    arguments: ['@config.factory']

  partytown.response_subscriber:
    class: Drupal\partytown\EventSubscriber\PartytownResponseSubscriber
    arguments: ['@config.factory', '@partytown.manager']
    tags:
      - { name: event_subscriber }
```

### 4.6 Config Schema

```yaml
# config/schema/partytown.schema.yml
partytown.settings:
  type: config_object
  label: 'Partytown settings'
  mapping:
    enabled:
      type: boolean
      label: 'Enabled'
    debug:
      type: boolean
      label: 'Debug mode'
    lib_path:
      type: string
      label: 'Library path'
    forward:
      type: sequence
      label: 'Event forwards'
      sequence:
        type: string
        label: 'Forward'
    intercept_patterns:
      type: sequence
      label: 'Intercept patterns'
      sequence:
        type: string
        label: 'Pattern'
    excluded_paths:
      type: sequence
      label: 'Excluded paths'
      sequence:
        type: string
        label: 'Path'
    resolve_url:
      type: boolean
      label: 'Enable CORS proxy'
```

---

## 5. Integration with google_tag Module

### 5.1 Automatic Detection

The module should automatically detect when `google_tag` is enabled and:
1. Add `dataLayer.push` to forwards (if not present)
2. Add `googletagmanager.com` to intercept patterns
3. Modify GTM script output

### 5.2 Hook Implementation

```php
// partytown.module

/**
 * Implements hook_page_attachments_alter().
 */
function partytown_page_attachments_alter(array &$attachments) {
  $config = \Drupal::config('partytown.settings');
  if (!$config->get('enabled')) {
    return;
  }

  // Check if google_tag module is present
  if (\Drupal::moduleHandler()->moduleExists('google_tag')) {
    // The response subscriber will handle script modification
    // Just ensure dataLayer.push is in forwards
    $forwards = $config->get('forward') ?? [];
    if (!in_array('dataLayer.push', $forwards)) {
      \Drupal::logger('partytown')->warning('google_tag module detected but dataLayer.push not in forwards. Add it via admin UI.');
    }
  }
}
```

---

## 6. Testing Plan

### 6.1 Unit Tests

| Test | Description |
|------|-------------|
| `testSnippetGeneration` | Verify Partytown snippet is correctly generated |
| `testConfigScript` | Verify config script includes all forwards |
| `testScriptConversion` | Verify script tags are converted correctly |
| `testExcludedPaths` | Verify excluded paths are respected |

### 6.2 Functional Tests

| Test | Description |
|------|-------------|
| `testAdminForm` | Test settings form saves correctly |
| `testModuleEnable` | Test module enables without errors |
| `testLibraryInstall` | Test library files are copied on install |
| `testGoogleTagIntegration` | Test GTM scripts are intercepted |

### 6.3 Performance Tests

| Metric | Before | Target |
|--------|--------|--------|
| TBT (Total Blocking Time) | 170ms | <100ms |
| PageSpeed Score (Mobile) | 57 | 70+ |
| Main Thread Work | High | Reduced |

---

## 7. Installation & Usage

### 7.1 Installation

```bash
# Option 1: Install via Composer (when published)
composer require drupal/partytown

# Option 2: Manual installation
cd web/modules/custom
git clone [repository-url] partytown
drush en partytown -y
```

### 7.2 Configuration

1. Navigate to `/admin/config/services/partytown`
2. Enable Partytown
3. Configure forwards for your tracking scripts
4. Add intercept patterns for script URLs
5. Clear caches

### 7.3 Verification

After enabling, verify in browser DevTools:
1. Check Network tab - third-party scripts should load
2. Check Console - Partytown initialization messages
3. Check Application > Service Workers - `partytown-sw.js` registered
4. Run PageSpeed test - TBT should be reduced

---

## 8. Known Limitations

### 8.1 GTM Preview Mode
- GTM Preview/Debug mode may not work with Partytown
- Workaround: Add admin paths to excluded paths

### 8.2 Scripts Requiring Synchronous Execution
- Some scripts require synchronous main thread access
- These should NOT be converted to Partytown
- Add their URLs to exclusion list if issues occur

### 8.3 CORS Issues
- Some scripts may have CORS restrictions
- Enable CORS proxy if needed (performance impact)

---

## 9. Development Timeline

| Phase | Tasks | Estimate |
|-------|-------|----------|
| **Phase 1** | Module scaffolding, config, admin form | 2 hours |
| **Phase 2** | Response subscriber, script interception | 3 hours |
| **Phase 3** | Partytown library integration, snippet | 2 hours |
| **Phase 4** | google_tag integration, testing | 2 hours |
| **Phase 5** | Documentation, edge cases, polish | 1 hour |
| **Total** | | **10 hours** |

---

## 10. References

- [Partytown Documentation](https://partytown.qwik.dev/)
- [Partytown GTM Integration](https://partytown.qwik.dev/google-tag-manager/)
- [Partytown Event Forwarding](https://partytown.qwik.dev/forwarding-events/)
- [Partytown Library Distribution](https://partytown.qwik.dev/distribution/)
- [Copy Library Files](https://partytown.qwik.dev/copy-library-files/)
- [Drupal google_tag Module](https://www.drupal.org/project/google_tag)

---

## 11. Success Criteria

The module is considered complete when:

- [ ] Module installs without errors on Drupal 10.x
- [ ] Admin settings form works correctly
- [ ] GTM scripts are automatically intercepted and converted
- [ ] Partytown service worker registers correctly
- [ ] Events (dataLayer.push) are forwarded to worker
- [ ] PageSpeed TBT metric improves by 30%+
- [ ] No console errors in production mode
- [ ] Admin paths are excluded by default
- [ ] Documentation is complete

---

**Last Updated:** 2025-12-07
**Status:** Specification Complete
**Next Step:** Development Phase 1

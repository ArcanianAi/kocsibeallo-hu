<?php

namespace Drupal\partytown\Service;

use Drupal\Core\Config\ConfigFactoryInterface;
use Drupal\Core\File\FileUrlGeneratorInterface;
use Drupal\Core\Extension\ModuleExtensionList;

/**
 * Partytown manager service.
 */
class PartytownManager {

  /**
   * The config factory.
   *
   * @var \Drupal\Core\Config\ConfigFactoryInterface
   */
  protected $configFactory;

  /**
   * The file URL generator.
   *
   * @var \Drupal\Core\File\FileUrlGeneratorInterface
   */
  protected $fileUrlGenerator;

  /**
   * The module extension list.
   *
   * @var \Drupal\Core\Extension\ModuleExtensionList
   */
  protected $moduleExtensionList;

  /**
   * Constructs a PartytownManager object.
   */
  public function __construct(
    ConfigFactoryInterface $config_factory,
    FileUrlGeneratorInterface $file_url_generator,
    ModuleExtensionList $module_extension_list
  ) {
    $this->configFactory = $config_factory;
    $this->fileUrlGenerator = $file_url_generator;
    $this->moduleExtensionList = $module_extension_list;
  }

  /**
   * Get the Partytown configuration.
   */
  protected function getConfig() {
    return $this->configFactory->get('partytown.settings');
  }

  /**
   * Check if Partytown is enabled.
   */
  public function isEnabled(): bool {
    return (bool) $this->getConfig()->get('enabled');
  }

  /**
   * Get the library path.
   */
  public function getLibPath(): string {
    return $this->getConfig()->get('lib_path') ?? '/modules/custom/partytown/lib';
  }

  /**
   * Get the forward configuration array.
   */
  public function getForwards(): array {
    return $this->getConfig()->get('forward') ?? ['dataLayer.push'];
  }

  /**
   * Get intercept patterns.
   */
  public function getInterceptPatterns(): array {
    return $this->getConfig()->get('intercept_patterns') ?? [];
  }

  /**
   * Get excluded paths.
   */
  public function getExcludedPaths(): array {
    return $this->getConfig()->get('excluded_paths') ?? [];
  }

  /**
   * Check if debug mode is enabled.
   */
  public function isDebugMode(): bool {
    return (bool) $this->getConfig()->get('debug');
  }

  /**
   * Check if CORS proxy is enabled.
   */
  public function isResolveUrlEnabled(): bool {
    return (bool) $this->getConfig()->get('resolve_url');
  }

  /**
   * Get the Partytown configuration script to inject in <head>.
   */
  public function getConfigScript(): string {
    $lib_path = $this->getLibPath();
    $forwards = $this->getForwards();
    $debug = $this->isDebugMode();

    // Build the config object
    $config_parts = [];
    $config_parts[] = '"lib": "' . $lib_path . '/"';
    $config_parts[] = '"debug": ' . ($debug ? 'true' : 'false');

    // Build forward array
    if (!empty($forwards)) {
      $forward_json = json_encode($forwards);
      $config_parts[] = '"forward": ' . $forward_json;
    }

    // Add resolveUrl if CORS proxy is enabled
    if ($this->isResolveUrlEnabled()) {
      $proxy_url = \Drupal::request()->getSchemeAndHttpHost() . '/partytown/proxy';
      $config_parts[] = '"resolveUrl": function(url, location, type) {
        if (url.hostname !== location.hostname) {
          const proxyUrl = new URL("' . $proxy_url . '");
          proxyUrl.searchParams.append("url", url.href);
          return proxyUrl;
        }
        return url;
      }';
    }

    $config_js = implode(",\n    ", $config_parts);

    return <<<HTML
<script>
  /* Partytown Configuration */
  partytown = {
    $config_js
  };
</script>
HTML;
  }

  /**
   * Get the inlined Partytown snippet that bootstraps the library.
   *
   * This is a minified version of the Partytown snippet that:
   * 1. Checks if there are any scripts with type="text/partytown"
   * 2. If so, loads the partytown.js library
   */
  public function getSnippet(): string {
    $lib_path = $this->getLibPath();

    // This is the official Partytown snippet, slightly modified
    // Original from: https://partytown.builder.io/
    return <<<HTML
<script>
/* Partytown Snippet v0.10.2 */
!function(t,e,n,i,o,r,a,s,c,d,l){if(l=t.partytown||{},e.querySelector('script[type="text/partytown"]')){for(r=function(t){return"string"==typeof t?t.replace(/^\\//,"/"):""},l.lib=r(l.lib||"{$lib_path}/"),a=e.getElementsByTagName("script"),c=0;c<a.length;c++)(d=a[c]).hasAttribute("type")&&"text/partytown"===d.getAttribute("type").toLowerCase()&&!d.hasAttribute("data-pt-init")&&(d.setAttribute("data-pt-init","1"));s||(s=1,t.partytown=l,"complete"==e.readyState?o():t.addEventListener("DOMContentLoaded",o))}function o(){l.lib?function(){var n=e.createElement("script");n.src=l.lib+"partytown.js",n.onload=function(){},n.onerror=function(){console.error("Partytown: Failed to load "+n.src)},e.head.appendChild(n)}():console.warn("Partytown: lib not defined")}}(window,document);
</script>
HTML;
  }

  /**
   * Get combined Partytown scripts (config + snippet) for injection.
   */
  public function getPartytownScripts(): string {
    return $this->getConfigScript() . "\n" . $this->getSnippet();
  }

  /**
   * Get list of required library files.
   */
  public function getRequiredLibraryFiles(): array {
    return [
      'partytown.js',
      'partytown-sw.js',
    ];
  }

  /**
   * Get list of all library files (including optional).
   */
  public function getAllLibraryFiles(): array {
    return [
      'partytown.js',
      'partytown-sw.js',
      'partytown-atomics.js',
      'partytown-media.js',
    ];
  }

  /**
   * Check if library files exist.
   */
  public function libraryFilesExist(): bool {
    $lib_path = DRUPAL_ROOT . $this->getLibPath();

    foreach ($this->getRequiredLibraryFiles() as $file) {
      if (!file_exists($lib_path . '/' . $file)) {
        return FALSE;
      }
    }

    return TRUE;
  }

}

<?php

namespace Drupal\partytown\EventSubscriber;

use Drupal\Core\Config\ConfigFactoryInterface;
use Drupal\Core\Path\CurrentPathStack;
use Drupal\Core\Path\PathMatcherInterface;
use Drupal\path_alias\AliasManagerInterface;
use Drupal\partytown\Service\PartytownManager;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\ResponseEvent;
use Symfony\Component\HttpKernel\KernelEvents;

/**
 * Modifies HTML responses to inject Partytown and convert scripts.
 */
class PartytownResponseSubscriber implements EventSubscriberInterface {

  /**
   * The config factory.
   *
   * @var \Drupal\Core\Config\ConfigFactoryInterface
   */
  protected $configFactory;

  /**
   * The Partytown manager.
   *
   * @var \Drupal\partytown\Service\PartytownManager
   */
  protected $partytownManager;

  /**
   * The current path.
   *
   * @var \Drupal\Core\Path\CurrentPathStack
   */
  protected $currentPath;

  /**
   * The alias manager.
   *
   * @var \Drupal\path_alias\AliasManagerInterface
   */
  protected $aliasManager;

  /**
   * The path matcher.
   *
   * @var \Drupal\Core\Path\PathMatcherInterface
   */
  protected $pathMatcher;

  /**
   * Constructs a PartytownResponseSubscriber object.
   */
  public function __construct(
    ConfigFactoryInterface $config_factory,
    PartytownManager $partytown_manager,
    CurrentPathStack $current_path,
    AliasManagerInterface $alias_manager,
    PathMatcherInterface $path_matcher
  ) {
    $this->configFactory = $config_factory;
    $this->partytownManager = $partytown_manager;
    $this->currentPath = $current_path;
    $this->aliasManager = $alias_manager;
    $this->pathMatcher = $path_matcher;
  }

  /**
   * {@inheritdoc}
   */
  public static function getSubscribedEvents() {
    // Run after most response processing but before final output
    // Priority -100 to run late in the process
    return [
      KernelEvents::RESPONSE => ['onResponse', -100],
    ];
  }

  /**
   * Processes the response to inject Partytown.
   */
  public function onResponse(ResponseEvent $event) {
    // Only process main requests
    if (!$event->isMainRequest()) {
      return;
    }

    // Check if Partytown is enabled
    if (!$this->partytownManager->isEnabled()) {
      return;
    }

    $response = $event->getResponse();
    $content = $response->getContent();

    // Skip if not HTML response
    $content_type = $response->headers->get('Content-Type', '');
    if (strpos($content_type, 'text/html') === FALSE) {
      return;
    }

    // Skip excluded paths
    if ($this->isExcludedPath()) {
      return;
    }

    // Skip if no HTML document structure
    if (strpos($content, '<head') === FALSE) {
      return;
    }

    // Check if library files exist
    if (!$this->partytownManager->libraryFilesExist()) {
      // Log warning but don't break the page
      \Drupal::logger('partytown')->warning('Partytown library files not found. Please check the lib_path configuration.');
      return;
    }

    // Inject Partytown configuration and snippet into <head>
    $content = $this->injectPartytownScripts($content);

    // Convert matching scripts to type="text/partytown"
    $content = $this->convertScripts($content);

    $response->setContent($content);
  }

  /**
   * Check if current path is excluded.
   */
  protected function isExcludedPath(): bool {
    $path = $this->currentPath->getPath();
    $alias = $this->aliasManager->getAliasByPath($path);
    $excluded_paths = $this->partytownManager->getExcludedPaths();

    foreach ($excluded_paths as $pattern) {
      // Check both system path and alias
      if ($this->pathMatcher->matchPath($path, $pattern) ||
          $this->pathMatcher->matchPath($alias, $pattern)) {
        return TRUE;
      }
    }

    return FALSE;
  }

  /**
   * Inject Partytown scripts after opening <head> tag.
   */
  protected function injectPartytownScripts(string $content): string {
    $scripts = $this->partytownManager->getPartytownScripts();

    // Find the position after <head...> tag
    // Use regex to handle attributes in head tag
    $pattern = '/(<head[^>]*>)/i';

    if (preg_match($pattern, $content, $matches, PREG_OFFSET_MATCH)) {
      $head_tag = $matches[1][0];
      $position = $matches[1][1] + strlen($head_tag);

      // Insert Partytown scripts right after <head>
      $content = substr($content, 0, $position) . "\n" . $scripts . "\n" . substr($content, $position);
    }

    return $content;
  }

  /**
   * Convert matching external scripts to use Partytown.
   */
  protected function convertScripts(string $content): string {
    $patterns = $this->partytownManager->getInterceptPatterns();

    if (empty($patterns)) {
      return $content;
    }

    foreach ($patterns as $pattern) {
      // Escape pattern for use in regex
      $escaped_pattern = preg_quote($pattern, '/');

      // Match script tags with src containing the pattern
      // Handles various attribute orders and quote styles
      $regex = '/<script([^>]*)\ssrc=["\']([^"\']*' . $escaped_pattern . '[^"\']*)["\']([^>]*)>/i';

      $content = preg_replace_callback($regex, function ($matches) {
        $before_src = $matches[1];
        $src_url = $matches[2];
        $after_src = $matches[3];

        // Check if already has type="text/partytown"
        if (stripos($before_src . $after_src, 'type="text/partytown"') !== FALSE ||
            stripos($before_src . $after_src, "type='text/partytown'") !== FALSE) {
          return $matches[0]; // Already converted
        }

        // Check if has another type attribute - don't modify
        if (preg_match('/\stype\s*=\s*["\'][^"\']+["\']/i', $before_src . $after_src)) {
          // Has a different type, skip conversion
          return $matches[0];
        }

        // Add type="text/partytown" attribute
        return '<script type="text/partytown"' . $before_src . ' src="' . $src_url . '"' . $after_src . '>';
      }, $content);
    }

    // Also convert inline scripts from google_tag module
    // These typically have specific patterns we can identify
    $content = $this->convertInlineGoogleTagScripts($content);

    return $content;
  }

  /**
   * Convert inline scripts from google_tag module.
   */
  protected function convertInlineGoogleTagScripts(string $content): string {
    // Match inline scripts that contain GTM/gtag initialization
    // Be careful to only match known patterns
    $gtm_patterns = [
      // GTM container snippet (the inline part after the external script)
      '/(<script>)\s*(window\.dataLayer\s*=\s*window\.dataLayer\s*\|\|\s*\[\];[^<]*gtag\([^<]+<\/script>)/is',
      // GA4 config
      '/(<script>)\s*(function\s+gtag\s*\(\)[^<]*gtag\([^<]+<\/script>)/is',
    ];

    foreach ($gtm_patterns as $pattern) {
      $content = preg_replace_callback($pattern, function ($matches) {
        // Check if already has partytown type
        if (stripos($matches[0], 'text/partytown') !== FALSE) {
          return $matches[0];
        }
        // Add partytown type
        return '<script type="text/partytown">' . $matches[2];
      }, $content);
    }

    return $content;
  }

}

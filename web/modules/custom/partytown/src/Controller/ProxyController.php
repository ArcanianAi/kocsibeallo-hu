<?php

namespace Drupal\partytown\Controller;

use Drupal\Core\Controller\ControllerBase;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * CORS proxy controller for Partytown.
 *
 * This proxies requests to third-party scripts that have CORS restrictions.
 * Only enable if needed, as it adds server load.
 */
class ProxyController extends ControllerBase {

  /**
   * Allowed domains for proxying (security measure).
   */
  protected const ALLOWED_DOMAINS = [
    'www.googletagmanager.com',
    'www.google-analytics.com',
    'connect.facebook.net',
    'consent.cookiebot.com',
    'www.googleadservices.com',
    'googleads.g.doubleclick.net',
    'static.hotjar.com',
    'script.hotjar.com',
  ];

  /**
   * Proxy a third-party script request.
   */
  public function proxy(Request $request) {
    $url = $request->query->get('url');

    if (empty($url)) {
      return new Response('Missing url parameter', 400);
    }

    // Validate URL
    $parsed = parse_url($url);
    if (!$parsed || empty($parsed['host'])) {
      return new Response('Invalid URL', 400);
    }

    // Security: Only allow specific domains
    if (!in_array($parsed['host'], self::ALLOWED_DOMAINS)) {
      \Drupal::logger('partytown')->warning('Proxy request blocked for domain: @domain', ['@domain' => $parsed['host']]);
      return new Response('Domain not allowed', 403);
    }

    // Fetch the remote content
    try {
      $client = \Drupal::httpClient();
      $response = $client->get($url, [
        'timeout' => 10,
        'headers' => [
          'User-Agent' => $request->headers->get('User-Agent', 'Drupal Partytown Proxy'),
          'Accept' => $request->headers->get('Accept', '*/*'),
        ],
      ]);

      $content = $response->getBody()->getContents();
      $content_type = $response->getHeaderLine('Content-Type') ?: 'application/javascript';

      // Return with CORS headers
      return new Response($content, 200, [
        'Content-Type' => $content_type,
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET',
        'Cache-Control' => 'public, max-age=86400', // Cache for 1 day
        'X-Partytown-Proxy' => 'true',
      ]);
    }
    catch (\Exception $e) {
      \Drupal::logger('partytown')->error('Proxy request failed for @url: @error', [
        '@url' => $url,
        '@error' => $e->getMessage(),
      ]);
      return new Response('Proxy request failed', 502);
    }
  }

}

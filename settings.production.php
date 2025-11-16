<?php

/**
 * Production Settings for Cloudways
 *
 * Copy these settings into your production settings.php file:
 * /home/kocsid10ssh/applications/[app-name]/public_html/drupal10/web/sites/default/settings.php
 *
 * Date: 2025-11-16
 * Production URL: https://phpstack-969836-6003258.cloudwaysapps.com
 */

/**
 * Production Database Configuration
 */
$databases['default']['default'] = array (
  'database' => 'wdzpzmmtxg',
  'username' => 'wdzpzmmtxg',
  'password' => 'fyQuAvP74q',
  'prefix' => '',
  'host' => 'localhost',
  'port' => '3306',
  'isolation_level' => 'READ COMMITTED',
  'driver' => 'mysql',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
);

/**
 * Configuration sync directory
 * Located outside web root for better security
 */
$settings['config_sync_directory'] = '../config/sync';

/**
 * Trusted host patterns
 * Add your production domains here
 */
$settings['trusted_host_patterns'] = [
  '^phpstack-969836-6003258\\.cloudwaysapps\\.com$',
  '^www\\.kocsibeallo\\.hu$',
  '^kocsibeallo\\.hu$',
];

/**
 * File paths
 */
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = 'sites/default/files/private';

/**
 * Redis Cache Configuration
 * Cloudways includes Redis by default
 */
if (extension_loaded('redis')) {
  $settings['redis.connection']['interface'] = 'PhpRedis';
  $settings['redis.connection']['host'] = 'localhost';
  $settings['redis.connection']['port'] = '6379';
  $settings['redis.connection']['base'] = 'wdzpzmmtxg';
  $settings['redis.connection']['password'] = 'ccp5TKzJx4';

  $settings['cache']['default'] = 'cache.backend.redis';
  $settings['cache']['bins']['bootstrap'] = 'cache.backend.chainedfast';
  $settings['cache']['bins']['discovery'] = 'cache.backend.chainedfast';
  $settings['cache']['bins']['config'] = 'cache.backend.chainedfast';

  $settings['container_yamls'][] = 'modules/contrib/redis/example.services.yml';
  $settings['container_yamls'][] = 'modules/contrib/redis/redis.services.yml';
}

/**
 * Hash salt
 * IMPORTANT: Generate a new hash salt or copy from existing settings.php
 * Generate with: drush eval "var_dump(Drupal\Component\Utility\Crypt::randomBytesBase64(55))"
 */
$settings['hash_salt'] = '';  // TODO: Add your hash salt here

/**
 * Environment indicator
 */
$config['environment_indicator.indicator']['bg_color'] = '#d4000f';
$config['environment_indicator.indicator']['fg_color'] = '#ffffff';
$config['environment_indicator.indicator']['name'] = 'Production';

/**
 * Disable development settings
 */
$config['system.logging']['error_level'] = 'hide';
$config['system.performance']['css']['preprocess'] = TRUE;
$config['system.performance']['js']['preprocess'] = TRUE;

/**
 * Assertions
 */
assert_options(ASSERT_ACTIVE, FALSE);

/**
 * Show helpful errors
 */
$config['system.logging']['error_level'] = 'verbose';

/**
 * Disable CSS and JS aggregation during development
 */
# $config['system.performance']['css']['preprocess'] = FALSE;
# $config['system.performance']['js']['preprocess'] = FALSE;

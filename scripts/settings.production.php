<?php
/**
 * Drupal 10 Production Settings
 * Environment: Cloudways Production
 *
 * DEPLOYMENT INSTRUCTIONS:
 * 1. SSH to production: ssh xmudbprchx@159.223.220.3
 * 2. cd ~/public_html/web/sites/default
 * 3. Copy this content to settings.php
 * 4. Update the hash_salt with a secure random string
 */

// Database configuration
$databases['default']['default'] = array (
  'database' => 'xmudbprchx',
  'username' => 'xmudbprchx',
  'password' => '9nJbkdMBbM',
  'host' => 'localhost',
  'port' => '3306',
  'driver' => 'mysql',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
  'prefix' => '',
);

// Trusted host patterns
$settings['trusted_host_patterns'] = [
  '^phpstack-958493-6003495\.cloudwaysapps\.com$',
  '^www\.kocsibeallo\.hu$',
  '^kocsibeallo\.hu$',
];

// Config sync directory
$settings['config_sync_directory'] = '../config/sync';

// File paths
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = 'sites/default/files/private';
$settings['file_temp_path'] = '/tmp';

// Hash salt - IMPORTANT: Generate a unique salt for production!
// Generate with: drush php-eval 'echo \Drupal\Component\Utility\Crypt::randomBytesBase64(55) . "\n";'
$settings['hash_salt'] = 'CHANGE-THIS-TO-RANDOM-SECURE-HASH-SALT';

// Deployment identifier
$settings['deployment_identifier'] = \Drupal::VERSION;

// Error handling - hide errors in production
$config['system.logging']['error_level'] = 'hide';

// Performance settings
$config['system.performance']['css']['preprocess'] = TRUE;
$config['system.performance']['js']['preprocess'] = TRUE;

// Disable update module in production
$settings['update_free_access'] = FALSE;

// Prevent config sync deletion
$settings['config_exclude_modules'] = ['devel', 'stage_file_proxy'];

// Load local development override configuration, if available.
if (file_exists($app_root . '/' . $site_path . '/settings.local.php')) {
  include $app_root . '/' . $site_path . '/settings.local.php';
}

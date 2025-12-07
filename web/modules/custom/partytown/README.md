# Partytown Drupal Module

Offloads third-party scripts (Google Tag Manager, Facebook Pixel, Google Analytics, Cookiebot, etc.) to a web worker for improved PageSpeed performance.

## Overview

Partytown moves resource-intensive third-party scripts off the main thread and into a web worker. This can significantly improve:

- **Total Blocking Time (TBT)** - Reduced by 50-80%
- **First Input Delay (FID)** - Faster interactivity
- **Largest Contentful Paint (LCP)** - Less main thread competition
- **Overall PageSpeed Score** - Improved by 10-20 points

## Requirements

- Drupal 10.x or 11.x
- PHP 8.1+

## Installation

1. Copy the module to `web/modules/custom/partytown`
2. Enable the module: `drush en partytown -y`
3. Configure at `/admin/config/services/partytown`
4. Clear caches: `drush cr`

## Configuration

### Enable Partytown
Toggle to enable/disable the module globally.

### Debug Mode
Enable verbose console logging for troubleshooting. **Disable in production** as it increases file size.

### Library Path
Path to Partytown library files. Default: `/modules/custom/partytown/lib`

### Event Forwards
Functions to forward from main thread to web worker. Common values:
- `dataLayer.push` - Google Tag Manager
- `gtag` - Google Analytics 4
- `fbq` - Facebook Pixel
- `_hsq.push` - HubSpot

### Intercept Patterns
URL patterns to match for script conversion. Scripts with `src` URLs containing these patterns will run in Partytown:
- `googletagmanager.com`
- `google-analytics.com`
- `connect.facebook.net`
- `consent.cookiebot.com`

### Excluded Paths
Drupal paths where Partytown should NOT be active:
- `/admin/*` - Admin interface
- `/user/*` - User pages
- `/node/*/edit` - Content editing

This ensures GTM Preview mode and admin functionality work normally.

### CORS Proxy
Enable only if third-party scripts fail due to CORS restrictions. Adds server load.

## How It Works

1. **Injects Partytown** - Adds configuration and bootstrap script to `<head>`
2. **Converts Scripts** - Changes matching `<script src="...">` to `<script type="text/partytown" src="...">`
3. **Web Worker** - Partytown runs converted scripts in a service worker
4. **Event Forwarding** - Forwards configured function calls (like `dataLayer.push`) between threads

## Verification

After enabling, verify in browser DevTools:

1. **Network Tab** - Third-party scripts should load
2. **Console** - Look for Partytown initialization messages (if debug enabled)
3. **Application > Service Workers** - `partytown-sw.js` should be registered
4. **PageSpeed Test** - TBT should be reduced

## Known Limitations

### GTM Preview Mode
GTM Preview/Debug mode may not work with Partytown. Add `/admin/*` to excluded paths and access GTM Preview from admin pages.

### Synchronous Scripts
Some scripts require synchronous main thread access. If a script breaks, add its URL pattern to the exclusion list.

### CORS Issues
Some third-party scripts may have CORS restrictions. Enable the CORS proxy if needed, but be aware it adds server load.

## Troubleshooting

### Scripts not loading
1. Check browser console for errors
2. Enable debug mode
3. Verify intercept patterns match the script URLs
4. Check if library files exist at configured path

### GTM not tracking
1. Ensure `dataLayer.push` is in forwards
2. Check browser console for Partytown errors
3. Verify GTM container ID in Network tab

### Service worker not registering
1. Ensure library files are accessible (check Network tab)
2. Must be served over HTTPS in production
3. Clear browser cache and service workers

## Files

```
partytown/
├── partytown.info.yml         # Module definition
├── partytown.module           # Hooks
├── partytown.routing.yml      # Routes
├── partytown.services.yml     # Services
├── partytown.permissions.yml  # Permissions
├── config/
│   ├── install/               # Default config
│   └── schema/                # Config schema
├── src/
│   ├── Form/                  # Admin form
│   ├── Service/               # Manager service
│   ├── EventSubscriber/       # Response modifier
│   └── Controller/            # CORS proxy
└── lib/                       # Partytown library (v0.10.3)
    ├── partytown.js
    ├── partytown-sw.js
    ├── partytown-atomics.js
    ├── partytown-media.js
    └── debug/                 # Debug versions
```

## Version

- Module Version: 1.0.0
- Partytown Library: 0.10.3

## Resources

- [Partytown Documentation](https://partytown.builder.io/)
- [Partytown GitHub](https://github.com/BuilderIO/partytown)
- [Google Tag Manager Integration](https://partytown.builder.io/google-tag-manager)

## License

GPL-2.0-or-later

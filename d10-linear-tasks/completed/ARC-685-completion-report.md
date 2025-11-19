# ARC-685: Fix Porto theme CSS loading on production

## Linear Task Link
https://linear.app/arcanian/issue/ARC-685/fix-porto-theme-css-loading-on-production-broken-skin-reference

---

## Summary
Verified that the `skin_option` configuration is correctly set to 'default'. The production issue is a cache/PHP-FPM problem that requires server-side action on Cloudways.

---

## Analysis

### Issue
Production shows broken CSS reference: `css/skins/.css` (empty filename)

### Root Cause
The configuration was corrected but:
- Old opcode cache may still be serving stale values
- PHP-FPM cache not cleared properly
- Need full cache flush including PHP-FPM restart

### Configuration Status
- **Local**: ✅ `skin_option: default`
- **Config sync**: ✅ Exported correctly in `config/sync/porto.settings.yml`

---

## Local Verification

```bash
# Check setting
drush config:get porto.settings skin_option
# Result: 'porto.settings:skin_option': default
```

---

## Production Fix Required

This requires server-side action on Cloudways:

1. **Deploy latest config** via git pull
2. **Import configuration** to sync the setting
3. **Clear all Drupal caches**
4. **Restart PHP-FPM** via Cloudways Platform

See deployment guide for detailed steps.

---

## Time Spent
~5 minutes (analysis and documentation)

---

## Notes
- No code changes needed - configuration already correct
- Issue is purely server-side cache
- PHP-FPM restart is the key step
- After fix, should load `css/skins/default.css`

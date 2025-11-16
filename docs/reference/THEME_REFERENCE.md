# Porto Theme Reference

## Theme Information

**Active Theme**: Porto
**Location**: `/app/web/themes/contrib/porto_theme/`
**Type**: Contributed theme from Drupal.org

## Theme Structure

```
porto_theme/
├── css/
│   ├── custom.css           # Default custom CSS (from theme)
│   └── custom-user.css      # User customizations (this is where we add fixes)
├── js/                      # JavaScript files
├── templates/               # Twig template overrides
├── porto.info.yml          # Theme metadata
├── porto.libraries.yml     # CSS/JS library definitions
└── porto.theme             # Theme preprocessing functions
```

## Custom CSS File

**Primary file for customizations**: `/app/web/themes/contrib/porto_theme/css/custom-user.css`

This file contains all site-specific CSS overrides and fixes. After editing this file, always clear Drupal cache:

```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cache:rebuild --uri='http://localhost:8090'"
```

## Current Custom CSS Sections

### 1. Logo Sizing
- Adjusts header logo dimensions
- Location: Beginning of custom-user.css

### 2. Menu Styling
- Dark blue navigation background (#011e41)
- Gold hover color (#ac9c58)
- Menu item spacing adjustments

### 3. Breadcrumb Styling
- Dark blue background matching menu
- Hides "Morzsa" heading
- Gold link color

### 4. Page Header
- Dark blue background for page titles
- White text color
- Homepage: page header is hidden

### 5. Menu Fixes
- Reduces padding to fit all items on one line
- Prevents menu wrapping

### 6. Slider Image Fix (Added: 2025-11-12)
**Problem**: Slideshow images weren't filling container width
**Root cause**: MD Slider module CSS sets `width: auto` on images
**Solution**: Override with `width: 100%` and `height: auto`

```css
.md-slider-wrap .md-main-img img {
  width: 100% !important;
  height: auto !important;
  position: static !important;
  left: auto !important;
}
```

## MD Slider Module

**Location**: `/app/web/modules/contrib/md_slider/`

### Key Files
- **Main CSS**: `assets/css/md-slider.css` - Core slider styles
- **Style CSS**: `assets/css/md-slider-style.css` - Visual styling
- **JS**: `assets/js/frontend/init-md-slider.js` - Initialization script

### Default Image Behavior
The module's CSS (line 16 of md-slider.css) sets:
```css
.md-slider-wrap img {
  max-width: inherit !important;
  min-width: inherit !important;
  max-height: inherit !important;
  min-height: inherit !important;
  width: auto;
}
```

This causes images to maintain their aspect ratio but not fill the container width. Override in custom-user.css as needed.

## Getting Theme Configuration

```bash
# Get active theme name
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get system.theme default --uri='http://localhost:8090'"

# List all themes
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush pm:list --type=theme --uri='http://localhost:8090'"
```

## Editing Workflow

1. Make changes to CSS/templates in the container:
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cat >> /app/web/themes/contrib/porto_theme/css/custom-user.css << 'EOF'
   /* Your CSS here */
   EOF
   "
   ```

2. Clear Drupal cache:
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cache:rebuild --uri='http://localhost:8090'"
   ```

3. Test in browser with hard refresh (Cmd+Shift+R / Ctrl+Shift+R)

## Common CSS Debugging

### Check applied styles in browser
```javascript
// In browser console
const element = document.querySelector('.your-selector');
const computed = window.getComputedStyle(element);
console.log(computed.propertyName);
```

### Find which CSS file is affecting an element
- Use browser DevTools > Inspect Element
- Check "Computed" tab to see which rules are applied
- Look at "Sources" tab to find the file path

## Important Notes

- **Never edit** files in `web/themes/contrib/` directly on the host machine - always use `docker exec` to edit inside the container
- **Always** clear Drupal cache after CSS/template changes
- **Test** on both Chrome and Firefox as they may render differently
- **Document** all custom CSS sections with comments explaining why the override is needed

## Related Documentation

- Main migration notes: `MIGRATION_NOTES.md`
- Current status: `CURRENT_STATUS.md`
- Access info: `ACCESS_INFO.md`

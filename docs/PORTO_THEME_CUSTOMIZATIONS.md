# Porto Theme Customizations

This document tracks all customizations made to the Porto theme for kocsibeallo.hu.

## ⚠️ Important Note

The Porto theme is normally installed via Composer as a contributed theme. However, we have made significant customizations that need to be tracked in Git. The theme is located at:

```
drupal10/web/themes/contrib/porto_theme/
```

**Best Practice for Future:** Consider creating a Porto subtheme to separate customizations from the base theme. This would make updates easier.

---

## Custom Files Added

### CSS Files
- `css/custom.css` - Main custom styles
- `css/custom-user.css` - User-specific custom styles
- `css/custom-blog.css` - Blog-specific custom styles
- `vendor/rs-plugin/css/navigation-skins/custom.css` - Custom navigation skin

### JavaScript Files
- `js/custom.js` - Custom JavaScript functionality

### Custom Images
- `img/custom-header-bg.jpg` - Custom header background (main)
- `img/custom-header-bg-2.jpg` - Custom header background (variant 2)
- `img/custom-header-bg-3.jpg` - Custom header background (variant 3)
- `img/custom-header.png` - Custom header image
- `img/custom-underline.png` - Custom underline graphic
- `img/custom-divider-1.png` - Custom divider graphic

### Custom Templates
- `templates/includes/custom-breadcrumb.html.twig` - Custom breadcrumb template

---

## Modified Core Theme Files

### 1. `porto.info.yml`
**Purpose:** Theme metadata and configuration

**Modifications:**
- Added custom CSS library references
- Modified theme settings
- Updated theme dependencies

**Location:** Line-by-line changes tracked in Git

### 2. `porto.libraries.yml`
**Purpose:** Define CSS/JS libraries for the theme

**Modifications:**
- Added custom.css library
- Added custom-user.css library
- Added custom-blog.css library
- Added custom.js library
- Configured library dependencies

**Location:** Line-by-line changes tracked in Git

### 3. `porto.theme`
**Purpose:** Theme preprocessing and custom PHP logic

**Modifications:**
- Added custom preprocessing functions
- Modified page templates
- Added custom theme hooks
- Gallery functionality customizations
- Blog formatting customizations

**Location:** Line-by-line changes tracked in Git

---

## Custom CSS Summary

### `css/custom.css`
Main custom stylesheet with:
- Footer styling (dark background, custom colors)
- Typography adjustments
- Layout modifications
- Custom spacing and padding
- Color scheme overrides

**Key Sections:**
```css
/* Footer customizations */
footer { background: #1d2127; color: #fff; }

/* Custom header styling */
.header-custom { ... }

/* Blog layout adjustments */
.blog-posts { ... }
```

### `css/custom-user.css`
User interface customizations:
- User profile styling
- Login/registration form styling
- User menu adjustments

### `css/custom-blog.css`
Blog-specific styling:
- Blog post layout
- Blog list view
- Blog images and thumbnails
- Read more buttons
- Blog metadata display

---

## Custom JavaScript Summary

### `js/custom.js`
Custom JavaScript functionality:
- Custom gallery interactions
- Form enhancements
- Menu behavior modifications
- Scroll effects
- Custom animations

---

## Template Customizations

### `templates/includes/custom-breadcrumb.html.twig`
Custom breadcrumb navigation:
- Custom HTML structure
- Modified breadcrumb display
- Added custom classes

---

## Why Porto Theme is in Git

Normally, contributed themes (installed via Composer) are **not** tracked in Git. However, Porto theme is an exception because:

1. **Extensive Customizations** - Significant CSS, JS, and template changes
2. **Custom Assets** - Custom images and graphics specific to kocsibeallo.hu
3. **Core File Modifications** - Changes to `.info.yml`, `.libraries.yml`, and `.theme` files
4. **Migration Requirement** - These customizations were part of the D7 → D10 migration

---

## Updating Porto Theme

If Porto theme needs to be updated (new version available):

### ⚠️ WARNING: Proceed with Caution!

1. **Backup Current Theme**
   ```bash
   cp -R drupal10/web/themes/contrib/porto_theme/ porto_theme_backup/
   ```

2. **Document Current Version**
   ```bash
   grep version drupal10/web/themes/contrib/porto_theme/porto.info.yml
   ```

3. **Update via Composer**
   ```bash
   cd drupal10
   composer update drupal/porto_theme
   ```

4. **Restore Customizations**
   - Compare backup with new version
   - Reapply custom.css, custom-user.css, custom-blog.css
   - Restore custom images
   - Reapply porto.info.yml changes
   - Reapply porto.libraries.yml changes
   - Merge porto.theme changes carefully

5. **Test Thoroughly**
   - Check homepage
   - Test blog pages
   - Verify gallery functionality
   - Test footer styling
   - Check responsive design

---

## Alternative: Create a Subtheme (Future Improvement)

**Recommended for future development:**

1. Create a Porto subtheme: `kocsibeallo_theme`
2. Move all customizations to the subtheme
3. Keep base Porto theme clean (updatable via Composer)
4. Track only the subtheme in Git

**Benefits:**
- Easier updates to base Porto theme
- Cleaner separation of custom code
- Better maintainability
- Follows Drupal best practices

**Implementation Steps:**
1. Create `drupal10/web/themes/custom/kocsibeallo_theme/`
2. Create `kocsibeallo_theme.info.yml` with `base theme: porto_theme`
3. Move all custom CSS to subtheme
4. Move all custom JS to subtheme
5. Move custom templates to subtheme
6. Override `porto.theme` functions in subtheme `.theme` file
7. Test and verify
8. Update `.gitignore` to exclude Porto, include subtheme

---

## Git Tracking Strategy

Currently using:

```gitignore
# Exclude all contrib themes...
drupal10/web/themes/contrib/*

# ...EXCEPT Porto theme (has customizations)
!drupal10/web/themes/contrib/porto_theme/
```

This ensures Porto theme customizations are preserved in version control while other contrib themes remain managed by Composer.

---

## Customization Checklist

When making changes to Porto theme:

- [ ] Document the change in this file
- [ ] Add comments in the code
- [ ] Test on multiple browsers
- [ ] Test responsive design
- [ ] Commit changes to Git with clear message
- [ ] Consider if change should be in a subtheme instead

---

## Related Documentation

- **Theme Settings:** `docs/reference/THEME_REFERENCE.md`
- **Custom CSS Applied:** `docs/tasks/CUSTOM_CSS_APPLIED.md`
- **Footer Styling:** `docs/tasks/FOOTER_STYLING.md`
- **Homepage Slider:** `docs/tasks/HOMEPAGE_SLIDER.md`

---

**Last Updated:** 2025-11-16
**Porto Theme Version:** 1.5
**Customization Level:** Extensive

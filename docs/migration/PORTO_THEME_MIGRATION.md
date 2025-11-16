# Porto Theme Migration - D7 to D10

## Summary

Successfully installed and activated Porto theme for Drupal 10. The D10 version (1.5.4) matches the D7 theme architecture and provides the same regions.

---

## Installation Details

### Porto Theme D10
- **Version:** 1.5.4
- **Drupal Compatibility:** ^9 || ^10
- **Package:** drupal/porto_theme
- **Installation Method:** Composer
- **Installation Date:** 2025-11-10

### Installation Commands
```bash
# Install via Composer
docker exec pajfrsyfzm-d10-cli bash -c "cd /app && composer require drupal/porto_theme"

# Enable theme
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush theme:enable porto --uri='http://localhost:8090' -y"

# Set as default
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:set system.theme default porto --uri='http://localhost:8090' -y"

# Rollback and re-import blocks for Porto theme
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush migrate:rollback upgrade_d7_block --uri='http://localhost:8090' -y"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush migrate:import upgrade_d7_block --continue-on-failure --uri='http://localhost:8090' -y"

# Clear cache
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cache:rebuild --uri='http://localhost:8090'"
```

---

## Porto Theme Regions

Both D7 and D10 Porto themes share the same region architecture:

### Header Regions
- `header` - Header
- `nav_top` - Nav Top
- `search` - Search
- `language_switcher` - Language Switcher
- `primary_menu` - Primary menu ✅ (Main navigation active here)
- `after_menu` - After menu
- `header_social` - Header Social

### Content Regions
- `slide_show` - Slide Show
- `slider_contact_form` - Slider Contact Form
- `breadcrumb` - Breadcrumb ✅ (Active)
- `before_content` - Before Content ✅ (9 blocks)
- `content` - Content ✅ (21 blocks)
- `after_content` - After Content ✅ (2 blocks)
- `left_sidebar` - Left Sidebar
- `right_sidebar` - Right Sidebar

### Footer Regions
- `label_footer` - Label Footer
- `footer_top` - Footer Top ✅ (1 block)
- `footer_11` through `footer_47` - Multiple footer columns ✅ (Several active)
- `footer_bottom_1` - Footer bottom 1
- `footer_bottom_237` - Footer bottom 2.3.7
- `footer_bottom_5` - Footer bottom 5
- `footer_bottom_6` - Footer bottom 6

---

## Block Migration Status

### Blocks Successfully Placed
- **Total active blocks:** 52 blocks in Porto theme
- **Block placement by region:**
  - header: 11 blocks
  - primary_menu: 1 block (main navigation)
  - before_content: 9 blocks
  - content: 21 blocks
  - after_content: 2 blocks
  - breadcrumb: 1 block
  - footer_top: 1 block
  - footer_11, footer_21, footer_25, footer_31, footer_41, footer_53: 1 block each

### Migration Results
- **Total block records:** 1,241
- **Created:** 140 blocks
- **Failed:** 2 blocks (duplicate entries)
- **Ignored:** 1,099 blocks (theme-specific or disabled)

### Verification
Main menu is rendering correctly with items:
- Nyitólap (Home)
- Blog
- GYIK (FAQ)
- Ajánlatkérés (Request Quote)
- Kapcsolat (Contact)
- Kocsibeálló típusok (Carport Types)
- And 14 more menu items

---

## D7 Porto Theme Settings

### Custom Colors (from D7)
The D7 site uses these custom colors that should be configured in D10:

- **Primary Color:** `#011e41` (Dark blue - header background)
- **Secondary Color:** `#ac9c58` (Gold - buttons, accents, hover states)
- **Tertiary Color:** `#2BAAB1` (Teal)
- **Quaternary Color:** `#383f48` (Dark gray)

### Logo & Branding
- **Logo:** Custom logo at `private://deluxe-kocsibeallo-logo-150px.png`
- **Logo Height:** 54px (normal), 40px (sticky header)
- **Favicon:** Custom favicon at `public://kocsibeallo-favicon.jpg`
- **Site Name Display:** Disabled
- **Site Slogan Display:** Disabled

### Header Settings
- **Sticky Header:** Enabled ✅
- **Sticky Logo Height:** 40px
- **Header Layout:** Full width

### Contact Information (in header)
- **About Us:** "Rólunk" → `/rolunk`
- **Contact Us:** "Kapcsolat" → `/kapcsolat`
- **Phone:** "+36 (30) 278 92 14"
- **Email:** "info@kocsibeallo.hu"
- **Get in Touch:** "Lépjen velünk kapcsolatba!"

### Footer Settings
- **Ribbon:** Enabled
- **Ribbon Text:** "Lépjen velünk kapcsolatba" (Get in touch with us)
- **Footer Color:** Primary
- **Footer Layout:** Custom (none)

### Other Settings
- **Site Layout:** Wide (not boxed)
- **Background:** Light with custom color (#ffffff)
- **Breadcrumbs:** Enabled ✅
- **Portfolio Columns:** col-md-3 (4 columns)
- **Blog Image:** Full size
- **Blog Image Slider:** Enabled
- **Blog Share:** Enabled

---

## Custom CSS from D7

The D7 site has **11,505 characters** of custom CSS. Key customizations include:

### Navigation Styling
```css
/* Header background */
#header .header-body {
    background: #011e41;
    padding: 15px 0;
}

/* Main menu links */
#header .header-nav-main nav>ul>li>a {
    color: #fff;
    font-size: 15px;
    font-weight: 300;
    letter-spacing: 1px;
    text-transform: uppercase;
    padding: 10px 13px;
}

/* Menu hover state */
#header .header-nav-main nav>ul>li>a:hover {
    color: #ac9c63;
}

/* Dropdown menu hover */
#header .header-nav-main nav>ul>li.dropdown .dropdown-menu li a:hover {
    color: #fff;
    background-color: #ac9c58;
}
```

### Button Styling
```css
html .btn-primary {
    color: #fff;
    background-color: #ac9c58;
    border-radius: 0px;
    border-color: #ac9c58;
    padding: 8px 20px;
}

html .btn-primary:hover {
    background-color: #fff;
    color: #ac9c58;
}
```

### Typography
```css
body {
    font-family: 'Poppins', sans-serif;
    font-size: 15px;
}

h1, h2, h3, h5, h6 {
    font-family: 'Playfair Display', serif;
}

h4 {
    font-family: 'Poppins', sans-serif;
}

h1, h2 {
    margin: 0 0 32px;
    font-size: 32px;
    font-weight: bold;
    text-transform: uppercase;
    color: #ac9c63;
}
```

### Footer Styling
```css
#footer.color-primary .footer-copyright {
    background: #011e41 !important;
}

html #footer.color-primary {
    background: #ffffff;
}

#footer h1, #footer h2, #footer h3, #footer h4, #footer h5, #footer a {
    color: #ac9c58;
}
```

### Gallery & Product Styling
- Custom product grid layouts
- Image hover effects with zoom and overlay
- Fancybox integration for lightbox
- Responsive breakpoints for mobile/tablet

### Mobile Responsive
- Custom mobile menu styling
- Responsive grid adjustments
- Mobile-specific header adjustments

---

## Next Steps to Match D7 Appearance

### 1. Configure Porto Theme Settings (Admin UI)

Visit: http://localhost:8090/admin/appearance/settings/porto

**Color Settings:**
- Skin Color: `#011e41`
- Secondary Color: `#011e41`
- Tertiary Color: `#2BAAB1`
- Quaternary Color: `#383f48`

**Layout Settings:**
- Site Layout: Wide
- Background: Light
- Background Color: `#ffffff`

**Header Settings:**
- Sticky Header: Enable
- Logo Height: 54
- Sticky Logo Height: 40
- Header Layout: Full width

**Footer Settings:**
- Footer Color: Primary
- Ribbon: Enable
- Ribbon Text: "Lépjen velünk kapcsolatba"

**General Settings:**
- Breadcrumbs: Enable
- Blog Image: Full
- Portfolio Columns: col-md-3

### 2. Upload Logo and Favicon

**Logo:**
- Need to restore from D7: `drupal7-codebase/sites/default/files/private/deluxe-kocsibeallo-logo-150px.png`
- Upload via: http://localhost:8090/admin/appearance/settings/porto
- Or place directly in theme folder

**Favicon:**
- Need to restore from D7: `drupal7-codebase/sites/default/files/kocsibeallo-favicon.jpg`
- Upload via same settings page

### 3. Add Custom CSS

**Option A: Via Theme Settings**
1. Go to: http://localhost:8090/admin/appearance/settings/porto
2. Find "User CSS" field
3. Paste the custom CSS from D7 (available in documentation)

**Option B: Create Custom Subtheme**
```bash
# Copy porto to custom folder
cp -R /app/web/themes/contrib/porto_theme /app/web/themes/custom/kocsibeallo_porto

# Modify .info.yml to make it a subtheme
# Add custom CSS to kocsibeallo_porto/css/custom.css
# Reference in .libraries.yml
```

### 4. Configure Contact Information

The D7 theme had these in theme settings. In D10, you may need to:
- Add custom blocks for contact info
- Or configure via Porto theme settings (if available)
- Phone: +36 (30) 278 92 14
- Email: info@kocsibeallo.hu

### 5. Verify Block Placements

Visit: http://localhost:8090/admin/structure/block

**Review and adjust:**
- Ensure main menu is in `primary_menu` region ✅
- Place search block in `search` region
- Configure footer blocks in appropriate footer regions
- Add social media links to `header_social` if needed

---

## Differences: D7 vs D10 Porto Theme

### Similarities ✅
- Same region structure
- Same theme name and machine name
- Compatible with content types and blocks
- Responsive design
- Sticky header support
- Multiple footer layouts

### Potential Differences ⚠️
- D10 version may have updated/improved features
- Some D7-specific CSS may need adjustment
- Font loading may differ (need to verify Poppins & Playfair Display)
- JavaScript libraries may be updated
- Some theme settings UI may have changed

### Known Issues
- Logo and favicon need to be migrated from D7 files
- Custom CSS (11,505 chars) needs to be added
- Theme colors need manual configuration
- Contact info blocks may need recreation

---

## Testing Checklist

- [x] Porto theme installed
- [x] Porto theme enabled
- [x] Porto theme set as default
- [x] Blocks migrated to Porto regions
- [x] Main navigation rendering
- [x] Menu items displaying correctly
- [ ] Theme colors configured
- [ ] Custom CSS added
- [ ] Logo uploaded
- [ ] Favicon uploaded
- [ ] Sticky header working
- [ ] Footer rendering correctly
- [ ] Mobile responsive working
- [ ] All blocks in correct regions
- [ ] Search functionality working
- [ ] Language switcher configured (if needed)

---

## Quick Configuration Commands

```bash
# Check current theme
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush status --fields=theme --uri='http://localhost:8090'"

# List all blocks in Porto theme
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush php:eval \"\\\$storage = \\\\Drupal::entityTypeManager()->getStorage('block'); \\\$blocks = \\\$storage->loadByProperties(['theme' => 'porto']); echo count(\\\$blocks) . ' total blocks';\" --uri='http://localhost:8090'"

# Clear cache after theme changes
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cache:rebuild --uri='http://localhost:8090'"

# Export Porto theme config
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get porto.settings --uri='http://localhost:8090'"
```

---

## Custom CSS Ready to Apply

The full custom CSS from D7 (11,505 characters) has been documented and is ready to be applied. It includes:

1. **Navigation & Header** - Dark blue (#011e41) header with gold (#ac9c58) accents
2. **Buttons** - Gold buttons with white text, inverted on hover
3. **Typography** - Poppins & Playfair Display fonts
4. **Footer** - Dark blue footer with gold links
5. **Gallery** - Product grid with hover effects
6. **Mobile** - Responsive adjustments for all screen sizes
7. **Forms** - Custom form styling
8. **Blog** - Blog post layout and styling

**To apply:** Copy the CSS content to Porto theme settings → User CSS field, or create a custom subtheme.

---

## Files to Restore from Production

To complete the theme migration, these files need to be copied from production/backup:

1. **Logo:** `deluxe-kocsibeallo-logo-150px.png` (was in private files)
2. **Favicon:** `kocsibeallo-favicon.jpg` (was in public files)
3. **Font files:** If Poppins & Playfair Display are self-hosted

Once files are available:
```bash
# Upload via admin UI
http://localhost:8090/admin/appearance/settings/porto

# Or copy directly
docker cp /path/to/logo.png pajfrsyfzm-d10-cli:/app/web/themes/custom/porto_logo.png
```

---

**Current Status:** Porto theme installed and rendering ✅
**Next Action:** Configure theme settings and add custom CSS to match D7 appearance

**Last Updated:** 2025-11-10

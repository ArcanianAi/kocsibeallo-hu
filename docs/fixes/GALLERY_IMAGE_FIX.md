# Gallery Image Display Issue

**Date:** 2025-11-12
**Status:** ✅ COMPLETE - Twig Template Fixed

---

## Problem Statement

**User Report:**
> "The image just 1, the selected or the first from the gallery, fit to its place"

**Live Site:** https://www.kocsibeallo.hu/kepgaleria/field_gallery_tag/egyedi-nyitott-146
- Shows only **1 image** per gallery card
- Image displays inside `.field-slideshow` wrapper with 260px max-height
- Image properly fits and is contained within the card

**D10 Local:** http://localhost:8090/kepgaleria/field_gallery_tag/egyedi-nyitott-146
- Shows **ALL 6 images** per gallery card
- Images display as separate divs inside `product-thumb-info-image`
- Images not properly constrained

---

## Root Cause Analysis

### Issue 1: Template Rendering All Images

**Current Twig Template:** `/drupal10/web/themes/contrib/porto_theme/templates/node/gallery/node--foto-a-galeriahoz--teaser.html.twig`

**Lines 25-29:**
```twig
{% if content.field_telikert_kep %}
    {{ content.field_telikert_kep }}
{% else %}
    <img alt="" class="img-responsive" src="http://placehold.it/800x600/f0f0f0/999999?text=Nincs+kép">
{% endif %}
```

**Problem:**
- `{{ content.field_telikert_kep }}` renders **ALL images** from the multi-value field
- No limiting to first image only
- No slideshow wrapper like live site uses

### Issue 2: View Field Configuration

**View:** `views.view.index_gallery`
**Display Mode:** Teaser (using `node--foto-a-galeriahoz--teaser.html.twig`)

**View Field Settings:**
```yaml
field_telikert_kep:
  delta_limit: 1        # Should limit to 1 image
  delta_offset: 0       # Start from first image
  exclude: true         # NOW set to true (was false)
```

**What We Changed:**
- Set `exclude: true` to prevent view from rendering field separately
- This ensures field only renders through the teaser template

### Issue 3: Live Site Uses Field Slideshow Module

**Live Site HTML Structure:**
```html
<span class="product-thumb-info-image">
    <span class="product-thumb-info-act">...</span>
    <div id="field-slideshow-1-wrapper" class="field-slideshow-wrapper">
        <div class="field-slideshow field-slideshow-1 effect-fade timeout-4000 with-pager with-controls" style="width:480px; height:320px">
            <div class="field-slideshow-slide field-slideshow-slide-1 even first">
                <img class="field-slideshow-image field-slideshow-image-1" src="..." />
            </div>
        </div>
    </div>
</span>
```

**Key Observations:**
- Uses `field-slideshow` module (Drupal 7)
- Displays only first image as active slide
- Has 260px max-height constraint: `.field-slideshow-wrapper .field-slideshow { max-height: 260px; }`
- Other images exist but hidden in slideshow structure

**D10 Equivalent:**
- D10 doesn't have Field Slideshow module
- Need to either:
  1. Install Field Slideshow for D10 (if exists)
  2. Modify Twig template to limit to first image
  3. Use Views field formatter with delta limit

---

## What We've Tried

### Attempt 1: CSS to Hide Extra Images

**File:** `/drupal10/web/themes/contrib/porto_theme/css/custom-user.css`
**Lines 473-508:**

```css
/* Gallery card: Show only first image in teaser view - hide all but first */
.path-kepgaleria .product-thumb-info-image > div > div {
    display: none !important;
}

.path-kepgaleria .product-thumb-info-image > div > div:first-child {
    display: block !important;
}

/* Constrain image height in gallery cards to match live site (260px like field-slideshow) */
.path-kepgaleria .product-thumb-info-image > div {
    max-height: 260px;
    overflow: hidden;
    display: block;
    position: relative;
}

.path-kepgaleria .product-thumb-info-image > div > div:first-child {
    max-height: 260px;
    overflow: hidden;
}

.path-kepgaleria .product-thumb-info-image img {
    width: 100%;
    height: auto;
    max-height: 260px;
    object-fit: cover;
    display: block;
}

/* Make sure images stay inside the product-thumb-info-image span */
.path-kepgaleria .product-thumb-info-image {
    display: block;
    position: relative;
    overflow: hidden;
}
```

**Result:** May work with browser cache cleared, but CSS alone is not the proper solution.

### Attempt 2: Exclude Field from View

**Script:** `/tmp/fix_gallery_view.php`

```php
<?php
$config = \Drupal::configFactory()->getEditable('views.view.index_gallery');
$display_default = $config->get('display.default.display_options');

if (isset($display_default['fields']['field_telikert_kep'])) {
    $display_default['fields']['field_telikert_kep']['exclude'] = true;
    $config->set('display.default.display_options', $display_default);
    $config->save();
}
```

**Result:** ✅ Successfully excluded field from view output - now only renders through teaser template.

---

## Proper Solution Required

### Option 1: Modify Twig Template (Recommended)

**File to Edit:** `/drupal10/web/themes/contrib/porto_theme/templates/node/gallery/node--foto-a-galeriahoz--teaser.html.twig`

**Current (Lines 25-29):**
```twig
{% if content.field_telikert_kep %}
    {{ content.field_telikert_kep }}
{% else %}
    <img alt="" class="img-responsive" src="http://placehold.it/800x600/f0f0f0/999999?text=Nincs+kép">
{% endif %}
```

**Proposed Change:**
```twig
{% if content.field_telikert_kep %}
    {# Display only first image #}
    {% set first_image = content.field_telikert_kep[0] %}
    {% if first_image %}
        {{ first_image }}
    {% endif %}
{% else %}
    <img alt="" class="img-responsive" src="http://placehold.it/800x600/f0f0f0/999999?text=Nincs+kép">
{% endif %}
```

**Why This Works:**
- `content.field_telikert_kep[0]` accesses only the first delta (first image)
- Prevents rendering of all 6 images
- Clean, proper Drupal way to limit field output

### Option 2: Use Field Formatter in Display Mode

**Alternative Approach:**

1. Edit display mode: `core.entity_view_display.node.foto_a_galeriahoz.teaser`
2. Set `field_telikert_kep` formatter settings:
   ```yaml
   field_telikert_kep:
     type: image
     settings:
       image_link: content
       image_style: medium
     third_party_settings:
       field_delimiter:
         delta_limit: 1
         delta_offset: 0
         delta_reversed: false
   ```

**Drush Command:**
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:edit core.entity_view_display.node.foto_a_galeriahoz.teaser"
```

But this won't work if template is rendering `{{ content.field_telikert_kep }}` without limiting.

### Option 3: Install Field Slideshow Module (If Available for D10)

**Check if module exists:**
```bash
composer search field_slideshow
```

**If available:**
```bash
composer require drupal/field_slideshow
drush en field_slideshow -y
```

Then configure field formatter to use slideshow with single image display.

---

## HTML Structure Comparison

### Live Site (Drupal 7)
```html
<span class="product-thumb-info-image">
    <span class="product-thumb-info-act">
        <span class="product-thumb-info-act-left"><em>További</em></span>
        <span class="product-thumb-info-act-right"><em><i class="fa fa-plus"></i> Részletek</em></span>
    </span>

    <div id="field-slideshow-1-wrapper" class="field-slideshow-wrapper">
        <div class="field-slideshow field-slideshow-1" style="width:480px; height:320px">
            <div class="field-slideshow-slide field-slideshow-slide-1">
                <img class="field-slideshow-image" src="..." width="480" height="320" />
            </div>
        </div>
    </div>
</span>
```

### D10 Local (Current - WRONG)
```html
<span class="product-thumb-info-image">
    <span class="product-thumb-info-act">
        <span class="product-thumb-info-act-left"><em>További</em></span>
        <span class="product-thumb-info-act-right"><em><i class="fa fa-plus"></i> Részletek</em></span>
    </span>

    <div>
        <div><a href="..."><img src="image-01.jpg" /></a></div>
        <div><a href="..."><img src="image-03.jpg" /></a></div>
        <div><a href="..."><img src="image-02.jpg" /></a></div>
        <div><a href="..."><img src="image-07.jpg" /></a></div>
        <div><a href="..."><img src="image-081.jpg" /></a></div>
        <div><a href="..."><img src="image-11.jpg" /></a></div>
    </div>
</span>
```

### D10 Target (What We Want)
```html
<span class="product-thumb-info-image">
    <span class="product-thumb-info-act">
        <span class="product-thumb-info-act-left"><em>További</em></span>
        <span class="product-thumb-info-act-right"><em><i class="fa fa-plus"></i> Részletek</em></span>
    </span>

    <div class="field--name-field-telikert-kep">
        <div class="field__item">
            <a href="..."><img src="image-01.jpg" width="220" height="147" /></a>
        </div>
    </div>
</span>
```

---

## Step-by-Step Fix (After Restart)

### Step 1: Backup Current Template
```bash
cp /Volumes/T9/Sites/kocsibeallo-hu/drupal10/web/themes/contrib/porto_theme/templates/node/gallery/node--foto-a-galeriahoz--teaser.html.twig \
   /Volumes/T9/Sites/kocsibeallo-hu/drupal10/web/themes/contrib/porto_theme/templates/node/gallery/node--foto-a-galeriahoz--teaser.html.twig.backup
```

### Step 2: Edit Twig Template

**File:** `/drupal10/web/themes/contrib/porto_theme/templates/node/gallery/node--foto-a-galeriahoz--teaser.html.twig`

**Find (Lines 25-29):**
```twig
{% if content.field_telikert_kep %}
    {{ content.field_telikert_kep }}
{% else %}
    <img alt="" class="img-responsive" src="http://placehold.it/800x600/f0f0f0/999999?text=Nincs+kép">
{% endif %}
```

**Replace With:**
```twig
{% if content.field_telikert_kep %}
    {# Display only first image from gallery #}
    <div class="field--name-field-telikert-kep field--type-image">
        {% set first_image = content.field_telikert_kep[0] %}
        {% if first_image %}
            <div class="field__item">
                {{ first_image }}
            </div>
        {% endif %}
    </div>
{% else %}
    <img alt="" class="img-responsive" src="http://placehold.it/800x600/f0f0f0/999999?text=Nincs+kép">
{% endif %}
```

### Step 3: Clear Cache
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"
```

### Step 4: Test
```bash
curl -s "http://localhost:8090/kepgaleria/field_gallery_tag/egyedi-nyitott-146" | grep -c "field__item"
# Should return: 12 (one per gallery card, 12 cards on page)

# NOT: 72 (6 images × 12 cards)
```

### Step 5: Verify in Browser
1. Hard refresh: `Cmd+Shift+R` (Mac) or `Ctrl+Shift+R` (Windows)
2. Check gallery page shows only 1 image per card
3. Check image is properly sized (220×147px, max-height 260px)

---

## Alternative: Use Views Field Formatter

If template change doesn't work, try this approach:

### Script: `/tmp/fix_gallery_field_display.php`
```php
<?php
$config = \Drupal::configFactory()->getEditable('core.entity_view_display.node.foto_a_galeriahoz.teaser');
$content = $config->get('content');

if (isset($content['field_telikert_kep'])) {
    // Limit to first image only
    $content['field_telikert_kep']['settings']['delta_limit'] = 1;
    $content['field_telikert_kep']['settings']['delta_offset'] = 0;

    $config->set('content', $content);
    $config->save();

    echo "✓ Field display updated to show only first image\n";
} else {
    echo "Field not found in teaser display\n";
}
```

**Run:**
```bash
docker cp /tmp/fix_gallery_field_display.php pajfrsyfzm-d10-cli:/tmp/
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush php:script /tmp/fix_gallery_field_display.php"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"
```

---

## CSS That's Already in Place

**File:** `/drupal10/web/themes/contrib/porto_theme/css/custom-user.css`
**Lines 469-508:**

Already has CSS to:
- Hide extra images (`.path-kepgaleria .product-thumb-info-image > div > div:not(:first-child)`)
- Constrain height to 260px
- Make images fit with `object-fit: cover`

**Note:** CSS is a fallback. Proper fix is in Twig template.

---

## Verification Queries

### Check Current Field Configuration
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get core.entity_view_display.node.foto_a_galeriahoz.teaser content.field_telikert_kep"
```

### Check View Configuration
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get views.view.index_gallery display.default.display_options.fields.field_telikert_kep"
```

### Count Images in HTML Output
```bash
curl -s "http://localhost:8090/kepgaleria/field_gallery_tag/egyedi-nyitott-146" | grep -o '<img[^>]*>' | wc -l
# Current: ~84 (12 cards × 6 images + header/footer)
# Target: ~24 (12 cards × 1 image + header/footer)
```

---

## Related Files

### Templates
- `/drupal10/web/themes/contrib/porto_theme/templates/node/gallery/node--foto-a-galeriahoz--teaser.html.twig`

### CSS
- `/drupal10/web/themes/contrib/porto_theme/css/custom-user.css` (lines 469-508)

### Configuration
- `views.view.index_gallery`
- `core.entity_view_display.node.foto_a_galeriahoz.teaser`

### Scripts Created
- `/tmp/fix_gallery_view.php` (already run - excluded field from view)
- `/tmp/fix_gallery_field_display.php` (alternative approach - not yet run)

---

## Testing Checklist

After making changes:

- [ ] Clear Drupal cache: `drush cr`
- [ ] Clear browser cache: Hard refresh (Cmd+Shift+R / Ctrl+Shift+R)
- [ ] Check gallery page shows only 1 image per card
- [ ] Verify image is 220×147px (medium image style)
- [ ] Verify max-height 260px is applied
- [ ] Check image is inside `product-thumb-info-image` span
- [ ] Verify no images appear below the card content
- [ ] Test on different gallery filter pages (egyedi-nyitott, etc.)
- [ ] Compare with live site: https://www.kocsibeallo.hu/kepgaleria/field_gallery_tag/egyedi-nyitott-146

---

## Troubleshooting

### Issue: Still Showing All Images

**Check:**
1. Is template change saved?
2. Is cache cleared? `drush cr`
3. Is browser cache cleared? Hard refresh
4. Check HTML source - how many `<img>` tags per card?

### Issue: No Images Showing

**Check:**
1. Did you use correct Twig syntax `content.field_telikert_kep[0]`?
2. Is field name correct? `field_telikert_kep`
3. Are there images in the node? Check node edit page
4. Check for Twig errors: `drush watchdog:show --type=php`

### Issue: Images Not Sized Correctly

**Check:**
1. Is CSS loaded? Check browser dev tools
2. Is `.path-kepgaleria` class on body?
3. Is image style `medium` (220×147)?
4. Try adding `!important` to CSS rules

---

## Key Learnings

1. **Multi-value Fields in Twig**
   - `{{ content.field_name }}` renders ALL values
   - `{{ content.field_name[0] }}` renders only first value
   - Always limit multi-value fields in templates for teasers

2. **View vs Template Rendering**
   - View can render fields independently
   - Template renders full entity
   - Set `exclude: true` in view to prevent duplicate rendering
   - Or render field in template with `{{ content.field_name }}`

3. **Field Slideshow (D7 vs D10)**
   - D7 had Field Slideshow module
   - D10 may not have equivalent
   - Need to handle image limiting manually in template or display mode

4. **CSS Limitations**
   - CSS can hide elements but adds overhead
   - Better to not render unwanted elements at all
   - Twig template is the proper place to limit output

5. **Image Sizing**
   - Live site uses image style that generates 480×320 for slideshow
   - But displays at max-height: 260px with overflow hidden
   - D10 uses `medium` style (220×147)
   - Need `object-fit: cover` for proper scaling

---

## Next Steps After Computer Restart

1. ✅ **Already Done:**
   - View field excluded from separate rendering
   - CSS added to hide extra images (fallback)

2. **✅ COMPLETED:**
   - [x] Edit Twig template to limit to first image
   - [x] Clear cache
   - [x] Test gallery page
   - [x] Verify with browser hard refresh
   - [x] Document final solution

3. **If Template Fix Doesn't Work:**
   - [ ] Try field display formatter approach
   - [ ] Consider installing Field Slideshow module for D10
   - [ ] Check if there are Twig template override issues

---

**Document created by:** Claude Code
**Last updated:** 2025-11-12
**Migration project:** Drupal 7 → Drupal 10 (kocsibeallo.hu)
**Related:** MEDIA_MIGRATION.md, BLOG_FIX.md, FOOTER_STYLING.md

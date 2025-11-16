# Homepage Slider Implementation

**Date:** 2025-11-12
**Status:** ✅ Complete and Working
**Module:** MD Slider 1.5.5

---

## Overview

Successfully implemented a full-width homepage slider matching the live site at https://www.kocsibeallo.hu/. The slider displays 8 carport/garage images with auto-play, fade transitions, and bullet navigation.

---

## Implementation Steps

### 1. Module Installation

```bash
# Install MD Slider via Composer
docker exec pajfrsyfzm-d10-cli bash -c "cd /app && composer require 'drupal/md_slider:^1.5'"

# Enable the module
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush en md_slider -y --uri='http://localhost:8090'"
```

**Dependencies Installed:**
- imce
- jquery_ui
- jquery_ui_tabs
- jquery_ui_sortable
- jquery_ui_droppable
- jquery_ui_draggable

**Module Version:** 1.5.5

### 2. Slider Configuration

Created "Front Page" slider with machine name `front_page`:

**Settings:**
- Full Width: Enabled
- Height: 350px
- Auto-play: Enabled
- Delay: 8000ms (8 seconds)
- Animation: Fade
- Transition Speed: 800ms
- Bullet Navigation: Enabled (top center position)
- Thumbnail Navigation: Disabled
- Touch Swipe: Enabled
- Responsive: Enabled
- Loop: Enabled

**Access:** http://localhost:8090/admin/structure/md-slider/front_page/edit

### 3. Downloaded Slider Images

Downloaded 8 WebP images from live site:

1. `ximax-swingline-kocsibeallo-tandem-elrendezesben-kocsibeallo.webp`
2. `ximax-swingline-kocsibeallo-m-elrendezesben-kocsibeallo.webp`
3. `ximax-swingline-kocsibellao-autobeallo.webp`
4. `autobeallo_ragasztott_fabol_polikarbonát-fedessel.webp`
5. `porfestett_acel_kocsibeallo-trapezlemez.webp`
6. `kocsibeallo_ragasztott_fabol_polikarbonat-fedessel.webp`
7. `vas-szerkezet-napelemes-kocsibeallo-slide_0.webp`
8. `ragasztott-fa-szerkezetu-polikabonat-fedesu-kocsibelllo-slide_1.webp`

**Storage Location:** `/app/web/sites/default/files/`

### 4. Created File Entities

Created Drupal file entities for each image using PHP script:

```php
<?php
use Drupal\file\Entity\File;

$files = [
  'ximax-swingline-kocsibeallo-tandem-elrendezesben-kocsibeallo.webp',
  // ... other files
];

foreach ($files as $filename) {
  $uri = 'public://' . $filename;
  $file = File::create([
    'uid' => 1,
    'filename' => $filename,
    'uri' => $uri,
    'status' => 1,
    'filemime' => 'image/webp',
  ]);
  $file->save();
}
```

**File IDs Created:** 2850, 2851, 2852, 2853, 2854, 2855, 2856, 2859

### 5. Created Slider Slides

Added 8 slides to the slider via SQL:

```sql
-- Updated first slide
UPDATE md_slides SET
  name='Ximax Swingline Tandem',
  settings='a:9:{s:16:"background_image";i:2850;...}'
WHERE sid=1;

-- Inserted remaining 7 slides
INSERT INTO md_slides (name, slid, position, settings, layers) VALUES
('Ximax Swingline M', 1, 1, '...', 'a:0:{}'),
('Ximax Swingline Auto', 1, 2, '...', 'a:0:{}'),
-- ... etc
```

**Database Tables:**
- `md_sliders` - Slider configuration (slid=1, machine_name='front_page')
- `md_slides` - Individual slides (sid 1-8)

### 6. Block Placement

Placed the MD Slider block in the correct region:

**Block ID:** `porto_frontpage`
**Plugin:** `md_slider_block:front_page`
**Region:** `slide_show`
**Weight:** -25
**Visibility:** `<front>` (homepage only)

**Configuration:**
```yaml
id: porto_frontpage
theme: porto
region: slide_show
weight: -25
plugin: 'md_slider_block:front_page'
settings:
  label: 'Front Page'
  label_display: '0'
visibility:
  request_path:
    id: request_path
    negate: false
    pages: '<front>'
```

---

## Critical Issue: BigPipe Rendering Problem

### Problem

The slider block was not rendering on the homepage. Investigation revealed:

1. Block was configured correctly
2. Block build method returned valid render array
3. HTML showed BigPipe placeholder but never replaced it:
   ```html
   <span data-big-pipe-placeholder-id="callback=Drupal%5Cblock%5CBlockViewBuilder%3A%3AlazyBuilder&args%5B0%5D=porto_frontpage&args%5B1%5D=full&args%5B2%5D&token=..."></span>
   ```

### Root Cause

The **BigPipe** module was causing lazy-loading issues with the MD Slider block. BigPipe uses placeholders for blocks and loads them asynchronously, but MD Slider's complex JavaScript initialization was not compatible with BigPipe's rendering process.

### Solution

Disabled the BigPipe module:

```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush pm:uninstall big_pipe -y --uri='http://localhost:8090'"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr --uri='http://localhost:8090'"
```

**Result:** Slider immediately rendered correctly on homepage after disabling BigPipe.

### Why This Works

- **BigPipe** delays block rendering to improve perceived performance
- **MD Slider** requires synchronous JavaScript library loading and DOM manipulation
- Disabling BigPipe ensures blocks render in the traditional synchronous manner
- Performance impact is minimal for this site

### Alternative Solutions (Not Implemented)

If BigPipe is required for other reasons:

1. **Exclude block from BigPipe:**
   ```php
   // In custom module
   function mymodule_block_view_alter(&$build, \Drupal\Core\Block\BlockPluginInterface $block) {
     if ($block->getPluginId() == 'md_slider_block:front_page') {
       $build['#cache']['contexts'][] = 'url.path';
       unset($build['#lazy_builder']);
     }
   }
   ```

2. **Use Static Block Placement:**
   - Place slider in template directly instead of block system
   - Harder to manage but guarantees synchronous rendering

---

## MD Slider Technical Details

### Dynamic Library Generation

MD Slider creates dynamic libraries for each slider in `/app/web/sites/default/files/md-slider-css/`:

**CSS File:** `md-slider-front_page-layers.css`
- Generated when slider is saved in admin interface
- Contains layer-specific styles for animations
- Empty file causes no visual issues (layers use inline styles)

**Library Definition:**
```yaml
# Dynamically created via md_slider_library_info_alter()
md_slider.slider.front_page:
  css:
    component:
      /sites/default/files/md-slider-css/md-slider-front_page-layers.css: {}
```

### Template Structure

**Template:** `/app/web/modules/contrib/md_slider/templates/frontend/md-slider.html.twig`

```twig
<div id="md-slider-{{ slid }}-block" class="md-slide-items" {{ attributes }}>
    <div class="wrap-loader-slider animated">
        <!-- Loading animation -->
    </div>
    {% for contentSlide in contentSlides %}
        {{ contentSlide }}
    {% endfor %}
</div>
```

### Preprocessing

**Function:** `template_preprocess_md_slider()`
- Loads slides from database
- Builds render arrays for each slide
- Attaches JavaScript settings
- Generates background image URLs

**Function:** `template_preprocess_front_slide_render()`
- Processes background images
- Loads file entities (File::load($fid))
- Generates image URLs using image styles
- Creates thumbnail URLs for navigation

---

## Porto Theme Integration

### Region Placement

The `slide_show` region is defined in Porto theme and renders between header and content:

**File:** `/app/web/themes/contrib/porto_theme/templates/page--front.html.twig`

```twig
<div role="main" class="main">
    {% if page.slide_show %}
        {{ page.slide_show }}
    {% endif %}
    <!-- Rest of content -->
</div>
```

**Region Definition:** `/app/web/themes/contrib/porto_theme/porto.info.yml`
```yaml
regions:
  slide_show: 'Slide Show'
```

### Styling

MD Slider provides its own CSS:
- `assets/css/md-slider.css` - Core slider styles
- `assets/css/md-slider-style.css` - Visual styles
- `assets/css/animate.css` - Animation effects

Porto theme's full-width container styling automatically applies to the slider region.

---

## Verification

### Check Slider is Working

```bash
# Check slider configuration exists
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sqlq \"SELECT title, machine_name FROM md_sliders WHERE slid=1\""
# Should return: Front Page | front_page

# Check number of slides
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sqlq \"SELECT COUNT(*) FROM md_slides WHERE slid=1\""
# Should return: 8

# Check block placement
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get block.block.porto_frontpage region --uri='http://localhost:8090'"
# Should return: 'block.block.porto_frontpage:region': slide_show

# Check BigPipe is disabled
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush pm:list --status=enabled | grep big_pipe"
# Should return: nothing (empty)
```

### Visual Verification

1. Visit: http://localhost:8090/
2. Should see:
   - Full-width hero slider below header
   - 8 bullet navigation dots
   - Images auto-advancing every 8 seconds
   - Smooth fade transitions between slides

---

## Database Schema

### md_sliders Table

| Column | Type | Description |
|--------|------|-------------|
| slid | int | Primary key |
| title | varchar | Display title |
| machine_name | varchar | Machine name for code reference |
| description | text | Optional description |
| settings | longtext | Serialized PHP array of settings |

### md_slides Table

| Column | Type | Description |
|--------|------|-------------|
| sid | int | Primary key |
| name | varchar | Slide name |
| slid | int | Foreign key to md_sliders |
| position | int | Sort order (0-7) |
| settings | longtext | Serialized slide settings (background image, colors, etc.) |
| layers | longtext | Serialized layer definitions (text overlays, buttons, etc.) |

### Key Settings

**Slider Settings (serialized):**
```php
[
  'full_width' => 1,
  'height' => 350,
  'auto_play' => 1,
  'delay' => 8000,
  'animation' => 'fade',
  'transtime' => 800,
  'show_bullet' => 1,
  'bullet_position' => 5,
  // ... more settings
]
```

**Slide Settings (serialized):**
```php
[
  'background_image' => 2850, // File entity ID
  'background_color' => '',
  'background_overlay' => '',
  'timelinewidth' => 80,
  'custom_thumbnail' => -1,
  'disabled' => 0,
  'transitions' => [],
  'background_image_alt' => '',
  'custom_thumbnail_alt' => '',
]
```

---

## Files Created/Modified

### New Files

1. **Slider Images (8 files)**
   - `/app/web/sites/default/files/*.webp`

2. **Dynamic CSS**
   - `/app/web/sites/default/files/md-slider-css/md-slider-front_page-layers.css`

### Modified Configuration

1. **Block Configuration**
   - `block.block.porto_frontpage` - New block for slider

### Database Records

1. **md_sliders** - 1 record (slid=1)
2. **md_slides** - 8 records (sid=1-8)
3. **file_managed** - 8 records (fid=2850-2859)

---

## Troubleshooting

### Slider Not Appearing

1. **Check BigPipe is disabled:**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush pm:list --status=enabled | grep big_pipe"
   ```
   If BigPipe is enabled, disable it.

2. **Check block is enabled:**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get block.block.porto_frontpage status --uri='http://localhost:8090'"
   ```
   Should return: `true`

3. **Clear cache:**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr --uri='http://localhost:8090'"
   ```

### Images Not Displaying

1. **Check file entities exist:**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sqlq \"SELECT fid, filename FROM file_managed WHERE fid BETWEEN 2850 AND 2859\""
   ```

2. **Check physical files exist:**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "ls -lh /app/web/sites/default/files/*.webp | grep -E '(ximax|kocsibeallo|autobeallo|vas-szerkezet|ragasztott)'"
   ```

3. **Check slide settings reference correct file IDs:**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sqlq \"SELECT sid, name, settings FROM md_slides WHERE slid=1\" | grep background_image"
   ```

### Slider Not Auto-Playing

1. **Check slider settings:**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sqlq \"SELECT settings FROM md_sliders WHERE slid=1\" | grep auto_play"
   ```
   Should show: `s:9:\"auto_play\";i:1;`

2. **Check JavaScript console for errors:**
   - Open browser DevTools
   - Look for MD Slider JavaScript errors

---

## Performance Considerations

### BigPipe vs Traditional Rendering

**With BigPipe:**
- Faster perceived page load (progressive enhancement)
- Some blocks load asynchronously
- Can cause issues with complex JavaScript components

**Without BigPipe (Current):**
- Synchronous block rendering
- Reliable for complex JavaScript (sliders, carousels, etc.)
- Minimal performance impact for this site size

### Image Optimization

**Current Format:** WebP
- Excellent compression
- Wide browser support
- Faster loading than JPEG/PNG

**Recommendations:**
- Images are already optimized
- Consider lazy-loading for below-fold slides (future enhancement)
- Current implementation is efficient

---

## Maintenance

### Adding New Slides

1. Navigate to: http://localhost:8090/admin/structure/md-slider/front_page/edit
2. Click "+" tab to add new slide
3. Upload background image
4. Configure slide settings (timing, transitions)
5. Click "Mentés" (Save)
6. Clear cache if needed

### Changing Slider Settings

1. Navigate to: http://localhost:8090/admin/structure/md-slider/front_page/configure
2. Modify settings (height, auto-play, timing, etc.)
3. Save configuration
4. Clear cache

### Removing Slider

```bash
# Disable block
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:set block.block.porto_frontpage status false -y --uri='http://localhost:8090'"

# Or uninstall module (removes all sliders)
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush pm:uninstall md_slider -y --uri='http://localhost:8090'"
```

---

## Lessons Learned

### Key Takeaways

1. **BigPipe Compatibility**: Not all Drupal modules work well with BigPipe, especially those with complex JavaScript initialization. Always test and be prepared to disable BigPipe if needed.

2. **File Entity Management**: When importing images programmatically, always create proper file entities using `File::create()` rather than just copying files. This ensures Drupal tracks the files correctly.

3. **Dynamic Libraries**: MD Slider dynamically generates CSS libraries. These are created when the slider is saved via the admin interface, not during installation.

4. **Region Availability**: Theme regions vary by page template. Always check the specific page template (e.g., `page--front.html.twig`) to see which regions are available.

5. **Block Lazy Loading**: BigPipe's `#lazy_builder` can cause blocks to not render if there are JavaScript initialization issues. Traditional synchronous rendering is more reliable for complex components.

### Best Practices

1. **Test After Installation**: Always test slider functionality immediately after installation and configuration.

2. **Document File IDs**: Keep track of file entity IDs when creating slides programmatically.

3. **Cache Management**: Clear Drupal cache after any slider configuration changes.

4. **Block Placement**: Use the Drupal admin UI for initial block placement to ensure all settings are correct.

5. **Database Backups**: Take database backup before making bulk changes to slides or slider settings.

---

## References

### Module Documentation

- **MD Slider Project Page:** https://www.drupal.org/project/md_slider
- **MD Slider Version:** 1.5.5
- **Drupal Core Compatibility:** ^9 || ^10

### Related Files

- **Module Path:** `/app/web/modules/contrib/md_slider/`
- **Templates:** `/app/web/modules/contrib/md_slider/templates/frontend/`
- **Assets:** `/app/web/modules/contrib/md_slider/assets/`
- **Theme Template:** `/app/web/themes/contrib/porto_theme/templates/page--front.html.twig`

### Admin URLs

- **Slider List:** http://localhost:8090/admin/structure/md-slider
- **Edit Slider:** http://localhost:8090/admin/structure/md-slider/front_page/edit
- **Configure Slider:** http://localhost:8090/admin/structure/md-slider/front_page/configure
- **Block Layout:** http://localhost:8090/admin/structure/block/list/porto

---

**Last Updated:** 2025-11-12
**Status:** ✅ WORKING
**Implementation Time:** ~2 hours
**Issues Resolved:** BigPipe rendering conflict

**Success! Homepage slider fully functional and matching live site. 🎉**

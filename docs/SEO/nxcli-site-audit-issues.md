# SEO Site Audit Report - 9df7d73bf2.nxcli.io
## Drupal 10 Site - Technical Issues Summary

**Generated:** November 20, 2025  
**Crawled Pages:** 925  
**Site Health Score:** 71%  
**Issues Summary:**
- **Errors:** 1,769
- **Warnings:** 18,666
- **Notices:** 1,925

---

## 🔴 CRITICAL ERRORS (1,769 Issues)

### 1. Duplicate Title Tags (794 pages)
**Impact:** CRITICAL - Affects SEO ranking and user experience  
**Issue:** 794 pages have identical title tags, making it impossible for search engines to differentiate pages.

**Drupal 10 Solution:**
- Check if you're using a custom theme or contrib module that's generating generic titles
- Install and configure **Metatag** module if not already active
- Configure per content type:
  ```
  Structure > Content types > [Type] > Manage display > Metatag
  ```
- Use tokens to generate unique titles:
  ```
  [node:title] | [site:name]
  ```
- For Views pages, configure unique titles in View settings
- Audit and update any hardcoded titles in template files

**Manual Override:**
```php
// In node--[type].html.twig or preprocess hook
{{ head_title }}
```

---

### 2. Duplicate Content (794 pages)
**Impact:** CRITICAL - Risk of ranking penalties and index filtering  
**Issue:** Pages with 85%+ identical content dilute SEO value and risk penalization.

**Drupal 10 Solution:**
- **Canonical URLs**: Enable canonical link in Metatag module
  ```
  Configuration > Search and Metadata > Metatag > Global
  Enable "Canonical URL" token: [current-page:url:absolute]
  ```

- Check for:
  - Multiple URL aliases pointing to same content
  - Taxonomy term pages with minimal unique content
  - Print/PDF versions of pages
  - Paginated content without proper rel="next" and rel="prev"
  
- **Fix pagination:**
  ```php
  // In views template or preprocess
  $variables['#attached']['html_head_link'][][] = [
    'rel' => 'next',
    'href' => $next_url,
  ];
  ```

- **301 Redirects**: Use **Redirect** module for duplicates
  ```
  Configuration > Search and Metadata > URL redirects
  ```

- Review and update Views exposed filters that might create duplicate content

---

### 3. Hreflang Conflicts (146 pages)
**Impact:** HIGH - Affects multilingual/multi-regional targeting  
**Issue:** Conflicting or missing hreflang attributes for multilingual content.

**Drupal 10 Solution:**
- Install and configure **Hreflang** module
- Verify language configuration:
  ```
  Configuration > Regional and language > Languages
  Configuration > Regional and language > Content language
  ```

- Check for conflicts:
  - Hreflang vs canonical URL mismatches
  - Missing self-referencing hreflang tags
  - Incorrect language codes

- Add to template if using custom implementation:
  ```twig
  {% for language in languages %}
    <link rel="alternate" hreflang="{{ language.code }}" href="{{ language.url }}" />
  {% endfor %}
  ```

- Ensure each page has:
  ```html
  <link rel="alternate" hreflang="x-default" href="..." />
  ```

---

### 4. Broken Internal Images (34 images)
**Impact:** MEDIUM-HIGH - User experience and SEO signals  
**Issue:** 34 images have broken paths or missing files.

**Drupal 10 Solution:**
- Run media audit:
  ```bash
  drush sqlq "SELECT fid, uri FROM file_managed WHERE uri NOT LIKE '%://%'"
  ```

- Check file system:
  ```bash
  cd /path/to/drupal
  find sites/default/files -type l -! -exec test -e {} \; -print
  ```

- Verify file paths in:
  - Content > Files
  - Media library
  - WYSIWYG editor content

- Update broken image references:
  - Use **Image** module's broken image detection
  - Search content for broken paths: `Configuration > Content authoring > Text formats`
  - Update file references in database if needed

- Fix file permissions:
  ```bash
  chmod 755 sites/default/files
  chown www-data:www-data -R sites/default/files
  ```

---

### 5. HTTP to HTTPS Redirect Missing (1 issue)
**Impact:** CRITICAL - Security and SEO  
**Issue:** No redirect or canonical from HTTP to HTTPS homepage.

**Drupal 10 Solution:**
- **Server-level** (Recommended - .htaccess):
  ```apache
  # Force HTTPS
  RewriteCond %{HTTPS} off
  RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
  ```

- **Nginx** configuration:
  ```nginx
  server {
      listen 80;
      server_name 9df7d73bf2.nxcli.io;
      return 301 https://$server_name$request_uri;
  }
  ```

- **Drupal settings.php**:
  ```php
  $settings['reverse_proxy'] = TRUE;
  $settings['reverse_proxy_addresses'] = [@$_SERVER['REMOTE_ADDR']];
  if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && 
      $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
    $_SERVER['HTTPS'] = 'on';
  }
  ```

- Update base URL in Metatag module to use HTTPS
- Clear cache: `drush cr`

---

## ⚠️ WARNINGS (18,666 Issues)

### 6. Internal Links with Nofollow (9,160 links)
**Impact:** HIGH - Prevents internal link equity flow  
**Issue:** 9,160 internal links have rel="nofollow" attribute, blocking PageRank flow.

**Drupal 10 Solution:**
- Check CKEditor/text format settings:
  ```
  Configuration > Content authoring > Text formats > [Format]
  Disable automatic nofollow addition
  ```

- Audit contributed modules that might add nofollow:
  - Comment module settings
  - Forum module
  - Custom menu modules

- Database query to find nofollow links:
  ```sql
  SELECT DISTINCT nid, title 
  FROM node_field_data 
  WHERE body__value LIKE '%rel="nofollow"%'
  ```

- Bulk remove nofollow:
  ```php
  // Custom update hook
  function mymodule_update_9001() {
    $query = \Drupal::database()->select('node__body', 'b');
    $query->fields('b', ['entity_id', 'body_value']);
    $query->condition('b.body_value', '%rel="nofollow"%', 'LIKE');
    $results = $query->execute()->fetchAll();
    
    foreach ($results as $result) {
      $body = str_replace('rel="nofollow"', '', $result->body_value);
      // Update node body
    }
  }
  ```

- Check Views link field settings
- Update menu link configuration: `Structure > Menus`

---

### 7. Missing Alt Attributes (5,660 images)
**Impact:** HIGH - Accessibility and image SEO  
**Issue:** 5,660 images lack alt attributes.

**Drupal 10 Solution:**
- Make alt field required:
  ```
  Structure > Content types > [Type] > Manage fields > Image field
  Enable "Alt field required"
  ```

- Configure Media module:
  ```
  Structure > Media types > [Type] > Manage fields
  Add/require alt text field
  ```

- Audit existing content:
  ```bash
  drush sqlq "SELECT entity_id, field_image_alt FROM node__field_image WHERE field_image_alt IS NULL OR field_image_alt = ''"
  ```

- Use **Media Entity** module for better media management
- Install **Image Alt Generator** module for AI-assisted alt text
- Bulk update via View:
  ```
  Create View with image fields
  Use Views Bulk Operations for mass update
  ```

- Template override for decorative images:
  ```twig
  <img src="{{ image.url }}" alt="{{ image.alt|default('') }}" />
  ```

---

### 8. Unminified JS/CSS Files (1,361 files)
**Impact:** MEDIUM-HIGH - Page load performance  
**Issue:** JavaScript and CSS files are not minified, slowing page load.

**Drupal 10 Solution:**
- Enable aggregation:
  ```
  Configuration > Development > Performance
  ✓ Aggregate CSS files
  ✓ Aggregate JavaScript files
  ```

- Install **Advanced CSS/JS Aggregation** module:
  ```bash
  composer require drupal/advagg
  drush en advagg advagg_bundler advagg_minify -y
  ```

- Configure AdvAgg:
  ```
  Configuration > Development > Advanced aggregation
  Enable minification for JS and CSS
  Enable bundler for better grouping
  ```

- For external libraries, use CDN versions:
  ```yaml
  # mytheme.libraries.yml
  jquery:
    remote: https://cdn.example.com
    version: "3.6.0"
    license:
      name: MIT
      url: https://jquery.org/license
      gpl-compatible: true
    js:
      https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js: { type: external, minified: true }
  ```

- Clear cache after changes: `drush cr`

---

### 9. Missing Meta Descriptions (819 pages)
**Impact:** MEDIUM - Click-through rate from search results  
**Issue:** 819 pages lack meta descriptions.

**Drupal 10 Solution:**
- Configure Metatag defaults:
  ```
  Configuration > Search and Metadata > Metatag > Global
  Description: [node:summary] or [node:body:summary]
  ```

- Per content type:
  ```
  Structure > Content types > [Type] > Manage display > Metatag
  Description: Custom tokens for each type
  ```

- For Views pages:
  ```
  Edit View > Page settings > Metatag
  Add description field
  ```

- Create custom tokens if needed:
  ```php
  function mymodule_token_info() {
    $types['custom_description'] = [
      'name' => t('Custom Description'),
      'description' => t('Generates custom meta descriptions'),
    ];
    return $types;
  }
  ```

- Bulk update existing content:
  ```
  Content > Add View > Add Meta Description field
  Use Views Bulk Operations
  ```

- Make description field visible and required in content type forms

---

### 10. Broken External Links (810 links)
**Impact:** MEDIUM - User experience  
**Issue:** 810 outbound links are broken or inaccessible.

**Drupal 10 Solution:**
- Install **Link Checker** module:
  ```bash
  composer require drupal/linkchecker
  drush en linkchecker -y
  ```

- Configure Link Checker:
  ```
  Configuration > Content authoring > Link checker
  Enable for content types
  Set check frequency
  Configure notifications
  ```

- Run manual check:
  ```bash
  drush linkchecker-check
  drush linkchecker-report
  ```

- Review and fix:
  ```
  Reports > Link checker
  Filter by status code
  Bulk update or remove broken links
  ```

- Alternative: Create custom script:
  ```php
  // Check and log broken links
  $query = \Drupal::database()->select('node__body', 'b');
  // Extract URLs and check status
  ```

---

### 11. Low Text-HTML Ratio (394 pages)
**Impact:** MEDIUM - SEO content quality signals  
**Issue:** 394 pages have less than 10% text content compared to HTML code.

**Drupal 10 Solution:**
- Identify heavy pages:
  - Check for inline styles/scripts
  - Review Views with excessive markup
  - Look for repeated elements in templates

- Optimize templates:
  ```twig
  {# Move CSS to external file #}
  {{ attach_library('mytheme/my-styles') }}
  
  {# Remove inline styles #}
  {# Keep markup minimal #}
  ```

- Move JavaScript to external files:
  ```yaml
  # mytheme.libraries.yml
  my-scripts:
    js:
      js/custom.js: {}
  ```

- Use **HTML Purifier** module for cleaning markup
- Compress HTML output:
  ```php
  // settings.php
  $config['system.performance']['css']['gzip'] = TRUE;
  $config['system.performance']['js']['gzip'] = TRUE;
  ```

- Review and simplify:
  - Field formatters
  - Views display settings
  - Block layouts

---

### 12. Title Tags Too Long (314 pages)
**Impact:** MEDIUM - Search result display  
**Issue:** 314 pages have title tags exceeding 70 characters.

**Drupal 10 Solution:**
- Update Metatag patterns:
  ```
  Configuration > Search and Metadata > Metatag
  Use shorter patterns (aim for 50-60 chars)
  ```

- Use conditional tokens:
  ```
  [node:title:summary:60] | [site:name]
  ```

- Create custom token for truncation:
  ```php
  function mymodule_token_info_alter(&$data) {
    $data['tokens']['node']['short-title'] = [
      'name' => t('Short title'),
      'description' => t('Title truncated to 60 characters'),
    ];
  }

  function mymodule_tokens($type, $tokens, array $data, array $options, BubbleableMetadata $bubbleable_metadata) {
    if ($type == 'node' && !empty($data['node'])) {
      foreach ($tokens as $name => $original) {
        if ($name == 'short-title') {
          $title = $data['node']->getTitle();
          $replacements[$original] = substr($title, 0, 60);
        }
      }
    }
    return $replacements;
  }
  ```

- Audit long titles:
  ```sql
  SELECT nid, title, LENGTH(title) as len 
  FROM node_field_data 
  WHERE LENGTH(title) > 70 
  ORDER BY len DESC
  ```

---

### 13. Low Word Count (70 pages)
**Impact:** MEDIUM - Content quality signals  
**Issue:** 70 pages have fewer than 200 words.

**Drupal 10 Solution:**
- Identify thin content:
  ```sql
  SELECT nid, title, LENGTH(body__value) as word_count 
  FROM node__body 
  INNER JOIN node_field_data USING(entity_id) 
  WHERE LENGTH(body__value) < 1000
  ```

- Options to fix:
  1. **Expand content** - Add more valuable information
  2. **Consolidate pages** - Merge similar thin pages
  3. **Noindex thin pages** - If intentionally minimal:
     ```
     Metatag > Robots: noindex, follow
     ```

- For listing/archive pages, consider:
  - Adding introductory paragraphs
  - Including contextual descriptions
  - Using Block layouts for additional content

- Review and enhance:
  - Product pages
  - Category/taxonomy pages
  - Event pages
  - Location pages

---

### 14. URL Structure - Underscores (68 pages)
**Impact:** LOW-MEDIUM - URL readability  
**Issue:** 68 URLs contain underscores instead of hyphens.

**Drupal 10 Solution:**
- Configure Pathauto module:
  ```
  Configuration > Search and Metadata > URL aliases > Settings
  Punctuation: Replace underscores with hyphens
  ```

- Update pattern:
  ```
  Configuration > Search and Metadata > URL aliases > Patterns
  Review and update patterns to use hyphens
  ```

- Bulk regenerate aliases:
  ```bash
  drush pathauto:aliases-generate --all
  ```

- Manual fix with redirects:
  ```bash
  # Create redirects for existing URLs
  drush sqlq "SELECT alias FROM url_alias WHERE alias LIKE '%_%'"
  ```

- **WARNING:** Only fix if:
  - Pages don't rank well yet
  - You can implement proper 301 redirects
  - Site is relatively new

---

## 📝 NOTICES (1,925 Issues)

### 15. Resources Formatted as Page Links (1,594 items)
**Impact:** LOW - Site architecture clarity  
**Issue:** Images and files linked with `<a href>` instead of proper tags.

**Drupal 10 Solution:**
- Check Media field formatters:
  ```
  Structure > Content types > [Type] > Manage display
  Change formatter from "Link to file" to "Rendered image"
  ```

- Update WYSIWYG configuration:
  ```
  Configuration > Content authoring > Text formats
  Configure CKEditor image handling
  ```

- Fix in templates:
  ```twig
  {# Instead of this: #}
  <a href="{{ file.url }}">Image</a>
  
  {# Use this: #}
  <img src="{{ file.url }}" alt="{{ file.alt }}" />
  ```

- Review Views file field settings

---

### 16. Single Incoming Link (183 pages)
**Impact:** LOW-MEDIUM - Internal linking structure  
**Issue:** 183 pages have only one internal link pointing to them.

**Drupal 10 Solution:**
- Improve internal linking:
  - Add related content blocks
  - Install **Similar Entries** or **Related Content** module
  - Create contextual navigation menus
  - Add breadcrumb navigation

- Use Related Content module:
  ```bash
  composer require drupal/related_content
  drush en related_content -y
  ```

- Add related content blocks:
  ```
  Structure > Block layout
  Add "Related content" block to content region
  ```

- Create Views for:
  - "You might also like"
  - "Related articles"
  - "Same category"

---

### 17. Deep Page Depth (139 pages)
**Impact:** MEDIUM - Crawlability  
**Issue:** 139 pages require more than 3 clicks from homepage.

**Drupal 10 Solution:**
- Simplify site architecture:
  ```
  Structure > Menus > Main navigation
  Add important pages to main menu
  ```

- Create hub pages/categories
- Implement mega-menus
- Add sitemap/archive pages

- Use **Menu UI** module for better organization
- Create landing pages that link to deep content
- Review and flatten taxonomy hierarchies

---

### 18. Multiple H1 Tags (3 pages)
**Impact:** LOW - HTML structure clarity  
**Issue:** 3 pages have more than one H1 tag.

**Drupal 10 Solution:**
- Check templates:
  ```twig
  {# page.html.twig #}
  <h1>{{ page.title }}</h1>
  
  {# node--[type].html.twig #}
  {# Ensure no duplicate H1 #}
  <h2>{{ node.field_subtitle }}</h2>
  ```

- Review View page title settings
- Check for H1 in:
  - Page template
  - Node template
  - Block content
  - View headers

---

### 19. Blocked External Resources (2 issues)
**Impact:** LOW - Resource loading  
**Issue:** External resources blocked by robots.txt.

**Drupal 10 Solution:**
- Review robots.txt:
  ```
  /robots.txt
  
  # Ensure CDN resources aren't blocked
  Allow: /sites/default/files/
  Allow: /*.css$
  Allow: /*.js$
  ```

- Check external robots.txt if resources are on CDN
- Update robots.txt:
  ```bash
  cd /path/to/drupal
  nano robots.txt
  ```

---

## 🚀 IMPLEMENTATION PRIORITIES

### Phase 1: Critical (Week 1)
1. ✅ Fix HTTPS redirect
2. ✅ Enable CSS/JS aggregation
3. ✅ Fix broken images
4. ✅ Configure canonical URLs

### Phase 2: High Priority (Week 2-3)
1. ✅ Install and configure Metatag module properly
2. ✅ Remove nofollow from internal links
3. ✅ Add required alt attributes to image fields
4. ✅ Fix duplicate titles with unique patterns

### Phase 3: Medium Priority (Week 4-5)
1. ✅ Configure meta descriptions
2. ✅ Fix hreflang conflicts
3. ✅ Check and fix broken external links
4. ✅ Optimize templates for better text-HTML ratio

### Phase 4: Ongoing Maintenance
1. ✅ Monitor and fix new broken links
2. ✅ Improve internal linking structure
3. ✅ Enhance thin content
4. ✅ Regular SEO audits

---

## 🛠️ RECOMMENDED DRUPAL 10 MODULES

### Essential SEO Modules:
```bash
# Core SEO functionality
composer require drupal/metatag
composer require drupal/pathauto
composer require drupal/redirect
composer require drupal/simple_sitemap

# Performance
composer require drupal/advagg

# Content quality
composer require drupal/linkchecker
composer require drupal/image_alt_generator

# Multilingual
composer require drupal/hreflang

# Enable all
drush en metatag pathauto redirect simple_sitemap advagg linkchecker -y
drush cr
```

---

## 📊 MONITORING & MAINTENANCE

### Regular Checks:
```bash
# Clear cache after changes
drush cr

# Rebuild pathauto aliases
drush pathauto:aliases-generate --all

# Check link status
drush linkchecker-check

# Generate sitemap
drush simple-sitemap:generate

# Check site status
drush status-report
```

### Monthly Tasks:
- Review Semrush Site Audit
- Check Google Search Console
- Monitor Core Web Vitals
- Review broken links report
- Audit new content for SEO best practices

---

## 🔧 QUICK FIXES CHECKLIST

- [ ] Install required modules (metatag, pathauto, redirect, advagg)
- [ ] Configure HTTPS redirect (server-level)
- [ ] Enable CSS/JS aggregation
- [ ] Configure Metatag global settings with tokens
- [ ] Make image alt fields required
- [ ] Fix broken images (check file system)
- [ ] Remove nofollow from internal links
- [ ] Set up canonical URLs
- [ ] Configure hreflang (if multilingual)
- [ ] Add meta descriptions to all content types
- [ ] Fix long title tags
- [ ] Review and update robots.txt
- [ ] Generate XML sitemap
- [ ] Clear all caches
- [ ] Test on staging first!

---

## 📞 NOTES FOR DEVELOPER

**Site:** 9df7d73bf2.nxcli.io (appears to be staging/dev environment)  
**Platform:** Drupal 10  
**Total Pages:** 925 crawled  
**Health Score:** 71% (needs improvement)

**Key Observations:**
- High volume of duplicate content suggests possible:
  - View/listing pages with poor configuration
  - Multiple URL patterns to same content
  - Lack of canonical URL implementation
  
- Large number of nofollow internal links suggests:
  - Possible bulk import issue
  - Text format settings problem
  - Theme or module adding nofollow automatically

**Testing Protocol:**
1. Make changes on development/staging environment first
2. Test with small content sample
3. Verify in browser and validator tools
4. Clear caches thoroughly
5. Deploy to production during low-traffic period
6. Monitor for 24-48 hours
7. Re-run Semrush audit after 1 week

**Questions to Address:**
- Is this a multilingual site? (hreflang errors suggest yes)
- What content types are affected by duplicate content?
- Are there custom modules that might interfere with SEO?
- Is the site behind a CDN/proxy? (affects HTTPS detection)

---

*Generated from Semrush Full Site Audit Report - November 20, 2025*  
*For: nxcli.io Drupal 10 Website*

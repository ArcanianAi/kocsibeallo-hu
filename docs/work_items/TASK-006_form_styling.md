# TASK-006: Fix Form Styling to Match Live Site

## Status: ⚪ TODO

---

## 📋 Task Details

**Job ID:** TASK-006
**Priority:** 🔴 High
**Estimated Time:** 2-4 hours
**Phase:** C - Styling & Polish
**Dependencies:** TASK-002 (sidebar form block)

---

## 📝 Description

The Ajánlatkérés (quote request) form doesn't match the live site styling. Both the main form page and sidebar form need proper styling including layout, colors, spacing, and field arrangement.

---

## 🔍 Current State

**Location:** http://localhost:8090/ajánlatkérés

**Issue:**
- Form appears basic/unstyled
- Layout doesn't match live site
- Missing Porto theme styling
- Fields may not be side-by-side where expected
- Colors and spacing incorrect

**Expected:**
- Professional appearance matching Porto theme
- Proper field layout (side-by-side where appropriate)
- Styled input fields
- Color-coded labels
- Styled submit button
- Matches live site closely

---

## 🎯 Expected Result

After fix:
- Form has professional styling
- Input fields properly styled
- Labels have correct colors
- Side-by-side layout where needed
- Submit button styled correctly
- File upload styled appropriately
- Required field indicators visible
- Validation messages styled
- Mobile responsive
- Both main form and sidebar form styled

---

## 🔬 Investigation Steps

1. **Compare forms**
   - Live main form: https://www.kocsibeallo.hu/ajánlatkérés
   - Local main form: http://localhost:8090/ajánlatkérés
   - Live sidebar: https://www.kocsibeallo.hu/kepgaleria
   - Local sidebar: http://localhost:8090/kepgaleria

2. **Inspect live site HTML**
   - Note form wrapper classes
   - Note field wrapper classes
   - Note input styling
   - Note button styling
   - Document layout structure

3. **Check webform configuration**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get webform.webform.ajanlatkeres"
   ```

4. **Check Porto webform templates**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "find /app/web/themes/contrib/porto_theme -name '*webform*' -o -name '*form*' | grep '\.twig$'"
   ```

5. **Check for webform display settings**
   - URL: http://localhost:8090/admin/structure/webform/manage/ajanlatkeres/settings

---

## 🛠 Implementation Steps

### Phase 1: Analysis (30 min)

1. **Document live site structure**
   - Screenshot both forms
   - Note HTML structure
   - List all CSS classes
   - Document field groupings
   - Note layout patterns (flexbox, grid, etc.)

2. **Identify styling approach**
   - Custom CSS
   - Template override
   - Webform settings
   - Or combination

### Phase 2: Webform Settings (30 min)

1. **Check webform settings**
   - URL: http://localhost:8090/admin/structure/webform/manage/ajanlatkeres/settings

2. **Configure display settings**
   - Form attributes
   - Wrapper classes
   - Field wrapper classes

3. **Configure field layout**
   - Use webform flexbox/grid if available
   - Configure side-by-side fields
   - Set field widths

### Phase 3: Template Customization (1-2 hours)

1. **Create webform templates if needed**
   - Copy from Porto or Drupal core
   - Customize for proper structure
   - Common templates:
     - `webform.html.twig`
     - `webform-element.html.twig`
     - `webform-submission-form.html.twig`

2. **Add necessary wrapper classes**
   - Match live site structure
   - Add Porto theme classes

3. **Configure sidebar form display**
   - May need separate template or settings
   - Compact layout for sidebar

### Phase 4: CSS Styling (1-2 hours)

1. **Add to custom-user.css**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "vim /app/web/themes/contrib/porto_theme/css/custom-user.css"
   ```

2. **Style form elements**
   ```css
   /* Example structure */
   .webform-submission-ajanlatkeres-form {
     /* Main form styling */
   }

   .webform-submission-ajanlatkeres-form input[type="text"],
   .webform-submission-ajanlatkeres-form input[type="email"],
   .webform-submission-ajanlatkeres-form textarea {
     /* Input field styling */
   }

   .webform-submission-ajanlatkeres-form label {
     /* Label styling */
   }

   .webform-submission-ajanlatkeres-form .form-submit {
     /* Submit button styling */
   }

   /* Sidebar form styling */
   .block-webform .webform-submission-form {
     /* Compact sidebar styling */
   }
   ```

3. **Match colors**
   - Porto theme colors from settings
   - Skin: #011e41 (dark blue)
   - Secondary: #ac9c58 (gold)
   - Tertiary: #2BAAB1 (teal)

4. **Add responsive styles**
   - Media queries for mobile
   - Stack fields on smaller screens

### Phase 5: Testing (30 min)

1. **Clear cache**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cache:rebuild --uri='http://localhost:8090'"
   ```

2. **Clear CSS/JS aggregation**
   ```bash
   docker exec pajfrsyfzm-d10-cli bash -c "rm -rf /app/web/sites/default/files/css/* /app/web/sites/default/files/js/*"
   ```

3. **Test both forms**
   - Main form page
   - Sidebar form
   - Desktop and mobile

---

## ✅ Testing Checklist

- [ ] Main form styled correctly
- [ ] Sidebar form styled correctly (compact)
- [ ] Input fields have proper styling
- [ ] Labels have correct colors
- [ ] Side-by-side fields work (if applicable)
- [ ] Submit button styled properly
- [ ] File upload styled correctly
- [ ] Required field indicators visible
- [ ] Validation messages styled
- [ ] Error messages styled
- [ ] Success message styled
- [ ] Form spacing/padding correct
- [ ] Mobile responsive
- [ ] Matches live site closely
- [ ] Test form submission still works
- [ ] Check both main and sidebar forms

---

## 📊 Progress Notes

### [Date] - [Status Update]
- Note progress here as work proceeds
- Document template changes
- Note CSS additions
- Log any challenges

---

## 📁 Related Files

**Configuration:**
- `webform.webform.ajanlatkeres` - Webform definition

**Templates:**
- Porto webform templates (TBD)
- Custom templates (if created)

**CSS:**
- `/app/web/themes/contrib/porto_theme/css/custom-user.css`

**URLs:**
- Webform settings: http://localhost:8090/admin/structure/webform/manage/ajanlatkeres/settings
- Main form: http://localhost:8090/ajánlatkérés
- Sidebar: http://localhost:8090/kepgaleria

---

## 🔗 References

- [URGENT_FIXES_NEEDED.md](../fixes/URGENT_FIXES_NEEDED.md) - Issue #4
- [WEBFORM_MIGRATION_URGENT.md](../migration/WEBFORM_MIGRATION_URGENT.md) - Webform migration
- [THEME_REFERENCE.md](../reference/THEME_REFERENCE.md) - Porto theme colors
- [CUSTOM_CSS_APPLIED.md](../tasks/CUSTOM_CSS_APPLIED.md) - CSS customizations
- [ENVIRONMENT_URLS.md](../ENVIRONMENT_URLS.md) - All URLs

---

## 💡 Porto Theme Colors

From theme settings:
- **Skin:** #011e41 (dark blue)
- **Secondary:** #ac9c58 (gold)
- **Tertiary:** #2BAAB1 (teal)
- **Quaternary:** #383f48 (gray)

---

**Created:** 2025-11-15
**Last Updated:** 2025-11-15
**Status:** ⚪ TODO

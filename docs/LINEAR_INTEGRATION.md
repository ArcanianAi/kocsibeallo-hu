# Linear Project Management Integration

This document tracks all Linear integration and open issues for the Kocsibeallo.hu Drupal 7 to Drupal 10 migration project.

## 🔗 Linear Setup

### Team Information

**Team:** Arcanian
**Team ID:** `17c42b32-05aa-42dd-be9e-5c853585eca0`
**Team Key:** ARC
**Linear Workspace:** https://linear.app/arcanian

### MCP Integration

This project uses the Linear MCP (Model Context Protocol) server for seamless issue management from the development environment.

**Capabilities:**
- Create issues directly from command line
- List and search issues
- Update issue status, priority, labels
- Add comments to issues
- Link issues to code changes

---

## 📋 Open Issues (Production Deployment)

### High Priority

#### ARC-685: Fix Porto theme CSS loading on production
**Status:** Todo
**Priority:** High
**Created:** 2025-11-16
**URL:** https://linear.app/arcanian/issue/ARC-685

**Problem:**
Production site shows broken CSS reference: `css/skins/.css` (empty filename)

**Root Cause:**
The `skin_option` configuration was not set in production database, causing Porto theme to try loading an empty skin filename.

**Current Status:**
- Configuration has been set: `drush config:set porto.settings skin_option 'default' -y`
- Configuration verified: `drush config:get porto.settings skin_option` shows correct value
- **Issue persists:** Browser still loads broken CSS reference
- **Likely cause:** PHP-FPM or opcode cache needs restart

**Next Steps:**
1. Log into Cloudways admin panel
2. Navigate to Application Management
3. Restart PHP-FPM service
4. Clear browser cache and test
5. If still broken, restart entire application
6. Verify in browser console that `css/skins/default.css` loads

**Commands for verification:**
```bash
ssh DB_USER (see .credentials)@D10_HOST (see .credentials)
cd ~/public_html/web
../vendor/bin/drush config:get porto.settings skin_option
../vendor/bin/drush cr
```

**Related Files:**
- `config/sync/porto.settings.yml`
- `docs/PORTO_THEME_CUSTOMIZATIONS.md`

---

#### ARC-687: Production deployment final verification
**Status:** Triage
**Priority:** High
**Created:** 2025-11-16
**URL:** https://linear.app/arcanian/issue/ARC-687

**Description:**
Complete final verification checklist for production deployment.

**Dependencies:**
- ARC-685 (Porto CSS fix) must be resolved first
- ARC-686 (Missing logo fix) should be resolved

**Verification Checklist:**

1. **Site Accessibility**
   - [ ] Homepage loads: https://phpstack-958493-6003495.cloudwaysapps.com/
   - [ ] No PHP errors displayed
   - [ ] No database connection errors

2. **Theme and Styling**
   - [ ] Porto theme skin loads correctly (no `css/skins/.css` error)
   - [ ] All CSS files load without 404 errors
   - [ ] Header displays correctly
   - [ ] Footer displays correctly (dark background)
   - [ ] Logo displays without 404
   - [ ] Responsive design works

3. **Content Display**
   - [ ] Homepage slider/content displays
   - [ ] Blog posts display correctly
   - [ ] Images load from `/sites/default/files/`
   - [ ] User profiles display

4. **Browser Console**
   - [ ] No JavaScript errors
   - [ ] No CSS loading errors
   - [ ] No 404 errors for assets

5. **Drupal Status**
   ```bash
   ssh DB_USER (see .credentials)@D10_HOST (see .credentials)
   cd ~/public_html/web
   ../vendor/bin/drush status
   ../vendor/bin/drush watchdog:show --count=20
   ```

6. **File Permissions**
   - [ ] Files directory writable: `web/sites/default/files/`
   - [ ] Correct ownership: `DB_USER (see .credentials):DB_USER (see .credentials)`

7. **Performance**
   - [ ] Page load time acceptable (< 3 seconds)
   - [ ] Images optimized and loading

**Success Criteria:**
All checklist items pass, no console errors, site performs well, content displays correctly.

---

### Medium Priority

#### ARC-684: Install and configure Redis module on production
**Status:** Todo
**Priority:** Medium
**Created:** 2025-11-16
**URL:** https://linear.app/arcanian/issue/ARC-684

**Description:**
Install and configure Redis caching module for improved performance on Cloudways production.

**Status:** Deferred until core deployment is verified and working.

**Implementation Steps:**

1. **Verify Redis is available on Cloudways:**
   - Cloudways includes Redis by default
   - Get Redis password from: Cloudways > Application > Access Details

2. **Install Redis module:**
   ```bash
   ssh DB_USER (see .credentials)@D10_HOST (see .credentials)
   cd ~/public_html
   composer require drupal/redis
   ```

3. **Enable Redis module:**
   ```bash
   cd web
   ../vendor/bin/drush en redis -y
   ```

4. **Configure in settings.php:**
   ```php
   /**
    * Redis configuration (Cloudways includes Redis)
    */
   if (extension_loaded('redis')) {
     $settings['redis.connection']['interface'] = 'PhpRedis';
     $settings['redis.connection']['host'] = 'localhost';
     $settings['redis.connection']['port'] = '6379';
     // $settings['redis.connection']['password'] = 'your-redis-password';

     $settings['cache']['default'] = 'cache.backend.redis';
     $settings['cache']['bins']['bootstrap'] = 'cache.backend.chainedfast';
     $settings['cache']['bins']['discovery'] = 'cache.backend.chainedfast';
     $settings['cache']['bins']['config'] = 'cache.backend.chainedfast';
   }
   ```

5. **Clear cache and test:**
   ```bash
   ../vendor/bin/drush cr
   ../vendor/bin/drush status
   ```

6. **Verify Redis is working:**
   ```bash
   # Check Redis connection
   redis-cli ping
   # Should return: PONG

   # Check Drupal cache
   ../vendor/bin/drush cache:get system.theme.data default
   ```

**Documentation:**
- Update `docs/CLOUDWAYS_DEPLOYMENT.md` with Redis configuration
- Document Redis performance improvements

**Related Files:**
- `web/sites/default/settings.php`
- `composer.json`

---

#### ARC-686: Fix missing logo file on production
**Status:** Triage
**Priority:** Medium
**Created:** 2025-11-16
**URL:** https://linear.app/arcanian/issue/ARC-686

**Problem:**
Production shows 404 error for: `themes/contrib/porto_theme/img/deluxe-kocsibeallo-logo-150px.png`

**Impact:**
Visual issue - logo doesn't display in Porto theme header.

**Investigation Steps:**

1. **Check if file exists locally:**
   ```bash
   ls -lh web/themes/contrib/porto_theme/img/deluxe-kocsibeallo-logo-150px.png
   ```

2. **Check if file is in Git:**
   ```bash
   git status web/themes/contrib/porto_theme/img/
   git ls-files web/themes/contrib/porto_theme/img/deluxe-kocsibeallo-logo-150px.png
   ```

3. **If file exists locally but not in Git:**
   ```bash
   git add web/themes/contrib/porto_theme/img/deluxe-kocsibeallo-logo-150px.png
   git commit -m "Add missing Porto theme logo file"
   git push origin main
   ```

4. **Deploy to production:**
   - In Cloudways admin: Application > Deployment Via Git > Pull
   - Or wait for webhook to trigger

5. **Verify on production:**
   ```bash
   ssh DB_USER (see .credentials)@D10_HOST (see .credentials)
   cd ~/public_html/web/themes/contrib/porto_theme/img/
   ls -lh deluxe-kocsibeallo-logo-150px.png
   ```

6. **Clear cache:**
   ```bash
   cd ~/public_html/web
   ../vendor/bin/drush cr
   ```

7. **Test in browser:**
   - Visit https://phpstack-958493-6003495.cloudwaysapps.com/
   - Check browser console for logo 404 error (should be gone)

**Alternative Solutions:**

If file doesn't exist locally:
- Check Porto theme settings for logo configuration
- May need to create/design the logo file (150px width)
- Or update Porto theme to use different logo path

**Related Files:**
- `web/themes/contrib/porto_theme/img/deluxe-kocsibeallo-logo-150px.png`
- `config/sync/porto.settings.yml` (check logo configuration)

---

## 🔧 Linear MCP Commands Reference

### List Issues

```bash
# List all issues in Arcanian team
linear list_issues --team=ARC

# List my open issues
linear list_issues --assignee=me

# List issues by label
linear list_issues --label=production

# List issues by state
linear list_issues --state=Todo
```

### Create Issue

```bash
# Create issue
linear create_issue \
  --team=17c42b32-05aa-42dd-be9e-5c853585eca0 \
  --title="Issue title" \
  --description="Issue description" \
  --priority=2 \
  --labels=production,deployment
```

**Priority values:**
- 0 = No priority
- 1 = Urgent
- 2 = High
- 3 = Normal (Medium)
- 4 = Low

### Update Issue

```bash
# Update issue state
linear update_issue \
  --id=ARC-685 \
  --state=In Progress

# Update issue priority
linear update_issue \
  --id=ARC-685 \
  --priority=1
```

### Add Comment

```bash
# Add comment to issue
linear create_comment \
  --issueId=ARC-685 \
  --body="Updated the configuration, testing now"
```

### Get Issue Details

```bash
# Get full issue details
linear get_issue --id=ARC-685
```

---

## 📊 Issue Labels Reference

**Common labels used in this project:**

- `production` - Production environment issues
- `deployment` - Deployment-related issues
- `bug` - Bug fixes
- `theme` - Porto theme customizations
- `performance` - Performance improvements
- `security` - Security-related issues
- `documentation` - Documentation updates
- `testing` - Testing and QA

---

## 🔄 Development Workflow with Linear

### 1. Feature Development

```bash
# Create issue for feature
linear create_issue --team=ARC --title="New feature"

# Create branch from issue
git checkout -b laszlofazakas/arc-XXX-feature-name

# Make changes, commit
git add .
git commit -m "ARC-XXX: Implement feature"

# Push and reference issue
git push origin laszlofazakas/arc-XXX-feature-name
```

### 2. Bug Fixes

```bash
# Create bug issue
linear create_issue --team=ARC --title="Fix bug" --labels=bug --priority=2

# Fix and commit with issue reference
git commit -m "ARC-XXX: Fix bug description"
```

### 3. Deployment Tasks

```bash
# Create deployment issue
linear create_issue --team=ARC --title="Deploy feature X" --labels=deployment,production

# Update as you deploy
linear update_issue --id=ARC-XXX --state="In Progress"

# Add deployment notes
linear create_comment --issueId=ARC-XXX --body="Deployed to staging, testing now"

# Mark complete
linear update_issue --id=ARC-XXX --state="Done"
```

---

## 📁 Related Documentation

- **Deployment Guide:** `docs/CLOUDWAYS_DEPLOYMENT.md`
- **Porto Theme Customizations:** `docs/PORTO_THEME_CUSTOMIZATIONS.md`
- **Settings.php Setup:** `docs/SETTINGS_PHP_SETUP.md`
- **Project README:** `README.md`

---

## 🔍 Issue Search and Filtering

### Find Issues by Keyword

```bash
# Search in title/description
linear list_issues --query="porto theme"
linear list_issues --query="CSS"
```

### Filter by Date

```bash
# Issues created in last day
linear list_issues --createdAt=-P1D

# Issues updated recently
linear list_issues --updatedAt=-P1D
```

### Filter by Project/Cycle

```bash
# List projects
linear list_projects --team=ARC

# List issues in project
linear list_issues --project="Drupal Migration"
```

---

## ✅ Completed Issues

Track completed issues here for reference:

- None yet (project just started tracking in Linear)

---

## 🆘 Troubleshooting Linear Integration

### "Argument Validation Error - teamId must be a UUID"

**Problem:** Using team key instead of team ID
**Solution:** Use full UUID: `17c42b32-05aa-42dd-be9e-5c853585eca0`

### Can't find issue by ID

**Problem:** Using wrong issue identifier
**Solution:** Use full identifier like `ARC-685`, not just the number

### Permission errors

**Problem:** Linear API authentication issues
**Solution:** Check Linear API key is configured in MCP settings

---

**Last Updated:** 2025-11-16
**Linear Team:** Arcanian (ARC)
**Active Issues:** 4 (ARC-684, ARC-685, ARC-686, ARC-687)

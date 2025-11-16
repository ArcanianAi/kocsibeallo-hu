# Kocsibeallo.hu - Access Information

> **📝 For detailed migration notes, troubleshooting, and technical lessons learned, see [MIGRATION_NOTES.md](./MIGRATION_NOTES.md)**

## Drupal 10 Environment

### 🔐 Admin Login

**One-time login link (no password needed):**
```
http://localhost:8090/user/reset/1/1762781277/UrTftcagLLaBunSSQqXMO35wC-cbT7EvolK9K6mg-4c/login
```

**Regular login:**
- URL: http://localhost:8090/user/login
- Username: `admin`
- Password: `admin123`
- Email: info@kocsibeallo.hu

**Second admin account:**
- Username: `admin2`
- Email: info+admin3@telikert.hu
- Password: Use drush to reset if needed

---

## 📊 Drupal 10 Content Management

### Main URLs
- **Homepage:** http://localhost:8090
- **Admin Dashboard:** http://localhost:8090/admin
- **Content Overview:** http://localhost:8090/admin/content
- **Structure:** http://localhost:8090/admin/structure
- **Languages:** http://localhost:8090/admin/config/regional/language

### Site Configuration
- **Default Language:** Hungarian (hu)
- **Available Languages:** English (en), Hungarian (hu)
- **Default Theme:** Porto (v1.5.4) - Same as D7 ✅
- **Admin Theme:** Claro
- **Clean URLs:** ✅ Enabled and working
- **Example URL:** http://localhost:8090/dupla-kocsibeallo-kulonleges-kivitelezessel-ragasztott-fa-szerkezettel

### Content by Type
- **Articles:** http://localhost:8090/admin/content?type=article (42 items)
- **Pages:** http://localhost:8090/admin/content?type=page (56 items)
- **Gallery Photos:** http://localhost:8090/admin/content?type=foto_a_galeriahoz (113 items)
- **Team Members:** http://localhost:8090/admin/content?type=team (7 items)
- **FAQs:** http://localhost:8090/admin/content?type=faq (5 items)
- **Webforms:** http://localhost:8090/admin/content?type=webform (5 items)

### Taxonomy Management
- **All Taxonomies:** http://localhost:8090/admin/structure/taxonomy
- **Cimkek (Tags):** http://localhost:8090/admin/structure/taxonomy/manage/cimkek/overview (37 terms)
- **Tags:** http://localhost:8090/admin/structure/taxonomy/manage/tags/overview (10 terms)
- **Tetőfedés Anyaga:** http://localhost:8090/admin/structure/taxonomy/manage/tetofedes_anyaga/overview (8 terms)
- **Szerkezet Anyaga:** http://localhost:8090/admin/structure/taxonomy/manage/szerkezet_anyaga/overview (5 terms)

---

## 🔌 JSON:API Endpoints (for React Frontend)

### Node Endpoints
- **All Articles:** http://localhost:8090/jsonapi/node/article
- **All Pages:** http://localhost:8090/jsonapi/node/page
- **Gallery Photos:** http://localhost:8090/jsonapi/node/foto_a_galeriahoz
- **Team Members:** http://localhost:8090/jsonapi/node/team
- **FAQs:** http://localhost:8090/jsonapi/node/faq
- **Single Node (by UUID):** http://localhost:8090/jsonapi/node/{type}/{uuid}

### Taxonomy Endpoints
- **Cimkek Terms:** http://localhost:8090/jsonapi/taxonomy_term/cimkek
- **Tags Terms:** http://localhost:8090/jsonapi/taxonomy_term/tags
- **All Vocabularies:** http://localhost:8090/jsonapi/taxonomy_vocabulary/taxonomy_vocabulary

### User Endpoints
- **Current User:** http://localhost:8090/jsonapi/user/user?filter[drupal_internal__uid][value]=1

---

## 🗄️ Database Access

### Drupal 10 Database (phpMyAdmin)
- **URL:** http://localhost:8082
- **Server:** drupal10-mariadb
- **Database:** drupal10
- **Username:** root
- **Password:** root

### Direct Database Connection
- **Host:** localhost
- **Port:** 8306
- **Database:** drupal10
- **Username:** drupal10
- **Password:** drupal10pass

---

## 📦 Drupal 7 Environment (Original Site)

### Web Access
- **Homepage:** http://localhost:7080
- **phpMyAdmin:** http://localhost:7081

### Database (phpMyAdmin)
- **URL:** http://localhost:7081
- **Server:** drupal7-db
- **Database:** pajfrsyfzm
- **Username:** root
- **Password:** root

### Direct Database Connection
- **Host:** localhost
- **Port:** 7306
- **Database:** pajfrsyfzm
- **Username:** drupal7
- **Password:** drupal7pass

---

## 🐳 Docker Container Names

### Drupal 10 Containers
- **CLI:** pajfrsyfzm-d10-cli
- **PHP-FPM:** pajfrsyfzm-d10-php
- **Nginx:** pajfrsyfzm-d10-nginx
- **MariaDB:** pajfrsyfzm-d10-mariadb
- **phpMyAdmin:** pajfrsyfzm-d10-phpmyadmin

### Drupal 7 Containers
- **CLI:** pajfrsyfzm-d7-cli
- **PHP-FPM:** pajfrsyfzm-d7-php
- **Nginx:** pajfrsyfzm-d7-nginx
- **MySQL:** pajfrsyfzm-d7-db
- **phpMyAdmin:** pajfrsyfzm-d7-phpmyadmin

---

## 📈 Migration Summary

### Successfully Migrated
- ✅ 242 content nodes (14 content types)
- ✅ 97 taxonomy terms (15 vocabularies)
- ✅ 2 users with roles
- ✅ 2,770 URL aliases
- ✅ 78 custom blocks
- ✅ 140 block placements (in Porto theme)
- ✅ 19 content types
- ✅ 22 image styles
- ✅ 7 menus with 28 menu links
- ✅ Porto theme (D10 v1.5.4) - Same as D7
- ✅ Site configuration and settings

### Known Limitations
- ⚠️ 1,512 public files not migrated (missing from D7 source filesystem)
- ⚠️ 945 private files not migrated (missing from D7 source filesystem)
- ⚠️ 30 menu links failed migration (broken/missing target pages)
- ⚠️ Logo and favicon need to be uploaded
- ✅ Porto theme custom CSS applied (10,958 chars from D7)
- ✅ Porto theme colors configured (#011e41, #ac9c58)

---

## 🎨 Theme Information

**Porto Theme D10:**
- Version: 1.5.4
- Machine Name: `porto`
- Settings: http://localhost:8090/admin/appearance/settings/porto
- Block Layout: http://localhost:8090/admin/structure/block

**For detailed theme migration notes:** See [PORTO_THEME_MIGRATION.md](./PORTO_THEME_MIGRATION.md)

**Quick Theme Stats:**
- 52 active blocks in Porto theme
- Main menu working with all items
- Same region structure as D7
- ✅ Custom CSS applied (10,958 chars from D7)
- ✅ Colors configured (#011e41 dark blue, #ac9c58 gold)
- ⚠️ Still needs: Logo and favicon from production

---

## 🛠️ Useful Commands

### Reset Admin Password
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush user:password admin 'newpassword' --uri='http://localhost:8090'"
```

### Generate One-time Login Link
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush user:login --uri='http://localhost:8090'"
```

### Clear Cache
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cache:rebuild --uri='http://localhost:8090'"
```

### Check Migration Status
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush migrate:status --group=migrate_drupal_7 --uri='http://localhost:8090'"
```

### Start Both Environments
```bash
docker-compose -f docker-compose.d7.yml up -d
docker-compose -f docker-compose.d10.yml up -d
```

### Stop Environments
```bash
docker-compose -f docker-compose.d10.yml down
docker-compose -f docker-compose.d7.yml down
```

### Add a New Language
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush language:add [langcode] --uri='http://localhost:8090'"
```

---

## 🔧 Troubleshooting

### Clean URLs Not Working / 404 Errors

**Problem:** URL aliases return 404 errors even though they exist in the database.

**Solution:** This was caused by a language mismatch. The site content is in Hungarian but D10 was initially set to English.

**Fix Applied:**
1. Enabled language modules: `language`, `locale`, `content_translation`
2. Added Hungarian language and imported translations
3. Set Hungarian as the default site language
4. Cleared cache

**Verify the fix:**
```bash
# Check current default language
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:get system.site default_langcode --uri='http://localhost:8090'"

# Should show: 'system.site:default_langcode': hu
```

### Missing Files

**Problem:** Images and files are not displaying on migrated content.

**Cause:** The D7 source filesystem only contained 68 files (mostly aggregated CSS/JS), but the database had 2458 file records. The actual media files were missing from the D7 source.

**Possible Solutions:**
1. Locate and restore the missing files from a backup or production server
2. Copy files to `/Volumes/T9/Sites/kocsibeallo-hu/drupal7-codebase/sites/default/files/`
3. Copy files to `/Volumes/T9/Sites/kocsibeallo-hu/drupal10/web/sites/default/files/`
4. Re-run file migration if D7 files are restored

---

**Last Updated:** 2025-11-10

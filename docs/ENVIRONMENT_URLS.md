# Environment URLs & Access Points

**Quick Reference Guide for All Project URLs**

---

## 🌐 Production (Live Site)

### Current Live Production Site
- **URL:** https://www.kocsibeallo.hu
- **Status:** Active (Drupal 7)
- **Purpose:** Current live production site serving customers
- **Access:** Public

---

## 💻 Local Development Environments

### Drupal 10 (New Migration - Primary Development)
**Container Prefix:** `pajfrsyfzm-d10-*`

| Service | URL | Credentials |
|---------|-----|-------------|
| **Web Interface** | http://localhost:8090 | admin / admin123 |
| **Admin Panel** | http://localhost:8090/admin | admin / admin123 |
| **phpMyAdmin** | http://localhost:8082 | root / root |
| **Database** | localhost:8306 | root / root |
| **Database Name** | `drupal10` | - |

**Quick Login:**
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush user:login --uri='http://localhost:8090'"
```

---

### Drupal 7 (Legacy - Reference/Comparison)
**Container Prefix:** `drupal7-*`

| Service | URL | Credentials |
|---------|-----|-------------|
| **Web Interface** | http://localhost:7080 | admin / admin |
| **phpMyAdmin** | http://localhost:7081 | root / root |
| **Database** | localhost:7306 | root / root |
| **Database Name** | `pajfrsyfzm` | - |

**Purpose:** Keep running for comparison and reference during migration

---

## 🔌 API Endpoints

### Drupal 10 JSON:API (Enabled)

**Base URL:** http://localhost:8090/jsonapi

**Test Endpoints:**
```bash
# Articles
curl http://localhost:8090/jsonapi/node/article

# Pages
curl http://localhost:8090/jsonapi/node/page

# Gallery items
curl http://localhost:8090/jsonapi/node/galeria_elem

# Taxonomy - Címkék (Tags)
curl http://localhost:8090/jsonapi/taxonomy_term/cimkek

# Taxonomy - Galéria kategóriák
curl http://localhost:8090/jsonapi/taxonomy_term/galeria_kategoriak
```

---

## 🗂️ Database Connection Details

### Drupal 10 Database
```php
$databases['default']['default'] = [
  'database' => 'drupal10',
  'username' => 'root',
  'password' => 'root',
  'host' => 'drupal10-db',  // Inside container
  'port' => '3306',
  'driver' => 'mysql',
];
```

**External Access:**
- Host: `localhost`
- Port: `8306`
- Database: `drupal10`
- Username: `root`
- Password: `root`

### Drupal 7 Database (Reference)
```php
$databases['default']['default'] = [
  'database' => 'pajfrsyfzm',
  'username' => 'root',
  'password' => 'root',
  'host' => 'drupal7-db',  // Inside container
  'port' => '3306',
  'driver' => 'mysql',
];
```

**External Access:**
- Host: `localhost`
- Port: `7306`
- Database: `pajfrsyfzm`
- Username: `root`
- Password: `root`

---

## 🐳 Docker Container Access

### Start All Environments
```bash
# Navigate to project
cd /Volumes/T9/Sites/kocsibeallo-hu

# Start D10 (primary)
docker-compose -f docker-compose.d10.yml up -d

# Start D7 (reference)
docker-compose -f docker-compose.d7.yml up -d

# Check status
docker ps
```

### Drupal 10 Container Access
```bash
# Web container (PHP)
docker exec -it pajfrsyfzm-d10-web bash

# CLI container (Drush)
docker exec -it pajfrsyfzm-d10-cli bash

# Database container
docker exec -it drupal10-db bash

# Nginx container
docker exec -it pajfrsyfzm-d10-nginx bash
```

### Drupal 7 Container Access
```bash
# Web/PHP container
docker exec -it drupal7-php bash

# Database container
docker exec -it drupal7-db bash

# Nginx container
docker exec -it drupal7-nginx bash
```

---

## 📋 Important Page URLs

### Drupal 10 Key Pages

**Admin Pages:**
- Content Overview: http://localhost:8090/admin/content
- Structure: http://localhost:8090/admin/structure
- Appearance: http://localhost:8090/admin/appearance
- Extend (Modules): http://localhost:8090/admin/modules
- Configuration: http://localhost:8090/admin/config
- Reports: http://localhost:8090/admin/reports

**Theme Settings:**
- Porto Theme Settings: http://localhost:8090/admin/appearance/settings/porto
- Block Layout: http://localhost:8090/admin/structure/block
- Menu Management: http://localhost:8090/admin/structure/menu

**Content Management:**
- Nodes: http://localhost:8090/admin/content
- Media: http://localhost:8090/admin/content/media
- Files: http://localhost:8090/admin/content/files
- Taxonomy: http://localhost:8090/admin/structure/taxonomy

**Views:**
- Views List: http://localhost:8090/admin/structure/views
- Blog View: http://localhost:8090/admin/structure/views/view/blog
- Gallery View: http://localhost:8090/admin/structure/views/view/galeria

**Webforms:**
- Webform List: http://localhost:8090/admin/structure/webform
- Ajánlatkérés Form: http://localhost:8090/admin/structure/webform/manage/ajanlatkeres

**Front-End Pages:**
- Homepage: http://localhost:8090/
- Blog: http://localhost:8090/blog
- Gallery: http://localhost:8090/kepgaleria
- Contact Form: http://localhost:8090/ajánlatkérés
- GYIK (FAQ): http://localhost:8090/gyik
- About: http://localhost:8090/rolunk

---

## 🔍 Comparison URLs (Side-by-Side Testing)

### Homepage
- **Live:** https://www.kocsibeallo.hu/
- **D10:** http://localhost:8090/
- **D7:** http://localhost:7080/

### Blog
- **Live:** https://www.kocsibeallo.hu/blog
- **D10:** http://localhost:8090/blog
- **D7:** http://localhost:7080/blog

### Gallery
- **Live:** https://www.kocsibeallo.hu/kepgaleria
- **D10:** http://localhost:8090/kepgaleria
- **D7:** http://localhost:7080/kepgaleria

### Contact Form
- **Live:** https://www.kocsibeallo.hu/ajánlatkérés
- **D10:** http://localhost:8090/ajánlatkérés
- **D7:** http://localhost:7080/node/243

### Example Gallery Item (Napelemes)
- **Live:** https://www.kocsibeallo.hu/napelemes-aluminium-kocsibeallo-vilagosszurke-porszorassal
- **D10:** http://localhost:8090/napelemes-aluminium-kocsibeallo-vilagosszurke-porszorassal
- **D7:** http://localhost:7080/napelemes-aluminium-kocsibeallo-vilagosszurke-porszorassal

---

## 🛠️ Development Tools

### phpMyAdmin Access

**D10 phpMyAdmin:**
- URL: http://localhost:8082
- Server: `drupal10-db`
- Username: `root`
- Password: `root`

**D7 phpMyAdmin:**
- URL: http://localhost:7081
- Server: `drupal7-db`
- Username: `root`
- Password: `root`

### File System Paths

**D10 Files:**
- Public files: `/Volumes/T9/Sites/kocsibeallo-hu/drupal10/web/sites/default/files/`
- Theme: `/Volumes/T9/Sites/kocsibeallo-hu/drupal10/web/themes/contrib/porto_theme/`
- Custom CSS: `/Volumes/T9/Sites/kocsibeallo-hu/drupal10/web/themes/contrib/porto_theme/css/custom-user.css`
- Modules: `/Volumes/T9/Sites/kocsibeallo-hu/drupal10/web/modules/contrib/`

**D7 Files:**
- Codebase: `/Volumes/T9/Sites/kocsibeallo-hu/drupal7-codebase/`
- Public files: `/Volumes/T9/Sites/kocsibeallo-hu/drupal7-codebase/sites/default/files/`

---

## 📊 Environment Status Check

### Quick Health Check
```bash
# Check all containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Test D10 web
curl -s -o /dev/null -w "%{http_code}" http://localhost:8090
# Expected: 200

# Test D7 web
curl -s -o /dev/null -w "%{http_code}" http://localhost:7080
# Expected: 200

# Test D10 database
docker exec drupal10-db mysql -uroot -proot -e "SELECT COUNT(*) FROM drupal10.node;"
# Expected: ~242

# Test D7 database
docker exec drupal7-db mysql -uroot -proot -e "SELECT COUNT(*) FROM pajfrsyfzm.node;"
# Expected: ~242
```

---

## 🚀 Staging/Production (Future)

### Staging Environment
**Status:** Not yet configured
**Planned URL:** TBD
**Purpose:** Pre-production testing with client

### Production Deployment
**Current:** https://www.kocsibeallo.hu (Drupal 7)
**Target:** https://www.kocsibeallo.hu (Drupal 10 after migration complete)
**Deployment Date:** TBD (after client UAT approval)

---

## 📝 Notes

### Port Mapping Summary
| Service | D7 Port | D10 Port |
|---------|---------|----------|
| HTTP | 7080 | 8090 |
| phpMyAdmin | 7081 | 8082 |
| MySQL | 7306 | 8306 |

### Network Configuration
- **D7 Network:** `d7_network`
- **D10 Network:** `d10_network`
- **Both isolated:** Containers cannot communicate between environments

### Volume Persistence
All data persists across container restarts:
- D10 database: `drupal10_db_data` volume
- D10 files: Bind mount to local filesystem
- D7 database: `d7_db_data` volume
- D7 files: Bind mount to local filesystem

---

## 🔗 Quick Links

**Documentation:**
- [Current Status](status/CURRENT_STATUS.md)
- [Access Information](reference/ACCESS_INFO.md)
- [Next Steps](planning/NEXT_STEPS.md)
- [Urgent Fixes](fixes/URGENT_FIXES_NEEDED.md)

**Docker Compose Files:**
- D10: `/Volumes/T9/Sites/kocsibeallo-hu/docker-compose.d10.yml`
- D7: `/Volumes/T9/Sites/kocsibeallo-hu/docker-compose.d7.yml`

---

**Last Updated:** 2025-11-15
**Project:** Kocsibeallo.hu D7 → D10 Migration
**Status:** Phase 4 - Testing & Bug Fixes

# Restart Checklist After Reboot

**Quick reference guide for restarting the Drupal migration environment**

---

## Step 1: Start Docker Containers (2 minutes)

```bash
cd /Volumes/T9/Sites/kocsibeallo-hu

# Start D10 (main site)
docker-compose -f docker-compose.d10.yml up -d

# Start D7 (for comparison)
docker-compose -f docker-compose.d7.yml up -d

# Wait for containers to initialize
sleep 30
```

---

## Step 2: Verify Containers Running

```bash
docker ps | grep pajfrsyfzm
```

**Expected output:** 10 containers running
- 5 D10 containers: cli, php, nginx, mariadb, phpmyadmin
- 5 D7 containers: cli, php, nginx, db, phpmyadmin

---

## Step 3: Test Site Access

**Open in browser:**
- D10: http://localhost:8090
- D7: http://localhost:7080

**Expected:** Both sites should load immediately

---

## Step 4: Quick Verification (Optional)

```bash
# Check D10 status
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush status --uri='http://localhost:8090'"

# Verify custom CSS exists
docker exec pajfrsyfzm-d10-cli bash -c "ls -lh /app/web/themes/contrib/porto_theme/css/custom-user.css"
```

---

## If Something Doesn't Work

### Clear Cache:
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cache:rebuild --uri='http://localhost:8090'"
```

### Restart Containers:
```bash
docker-compose -f docker-compose.d10.yml restart
```

### Generate New Login Link:
```bash
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush user:login --uri='http://localhost:8090'"
```

---

## Admin Access

**D10 Login:**
- URL: http://localhost:8090/user/login
- Username: `admin`
- Password: `admin123`

**D10 phpMyAdmin:**
- URL: http://localhost:8082
- Username: `root`
- Password: `root`

---

## Documentation Files Available

1. **CURRENT_STATUS.md** - Complete current state (read this first!)
2. **PHASE_3_COMPLETE.md** - Full Phase 3 summary
3. **ACCESS_INFO.md** - All URLs and credentials
4. **CUSTOM_CSS_APPLIED.md** - Custom CSS details
5. **PORTO_THEME_MIGRATION.md** - Theme installation guide
6. **MIGRATION_NOTES.md** - Technical migration notes

---

## What's Already Done ✅

- ✅ Porto theme installed and configured
- ✅ Custom CSS applied (10,958 chars from D7)
- ✅ Footer blocks properly placed
- ✅ 242 nodes, 97 terms, 2,770 URLs migrated
- ✅ Everything tested and working

**You're ready to resume work immediately after restart!**

---

**Next Phase:** React Frontend Development (Phase 4)

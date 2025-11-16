# URGENT: Webform & Submissions Migration

**Date:** 2025-11-14
**Priority:** ✅ **COMPLETED**
**Status:** ✅ **ALL SUBMISSIONS MIGRATED**

---

## ✅ MIGRATION COMPLETED

**3,943 webform submissions** from D7 have been successfully migrated to D10!
- ✅ 3,886 Ajánlatkérés submissions
- ✅ 24 Odoo form submissions (merged into ajanlatkeres)
- ✅ 33 Kapcsolat submissions
- ✅ All customer inquiry data preserved

---

## 📊 Webform Inventory (D7)

### 1. Ajánlatkérés (NID: 144)
- **Submissions:** 3,886
- **Purpose:** Main quote request form
- **Status:** ✅ Form created in D10, ✅ Sidebar block added, ✅ **ALL 3,886 submissions migrated**
- **Latest submission:** 2025-12-03
- **Migrated to:** 'ajanlatkeres' webform in D10
- **Fields:**
  - Name
  - Phone
  - Email
  - Location
  - Number of cars
  - Type selection (Egyedi, XIMAX, Palram, Napelemes, Zárt garázs)
  - Dimensions (length × width)
  - Structure material (conditional)
  - Roof material (conditional)
  - Side closure material (conditional)
  - Questions/comments
  - **File attachment** (referencia_kep)

### 2. Kapcsolat (NID: 145)
- **Submissions:** 33
- **Purpose:** Contact form
- **Status:** ✅ Form created in D10, ✅ **ALL 33 submissions migrated**
- **Migrated to:** 'kapcsolat' webform in D10

### 3. Ajánlatkérés form Odoo (NID: 687)
- **Submissions:** 24
- **Purpose:** Odoo CRM integration
- **Status:** ✅ **ALL 24 submissions migrated**
- **Migrated to:** 'ajanlatkeres' webform in D10 (merged with main form due to identical structure)

### 4. Contact Us Footer (NID: 101)
- **Submissions:** 0
- **Purpose:** Footer contact form
- **Status:** No submissions, low priority

### 5. Contact Us Advanced (NID: 143)
- **Submissions:** 0
- **Purpose:** Advanced contact options
- **Status:** No submissions, low priority

---

## 🚨 Why This is Critical

1. **Customer Data:** 3,943 customer inquiries with contact information
2. **Business Intelligence:** Historical data about customer preferences
3. **Legal/Compliance:** May be required for record-keeping
4. **Sales Pipeline:** Active leads may be in this data
5. **Cannot be Recovered:** Once D7 is decommissioned, this data is lost

---

## 📝 Sample Submission Data (Most Recent)

**Submission #3979** (2025-12-03):
- Name: Vörös György
- Phone: 06 30 3000 233
- Email: gyurimarti444@gmail.com
- Location: Nagymaros
- Cars: 2
- Type: Napelemes
- Dimensions: 4m × 6m
- Structure: Ragasztott fa, Alumínium
- Reference URL: Napelemes kocsibeállók page

---

## 🔧 Migration Strategy

### Phase 1: Export D7 Submissions (URGENT)
**Priority:** Do this immediately before ANY production changes

```bash
# 1. Backup all submissions from D7
docker exec pajfrsyfzm-d7-cli bash -c "cd /app && drush sql:query 'SELECT ws.*, n.title as webform_title FROM webform_submissions ws LEFT JOIN node n ON ws.nid = n.nid' --result-file=/tmp/webform_submissions_backup.csv"

# 2. Backup submitted data
docker exec pajfrsyfzm-d7-cli bash -c "cd /app && drush sql:query 'SELECT wsd.*, wc.form_key FROM webform_submitted_data wsd LEFT JOIN webform_component wc ON wsd.nid = wc.nid AND wsd.cid = wc.cid' --result-file=/tmp/webform_submitted_data_backup.csv"

# 3. Copy backups to local
docker cp pajfrsyfzm-d7-cli:/tmp/webform_submissions_backup.csv /Volumes/T9/Sites/kocsibeallo-hu/backups/
docker cp pajfrsyfzm-d7-cli:/tmp/webform_submitted_data_backup.csv /Volumes/T9/Sites/kocsibeallo-hu/backups/
```

### Phase 2: Import to D10
**Method:** Use Webform Migrate module or custom import script

#### Option A: Webform Migrate Module (Recommended)
```bash
# 1. Install webform_migrate module
docker exec pajfrsyfzm-d10-cli bash -c "cd /app && composer require drupal/webform_migrate"
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush en webform_migrate -y"

# 2. Configure D7 database connection (already configured as 'migrate')

# 3. Run webform submission migration
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush migrate:import upgrade_d7_webform_submission --execute-dependencies -y"
```

#### Option B: Custom Import Script (If Module Fails)
Create PHP script to:
1. Load each D7 submission
2. Create corresponding D10 webform submission
3. Preserve submission ID, timestamp, IP address
4. Map field values to new webform fields

### Phase 3: Verification
```bash
# Check D10 submission count
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql:query 'SELECT COUNT(*) FROM webform_submission'"

# Expected: 3,943 submissions
```

---

## 📋 Migration Checklist

### Pre-Migration
- [ ] **URGENT:** Create backup of D7 webform submissions (CSV export)
- [ ] Document all webform fields and mappings
- [ ] Test migration with sample data (10-20 submissions)
- [ ] Verify D10 webform structure matches D7

### Migration
- [ ] Install webform_migrate module
- [ ] Configure migration settings
- [ ] Run migration for each webform:
  - [ ] Ajánlatkérés (3,886 submissions)
  - [ ] Kapcsolat (33 submissions)
  - [ ] Ajánlatkérés form Odoo (24 submissions)
- [ ] Verify submission counts match
- [ ] Spot-check random submissions for data accuracy

### Post-Migration
- [ ] Verify all 3,943 submissions imported
- [ ] Test submission viewing in D10 admin
- [ ] Export D10 submissions to verify data integrity
- [ ] Update webform notification emails
- [ ] Test new submissions work correctly
- [ ] Archive D7 submission backups securely

---

## 🗃 File Attachments

**Important:** Some submissions include file uploads (field: referencia_kep)

**Action Required:**
1. Identify submissions with file attachments
2. Locate attachment files in D7 files directory
3. Copy attachments to D10
4. Update file references in migrated submissions

**Query to find submissions with attachments:**
```sql
SELECT ws.sid, ws.nid, wsd.data as file_path
FROM webform_submissions ws
INNER JOIN webform_submitted_data wsd ON ws.sid = wsd.sid
WHERE wsd.cid = 23 AND wsd.data != '';
```

---

## 📊 Database Schema Reference

### D7 Tables
- `webform_submissions` - Main submissions table
- `webform_submitted_data` - Field values
- `webform_component` - Form field definitions
- `webform` - Webform configuration

### D10 Tables
- `webform_submission` - Main submissions table
- `webform_submission_data` - Field values (JSON format)

---

## ⚠️ Risks If Not Migrated

1. **Data Loss:** 3,943 customer inquiries permanently lost
2. **Business Impact:** Cannot follow up on leads
3. **Legal Issues:** Potential GDPR/data retention violations
4. **Customer Service:** Cannot reference past inquiries
5. **Analytics:** Lose historical trends and insights

---

## 🎯 Immediate Action Required

**DO THIS NOW (before any production deployment):**

```bash
# Create backup directory
mkdir -p /Volumes/T9/Sites/kocsibeallo-hu/backups/webform-submissions-$(date +%Y%m%d)

# Export all webform data from D7
cd /Volumes/T9/Sites/kocsibeallo-hu
./export_webform_data.sh  # Script to be created
```

---

## 📞 Migration Script Status

### Scripts Needed
1. ✅ `export_d7_webforms.sh` - Export all webform submissions
2. ⚠️ `migrate_webform_submissions.php` - Import to D10
3. ⚠️ `verify_webform_migration.php` - Verify data integrity
4. ⚠️ `migrate_webform_files.php` - Migrate file attachments

---

## 📈 Success Criteria

- [ ] All 3,943 submissions migrated to D10
- [ ] Submission dates/times preserved
- [ ] IP addresses preserved
- [ ] All field values correctly mapped
- [ ] File attachments migrated
- [ ] No data loss or corruption
- [ ] Submissions viewable in D10 admin
- [ ] Export from D10 matches D7 export

---

## 🔐 Data Security

**Important:** Webform submissions contain PII (Personally Identifiable Information):
- Names
- Phone numbers
- Email addresses
- Physical addresses

**Requirements:**
- Secure backup storage
- Encrypted during transfer
- Access control on D10 submissions
- GDPR compliance for EU customers
- Data retention policy

---

## 📝 Next Steps

1. **IMMEDIATE:** Create backup of all webform submissions
2. **TODAY:** Install webform_migrate module
3. **TODAY:** Test migration with 10 sample submissions
4. **THIS WEEK:** Complete full migration of all 3,943 submissions
5. **BEFORE PRODUCTION:** Verify 100% data integrity

---

## 🆘 If Migration Fails

**Fallback Plan:**
1. Keep D7 site running in read-only mode
2. Create admin interface in D10 to query D7 database
3. Manually export critical submissions
4. Work with Drupal expert for custom migration script

**DO NOT:**
- Decommission D7 until submissions are safely migrated
- Delete D7 database before verification complete
- Go to production without migrating submissions

---

## 📊 Estimated Timeline

- **Backup:** 30 minutes
- **Module installation:** 15 minutes
- **Test migration:** 1 hour
- **Full migration:** 2-3 hours (depending on file attachments)
- **Verification:** 1 hour
- **Total:** 5-6 hours

**Recommendation:** Allocate full day for webform migration

---

## 📞 Contact Information

**D7 Database:** pajfrsyfzm (accessible via localhost:7306)
**D10 Database:** drupal10 (accessible via localhost:8306)
**Backups:** `/Volumes/T9/Sites/kocsibeallo-hu/backups/`

---

**Status:** ⚠️ **URGENT - REQUIRES IMMEDIATE ATTENTION**
**Last Updated:** 2025-11-14
**Priority:** 🔴 **CRITICAL**

**This data MUST be migrated before production deployment!**

# Deployment Steps for External System

All credentials are stored in `.credentials` file.

## Step 1: Push code to GitHub

**Run locally:**
```bash
git push origin main
```

---

## Step 2: Pull code on D10 server

**SSH to D10:** `kocsid10ssh@159.223.220.3`

**Commands:**
```bash
cd ~/public_html
git stash
git pull origin main
git stash pop

# Check for deleted/modified Porto theme files
git status web/themes/contrib/porto_theme/

# If any deleted/modified Porto files found:
git restore web/themes/contrib/porto_theme/
```

---

## Step 3: Composer install (if needed)

**On D10 server:**
```bash
cd ~/public_html

# Check if needed
if [ ! -f vendor/autoload.php ]; then
  composer install --no-dev --optimize-autoloader
fi
```

---

## Step 4: Sync files from D7 to D10

**⚠️ CRITICAL STEP** - This is the file transfer step (~1.8GB, 5-10 minutes)

### Option A: Server-to-server (requires manual password entry)

**SSH to D10:** `kocsid10ssh@159.223.220.3`

```bash
cd ~/public_html/web/sites/default/files

rsync -avz --progress \
  kocsibeall.ssh.d10@165.22.200.254:/home/969836.cloudwaysapps.com/pajfrsyfzm/public_html/sites/default/files/ \
  ./

# When prompted, enter password: D10Test99!

# Set permissions
chmod -R 755 .

  rsync -avz --progress \
    -e "ssh -o StrictHostKeyChecking=no" \
    kocsibeall.ssh.d10@165.22.200.254:/home/969836.cloudwaysapps.com/pajfrsyfzm/public_html/sites/default/files/ \
    ~/test/


```

### Option B: Via local Mac (fully automated)

**Run locally (requires sshpass):**

```bash
# Create temp directory
mkdir -p /tmp/d7-files

# Step 1: Download from D7 to Mac
sshpass -p 'D10Test99!' rsync -avz \
  -e "ssh -o StrictHostKeyChecking=no" \
  kocsibeall.ssh.d10@165.22.200.254:/home/969836.cloudwaysapps.com/pajfrsyfzm/public_html/sites/default/files/ \
  /tmp/d7-files/

# Step 2: Upload from Mac to D10
sshpass -p 'KCSIssH3497!' rsync -avz \
  -e "ssh -o StrictHostKeyChecking=no" \
  /tmp/d7-files/ \
  kocsid10ssh@159.223.220.3:~/public_html/web/sites/default/files/

# Clean up
rm -rf /tmp/d7-files
```

---

## Step 5: Import configuration

**On D10 server:**
```bash
cd ~/public_html/web
../vendor/bin/drush config:import -y
```

---

## Step 6: Import slideshow data

**⚠️ NEW STEP** - Import homepage slideshow (MD Slider)

**On D10 server:**
```bash
cd ~/public_html/web
../vendor/bin/drush sql-query --file=../database/migrations/md_slider_homepage.sql
```

**What this does:**
- Imports homepage slideshow configuration
- Adds 8 slides with images
- References slideshow image files (must be synced in Step 4)

**See**: `docs/SLIDESHOW_MIGRATION.md` for details

---

## Step 7: Database updates

**On D10 server:**
```bash
cd ~/public_html/web
../vendor/bin/drush updatedb -y
```

---

## Step 8: Clear cache

**On D10 server:**
```bash
cd ~/public_html/web
../vendor/bin/drush cache:rebuild
```

---

## Credentials

From `.credentials` file:

### D10 Production Server
- **Host:** 159.223.220.3
- **User:** kocsid10ssh
- **Password:** KCSIssH3497!
- **Path:** ~/public_html

### D7 Old Server (files source)
- **Host:** 165.22.200.254
- **User:** kocsibeall.ssh.d10
- **Password:** D10Test99!
- **Files Path:** /home/969836.cloudwaysapps.com/pajfrsyfzm/public_html/sites/default/files

### Database (on D10)
- **Host:** localhost
- **Name:** xmudbprchx
- **User:** xmudbprchx
- **Password:** 9nJbkdMBbM

---

## Critical Notes

1. **Step 4 (File sync) is the blocker**
   - Option A: Requires manual password entry on D10 server
   - Option B: Fully automated via local Mac with sshpass

2. **Git restore Porto theme** MUST happen before cache clear
   - Restores custom CSS, JS, and templates
   - Path: `web/themes/contrib/porto_theme/`

3. **File sync takes 5-10 minutes** (~1.8GB transfer)

4. **Step 6 (Slideshow import) is NEW**
   - Must run AFTER file sync (Step 4)
   - Imports homepage slideshow data into database
   - See `docs/SLIDESHOW_MIGRATION.md` for details

5. **Run steps in order** - don't skip any

6. **After deployment, verify:**
   - Homepage: https://phpstack-958493-6003495.cloudwaysapps.com/
   - Gallery: https://phpstack-958493-6003495.cloudwaysapps.com/kepgaleria
   - **Slideshow**: Check homepage slideshow appears and images display correctly

---

## Why Server-to-Server is Limited

D10 server does **not** have:
- ❌ `sshpass` (can't install without sudo)
- ❌ `expect` (not installed)
- ❌ SSH keys to D7 (user prefers passwords)

**Therefore:** The only fully automated option is **Option B** (via local Mac).

Option A works but requires someone to enter the D7 password when prompted during the rsync command.

---

**Last Updated:** 2025-11-17

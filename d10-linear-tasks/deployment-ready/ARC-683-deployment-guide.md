# ARC-683: Create Missing Sitemap Page

## Pre-deployment Checklist
- [ ] CSS changes committed to Git
- [ ] Sitemap content verified locally

---

## Deployment Commands

### Step 1: Deploy CSS Changes

```bash
# SSH to production server
SSH_AUTH_SOCK="" sshpass -p 'KCSIssH3497!' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no kocsid10ssh@159.223.220.3

# Navigate and pull
cd ~/public_html
git pull origin main

# Clear cache
cd web && ../vendor/bin/drush cr
```

### Step 2: Create Sitemap Page on Production

Since this is content (not config), you need to create the page manually.

**Option A: Via Drush (copy this entire command)**

```bash
cd ~/public_html/web && ../vendor/bin/drush php-eval "
\$node = \Drupal\node\Entity\Node::create([
  'type' => 'page',
  'title' => 'Oldaltérkép',
  'body' => [
    'value' => '<h2>Oldaltérkép</h2>
<div class=\"sitemap-content\">
<h3>Főoldal</h3>
<ul>
  <li><a href=\"/\">Nyitólap</a></li>
</ul>
<h3>Kocsibeálló típusok</h3>
<ul>
  <li><a href=\"/egyedi-nyitott-kocsibealloink\">Egyedi nyitott kocsibeállók</a></li>
  <li><a href=\"/ximax-kocsibealloink\">XIMAX kocsibeállók</a>
    <ul>
      <li><a href=\"/node/705\">XIMAX Wing kocsibeálló</a></li>
      <li><a href=\"/node/643\">XIMAX Linea kocsibeálló</a></li>
      <li><a href=\"/node/642\">XIMAX Portoforte kocsibeálló</a></li>
      <li><a href=\"/node/673\">Ximax NEO kocsibeálló</a></li>
    </ul>
  </li>
  <li><a href=\"/palram-autobealloink\">Palram autóbeálló típusok</a>
    <ul>
      <li><a href=\"/node/696\">Palram Arizona 5000</a></li>
      <li><a href=\"/node/697\">Palram Arcadia</a></li>
      <li><a href=\"/node/703\">Palram Atlas 5000</a></li>
    </ul>
  </li>
  <li><a href=\"/napelemes-kocsibealloink\">Napelemes kocsibeállók</a></li>
  <li><a href=\"/node/679\">Zárt garázsok</a></li>
  <li><a href=\"/node/588\">Gabion kocsibeállók</a></li>
  <li><a href=\"/node/589\">Fedett parkolók</a></li>
</ul>
<h3>Galériák</h3>
<ul>
  <li><a href=\"/kepgaleria\">Kocsibeálló munkáink</a></li>
  <li><a href=\"/kepgaleria/field_gallery_tag/egyedi-nyitott-146\">Egyedi kocsibeállók</a></li>
  <li><a href=\"/kepgaleria/field_gallery_tag/ximax\">Ximax kocsibeállók</a></li>
  <li><a href=\"/kepgaleria/field_gallery_tag/palram-194\">Palram kocsibeállók</a></li>
  <li><a href=\"/kepgaleria/field_gallery_tag/napelemes\">Napelemes kocsibeállók</a></li>
  <li><a href=\"/kepgaleria/field_szerkezet_anyaga/aluminium-123\">Alumínium kocsibeállók</a></li>
  <li><a href=\"/kepgaleria/field_szerkezet_anyaga/ragasztott-fa-155\">Fa kocsibeállók</a></li>
  <li><a href=\"/kepgaleria/field_cimkek/dupla-kocsibeallo-172\">Dupla kocsibeállók</a></li>
  <li><a href=\"/kepgaleria/field_cimkek/modern-kocsibeallo-170\">Modern kocsibeállók</a></li>
</ul>
<h3>Információ</h3>
<ul>
  <li><a href=\"/blog\">Blog</a></li>
  <li><a href=\"/node/598\">GYIK - Gyakori kérdések</a></li>
  <li><a href=\"/node/251\">Mit építünk</a></li>
</ul>
<h3>Kapcsolat</h3>
<ul>
  <li><a href=\"/node/144\">Ajánlatkérés</a></li>
  <li><a href=\"/node/145\">Kapcsolat</a></li>
</ul>
</div>',
    'format' => 'full_html',
  ],
  'status' => 1,
  'path' => ['alias' => '/oldalterkep', 'pathauto' => FALSE],
]);
\$node->save();
echo 'Created node ' . \$node->id();
"
```

**Option B: Via Admin UI**
1. Go to /node/add/page
2. Title: Oldaltérkép
3. Text format: Full HTML
4. Paste the HTML content
5. Set URL alias: /oldalterkep
6. Save

---

## Verification Steps

1. Visit https://phpstack-958493-6003495.cloudwaysapps.com/oldalterkep
2. Verify all sections display correctly
3. Check all links work
4. Verify hover effects (gold color)
5. Test on mobile

---

## Rollback Plan

```bash
# For CSS changes
cd ~/public_html
git checkout HEAD~1 -- web/themes/contrib/porto_theme/css/custom-user.css
cd web && ../vendor/bin/drush cr

# For content, delete the node via UI or:
../vendor/bin/drush entity:delete node [NODE_ID]
```

---

## Files Changed
- `web/themes/contrib/porto_theme/css/custom-user.css` (CSS styling)
- Node 776 created (content - must be recreated on production)

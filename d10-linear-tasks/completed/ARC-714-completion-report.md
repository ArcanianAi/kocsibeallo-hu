# ARC-714: Fix Frontpage Blog Entry Links

## Linear Task Link
https://linear.app/arcanian/issue/ARC-714/frontpage-blog-entries-link-to-wrong-page-refresh-instead-of-blog-post

---

## Summary
Fixed blog entry links on frontpage that were pointing to "/" (homepage) instead of actual blog posts. Both title links and "Read More" buttons now navigate to correct blog post URLs.

---

## Changes Made

### Files Modified
1. `config/sync/views.view.blog.yml`
   - Line 296: Changed `link_to_entity: false` to `link_to_entity: true`
   - This makes the title field link to the node entity

2. `web/themes/contrib/porto_theme/templates/view/blog/block_blog/views-view-fields--blog--block-1.html.twig`
   - Line 50: Removed extra `<a>` wrapper around title (now uses built-in entity link)
   - Line 54: Changed `href="{{ fields.path.content }}"` to `href="{{ path('entity.node.canonical', {'node': row.nid}) }}"`

### Root Cause
- View's title field had `link_to_entity: false`
- Template used `fields.path.content` which rendered markup instead of URL
- Both issues caused links to point to "/" instead of node URL

---

## Local Verification

1. Navigate to http://localhost:8090/
2. Scroll to "BLOG BEJEGYZÉSEINK" section
3. Verify blog entry titles link to actual posts (e.g., `/blog/modern-kocsibeallo-okos-technologiakkal-...`)
4. Verify "Read More" buttons link to same URLs
5. Click links to confirm navigation works

**Result**: ✅ All 3 blog entries now link correctly

---

## Remote Deployment

```bash
# SSH to Nexcess
SSH_AUTH_SOCK="" sshpass -p 'LongRagHaltsLied' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no a17d7af6_1@d99a9d9894.nxcli.io

# Deploy
cd ~/9df7d73bf2.nxcli.io/drupal
git pull origin main
cd web && ../vendor/bin/drush config:import -y
../vendor/bin/drush cr
```

---

## Verification on Nexcess

1. Visit https://9df7d73bf2.nxcli.io/
2. Check blog entry links point to `/blog/[slug]`
3. Test clicking through to blog posts

---

## Time Spent
~15 minutes

---

## Commit
`0820bd5` - ARC-714: Fix frontpage blog entry links pointing to homepage

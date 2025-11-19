# Kocsibeallo.hu D10 Migration - Continuation Guide

## Quick Start

When starting a new Claude Code session, read this file first to resume work.

Perfect! That makes this much more powerful. Here's the optimized version leveraging your Linear MCP connection:

---

**CLAUDE CODE TASK: Autonomous Drupal 10 Development with Linear Integration**

**OBJECTIVE:**
Execute Drupal 10 tasks from Linear in the local container with full automation, bi-directional sync, and deployment documentation.

**INITIALIZATION:**

1. **Connect to Linear via MCP** and fetch all relevant D10 tasks
2. **Create local documentation structure**:
```
/home/claude/d10-linear-tasks/
├── README.md (master tracker with Linear links)
├── tasks-pulled/
│   └── linear-tasks-snapshot.json
├── in-progress/
│   └── [LINEAR-ID]-[name].md (active work log)
├── completed/
│   └── [LINEAR-ID]-completion-report.md
├── deployment-ready/
│   └── [LINEAR-ID]-deployment-guide.md
└── logs/
    ├── execution-log.md
    └── linear-sync-log.md
```

**EXECUTION WORKFLOW:**

**For each Linear task:**
1. Pull task details (ID, title, description, labels, priority, dependencies)
2. Create working document in `in-progress/[LINEAR-ID]-[name].md`
3. Execute changes in local D10 container
4. Document every change in real-time
5. Update Linear task with progress comments
6. Run validation/tests
7. Move to `completed/` with full report
8. Generate deployment checklist in `deployment-ready/`
9. Update Linear task status (if allowed)
10. **Automatically proceed to next task**

**LINEAR INTEGRATION REQUIREMENTS:**

- **Before starting each task**: Comment in Linear: "🤖 Claude Code: Starting task in local container"
- **During execution**: Post significant milestones as comments
- **After completion**: Comment with summary + link to local documentation
- **On error**: Comment with error details and recovery plan

**TASK PRIORITIZATION:**
- Respect Linear priority order
- Handle dependencies automatically (skip if blocker not done)
- Flag parallel-executable tasks

**DOCUMENTATION PER TASK:**

Each `[LINEAR-ID]-completion-report.md` includes:
- 📎 Linear task link
- ✅ Changes made (files, configs, commands)
- 🔍 Local verification steps
- 📋 Remote deployment script (copy-paste ready)
- ⚠️ Dependencies & risks
- 🧪 Test results with evidence
- 📸 Screenshots/logs where relevant
- ⏱️ Time spent

**DEPLOYMENT-READY FORMAT:**

Each `[LINEAR-ID]-deployment-guide.md`:
```markdown
# [LINEAR-ID]: [Task Title]

## Pre-deployment Checklist
- [ ] Backup verified
- [ ] Dependencies checked
- [ ] Staging tested

## Deployment Commands
```bash
# Copy-paste ready commands
```

## Verification Steps
1. ...

## Rollback Plan
```bash
# Emergency rollback
```
```

**ERROR HANDLING:**
- Log to `logs/error-log.md`
- Comment on Linear task
- Create recovery plan
- Continue to next task (non-blocking)

**5-HOUR CHECKPOINT:**
After completion, I'll have:
- All tasks attempted and documented
- Linear updated with status
- `deployment-ready/` folder with approval-ready guides
- Clear view of what's ready vs. what needs attention

**EXECUTION MODE:**
Autonomous, sequential, fully documented, Linear-synced. Begin immediately upon receiving this prompt.

---

Be aware to avoid this kind of errors>

  ⎿ API Error: 400 {"type":"error","error":{"type":"invalid_request_error","mess
    age":"messages.1.content.41.image.source.base64.data: Image does not match
    the provided media type
    image/jpeg"},"request_id":"req_011CVHfr8tXvN52oEDC2Av1W"}



---

## Project Overview

Drupal 7 to Drupal 10 migration for kocsibeallo.hu (carport/garage company).

**Linear Project:** https://linear.app/arcanian/project/kocsibeallohu-d7-d10-migration-497436380d6b

---

## Environments

| Environment | URL | SSH |
|------------|-----|-----|
| **Local D10** | http://localhost:8090 | `docker exec pajfrsyfzm-d10-cli bash` |
| **Nexcess Staging** | https://9df7d73bf2.nxcli.io | See below |
| **D7 Live** | https://www.kocsibeallo.hu | Reference only |

### Nexcess SSH

```bash
SSH_AUTH_SOCK="" sshpass -p 'LongRagHaltsLied' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=30 a17d7af6_1@d99a9d9894.nxcli.io
```

Site directory: `~/9df7d73bf2.nxcli.io/drupal`

### Local Docker Commands

```bash
# Clear cache
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush cr"

# Import config
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush config:import -y"

# SQL query
docker exec pajfrsyfzm-d10-cli bash -c "cd /app/web && ../vendor/bin/drush sql-query 'QUERY'"
```

---

## Workflow

1. Work on local Docker container (localhost:8090)
2. Git commit after each task
3. Push to GitHub
4. Deploy to Nexcess: `git pull && drush config:import -y && drush cr`
5. Verify on Nexcess
6. Update Linear with completion comment
7. Mark Linear task as Done

---

## Current Task Status (2025-11-19)

### Completed Today

| ID | Task | Commit |
|----|------|--------|
| ARC-714 | Fix frontpage blog entry links | `0820bd5` |
| ARC-712 | Fix front page blog styling to match D7 | `b3f99a9` |
| ARC-713 | Add footer contact ribbon | `6e1700d` |
| ARC-715 | Add request for proposal form to gallery entries | `eaef355` |

### In Progress

**ARC-716: Fix tag display format on gallery entries**

**Problem:** On gallery entry pages (foto_a_galeriahoz nodes), taxonomy fields display as:
```
Típus
egyedi nyitott

Stílus
egyenes
```

Should display inline:
```
Típus: egyedi nyitott
Stílus: egyenes
```

**Investigation Done:**
- Config already has `label: inline` (see `core.entity_view_display.node.foto_a_galeriahoz.default.yml`)
- D10 HTML output lacks standard Drupal field BEM classes
- Need to add CSS to force inline display

**Next Step:** Add CSS to `custom.css` to make field labels inline

### Pending Tasks (from Linear)

- ARC-717: Remove author from blog displays
- ARC-718: Fix missing blog images on teaser view
- ARC-719: Limit gallery filtering combinations

---

## Key Files

### Theme Files
- `/web/themes/contrib/porto_theme/css/custom.css` - Main custom CSS
- `/web/themes/contrib/porto_theme/css/custom-blog.css` - Blog-specific CSS
- `/web/themes/contrib/porto_theme/porto.info.yml` - Theme info
- `/web/themes/contrib/porto_theme/porto.libraries.yml` - Asset libraries

### Templates
- `/web/themes/contrib/porto_theme/templates/view/blog/block_blog/views-view-fields--blog--block-1.html.twig` - Frontpage blog block
- `/web/themes/contrib/porto_theme/templates/includes/footer_option/f_default.html.twig` - Footer template
- `/web/themes/contrib/porto_theme/templates/node/gallery/node--foto-a-galeriahoz--teaser.html.twig` - Gallery teaser

### Configuration
- `/config/sync/views.view.blog.yml` - Blog view
- `/config/sync/block.block.porto_ajanlatkeres_webform.yml` - Proposal form block
- `/config/sync/core.entity_view_display.node.foto_a_galeriahoz.default.yml` - Gallery display

---

## Common Tasks

### Git Workflow

```bash
# Check status
git status

# Commit with proper format
git add [files] && git commit -m "$(cat <<'EOF'
ARC-XXX: Brief description

- Detail 1
- Detail 2

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

# Push
git push origin main
```

### Deploy to Nexcess

```bash
SSH_AUTH_SOCK="" sshpass -p 'LongRagHaltsLied' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=30 a17d7af6_1@d99a9d9894.nxcli.io "cd ~/9df7d73bf2.nxcli.io/drupal && git pull origin main && cd web && ../vendor/bin/drush config:import -y && ../vendor/bin/drush cr"
```

### Linear Updates

```
# Get task details
mcp__linear__get_issue with id: "ARC-XXX"

# Add completion comment
mcp__linear__create_comment with issueId and markdown body

# Mark as Done
mcp__linear__update_issue with id and state: "Done"
```

---

## Important Notes

1. **Porto Theme:** This is a custom Porto theme with many modifications. Check custom CSS files before making changes.

2. **Nexcess Connection:** SSH may timeout. Retry with longer timeout (60s) if needed.

3. **Config Import:** Always import config after pulling on Nexcess to apply block/view changes.

4. **Block Visibility in D10:** Use `entity_bundle:node` plugin (not `node_type`) for content type visibility.

5. **Field Display:** Porto theme may strip standard Drupal field classes. CSS fixes may be needed.

---

## Task Tracker Location

Full task documentation: `/d10-linear-tasks/`
- `README.md` - Task list overview
- `completed/` - Completion reports for finished tasks

---

## Documentation

- `/docs/NEXCESS-DEPLOYMENT.md` - Full deployment guide
- This file (`start_here.md`) - Quick start for new sessions

# Linear Integration - Task Management

**Date:** 2025-11-16
**Status:** Active

---

## 📊 Overview

This project uses **Linear** for task management and issue tracking through **Linear MCP (Model Context Protocol)** integration with Claude Code.

---

## 🔧 Configuration

### Team Information
- **Team Name:** Arcanian
- **Team ID:** `17c42b32-05aa-42dd-be9e-5c853585eca0`
- **Team Icon:** Dashboard

### Project Information
- **Project Name:** Kocsibeallo.hu D7 - D10 migration
- **Project ID:** `e24cc0c1-708d-4e42-9766-dbd4a17fcb3b`
- **Project URL:** https://linear.app/arcanian/project/kocsibeallohu-d7-d10-migration-497436380d6b
- **Status:** In Progress
- **Priority:** High
- **Start Date:** 2025-11-16
- **Target Date:** 2025-11-21
- **Lead:** laszlo.fazakas@arcanian.ai

---

## 📋 Issue Statuses Available

| Status | Type | ID |
|--------|------|-----|
| Triage | triage | `f07241d7-86b6-4cdf-92cc-ea4bafb09113` |
| Todo | unstarted | `bf3e4370-db94-4ec6-af4b-5fc29d10d9c4` |
| In Progress | started | `84c2cf87-964a-4364-a86c-cff5a69de9a4` |
| In Review | started | `10c48ee0-f79a-47c2-a993-17ba3103b03b` |
| Done | completed | `29193861-b4fc-42ac-919e-a0192dff1744` |
| Backlog | backlog | `b3bf2b17-7cfb-4344-9d5a-82c4079e7db3` |
| Canceled | canceled | `89272519-9efa-4368-aeaf-6b77be49e4a2` |
| Duplicate | canceled | `5dd9d765-7511-40df-826d-6fae9d37f8ac` |

---

## 🎯 Current Issues in Linear

All tasks from the local documentation have been migrated to Linear:

| Linear ID | Task | Status | Priority | Estimated |
|-----------|------|--------|----------|-----------|
| **ARC-677** | TASK-001: Fix Homepage Blog Count | Done | Medium | 30m |
| **ARC-678** | TASK-002: Add Sidebar Form Block | Done | High | 1-2h |
| **ARC-679** | TASK-003: Fix Blog Images Homepage | Done | High | 1-2h |
| **ARC-680** | TASK-004: Fix Embedded Images | Done | High | 3-5h |
| **ARC-681** | TASK-005: Fix Blog Formatting | In Progress | High | 2-3h |
| **ARC-682** | TASK-006: Fix Form Styling | Todo | High | 2-4h |
| **ARC-683** | TASK-007: Create Sitemap Page | Todo | High | 1-2h |

**Total:** 7 tasks, 11-19 hours estimated

---

## 🔄 Workflow: Creating Linear Issues

### Via Claude Code MCP

The Linear MCP integration allows creating and managing issues directly through Claude Code.

#### Creating a New Issue

```typescript
// Example: Create issue via MCP
mcp__linear__create_issue({
  team: "Arcanian",
  title: "TASK-XXX: Task Title",
  description: "## Description\n\n...",
  state: "Todo", // or "In Progress", "Done", etc.
  priority: 2, // 1=Urgent, 2=High, 3=Medium, 4=Low
  project: "e24cc0c1-708d-4e42-9766-dbd4a17fcb3b", // Project ID
  labels: ["migration", "drupal", "kocsibeallo"]
})
```

#### Adding Comments

```typescript
// Example: Add comment to issue
mcp__linear__create_comment({
  issueId: "issue-id-here",
  body: "## Progress Update\n\n..."
})
```

#### Updating Issues

```typescript
// Example: Update issue status
mcp__linear__update_issue({
  id: "issue-id-here",
  state: "Done",
  project: "e24cc0c1-708d-4e42-9766-dbd4a17fcb3b"
})
```

---

## 📝 Issue Template

When creating new issues, use this structure:

```markdown
## Description
Brief description of the task

## Current State
- What's currently happening
- What's wrong or missing

## Expected Result
- What should happen
- Success criteria

## Related URLs
- Local: http://localhost:8090/...
- Live: https://www.kocsibeallo.hu/...

## Priority: High/Medium/Low
## Estimated Time: X hours
```

---

## 🏷️ Labels Used

Standard labels for this project:
- `migration` - All migration-related tasks
- `drupal` - Drupal-specific work
- `kocsibeallo` - Project identifier
- `webform` - Webform-related tasks
- `media` - Media/image tasks
- `styling` - CSS/theme styling tasks

---

## 💡 Best Practices

### Task Creation
1. **Always include:**
   - Clear title with TASK-XXX prefix
   - Detailed description
   - Current vs expected state
   - Related URLs
   - Time estimate

2. **Connect to project:**
   - Always link issues to the project
   - Use consistent labeling

3. **Track progress:**
   - Add comments when making progress
   - Document solutions and findings
   - Update status regularly

### Status Management
- **Todo** - Not started, ready to work on
- **In Progress** - Actively working on it
- **In Review** - Completed, needs review
- **Done** - Completed and verified
- **Backlog** - Future work, not prioritized yet

### Priority Guidelines
- **Urgent (1)** - Blocking issues, critical bugs
- **High (2)** - Important features, major bugs
- **Medium (3)** - Standard tasks, minor bugs
- **Low (4)** - Nice-to-have, minor improvements

---

## 🔍 Querying Issues

### List All Project Issues
```typescript
mcp__linear__list_issues({
  team: "Arcanian",
  project: "Kocsibeallo.hu D7 - D10 migration"
})
```

### Filter by Status
```typescript
mcp__linear__list_issues({
  team: "Arcanian",
  state: "In Progress"
})
```

### Filter by Label
```typescript
mcp__linear__list_issues({
  team: "Arcanian",
  label: "webform"
})
```

---

## 📊 Integration Benefits

### Centralized Task Tracking
- All tasks in one place
- Easy to see overall progress
- Team visibility

### Seamless Development Workflow
- Create issues directly from code
- Update status while working
- Add progress notes without switching tools

### Documentation Link
- Linear issues linked to local docs
- Comments preserve implementation details
- Easy reference for future work

### Real-time Sync
- MCP provides real-time access
- No manual export/import needed
- Always up-to-date

---

## 🔗 Quick Links

- **Project Board:** https://linear.app/arcanian/project/kocsibeallohu-d7-d10-migration-497436380d6b
- **All Issues:** https://linear.app/arcanian/project/kocsibeallohu-d7-d10-migration-497436380d6b/issues
- **Team Dashboard:** https://linear.app/arcanian
- **Linear Docs:** https://linear.app/docs

---

## 📂 Related Documentation

- [README.md](../README.md) - Project overview
- [CURRENT_STATUS.md](../status/CURRENT_STATUS.md) - Current project status
- [work_items/README.md](../work_items/README.md) - Local task tracking

---

## 🆘 Common Operations

### Create Issue from Local Task
1. Read the local task file (e.g., `TASK-XXX_description.md`)
2. Extract key information (description, state, priority)
3. Create Linear issue with `mcp__linear__create_issue`
4. Add detailed comment with progress notes
5. Update local file to reference Linear issue ID

### Sync Completed Work
1. When task is done, update status to "Done"
2. Add comment with:
   - What was implemented
   - How it was tested
   - Any important notes
3. Update local documentation if needed

### Link Issues to Project
If an issue was created without project link:
```typescript
mcp__linear__update_issue({
  id: "issue-id",
  project: "e24cc0c1-708d-4e42-9766-dbd4a17fcb3b"
})
```

---

## 📈 Migration Summary

**Date:** 2025-11-16

All 7 work items from `docs/work_items/` have been successfully migrated to Linear:

- ✅ 4 completed tasks marked as "Done" with detailed comments
- 🚧 1 task marked as "In Progress"
- 📋 2 tasks marked as "Todo"

All issues include:
- Full descriptions from original task files
- Progress notes as comments
- Proper status mapping
- Project linkage
- Labels and priorities

---

**Last Updated:** 2025-11-16
**Maintained By:** Claude Code + Linear MCP

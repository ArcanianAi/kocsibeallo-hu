# Changes Log

This directory contains documentation for major changes made to the project.

---

## Purpose

Track significant structural, architectural, or deployment changes that affect:
- Repository structure
- Deployment workflows
- Breaking changes
- Major refactors
- Critical bug fixes

---

## Change Log Format

Each change is documented in a separate markdown file with the naming convention:

```
YYYY-MM-DD-brief-description.md
```

---

## Change Log Entries

| Date | Change | Impact | Status |
|------|--------|--------|--------|
| 2025-11-16 | [Repository Restructure](2025-11-16-repository-restructure.md) | HIGH - All deployment paths changed | ✅ Complete Locally |

---

## How to Document Changes

When making a significant change:

1. Create a new file: `changes/YYYY-MM-DD-change-name.md`
2. Include:
   - Summary
   - Problem statement
   - Solution
   - Technical changes
   - Impact assessment
   - Migration steps
   - Verification steps
   - Related documentation
3. Update this README with entry in table above
4. Commit with descriptive message

---

## Change Categories

### HIGH Impact
- Repository structure changes
- Deployment workflow changes
- Breaking API changes
- Database schema changes
- Major dependency updates

### MEDIUM Impact
- Configuration changes
- New features
- Significant refactors
- Security updates

### LOW Impact
- Bug fixes
- Documentation updates
- Minor dependency updates
- Code style changes

---

**Last Updated:** 2025-11-16

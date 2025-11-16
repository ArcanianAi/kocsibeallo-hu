# Scripts Directory

This directory contains all scripts for deployment, migration, and utilities for the Kocsibeallo.hu Drupal 7 to Drupal 10 migration project.

## Directory Structure

```
scripts/
├── deployment/     # Production deployment and setup scripts
├── migration/      # D7 to D10 migration helper scripts
└── utilities/      # General utility scripts
```

## Migration Scripts (`migration/`)

These scripts were used during the Drupal 7 to Drupal 10 migration process:

### `discover_d7_filesystem.sh`
**Purpose:** Analyzes the Drupal 7 codebase structure

**Usage:**
```bash
./scripts/migration/discover_d7_filesystem.sh
```

**Output:**
- Discovers custom modules, themes, and files
- Creates a summary of D7 codebase structure
- Helps identify what needs to be migrated

### `download_missing_files.sh`
**Purpose:** Downloads missing files from the live site

**Usage:**
```bash
./scripts/migration/download_missing_files.sh
```

**Features:**
- Reads from `docs/missing_files_list.csv`
- Downloads files from https://www.kocsibeallo.hu
- Saves to appropriate directories in D10
- Includes retry logic and error handling

### `download_priority_files.sh`
**Purpose:** Downloads high-priority files needed for critical content

**Usage:**
```bash
./scripts/migration/download_priority_files.sh
```

**Features:**
- Focuses on critical files first
- Faster execution for urgent file recovery
- Used when full file migration is not yet needed

---

## Deployment Scripts (`deployment/`)

These scripts help with deploying and setting up the Drupal 10 environment.

### `setup.sh` (To be created)
**Purpose:** Initial setup after cloning the repository

**Will include:**
- Composer install
- Docker container startup
- Database import
- Configuration import
- File directory setup

### `deploy.sh` (To be created)
**Purpose:** Deploy to production or staging environment

**Will include:**
- Pull latest code
- Run composer install
- Import configuration
- Clear caches
- Database updates

---

## Utilities (`utilities/`)

General utility scripts for maintenance and development tasks.

---

## Usage Notes

### Making Scripts Executable

All scripts should be executable. If a script is not executable, run:
```bash
chmod +x scripts/migration/script-name.sh
chmod +x scripts/deployment/script-name.sh
chmod +x scripts/utilities/script-name.sh
```

### Running Scripts

From project root:
```bash
# Migration scripts
./scripts/migration/discover_d7_filesystem.sh
./scripts/migration/download_missing_files.sh

# Deployment scripts
./scripts/deployment/setup.sh
./scripts/deployment/deploy.sh
```

### Docker Context

Some scripts may need to run inside Docker containers:
```bash
# Run inside D10 container
docker exec pajfrsyfzm-d10-cli bash -c "cd /app && ./scripts/deployment/setup.sh"
```

---

## Best Practices

1. **Always test scripts** in development before production
2. **Add error handling** to all scripts
3. **Document** what each script does
4. **Use relative paths** when possible
5. **Check prerequisites** before running
6. **Log output** for debugging

---

## Contributing

When adding new scripts:
1. Place in appropriate subdirectory
2. Add description in this README
3. Make executable (`chmod +x`)
4. Add usage examples
5. Include error handling
6. Test thoroughly

---

**Last Updated:** 2025-11-16

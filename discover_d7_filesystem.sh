#!/bin/bash
# Comprehensive D7 filesystem discovery

D7_ROOT="${1:-drupal7-codebase}"

if [ ! -d "$D7_ROOT" ]; then
    echo "Error: D7 directory '$D7_ROOT' not found"
    echo "Usage: ./discover_d7_filesystem.sh /path/to/drupal7"
    exit 1
fi

OUTPUT_DIR="d7_discovery"
mkdir -p "$OUTPUT_DIR"

echo "🔍 Discovering Drupal 7 codebase at: $D7_ROOT"
echo ""

# Function to extract module info
extract_module_info() {
    local info_file=$1
    local module_dir=$(dirname "$info_file")
    local module_name=$(basename "$module_dir")

    # Get version
    local version=$(grep "^version" "$info_file" | cut -d'=' -f2 | tr -d ' "' | head -1)

    # Get dependencies
    local dependencies=$(grep "^dependencies\[\]" "$info_file" | cut -d'=' -f2 | tr -d ' ' | paste -sd "," -)

    # Get core compatibility
    local core=$(grep "^core" "$info_file" | cut -d'=' -f2 | tr -d ' "x' | head -1)

    echo "$module_name|$version|$dependencies|$core"
}

# 1. CONTRIB MODULES
echo "📦 Discovering contrib modules..."
{
    echo "Module Name|Version|Dependencies|Core"
    echo "-----------|-------|------------|----"
    find "$D7_ROOT/sites/all/modules" -maxdepth 2 -name "*.info" -type f 2>/dev/null | \
    grep -v "/tests/" | \
    grep -v "_test.info" | \
    while read info_file; do
        # Skip if it's in a subdirectory of a module (like commerce submodules)
        module_dir=$(dirname "$info_file")
        parent_dir=$(dirname "$module_dir")
        if [ "$(basename "$parent_dir")" = "modules" ]; then
            extract_module_info "$info_file"
        fi
    done | sort
} > "$OUTPUT_DIR/contrib_modules.txt"

contrib_count=$(grep -v "^Module Name" "$OUTPUT_DIR/contrib_modules.txt" | grep -v "^---" | wc -l | tr -d ' ')
echo "   Found: $contrib_count contrib modules"

# 2. DETECT CUSTOM MODULES (porto_* modules)
echo "🔧 Discovering custom modules..."
{
    echo "Module Name|Version|Dependencies|Core"
    echo "-----------|-------|------------|----"
    find "$D7_ROOT/sites/all/modules" -maxdepth 2 -name "*.info" -type f 2>/dev/null | \
    grep -v "/tests/" | \
    grep -v "_test.info" | \
    while read info_file; do
        module_dir=$(dirname "$info_file")
        module_name=$(basename "$module_dir")
        parent_dir=$(dirname "$module_dir")
        # Custom modules are those starting with porto_
        if [ "$(basename "$parent_dir")" = "modules" ] && [[ "$module_name" == porto_* ]]; then
            extract_module_info "$info_file"
        fi
    done | sort
} > "$OUTPUT_DIR/custom_modules.txt"

custom_count=$(grep -v "^Module Name" "$OUTPUT_DIR/custom_modules.txt" | grep -v "^---" | wc -l | tr -d ' ')
echo "   Found: $custom_count custom modules"

# 3. SUB-MODULES (modules within other modules like commerce)
echo "📦 Discovering sub-modules..."
{
    echo "Module Name|Parent|Version"
    echo "-----------|------|-------"
    find "$D7_ROOT/sites/all/modules" -mindepth 3 -name "*.info" -type f 2>/dev/null | \
    grep -v "/tests/" | \
    grep -v "_test.info" | \
    while read info_file; do
        module_dir=$(dirname "$info_file")
        module_name=$(basename "$module_dir")
        parent_module=$(basename "$(dirname "$(dirname "$module_dir")")")
        version=$(grep "^version" "$info_file" | cut -d'=' -f2 | tr -d ' "' | head -1)
        echo "$module_name|$parent_module|$version"
    done | sort
} > "$OUTPUT_DIR/submodules.txt"

submodules_count=$(grep -v "^Module Name" "$OUTPUT_DIR/submodules.txt" | grep -v "^---" | wc -l | tr -d ' ')
echo "   Found: $submodules_count sub-modules"

# 4. THEMES
echo "🎨 Discovering themes..."
{
    echo "Theme Name|Version|Base Theme|Engine"
    echo "----------|-------|----------|------"
    find "$D7_ROOT/sites/all/themes" -maxdepth 2 -name "*.info" -type f 2>/dev/null | while read info_file; do
        local theme_dir=$(dirname "$info_file")
        local theme_name=$(basename "$theme_dir")
        local version=$(grep "^version" "$info_file" | cut -d'=' -f2 | tr -d ' "' | head -1)
        local base_theme=$(grep "^base theme" "$info_file" | cut -d'=' -f2 | tr -d ' "' | head -1)
        local engine=$(grep "^engine" "$info_file" | cut -d'=' -f2 | tr -d ' "' | head -1)
        echo "$theme_name|$version|$base_theme|$engine"
    done | sort
} > "$OUTPUT_DIR/themes.txt"

themes_count=$(grep -v "^Theme Name" "$OUTPUT_DIR/themes.txt" | grep -v "^---" | wc -l | tr -d ' ')
echo "   Found: $themes_count themes"

# 5. LIBRARIES
echo "📚 Discovering libraries..."
if [ -d "$D7_ROOT/sites/all/libraries" ]; then
    ls -1 "$D7_ROOT/sites/all/libraries" 2>/dev/null | grep -v ".zip" | grep -v "README.txt" | grep -v ".DS_Store" > "$OUTPUT_DIR/libraries.txt"
    libraries_count=$(wc -l < "$OUTPUT_DIR/libraries.txt" | tr -d ' ')
    echo "   Found: $libraries_count libraries"
else
    echo "   No libraries directory found"
    echo "No libraries directory" > "$OUTPUT_DIR/libraries.txt"
fi

# 6. CHECK DRUPAL VERSION
echo "📋 Checking Drupal version..."
if [ -f "$D7_ROOT/CHANGELOG.txt" ]; then
    drupal_version=$(head -1 "$D7_ROOT/CHANGELOG.txt" | grep -oE '[0-9]+\.[0-9]+' | head -1)
    echo "   Drupal version: $drupal_version"
    echo "$drupal_version" > "$OUTPUT_DIR/drupal_version.txt"
else
    echo "   Unknown (CHANGELOG.txt not found)"
    echo "Unknown" > "$OUTPUT_DIR/drupal_version.txt"
fi

# 7. CREATE SUMMARY
echo ""
echo "📊 Creating summary..."
cat > "$OUTPUT_DIR/SUMMARY.txt" << SUMMARY
Drupal 7 Codebase Discovery Summary
====================================
Analyzed: $D7_ROOT
Date: $(date)

Statistics:
-----------
Drupal Version:   $(cat "$OUTPUT_DIR/drupal_version.txt")
Contrib Modules:  $contrib_count
Custom Modules:   $custom_count
Sub-modules:      $submodules_count
Themes:           $themes_count
Libraries:        $libraries_count

Files Generated:
----------------
- contrib_modules.txt  : All contrib modules with versions
- custom_modules.txt   : All custom modules (porto_*)
- submodules.txt       : Sub-modules (e.g., commerce submodules)
- themes.txt           : All themes
- libraries.txt        : All libraries
- drupal_version.txt   : Drupal core version

Custom Code Identified:
-----------------------
Custom Modules:
$(grep -v "^Module Name" "$OUTPUT_DIR/custom_modules.txt" | grep -v "^---" | cut -d'|' -f1 | sed 's/^/  - /')

Custom Themes:
  - Porto
  - Porto_sub

Next Steps:
-----------
1. Review contrib_modules.txt - these need to be installed in D7
2. Backup custom_modules.txt modules - CRITICAL for migration
3. Check for D10 equivalents in contrib modules
4. Plan custom module migration strategy
5. Test D7 installation before migration
SUMMARY

cat "$OUTPUT_DIR/SUMMARY.txt"

echo ""
echo "✅ Discovery complete! Results saved in: $OUTPUT_DIR/"
echo ""
echo "📄 View results:"
echo "   cat $OUTPUT_DIR/contrib_modules.txt"
echo "   cat $OUTPUT_DIR/custom_modules.txt"
echo "   cat $OUTPUT_DIR/SUMMARY.txt"

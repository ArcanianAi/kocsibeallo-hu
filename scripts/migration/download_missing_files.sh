#!/bin/bash
#
# Download Missing Files from Production Site
# Downloads all missing product/content images from www.kocsibeallo.hu
# and imports them into the D10 development environment
#

set -e

LIVE_SITE="https://www.kocsibeallo.hu"
D10_CONTAINER="pajfrsyfzm-d10-cli"
TEMP_DIR="./temp_downloads"
D10_FILES_PATH="/app/web/sites/default/files"

echo "=========================================="
echo "Missing Files Recovery Script"
echo "=========================================="
echo ""

# Create temp directory
mkdir -p "$TEMP_DIR"
mkdir -p "$TEMP_DIR/field/image"
mkdir -p "$TEMP_DIR/banner"

echo "📥 Downloading missing files from $LIVE_SITE..."
echo ""

# Counter
TOTAL=0
SUCCESS=0
FAILED=0

# Download function
download_file() {
    local uri=$1
    local filepath=${uri#public://}
    local url="$LIVE_SITE/sites/default/files/$filepath"
    local local_path="$TEMP_DIR/$filepath"

    echo -n "  ⬇️  $filepath ... "

    if curl -f -s -o "$local_path" "$url"; then
        echo "✅"
        ((SUCCESS++))
    else
        echo "❌ (404 or error)"
        ((FAILED++))
    fi
    ((TOTAL++))
}

# High Priority Product Images
echo "🎯 Downloading Product Images (Priority: High)"
download_file "public://field/image/autobealloepites-kocsibeallo.hu_.jpg"
download_file "public://field/image/telki2.kocsibeallo.hujpg_.jpg"
download_file "public://field/image/vaszati-kkocsibeallo2.jpg"
download_file "public://field/image/magyarterrendezes-kocsibeallo.jpg"
download_file "public://field/image/polikarbonat-fedes-autobeallo.jpg"
download_file "public://field/image/polikarbonat2_0.jpg"
download_file "public://field/image/hasznos-kocsibeallo-h.jpg"
download_file "public://field/image/legximax-portoforte-ives-aluminium-kocsibeallo-2.jpg"
download_file "public://field/image/elektromos-autok-kocsibealloja_kocsibeallo.hu_.jpeg"
download_file "public://field/image/uveggarazs_egyedi_kocsibeallok_Deluxe_Building.jpg"
download_file "public://field/image/palram_arcadia_dupla_autobeallo_Deluxe_Building.jpg"
download_file "public://field/image/egyedi_tervezesu_kocsibeallo_deluxe_building_2(1).jpg"
download_file "public://field/image/karacsonyi_diszitesu_fa_kocsibeallo_deluxe_building.jpg"
download_file "public://field/image/uveg_fedes_kocsibeallo_deluxe_building.jpg"
download_file "public://field/image/ximax-portoforte-ives-aluminium-dupla-kocsibeallo-beton_aljzat_Deluxe_building.jpg"
download_file "public://field/image/ximax-linea-dupla-aluminium-kocsibeallo_deluxe_building.jpg"
download_file "public://field/image/elore_gyartott_kocsibeallo_Ximax_cegeknek_Deluxe_building.jpg"
download_file "public://field/image/Ximax_Portoforte_kocsibeallo_deluxe_building.jpg"
download_file "public://field/image/ximax_myport_7_kocsibeallo_deluxe_building.jpg"
download_file "public://field/image/szines_LED_csikokkal_felszerelt_egyedi_kocsibeallo_Deluxe_Building.jpg"
download_file "public://field/image/ragasztott-fa-szerkezetu-lamberiazott-zsindely-fedesu-kocsibeallo_Deluxe_Building.jpg"
download_file "public://field/image/vas_szerkezetu_Eco-autobeallo_Deluxe_Building.jpg"
download_file "public://field/image/egyedi_kocsibeallo_taroloval_Deluxe_Building.jpg"
download_file "public://field/image/napelemes_kocsibeallo_autobeallo_deluxe_building_5.jpg"
download_file "public://field/image/femhatasu_ragasztott_fa_kocsibeallo_deluxe_building_2.jpg"
download_file "public://field/image/egyedi_kocsibeallo_deluxe_building_6.jpg"
download_file "public://field/image/egyedi_kocsibeallo_deluxe_building.jpg"
download_file "public://field/image/egyedi_kocsibeallo_pingpong_asztallal_deluxe_building-5.png"

echo ""
echo "🏗️  Downloading Ximax Wing Series"
download_file "public://field/image/Ximax_Wing_antracit_aluminium_kocsibeallo_7.jpg"
download_file "public://field/image/Ximax_WING_aluminium_antracit_szinu_kocsibeallo5.jpg"
download_file "public://field/image/Ximax_WING_aluminium_antracit_szinu_kocsibeallo3.jpg"

echo ""
echo "📦 Downloading Prefabricated Models"
download_file "public://field/image/deluxe-eloregyartott-kocsibeallo-ximax-wing-05.jpg"
download_file "public://field/image/deluxe-eloregyartott-kocsibeallo-ximax-wing-1.jpg"
download_file "public://field/image/deluxe-autobeallo-ximax-eco-eloregyartott-aluminium-kocsibeallo-06.jpg"
download_file "public://field/image/deluxe-eloregyartott-autobeallo-ximax-linea-aluminium-17.jpg"
download_file "public://field/image/deluxe-eloregyartott-autobeallo-ximax-linea-aluminium-6.jpg"
download_file "public://field/image/deluxe-eloregyartott-autobeallo-ximax-eco-aluminium-05.jpg"

echo ""
echo "🏛️  Downloading Government Subsidy Campaign Images"
download_file "public://field/image/videki-otthonfelujitasi-tamogatas-egyedi-kocsibeallo-deluxe-building.jpg"
download_file "public://field/image/videki-otthonfelujitasi-tamogatas-eloregyarrtott-nyitott-kocsibeallo-deluxe-building.jpg"
download_file "public://field/image/videki-otthonfelujitasi-tamogatas-eloregyartott-teraszfedes-deluxe-building.jpg"
download_file "public://field/image/videki-otthonfelujitasi-tamogatas-eloteto-deluxe-building.jpg"
download_file "public://field/image/videki-otthonfelujitasi-tamogatas-napelemes-kocsibeallo-napelemes-teraszfedes-deluxe-building.jpg"
download_file "public://field/image/videki-otthonfelujitasi-tamogatas-telikert-deluxe-building.jpg"
download_file "public://field/image/videki-otthonfelujitasi-tamogatas-terasz-deluxe-building.jpg"
download_file "public://field/image/deluxe-building-videki-otthonfelujitasi-tamogatas-ragasztott-fa-szerkezetu-szendvics-panel-_fedesu_-zart-garazs_01.jpg"
download_file "public://field/image/egyedi-tervezesu-napelemmel-fedett-dupla-kocsibeallo-ragasztott-fa-szerkezettel-deluxe-kocsibeallo-15.jpg"

echo ""
echo "🌐 Downloading Additional Product Images"
download_file "public://field/image/kocsibeallo-elektromos autoknak_kocsibeallo.hu_.jpeg"

echo ""
echo "=========================================="
echo "📊 Download Summary"
echo "=========================================="
echo "Total files processed: $TOTAL"
echo "✅ Successfully downloaded: $SUCCESS"
echo "❌ Failed/Not found: $FAILED"
echo ""

if [ $SUCCESS -gt 0 ]; then
    echo "📤 Copying files to D10 container..."
    docker cp "$TEMP_DIR/." "$D10_CONTAINER:$D10_FILES_PATH/"

    echo "🔧 Setting permissions..."
    docker exec "$D10_CONTAINER" chown -R www-data:www-data "$D10_FILES_PATH"

    echo ""
    echo "✅ Files successfully imported to D10!"
    echo ""
    echo "🔄 Next steps:"
    echo "1. Re-run the file migration to register these files in D10 database:"
    echo "   docker exec $D10_CONTAINER bash -c \"cd /app/web && ../vendor/bin/drush migrate:rollback upgrade_d7_file --uri='http://localhost:8090' -y\""
    echo "   docker exec $D10_CONTAINER bash -c \"cd /app/web && ../vendor/bin/drush migrate:import upgrade_d7_file --uri='http://localhost:8090' -y\""
    echo ""
    echo "2. Check migration status:"
    echo "   docker exec $D10_CONTAINER bash -c \"cd /app/web && ../vendor/bin/drush migrate:status upgrade_d7_file --uri='http://localhost:8090'\""
else
    echo "⚠️  No files were downloaded successfully."
fi

# Cleanup
echo ""
echo "🧹 Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo "✅ Done!"

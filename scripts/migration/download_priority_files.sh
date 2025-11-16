#!/bin/bash
#
# Download Priority Missing Files from Production
#

LIVE_SITE="https://www.kocsibeallo.hu"
TEMP_DIR="./temp_downloads"
SUCCESS=0
FAILED=0

echo "==========================================  "
echo "Downloading Missing Files"
echo "=========================================="
echo ""

mkdir -p "$TEMP_DIR/field/image"

# List of high-priority files
files=(
    "field/image/autobealloepites-kocsibeallo.hu_.jpg"
    "field/image/telki2.kocsibeallo.hujpg_.jpg"
    "field/image/vaszati-kkocsibeallo2.jpg"
    "field/image/magyarterrendezes-kocsibeallo.jpg"
    "field/image/polikarbonat-fedes-autobeallo.jpg"
    "field/image/polikarbonat2_0.jpg"
    "field/image/hasznos-kocsibeallo-h.jpg"
    "field/image/legximax-portoforte-ives-aluminium-kocsibeallo-2.jpg"
    "field/image/elektromos-autok-kocsibealloja_kocsibeallo.hu_.jpeg"
    "field/image/kocsibeallo-elektromos autoknak_kocsibeallo.hu_.jpeg"
    "field/image/uveggarazs_egyedi_kocsibeallok_Deluxe_Building.jpg"
    "field/image/palram_arcadia_dupla_autobeallo_Deluxe_Building.jpg"
    "field/image/egyedi_tervezesu_kocsibeallo_deluxe_building_2(1).jpg"
    "field/image/karacsonyi_diszitesu_fa_kocsibeallo_deluxe_building.jpg"
    "field/image/uveg_fedes_kocsibeallo_deluxe_building.jpg"
    "field/image/ximax-portoforte-ives-aluminium-dupla-kocsibeallo-beton_aljzat_Deluxe_building.jpg"
    "field/image/ximax-linea-dupla-aluminium-kocsibeallo_deluxe_building.jpg"
    "field/image/elore_gyartott_kocsibeallo_Ximax_cegeknek_Deluxe_building.jpg"
    "field/image/Ximax_Portoforte_kocsibeallo_deluxe_building.jpg"
    "field/image/ximax_myport_7_kocsibeallo_deluxe_building.jpg"
    "field/image/szines_LED_csikokkal_felszerelt_egyedi_kocsibeallo_Deluxe_Building.jpg"
    "field/image/ragasztott-fa-szerkezetu-lamberiazott-zsindely-fedesu-kocsibeallo_Deluxe_Building.jpg"
    "field/image/vas_szerkezetu_Eco-autobeallo_Deluxe_Building.jpg"
    "field/image/egyedi_kocsibeallo_taroloval_Deluxe_Building.jpg"
    "field/image/Ximax_Wing_antracit_aluminium_kocsibeallo_7.jpg"
    "field/image/Ximax_WING_aluminium_antracit_szinu_kocsibeallo5.jpg"
    "field/image/Ximax_WING_aluminium_antracit_szinu_kocsibeallo3.jpg"
    "field/image/napelemes_kocsibeallo_autobeallo_deluxe_building_5.jpg"
    "field/image/femhatasu_ragasztott_fa_kocsibeallo_deluxe_building_2.jpg"
    "field/image/egyedi_kocsibeallo_deluxe_building_6.jpg"
    "field/image/egyedi_kocsibeallo_deluxe_building.jpg"
    "field/image/egyedi_kocsibeallo_pingpong_asztallal_deluxe_building-5.png"
    "field/image/deluxe-eloregyartott-kocsibeallo-ximax-wing-05.jpg"
    "field/image/deluxe-eloregyartott-kocsibeallo-ximax-wing-1.jpg"
    "field/image/deluxe-autobeallo-ximax-eco-eloregyartott-aluminium-kocsibeallo-06.jpg"
    "field/image/deluxe-eloregyartott-autobeallo-ximax-linea-aluminium-17.jpg"
    "field/image/deluxe-eloregyartott-autobeallo-ximax-linea-aluminium-6.jpg"
    "field/image/deluxe-eloregyartott-autobeallo-ximax-eco-aluminium-05.jpg"
    "field/image/videki-otthonfelujitasi-tamogatas-egyedi-kocsibeallo-deluxe-building.jpg"
    "field/image/videki-otthonfelujitasi-tamogatas-eloregyarrtott-nyitott-kocsibeallo-deluxe-building.jpg"
    "field/image/videki-otthonfelujitasi-tamogatas-eloregyartott-teraszfedes-deluxe-building.jpg"
    "field/image/videki-otthonfelujitasi-tamogatas-eloteto-deluxe-building.jpg"
    "field/image/videki-otthonfelujitasi-tamogatas-napelemes-kocsibeallo-napelemes-teraszfedes-deluxe-building.jpg"
    "field/image/videki-otthonfelujitasi-tamogatas-telikert-deluxe-building.jpg"
    "field/image/videki-otthonfelujitasi-tamogatas-terasz-deluxe-building.jpg"
    "field/image/deluxe-building-videki-otthonfelujitasi-tamogatas-ragasztott-fa-szerkezetu-szendvics-panel-_fedesu_-zart-garazs_01.jpg"
    "field/image/egyedi-tervezesu-napelemmel-fedett-dupla-kocsibeallo-ragasztott-fa-szerkezettel-deluxe-kocsibeallo-15.jpg"
)

for file in "${files[@]}"; do
    url="$LIVE_SITE/sites/default/files/$file"
    output="$TEMP_DIR/$file"
    filename=$(basename "$file")

    printf "%-80s" "  $filename"

    if curl -f -s -o "$output" "$url" 2>/dev/null; then
        size=$(du -h "$output" | cut -f1)
        echo "✅ ($size)"
        ((SUCCESS++))
    else
        echo "❌"
        ((FAILED++))
    fi
done

echo ""
echo "=========================================="
echo "Summary: $SUCCESS downloaded, $FAILED failed"
echo "=========================================="

if [ $SUCCESS -gt 0 ]; then
    echo ""
    echo "Files downloaded to: $TEMP_DIR"
    echo ""
    echo "Next: Copy to D10 container with:"
    echo "  docker cp temp_downloads/. pajfrsyfzm-d10-cli:/app/web/sites/default/files/"
fi

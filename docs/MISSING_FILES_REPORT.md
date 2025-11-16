# Missing Files Report - Drupal 7 to Drupal 10 Migration

**Generated:** 2025-11-15
**Migration Date:** November 2025
**Project:** kocsibeallo.hu

---

## Summary

### Public Files
- **Total Public Files in D7:** 1,512
- **Successfully Migrated:** 1,432 (94.7%)
- **Failed to Migrate:** 68 (4.5%)
- **Missing on Filesystem:** 12 (0.8%)

### Private Files
- **Total Private Files in D7:** 945
- **Successfully Migrated:** 0 (0%)
- **Status:** Migration not completed (path configuration issue)

---

## Missing Public Files (68 files)

### Category 1: Theme Demo/Placeholder Files (14 files)
These are sample/demo images that came with the Porto theme and were never physically uploaded:

| FID | Filename | Location | Impact |
|-----|----------|----------|--------|
| 624 | slide-1.jpg | public://banner/ | Low - Theme demo |
| 626 | slide-2.jpg | public://banner/ | Low - Theme demo |
| 629 | project-1.jpg | public:// | Low - Theme demo |
| 674 | team-1.jpg | public:// | Low - Theme demo |
| 675 | team-2.jpg | public:// | Low - Theme demo |
| 676 | team-3.jpg | public:// | Low - Theme demo |
| 677 | team-4.jpg | public:// | Low - Theme demo |
| 678 | team-5.jpg | public:// | Low - Theme demo |
| 679 | team-6.jpg | public:// | Low - Theme demo |
| 680 | team-7.jpg | public:// | Low - Theme demo |
| 686 | office-4.jpg | public:// | Low - Theme demo |
| 688 | office-2.jpg | public:// | Low - Theme demo |
| 690 | office-1.jpg | public:// | Low - Theme demo |
| 692 | office-3.jpg | public:// | Low - Theme demo |

**Action Required:** None - these were never used in actual content

---

### Category 2: Files with Encoding Issues (2 files)
Files with Hungarian special characters that may have filesystem naming issues:

| FID | Filename | Location | Impact |
|-----|----------|----------|--------|
| 1084 | kocsibeallo_ötletek.jpg | public:// | Medium - May exist with different encoding |
| 1182 | autóbeálló2.jpg | public:// | Medium - May exist with different encoding |

**Action Required:** Check if files exist with URL-encoded or different character encoding names

---

### Category 3: Content Images - Field Images (52 files)
Real content images that are referenced in nodes but missing from filesystem:

#### Product/Portfolio Images (26 files)
| FID | Filename | Notes |
|-----|----------|-------|
| 1340 | autobealloepites-kocsibeallo.hu_.jpg | Product showcase image |
| 1355 | telki2.kocsibeallo.hujpg_.jpg | Project photo - Telki |
| 1437 | vaszati-kkocsibeallo2.jpg | Product variant |
| 1445 | magyarterrendezes-kocsibeallo.jpg | Project reference |
| 1450 | színek-kocsibeallo1.jpg | Color options showcase |
| 1460 | rétegelt-ragasztott-fa-kocsibeálló1.jpg | Wood structure product |
| 1476 | polikarbonat-fedes-autobeallo.jpg | Polycarbonate roof product |
| 1477 | üvegtető- kocsibeálló2_0.jpg | Glass roof variant |
| 1478 | polikarbonat2_0.jpg | Polycarbonate variant |
| 1569 | hasznos-kocsibeallo-h.jpg | Utility carport |
| 1606 | legximax-portoforte-ives-aluminium-kocsibeallo-2.jpg | Ximax product line |
| 1608 | szép-kocsibeallok.jpg | Beautiful carports showcase |
| 2688 | elektromos-autok-kocsibealloja_kocsibeallo.hu_.jpeg | EV carport |
| 2689 | kocsibeallo-elektromos autoknak_kocsibeallo.hu_.jpeg | EV carport variant |
| 2730 | uveggarazs_egyedi_kocsibeallok_Deluxe_Building.jpg | Glass garage custom |
| 2737 | palram_arcadia_dupla_autobeallo_Deluxe_Building.jpg | Palram Arcadia double |
| 2740 | egyedi_tervezesu_kocsibeallo_deluxe_building_2(1).jpg | Custom design v2 |
| 2771 | karacsonyi_diszitesu_fa_kocsibeallo_deluxe_building.jpg | Christmas decorated |
| 2772 | uveg_fedes_kocsibeallo_deluxe_building.jpg | Glass roof deluxe |
| 2776 | ximax-portoforte-ives-aluminium-dupla-kocsibeallo-beton_aljzat_Deluxe_building.jpg | Ximax curved double |
| 2781 | ximax-linea-dupla-aluminium-kocsibeallo_deluxe_building.jpg | Ximax Linea double |
| 2786 | üvegfedésű-kocsibeálló-02.jpg | Glass roof variant 02 |
| 2791 | elore_gyartott_kocsibeallo_Ximax_cegeknek_Deluxe_building.jpg | Prefab for companies |
| 2797 | Ximax_Portoforte_kocsibeallo_deluxe_building.jpg | Ximax Portoforte |
| 2801 | ximax_myport_7_kocsibeallo_deluxe_building.jpg | Ximax MyPort 7 |
| 2835 | szines_LED_csikokkal_felszerelt_egyedi_kocsibeallo_Deluxe_Building.jpg | LED strips custom |

#### Construction Types (6 files)
| FID | Filename | Product Type |
|-----|----------|--------------|
| 2840 | ragasztott-fa-szerkezetu-lamberiazott-zsindely-fedesu-kocsibeallo_Deluxe_Building.jpg | Wood + Shingle |
| 2844 | vas_szerkezetu_Eco-autobeallo_Deluxe_Building.jpg | Steel ECO |
| 2866 | egyedi_kocsibeallo_taroloval_Deluxe_Building.jpg | With storage |
| 3078 | napelemes_kocsibeallo_autobeallo_deluxe_building_5.jpg | Solar panels v5 |
| 3282 | femhatasu_ragasztott_fa_kocsibeallo_deluxe_building_2.jpg | Metal-look wood |
| 3999 | egyedi-tervezesu-napelemmel-fedett-dupla-kocsibeallo-ragasztott-fa-szerkezettel-deluxe-kocsibeallo-15.jpg | Solar double custom |

#### Ximax Wing Series (3 files)
| FID | Filename |
|-----|----------|
| 2944 | Ximax_Wing_antracit_aluminium_kocsibeallo_7.jpg |
| 2945 | Ximax_WING_aluminium_antracit_szinu_kocsibeallo5.jpg |
| 2949 | Ximax_WING_aluminium_antracit_szinu_kocsibeallo3.jpg |

#### Custom Designs (3 files)
| FID | Filename |
|-----|----------|
| 3305 | egyedi_kocsibeallo_deluxe_building_6.jpg |
| 3306 | egyedi_kocsibeallo_deluxe_building.jpg |
| 3307 | egyedi_kocsibeallo_pingpong_asztallal_deluxe_building-5.png |

#### Prefabricated Models (6 files)
| FID | Filename | Product Line |
|-----|----------|--------------|
| 3632 | deluxe-eloregyartott-kocsibeallo-ximax-wing-05.jpg | Wing 05 |
| 3633 | deluxe-eloregyartott-kocsibeallo-ximax-wing-1.jpg | Wing 1 |
| 3634 | deluxe-autobeallo-ximax-eco-eloregyartott-aluminium-kocsibeallo-06.jpg | ECO 06 |
| 3635 | deluxe-eloregyartott-autobeallo-ximax-linea-aluminium-17.jpg | Linea 17 |
| 3636 | deluxe-eloregyartott-autobeallo-ximax-linea-aluminium-6.jpg | Linea 6 |
| 3638 | deluxe-eloregyartott-autobeallo-ximax-eco-aluminium-05.jpg | ECO 05 |

#### Government Subsidy Campaign ("Vidéki Otthonfelújítási Támogatás") (8 files)
| FID | Filename | Product Type |
|-----|----------|--------------|
| 3846 | videki-otthonfelujitasi-tamogatas-egyedi-kocsibeallo-deluxe-building.jpg | Custom carport |
| 3847 | videki-otthonfelujitasi-tamogatas-eloregyarrtott-nyitott-kocsibeallo-deluxe-building.jpg | Open prefab |
| 3848 | videki-otthonfelujitasi-tamogatas-eloregyartott-teraszfedes-deluxe-building.jpg | Terrace cover |
| 3849 | videki-otthonfelujitasi-tamogatas-eloteto-deluxe-building.jpg | Front canopy |
| 3851 | videki-otthonfelujitasi-tamogatas-napelemes-kocsibeallo-napelemes-teraszfedes-deluxe-building.jpg | Solar carport+terrace |
| 3852 | videki-otthonfelujitasi-tamogatas-telikert-deluxe-building.jpg | Winter garden |
| 3853 | videki-otthonfelujitasi-tamogatas-terasz-deluxe-building.jpg | Terrace |
| 3855 | deluxe-building-videki-otthonfelujitasi-tamogatas-ragasztott-fa-szerkezetu-szendvics-panel-_fedesu_-zart-garazs_01.jpg | Closed garage |

**Impact:** Medium to High - These images are referenced in actual product pages and blog posts

**Action Required:**
1. Check production website (www.kocsibeallo.hu) to see if these images are still in use
2. If images are on production, download them from there
3. For missing images, consider:
   - Using placeholder images
   - Removing broken image references from content
   - Contacting content owners for original files

---

## Private Files Status (945 files)

### Issue
Private files migration failed due to path configuration error. The migration is looking for files at:
```
//sitesdefault/files/private/...
```

Instead of:
```
/app/web/sites/default/files/private/...
```

### File Categories
Based on sample errors, private files include:

1. **CSV Feeds** (exports/imports)
   - Node_tippek.csv
   - Taxonomy_cikkek.csv
   - Taxonomy_galeria.csv
   - Node_foto_galeriahoz.csv
   - story_csv_0.csv

2. **Webform Attachments** (customer submissions)
   - Quote documents (.xlsx)
   - Customer photos (.jpeg)
   - Various submission attachments

3. **Private Gallery Images**
   - Duplicate copies of public images stored privately

### Action Required
1. Fix private file path configuration in D10 settings
2. Copy private files from D7 to D10
3. Re-run private file migration

---

## File Recovery Recommendations

### Priority 1: High Impact (Production Content)
- All files in Categories 3 (52 files) - actual product/portfolio images
- Focus on "Vidéki Otthonfelújítási Támogatás" campaign images (active marketing)

### Priority 2: Medium Impact (Future Content)
- Files with encoding issues (2 files)
- May need for legacy content

### Priority 3: Low Impact (Can Skip)
- Theme demo files (14 files)
- Never used in production

---

## Recovery Strategy

### Step 1: Check Production Website
```bash
# Download missing files from production if available
wget http://www.kocsibeallo.hu/sites/default/files/field/image/[filename]
```

### Step 2: Database Cleanup (Optional)
For files that cannot be recovered and are not needed:
```sql
-- Remove file references from D10 database
DELETE FROM file_managed WHERE fid IN ([list of unrecoverable fids]);
```

### Step 3: Fix Private Files
1. Update D10 settings.php:
   ```php
   $settings['migrate_file_private_path'] = '/app/web';
   ```

2. Copy private files:
   ```bash
   docker cp pajfrsyfzm-d7-cli:/app/sites/default/files/private \
            drupal10/web/sites/default/files/
   ```

3. Re-run migration:
   ```bash
   drush migrate:rollback upgrade_d7_file_private
   drush migrate:import upgrade_d7_file_private
   ```

---

## Migration Statistics

### Overall Success Rate
- **Public Files:** 94.7% success (1,432/1,512)
- **Private Files:** 0% success (requires configuration fix)
- **Combined:** 60.2% success (1,432/2,457)

### File Size Impact
To be determined - would require checking actual file sizes of missing files

---

## Next Steps

1. **Audit Production Website**
   - Check which missing files are actively used
   - Download available files from production

2. **Content Review**
   - Review nodes/pages referencing missing images
   - Decide: replace, remove, or leave as broken

3. **Fix Private Files**
   - Implement path configuration fix
   - Copy files and re-run migration

4. **Update Documentation**
   - Document which files were recovered
   - Document which content was updated/removed

---

## Technical Notes

### File Path Configuration Used
```php
// D10 settings.php
$settings['migrate_file_public_path'] = '/app/web';
$settings['migrate_file_private_path'] = '/app/web';  // Needs update

// Migration config
source_base_path: '/app/web'
```

### Migration Commands Reference
```bash
# Check migration status
drush migrate:status upgrade_d7_file

# View errors
drush migrate:messages upgrade_d7_file

# Rollback if needed
drush migrate:rollback upgrade_d7_file

# Re-run migration
drush migrate:import upgrade_d7_file
```

---

**Report Generated By:** Claude Code Migration Assistant
**Last Updated:** 2025-11-15

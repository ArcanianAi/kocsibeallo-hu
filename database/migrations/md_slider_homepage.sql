-- MD Slider Homepage Slideshow Migration
-- Created: 2025-11-17
-- Purpose: Import homepage slideshow slider and slides data
--
-- IMPORTANT: Run this AFTER files have been synced from D7 to D10
-- IMPORTANT: Run this AFTER config:import has been done (to get block.block.porto_frontpage.yml)
--
-- Prerequisites:
-- 1. Files synced: sites/default/files/*.webp slideshow images must exist
-- 2. Config imported: block.block.porto_frontpage.yml must be imported
-- 3. MD Slider module enabled
--
-- To import:
-- drush sql-query --file=database/migrations/md_slider_homepage.sql

-- ============================================
-- Clear existing slideshow data (if any)
-- ============================================
DELETE FROM md_slides WHERE slid = 1;
DELETE FROM md_sliders WHERE slid = 1;

-- ============================================
-- Insert MD Slider Configuration
-- ============================================
INSERT INTO md_sliders (slid, title, description, machine_name, settings) VALUES
(1, 'Front Page', '', 'front_page', 'a:40:{s:10:"full_width";i:0;s:5:"width";s:3:"960";s:6:"height";s:3:"350";s:11:"touch_swipe";i:1;s:10:"responsive";i:1;s:8:"videobox";i:0;s:4:"loop";i:1;s:10:"loadingbar";i:0;s:12:"bar_position";s:6:"bottom";s:21:"show_next_prev_button";i:1;s:21:"enable_key_navigation";i:0;s:9:"auto_play";i:1;s:11:"pause_hover";i:1;s:11:"show_bullet";i:1;s:15:"bullet_position";s:1:"5";s:14:"show_thumbnail";i:0;s:18:"thumbnail_position";s:1:"1";s:12:"border_style";s:1:"0";s:16:"dropshadow_style";i:0;s:9:"animation";s:4:"fade";s:5:"delay";s:4:"8000";s:9:"transtime";s:3:"800";s:11:"thumb_style";s:9:"thumbnail";s:18:"create_bg_imgstyle";i:1;s:8:"bg_style";s:4:"none";s:10:"dmf_google";s:0:"";s:8:"on_start";s:0:"";s:6:"on_end";s:0:"";s:11:"color_saved";s:13:"ff9900,CC0000";s:5:"label";s:10:"Front Page";s:2:"id";s:10:"front_page";s:6:"is_new";b:1;s:8:"sls_desc";s:0:"";s:12:"device_width";s:3:"460";s:13:"device_enable";i:0;}');

-- ============================================
-- Insert Slides
-- ============================================
-- Note: background_image values reference file_managed.fid
-- These FIDs must exist in the file_managed table after file sync

INSERT INTO md_slides (sid, name, slid, position, settings, layers) VALUES
(1, 'Slide name', 1, 0, 'a:9:{s:16:"background_image";i:2850;s:16:"background_color";s:0:"";s:18:"background_overlay";s:0:"";s:13:"timelinewidth";i:80;s:16:"custom_thumbnail";i:-1;s:8:"disabled";i:0;s:11:"transitions";a:0:{}s:20:"background_image_alt";s:0:"";s:20:"custom_thumbnail_alt";s:0:"";}', 'a:0:{}'),
(2, 'Slide name', 1, 1, 'a:9:{s:16:"background_image";i:2851;s:16:"background_color";s:0:"";s:18:"background_overlay";s:0:"";s:13:"timelinewidth";i:80;s:16:"custom_thumbnail";i:-1;s:8:"disabled";i:0;s:11:"transitions";a:0:{}s:20:"background_image_alt";s:0:"";s:20:"custom_thumbnail_alt";s:0:"";}', 'a:0:{}'),
(3, 'Slide name', 1, 2, 'a:9:{s:16:"background_image";i:2852;s:16:"background_color";s:0:"";s:18:"background_overlay";s:0:"";s:13:"timelinewidth";i:80;s:16:"custom_thumbnail";i:-1;s:8:"disabled";i:0;s:11:"transitions";a:0:{}s:20:"background_image_alt";s:0:"";s:20:"custom_thumbnail_alt";s:0:"";}', 'a:0:{}'),
(4, 'Slide name', 1, 3, 'a:9:{s:16:"background_image";i:2853;s:16:"background_color";s:0:"";s:18:"background_overlay";s:0:"";s:13:"timelinewidth";i:80;s:16:"custom_thumbnail";i:-1;s:8:"disabled";i:0;s:11:"transitions";a:0:{}s:20:"background_image_alt";s:0:"";s:20:"custom_thumbnail_alt";s:0:"";}', 'a:0:{}'),
(5, 'Slide name', 1, 4, 'a:9:{s:16:"background_image";i:2854;s:16:"background_color";s:0:"";s:18:"background_overlay";s:0:"";s:13:"timelinewidth";i:80;s:16:"custom_thumbnail";i:-1;s:8:"disabled";i:0;s:11:"transitions";a:0:{}s:20:"background_image_alt";s:0:"";s:20:"custom_thumbnail_alt";s:0:"";}', 'a:0:{}'),
(6, 'Slide name', 1, 5, 'a:9:{s:16:"background_image";i:2855;s:16:"background_color";s:0:"";s:18:"background_overlay";s:0:"";s:13:"timelinewidth";i:80;s:16:"custom_thumbnail";i:-1;s:8:"disabled";i:0;s:11:"transitions";a:0:{}s:20:"background_image_alt";s:0:"";s:20:"custom_thumbnail_alt";s:0:"";}', 'a:0:{}'),
(7, 'Slide name', 1, 6, 'a:9:{s:16:"background_image";i:2856;s:16:"background_color";s:0:"";s:18:"background_overlay";s:0:"";s:13:"timelinewidth";i:80;s:16:"custom_thumbnail";i:-1;s:8:"disabled";i:0;s:11:"transitions";a:0:{}s:20:"background_image_alt";s:0:"";s:20:"custom_thumbnail_alt";s:0:"";}', 'a:0:{}'),
(8, 'Slide name', 1, 7, 'a:9:{s:16:"background_image";i:2859;s:16:"background_color";s:0:"";s:18:"background_overlay";s:0:"";s:13:"timelinewidth";i:80;s:16:"custom_thumbnail";i:-1;s:8:"disabled";i:0;s:11:"transitions";a:0:{}s:20:"background_image_alt";s:0:"";s:20:"custom_thumbnail_alt";s:0:"";}', 'a:0:{}');

-- ============================================
-- Verification Queries
-- ============================================
-- Run these to verify the import worked:
-- SELECT * FROM md_sliders WHERE machine_name = 'front_page';
-- SELECT COUNT(*) FROM md_slides WHERE slid = 1;  -- Should return 8
--
-- Check that image files exist:
-- SELECT fid, filename FROM file_managed WHERE fid IN (2850, 2851, 2852, 2853, 2854, 2855, 2856, 2859);

-- ============================================
-- Required Image Files
-- ============================================
-- The following files must exist in sites/default/files/:
-- FID 2850: ximax-swingline-kocsibeallo-tandem-elrendezesben-kocsibeallo.webp
-- FID 2851: ximax-swingline-kocsibeallo-m-elrendezesben-kocsibeallo.webp
-- FID 2852: ximax-swingline-kocsibellao-autobeallo.webp
-- FID 2853: autobeallo_ragasztott_fabol_polikarbonát-fedessel.webp
-- FID 2854: porfestett_acel_kocsibeallo-trapezlemez.webp
-- FID 2855: kocsibeallo_ragasztott_fabol_polikarbonat-fedessel.webp
-- FID 2856: vas-szerkezet-napelemes-kocsibeallo-slide_0.webp
-- FID 2859: ragasztott-fa-szerkezetu-polikabonat-fedesu-kocsibelllo-slide_1.webp

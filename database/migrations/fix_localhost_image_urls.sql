-- Fix Localhost Image URLs in Content
-- Created: 2025-11-17
-- Issue: Content body contains absolute localhost:8090 URLs instead of relative paths
--
-- Affected: 29 nodes with images pointing to http://localhost:8090/sites/default/files/
--
-- This script:
-- 1. Replaces http://localhost:8090/sites/default/files/ with /sites/default/files/
-- 2. Creates backup before changes
--
-- To run:
-- drush sql-query --file=../database/migrations/fix_localhost_image_urls.sql

-- Create backup
CREATE TABLE IF NOT EXISTS node__body_backup_localhost_urls AS
SELECT * FROM node__body WHERE body_value LIKE '%http://localhost:8090%';

-- Show affected nodes before update
SELECT
    entity_id,
    SUBSTRING(body_value, 1, 100) as preview
FROM node__body
WHERE body_value LIKE '%http://localhost:8090%'
ORDER BY entity_id
LIMIT 10;

-- Update body_value: Replace localhost URLs with relative paths
UPDATE node__body
SET body_value = REPLACE(body_value, 'http://localhost:8090/sites/default/files/', '/sites/default/files/')
WHERE body_value LIKE '%http://localhost:8090/sites/default/files/%';

-- Also fix any http://localhost:8090/ references without /sites/default/files/
UPDATE node__body
SET body_value = REPLACE(body_value, 'http://localhost:8090/', '/')
WHERE body_value LIKE '%http://localhost:8090/%';

-- Update body_summary if it exists and has localhost URLs
UPDATE node__body
SET body_summary = REPLACE(body_summary, 'http://localhost:8090/sites/default/files/', '/sites/default/files/')
WHERE body_summary LIKE '%http://localhost:8090/sites/default/files/%';

UPDATE node__body
SET body_summary = REPLACE(body_summary, 'http://localhost:8090/', '/')
WHERE body_summary LIKE '%http://localhost:8090/%';

-- Verification: Show updated count
SELECT
    COUNT(*) as remaining_localhost_urls
FROM node__body
WHERE body_value LIKE '%http://localhost:8090%';

-- Show sample of fixed content
SELECT
    entity_id,
    SUBSTRING(body_value, LOCATE('/sites/default/files/', body_value) - 20, 100) as fixed_url_preview
FROM node__body
WHERE body_value LIKE '%/sites/default/files/%'
ORDER BY entity_id
LIMIT 5;

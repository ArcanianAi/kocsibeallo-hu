# ARC-808: Add contact form to Kapcsolat page

**Status:** Completed
**Date:** 2025-11-25
**Type:** Database update (content modification)

## Summary
Added the "Kapcsolat" webform to the Kapcsolat (Contact) page (node 145) using entity embed.

## Problem
The /kapcsolat page displayed company information and a map but was missing the contact form that already existed in the system.

## Solution
Embedded the existing "Kapcsolat" webform (UUID: 2e1c5d29-dbd7-4ed5-a197-a966b38bbbbd) into the page content using Drupal's entity embed system.

### Webform Details
The "Kapcsolat" webform already exists with the following fields:
- **Név** (Name) - Required text field
- **Email** - Required email field with validation
- **Telefonszám** (Phone) - Optional tel field
- **Tárgy** (Subject) - Required text field
- **Üzenet** (Message) - Required textarea (8 rows)
- **Submit button:** "Küldés"

## Database Changes

### Updated Tables:
- `node__body` (entity_id = 145)
- `node_revision__body` (entity_id = 145)

### Changes Made:
1. Removed incomplete/malformed `<div>` tag from previous attempts
2. Added instructional text: "Kérjük, töltse ki az alábbi űrlapot és hamarosan felvesszük Önnel a kapcsolatot!"
3. Embedded webform using `<drupal-entity>` tag with proper attributes:
   - `data-embed-button="webform"`
   - `data-entity-embed-display="entity_reference:entity_reference_entity_view"`
   - `data-entity-type="webform"`
   - `data-entity-uuid="2e1c5d29-dbd7-4ed5-a197-a966b38bbbbd"`

## Page Structure
The Kapcsolat page (node 145) now includes:
1. Company description
2. Contact information (address, phone, email, website)
3. Google Maps iframe
4. **"Kapcsolat" heading**
5. **Instructional text** (new)
6. **Contact form** (new - embedded webform)

## Deployment
This change requires direct database updates on Nexcess:

```bash
# SSH into Nexcess
SSH_AUTH_SOCK="" sshpass -p 'LongRagHaltsLied' ssh -o StrictHostKeyChecking=no a17d7af6_1@d99a9d9894.nxcli.io

cd ~/9df7d73bf2.nxcli.io/drupal/web

# Update node__body
../vendor/bin/drush sql-query "UPDATE node__body SET body_value = CONCAT(SUBSTRING_INDEX(body_value, '<div data-drupal-selector=', 1), '<p>Kérjük, töltse ki az alábbi űrlapot és hamarosan felvesszük Önnel a kapcsolatot!</p>\n\n<drupal-entity data-embed-button=\"webform\" data-entity-embed-display=\"entity_reference:entity_reference_entity_view\" data-entity-type=\"webform\" data-entity-uuid=\"2e1c5d29-dbd7-4ed5-a197-a966b38bbbbd\"></drupal-entity>') WHERE entity_id = 145"

# Update node_revision__body
../vendor/bin/drush sql-query "UPDATE node_revision__body SET body_value = CONCAT(SUBSTRING_INDEX(body_value, '<div data-drupal-selector=', 1), '<p>Kérjük, töltse ki az alábbi űrlapot és hamarosan felvesszük Önnel a kapcsolatot!</p>\n\n<drupal-entity data-embed-button=\"webform\" data-entity-embed-display=\"entity_reference:entity_reference_entity_view\" data-entity-type=\"webform\" data-entity-uuid=\"2e1c5d29-dbd7-4ed5-a197-a966b38bbbbd\"></drupal-entity>') WHERE entity_id = 145"

# Clear cache
../vendor/bin/drush cr
```

## Testing
- ✅ Form displays on /kapcsolat page
- ✅ All fields render correctly (name, email, phone, subject, message)
- ✅ Submit button displays as "Küldés"
- ✅ Form validation works (required fields)
- ✅ Page layout remains intact

## Notes
- Webform configuration already exists: `config/sync/webform.webform.kapcsolat.yml`
- No new configuration files needed
- This is a content-only change
- The webform uses Drupal's entity embed system which requires the Entity Embed module
- Form submissions will be handled according to existing webform email handlers

## Verification URLs
- Local: http://localhost:8090/kapcsolat
- Staging: https://9df7d73bf2.nxcli.io/kapcsolat

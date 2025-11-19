# ARC-688: Replicate conditional fields logic in Ajánlatkérés form

## Linear Task Link
https://linear.app/arcanian/issue/ARC-688/replicate-conditional-fields-logic-in-ajanlatkeres-quote-request-form

---

## Summary
Implemented conditional field logic in the Ajánlatkérés (Quote Request) webform. Added Palram type selection that appears conditionally when Palram is selected.

---

## Changes Made

### Configuration File Modified
`config/sync/webform.webform.ajanlatkeres.yml`

### Conditional Fields Implemented

#### 1. XIMAX Type (existing)
- **Field**: `ximax_type` (checkboxes)
- **Condition**: Visible when `type = XIMAX`
- **Options**:
  - Wing - egyenes
  - Linea - egyenes
  - Portoforte - íves
  - NEO - egyenes

#### 2. Palram Type (NEW)
- **Field**: `palram_type` (checkboxes)
- **Condition**: Visible when `type = Palram`
- **Options**:
  - Arizona 5000
  - Arcadia
  - Atlas 5000

---

## Conditional Logic Structure

```yaml
ximax_type:
  '#states':
    visible:
      ':input[name="type"]':
        value: XIMAX

palram_type:
  '#states':
    visible:
      ':input[name="type"]':
        value: Palram
```

---

## Form Field Order

1. Az Ön neve (required)
2. Az Ön telefonszáma (required)
3. Az Ön email címe (required)
4. Építés helyszíne (required)
5. Autók száma (required)
6. Választott típus (required) - triggers conditions
7. XIMAX autóbeálló típus (conditional - shows for XIMAX)
8. Palram autóbeálló típus (conditional - shows for Palram)
9. Méret section
10. Hossz (required)
11. Szélesség (required)
12. Kérdések, megjegyzések
13. Csatolmány feltöltése

---

## Testing Scenarios

1. **Select "XIMAX"** → ximax_type checkboxes appear
2. **Select "Palram"** → palram_type checkboxes appear
3. **Select "Egyedi nyitott"** → no subtype options
4. **Select "Napelemes"** → no subtype options
5. **Select "Zárt garázs"** → no subtype options
6. **Switch between types** → correct subtypes show/hide

---

## Local Verification Steps

1. Clear cache: `drush cr`
2. Visit http://localhost:8090/ajanlatkeres
3. Select "XIMAX" from type dropdown → verify XIMAX subtypes appear
4. Select "Palram" from type dropdown → verify Palram subtypes appear
5. Select other types → verify no subtypes shown
6. Test form submission

---

## Time Spent
~10 minutes

---

## Notes
- Uses Drupal's Form API #states for conditional visibility
- No page refresh required - JavaScript handles show/hide
- Also addresses ARC-710 (Missing Palram type options)

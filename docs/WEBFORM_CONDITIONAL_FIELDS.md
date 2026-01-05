# Ajánlatkérés Webform - Feltételes Mezők Dokumentáció

## Áttekintés

Az Ajánlatkérés űrlap (`/ajanlatkeres`) feltételes mezőket használ, amelyek a kiválasztott kocsibeálló típustól függően jelennek meg. A feltételes megjelenítés **két helyen** van konfigurálva:

1. **Űrlapon** - Drupal #states API (melyik mezők láthatók kitöltéskor)
2. **Email értesítőkben** - Twig sablonok (melyik mezők jelennek meg az emailben)

---

## 1. Űrlap Feltételes Mezők (#states API)

### Konfiguráció helye
- **Fájl:** `config/sync/webform.webform.ajanlatkeres.yml`
- **Admin felület:** `/admin/structure/webform/manage/ajanlatkeres` → Mező szerkesztése → "Feltételek" fül

### Típusok és mezők

| Típus | Megjelenő mezők |
|-------|-----------------|
| Egyedi nyitott | szerkezet_anyaga, tetofedes_anyaga |
| XIMAX | ximax_type |
| Palram | palram_type |
| Napelemes | szerkezet_anyaga, napelem_rendszer |
| Zárt garázs | szerkezet_anyaga, tetofedes_anyaga, oldalzaras_anyaga |

### Példa konfiguráció (YAML)

```yaml
ximax_type:
  '#type': checkboxes
  '#title': 'XIMAX autóbeálló típus'
  '#options':
    wing: 'Wing - egyenes'
    linea: 'Linea - egyenes'
    portoforte: 'Portoforte - íves'
    neo: 'NEO - egyenes'
  '#states':
    visible:
      ':input[name="type"]':
        value: XIMAX

szerkezet_anyaga:
  '#type': checkboxes
  '#title': 'Tartószerkezet anyaga'
  '#options':
    ragasztott_fa: 'Ragasztott fa'
    vas: Vas
    aluminium: Alumínium
  '#states':
    visible:
      ':input[name="type"]':
        - value: 'Egyedi nyitott'
        - value: 'Napelemes'
        - value: 'Zárt garázs'
```

---

## 2. Email Értesítők Feltételes Megjelenítése (Twig)

### Konfiguráció helye
- **Fájl:** `config/sync/webform.webform.ajanlatkeres.yml` (handlers szekció)
- **Admin felület:** `/admin/structure/webform/manage/ajanlatkeres/handlers` → Email handler → "Törzs" mező

### Email kezelők
1. **Email notification** - Admin értesítő (info@kocsibeallo.hu, hello@deluxebuilding.hu)
2. **Visszaigazoló email** - Ügyfél visszaigazolás

### Fontos beállítások

```yaml
handlers:
  email:
    settings:
      html: true      # HTML email engedélyezése
      twig: true      # Twig sablon feldolgozás engedélyezése
      body: |         # Twig sablon
        ...
```

### Twig Sablon Szintaxis

#### Egyszerű mezők (text, select, number)
```twig
{{ data.name }}
{{ data.type }}
{{ data.length }}
```

#### Checkbox mezők feltételes megjelenítése
```twig
{% if data.ximax_type|filter(v => v)|length > 0 %}
<tr>
  <td>XIMAX típus</td>
  <td>{{ webform_token('[webform_submission:values:ximax_type]', webform_submission, [], options) }}</td>
</tr>
{% endif %}
```

**Magyarázat:**
- `data.ximax_type|filter(v => v)` - kiszűri az üres értékeket a checkbox tömbből
- `|length > 0` - ellenőrzi, hogy van-e kiválasztott érték
- `webform_token()` - szükséges a checkbox értékek helyes megjelenítéséhez (pl. "Wing - egyenes, Linea - egyenes")

#### Opcionális szöveges mezők
```twig
{% if data.message %}
<tr>
  <td>Kérdések, megjegyzések</td>
  <td>{{ data.message }}</td>
</tr>
{% endif %}
```

---

## 3. Teljes Email Sablon Példa

```twig
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
  <div style="background-color: #011e41; padding: 20px; text-align: center;">
    <img src="https://www.kocsibeallo.hu/sites/default/files/deluxe-kocsibeallo-logo-150px.png" alt="Kocsibeálló.hu">
  </div>
  <div style="padding: 30px 20px;">
    <h2>Új ajánlatkérés érkezett</h2>
    <table style="width: 100%; border-collapse: collapse;">
      <!-- Alapmezők - mindig megjelennek -->
      <tr>
        <td style="padding: 10px; font-weight: bold;">Név</td>
        <td style="padding: 10px;">{{ data.name }}</td>
      </tr>
      <tr>
        <td style="padding: 10px; font-weight: bold;">Típus</td>
        <td style="padding: 10px;">{{ data.type }}</td>
      </tr>

      <!-- Feltételes mezők -->
      {% if data.ximax_type|filter(v => v)|length > 0 %}
      <tr>
        <td style="padding: 10px; font-weight: bold;">XIMAX típus</td>
        <td style="padding: 10px;">{{ webform_token('[webform_submission:values:ximax_type]', webform_submission, [], options) }}</td>
      </tr>
      {% endif %}

      {% if data.palram_type|filter(v => v)|length > 0 %}
      <tr>
        <td style="padding: 10px; font-weight: bold;">Palram típus</td>
        <td style="padding: 10px;">{{ webform_token('[webform_submission:values:palram_type]', webform_submission, [], options) }}</td>
      </tr>
      {% endif %}

      <!-- ... további feltételes mezők ... -->
    </table>
  </div>
</div>
```

---

## 4. Hibaelhárítás

### Probléma: Checkbox értékek nem jelennek meg
**Megoldás:** Használj `webform_token()` függvényt a `{{ data.field }}` helyett:
```twig
{{ webform_token('[webform_submission:values:field_name]', webform_submission, [], options) }}
```

### Probléma: Email nem HTML formátumú
**Ellenőrizd:**
1. `html: true` be van állítva a handler settings-ben
2. `twig: true` be van állítva (ha Twig sablont használsz)

### Probléma: Üres mezők megjelennek
**Megoldás:** Használj Twig feltételt:
- Checkbox mezőkhöz: `{% if data.field|filter(v => v)|length > 0 %}`
- Szöveges mezőkhöz: `{% if data.field %}`

---

## 5. Módosítások Naplója

| Dátum | Változás |
|-------|----------|
| 2025-01-05 | Twig sablonok hozzáadása mindkét email kezelőhöz, feltételes megjelenítés implementálása |

---

## 6. Kapcsolódó Fájlok

- `config/sync/webform.webform.ajanlatkeres.yml` - Webform és handler konfiguráció
- `config/sync/block.block.porto_ajanlatkeres_webform.yml` - Sidebar block konfiguráció

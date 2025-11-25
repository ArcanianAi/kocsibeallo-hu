# ARC-703: Limit gallery filters to maximum 3 combinations

**Started:** 2025-11-20
**Linear:** https://linear.app/arcanian/issue/ARC-703
**Priority:** High

## Objective

Limit gallery filter combinations on `/kepgaleria` page to maximum 3 selected filters at once.

**Updated:** Changed from max 2 to max 3 based on client requirements.

## Tasks

- [ ] Check current filter implementation on D10
- [ ] Compare with D7 filter behavior
- [ ] Identify filter field names and types
- [ ] Implement JavaScript filter limiting
- [ ] Add CSS for visual feedback
- [ ] Test filter limitation
- [ ] Deploy to Nexcess

## Investigation

### D7 Site Filters
Checking: https://www.kocsibeallo.hu/kepgaleria

### D10 Local Site Filters
Checking: http://localhost:8090/kepgaleria

## Work Log

### Investigation Findings

**D7 Site** (`https://www.kocsibeallo.hu/kepgaleria`):
- Uses link-based filters in sidebar
- Filter categories: Típus, Stílus, Szerkezet anyaga, Tetőfedés anyaga, Oldalzárás anyaga, Termék típusok, Címkék
- Single-selection filters (clicking navigates to filtered view)

**D10 Site** (`http://localhost:8090/kepgaleria`):
- Uses **Search API** with **Facets module**
- Uses **Facets Pretty Paths** for clean URLs
- Same filter categories as D7
- Multiple facets can be combined via URL parameters
- Example combined URL: `/kepgaleria/field_gallery_tag/ximax-156/field_stilus/egyenes-158`

**Filter Configuration**:
- Facet source: `search_api__views_page__index_gallery__page_1`
- Widget type: `links`
- URL processor: `facets_pretty_paths`
- Query operator: `or`

**Active Facets**:
1. `gallery_tag` - Gallery Tag (Típus)
2. `stilus` - Style (Stílus)
3. `szerkezet_anyaga` - Structure Material
4. `tetofedes_anyaga` - Roof Material
5. `oldalzaras_anyaga` - Side Closure Material
6. `termek_tipus` - Product Type
7. `cimkek` - Tags (Címkék)

**Problem**: Users can currently select unlimited filter combinations. Need to limit to **maximum 3** active facets.

### Solution Approach

1. **JavaScript Implementation**:
   - Detect currently active facets from URL
   - Count active facets
   - When 3 facets are active, disable all inactive facet links
   - Add visual feedback (grey out disabled links)
   - Show message when limit is reached

2. **CSS Styling**:
   - Add `.facet-link-disabled` class styling
   - Visual indicator for disabled state
   - Optional: Show active filter count

3. **User Experience**:
   - Allow users to deselect active filters to select different ones
   - Clear messaging when limit is reached
   - Maintain existing facet functionality

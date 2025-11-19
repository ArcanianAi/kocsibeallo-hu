# ARC-706: Style gallery pager to match blog list pager

## Linear Task Link
https://linear.app/arcanian/issue/ARC-706/style-gallery-pager-to-match-blog-list-pager

---

## Summary
Added `.view-blog` selectors to all existing gallery pager CSS rules so both the blog list page (`/blog`) and gallery page (`/kepgaleria`) use identical pagination styling.

---

## Changes Made

### File Modified
`web/themes/contrib/porto_theme/css/custom-user.css` (lines 1463-1600)

### CSS Rules Updated
Added `.view-blog` selector to all pager rules:
- Pager container (list reset, inline-block)
- Pager items (inline display, margins)
- Pager links (Bootstrap button style, colors #011e41 background)
- First/last item border-radius
- Hover state (#ac9c58 gold)
- Active/current page state
- Visually hidden elements
- Next/previous button arrows
- Mobile responsiveness

---

## Styling Applied

### Colors
- **Background**: #011e41 (dark blue)
- **Border**: #011e41
- **Text**: #fff (white)
- **Hover/Active**: #ac9c58 (gold)

### Features
- Rounded corners on first/last items
- Smooth transition (0.3s)
- Arrow symbols on next (›) and last (») buttons
- Mobile responsive (smaller padding/font at <767px)

---

## Local Verification Steps

1. Start local D10 container
2. Visit http://localhost:8090/blog - verify pager styling
3. Visit http://localhost:8090/kepgaleria - verify pager matches
4. Test pagination on both pages
5. Check hover states and active page highlighting
6. Test on mobile viewport

---

## Test Results

- [x] CSS syntax valid
- [ ] Blog pager styled (requires browser verification)
- [ ] Gallery pager styled (requires browser verification)
- [ ] Colors match across both pages
- [ ] Hover effects work
- [ ] Active page highlighted
- [ ] Mobile responsive

---

## Time Spent
~15 minutes

---

## Notes
- Both pagers now share identical CSS rules
- Changes are additive (no existing functionality removed)
- Should clear Drupal cache after deployment to see changes

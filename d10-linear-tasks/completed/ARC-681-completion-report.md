# ARC-681: Fix Blog Formatting to Match Live Site

## Linear Task Link
https://linear.app/arcanian/issue/ARC-681/task-005-fix-blog-formatting-to-match-live-site

---

## Summary
Implemented Porto theme card layout for blog posts on `/blog` page with featured images, date badge overlay, title, excerpt, and "Read More" button styling.

---

## Changes Made

### File Modified
`web/themes/contrib/porto_theme/css/custom-user.css` (lines 1303-1430+)

### Key CSS Updates

1. **Enabled featured images** (was `display: none !important`)
   - Changed to proper image display with full width

2. **Card layout styling**
   - Box shadow: `0 2px 10px rgba(0,0,0,0.08)`
   - Border radius: 4px
   - Overflow hidden for image containment

3. **Date badge overlay**
   - Position: absolute, top-left over image
   - Background: #011e41 (dark blue)
   - Split display (day/month) styling ready

4. **Content padding**
   - Title: 25px padding (top and sides)
   - Body/tags: 25px left/right
   - Links: 25px padding with bottom spacing

---

## Styling Applied

### Card Layout
- White background with subtle shadow
- Featured image at top (full width, no padding)
- Date badge positioned over image
- Content area with consistent 25px padding

### Typography
- Title: Playfair Display, 32px, #ac9c63
- Body: Poppins, 15px, #333
- Tags: FontAwesome icon, 14px
- Read More: Gold button (#ac9c58)

### Colors
- Card shadow: rgba(0,0,0,0.08)
- Date badge background: #011e41
- Title: #ac9c63 (gold)
- Hover: #011e41 (title), #ffffff (button)

---

## Related Tasks Addressed

- **ARC-689**: Add teaser images - RESOLVED (images now visible)
- **ARC-690**: Blog post dates - PARTIALLY (CSS ready, needs view config)

---

## Local Verification Steps

1. Visit http://localhost:8090/blog
2. Verify blog posts show in card layout
3. Check featured images display at top
4. Verify date badge styling (may need view config update)
5. Check title, excerpt, tags display
6. Test "TOVÁBB" button styling and hover
7. Test responsive on mobile

---

## Time Spent
~20 minutes

---

## Notes
- Date badge requires views configuration to add date field
- May need template updates for proper date rendering with day/month split
- Images were previously hidden with `display: none !important`

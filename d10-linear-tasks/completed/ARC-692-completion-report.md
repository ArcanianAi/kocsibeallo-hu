# ARC-692: Format individual blog post pages

## Linear Task Link
https://linear.app/arcanian/issue/ARC-692/format-individual-blog-post-pages-teaser-image-date-and-title-styling

---

## Summary
Added comprehensive CSS styling for individual blog post pages including title, date badge, post meta, featured image, and content formatting.

---

## Changes Made

### File Modified
`web/themes/contrib/porto_theme/css/custom-user.css` (lines 2044-2125)

### CSS Added

1. **Date badge styling**
   - Background: #011e41 (dark blue, matches site theme)
   - Padding: 12px 15px
   - Positioned absolute over featured image

2. **Title styling**
   - Font: Playfair Display, 36px, bold, uppercase
   - Color: #ac9c63 (gold)

3. **Post meta styling**
   - Font: Poppins, 14px
   - Icons: Gold color (#ac9c58)
   - Border-bottom separator

4. **Featured image**
   - Full width display
   - No margin below

5. **Post content**
   - 20px padding
   - Body text: Poppins, 16px, line-height 1.8

---

## Styling Applied

### Colors
- Date badge background: #011e41 (dark blue)
- Title: #ac9c63 (gold)
- Meta icons: #ac9c58 (gold)
- Meta text: #777 (gray)
- Body text: #555 (dark gray)

### Typography
- Title: Playfair Display, serif
- Meta & Body: Poppins, sans-serif

---

## Template Structure (Existing)

The template `node--blog.html.twig` already provides:
- Featured image with multiple display modes
- Date badge with day/month split
- Title with link
- Post meta (author, tags, comments)
- Body content
- Share section
- Author section
- Comments section

---

## Local Verification Steps

1. Visit http://localhost:8090/node/[article-id]
2. Verify featured image displays at top
3. Check date badge with dark blue background
4. Verify gold title styling
5. Check post meta formatting
6. Test body content readability

---

## Time Spent
~10 minutes

---

## Notes
- Template already had good structure
- CSS updates provide consistent styling
- Colors match site theme (#011e41, #ac9c63)
- Removed #0088cc blue in favor of #011e41

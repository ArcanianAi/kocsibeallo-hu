# ARC-682: Fix Form Styling to Match Live Site

## Linear Task Link
https://linear.app/arcanian/issue/ARC-682/task-006-fix-form-styling-to-match-live-site

---

## Summary
The Ajánlatkérés form already has comprehensive CSS styling embedded in the webform configuration. All styling is complete and matches the Porto theme and site colors.

---

## Current Styling (Already Implemented)

### Colors
- Labels: #011e41 (dark blue)
- Required markers: #ac9c58 (gold)
- Buttons: #ac9c58 (gold) with white text
- Button hover: white with gold text/border
- Descriptions: #666 (gray)

### Typography
- Labels: 400 weight, 14px
- Fieldset legends: 600 weight, 18px
- Submit button: 15px
- Descriptions: 13px

### Input Styling
- Padding: 10px 12px
- Border: 1px solid #ddd
- Border-radius: 0px (sharp corners)
- Full width on inputs and selects
- Textarea min-height: 150px

### Button Styling
- Gold background (#ac9c58)
- White text
- 12px 30px padding
- Hover: inverted colors

### Spacing
- Form items: 20px bottom margin
- Fieldsets: 30px top, 20px bottom margin
- Labels: 5px bottom margin

---

## CSS Location

The CSS is embedded directly in the webform configuration:
`config/sync/webform.webform.ajanlatkeres.yml` → `css:` property

This approach keeps form-specific styles with the form definition rather than in a separate theme file.

---

## Local Verification Steps

1. Visit http://localhost:8090/ajanlatkeres
2. Verify:
   - Input fields have consistent styling
   - Labels are dark blue
   - Required markers are gold
   - Submit button is gold
   - Hover effects work on buttons
3. Test on mobile viewport
4. Test file upload button styling

---

## Time Spent
~5 minutes (verification)

---

## Notes
- Styling was already implemented in webform config
- Uses site theme colors (#011e41, #ac9c58)
- Sharp corners (border-radius: 0) for Porto theme consistency
- No additional CSS needed in custom-user.css

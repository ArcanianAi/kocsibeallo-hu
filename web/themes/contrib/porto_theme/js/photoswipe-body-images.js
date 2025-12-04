/**
 * @file
 * Initialize Photoswipe lightbox for embedded body content images.
 *
 * This script automatically wraps embedded images in body content with
 * Photoswipe-compatible markup and initializes the lightbox.
 *
 * Created: 2025-11-17 (ARC-693)
 */

(function ($, Drupal, once) {
  'use strict';

  Drupal.behaviors.photoswipeBodyImages = {
    attach: function (context, settings) {
      // Find all images in body content that aren't already in photoswipe wrappers
      // Target article content area, excluding header and navigation
      const bodyImages = once('photoswipe-body-init', 'article img, .field--name-body img, .node__content img', context);

      bodyImages.forEach(function(img) {
        const $img = $(img);

        // Skip if already wrapped in photoswipe link or if it's a thumbnail/icon
        if ($img.closest('a.photoswipe').length || $img.closest('.product-thumb-info').length) {
          return;
        }

        // Get image source
        let src = $img.attr('src');

        // If image is an image style, try to get original URL
        // Drupal image styles path pattern: /sites/default/files/styles/{style_name}/public/{original_path}
        if (src && src.includes('/styles/')) {
          // Extract original path from image style URL
          src = src.replace(/\/styles\/[^\/]+\/public/, '');
        }

        // Note: /system/files/ is a valid Drupal path for private files - don't convert it

        // Get caption from alt or title
        const caption = $img.attr('alt') || $img.attr('title') || '';

        // Check if image is already wrapped in a link
        const $parent = $img.parent();
        if ($parent.is('a')) {
          const existingHref = $parent.attr('href') || '';
          // If the link points to a page (not an image file), skip it - don't add photoswipe
          // Check if href contains common image extensions or files path patterns
          const isImageLink = /\.(jpg|jpeg|png|gif|webp|svg)$/i.test(existingHref) ||
                             existingHref.includes('/sites/default/files/') && !existingHref.includes('/node/');

          if (isImageLink) {
            // Update existing link to be a Photoswipe link
            $parent.addClass('photoswipe');
            $parent.attr({
              'href': src,
              'data-caption': caption
            });
            // Remove data-size to let PhotoSwipe auto-detect and maintain aspect ratio
            $parent.removeAttr('data-size');
          }
          // If it's a page link, leave it alone - don't convert to photoswipe
          return;
        } else {
          // Wrap image in new Photoswipe link without data-size
          // PhotoSwipe will auto-detect dimensions and maintain aspect ratio
          $img.wrap('<a href="' + src + '" class="photoswipe" data-caption="' + caption + '"></a>');
        }
      });

      // Initialize PhotoSwipeLightbox for containers with wrapped images
      const bodyFields = once('photoswipe-gallery-init', 'article, .field--name-body, .node__content', context);

      bodyFields.forEach(function(field) {
        const $gallery = $(field);
        const $links = $gallery.find('a.photoswipe');

        if ($links.length > 0) {
          // Add photoswipe-gallery class for styling
          $gallery.addClass('photoswipe-gallery');

          // Manually initialize PhotoSwipeLightbox for this gallery
          // This ensures we have full control over initialization timing
          if (typeof PhotoSwipeLightbox !== 'undefined' && typeof PhotoSwipe !== 'undefined') {
            const lightbox = new PhotoSwipeLightbox({
              gallery: field,
              children: 'a.photoswipe',
              pswpModule: PhotoSwipe,
              ...(settings?.photoswipe?.options || {})
            });
            lightbox.init();
          }
        }
      });
    }
  };

})(jQuery, Drupal, once);

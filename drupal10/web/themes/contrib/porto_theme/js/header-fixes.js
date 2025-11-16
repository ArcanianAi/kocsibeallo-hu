/**
 * Header fixes - Move Facebook icon to header
 */
(function ($, Drupal, once) {
  'use strict';

  Drupal.behaviors.headerFixes = {
    attach: function (context, settings) {
      // Use once to ensure this runs only once per element
      once('header-fb-icon', '.social-icons-facebook', context).forEach(function(fbIcon) {
        // Check if we already created the header social icons
        let headerSocialIcons = document.querySelector('#header .header-social-icons');

        if (!headerSocialIcons) {
          // Create the container
          headerSocialIcons = document.createElement('div');
          headerSocialIcons.className = 'header-social-icons';

          // Inline styles for positioning
          headerSocialIcons.style.position = 'absolute';
          headerSocialIcons.style.right = '15px';
          headerSocialIcons.style.top = '50%';
          headerSocialIcons.style.transform = 'translateY(-50%)';
          headerSocialIcons.style.zIndex = '1000';

          // Find header body
          const headerBody = document.querySelector('#header .header-body');

          if (headerBody) {
            headerBody.appendChild(headerSocialIcons);
          }
        }

        // Clone and add the Facebook icon
        if (headerSocialIcons && !headerSocialIcons.querySelector('.social-icons-facebook')) {
          const fbClone = fbIcon.cloneNode(true);
          fbClone.style.listStyle = 'none';
          fbClone.style.display = 'inline-block';
          headerSocialIcons.appendChild(fbClone);

          // Hide the original
          fbIcon.style.display = 'none';
        }
      });
    }
  };
})(jQuery, Drupal, once);

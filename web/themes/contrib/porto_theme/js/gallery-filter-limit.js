/**
 * @file
 * Limits gallery facet filter selections to maximum 3 combinations.
 */

(function (Drupal, once) {
  'use strict';

  const MAX_FILTERS = 3;

  Drupal.behaviors.galleryFilterLimit = {
    attach: function (context, settings) {
      // Run only on gallery pages
      if (!window.location.pathname.startsWith('/kepgaleria')) {
        return;
      }

      // Process facet blocks only once
      once('gallery-filter-limit', '[id*="block-facet"]', context).forEach(function (block) {
        initializeFilterLimiting();
      });
    }
  };

  /**
   * Initialize filter limiting functionality.
   */
  function initializeFilterLimiting() {
    // Show instructional text above filters
    showInstructionalText();

    // Count active filters from URL path
    const activeFacets = getActiveFacetsFromUrl();
    const activeCount = activeFacets.length;

    // If we have 3 active filters, disable all inactive filter links
    if (activeCount >= MAX_FILTERS) {
      disableInactiveFilters(activeFacets);
      showLimitMessage();
    }

    // Add event listeners to all facet links
    addClickListeners(activeFacets);
  }

  /**
   * Show instructional text above the filter sidebar.
   */
  function showInstructionalText() {
    // Check if text already exists
    if (document.querySelector('.filter-instructional-text')) {
      return;
    }

    // Create instructional text element
    const instructionalText = document.createElement('div');
    instructionalText.className = 'filter-instructional-text';
    instructionalText.innerHTML = '<p>A szűrő segítségével kiválaszthatja a szerkezet és a fedés anyagát, valamint az Önnek tetsző stílust.</p>';

    // Insert at the top of the first facet block
    const firstFacetBlock = document.querySelector('[id*="block-facet"]');
    if (firstFacetBlock) {
      firstFacetBlock.parentNode.insertBefore(instructionalText, firstFacetBlock);
    }
  }

  /**
   * Get active facets from the current URL.
   * @returns {Array} Array of active facet identifiers
   */
  function getActiveFacetsFromUrl() {
    const path = window.location.pathname;
    const activeFacets = [];

    // Facet field identifiers
    const facetFields = [
      'field_gallery_tag',
      'field_stilus',
      'field_szerkezet_anyaga',
      'field_tetofedes_anyaga',
      'field_oldalzaras_anyaga',
      'field_termek_tipus',
      'field_cimkek'
    ];

    // Check which facets are present in the URL
    facetFields.forEach(function (field) {
      if (path.includes('/' + field + '/')) {
        activeFacets.push(field);
      }
    });

    return activeFacets;
  }

  /**
   * Disable all facet links that are not currently active.
   * @param {Array} activeFacets - Array of currently active facet identifiers
   */
  function disableInactiveFilters(activeFacets) {
    // Get all facet blocks
    const facetBlocks = document.querySelectorAll('[id*="block-facet"]');

    facetBlocks.forEach(function (block) {
      // Get the facet type from block ID or data attribute
      const blockId = block.getAttribute('id') || '';
      let facetType = '';

      // Extract facet type from block ID (e.g., 'block-facet-gallery-tag' -> 'field_gallery_tag')
      if (blockId.includes('facet-gallery-tag')) {
        facetType = 'field_gallery_tag';
      } else if (blockId.includes('facet-stilus')) {
        facetType = 'field_stilus';
      } else if (blockId.includes('facet-szerkezet')) {
        facetType = 'field_szerkezet_anyaga';
      } else if (blockId.includes('facet-tetofedes')) {
        facetType = 'field_tetofedes_anyaga';
      } else if (blockId.includes('facet-oldalzaras')) {
        facetType = 'field_oldalzaras_anyaga';
      } else if (blockId.includes('facet-termek')) {
        facetType = 'field_termek_tipus';
      } else if (blockId.includes('facet-cimkek')) {
        facetType = 'field_cimkek';
      }

      // If this facet is not active, disable all its links
      if (facetType && !activeFacets.includes(facetType)) {
        const links = block.querySelectorAll('.facet-item a');
        links.forEach(function (link) {
          link.classList.add('facet-link-disabled');
          link.setAttribute('data-disabled', 'true');
        });
      }
    });
  }

  /**
   * Show message when filter limit is reached.
   */
  function showLimitMessage() {
    // Check if message already exists
    if (document.querySelector('.filter-limit-message')) {
      return;
    }

    // Create message element
    const message = document.createElement('div');
    message.className = 'filter-limit-message';
    message.innerHTML = '<strong>Maximum 3 szűrő kombinálható.</strong> Kérjük, távolítson el egy aktív szűrőt egy új kiválasztásához.';

    // Insert message at the top of the first facet block
    const firstFacetBlock = document.querySelector('[id*="block-facet"]');
    if (firstFacetBlock) {
      firstFacetBlock.parentNode.insertBefore(message, firstFacetBlock);
    }
  }

  /**
   * Add click listeners to facet links to enforce limit.
   * @param {Array} activeFacets - Array of currently active facet identifiers
   */
  function addClickListeners(activeFacets) {
    const facetLinks = document.querySelectorAll('[id*="block-facet"] .facet-item a');

    facetLinks.forEach(function (link) {
      link.addEventListener('click', function (e) {
        // If link is disabled, prevent navigation
        if (link.getAttribute('data-disabled') === 'true') {
          e.preventDefault();

          // Show temporary warning
          showTemporaryWarning(link);

          return false;
        }

        // If this is a new filter (not deselecting an active one)
        const href = link.getAttribute('href');
        let isRemovingFilter = false;

        // Check if clicking this link would remove a filter
        // (Active filters typically have .is-active class)
        if (link.classList.contains('is-active') || link.closest('li')?.classList.contains('is-active')) {
          isRemovingFilter = true;
        }

        // If adding a new filter and we're at the limit, prevent it
        if (!isRemovingFilter && activeFacets.length >= MAX_FILTERS) {
          e.preventDefault();
          showTemporaryWarning(link);
          return false;
        }
      });
    });
  }

  /**
   * Show temporary warning message near the clicked link.
   * @param {Element} link - The link element that was clicked
   */
  function showTemporaryWarning(link) {
    // Remove any existing warnings
    const existingWarnings = document.querySelectorAll('.filter-warning-tooltip');
    existingWarnings.forEach(function (warning) {
      warning.remove();
    });

    // Create warning tooltip
    const warning = document.createElement('div');
    warning.className = 'filter-warning-tooltip';
    warning.textContent = 'Maximum 3 szűrő! Távolítson el egyet az új kiválasztásához.';

    // Position near the link
    link.parentNode.appendChild(warning);

    // Remove after 3 seconds
    setTimeout(function () {
      warning.remove();
    }, 3000);
  }

})(Drupal, once);

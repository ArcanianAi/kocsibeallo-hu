(function (Drupal) {
  'use strict';

  /**
   * Remove contextual-region class from ajanlatkeres webform.
   *
   * This ensures consistent CSS classes for HubSpot/Make integration.
   */
  Drupal.behaviors.webformCustomRemoveContextual = {
    attach: function (context) {
      var forms = context.querySelectorAll('form[id*="webform-submission-ajanlatkeres"].contextual-region');
      forms.forEach(function (form) {
        form.classList.remove('contextual-region');
      });
    }
  };

})(Drupal);

(function () {
  'use strict';

  // Hungarian month abbreviations
  const monthNames = {
    '01': 'jan',
    '02': 'feb',
    '03': 'már',
    '04': 'ápr',
    '05': 'máj',
    '06': 'jún',
    '07': 'júl',
    '08': 'aug',
    '09': 'szep',
    '10': 'okt',
    '11': 'nov',
    '12': 'dec'
  };

  function formatBlogDates() {
    // Find all time elements in blog posts
    const timeElements = document.querySelectorAll('.view-blog article footer time[datetime]');

    timeElements.forEach(function(timeElement) {
      const datetime = timeElement.getAttribute('datetime');
      if (!datetime) return;

      // Parse datetime (format: 2025-07-07T16:17:07+02:00)
      const dateParts = datetime.split('T')[0].split('-');
      const year = dateParts[0];
      const month = dateParts[1];
      const day = dateParts[2];

      // Get month abbreviation
      const monthAbbr = monthNames[month] || month;

      // Remove leading zero from day
      const dayNumber = parseInt(day, 10);

      // Create date display elements
      const daySpan = document.createElement('span');
      daySpan.className = 'blog-date-day';
      daySpan.textContent = dayNumber;

      const monthSpan = document.createElement('span');
      monthSpan.className = 'blog-date-month';
      monthSpan.textContent = monthAbbr;

      // Clear time element and add new structure
      timeElement.innerHTML = '';
      timeElement.appendChild(daySpan);
      timeElement.appendChild(monthSpan);
      timeElement.classList.add('blog-date-formatted');
    });
  }

  // Run when DOM is loaded
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', formatBlogDates);
  } else {
    formatBlogDates();
  }

})();

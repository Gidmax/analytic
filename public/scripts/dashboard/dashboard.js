(function($) {
  'use strict';

  var getRandomArbitrary = function() {
    return Math.round(Math.random() * 100);
  };

  var visitor = [    
    [12, getRandomArbitrary()],
    [13, getRandomArbitrary()],
    [14, getRandomArbitrary()],
    [15, getRandomArbitrary()],
    [16, getRandomArbitrary()],
    [17, getRandomArbitrary()],
    [18, getRandomArbitrary()],
    [19, getRandomArbitrary()],
    [20, getRandomArbitrary()]
  ];

  var lineData = [{
    data: visitor,
    color: $.constants.success
  }];

  /******** Line chart widget ********/
  /*jshint -W030 */
  $.plot($('.dashboard-line'), lineData, {
    series: {
      lines: {
        show: false,
        lineWidth: 0
      },
      splines: {
        show: true,
        lineWidth: 1,
        fill: 0.5
      }
    },
    grid: {
      borderWidth: 1,
      color: 'rgba(0,0,0,0.02)'
    },
    yaxis: {
      color: 'rgba(0,0,0,0.02)'
    },
    xaxis: {
      mode: 'categories'
    }
  });

  /******** Notification ********/
  noty({
   theme: 'app-noty',
    text: 'Welcome! You are now using Milestone Bootstrap 4 dashboard template.',
    type: 'success',
    timeout: 10000,
    layout: 'topRight',
    closeWith: ['button', 'click'],
    animation: {
      open: 'animated fadeInDown', // Animate.css class names
      close: 'animated fadeOutUp', // Animate.css class names
    }
  });
})(jQuery);

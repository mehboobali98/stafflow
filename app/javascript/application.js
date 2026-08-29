require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("./channels")
window.$ = window.jQuery = require("jquery")
require("./settings")
require('./user')
require("bootstrap")
import "chartkick/chart.js"
document.addEventListener("turbolinks:load", function() {
  $(function () {
    $('[data-toggle="tooltip"]').tooltip();
    $('[data-toggle="popover"]').popover();
  })
})

$(document).on('click', '.leave-pagination-wrapper a', function(event) {
  event.preventDefault();
  $.ajax({
    type: 'GET',
    url: this.href,
    dataType: 'script'
  });
});

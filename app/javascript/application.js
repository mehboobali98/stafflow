require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("./channels")
window.$ = window.jQuery = require("jquery")
// Registers itself on the jQuery above. Nothing here calls it - the
// .select2() call is in show_applied_leaves.js, a separate bundle that
// reads jQuery off window, so dropping this breaks that page and not this one.
require("select2")
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

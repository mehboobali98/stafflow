require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
window.$ = window.jQuery = require("jquery")
// Under CommonJS select2's UMD wrapper exports a factory rather than
// registering itself, so the call is what puts .select2() on the jQuery above.
// The only caller is show_applied_leaves.js, a separate bundle that reads
// jQuery back off window.
require("select2")()
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

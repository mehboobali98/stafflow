require("@rails/ujs").start()
import "@hotwired/turbo"
import "./controllers"
require("@rails/activestorage").start()
window.$ = window.jQuery = require("jquery")
// Under CommonJS select2's UMD wrapper exports a factory rather than
// registering itself, so the call is what puts .select2() on the jQuery above.
// The only caller is show_applied_leaves.js, a separate bundle that reads
// jQuery back off window.
require("select2")()

// Turbo snapshots a page on the way out and restores that snapshot on a back
// navigation. select2 builds its control as a sibling of the select it wraps,
// so the snapshot carries that markup, and the bundle re-running on restore
// builds a second control beside the first. Tearing it down before the
// snapshot is taken leaves one control per select. turbolinks did not need
// this - measured, one container both ways - so it arrived with Turbo.
//
// This listener is registered here, in the bundle the layout loads in <head>,
// rather than beside the .select2() call in show_applied_leaves.js: body
// bundles are re-executed on every visit, and a listener added there would
// accumulate one copy per navigation. The class is select2's own marker for a
// select it has taken over, so the call is a no-op on a page without one.
document.addEventListener("turbo:before-cache", function () {
  $("#applied_leave_member_id.select2-hidden-accessible").select2("destroy")
})
require('./user')
require("bootstrap")
import "chartkick/chart.js"

$(document).on('click', '.leave-pagination-wrapper a', function(event) {
  event.preventDefault();
  $.ajax({
    type: 'GET',
    url: this.href,
    dataType: 'script'
  });
});

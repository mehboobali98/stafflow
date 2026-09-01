import { Controller } from "@hotwired/stimulus"

// Slugs the company name into the subdomain the tenant will be reached at, and
// shows it under the field as the URL it is about to become.
//
// This existed twice, character for character: once in signup.js, which the
// sign-up page loaded, and once at the top of user.js, which is bundled into
// application.js and therefore ran on every page in the application. Both bound
// keyup on #company and wrote the same value to the same two elements, so on
// the one page that has a #company field the work was simply done twice. That
// is why neither copy was ever noticed.
export default class extends Controller {
  static targets = ["source", "field", "preview"]

  update() {
    const subdomain = this.sourceTarget.value.replace(/[^A-Z0-9]/gi, "").toLowerCase()

    this.fieldTarget.value = subdomain
    this.previewTarget.textContent = subdomain
  }
}
